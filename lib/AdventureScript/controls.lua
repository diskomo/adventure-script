-- functions for checking which controller inputs have been pressed
local CONTROLS = {
    leftClickDown = function()
        return IS_DISABLED_CONTROL_JUST_PRESSED(2, 24)
    end,

    leftClickUp = function()
        return IS_DISABLED_CONTROL_JUST_RELEASED(2, 24)
    end,

    r3Hold = function()
        return IS_DISABLED_CONTROL_PRESSED(2, 26)
    end,

    dpadUpPress = function()
        return IS_DISABLED_CONTROL_JUST_PRESSED(2, 27)
    end,

    dpadRightPress = function()
        return IS_DISABLED_CONTROL_JUST_PRESSED(2, 74)
    end,

    dpadDownPress = function()
        return IS_DISABLED_CONTROL_JUST_PRESSED(2, 48)
    end,

    dpadLeftPress = function()
        return IS_DISABLED_CONTROL_JUST_PRESSED(2, 85)
    end
}

return CONTROLS
