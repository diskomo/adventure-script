-- AdventureScript
-- by META IIII (aka AdventureTours)
util.require_natives(1676318796)
util.keep_running()

local SCRIPT_VERSION = '0.8.4'
local AUTO_UPDATE_BRANCHES = {{'main', {}, 'More stable, but updated less often.', 'main'},
                              {'dev', {}, 'Cutting edge updates, but less stable.', 'dev'}}
local SELECTED_BRANCH_INDEX = 1
local SELECTED_BRANCH = AUTO_UPDATE_BRANCHES[SELECTED_BRANCH_INDEX][1]

---
--- Auto-Updater
--- from https://github.com/hexarobi/stand-lua-auto-updater
---
local status, auto_updater = pcall(require, 'auto-updater')
if not status then
    local auto_update_complete = nil
    util.toast('Installing auto-updater...', TOAST_ALL)
    async_http.init('raw.githubusercontent.com', '/hexarobi/stand-lua-auto-updater/main/auto-updater.lua',
        function(result, headers, status_code)
            local function parse_auto_update_result(result, headers, status_code)
                local error_prefix = 'Error downloading auto-updater: '
                if status_code ~= 200 then
                    util.toast(error_prefix .. status_code, TOAST_ALL)
                    return false
                end
                if not result or result == '' then
                    util.toast(error_prefix .. 'Found empty file.', TOAST_ALL)
                    return false
                end
                filesystem.mkdir(filesystem.scripts_dir() .. 'lib')
                local file = io.open(filesystem.scripts_dir() .. 'lib\\auto-updater.lua', 'wb')
                if file == nil then
                    util.toast(error_prefix .. 'Could not open file for writing.', TOAST_ALL)
                    return false
                end
                file:write(result)
                file:close()
                util.toast('Successfully installed auto-updater lib', TOAST_ALL)
                return true
            end
            auto_update_complete = parse_auto_update_result(result, headers, status_code)
        end, function()
            util.toast('Error downloading auto-updater lib. Update failed to download.', TOAST_ALL)
        end)
    async_http.dispatch()
    local i = 1
    while (auto_update_complete == nil and i < 40) do
        util.yield(250)
        i = i + 1
    end
    if auto_update_complete == nil then
        error('Error downloading auto-updater lib. HTTP Request timeout')
    end
    auto_updater = require('auto-updater')
end
if auto_updater == true then
    error('Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again')
end

local DEFAULT_CHECK_INTERVAL = 604800
local auto_update_config = {
    source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/AdventureScript.lua',
    script_relpath = SCRIPT_RELPATH,
    switch_to_branch = SELECTED_BRANCH,
    verify_file_begins_with = '--',
    check_interval = DEFAULT_CHECK_INTERVAL,
    dependencies = {{
        name = 'data',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/data.lua',
        script_relpath = 'lib/AdventureScript/data.lua',
        verify_file_begins_with = '--',
        check_interval = DEFAULT_CHECK_INTERVAL,
        is_required = true
    }, {
        name = 'controls',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/controls.lua',
        script_relpath = 'lib/AdventureScript/controls.lua',
        verify_file_begins_with = '--',
        check_interval = DEFAULT_CHECK_INTERVAL,
        is_required = true
    }, {
        name = 'gridspawn',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/gridspawn.lua',
        script_relpath = 'lib/AdventureScript/gridspawn.lua',
        verify_file_begins_with = '--',
        check_interval = DEFAULT_CHECK_INTERVAL,
        is_required = true
    }, {
        name = 'helpers',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/HELPERS.lua',
        script_relpath = 'lib/AdventureScript/HELPERS.lua',
        verify_file_begins_with = '--',
        check_interval = DEFAULT_CHECK_INTERVAL,
        is_required = true
    }, {
        name = 'logo',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/logo.png',
        script_relpath = 'lib/AdventureScript/logo.png',
        check_interval = DEFAULT_CHECK_INTERVAL
    }}
}
local update_success = auto_updater.run_auto_update(auto_update_config)
local function requireDependency(path)
    local dep_status, required_dep = pcall(require, path)
    if not dep_status then
        error('Could not load ' .. path .. ': ' .. required_dep)
    else
        return required_dep
    end
