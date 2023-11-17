-- AdventureScript
-- by META IIII (aka AdventureTours)
util.require_natives('1681379138.g')
util.keep_running()

local scriptVersion = '0.9.9'

local data = require('lib.AdventureScript.data')
local controls = require('lib.AdventureScript.controls')
local helpers = require('lib.AdventureScript.helpers')
local gridSpawn = require('lib.AdventureScript.gridspawn')

-- A list of all passengers that have ever been on the tour (stored in lib/AdventureTours/passengers.txt)
local historicPassengers = helpers.loadPassengers()
-- Adventure Tours are supposed to be a passive affair, so this takes away the guide's weapons
helpers.removeWeapons()

-- Used as a list of passengers that are currently on the tour
local currentPassengers = {}

local spawnModeEnabled = false
local spawnTargetHash = util.joaat('manchez2')
local spawnTargetDimensions = gridSpawn.getModelDimensions(spawnTargetHash)
local spawnTargetOptions = {
    drift = false,
    f1Wheels = false,
    livery = -1,
    randomColor = false
}
local spawnTargetModOverrides = {}

-- Sets the vehicle used for the grid spawner
-- @param hash: Hash of the vehicle
-- @param options: Options for the vehicle
-- @param modOverrides: Explicitly set vehicle mods
local function setVehicle(hash, options, modOverrides)
    spawnModeEnabled = true -- automatically enable spawn mode when setting a vehicle
    spawnTargetHash = hash
    spawnTargetDimensions = gridSpawn.getModelDimensions(hash)
    if not options then
        spawnTargetOptions = {
            drift = false,
            f1Wheels = false,
            livery = -1,
            randomColor = false
        }
    else
        spawnTargetOptions = {
            drift = options.drift or false,
            f1Wheels = options.f1Wheels or false,
            livery = options.livery or -1,
            randomColor = options.randomColor or false
        }
    end

    if not modOverrides then
        spawnTargetModOverrides = {}
    else
        spawnTargetModOverrides = modOverrides
    end
end

-- Converts any old vehicle into an AdventureToy
-- @param veh: The vehicle entity
local function makeAdventureVehicle(veh)
    local color = {
        r = math.random(0, 255),
        g = math.random(0, 255),
        b = math.random(0, 255)
    }
    local wheelColor = math.random(0, 80)
    if not spawnTargetOptions.randomColor then
        color = data.brandColor
        wheelColor = 37
    end

    local livery = -1
    if (spawnTargetOptions.livery >= 0) then
        livery = math.random(0, spawnTargetOptions.livery)
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
    for type, value in pairs(spawnTargetModOverrides) do
        SET_VEHICLE_MOD(veh, type, value, true)
    end

    -- low-grip drift tyres
    if spawnTargetOptions.drift then
        SET_DRIFT_TYRES(veh, true)
    else
        SET_DRIFT_TYRES(veh, false)
    end
    -- set wheels to f1 wheels
    if spawnTargetOptions.f1Wheels then
        SET_VEHICLE_WHEEL_TYPE(veh, 10)
        SET_VEHICLE_MOD(veh, 23, 3, true)
        SET_VEHICLE_MOD(veh, 24, 3, true)
    else
        -- default to offroad wheels
        SET_VEHICLE_WHEEL_TYPE(veh, 4)
        SET_VEHICLE_MOD(veh, 23, 8, false)
        SET_VEHICLE_MOD(veh, 24, 8, false)
    end

    -- set livery
    if livery ~= -1 then
        SET_VEHICLE_LIVERY(veh, livery)
        SET_VEHICLE_MOD(veh, 48, livery, true)
    end

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

