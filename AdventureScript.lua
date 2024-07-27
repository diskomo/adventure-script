-- AdventureScript
-- by META IIII (aka AdventureTours)
util.require_natives('3095a.g')
util.keep_running()

local auto_updater = require('auto-updater')

local config = require('lib.AdventureScript.config')
local state = require('lib.AdventureScript.state')
local controls = require('lib.AdventureScript.controls')
local gridSpawn = require('lib.AdventureScript.gridspawn')
local tour = require('lib.AdventureScript.tour')
local vehicles = require('lib.AdventureScript.vehicles')
local ui = require('lib.AdventureScript.ui')
local menuHelpers = require('lib.AdventureScript.menu')

---
--- ----------------------------------------
--- START OF HEXAROBI AUTO-UPDATER
util.ensure_package_is_installed('lua/auto-updater')
if auto_updater ~= nil then
    auto_updater.run_auto_update(config.auto_update_config)
end
--- END OF HEXAROBI AUTO-UPDATER
--- ----------------------------------------
---

--- Initialize
menuHelpers.initializeMenu()
gridSpawn.initialize()

--- Tick handler for gamepad controls and grid spawn listener
util.create_tick_handler(function()
    if controls.r3Hold() and state.show_on_screen_controls then
        ui.showGamepadControls(tour.isDrivingBus())
    end

    -- Gamepad shortcuts (R3 + DPad)
    if controls.r3Hold() and controls.dpadDownPress() then
        vehicles.spawnAdventureToursBus()
    end

    if controls.r3Hold() and controls.doubleTapDpadDown() then
        if tour.isDrivingBus() then
            tour.goToNextTourStop()
        end
    end

    if controls.r3Hold() and controls.doubleTapDpadUp() then
        if tour.isDrivingBus() then
            tour.goToPreviousTourStop()
        end
    end

    if controls.r3Hold() and controls.dpadRightPress() then
        state.spawnModeEnabled = not state.spawnModeEnabled
    end

    -- Delete the tour bus (unless driving) and all spawned vehicles
    if controls.r3Hold() and controls.dpadLeftPress() then
        tour.deleteTourBus()
        vehicles.deleteSpawnedVehicles()
    end

    -- Delete all vehicles in radius
    if controls.r3Hold() and controls.doubleTapDpadLeft() then
        vehicles.deleteVehiclesInArea()
    end
    -- Grid spawn handler
    if state.spawnModeEnabled == true then
        DISABLE_CONTROL_ACTION(0, 142, true)
        gridSpawn.handleSpawn(state.spawnTargetHash, state.spawnTargetDimensions, vehicles.makeAdventureVehicle)
    end
end)

util.on_stop(function()
    gridSpawn.handleCleanup()
end)

ui.showLogo()
