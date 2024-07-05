local state = {
    -- Displays a controls diagram on screen while holding R3
    show_on_screen_controls = false,

    -- Used as a list of passengers that are currently on the tour
    currentPassengers = {},

    -- Keep track of the current tour stop
    currentTourStopIndex = 1,

    -- Keep track of currently spawned vehicles
    spawnedVehicles = {},

    -- Keep track of the tour bus
    theTourBus = nil,

    spawnModeEnabled = false,
    spawnTargetHash = util.joaat('manchez2'),
    spawnTargetDimensions = nil,
    spawnTargetOptions = {
        drift = false,
        f1Wheels = false,
        livery = -1,
        randomColor = false
    },
    spawnTargetModOverrides = {}
}

return state
