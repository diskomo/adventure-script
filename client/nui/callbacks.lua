-- NUI callbacks: closeMenu, goToLocation, setVehicle, playAction, tour controls, settings toggles.

local function nuiCallback(name, handler)
    RegisterNUICallback(name, function(data, cb)
        handler(data or {})
        cb('ok')
    end)
end

local function requireGuide()
    return AdventureTours.IsTourGuide()
end

local function handleCycleLocation(direction)
    if AdventureTours.CycleLocationForCurrentStop(direction) then
        AdventureTours.AfterAction()
    end
end

local function handleCycleVehicle(direction)
    if AdventureTours.CycleSpawnVehicleForCurrentStop(direction) then
        AdventureTours.AfterAction()
    end
end

local BOOLEAN_TOGGLES = {
    toggleSpawn = { key = 'spawnModeEnabled', guideOnly = true },
    toggleControls = { key = 'showOnScreenControls' },
    toggleMiniMenu = {
        key = 'miniMenuEnabled',
        apply = function()
            AdventureTours.UpdateMiniMenuFocus()
        end,
    },
    toggleSuperdrive = {
        guideOnly = true,
        get = function()
            return AdventureTours.Get('superdriveEnabled')
        end,
        set = function(enabled)
            AdventureTours.SetSuperdriveEnabled(enabled)
        end,
    },
    toggleAutoChat = { key = 'autoChat', guideOnly = true },
}

local function registerBooleanToggle(callbackName, config)
    nuiCallback(callbackName, function()
        if config.guideOnly and not requireGuide() then
            return
        end

        local getFn = config.get or function()
            return AdventureTours.Get(config.key)
        end
        local setFn = config.set or function(enabled)
            AdventureTours.Set(config.key, enabled)
        end
        local enabled = not getFn()
        setFn(enabled)
        if config.apply then
            config.apply(enabled)
        end
        AdventureTours.AfterAction()
    end)
end

for callbackName, config in pairs(BOOLEAN_TOGGLES) do
    registerBooleanToggle(callbackName, config)
end

nuiCallback('nuiReady', function()
    AdventureTours.SendNuiInit()
    AdventureTours.AfterAction()
    AdventureTours.UpdateMiniMenuFocus()
    TriggerServerEvent('adventure_tours:requestBanner')
    TriggerServerEvent('adventure_tours:requestState')
end)

nuiCallback('requestBanner', function()
    TriggerServerEvent('adventure_tours:requestBanner')
end)

nuiCallback('closeMenu', function()
    AdventureTours.CloseMenu()
end)

nuiCallback('goToLocation', function(data)
    if not requireGuide() then
        return
    end

    if data.name and AdventureTours.GoToTourLocation(data.name) then
        AdventureTours.AfterAction()
    end
end)

nuiCallback('setVehicle', function(data)
    if not requireGuide() then
        return
    end

    local stopIndex = tonumber(data.stopIndex)
    local stop = stopIndex and TourStops[stopIndex]
    if not stop then
        return
    end

    for _, vehicle in ipairs(stop.vehicles or {}) do
        if vehicle.id == data.id then
            if AdventureTours.SetSpawnVehicle(vehicle.id, vehicle.options, vehicle.mods) then
                if stopIndex then
                    AdventureTours.Set('currentTourStopIndex', stopIndex)
                end
                AdventureTours.AfterAction()
            end
            return
        end
    end
end)

nuiCallback('playAction', function(data)
    if data.id then
        AdventureTours.PlayGuideAction(data.id, data.variants)
    end
end)

nuiCallback('cancelAction', function()
    AdventureTours.CancelGuideAction()
end)

nuiCallback('sendChat', function(data)
    if not requireGuide() then
        return
    end

    if data.chatId then
        TriggerServerEvent('adventure_tours:sendChat', data.chatId)
    end
end)

nuiCallback('setColour', function(data)
    if not requireGuide() then
        return
    end

    if data.colour and Branding.colours[data.colour] then
        AdventureTours.Set('brandColour', data.colour)
        if AdventureTours.Get('outfitApplied') and GetEntityModel(PlayerPedId()) == joaat('mp_m_freemode_01') then
            AdventureTours.ApplyTourGuideOutfit(false)
        end
        AdventureTours.AfterAction()
    end
end)

nuiCallback('setBusType', function(data)
    if not requireGuide() then
        return
    end

    if data.busType == 'bus' or data.busType == 'tourbus' then
        AdventureTours.Set('busType', data.busType)
        AdventureTours.AfterAction()
    end
end)

nuiCallback('spawnBus', function()
    if not requireGuide() then
        return
    end

    AdventureTours.SpawnAdventureToursBus()
    AdventureTours.AfterAction()
end)

nuiCallback('nextStop', function()
    if not requireGuide() or not AdventureTours.IsDrivingBus() then
        return
    end

    AdventureTours.GoToNextTourStop()
    AdventureTours.AfterAction()
end)

nuiCallback('prevStop', function()
    if not requireGuide() or not AdventureTours.IsDrivingBus() then
        return
    end

    AdventureTours.GoToPreviousTourStop()
    AdventureTours.AfterAction()
end)

