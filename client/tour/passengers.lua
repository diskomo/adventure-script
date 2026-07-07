-- Passenger sync, role changes, roster, gather commands, and elections.

AdventureTours = AdventureTours or {}

local function getBusNetId()
    local bus = AdventureTours.Get('theTourBus')
    if bus and DoesEntityExist(bus) then
        return VehToNet(bus)
    end
    return 0
end

local function isInGuideBus()
    local guideBusNetId = AdventureTours.Get('guideBusNetId') or 0
    if guideBusNetId == 0 then
        return false
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        return false
    end

    return VehToNet(vehicle) == guideBusNetId
end

function AdventureTours.IsTourGuide()
    return AdventureTours.Get('isGuide') == true
end

function AdventureTours.IsFollowingTour()
    return AdventureTours.Get('following') ~= false
end

local function applyGuideRole(gainedGuide)
    if gainedGuide then
        AdventureTours.InitializeGuideDefaults()
        AdventureTours.Notify(Branding.guideYouAreGuideMessage, 'success')
    else
        AdventureTours.Set('spawnModeEnabled', false)
        AdventureTours.SetSuperdriveEnabled(false)
        AdventureTours.DeleteSpawnedVehicles()
        AdventureTours.DeleteTourBus()
        AdventureTours.Set('tourActive', false)
        AdventureTours.Set('currentTourStopIndex', 0)
        AdventureTours.CloseL3Menu()
    end
end

local function applyServerState(payload)
    if not payload then
        return
    end

    AdventureTours.Set('guideId', payload.guideId)
    AdventureTours.Set('guideName', payload.guideName)
    AdventureTours.Set('sessionActive', payload.tourActive == true)
    AdventureTours.Set('guideBusNetId', tonumber(payload.busNetId) or 0)
    AdventureTours.Set('serverStopIndex', tonumber(payload.stopIndex) or 0)
    AdventureTours.Set('serverLocationIndex', tonumber(payload.locationIndex) or 1)
    AdventureTours.Set('tourRoster', payload.roster or {})
    AdventureTours.Set('nextStopVote', payload.nextStopVote or { votes = 0, passengerCount = 0, threshold = 0, thresholdMet = false })
    AdventureTours.Set('election', payload.election)

    local myServerId = GetPlayerServerId(PlayerId())
    local myEntry = nil
    for _, entry in ipairs(payload.roster or {}) do
        if entry.id == myServerId then
            myEntry = entry
            break
        end
    end

    if myEntry then
        AdventureTours.Set('following', myEntry.following ~= false)
        AdventureTours.Set('ready', myEntry.ready == true)
        AdventureTours.Set('helpState', myEntry.help)
        AdventureTours.Set('nextStopVoted', myEntry.nextStopVote == true)
    end
end

