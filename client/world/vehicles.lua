-- Tour bus spawn, activity vehicle grid targets, and adventurify styling.

local function mergeOptions(options)
    return AdventureTours.CopyDefaultOptions(options)
end

function AdventureTours.SetSpawnVehicle(modelName, options, modOverrides)
    local hash = joaat(modelName)
    if not IsModelAVehicle(hash) then
        AdventureTours.Notify(('Model %s is not a vehicle.'):format(modelName), 'error')
        return false
    end

    AdventureTours.Set('spawnTargetHash', hash)
    AdventureTours.Set('spawnTargetDimensions', AdventureTours.GetModelDimensions(hash))
    AdventureTours.Set('spawnTargetOptions', mergeOptions(options))
    AdventureTours.Set('spawnTargetModOverrides', AdventureTours.CopyModOverrides(modOverrides))

    for _, tourStop in ipairs(TourStops) do
        local vehicles = tourStop.vehicles
        if vehicles then
            for _, vehicle in ipairs(vehicles) do
                if vehicle.id == modelName then
                    AdventureTours.Set('spawnTargetName', vehicle.name)
                    return true
                end
            end
        end
    end

    AdventureTours.Set('spawnTargetName', modelName)
    return true
end

function AdventureTours.MakeAdventureVehicle(veh)
    if not DoesEntityExist(veh) then
        return
    end

    local options = AdventureTours.Get('spawnTargetOptions') or DefaultVehicleOptions
    ---@type table<integer, integer>
    local modOverrides = AdventureTours.Get('spawnTargetModOverrides') or {}

    local colour
    local wheelColour = 37
    local stopIndex = AdventureTours.Get('currentTourStopIndex')
    if AdventureTours.GetStopRainbowMode(stopIndex) then
        colour = { r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255) }
        wheelColour = math.random(0, 80)
    else
        colour = GetBrandColour(AdventureTours.Get('brandColour'))
    end

    SetEntityInvincible(veh, true)
    SetVehicleModKit(veh, 0)

    for _, modType in ipairs(DefaultVehicleMods) do
        local count = GetNumVehicleMods(veh, modType)
        if count > 0 then
            SetVehicleMod(veh, modType, count - 1, true)
        end
    end

    for modType, value in pairs(modOverrides) do
        SetVehicleMod(veh, modType, value, true)
    end

    SetDriftTyresEnabled(veh, options.drift == true)

    if options.f1Wheels then
        SetVehicleWheelType(veh, 10)
        SetVehicleMod(veh, 23, 3, true)
        SetVehicleMod(veh, 24, 3, true)
    else
        SetVehicleWheelType(veh, 4)
        SetVehicleMod(veh, 23, 8, false)
        SetVehicleMod(veh, 24, 8, false)
    end

    if options.randomLivery then
        local liveryCount = GetVehicleLiveryCount(veh)
        if liveryCount > 0 then
            local livery = math.random(0, liveryCount - 1)
            SetVehicleLivery(veh, livery)
            SetVehicleMod(veh, VehicleMods.LIVERY, livery, true)
        end
    end

    SetVehicleExtraColours(veh, wheelColour, wheelColour)
    SetVehicleCustomPrimaryColour(veh, colour.r, colour.g, colour.b)
    SetVehicleCustomSecondaryColour(veh, colour.r + 20, colour.g + 20, colour.b + 20)
    SetVehicleNumberPlateTextIndex(veh, 5)
    SetVehicleNumberPlateText(veh, Branding.licensePlate)
    -- Random horn sound index (VehicleMods.HORNS = 16–23 on most vehicles).
    SetVehicleMod(veh, VehicleMods.HORNS, math.random(16, 23), true)
    ToggleVehicleMod(veh, VehicleMods.XENON_HEADLIGHTS, true)
    SetVehicleXenonLightsColor(veh, 6)
end

