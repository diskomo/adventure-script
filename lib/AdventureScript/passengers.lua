local state = require('lib.AdventureScript.state')
local tour = require('lib.AdventureScript.tour')

local PASSENGERS = {}

-- Keep the fuckin cops off a passenger and keep 'em healthy
PASSENGERS.assistPassenger = function(passenger)
    menu.trigger_commands('bail' .. passenger .. ' on')
    menu.trigger_commands('autoheal' .. passenger .. ' on')

end

PASSENGERS.assistPassengers = function(passengers)
    for i = 0, #passengers do
        menu.trigger_commands('bail' .. passengers[i] .. ' on')
        menu.trigger_commands('autoheal' .. passengers[i] .. ' on')
    end
end

PASSENGERS.getLocalPlayers = function()
    local playerPed = PLAYER_PED_ID()
    local playerPos = GET_ENTITY_COORDS(playerPed)
    local radius = 10000
    local playersList = {}
    for i = 0, 31 do
        if NETWORK_IS_PLAYER_ACTIVE(i) and i ~= PLAYER_ID() then
            local ped = GET_PLAYER_PED(i)
            local pedPos = GET_ENTITY_COORDS(ped)
            local distance = VDIST2(playerPos.x, playerPos.y, playerPos.z, pedPos.x, pedPos.y, pedPos.z)
            if distance <= radius then
                local playerName = GET_PLAYER_NAME(i)
                if (playerName ~= '**Invalid**') then
                    table.insert(playersList, playerName)
                end
            end
        end
    end
    return playersList
end

PASSENGERS.updatePassengers = function()
    -- local player = GET_PLAYER_INDEX()
    local playerPed = PLAYER_PED_ID()
    local allPlayersIds = players.list(false, true, true)
    local isInVehicle = IS_PED_IN_ANY_VEHICLE(playerPed, false)
    if isInVehicle then
        if tour.isDrivingBus() then
            local bus = GET_VEHICLE_PED_IS_IN(playerPed, false)
            -- Set the bus' map blip to a yellow tour bus sprite
            -- local blip = ADD_BLIP_FOR_ENTITY(bus)
            -- if blip ~= nil then
            --     SET_BLIP_AS_FRIENDLY(blip, true)
            --     SET_BLIP_SPRITE(blip, 85) -- Tour bus sprite
            --     SET_BLIP_COLOUR(blip, 81) -- Gold color
            --     SET_BLIP_SECONDARY_COLOUR(blip, data.brandColor.r, data.brandColor.g, data.brandColor.b)
            --     SET_BLIP_NAME_TO_PLAYER_NAME(blip, player)
            -- end

            local busPassengers = {}

            for i = 0, GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(bus, false, false) do
                local passenger = GET_PED_IN_VEHICLE_SEAT(bus, i, false)
                if passenger ~= nil then
                    local passengerName = GET_PLAYER_NAME(NETWORK_GET_PLAYER_INDEX_FROM_PED(passenger))
                    if (passengerName ~= '**Invalid**' and passengerName ~= nil) then
                        table.insert(busPassengers, i, passengerName)
                        PASSENGERS.assistPassenger(passengerName)
                    end
                end
            end

            state.currentPassengers = busPassengers

            local licensePlate = 'ADVTOUR'
            if #busPassengers > 0 and #busPassengers < 10 then
                licensePlate = licensePlate .. tostring(#busPassengers)
            else
                licensePlate = licensePlate .. 'S'
            end
            SET_VEHICLE_NUMBER_PLATE_TEXT(bus, licensePlate)
            util.toast((#busPassengers > 0 and 'Assisted passengers. ' or 'Empty bus. ') .. tostring(#busPassengers) ..
                           ' out of ' .. tostring(#allPlayersIds) .. ' are on the bus.')
        end
    else
        local localPlayers = PASSENGERS.getLocalPlayers()
        PASSENGERS.assistPassengers(localPlayers)
        state.currentPassengers = localPlayers
        util.toast('Found ' .. tostring(#localPlayers) .. ' local players.')
    end
end

return PASSENGERS