function AdventureTours.WarpPedToBus(busNetId)
    busNetId = tonumber(busNetId) or 0
    if busNetId == 0 then
        return false
    end

    local vehicle = NetToVeh(busNetId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    local ped = PlayerPedId()
    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    for seat = 0, maxSeats - 1 do
        if IsVehicleSeatFree(vehicle, seat) then
            TaskWarpPedIntoVehicle(ped, vehicle, seat)
            return true
        end
    end

    local heading = GetEntityHeading(vehicle)
    local offset = GetOffsetFromEntityInWorldCoords(vehicle, 3.0, 0.0, 0.0)
    SetEntityCoords(ped, offset.x, offset.y, offset.z, false, false, false, false)
    SetEntityHeading(ped, heading)
    return true
end

function AdventureTours.TeleportToTourStopIndex(stopIndex, locationIndex)
    stopIndex = tonumber(stopIndex)
    locationIndex = tonumber(locationIndex) or 1
    if not stopIndex or stopIndex < 1 or not TourStops[stopIndex] then
        return
    end

    AdventureTours.TeleportPlayerToTourStop(TourStops[stopIndex], locationIndex)
end

local function getPlayerDistance(playerId)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local targetPed = GetPlayerPed(playerId)
    if targetPed == 0 then
        return nil
    end
    return #(myCoords - GetEntityCoords(targetPed))
end

local function getRosterPresence(serverId)
    if serverId == AdventureTours.Get('guideId') then
        return 'guide'
    end

    local guideBusNetId = AdventureTours.Get('guideBusNetId') or 0
    local playerId = GetPlayerFromServerId(serverId)
    if playerId == -1 then
        return 'away'
    end

    local ped = GetPlayerPed(playerId)
    if ped == 0 then
        return 'away'
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if guideBusNetId ~= 0 and vehicle ~= 0 and VehToNet(vehicle) == guideBusNetId then
        return 'on_bus'
    end

    local stopIndex = AdventureTours.IsTourGuide()
        and AdventureTours.Get('currentTourStopIndex')
        or AdventureTours.Get('serverStopIndex')

    if stopIndex and stopIndex > 0 and TourStops[stopIndex] then
        local locIndex = AdventureTours.IsTourGuide()
            and (AdventureTours.Get('currentTourLocationIndex') or 1)
            or AdventureTours.Get('serverLocationIndex')
        local tourStop = TourStops[stopIndex]
        local locations = tourStop.locations
        if locations then
            local location = locations[locIndex]
            if location and location.coords then
                local dist = #(GetEntityCoords(ped) - location.coords)
                if dist <= (Branding.awayDistance or 75.0) then
                    return 'near_stop'
                end
            end
        end
    end

    return 'away'
end

function AdventureTours.GetOnlinePlayersForNui()
    local myServerId = GetPlayerServerId(PlayerId())
    local players = {}

    for _, playerId in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(playerId)
        if serverId ~= myServerId then
            local distance = getPlayerDistance(playerId)
            players[#players + 1] = {
                id = serverId,
                name = GetPlayerName(playerId) or ('Player %d'):format(serverId),
                distance = distance and math.floor(distance + 0.5) or nil,
                isGuide = serverId == AdventureTours.Get('guideId'),
            }
        end
    end

    table.sort(players, function(a, b)
        if a.isGuide ~= b.isGuide then
            return a.isGuide
        end
        local distA = a.distance or 999999
        local distB = b.distance or 999999
        if distA ~= distB then
            return distA < distB
        end
        return (a.name or ''):lower() < (b.name or ''):lower()
    end)

    return players
end

function AdventureTours.GetTourRosterForNui()
    local roster = AdventureTours.Get('tourRoster') or {}
    local enriched = {}
    for _, entry in ipairs(roster) do
        if entry and entry.id then
            enriched[#enriched + 1] = {
                id = entry.id,
                name = entry.name or ('Player %d'):format(entry.id),
                ready = entry.ready,
                help = entry.help,
                nextStopVote = entry.nextStopVote,
                following = entry.following,
                isGuide = entry.isGuide,
                presence = getRosterPresence(entry.id),
            }
        end
    end
    return enriched
end

function AdventureTours.TransferGuide(targetId)
    targetId = tonumber(targetId)
    if targetId and AdventureTours.IsTourGuide() then
        TriggerServerEvent('adventure_tours:transferGuide', targetId)
    end
end

function AdventureTours.SetFollowing(following)
    TriggerServerEvent('adventure_tours:setFollowing', following == true)
end

function AdventureTours.SetReady(ready)
    TriggerServerEvent('adventure_tours:setReady', ready == true)
end

function AdventureTours.RequestHelp(helpType)
    TriggerServerEvent('adventure_tours:requestHelp', helpType)
end

function AdventureTours.VoteNextStop(voted)
    TriggerServerEvent('adventure_tours:voteNextStop', voted == true)
end

function AdventureTours.StartElection(candidateId)
    candidateId = tonumber(candidateId)
    if candidateId and not AdventureTours.IsTourGuide() then
        TriggerServerEvent('adventure_tours:startElection', candidateId)
    end
end

function AdventureTours.CastElectionVote(yes)
    TriggerServerEvent('adventure_tours:castVote', yes == true)
end

function AdventureTours.GatherPassengers(mode)
    if not AdventureTours.IsTourGuide() then
        return
    end

    if mode ~= 'bus' and mode ~= 'stop' then
        return
    end

    if mode == 'bus' then
        local busNetId = getBusNetId()
        if busNetId == 0 then
            return
        end
        TriggerServerEvent('adventure_tours:updateSessionBus', busNetId)
    end

    TriggerServerEvent('adventure_tours:gatherPassengers', mode)
end

function AdventureTours.RefreshPassengerData()
    TriggerServerEvent('adventure_tours:requestRoster')
end

function AdventureTours.PublishTourSessionStart()
    local busNetId = getBusNetId()
    TriggerServerEvent('adventure_tours:startTourSession',
        AdventureTours.Get('currentTourStopIndex'),
        AdventureTours.Get('currentTourLocationIndex') or 1,
        busNetId)
end

function AdventureTours.PublishTourSync()
    if not AdventureTours.Get('tourActive') then
        return
    end

    local busNetId = getBusNetId()
    TriggerServerEvent('adventure_tours:syncTourStop',
        AdventureTours.Get('currentTourStopIndex'),
        AdventureTours.Get('currentTourLocationIndex') or 1,
        busNetId)
end

function AdventureTours.PublishTourSessionEnd()
    TriggerServerEvent('adventure_tours:endTourSession')
end

RegisterNetEvent('adventure_tours:roleChanged', function(isGuide, guideId, guideName)
    local wasGuide = AdventureTours.Get('isGuide') == true
    local hadGuide = AdventureTours.Get('guideId') ~= nil

    AdventureTours.Set('isGuide', isGuide == true)
    AdventureTours.Set('guideId', guideId)
    AdventureTours.Set('guideName', guideName)

    if isGuide and not wasGuide then
        applyGuideRole(true)
    elseif not isGuide and wasGuide then
        applyGuideRole(false)
        if guideName then
            AdventureTours.Notify((Branding.guideYouArePassengerMessage):format(guideName), 'inform')
        end
    elseif not isGuide and not hadGuide and guideName then
        AdventureTours.Notify((Branding.guideYouArePassengerMessage):format(guideName), 'inform')
    end

    AdventureTours.AfterAction()
end)

RegisterNetEvent('adventure_tours:serverState', function(payload)
    applyServerState(payload)
    AdventureTours.AfterAction()
end)

RegisterNetEvent('adventure_tours:syncTourStop', function(stopIndex, locationIndex)
    if AdventureTours.IsTourGuide() or not AdventureTours.IsFollowingTour() then
        return
    end

    if isInGuideBus() then
        return
    end

    AdventureTours.TeleportToTourStopIndex(stopIndex, locationIndex)
end)

RegisterNetEvent('adventure_tours:gatherToBus', function(busNetId)
    if AdventureTours.IsTourGuide() or not AdventureTours.IsFollowingTour() then
        return
    end

    if isInGuideBus() then
        return
    end

    AdventureTours.Set('guideBusNetId', tonumber(busNetId) or 0)
    if not AdventureTours.WarpPedToBus(busNetId) then
        AdventureTours.Notify('Could not reach the tour bus.', 'error')
    end
end)

RegisterNetEvent('adventure_tours:gatherToStop', function(stopIndex, locationIndex)
    if AdventureTours.IsTourGuide() or not AdventureTours.IsFollowingTour() then
        return
    end

    if isInGuideBus() then
        return
    end

    AdventureTours.TeleportToTourStopIndex(stopIndex, locationIndex)
end)

RegisterNetEvent('adventure_tours:rosterUpdated', function(roster, counts, sessionActive, stopIndex, locationIndex, busNetId, nextStopVote)
    AdventureTours.Set('tourRoster', roster or {})
    AdventureTours.Set('rosterCounts', counts or { passengers = 0 })
    AdventureTours.Set('sessionActive', sessionActive == true)
    AdventureTours.Set('guideBusNetId', tonumber(busNetId) or 0)
    AdventureTours.Set('serverStopIndex', tonumber(stopIndex) or 0)
    AdventureTours.Set('serverLocationIndex', tonumber(locationIndex) or 1)
    if nextStopVote then
        AdventureTours.Set('nextStopVote', nextStopVote)
    end
    AdventureTours.AfterAction()
end)

RegisterNetEvent('adventure_tours:helpSignal', function(playerId, playerName, helpType, message)
    if not AdventureTours.IsTourGuide() then
        return
    end

    AdventureTours.Notify(message, helpType == 'injured' and 'error' or 'warning')
    AdventureTours.AfterAction()
end)

RegisterNetEvent('adventure_tours:nextStopVoteThreshold', function(votes, passengerCount)
    if not AdventureTours.IsTourGuide() then
        return
    end

    AdventureTours.Notify((Branding.nextStopVoteThresholdMessage):format(votes, passengerCount), 'inform')
end)

RegisterNetEvent('adventure_tours:electionBallot', function(candidateId, candidateName, expiresAt)
    if AdventureTours.IsTourGuide() then
        return
    end

    CreateThread(function()
        local response = lib.alertDialog({
            header = 'Adventure Tours',
            content = (Branding.electionBallotMessage):format(candidateName),
            centered = true,
            cancel = true,
            labels = {
                confirm = 'Yes',
                cancel = 'No',
            },
        })

        if response == 'confirm' then
            TriggerServerEvent('adventure_tours:castVote', true)
        elseif response == 'cancel' then
            TriggerServerEvent('adventure_tours:castVote', false)
        end
    end)
end)

CreateThread(function()
    Wait(2000)
    TriggerServerEvent('adventure_tours:requestState')
end)