end
local missing_required_dependencies = {}
for _, dependency in pairs(auto_update_config.dependencies) do
    if dependency.is_required then
        local var_name = dependency.name
        if dependency.loaded_lib ~= nil then
            _G[var_name] = dependency.loaded_lib
        else
            local lib_require_status, loaded_lib = pcall(require, dependency.script_relpath:gsub('[.]lua$', ''))
            if lib_require_status then
                _G[var_name] = loaded_lib
            else
                table.insert(missing_required_dependencies, dependency.name)
            end
        end
    end
end
if #missing_required_dependencies > 0 then
    local missing_files = table.concat(missing_required_dependencies, ', ')
    if not update_success then
        error('Error: Install Failed. Auto-update failed and required files are missing (' .. missing_files ..
                  ') Please re-install from the project zip file @ https://github.com/diskomo/adventure-script')
    else
        menu.readonly(menu.my_root(), 'Error: Load Failed', 'Required files are missing. (' .. missing_files .. ')')
        error(
            'Error: Load Failed. Auto-update successful but required files are missing. This is likely a bug. Please report this issue on Discord @ https://discord.gg/2u5HbHPB9y')
    end
end

---
--- AdventureScript begins here
---
local DATA = requireDependency('lib/AdventureScript/data')
local CONTROLS = requireDependency('lib/AdventureScript/controls')
local HELPERS = requireDependency('lib/AdventureScript/helpers')
local GRIDSPAWN = requireDependency('lib/AdventureScript/gridspawn')
local passengers = {}
local spawnModeEnabled = false
local spawnTargetHash = util.joaat('manchez2')
local spawnTargetDimensions = GRIDSPAWN.getModelDimensions(spawnTargetHash)
local spawnTargetOptions = {
    drift = false,
    f1Wheels = false,
    livery = -1,
    randomColor = false
}

-- Sets the vehicle used for the grid spawner
local function setVehicle(hash, options)
    spawnModeEnabled = true -- automatically enable spawn mode when setting a vehicle
    spawnTargetHash = hash
    spawnTargetDimensions = GRIDSPAWN.getModelDimensions(hash)
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
end

-- Converts any old vehicle into an AdventureToy
local function makeAdventureVehicle(veh)
    local color = {
        r = math.random(0, 255),
        g = math.random(0, 255),
        b = math.random(0, 255)
    }
    local wheelColor = math.random(0, 80)
    if not spawnTargetOptions.randomColor then
        color = DATA.brandColor
        wheelColor = 37
    end

    local livery = -1
    if (spawnTargetOptions.livery >= 0) then
        livery = math.random(0, spawnTargetOptions.livery)
    end

    if not ENTITY.DOES_ENTITY_EXIST(veh) then
        return
    end
    ENTITY.SET_ENTITY_INVINCIBLE(veh, true)
    VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
    -- This loop will set all of the vehicle modifications defined in defaultMods to their highest possible value
    for _, type in pairs(DATA.defaultMods) do
        VEHICLE.SET_VEHICLE_MOD(veh, type, VEHICLE.GET_NUM_vehicleMods(veh, type) - 1, true)
    end
    -- low-grip drift tyres
    if spawnTargetOptions.drift then
        VEHICLE.SET_DRIFT_TYRES(veh, true)
    else
        VEHICLE.SET_DRIFT_TYRES(veh, false)
    end
    -- set wheels to f1 wheels
    if spawnTargetOptions.f1Wheels then
        VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, 10)
        VEHICLE.SET_VEHICLE_MOD(veh, 23, 3, true)
        VEHICLE.SET_VEHICLE_MOD(veh, 24, 3, true)
    else
        -- default to offroad wheels
        VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, 4)
        VEHICLE.SET_VEHICLE_MOD(veh, 23, 8, false)
        VEHICLE.SET_VEHICLE_MOD(veh, 24, 8, false)
    end

    -- set livery
    if livery ~= -1 then
        VEHICLE.SET_VEHICLE_LIVERY(veh, livery)
        VEHICLE.SET_VEHICLE_MOD(veh, 48, livery, true)
    end

    -- Branding
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, wheelColor, wheelColor)
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, color.r, color.g, color.b)
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, color.r + 20, color.g + 20, color.b + 20)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, 5) -- yankton plate
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, DATA.licensePlate)
    VEHICLE.SET_VEHICLE_MOD(veh, 14, math.random(16, 23), true) -- horn (high note)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true) -- xenon headlights
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, 6) -- gold tint headlights
end

