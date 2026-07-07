-- Keyboard/gamepad shortcuts, modifier handling, and L3 radial input.

local doublePressTime = 500
local lastMiniMenuDrivingBus

local MODIFIER_CONTROL = 26 -- R3 / look behind (gamepad)
local L3_MENU_TOGGLE_CONTROL = 36 -- INPUT_DUCK / L3 (native gamepad)
local L3_MENU_ALT_CONTROL = 28 -- INPUT_SPECIAL_ABILITY / L3 (native gamepad)
local KEYBOARD_MODIFIER_CONTROL = 19 -- Left Alt / character wheel
local SUPERDRIVE_CONTROL = 226 -- L1 / INPUT_SCRIPT_LB (gamepad, no keyboard default)
local MENU_CONTROL = 227 -- R1 / INPUT_SCRIPT_RB (gamepad, no keyboard default)
local CANCEL_ACTION_CONTROL = 177 -- Back / Select
local HUB_ACCEPT_CONTROLS = {
    22,  -- INPUT_JUMP (X / Square)
    203, -- INPUT_FRONTEND_X (X / Square)
    193, -- INPUT_FRONTEND_RLEFT (X / Square)
    224, -- INPUT_SCRIPT_RLEFT (X / Square)
    179, -- INPUT_CELLPHONE_EXTRA_OPTION (X / Square)
}

local pendingLeftTap = nil
local pendingRightTap = nil

local function isModifierHeld()
    if IsControlPressed(0, MODIFIER_CONTROL) or IsDisabledControlPressed(0, MODIFIER_CONTROL) then
        return true
    end

    -- Left Alt (control 19) shares its id with DPAD Down on a gamepad, so only
    -- accept it as the modifier when the last input came from keyboard/mouse.
    if IsInputDisabled(0) then
        return IsControlPressed(0, KEYBOARD_MODIFIER_CONTROL)
            or IsDisabledControlPressed(0, KEYBOARD_MODIFIER_CONTROL)
    end

    return false
end

local function l3MenuInputActive()
    return AdventureTours.Get('l3MenuOpen') or AdventureTours.CanUseL3Menu()
end

local function disableL3MenuControls()
    if not l3MenuInputActive() then
        return
    end

    DisableControlAction(0, L3_MENU_TOGGLE_CONTROL, true)
    DisableControlAction(0, L3_MENU_ALT_CONTROL, true)
end

local function disableL3MenuDpadControls()
    if not AdventureTours.Get('l3MenuOpen') then
        return
    end

    DisableControlAction(0, 27, true) -- INPUT_PHONE / DPAD UP
    DisableControlAction(0, 48, true) -- INPUT_HUD_SPECIAL / DPAD DOWN
    DisableControlAction(0, 85, true) -- INPUT_VEH_RADIO_WHEEL / DPAD LEFT
    DisableControlAction(0, 74, true) -- INPUT_VEH_HEADLIGHT / DPAD RIGHT

    for _, control in ipairs(HUB_ACCEPT_CONTROLS) do
        DisableControlAction(0, control, true)
        DisableControlAction(2, control, true)
    end
end

local function disableModifierDpadControls()
    if not isModifierHeld() then
        return
    end

    DisableControlAction(0, 27, true) -- INPUT_PHONE / DPAD UP
    DisableControlAction(0, 48, true) -- INPUT_HUD_SPECIAL / DPAD DOWN
    DisableControlAction(0, 85, true) -- INPUT_VEH_RADIO_WHEEL / DPAD LEFT
    DisableControlAction(0, 74, true) -- INPUT_VEH_HEADLIGHT / DPAD RIGHT
end

local function l3MenuTogglePress()
    return IsDisabledControlJustPressed(0, L3_MENU_TOGGLE_CONTROL)
        or IsDisabledControlJustPressed(0, L3_MENU_ALT_CONTROL)
end

local function dpadUpPress()
    return IsDisabledControlJustPressed(0, 27)
end

local function dpadRightPress()
    return IsDisabledControlJustPressed(0, 74)
end

local function dpadDownPress()
    return IsDisabledControlJustPressed(0, 48)
