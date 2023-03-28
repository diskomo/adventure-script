-- AdventureScript
-- by META IIII (aka AdventureTours)
util.require_natives(1676318796)
util.keep_running()

local SCRIPT_VERSION = '0.8.0'
local AUTO_UPDATE_BRANCHES = {{'main', {}, 'More stable, but updated less often.', 'main'},
                              {'dev', {}, 'Cutting edge updates, but less stable.', 'dev'}}
local SELECTED_BRANCH_INDEX = 1
local selected_branch = AUTO_UPDATE_BRANCHES[SELECTED_BRANCH_INDEX][1]

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

local default_check_interval = 604800
local auto_update_config = {
    source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/AdventureScript.lua',
    script_relpath = SCRIPT_RELPATH,
    switch_to_branch = selected_branch,
    verify_file_begins_with = '--',
    check_interval = default_check_interval,
    dependencies = {{
        name = 'data',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/data.lua',
        script_relpath = 'lib/AdventureScript/data.lua',
        verify_file_begins_with = '--',
        check_interval = default_check_interval,
        is_required = true
    }, {
        name = 'helpers',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/helpers.lua',
        script_relpath = 'lib/AdventureScript/helpers.lua',
        verify_file_begins_with = '--',
        check_interval = default_check_interval,
        is_required = true
    }, {
        name = 'logo',
        source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/logo.png',
        script_relpath = 'lib/AdventureScript/logo.png',
        check_interval = default_check_interval
    }}
}
local update_success = auto_updater.run_auto_update(auto_update_config)
local function require_dependency(path)
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

local adventure_data = require_dependency('lib/AdventureScript/data')
local helpers = require_dependency('lib/AdventureScript/helpers')
local passengers = {}
local spawn_mode_enabled = false
local spawn_target_hash = util.joaat('manchez2')
local spawn_target_dimensions = helpers.get_model_dimensions(spawn_target_hash)
local spawn_target_options = {
    drift = false,
    f1_wheels = false,
    livery = -1,
    random_colour = false
}

-- Sets the vehicle used for the grid spawner
local function set_vehicle(hash, options)
    spawn_mode_enabled = true -- automatically enable spawn mode when setting a vehicle
    spawn_target_hash = hash
    spawn_target_dimensions = helpers.get_model_dimensions(hash)
    if not options then
        spawn_target_options = {
            drift = false,
            f1_wheels = false,
            livery = -1,
            random_colour = false
        }
    else
        spawn_target_options = {
            drift = options.drift or false,
            f1_wheels = options.f1_wheels or false,
            livery = options.livery or -1,
            random_colour = options.random_colour or false
        }
    end
end

-- Converts any old vehicle into an AdventureToy
local function make_adventure_vehicle(veh)
    local colour = {
        r = math.random(0, 255),
        g = math.random(0, 255),
        b = math.random(0, 255)
    }
    local wheel_colour = math.random(0, 80)
    if not spawn_target_options.random_colour then
        colour = adventure_data.brand_colour
        wheel_colour = 37
    end

    local livery = -1
    if (spawn_target_options.livery >= 0) then
        livery = math.random(0, spawn_target_options.livery)
    end

    if not ENTITY.DOES_ENTITY_EXIST(veh) then
        return
    end
    ENTITY.SET_ENTITY_INVINCIBLE(veh, true)
    VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
    -- This loop will set all of the vehicle modifications defined in default_mods to their highest possible value
    for _, type in pairs(adventure_data.default_mods) do
        VEHICLE.SET_VEHICLE_MOD(veh, type, VEHICLE.GET_NUM_VEHICLE_MODS(veh, type) - 1, true)
    end
    -- low-grip drift tyres
    if spawn_target_options.drift then
        VEHICLE.SET_DRIFT_TYRES(veh, true)
    else
        VEHICLE.SET_DRIFT_TYRES(veh, false)
    end
    -- set wheels to f1 wheels
    if spawn_target_options.f1_wheels then
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
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, wheel_colour, wheel_colour)
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, colour.r, colour.g, colour.b)
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, colour.r + 20, colour.g + 20, colour.b + 20)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, 5) -- yankton plate
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, adventure_data.license_plate)
    VEHICLE.SET_VEHICLE_MOD(veh, 14, math.random(16, 23), true) -- horn (high note)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true) -- xenon headlights
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, 6) -- gold tint headlights
end