function AdventureTours.SpawnAdventureToursBus()
    AdventureTours.Set('spawnModeEnabled', false)
    AdventureTours.ResetSpawnOptions()

    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        return
    end

    local existingBus = AdventureTours.Get('theTourBus')
    if existingBus and DoesEntityExist(existingBus) then
        TaskWarpPedIntoVehicle(playerPed, existingBus, -1)
        return
    end

    local busModel = joaat(AdventureTours.Get('busType'))
    if not AdventureTours.LoadModel(busModel) then
        AdventureTours.Notify('Failed to load bus model.', 'error')
        return
    end

    local playerPos = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local bus = CreateVehicle(busModel, playerPos.x + 5.0, playerPos.y + 5.0, playerPos.z, heading, true, false)

    if bus == 0 then
        AdventureTours.Notify('Failed to spawn tour bus.', 'error')
        return
    end

    SetEntityAsMissionEntity(bus, true, true)
    AdventureTours.MakeAdventureVehicle(bus)
    AdventureTours.Set('theTourBus', bus)
    TaskWarpPedIntoVehicle(playerPed, bus, -1)
    SetModelAsNoLongerNeeded(busModel)
end

function AdventureTours.DeleteSpawnedVehicles()
    for _, vehicle in ipairs(AdventureTours.Get('spawnedVehicles')) do
        AdventureTours.DeleteEntitySafe(vehicle)
    end
    AdventureTours.Set('spawnedVehicles', {})
    AdventureTours.ClearSpawnUndoStack()
end

function AdventureTours.DeleteVehiclesInArea(radius)
    radius = radius or 100.0
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local tourBus = AdventureTours.Get('theTourBus')

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) then
            if vehicle ~= tourBus or not AdventureTours.IsDrivingBus() then
                local vehCoords = GetEntityCoords(vehicle)
                if #(coords - vehCoords) <= radius then
                    AdventureTours.DeleteEntitySafe(vehicle)
                end
            end
        end
    end

    AdventureTours.DeleteSpawnedVehicles()
end

function AdventureTours.AdventurifyCurrentVehicle()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        AdventureTours.MakeAdventureVehicle(vehicle)
    end
end

function AdventureTours.SetSpoilerOnCurrentVehicle(value)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        return
    end

    if value < -1 or value > GetNumVehicleMods(vehicle, 0) then
        return
    end

    SetVehicleMod(vehicle, 0, value, false)
end

function AdventureTours.TrackSpawnedVehicle(vehicle)
    local spawned = AdventureTours.Get('spawnedVehicles')
    spawned[#spawned + 1] = vehicle
    AdventureTours.Set('spawnedVehicles', spawned)
end

function AdventureTours.PushSpawnUndoBatch(vehicles)
    if not vehicles or #vehicles == 0 then
        return
    end

    local stack = AdventureTours.Get('spawnUndoStack')
    stack[#stack + 1] = vehicles
    AdventureTours.Set('spawnUndoStack', stack)
end

function AdventureTours.GetSpawnUndoCount()
    return #(AdventureTours.Get('spawnUndoStack') or {})
end

function AdventureTours.ClearSpawnUndoStack()
    AdventureTours.Set('spawnUndoStack', {})
end

function AdventureTours.UndoLastSpawn()
    local stack = AdventureTours.Get('spawnUndoStack')
    if #stack == 0 then
        return false
    end

    local batch = stack[#stack]
    stack[#stack] = nil
    AdventureTours.Set('spawnUndoStack', stack)

    local removed = {}
    for _, vehicle in ipairs(batch) do
        removed[vehicle] = true
        AdventureTours.DeleteEntitySafe(vehicle)
    end

    local spawned = AdventureTours.Get('spawnedVehicles')
    local remaining = {}
    for _, vehicle in ipairs(spawned) do
        if not removed[vehicle] then
            remaining[#remaining + 1] = vehicle
        end
    end
    AdventureTours.Set('spawnedVehicles', remaining)
    return true
end
