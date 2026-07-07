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

-- Function to navigate to the next tour stop
TOUR.goToNextTourStop = function()
    state:set('currentTourStopIndex', state:get('currentTourStopIndex') + 1)
    if state:get('currentTourStopIndex') > #data.tourStops then
        state:set('currentTourStopIndex', 1)
    end
    local currentTourStop = getCurrentTourStop(state:get('currentTourStopIndex'))
    setVehicleForTourStop(currentTourStop)
    teleportPlayerToTourStop(currentTourStop)
end

-- Function to navigate to the previous tour stop
TOUR.goToPreviousTourStop = function()
    state:set('currentTourStopIndex', state:get('currentTourStopIndex') - 1)
    if state:get('currentTourStopIndex') < 1 then
        state:set('currentTourStopIndex', #data.tourStops)
    end
    local currentTourStop = getCurrentTourStop(state:get('currentTourStopIndex'))
    setVehicleForTourStop(currentTourStop)
    teleportPlayerToTourStop(currentTourStop)
end

-- Check if the player is currently driving a bus
TOUR.isDrivingBus = function()
    local playerPed = PLAYER_PED_ID()
    local playerVehicle = GET_VEHICLE_PED_IS_IN(playerPed, false)

    if playerVehicle ~= 0 then
        local vehicleModel = GET_ENTITY_MODEL(playerVehicle)
        local busModelHash = GET_HASH_KEY(state:get('busType'))
        return vehicleModel == busModelHash
    end

    return false
end

-- Delete the tour bus
TOUR.deleteTourBus = function()
    if state:get('theTourBus') and DOES_ENTITY_EXIST(state:get('theTourBus')) then
        entities.delete_by_handle(state:get('theTourBus'))
        state:set('theTourBus', nil)
    end
end

return TOUR
