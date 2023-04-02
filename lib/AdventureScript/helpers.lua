-- Small helper functions for the menu
local HELPERS = {
    clearObjects = function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        menu.trigger_commands('clearobjects on')
        menu.trigger_commands('clearvehicles off')
        menu.trigger_commands('cleararea')
    end,
    clearVehicles = function()
        menu.trigger_commands('clearobjects off')
        menu.trigger_commands('clearvehicles on')
        menu.trigger_commands('cleararea')
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
    end,
    getLocalPlayers = function()
        local playerPed = PLAYER.PLAYER_PED_ID()
        local playerPos = ENTITY.GET_ENTITY_COORDS(playerPed)
        local radius = 100
        local playersList = {}
        for i = 0, 31 do
            if NETWORK.NETWORK_IS_PLAYER_ACTIVE(i) and i ~= PLAYER.PLAYER_ID() then
                local ped = PLAYER.GET_PLAYER_PED(i)
                local pedPos = ENTITY.GET_ENTITY_COORDS(ped)
                local distance = SYSTEM.VDIST2(playerPos.x, playerPos.y, playerPos.z, pedPos.x, pedPos.y, pedPos.z)
                if distance <= radius then
                    local playerName = PLAYER.GET_PLAYER_NAME(i)
                    table.insert(playersList, playerName)
                    util.toast("Player " .. playerName .. " is " .. distance .. " units away.")
                end
            end
        end
        return playersList
    end
}

return HELPERS
