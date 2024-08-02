local data = require('lib.AdventureScript.data')
local state = require('lib.AdventureScript.state')
local vehicles = require('lib.AdventureScript.vehicles')

local TOUR = {}

-- Function to get the current tour stop
local function getCurrentTourStop(index)
    return data.tourStops[index]
end

-- Function to set the vehicle for the current tour stop
local function setVehicleForTourStop(tourStop)
    local firstVehicle = tourStop.vehicles[1]
    local hash = util.joaat(firstVehicle.id)
    if IS_MODEL_A_VEHICLE(hash) then
        vehicles.setVehicle(hash, firstVehicle.options, firstVehicle.mods)
    else
        util.log('Model ' .. firstVehicle.id .. ' is not a vehicle.')
    end
end

-- Function to teleport the player to the first location of the current tour stop
local function teleportPlayerToTourStop(tourStop)
    local firstLocation = tourStop.locations[1]
    local playerPed = PLAYER_PED_ID()
    SET_PED_COORDS_KEEP_VEHICLE(playerPed, firstLocation.coords.x, firstLocation.coords.y, firstLocation.coords.z)
end

-- Function to navigate to the next tour stop
TOUR.goToNextTourStop = function()
    state.currentTourStopIndex = state.currentTourStopIndex + 1
    if state.currentTourStopIndex > #data.tourStops then
        state.currentTourStopIndex = 1
    end
    local currentTourStop = getCurrentTourStop(state.currentTourStopIndex)
    setVehicleForTourStop(currentTourStop)
    teleportPlayerToTourStop(currentTourStop)
end

-- Function to navigate to the previous tour stop
TOUR.goToPreviousTourStop = function()
    state.currentTourStopIndex = state.currentTourStopIndex - 1
    if state.currentTourStopIndex < 1 then
        state.currentTourStopIndex = #data.tourStops
    end
    local currentTourStop = getCurrentTourStop(state.currentTourStopIndex)
    setVehicleForTourStop(currentTourStop)
    teleportPlayerToTourStop(currentTourStop)
end

-- Check if the player is currently driving a bus
TOUR.isDrivingBus = function()
    local playerPed = PLAYER_PED_ID()
    local playerVehicle = GET_VEHICLE_PED_IS_IN(playerPed, false)

    if playerVehicle ~= 0 then
        local vehicleModel = GET_ENTITY_MODEL(playerVehicle)
        local busModelHash = GET_HASH_KEY(state.busType)
        return vehicleModel == busModelHash
    end

    return false
end

-- Delete the tour bus
TOUR.deleteTourBus = function()
    if state.theTourBus and DOES_ENTITY_EXIST(state.theTourBus) then
        entities.delete_by_handle(state.theTourBus)
        state.theTourBus = nil
    end
end

return TOUR