nuiCallback('cycleStopPrev', function()
    if not requireGuide() or not AdventureTours.Get('tourActive') then
        return
    end

    AdventureTours.GoToPreviousTourStop()
    AdventureTours.AfterAction()
end)

nuiCallback('cycleStopNext', function()
    if not requireGuide() or not AdventureTours.Get('tourActive') then
        return
    end

    AdventureTours.GoToNextTourStop()
    AdventureTours.AfterAction()
end)

nuiCallback('cycleLocationPrev', function()
    if not requireGuide() then
        return
    end

    handleCycleLocation(-1)
end)

nuiCallback('cycleLocationNext', function()
    if not requireGuide() then
        return
    end

    handleCycleLocation(1)
end)

nuiCallback('cycleVehiclePrev', function()
    if not requireGuide() then
        return
    end

    handleCycleVehicle(-1)
end)

nuiCallback('cycleVehicleNext', function()
    if not requireGuide() then
        return
    end

    handleCycleVehicle(1)
end)

nuiCallback('undoSpawn', function()
    if not requireGuide() then
        return
    end

    if AdventureTours.UndoLastSpawn() then
        AdventureTours.AfterAction()
    end
end)

nuiCallback('toggleStopRainbow', function(data)
    if not requireGuide() then
        return
    end

    local stopIndex = tonumber(data.stopIndex)
    if not stopIndex then
        return
    end

    if AdventureTours.ToggleStopRainbowMode(stopIndex) ~= nil then
        AdventureTours.AfterAction()
    end
end)

nuiCallback('resetStop', function()
    if not requireGuide() then
        return
    end

    AdventureTours.ResetStop()
    AdventureTours.AfterAction()
end)

nuiCallback('clearArea', function()
    if not requireGuide() then
        return
    end

    AdventureTours.DeleteVehiclesInArea()
    AdventureTours.AfterAction()
end)

nuiCallback('adventurify', function()
    if not requireGuide() then
        return
    end

    AdventureTours.AdventurifyCurrentVehicle()
end)

nuiCallback('setSpoiler', function(data)
    if not requireGuide() then
        return
    end

    local value = tonumber(data.value)
    if value == nil then
        return
    end

    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        return
    end

    AdventureTours.SetSpoilerOnCurrentVehicle(value)
end)

nuiCallback('applyOutfit', function()
    if not requireGuide() then
        return
    end

    AdventureTours.ApplyTourGuideOutfit(true)
end)

nuiCallback('setMiniMenuCorner', function(data)
    local corner = data.corner
    local valid = {
        ['top-left'] = true,
        ['top-right'] = true,
        ['bottom-left'] = true,
        ['bottom-right'] = true,
    }
    if not valid[corner] then
        return
    end

    AdventureTours.Set('miniMenuCorner', corner)
    AdventureTours.AfterAction()
end)

nuiCallback('openMainMenu', function()
    AdventureTours.OpenMainMenu()
end)

nuiCallback('startTour', function()
    if not requireGuide() or not AdventureTours.IsDrivingBus() then
        return
    end

    AdventureTours.StartTour()
    AdventureTours.AfterAction()
end)

nuiCallback('stopTour', function()
    if not requireGuide() then
        return
    end

    if AdventureTours.StopTour() then
        AdventureTours.AfterAction()
    end
end)

nuiCallback('refreshPlayers', function()
    AdventureTours.RefreshPassengerData()
    AdventureTours.AfterAction()
end)

nuiCallback('transferGuide', function(data)
    local targetId = tonumber(data.targetId)
    if targetId then
        AdventureTours.TransferGuide(targetId)
        AdventureTours.AfterAction()
    end
end)

nuiCallback('gatherToBus', function()
    AdventureTours.GatherPassengers('bus')
    AdventureTours.AfterAction()
end)

nuiCallback('gatherToStop', function()
    AdventureTours.GatherPassengers('stop')
    AdventureTours.AfterAction()
end)

nuiCallback('toggleFollowing', function()
    if requireGuide() then
        return
    end

    local following = not AdventureTours.IsFollowingTour()
    AdventureTours.SetFollowing(following)
    AdventureTours.Notify(following and Branding.followingEnabledMessage or Branding.followingDisabledMessage, 'inform')
    AdventureTours.AfterAction()
end)

nuiCallback('setReady', function(data)
    if requireGuide() then
        return
    end

    AdventureTours.SetReady(data.ready == true)
    AdventureTours.AfterAction()
end)

nuiCallback('requestHelp', function(data)
    if requireGuide() then
        return
    end

    AdventureTours.RequestHelp(data.helpType)
    AdventureTours.AfterAction()
end)

nuiCallback('voteNextStop', function(data)
    if requireGuide() then
        return
    end

    AdventureTours.VoteNextStop(data.voted == true)
    AdventureTours.AfterAction()
end)

nuiCallback('startElection', function(data)
    local candidateId = tonumber(data.candidateId)
    if candidateId then
        AdventureTours.StartElection(candidateId)
        AdventureTours.AfterAction()
    end
end)

nuiCallback('castVote', function(data)
    AdventureTours.CastElectionVote(data.yes == true)
    AdventureTours.AfterAction()
end)