end

local function dpadLeftPress()
    return IsDisabledControlJustPressed(0, 85)
end

local function hubAcceptPress()
    for _, control in ipairs(HUB_ACCEPT_CONTROLS) do
        if IsDisabledControlJustPressed(0, control)
            or IsDisabledControlJustPressed(2, control)
            or IsControlJustPressed(0, control)
            or IsControlJustPressed(2, control) then
            return true
        end
    end
    return false
end

local function executeL3RadialAction(direction, variant)
    if direction == 'accept' then
        if AdventureTours.Get('tourActive') then
            if AdventureTours.StopTour() then
                AdventureTours.AfterAction()
            end
        elseif variant == 'bus' then
            AdventureTours.StartTour()
            AdventureTours.AfterAction()
        end
        return true
    end

    if direction == 'down' and variant == 'bus' then
        return false
    end

    if direction == 'up' then
        AdventureTours.Set('spawnModeEnabled', not AdventureTours.Get('spawnModeEnabled'))
        AdventureTours.AfterAction()
    elseif direction == 'right' then
        AdventureTours.DeleteVehiclesInArea()
        AdventureTours.AfterAction()
    elseif direction == 'left' then
        if AdventureTours.UndoLastSpawn() then
            AdventureTours.AfterAction()
        end
    elseif direction == 'down' then
        AdventureTours.SpawnAdventureToursBus()
        AdventureTours.AfterAction()
    end

    return true
end

local function scheduleDeferredTap(pendingRef, onSingle)
    local currentTime = GetGameTimer()

    if pendingRef.pressTime and (currentTime - pendingRef.pressTime >= doublePressTime) then
        onSingle()
        pendingRef.pressTime = nil
    end
end

local function handleDeferredDpadPress(pressFn, pendingRef, onSingle, onDouble)
    if not pressFn() then
        return
    end

    local currentTime = GetGameTimer()
    if pendingRef.pressTime and (currentTime - pendingRef.pressTime < doublePressTime) then
        pendingRef.pressTime = nil
        onDouble()
        return
    end

    pendingRef.pressTime = currentTime
end

local function superdriveTogglePress()
    return IsControlJustPressed(0, SUPERDRIVE_CONTROL) or IsDisabledControlJustPressed(0, SUPERDRIVE_CONTROL)
end

local function menuTogglePress()
    return IsControlJustPressed(0, MENU_CONTROL) or IsDisabledControlJustPressed(0, MENU_CONTROL)
end

local function cancelActionPress()
    return IsControlJustPressed(0, CANCEL_ACTION_CONTROL) or IsDisabledControlJustPressed(0, CANCEL_ACTION_CONTROL)
end

local function requireGuide()
    return AdventureTours.IsTourGuide()
end

local function requireGuideModifier(action)
    if not isModifierHeld() or not requireGuide() then
        return
    end
    action()
end

local function requireGuideAction(action)
    if not requireGuide() then
        return
    end
    action()
end

RegisterCommand('adventuretours', function()
    AdventureTours.ToggleMainMenu()
end, false)

RegisterKeyMapping('adventuretours', 'Open Adventure Tours menu', 'keyboard', 'F6')

RegisterCommand('adventure_cycle_venue_prev', function()
    requireGuideModifier(function()
        local name = AdventureTours.CycleLocationForCurrentStop(-1)
        if name then
            AdventureTours.AfterAction()
        end
    end)
end, false)

RegisterKeyMapping('adventure_cycle_venue_prev', 'Adventure Tours: Previous venue (with modifier)', 'keyboard', 'LEFT')

RegisterCommand('adventure_cycle_venue_next', function()
    requireGuideModifier(function()
        local name = AdventureTours.CycleLocationForCurrentStop(1)
        if name then
            AdventureTours.AfterAction()
        end
    end)
end, false)

RegisterKeyMapping('adventure_cycle_venue_next', 'Adventure Tours: Next venue (with modifier)', 'keyboard', 'RIGHT')

