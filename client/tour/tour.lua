-- Tour stop navigation, rainbow modes, start/stop/reset, and bus checks.

local function getCurrentTourStop(index)
    return TourStops[index]
end

local function setVehicleForTourStop(tourStop)
    if not tourStop or not tourStop.vehicles then
        return
    end

    local firstVehicle = tourStop.vehicles[1]
    if firstVehicle then
        AdventureTours.SetSpawnVehicle(firstVehicle.id, firstVehicle.options, firstVehicle.mods)
    end
end

function AdventureTours.TeleportPlayerToTourStop(tourStop, locationIndex)
    if not tourStop or not tourStop.locations then
        return
    end

    local location = tourStop.locations[locationIndex or 1]
    if not location or not location.coords then
        return
    end

    AdventureTours.TeleportPedOrVehicle(location.coords)
end

function AdventureTours.GoToNextTourStop()
    if not AdventureTours.Get('tourActive') then
        return
    end

    local index = AdventureTours.Get('currentTourStopIndex')
    if index < 1 then
        index = 0
    end
    index = index + 1
    if index > #TourStops then
        index = 1
    end
    AdventureTours.Set('currentTourStopIndex', index)
    AdventureTours.Set('currentTourLocationIndex', 1)

    local currentTourStop = getCurrentTourStop(index)
    if not currentTourStop then
        return
    end

    setVehicleForTourStop(currentTourStop)
    AdventureTours.TeleportPlayerToTourStop(currentTourStop, 1)
    AdventureTours.PublishTourSync()
end

function AdventureTours.GoToPreviousTourStop()
    if not AdventureTours.Get('tourActive') then
        return
    end

    local index = AdventureTours.Get('currentTourStopIndex')
    if index < 1 then
        return
    end
    index = index - 1
    if index < 1 then
        index = #TourStops
    end
    AdventureTours.Set('currentTourStopIndex', index)
    AdventureTours.Set('currentTourLocationIndex', 1)

    local currentTourStop = getCurrentTourStop(index)
    if not currentTourStop then
        return
    end

    setVehicleForTourStop(currentTourStop)
    AdventureTours.TeleportPlayerToTourStop(currentTourStop, 1)
    AdventureTours.PublishTourSync()
end

function AdventureTours.GoToTourLocation(locationName)
    for stopIndex, tourStop in ipairs(TourStops) do
        local locations = tourStop.locations
        if locations then
            for locIndex, location in ipairs(locations) do
                if location.name == locationName and location.coords then
                    AdventureTours.TeleportPedOrVehicle(location.coords)

                    AdventureTours.Set('currentTourStopIndex', stopIndex)
                    AdventureTours.Set('currentTourLocationIndex', locIndex)
                    AdventureTours.PublishTourSync()
                    return true
                end
            end
        end
    end

    return false
end

local function resolveCurrentStopIndex()
    local index = AdventureTours.Get('currentTourStopIndex')
    if index < 1 or index > #TourStops then
        if not AdventureTours.Get('tourActive') then
            return nil
        end
        index = 1
        AdventureTours.Set('currentTourStopIndex', index)
        AdventureTours.Set('currentTourLocationIndex', 1)
    end
    return index
end

function AdventureTours.CycleLocationForCurrentStop(direction)
    if not AdventureTours.Get('tourActive') then
        return nil
    end

    direction = direction or 1

    local index = resolveCurrentStopIndex()
    if not index then
        return nil
    end
    local tourStop = TourStops[index]
    if not tourStop or not tourStop.locations or #tourStop.locations == 0 then
        return nil
    end

    local locIndex = AdventureTours.Get('currentTourLocationIndex') or 1
    if locIndex < 1 or locIndex > #tourStop.locations then
        locIndex = 1
    end

    local locationCount = #tourStop.locations
    local nextIndex = ((locIndex - 1 + direction) % locationCount) + 1
    AdventureTours.Set('currentTourLocationIndex', nextIndex)
    AdventureTours.TeleportPlayerToTourStop(tourStop, nextIndex)
    AdventureTours.PublishTourSync()
    local location = tourStop.locations[nextIndex]
    return location and location.name or nil
end

function AdventureTours.CycleSpawnVehicleForCurrentStop(direction)
    if not AdventureTours.Get('tourActive') then
        return nil
    end

    direction = direction or 1

    local index = resolveCurrentStopIndex()
    if not index then
        return nil
    end
    local tourStop = TourStops[index]
    if not tourStop or not tourStop.vehicles or #tourStop.vehicles == 0 then
        return nil
    end

    local currentHash = AdventureTours.Get('spawnTargetHash')
    local currentIdx = 1
    for i, vehicle in ipairs(tourStop.vehicles) do
        if joaat(vehicle.id) == currentHash then
            currentIdx = i
            break
        end
    end

    local vehicleCount = #tourStop.vehicles
    local nextIdx = ((currentIdx - 1 + direction) % vehicleCount) + 1
    local nextVehicle = tourStop.vehicles[nextIdx]
    if not nextVehicle then
        return nil
    end

    AdventureTours.SetSpawnVehicle(nextVehicle.id, nextVehicle.options, nextVehicle.mods)
    return nextVehicle.name
end