-- Keep the fuckin cops off a passenger and keep 'em healthy
local function assist_passenger(passenger)
    menu.trigger_commands('bail' .. passenger .. ' on')
    menu.trigger_commands('autoheal' .. passenger .. ' on')
    util.yield()
end

local function update_passengers()
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
        --     HUD.SET_BLIP_COLOUR(blip, 81) -- Gold colour
        --     HUD.SET_BLIP_SECONDARY_COLOUR(blip, adventure_data.brand_colour.r, adventure_data.brand_colour.g,
        --         adventure_data.brand_colour.b)
        --     HUD.SET_BLIP_NAME_TO_PLAYER_NAME(blip, player)
        -- end

        local passengerList = {}
        for i = 0, VEHICLE.GET_VEHICLE_NUMBER_OF_PASSENGERS(vehicle, false, false) do
            local passenger = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i, false)
            if passenger ~= nil then
                local passengerName = PLAYER.GET_PLAYER_NAME(NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(passenger))
                if (passengerName ~= '**Invalid**') then
                    table.insert(passengerList, passengerName)
                    assist_passenger(passengerName)
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
local function get_the_bus()
    spawn_target_options = {
        drift = false,
        f1_wheels = false,
        livery = -1,
        random_colour = false
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

        make_adventure_vehicle(bus)
        PED.SET_PED_INTO_VEHICLE(playerPed, bus, -1)
        helpers.set_super_drive('on')
        util.yield(1000)
    end
    update_passengers()
end

local function add_event_vehicle(listRef, vehicleName, vehicleModel, vehicleOptions)
    local hash = util.joaat(vehicleModel)
    if STREAMING.IS_MODEL_A_VEHICLE(hash) then
        menu.action(listRef, vehicleName, {}, 'Set spawn vehicle to ' .. vehicleName, function()
            set_vehicle(hash, vehicleOptions)
        end)
    else
        util.log('Model ' .. vehicleModel .. ' is not a vehicle.')
    end
end

local function add_event_location(listRef, locationName, locationCoords)
    menu.action(listRef, locationName, {}, 'Go to the location', function()
        local playerPed = PLAYER.PLAYER_PED_ID()
        PED.SET_PED_COORDS_KEEP_VEHICLE(playerPed, locationCoords.x, locationCoords.y, locationCoords.z)
    end)
end

menu.divider(menu.my_root(), #passengers == 0 and 'Tour Stops' or tostring(#passengers) .. ' passenger' ..
    (#passengers == 1 and '' or 's'))

-- Add the tour stops to the menu
for _, ts in pairs(adventure_data.tour_stops) do
    local eventList = menu.list(menu.my_root(), ts.name, {}, ts.description)
    menu.divider(eventList, 'Locations')
    for _, location in pairs(ts.locations) do
        add_event_location(eventList, location.name, location.coords)
    end
    menu.divider(eventList, 'Vehicles')
    for _, vehicle in pairs(ts.vehicles) do
        add_event_vehicle(eventList, vehicle.name, vehicle.id, vehicle.options)
    end
    util.yield()
end

menu.divider(menu.my_root(), 'Other Settings')

local actionsMenu = menu.list(menu.my_root(), 'Actions', {}, 'Fun animations for the Tour Guide')
menu.action(actionsMenu, 'Cancel', {},
    'Cancels any actions being performed by the Tour Guide and clears away props (except vehicles)', function()
        helpers.clear_objects()
    end)
menu.divider(actionsMenu, 'Animations')
for _, action in pairs(adventure_data.actions) do
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
menu.action(chatMenu, 'Welcome', {}, adventure_data.welcome_message, function()
    chat.send_message(adventure_data.welcome_message, false, true, true)
end)
menu.action(chatMenu, 'Thank you', {}, adventure_data.thank_you_message, function()
    chat.send_message(adventure_data.thank_you_message, false, true, true)
end)
menu.action(chatMenu, 'Rules', {}, 'Display the rules', function()
    for _, rule in pairs(adventure_data.tour_rules) do
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
    helpers.toggle_super_drive()
end, true)

---
--- Parts of the code below have been adapted from GridSpawn by NotTonk
--- https://discord.com/channels/956618713157763072/1037454538921214082
---
local function left_click_down()
    return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 24)
end

local function left_click_up()
    return PAD.IS_DISABLED_CONTROL_JUST_RELEASED(2, 24)
end

local function left_click_hold()
    return PAD.IS_DISABLED_CONTROL_PRESSED(2, 24)
end

local function r3_hold()
    return PAD.IS_DISABLED_CONTROL_PRESSED(2, 26)
end

local function dpad_up_press()
    return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 27)
end

local function dpad_right_press()
    return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 74)
