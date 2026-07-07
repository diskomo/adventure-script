-- Main menu open/close, NUI focus, and init trigger.

function AdventureTours.UpdateMiniMenuFocus()
    if AdventureTours.Get('menuOpen') then
        SetNuiFocusKeepInput(false)
        SetNuiFocus(true, true)
        return
    end

    if AdventureTours.Get('l3MenuOpen') then
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
        return
    end

    if AdventureTours.Get('miniMenuEnabled') then
        SetNuiFocusKeepInput(true)
        SetNuiFocus(true, true)
        return
    end

    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
end

function AdventureTours.OpenMainMenu()
    AdventureTours.CloseL3Menu()
    AdventureTours.Set('menuOpen', true)
    AdventureTours.UpdateMiniMenuFocus()
    AdventureTours.SendNuiInit()
    AdventureTours.RefreshPassengerData()
    AdventureTours.AfterAction()
    SendNUIMessage({ action = 'menu:open' })
end

function AdventureTours.CloseMenu()
    if not AdventureTours.Get('menuOpen') then
        return
    end

    AdventureTours.Set('menuOpen', false)
    AdventureTours.UpdateMiniMenuFocus()
    SendNUIMessage({ action = 'menu:close' })
end

function AdventureTours.ToggleMainMenu()
    if AdventureTours.Get('menuOpen') then
        AdventureTours.CloseMenu()
    else
        AdventureTours.OpenMainMenu()
    end
end
