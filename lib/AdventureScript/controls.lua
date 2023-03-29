-- functions for checking which controller inputs have been pressed
local CONTROLS = {
    left_click_down = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 24)
    end,

    left_click_up = function()
        return PAD.IS_DISABLED_CONTROL_JUST_RELEASED(2, 24)
    end,

    left_click_hold = function()
        return PAD.IS_DISABLED_CONTROL_PRESSED(2, 24)
    end,

    r3_hold = function()
        return PAD.IS_DISABLED_CONTROL_PRESSED(2, 26)
    end,

    dpad_up_press = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 27)
    end,

    dpad_right_press = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 74)
    end,

    dpad_down_press = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 48)
    end,

    dpad_left_press = function()
        return PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, 85)
    end
}

return CONTROLS