end

local function dpad_down_press()
    return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 48)
end

local function dpad_left_press()
    return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 85)
end

local preview_cars = {{}}
local undo_record = {}
local up<const> = v3.new(0, 0, 1)
local is_placing = false
local start_pos
local cam_start_heading
local start_forward
local start_right
local arrow_rot = 0
local x_padding = 0.5
local y_padding = 0.5

util.create_tick_handler(function()
    if r3_hold() and dpad_down_press() then
        get_the_bus()
    end
    if r3_hold() and dpad_right_press() then
        spawn_mode_enabled = not spawn_mode_enabled
    end
    if r3_hold() and dpad_left_press() then
        helpers.clear_vehicles()
    end
    if r3_hold() and dpad_up_press() and spawn_mode_enabled == false then
        -- TODO hide mobile phone after pressing dpad up
        helpers.clear_objects()
    end
    if spawn_mode_enabled == true then
        arrow_rot = arrow_rot + MISC.GET_FRAME_TIME() * 45
        local camPos = v3.new(CAM.GET_FINAL_RENDERED_CAM_COORD())
        local camRot = v3.new(CAM.GET_FINAL_RENDERED_CAM_ROT())
        local dir = v3.toDir(camRot)
        v3.mul(dir, 200)
        v3.add(dir, camPos)
        local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(camPos.x, camPos.y, camPos.z, dir.x,
            dir.y, dir.z, 1, 0, 4)

        local hit = memory.alloc(8)
        local end_pos = memory.alloc()
        local surfaceNormal = memory.alloc()
        local ent = memory.alloc_int()
        SHAPETEST.GET_SHAPE_TEST_RESULT(handle, hit, end_pos, surfaceNormal, ent)

        if memory.read_byte(hit) ~= 0 then
            end_pos = v3.new(end_pos)
            helpers.arrow_indicator(end_pos, math.rad(arrow_rot), 1, {
                r = 204,
                g = 132,
                b = 0,
                a = 255
            })

            if left_click_down() then
                is_placing = true
                start_pos = v3.new(end_pos)
                local cam_start_rot = v3.new(CAM.GET_FINAL_RENDERED_CAM_ROT(2))
                cam_start_rot.x = 0
                cam_start_heading = v3.getHeading(cam_start_rot)
                start_forward = v3.toDir(cam_start_rot)
                start_right = v3.crossProduct(start_forward, up)
            elseif left_click_up() then
                is_placing = false
                undo_record[#undo_record + 1] = {}
                local new_record = undo_record[#undo_record]
                for _, tbl in pairs(preview_cars) do
                    for _, car in pairs(tbl) do
                        local pos = ENTITY.GET_ENTITY_COORDS(car, false)
                        entities.delete_by_handle(car)
                        local new_car = VEHICLE.CREATE_VEHICLE(spawn_target_hash, pos.x, pos.y, pos.z,
                            cam_start_heading, true, false, false)
                        new_record[#new_record + 1] = new_car
                        make_adventure_vehicle(new_car)
                        util.yield()
                    end
                end
                preview_cars = {{}}
            end

            if r3_hold() and dpad_up_press() and #undo_record > 0 then
                for _, car in pairs(undo_record[#undo_record]) do
                    if ENTITY.DOES_ENTITY_EXIST(car) then
                        entities.delete_by_handle(car)
                    end
                end
                undo_record[#undo_record] = nil
            end

            if is_placing then
                helpers.arrow_indicator(start_pos, math.rad(arrow_rot), 1, {
                    r = 255,
                    g = 50,
                    b = 50,
                    a = 255
                })
                local angle = -math.rad(cam_start_heading)
                local angle_cos = math.cos(angle)
                local angle_sin = math.sin(angle)
                end_pos = v3.new(start_pos.x +
                                     (angle_cos * (end_pos.x - start_pos.x) - angle_sin * (end_pos.y - start_pos.y)),
                    start_pos.y + (angle_sin * (end_pos.x - start_pos.x) + angle_cos * (end_pos.y - start_pos.y)),
                    end_pos.z)
                local spawn_target_x_plus_pad = spawn_target_dimensions.x + x_padding
                local spawn_target_y_plus_pad = spawn_target_dimensions.y + y_padding

                local x_count = math.min(math.floor(math.abs((start_pos.x - end_pos.x) / spawn_target_x_plus_pad)), 9)
                local y_count = math.min(math.floor(math.abs((start_pos.y - end_pos.y) / spawn_target_y_plus_pad)), 9)
                for x = 0, x_count, 1 do
                    for y = 0, y_count, 1 do
                        local mult_x = start_pos.x > end_pos.x and -1 or 1
                        local mult_y = start_pos.y > end_pos.y and -1 or 1
                        local temp_forward = v3.new(start_forward)
                        local temp_right = v3.new(start_right)
                        v3.mul(temp_forward, (spawn_target_y_plus_pad * y) * mult_y)
                        v3.mul(temp_right, (spawn_target_x_plus_pad * x) * mult_x)
                        v3.add(temp_forward, temp_right)
                        v3.add(temp_forward, start_pos)
                        local coords = temp_forward

                        local z_found, z_coord = util.get_ground_z(coords.x, coords.y)
                        if z_found then
                            coords.z = z_coord
                        else
                            coords.z = start_pos.z
                        end
                        local car
                        if preview_cars[x] then
                            if preview_cars[x][y] then
                                car = preview_cars[x][y]
                            end
                        else
                            preview_cars[x] = {}
                        end
                        if not car then
                            car = VEHICLE.CREATE_VEHICLE(spawn_target_hash, coords.x, coords.y, coords.z,
                                cam_start_heading, false, false, false)
                            ENTITY.SET_ENTITY_ALPHA(car, 51, false)
                            ENTITY.SET_ENTITY_COLLISION(car, false, false)
                            ENTITY.FREEZE_ENTITY_POSITION(car, true)
                            make_adventure_vehicle(car)
                            preview_cars[x][y] = car
                        end
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(car, coords.x, coords.y,
                            coords.z + spawn_target_dimensions.z * 0.5, false, false, false)
                        helpers.draw_bounding_box(car, {
                            r = 204,
                            g = 132,
                            b = 0,
                            a = 100
                        })
                    end
                end
                for x, tbl in pairs(preview_cars) do
                    for y, car in pairs(tbl) do
                        if x > x_count or y > y_count then
                            entities.delete_by_handle(car)
                            preview_cars[x][y] = nil
                        end
                    end
                end
            end
        end
    end
end)

util.on_stop(function()
    for _, tbl in pairs(preview_cars) do
        for _, car in pairs(tbl) do
            entities.delete_by_handle(car)
        end
    end
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