function AdventureTours.JumpToFirstVehicleForCurrentStop()
    if not AdventureTours.Get('tourActive') then
        return nil
    end

    local index = resolveCurrentStopIndex()
    if not index then
        return nil
    end
    local tourStop = TourStops[index]
    if not tourStop or not tourStop.vehicles or #tourStop.vehicles == 0 then
        return nil
    end

    local firstVehicle = tourStop.vehicles[1]
    AdventureTours.SetSpawnVehicle(firstVehicle.id, firstVehicle.options, firstVehicle.mods)
    return firstVehicle.name
end

function AdventureTours.CanUseL3Menu()
    if not AdventureTours.IsTourGuide() then
        return false
    end

    if AdventureTours.Get('menuOpen') then
        return false
    end

    if AdventureTours.IsDrivingBus() then
        return true
    end

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        return false
    end

    return true
end

function AdventureTours.GetL3MenuVariant()
    if AdventureTours.IsDrivingBus() then
        return 'bus'
    end

    return 'foot'
end

function AdventureTours.IsDrivingBus()
    local playerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    if playerVehicle ~= 0 then
        local vehicleModel = GetEntityModel(playerVehicle)
        local busModelHash = joaat(AdventureTours.Get('busType'))
        return vehicleModel == busModelHash
    end

    return false
end

function AdventureTours.DeleteTourBus()
    local tourBus = AdventureTours.Get('theTourBus')
    if tourBus then
        AdventureTours.DeleteEntitySafe(tourBus)
        AdventureTours.Set('theTourBus', nil)
    end
end

local function getStopAtIndex(index)
    return index and index > 0 and TourStops[index] or nil
end

function AdventureTours.InitializeStopRainbowModes()
    local modes = {}
    for index, tourStop in ipairs(TourStops) do
        modes[index] = tourStop.rainbowMode == true
    end
    AdventureTours.Set('stopRainbowModes', modes)
end

function AdventureTours.GetStopRainbowMode(stopIndex)
    local modes = AdventureTours.Get('stopRainbowModes')
    if modes and modes[stopIndex] ~= nil then
        return modes[stopIndex] == true
    end

    local tourStop = getStopAtIndex(stopIndex)
    return tourStop and tourStop.rainbowMode == true or false
end

function AdventureTours.SetStopRainbowMode(stopIndex, enabled)
    if not getStopAtIndex(stopIndex) then
        return false
    end

    local modes = AdventureTours.Get('stopRainbowModes') or {}
    modes[stopIndex] = enabled == true
    AdventureTours.Set('stopRainbowModes', modes)
    return true
end

function AdventureTours.ToggleStopRainbowMode(stopIndex)
    local enabled = not AdventureTours.GetStopRainbowMode(stopIndex)
    if not AdventureTours.SetStopRainbowMode(stopIndex, enabled) then
        return nil
    end
    return enabled
end

function AdventureTours.GetStopRainbowModesForNui()
    local modes = {}
    for index in ipairs(TourStops) do
        modes[index] = AdventureTours.GetStopRainbowMode(index)
    end
    return modes
end

local function applyTourCleanup(options)
    if options.cancelAnimation then
        AdventureTours.CancelGuideAction()
    end
    if options.cleanupGrid then
        AdventureTours.CleanupGridSpawn()
    end
    if options.deleteBus and not AdventureTours.IsDrivingBus() then
        AdventureTours.DeleteTourBus()
    end
    if options.deleteSpawned then
        AdventureTours.DeleteSpawnedVehicles()
    end
    if options.disableSpawn then
        AdventureTours.Set('spawnModeEnabled', false)
    end

    local stopIndex = AdventureTours.Get('currentTourStopIndex')
    if options.clearIndex then
        AdventureTours.Set('currentTourStopIndex', 0)
        AdventureTours.Set('currentTourLocationIndex', 0)
    elseif options.resetIndex then
        stopIndex = 1
        AdventureTours.Set('currentTourStopIndex', stopIndex)
        AdventureTours.Set('currentTourLocationIndex', 1)
    end

    local stop = getStopAtIndex(stopIndex)
    if options.resetVehicle and stop then
        setVehicleForTourStop(stop)
    end

    if options.teleport then
        local teleportStop = options.teleportStop or stop
        if teleportStop then
            AdventureTours.TeleportPlayerToTourStop(teleportStop, 1)
        end
    end
end

function AdventureTours.StartTour()
    applyTourCleanup({
        cancelAnimation = true,
        cleanupGrid = true,
        deleteBus = true,
        deleteSpawned = true,
        disableSpawn = true,
        resetIndex = true,
        resetVehicle = true,
        teleport = true,
    })
    AdventureTours.Set('tourActive', true)
    if AdventureTours.Get('autoChat') then
        TriggerServerEvent('adventure_tours:sendChat', Branding.welcomeMessage)
    end
    AdventureTours.PublishTourSessionStart()
end

function AdventureTours.StopTour()
    if not AdventureTours.Get('tourActive') then
        return false
    end

    AdventureTours.Set('tourActive', false)

    applyTourCleanup({
        cancelAnimation = true,
        deleteBus = false,
        deleteSpawned = true,
        disableSpawn = true,
        clearIndex = true,
    })

    if AdventureTours.Get('autoChat') then
        TriggerServerEvent('adventure_tours:sendChat', Branding.thankYouMessage)
    end

    AdventureTours.PublishTourSessionEnd()

    return true
end

function AdventureTours.ResetStop()
    applyTourCleanup({
        cancelAnimation = true,
        cleanupGrid = true,
        deleteBus = true,
        deleteSpawned = true,
        resetVehicle = true,
        teleport = true,
    })
    AdventureTours.PublishTourSync()
end
