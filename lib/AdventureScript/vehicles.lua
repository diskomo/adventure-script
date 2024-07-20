local data = require('lib.AdventureScript.data')
local state = require('lib.AdventureScript.state')
local gridSpawn = require('lib.AdventureScript.gridspawn')

local VEHICLES = {}

local DEFAULT_VEHICLE_OPTIONS = {
    -- Enable low-grip drift tyres
    drift = false,
    -- Enable F1 wheel style (fat looking tyres)
    f1Wheels = false,
    -- Randomize the vehicle's livery
    randomLivery = false,
    -- Randomize the vehicle's primary and secondary colors
    randomColor = false
}

-- Sets the vehicle used for the grid spawner
-- @param hash: Hash of the vehicle
-- @param options: Options for the vehicle
-- @param modOverrides: Explicitly set vehicle mods
VEHICLES.setVehicle = function(hash, options, modOverrides)
    state.spawnModeEnabled = true -- automatically enable spawn mode when a vehicle is selected
    state.spawnTargetHash = hash
    state.spawnTargetDimensions = gridSpawn.getModelDimensions(hash)
    state.spawnTargetOptions = options or DEFAULT_VEHICLE_OPTIONS
    state.spawnTargetModOverrides = modOverrides or {}
end

-- Converts any old vehicle into an AdventureToy
-- @param veh: The vehicle entity
VEHICLES.makeAdventureVehicle = function(veh)
    local color = {
        r = math.random(0, 255),
        g = math.random(0, 255),
        b = math.random(0, 255)
    }
    local wheelColor = math.random(0, 80)
    if not state.spawnTargetOptions.randomColor then
        color = data.brandColor
        wheelColor = 37
    end

    if not DOES_ENTITY_EXIST(veh) then
        return
    end
    SET_ENTITY_INVINCIBLE(veh, true)
    SET_VEHICLE_MOD_KIT(veh, 0)
    -- This loop will set all of the vehicle modifications defined in defaultMods to their highest possible value
    for _, type in pairs(data.defaultMods) do
        SET_VEHICLE_MOD(veh, type, GET_NUM_VEHICLE_MODS(veh, type) - 1, true)
    end

    -- If the vehicle has explicit modifications defined
    for type, value in pairs(state.spawnTargetModOverrides) do
        SET_VEHICLE_MOD(veh, type, value, true)
    end

    -- low-grip drift tyres
    if state.spawnTargetOptions.drift then
        SET_DRIFT_TYRES(veh, true)
    else
        SET_DRIFT_TYRES(veh, false)
    end
    -- set wheels to f1 wheels
    if state.spawnTargetOptions.f1Wheels then
        SET_VEHICLE_WHEEL_TYPE(veh, 10)
        SET_VEHICLE_MOD(veh, 23, 3, true)
        SET_VEHICLE_MOD(veh, 24, 3, true)
    else
        -- default to offroad wheels
        SET_VEHICLE_WHEEL_TYPE(veh, 4)
        SET_VEHICLE_MOD(veh, 23, 8, false)
        SET_VEHICLE_MOD(veh, 24, 8, false)
    end

    -- set random livery
    -- local livery = -1
    -- if state.spawnTargetOptions.randomLivery then
    --     livery = math.random(1, GET_VEHICLE_LIVERY_COUNT(veh) - 1)
    -- end
    -- if livery ~= -1 then
    --     SET_VEHICLE_LIVERY(veh, livery)
    --     SET_VEHICLE_MOD(veh, 48, livery, true)
    -- end

    -- Branding 
    SET_VEHICLE_EXTRA_COLOURS(veh, wheelColor, wheelColor)
    SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, color.r, color.g, color.b)
    SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, color.r + 20, color.g + 20, color.b + 20)
    SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, 5) -- yankton plate
    SET_VEHICLE_NUMBER_PLATE_TEXT(veh, data.licensePlate)
    SET_VEHICLE_MOD(veh, 14, math.random(16, 23), true) -- horn (high note)
    TOGGLE_VEHICLE_MOD(veh, 22, true) -- xenon headlights
    SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, 6) -- gold tint headlights
end

-- Spawns the official Adventure Tours bus
VEHICLES.spawnAdventureToursBus = function()
    -- Reset spawn state
    state.spawnModeEnabled = false
    state.spawnTargetOptions = DEFAULT_VEHICLE_OPTIONS
    local playerPed = PLAYER_PED_ID()
    if not IS_PED_IN_ANY_VEHICLE(playerPed, false) then

        -- Get in old bus if it exists
        if state.theTourBus ~= nil then
            if DOES_ENTITY_EXIST(state.theTourBus) then
                SET_PED_INTO_VEHICLE(playerPed, state.theTourBus, -1)
                return
            end
        end

        -- Load a new bus
        local busModel = util.joaat('bus')
        REQUEST_MODEL(busModel)
        while not HAS_MODEL_LOADED(busModel) do
            util.yield(1000)
        end
        local playerPos = GET_ENTITY_COORDS(playerPed, false)
        local bus = CREATE_VEHICLE(busModel, playerPos.x + 5.0, playerPos.y + 5.0, playerPos.z,
            GET_ENTITY_HEADING(playerPed), true, false)

        VEHICLES.makeAdventureVehicle(bus)
        state.theTourBus = bus
        SET_PED_INTO_VEHICLE(playerPed, bus, -1)
        util.yield(1000)
    end
end

VEHICLES.deleteSpawnedVehicles = function()
    for _, car in pairs(state.spawnedVehicles) do
        if DOES_ENTITY_EXIST(car) then
            entities.delete_by_handle(car)
        end
    end
    state.spawnedVehicles = {}
end

VEHICLES.deleteVehiclesInArea = function()
    menu.trigger_commands("clearvehicles on")
    menu.trigger_commands("clearobjects off")
    menu.trigger_commands("cleararea")
end

return VEHICLES
