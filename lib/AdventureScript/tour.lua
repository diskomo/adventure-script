local data = require('lib.AdventureScript.data')
local state = require('lib.AdventureScript.state')
local vehicles = require('lib.AdventureScript.vehicles')

local tour = {}

-- Function to navigate to the next tour stop
tour.goToNextTourStop = function()
    -- Increment the tour stop index
    state.currentTourStopIndex = state.currentTourStopIndex + 1

    -- Loop back to the first tour stop if we've reached the end
    if state.currentTourStopIndex > #data.tourStops then
        state.currentTourStopIndex = 1
    end

    -- Get the current tour stop
    local currentTourStop = data.tourStops[state.currentTourStopIndex]

    -- Get the first location of the current tour stop
    local firstLocation = currentTourStop.locations[1]

    -- Get the first vehicle for the current tour stop
    local firstVehicle = currentTourStop.vehicles[1]

    -- Set the spawn target hash to the first vehicle for the current tour stop
    local hash = util.joaat(firstVehicle.id)
    if IS_MODEL_A_VEHICLE(hash) then
        vehicles.setVehicle(hash, firstVehicle.options, firstVehicle.mods)
    else
        util.log('Model ' .. firstVehicle.id .. ' is not a vehicle.')
    end

    -- Teleport the player to the first location of the current tour stop
    local playerPed = PLAYER_PED_ID()
    SET_PED_COORDS_KEEP_VEHICLE(playerPed, firstLocation.coords.x, firstLocation.coords.y, firstLocation.coords.z)
end

-- Check if the player is currently driving a bus
tour.isDrivingBus = function()
    local playerPed = PLAYER_PED_ID()
    local playerVehicle = GET_VEHICLE_PED_IS_IN(playerPed, false)

    if playerVehicle ~= 0 then
        local vehicleModel = GET_ENTITY_MODEL(playerVehicle)
        local busModelHash = GET_HASH_KEY("bus")
        return vehicleModel == busModelHash
    end

    return false
end

-- Delete the tour bus
tour.deleteTourBus = function()
    if state.theTourBus and DOES_ENTITY_EXIST(state.theTourBus) then
        entities.delete_by_handle(state.theTourBus)
        state.theTourBus = nil
    end
end

return tour
