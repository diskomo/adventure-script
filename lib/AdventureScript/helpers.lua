-- Small helper functions for the menu
-- Used to load and populate the .txt file record of every passenger that has joined a tour
local passengersTable = {}

local HELPERS = {
    loadPassengers = function()
        local file = io.open(filesystem.scripts_dir() .. 'lib\\AdventureScript\\passengers.txt', 'r')
        if file then
            for line in file:lines() do
                passengersTable[line] = true
            end
            file:close()
        end
        return passengersTable
    end,
    addPassengerToTable = function(passengerName)
        if not passengersTable[passengerName] then
            -- The passenger isn't in the set, add them
            passengersTable[passengerName] = true
            local file = io.open(filesystem.scripts_dir() .. 'lib\\AdventureScript\\passengers.txt', 'a')
            if file then
                file:write(passengerName .. '\n')
                file:close()
            else
                util.toast('Error: Could not open passengers.txt file for writing.')
            end
        end
    end,
    clearObjects = function()
        local ped = GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        CLEAR_PED_TASKS_IMMEDIATELY(ped)
        menu.trigger_commands('clearobjects on')
        menu.trigger_commands('clearvehicles off')
        menu.trigger_commands('cleararea')
    end,
    clearVehicles = function()
        menu.trigger_commands('clearobjects off')
        menu.trigger_commands('clearvehicles on')
        menu.trigger_commands('cleararea')
    end,
    removeWeapons = function()
        menu.trigger_commands('noguns')
    end,
    setSuperDrive = function(value)
        menu.trigger_commands('superdrive' .. ' ' .. value)
        menu.trigger_commands('superhandbrake' .. ' ' .. value)
    end,
    toggleSuperDrive = function()
        menu.trigger_commands('superdrive')
        menu.trigger_commands('superhandbrake')
    end,
    -- Keep the fuckin cops off a passenger and keep 'em healthy
    assistPassenger = function(passenger)
        menu.trigger_commands('bail' .. passenger .. ' on')
        menu.trigger_commands('autoheal' .. passenger .. ' on')
        menu.trigger_commands('repairveh' .. passenger)
        menu.trigger_commands('givevehgod' .. passenger .. ' on')

    end,
    assistPassengers = function(passengers)
        for i = 0, #passengers do
            menu.trigger_commands('bail' .. passengers[i] .. ' on')
            menu.trigger_commands('autoheal' .. passengers[i] .. ' on')
            menu.trigger_commands('repairveh' .. passengers[i])
            menu.trigger_commands('givevehgod' .. passengers[i] .. ' on')
        end
    end,
    getLocalPlayers = function()
        local playerPed = PLAYER_PED_ID()
        local playerPos = GET_ENTITY_COORDS(playerPed)
        local radius = 10000
        local playersList = {}
        for i = 0, 31 do
            if NETWORK_IS_PLAYER_ACTIVE(i) and i ~= PLAYER_ID() then
                local ped = GET_PLAYER_PED(i)
                local pedPos = GET_ENTITY_COORDS(ped)
                local distance = VDIST2(playerPos.x, playerPos.y, playerPos.z, pedPos.x, pedPos.y, pedPos.z)
                if distance <= radius then
                    local playerName = GET_PLAYER_NAME(i)
                    if (playerName ~= '**Invalid**') then
                        table.insert(playersList, playerName)
                    end
                end
            end
        end
        return playersList
    end
}

return HELPERS