RegisterCommand('adventure_prev_stop', function()
    requireGuideModifier(function()
        if AdventureTours.Get('tourActive') then
            AdventureTours.GoToPreviousTourStop()
            AdventureTours.AfterAction()
        end
    end)
end, false)

RegisterKeyMapping('adventure_prev_stop', 'Adventure Tours: Previous stop (with modifier)', 'keyboard', 'PAGEUP')

RegisterCommand('adventure_next_stop', function()
    requireGuideModifier(function()
        if AdventureTours.Get('tourActive') then
            AdventureTours.GoToNextTourStop()
            AdventureTours.AfterAction()
        end
    end)
end, false)

RegisterKeyMapping('adventure_next_stop', 'Adventure Tours: Next stop (with modifier)', 'keyboard', 'PAGEDOWN')

RegisterCommand('adventure_cycle_vehicle', function()
    requireGuideModifier(function()
        if AdventureTours.CycleSpawnVehicleForCurrentStop(1) then
            AdventureTours.AfterAction()
        end
    end)
end, false)

RegisterKeyMapping('adventure_cycle_vehicle', 'Adventure Tours: Next spawn vehicle (with modifier)', 'keyboard', 'UP')

RegisterCommand('adventure_cycle_vehicle_prev', function()
    requireGuideModifier(function()
        if AdventureTours.CycleSpawnVehicleForCurrentStop(-1) then
            AdventureTours.AfterAction()
        end
    end)
end, false)

RegisterKeyMapping('adventure_cycle_vehicle_prev', 'Adventure Tours: Previous spawn vehicle (with modifier)', 'keyboard', 'DOWN')

RegisterCommand('adventure_toggle_spawn', function()
    requireGuideAction(function()
        if not AdventureTours.CanUseL3Menu() then
            return
        end

        AdventureTours.Set('spawnModeEnabled', not AdventureTours.Get('spawnModeEnabled'))
        AdventureTours.AfterAction()
    end)
end, false)

RegisterKeyMapping('adventure_toggle_spawn', 'Adventure Tours: Toggle spawn mode', 'keyboard', 'G')

RegisterCommand('adventure_clear_area', function()
    requireGuideAction(function()
        if not AdventureTours.CanUseL3Menu() then
            return
        end

        AdventureTours.DeleteVehiclesInArea()
        AdventureTours.AfterAction()
    end)
end, false)

RegisterKeyMapping('adventure_clear_area', 'Adventure Tours: Clear area', 'keyboard', 'DELETE')

RegisterCommand('adventure_undo_spawn', function()
    requireGuideAction(function()
        if not AdventureTours.CanUseL3Menu() then
            return
        end

        if AdventureTours.UndoLastSpawn() then
            AdventureTours.AfterAction()
        end
    end)
end, false)

RegisterKeyMapping('adventure_undo_spawn', 'Adventure Tours: Undo last spawn', 'keyboard', 'BACK')

RegisterCommand('adventure_spawn_bus', function()
    requireGuideAction(function()
        if not AdventureTours.CanUseL3Menu() then
            return
        end

        AdventureTours.SpawnAdventureToursBus()
        AdventureTours.AfterAction()
    end)
end, false)

RegisterKeyMapping('adventure_spawn_bus', 'Adventure Tours: Spawn bus', 'keyboard', 'B')

RegisterCommand('adventure_cancel_action', function()
    requireGuideModifier(function()
        AdventureTours.CancelGuideAction()
    end)
end, false)

RegisterKeyMapping('adventure_cancel_action', 'Adventure Tours: Cancel animation (with modifier)', 'keyboard', 'HOME')

RegisterCommand('adventure_apply_outfit', function()
    requireGuideModifier(function()
        AdventureTours.ApplyTourGuideOutfit(true)
    end)
end, false)

RegisterKeyMapping('adventure_apply_outfit', 'Adventure Tours: Apply tour guide outfit (with modifier)', 'keyboard', 'END')

RegisterCommand('adventure_toggle_l3_menu', function()
    if not requireGuide() or AdventureTours.Get('menuOpen') or isModifierHeld() then
        return
    end

    AdventureTours.ToggleL3Menu()
end, false)

