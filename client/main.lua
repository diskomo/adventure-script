-- Client entry point: main loop for input polling and grid-spawn handling.

CreateThread(function()
    AdventureTours.InitializeGridSpawn()
    AdventureTours.RemoveGuideWeapons()

    while true do
        AdventureTours.PollGamepadShortcuts()

        if AdventureTours.IsTourGuide() and AdventureTours.Get('spawnModeEnabled') then
            AdventureTours.HandleGridSpawn()
        end

        Wait(0)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    AdventureTours.CleanupGridSpawn()
    AdventureTours.DeleteSpawnedVehicles()
    AdventureTours.DeleteTourBus()
    AdventureTours.SetSuperdriveEnabled(false)
    AdventureTours.CloseMenu()
    AdventureTours.HideControlsOverlay()
    AdventureTours.HideL3MenuOverlay()
end)