local function updatePassengers()
    local player = PLAYER.GET_PLAYER_INDEX()
    local playerPed = PLAYER.PLAYER_PED_ID()
    local allPlayersIds = players.list(false, true, true)
    if PED.IS_PED_SITTING_IN_ANY_VEHICLE(playerPed) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)

        -- -- Set the bus' map blip to a yellow tour bus sprite
        -- local blip = HUD.ADD_BLIP_FOR_ENTITY(vehicle)
        -- if blip ~= nil then
        --     HUD.SET_BLIP_AS_FRIENDLY(blip, true)
        --     HUD.SET_BLIP_SPRITE(blip, 85) -- Tour bus sprite
        --     HUD.SET_BLIP_COLOUR(blip, 81) -- Gold color
        --     HUD.SET_BLIP_SECONDARY_COLOUR(blip, DATA.brandColor.r, DATA.brandColor.g,
        --         DATA.brandColor.b)
        --     HUD.SET_BLIP_NAME_TO_PLAYER_NAME(blip, player)
        -- end

        local passengerList = {}
        for i = 0, VEHICLE.GET_VEHICLE_NUMBER_OF_PASSENGERS(vehicle, false, false) do
            local passenger = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i, false)
            if passenger ~= nil then
                local passengerName = PLAYER.GET_PLAYER_NAME(NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(passenger))
                if (passengerName ~= '**Invalid**') then
                    table.insert(passengerList, passengerName)
                    HELPERS.assistPassenger(passengerName)
                end
            end
            util.yield()
        end
        passengers = passengerList
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, 'ADVTOUR' ..
            ((#passengerList > 0 and #passengerList < 10) and tostring(#passengerList) or 'S'))
        util.toast((#passengerList > 0 and 'Assisted passengers. ' or 'Empty bus. ') .. tostring(#passengerList) ..
                       ' out of ' .. tostring(#allPlayersIds) .. ' are on the bus.')
    else
        util.toast('Must be in a vehicle to update passenger list.')
    end
end

-- Spawn the official Adventure Tours bus
local function getTheBus()
    spawnTargetOptions = {
        drift = false,
        f1Wheels = false,
        livery = -1,
        randomColor = false
    }
    local playerPed = PLAYER.PLAYER_PED_ID()
    if not PED.IS_PED_IN_ANY_VEHICLE(playerPed, false) then
        local busModel = util.joaat('bus')
        STREAMING.REQUEST_MODEL(busModel)
        while not STREAMING.HAS_MODEL_LOADED(busModel) do
            util.yield(1000)
        end
        local playerPos = ENTITY.GET_ENTITY_COORDS(playerPed, false)
        local bus = VEHICLE.CREATE_VEHICLE(busModel, playerPos.x + 5.0, playerPos.y + 5.0, playerPos.z,
            ENTITY.GET_ENTITY_HEADING(playerPed), true, false)

        makeAdventureVehicle(bus)
        PED.SET_PED_INTO_VEHICLE(playerPed, bus, -1)
        HELPERS.setSuperDrive('on')
        util.yield(1000)
    end
    updatePassengers()
end

local function addEventVehicle(listRef, vehicleName, vehicleModel, vehicleOptions)
    local hash = util.joaat(vehicleModel)
    if STREAMING.IS_MODEL_A_VEHICLE(hash) then
        menu.action(listRef, vehicleName, {}, 'Set spawn vehicle to ' .. vehicleName, function()
            setVehicle(hash, vehicleOptions)
        end)
    else
        util.log('Model ' .. vehicleModel .. ' is not a vehicle.')
    end
end

local function addEventLocation(listRef, locationName, locationCoords)
    menu.action(listRef, locationName, {}, 'Go to the location', function()
        local playerPed = PLAYER.PLAYER_PED_ID()
        PED.SET_PED_COORDS_KEEP_VEHICLE(playerPed, locationCoords.x, locationCoords.y, locationCoords.z)
    end)
end

menu.divider(menu.my_root(), #passengers == 0 and 'Tour Stops' or tostring(#passengers) .. ' passenger' ..
    (#passengers == 1 and '' or 's'))

-- Add the tour stops to the menu
for _, ts in pairs(DATA.tourStops) do
    local eventList = menu.list(menu.my_root(), ts.name, {}, ts.description)
    menu.divider(eventList, 'Locations')
    for _, location in pairs(ts.locations) do
        addEventLocation(eventList, location.name, location.coords)
    end
    menu.divider(eventList, 'Vehicles')
    for _, vehicle in pairs(ts.vehicles) do
        addEventVehicle(eventList, vehicle.name, vehicle.id, vehicle.options)
    end
    util.yield()
end

menu.divider(menu.my_root(), 'Other Settings')

local actionsMenu = menu.list(menu.my_root(), 'Actions', {}, 'Fun animations for the Tour Guide')
menu.action(actionsMenu, 'Cancel', {},
    'Cancels any actions being performed by the Tour Guide and clears away props (except vehicles)', function()
        HELPERS.clearObjects()
    end)
menu.divider(actionsMenu, 'Animations')
for _, action in pairs(DATA.actions) do
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
menu.action(chatMenu, 'Welcome', {}, DATA.welcomeMessage, function()
    chat.send_message(DATA.welcomeMessage, false, true, true)
end)
menu.action(chatMenu, 'Thank you', {}, DATA.thankYouMessage, function()
    chat.send_message(DATA.thankYouMessage, false, true, true)
end)
menu.action(chatMenu, 'Rules', {}, 'Display the rules', function()
    for _, rule in pairs(DATA.tourRules) do
        chat.send_message(rule, false, true, true)
        util.yield(1000)
    end
end)

local helpMenu = menu.list(menu.my_root(), 'Help', {}, 'Helpful commands')
menu.divider(helpMenu, 'Hold R3 and press:')
menu.divider(helpMenu, 'DPAD-L to clear area')
menu.divider(helpMenu, 'DPAD-R to toggle spawn mode')
menu.divider(helpMenu, 'DPAD-U to undo last grid spawn')
menu.divider(helpMenu, 'DPAD-D to spawn bus/update passengers')

menu.toggle(menu.my_root(), 'Superdrive', {}, 'Toggle superdrive and superhandbrake', function()
    HELPERS.toggleSuperDrive()
end, true)

menu.divider(menu.my_root(), 'Version ' .. SCRIPT_VERSION)

util.create_tick_handler(function()
    if CONTROLS.r3Hold() and CONTROLS.dpadDownPress() then
        getTheBus()
    end
    if CONTROLS.r3Hold() and CONTROLS.dpadRightPress() then
        spawnModeEnabled = not spawnModeEnabled
    end
    if CONTROLS.r3Hold() and CONTROLS.dpadLeftPress() then
        HELPERS.clearVehicles()
    end
    if CONTROLS.r3Hold() and CONTROLS.dpadUpPress() and spawnModeEnabled == false then
        -- TODO hide mobile phone after pressing dpad up
        HELPERS.clearObjects()
    end
    if spawnModeEnabled == true then
        GRIDSPAWN.handleSpawn(spawnTargetHash, spawnTargetDimensions, makeAdventureVehicle)
    end
end)

util.on_stop(function()
    GRIDSPAWN.handleCleanup()
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