RegisterKeyMapping('adventure_toggle_l3_menu', 'Adventure Tours: Toggle quick actions menu', 'PAD_ANALOGBUTTON', 'L3')

function AdventureTours.PollGamepadShortcuts()
    local modifierHeld = isModifierHeld()
    AdventureTours.Set('modifierHeld', modifierHeld)

    disableL3MenuControls()
    disableL3MenuDpadControls()
    disableModifierDpadControls()

    if AdventureTours.Get('l3MenuOpen') and not AdventureTours.CanUseL3Menu() then
        AdventureTours.CloseL3Menu()
    end

    AdventureTours.UpdateControlsOverlay()
    AdventureTours.UpdateL3MenuOverlay()

    if AdventureTours.Get('miniMenuEnabled') then
        local drivingBus = AdventureTours.IsDrivingBus()
        if lastMiniMenuDrivingBus ~= drivingBus then
            lastMiniMenuDrivingBus = drivingBus
            AdventureTours.PushMiniMenuOverlay()
        end
    end

    if l3MenuTogglePress() and requireGuide() and not modifierHeld and not AdventureTours.Get('menuOpen') then
        AdventureTours.ToggleL3Menu()
    end

    if AdventureTours.Get('l3MenuOpen') then
        local acted = false
        local variant = AdventureTours.GetL3MenuVariant()

        if dpadUpPress() then
            acted = executeL3RadialAction('up', variant)
        elseif dpadRightPress() then
            acted = executeL3RadialAction('right', variant)
        elseif dpadLeftPress() then
            acted = executeL3RadialAction('left', variant)
        elseif dpadDownPress() then
            acted = executeL3RadialAction('down', variant)
        elseif hubAcceptPress() then
            acted = executeL3RadialAction('accept', variant)
        end

        if acted then
            AdventureTours.CloseL3Menu()
        end
        return
    end

    if not modifierHeld then
        pendingLeftTap = nil
        pendingRightTap = nil
        return
    end

    if menuTogglePress() then
        AdventureTours.ToggleMainMenu()
        return
    end

    if AdventureTours.Get('menuOpen') then
        return
    end

    if not requireGuide() then
        return
    end

    if superdriveTogglePress() then
        AdventureTours.SetSuperdriveEnabled(not AdventureTours.Get('superdriveEnabled'))
        AdventureTours.AfterAction()
    end

    if cancelActionPress() then
        AdventureTours.CancelGuideAction()
    end

    if dpadUpPress() then
        if AdventureTours.CycleSpawnVehicleForCurrentStop(1) then
            AdventureTours.AfterAction()
        end
    end

    if dpadDownPress() then
        if AdventureTours.CycleSpawnVehicleForCurrentStop(-1) then
            AdventureTours.AfterAction()
        end
    end

    pendingLeftTap = pendingLeftTap or {}
    pendingRightTap = pendingRightTap or {}

    scheduleDeferredTap(pendingLeftTap, function()
        local name = AdventureTours.CycleLocationForCurrentStop(-1)
        if name then
            AdventureTours.AfterAction()
        end
    end)

    scheduleDeferredTap(pendingRightTap, function()
        local name = AdventureTours.CycleLocationForCurrentStop(1)
        if name then
            AdventureTours.AfterAction()
        end
    end)

    handleDeferredDpadPress(dpadLeftPress, pendingLeftTap, function()
        local name = AdventureTours.CycleLocationForCurrentStop(-1)
        if name then
            AdventureTours.AfterAction()
        end
    end, function()
        if AdventureTours.Get('tourActive') then
            AdventureTours.GoToPreviousTourStop()
            AdventureTours.AfterAction()
        end
    end)

    handleDeferredDpadPress(dpadRightPress, pendingRightTap, function()
        local name = AdventureTours.CycleLocationForCurrentStop(1)
        if name then
            AdventureTours.AfterAction()
        end
    end, function()
        if AdventureTours.Get('tourActive') then
            AdventureTours.GoToNextTourStop()
            AdventureTours.AfterAction()
        end
    end)
end