local function updatePassengers()
    local player = GET_PLAYER_INDEX()
    local playerPed = PLAYER_PED_ID()
    local allPlayersIds = players.list(false, true, true)
    local isInVehicle = IS_PED_IN_ANY_VEHICLE(playerPed, false)
    if isInVehicle then
        local vehicle = GET_VEHICLE_PED_IS_IN(playerPed, false)
        local isBus = GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(GET_ENTITY_MODEL(vehicle)) == 'BUS'

        if isBus then
            -- Set the bus' map blip to a yellow tour bus sprite
            -- local blip = ADD_BLIP_FOR_ENTITY(vehicle)
            -- if blip ~= nil then
            --     SET_BLIP_AS_FRIENDLY(blip, true)
            --     SET_BLIP_SPRITE(blip, 85) -- Tour bus sprite
            --     SET_BLIP_COLOUR(blip, 81) -- Gold color
            --     SET_BLIP_SECONDARY_COLOUR(blip, data.brandColor.r, data.brandColor.g, data.brandColor.b)
            --     SET_BLIP_NAME_TO_PLAYER_NAME(blip, player)
            -- end

            local busPassengers = {}

            for i = 0, GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle, false, false) do
                local passenger = GET_PED_IN_VEHICLE_SEAT(vehicle, i, false)
                if passenger ~= nil then
                    local passengerName = GET_PLAYER_NAME(NETWORK_GET_PLAYER_INDEX_FROM_PED(passenger))
                    if (passengerName ~= '**Invalid**' and passengerName ~= nil) then
                        table.insert(busPassengers, passengerName)
                        helpers.assistPassenger(passengerName)
                    end
                end
            end

            currentPassengers = busPassengers

            for i, passengerName in ipairs(busPassengers) do
                helpers.addPassengerToTable(passengerName)
            end

            SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, 'ADVTOUR' ..
                ((#busPassengers > 0 and #busPassengers < 10) and tostring(#busPassengers) or 'S'))
            util.toast((#busPassengers > 0 and 'Assisted passengers. ' or 'Empty bus. ') .. tostring(#busPassengers) ..
                           ' out of ' .. tostring(#allPlayersIds) .. ' are on the bus.')
        end
    else
        local localPlayers = helpers.getLocalPlayers()
        helpers.assistPassengers(localPlayers)
        currentPassengers = localPlayers
        util.toast('Found ' .. tostring(#localPlayers) .. ' local players.')
    end
end

-- Spawns the official Adventure Tours bus
local function spawnAdventureToursBus()
    spawnTargetOptions = {
        drift = false,
        f1Wheels = false,
        livery = -1,
        randomColor = false
    }
    local playerPed = PLAYER_PED_ID()
    if not IS_PED_IN_ANY_VEHICLE(playerPed, false) then
        local busModel = util.joaat('bus')
        REQUEST_MODEL(busModel)
        while not HAS_MODEL_LOADED(busModel) do
            util.yield(1000)
        end
        local playerPos = GET_ENTITY_COORDS(playerPed, false)
        local bus = CREATE_VEHICLE(busModel, playerPos.x + 5.0, playerPos.y + 5.0, playerPos.z,
            GET_ENTITY_HEADING(playerPed), true, false)

        makeAdventureVehicle(bus)
        SET_PED_INTO_VEHICLE(playerPed, bus, -1)
        helpers.setSuperDrive('on')
        util.yield(1000)
    end
    updatePassengers()
end

local function addEventVehicle(listRef, vehicleName, vehicleModel, vehicleOptions, vehicleMods)
    local hash = util.joaat(vehicleModel)
    if IS_MODEL_A_VEHICLE(hash) then
        menu.action(listRef, vehicleName, {}, 'Set spawn vehicle to ' .. vehicleName, function()
            setVehicle(hash, vehicleOptions, vehicleMods)
        end)
    else
        util.log('Model ' .. vehicleModel .. ' is not a vehicle.')
    end
end

local function addEventLocation(listRef, locationName, locationCoords)
    menu.action(listRef, locationName, {}, 'Go to the location', function()
        local playerPed = PLAYER_PED_ID()
        SET_PED_COORDS_KEEP_VEHICLE(playerPed, locationCoords.x, locationCoords.y, locationCoords.z)
    end)
end

menu.divider(menu.my_root(), #currentPassengers == 0 and 'Tour Stops' or tostring(#currentPassengers) .. ' passenger' ..
    (#currentPassengers == 1 and '' or 's'))

-- Add the tour stops to the menu
for _, ts in pairs(data.tourStops) do
    local eventList = menu.list(menu.my_root(), ts.name, {}, ts.description)
    menu.divider(eventList, 'Locations')
    for _, location in pairs(ts.locations) do
        addEventLocation(eventList, location.name, location.coords)
    end
    menu.divider(eventList, 'Vehicles')
    for _, vehicle in pairs(ts.vehicles) do
        addEventVehicle(eventList, vehicle.name, vehicle.id, vehicle.options, vehicle.mods)
    end
    util.yield()
end

menu.divider(menu.my_root(), 'Other Settings')

local actionsMenu = menu.list(menu.my_root(), 'Actions', {}, 'Fun animations for the Tour Guide')
menu.action(actionsMenu, 'Cancel', {},
    'Cancels any actions being performed by the Tour Guide and clears away props (except vehicles)', function()
        helpers.clearObjects()
    end)
menu.divider(actionsMenu, 'Animations')
for _, action in pairs(data.actions) do
    local action_label = action.id:gsub('^%l', string.upper)
    menu.action(actionsMenu, action_label, {}, action.name, function()
        local variant = ''
        if action.variants ~= nil then
            variant = action.variants[math.random(#action.variants)]
        end
        menu.trigger_commands('playanim' .. action.id .. variant)
    end)
end

local chatMenu = menu.list(menu.my_root(), 'Chat', {}, 'Handy chat messages')
menu.action(chatMenu, 'Welcome', {}, data.welcomeMessage, function()
    chat.send_message(data.welcomeMessage, false, true, true)
end)
menu.action(chatMenu, 'Rules', {}, 'Display the rules', function()
    for _, rule in pairs(data.tourRules) do
        chat.send_message(rule, false, true, true)
        util.yield(1000)
    end
end)
menu.action(chatMenu, 'Invite', {}, data.callToActionMessage, function()
    chat.send_message(data.callToActionMessage, false, true, true)
end)
menu.action(chatMenu, 'Thank you', {}, data.thankYouMessage, function()
    chat.send_message(data.thankYouMessage, false, true, true)
end)
menu.action(chatMenu, 'Boast', {}, data.boastMessage, function()
    chat.send_message(data.boastMessage, false, true, true)
end)
menu.action(chatMenu, 'Passenger Count', {}, data.passengerCountMessage(historicPassengers), function()
    chat.send_message(data.passengerCountMessage(historicPassengers), false, true, true)
end)

local helpMenu = menu.list(menu.my_root(), 'Help', {}, 'Helpful commands')
menu.divider(helpMenu, 'Hold R3 and press:')
menu.divider(helpMenu, 'DPAD-L to clear area')
menu.divider(helpMenu, 'DPAD-R to toggle spawn mode')
menu.divider(helpMenu, 'DPAD-U to undo last grid spawn')
menu.divider(helpMenu, 'DPAD-D to spawn bus/update passengers')

menu.toggle(menu.my_root(), 'Superdrive', {}, 'Toggle superdrive and superhandbrake', function()
    helpers.toggleSuperDrive()
end, true)

menu.divider(menu.my_root(), 'Version ' .. scriptVersion)

util.create_tick_handler(function()
    if controls.r3Hold() and controls.dpadDownPress() then
        spawnAdventureToursBus()
    end
    if controls.r3Hold() and controls.dpadRightPress() then
        spawnModeEnabled = not spawnModeEnabled
    end
    if controls.r3Hold() and controls.dpadLeftPress() then
        helpers.clearVehicles()
    end
    if controls.r3Hold() and controls.dpadUpPress() and spawnModeEnabled == false then
        -- TODO hide mobile phone after pressing dpad up
        helpers.clearObjects()
    end
    if spawnModeEnabled == true then
        DISABLE_CONTROL_ACTION(0, 142, true)
        gridSpawn.handleSpawn(spawnTargetHash, spawnTargetDimensions, makeAdventureVehicle)
    end
end)

util.on_stop(function()
    gridSpawn.handleCleanup()
end)

---
--- Startup Logo (taken from Constructor by Hexarobi)
--- https://github.com/hexarobi/stand-lua-constructor
---

local logo = directx.create_texture(filesystem.scripts_dir() .. 'lib\\AdventureScript\\logo.png')
local fade_steps = 25
-- Fade In
for i = 0, fade_steps do
    directx.draw_texture(logo, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, i / fade_steps)
    util.yield()
end
for i = 0, 25 do
    directx.draw_texture(logo, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, 1)
    util.yield()
end
-- Fade Out
for i = fade_steps, 0, -1 do
    directx.draw_texture(logo, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, i / fade_steps)
    util.yield()
end
