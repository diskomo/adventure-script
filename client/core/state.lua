-- Shared client state bag and spawn-option copy helpers.

AdventureTours = AdventureTours or {}

local State = {
    showOnScreenControls = true,
    miniMenuEnabled = true,
    miniMenuCorner = 'top-right',
    currentTourStopIndex = 0,
    currentTourLocationIndex = 1,
    spawnedVehicles = {},
    spawnUndoStack = {},
    theTourBus = nil,
    brandColour = 'yellow',
    outfitApplied = false,
    busType = 'bus',
    stopRainbowModes = {},
    spawnModeEnabled = false,
    spawnTargetHash = joaat('manchez2'),
    spawnTargetDimensions = nil,
    spawnTargetOptions = {
        drift = false,
        f1Wheels = false,
        randomLivery = false,
        randomColour = false,
    },
    spawnTargetModOverrides = {},
    superdriveEnabled = true,
    modifierHeld = false,
    menuOpen = false,
    l3MenuOpen = false,
    spawnTargetName = 'Dirtbike',
    tourActive = false,
    autoChat = false,
    isGuide = false,
    guideId = nil,
    guideName = nil,
    following = true,
    ready = false,
    helpState = nil,
    nextStopVoted = false,
    guideBusNetId = 0,
    tourRoster = {},
    rosterCounts = { passengers = 0 },
    sessionActive = false,
    nextStopVote = { votes = 0, passengerCount = 0, threshold = 0, thresholdMet = false },
    election = nil,
    serverStopIndex = 0,
    serverLocationIndex = 1,
}
function AdventureTours.Get(key)
    return State[key]
end

function AdventureTours.Set(key, value)
    State[key] = value
end

function AdventureTours.ResetSpawnOptions()
    State.spawnTargetOptions = {
        drift = false,
        f1Wheels = false,
        randomLivery = false,
        randomColour = false,
    }
    State.spawnTargetModOverrides = {}
end

function AdventureTours.CopyDefaultOptions(options)
    local copy = {}
    for k, v in pairs(DefaultVehicleOptions) do
        copy[k] = v
    end
    if options then
        for k, v in pairs(options) do
            copy[k] = v
        end
    end
    return copy
end

function AdventureTours.CopyModOverrides(mods)
    local copy = {}
    if mods then
        for k, v in pairs(mods) do
            copy[k] = v
        end
    end
    return copy
end
