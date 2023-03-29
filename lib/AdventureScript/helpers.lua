-- Small helper functions for the menu
local HELPERS = {
    clear_objects = function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        menu.trigger_commands('clearobjects on')
        menu.trigger_commands('clearvehicles off')
        menu.trigger_commands('cleararea')
    end,
    clear_vehicles = function()
        menu.trigger_commands('clearobjects off')
        menu.trigger_commands('clearvehicles on')
        menu.trigger_commands('cleararea')
    end,
    set_super_drive = function(value)
        menu.trigger_commands('superdrive' .. ' ' .. value)
        menu.trigger_commands('superhandbrake' .. ' ' .. value)
    end,
    toggle_super_drive = function()
        menu.trigger_commands('superdrive')
        menu.trigger_commands('superhandbrake')
    end,
    -- Keep the fuckin cops off a passenger and keep 'em healthy
    assist_passenger = function(passenger)
        menu.trigger_commands('bail' .. passenger .. ' on')
        menu.trigger_commands('autoheal' .. passenger .. ' on')
    end
}

return HELPERS
