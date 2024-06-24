local menuHelpers = {}

local config = require('lib.AdventureScript.config')
local state = require('lib.AdventureScript.state')
local data = require('lib.AdventureScript.data')
local passengers = require('lib.AdventureScript.passengers')
local vehicles = require('lib.AdventureScript.vehicles')

local function addEventVehicle(listRef, vehicleName, vehicleModel, vehicleOptions, vehicleMods)
    local hash = util.joaat(vehicleModel)
    if IS_MODEL_A_VEHICLE(hash) then
        menu.action(listRef, vehicleName, {}, 'Set spawn vehicle to ' .. vehicleName, function()
            vehicles.setVehicle(hash, vehicleOptions, vehicleMods)
        end)
    else
        util.log('Model ' .. vehicleModel .. ' is not a vehicle.')
    end
end

local function addEventLocation(listRef, locationName, locationCoords)
    menu.action(listRef, locationName, {}, 'Go to the location', function()
        local playerPed = PLAYER_PED_ID()
        SET_PED_COORDS_KEEP_VEHICLE(playerPed, locationCoords.x, locationCoords.y, locationCoords.z)
        -- Set state.currentTourStopIndex
        for i, ts in pairs(data.tourStops) do
            for j, loc in pairs(ts.locations) do
                if loc.name == locationName then
                    state.currentTourStopIndex = i
                    return
                end
            end
        end
    end)
end

menuHelpers.initializeMenu = function()
    -- Put on the tour guide outfit (requires `<%AppData%>/Stand/Outfits/tourguide.txt`)
    menu.trigger_commands('outfittourguide')
    -- Adventure Tours are supposed to be a passive affair, so this takes away the guide's weapons
    menu.trigger_commands('noguns')
    menu.trigger_commands('superdrive on')
    menu.trigger_commands('superhandbrake on')

    menu.divider(menu.my_root(),
        #state.currentPassengers == 0 and 'Tour Stops' or tostring(#state.currentPassengers) .. ' passenger' ..
            (#state.currentPassengers == 1 and '' or 's'))

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
            local ped = GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            CLEAR_PED_TASKS_IMMEDIATELY(ped)
        end)
    menu.divider(actionsMenu, 'Animations')
    for _, action in pairs(data.actions) do
        menu.action(actionsMenu, action.name, {}, action.name, function()
            local variant = ''
            if action.variants ~= nil then
                variant = action.variants[math.random(#action.variants)]
            end
            menu.trigger_commands('anim' .. action.id .. variant)
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
    menu.action(chatMenu, 'Passenger Count', {}, data.passengerCountMessage(passengers.passengerDatabase), function()
        chat.send_message(data.passengerCountMessage(passengers.passengerDatabase), false, true, true)
    end)

    menu.toggle(menu.my_root(), 'Show controls', {}, 'Show gamepad controls when holding R3', function()
        state.show_on_screen_controls = not state.show_on_screen_controls
    end, state.show_on_screen_controls)

    menu.toggle(menu.my_root(), 'Superdrive', {}, 'Toggle superdrive and superhandbrake', function()
        menu.trigger_commands('superdrive')
        menu.trigger_commands('superhandbrake')
    end, true)

    menu.divider(menu.my_root(), 'Version ' .. config.scriptVersion)
end

return menuHelpers
