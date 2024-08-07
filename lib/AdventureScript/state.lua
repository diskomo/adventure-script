local STATE = {
    -- Displays a controls diagram on screen while holding R3
    show_on_screen_controls = false,

    -- Keep track of the current tour stop
    currentTourStopIndex = 0,

    -- Keep track of currently spawned vehicles
    spawnedVehicles = {},

    -- Keep track of the tour bus
    theTourBus = nil,

    brandColour = 'yellow',

    -- 'bus' or 'tourbus'
    busType = 'bus',

    spawnModeEnabled = false,
    spawnTargetHash = util.joaat('manchez2'),
    spawnTargetDimensions = nil,
    spawnTargetOptions = {
        drift = false,
        f1Wheels = false,
        randomLivery = false,
        randomColour = false
    },
    spawnTargetModOverrides = {}
}

return STATE
