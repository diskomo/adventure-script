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

CONTROLS.doubleTapDpadUp = function()
    local currentTime = GET_GAME_TIMER()
    if CONTROLS.dpadUpPress() then
        if CONTROLS.lastDpadUpPressTime and (currentTime - CONTROLS.lastDpadUpPressTime < 500) then -- 500ms for double-tap window
            CONTROLS.lastDpadUpPressTime = nil
            return true
        else
            CONTROLS.lastDpadUpPressTime = currentTime
        end
    end
    return false
end

CONTROLS.doubleTapDpadLeft = function()
    local currentTime = GET_GAME_TIMER()
    if CONTROLS.dpadLeftPress() then
        if CONTROLS.lastDpadLeftPressTime and (currentTime - CONTROLS.lastDpadLeftPressTime < 500) then -- 500ms for double-tap window
            CONTROLS.lastDpadLeftPressTime = nil
            return true
        else
            CONTROLS.lastDpadLeftPressTime = currentTime
        end
    end
    return false
end

CONTROLS.doubleTapDpadDown = function()
    local currentTime = GET_GAME_TIMER()
    if CONTROLS.dpadDownPress() then
        if CONTROLS.lastDpadDownPressTime and (currentTime - CONTROLS.lastDpadDownPressTime < 500) then -- 500ms for double-tap window
            CONTROLS.lastDpadDownPressTime = nil
            return true
        else
            CONTROLS.lastDpadDownPressTime = currentTime
        end
    end
    return false
end

CONTROLS.lastDpadUpPressTime = nil
CONTROLS.lastDpadLeftPressTime = nil
CONTROLS.lastDpadDownPressTime = nil

return CONTROLS
