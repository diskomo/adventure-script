local State = {}
State.__index = State

function State:new(initialState)
    local instance = {
        state = initialState or {}
    }
    setmetatable(instance, State)
    return instance
end

function State:get(key)
    return self.state[key]
end

function State:set(key, value)
    self.state[key] = value
end

function State:reset(newState)
    self.state = newState or {}
end

-- Initial state data
local initialState = {
    -- Displays a controls diagram on screen while holding R3
    showOnScreenControls = false,

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

-- Singleton pattern to ensure only one state instance
local stateInstance = State:new(initialState)

return stateInstance
