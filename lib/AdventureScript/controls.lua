-- functions for checking which controller inputs have been pressed
local CONTROLS = {
    leftClickDown = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 24)
    end,

    leftClickUp = function()
        return PAD.IS_DISABLED_CONTROL_JUST_RELEASED(2, 24)
    end,

    r3Hold = function()
        return PAD.IS_DISABLED_CONTROL_PRESSED(2, 26)
    end,

    dpadUpPress = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 27)
    end,

    dpadRightPress = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 74)
    end,

    dpadDownPress = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 48)
    end,

    dpadLeftPress = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 85)
    end
}

return CONTROLS
