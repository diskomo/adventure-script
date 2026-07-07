-- Server-side single tour guide, roster, passenger signals, and elections.

local ELECTION_DURATION_SEC = Branding.electionDurationSec or 30
local ELECTION_COOLDOWN_SEC = Branding.electionCooldownSec or 90
local NEXT_STOP_VOTE_THRESHOLD = Branding.nextStopVoteThreshold or 0.5

---@class RosterEntry
---@field name string
---@field ready boolean
---@field help 'stuck' | 'injured' | nil
---@field nextStopVote boolean
---@field following boolean

---@class TourState
---@field active boolean
---@field stopIndex integer
---@field locationIndex integer
---@field busNetId integer

---@class ElectionState
---@field active boolean
---@field candidateId integer
---@field candidateName string
---@field starterId integer
---@field votes table<integer, boolean>
---@field expiresAt integer

local guideId = nil
local joinOrder = {} ---@type { id: integer, joinedAt: integer }[]
local roster = {} ---@type table<integer, RosterEntry>
local tour = {
    active = false,
    stopIndex = 1,
    locationIndex = 1,
    busNetId = 0,
}
local election = {
    active = false,
    candidateId = 0,
    candidateName = '',
    starterId = 0,
    votes = {},
    expiresAt = 0,
}
local electionCooldownUntil = 0
local nextStopVoteNotified = false

local function getPlayerNameSafe(playerId)
    return GetPlayerName(playerId) or ('Player %d'):format(playerId)
end

local function isValidPlayerId(playerId)
    return playerId and playerId > 0 and GetPlayerName(playerId) ~= nil
end

local function isGuide(playerId)
    return guideId ~= nil and playerId == guideId
end

local function countPassengers()
    local count = 0
    for playerId in pairs(roster) do
        if playerId ~= guideId and isValidPlayerId(playerId) then
            count = count + 1
        end
    end
    return count
end

local function countNextStopVotes()
    local votes = 0
    for playerId, entry in pairs(roster) do
        if playerId ~= guideId and entry.nextStopVote then
            votes = votes + 1
        end
    end
    return votes
end

local function getNextStopVoteTally()
    local passengerCount = countPassengers()
    local votes = countNextStopVotes()
    local threshold = math.floor(passengerCount * NEXT_STOP_VOTE_THRESHOLD) + 1
    return {
        votes = votes,
        passengerCount = passengerCount,
        threshold = passengerCount > 0 and threshold or 0,
        thresholdMet = passengerCount > 0 and votes >= threshold,
    }
end

local function clearRosterSignals()
    for _, entry in pairs(roster) do
        entry.ready = false
        entry.help = nil
        entry.nextStopVote = false
    end
    nextStopVoteNotified = false
end

local function serializeRoster()
    local list = {}
    for playerId, entry in pairs(roster) do
        list[#list + 1] = {
            id = playerId,
            name = entry.name,
            ready = entry.ready,
            help = entry.help,
            nextStopVote = entry.nextStopVote,
            following = entry.following,
            isGuide = playerId == guideId,
        }
    end
    table.sort(list, function(a, b)
        if a.isGuide ~= b.isGuide then
            return a.isGuide
        end
        return a.name:lower() < b.name:lower()
    end)
    return list
end

local function serializeElection()
    if not election.active then
        return nil
    end

    local yesVotes, noVotes, totalVotes = 0, 0, 0
    for _, vote in pairs(election.votes) do
        totalVotes = totalVotes + 1
        if vote then
            yesVotes = yesVotes + 1
        else
            noVotes = noVotes + 1
        end
    end

    return {
        active = true,
        candidateId = election.candidateId,
        candidateName = election.candidateName,
        starterId = election.starterId,
        yesVotes = yesVotes,
        noVotes = noVotes,
        totalVotes = totalVotes,
        expiresAt = election.expiresAt,
        remainingSec = math.max(0, election.expiresAt - os.time()),
    }
end

local function pushStateToAll()
    local payload = {
        guideId = guideId,
        guideName = guideId and getPlayerNameSafe(guideId) or nil,
        tourActive = tour.active,
        stopIndex = tour.stopIndex,
        locationIndex = tour.locationIndex,
        busNetId = tour.busNetId,
        roster = serializeRoster(),
        nextStopVote = getNextStopVoteTally(),
        election = serializeElection(),
    }

    TriggerClientEvent('adventure_tours:serverState', -1, payload)
end

local function pushStateToPlayer(playerId)
    local payload = {
        guideId = guideId,
        guideName = guideId and getPlayerNameSafe(guideId) or nil,
        tourActive = tour.active,
        stopIndex = tour.stopIndex,
        locationIndex = tour.locationIndex,
        busNetId = tour.busNetId,
        roster = serializeRoster(),
        nextStopVote = getNextStopVoteTally(),
        election = serializeElection(),
    }

    TriggerClientEvent('adventure_tours:serverState', playerId, payload)
end

local function pushRosterToGuide()
    if not guideId or not isValidPlayerId(guideId) then
        return
    end

    TriggerClientEvent('adventure_tours:rosterUpdated', guideId, serializeRoster(), {
        passengers = countPassengers(),
    }, tour.active, tour.stopIndex, tour.locationIndex, tour.busNetId, getNextStopVoteTally())
end

local function broadcastRoleChanged()
    for _, entry in ipairs(joinOrder) do
        if isValidPlayerId(entry.id) then
            TriggerClientEvent('adventure_tours:roleChanged', entry.id, entry.id == guideId, guideId, getPlayerNameSafe(guideId))
        end
    end
    pushStateToAll()
end

local function addPlayerToRoster(playerId)
    roster[playerId] = {
        name = getPlayerNameSafe(playerId),
        ready = false,
        help = nil,
        nextStopVote = false,
        following = true,
    }
end

local function removePlayerFromRoster(playerId)
    roster[playerId] = nil
end

local function recordJoinOrder(playerId)
    for _, entry in ipairs(joinOrder) do
        if entry.id == playerId then
            return
        end
    end

    joinOrder[#joinOrder + 1] = {
        id = playerId,
        joinedAt = os.time(),
    }
end

local function removeJoinOrder(playerId)
    for i = #joinOrder, 1, -1 do
        if joinOrder[i].id == playerId then
            table.remove(joinOrder, i)
            return
        end
    end
end

local function getLongestConnectedPlayer(excludeId)
    local bestId, bestTime = nil, nil
    for _, entry in ipairs(joinOrder) do
        if entry.id ~= excludeId and isValidPlayerId(entry.id) then
            if not bestTime or entry.joinedAt < bestTime then
                bestId = entry.id
                bestTime = entry.joinedAt
            end
        end
    end
    return bestId
end

local function assignGuide(newGuideId, reason)
    if not isValidPlayerId(newGuideId) then
        return false
    end

    local wasGuide = guideId
    guideId = newGuideId

    if roster[newGuideId] then
        roster[newGuideId].ready = false
        roster[newGuideId].help = nil
        roster[newGuideId].nextStopVote = false
    end

    clearRosterSignals()

    if wasGuide ~= newGuideId then
        if reason then
            TriggerClientEvent('chat:addMessage', -1, {
                color = { Branding.colours.yellow.r, Branding.colours.yellow.g, Branding.colours.yellow.b },
                multiline = true,
                args = { 'Adventure Tours', reason },
            })
        end
        broadcastRoleChanged()
    end

    return true
end

local function ensureGuide()
    if guideId and isValidPlayerId(guideId) then
        return
    end

    guideId = nil
    local nextGuide = getLongestConnectedPlayer(nil)
    if nextGuide then
        assignGuide(nextGuide, (Branding.guidePromotedMessage):format(getPlayerNameSafe(nextGuide)))
    end
end

local function cancelElection(reason)
    if not election.active then
        return
    end

    election.active = false
    election.candidateId = 0
    election.candidateName = ''
    election.starterId = 0
    election.votes = {}
    election.expiresAt = 0

    if reason then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { Branding.colours.yellow.r, Branding.colours.yellow.g, Branding.colours.yellow.b },
            multiline = true,
            args = { 'Adventure Tours', reason },
        })
    end

    pushStateToAll()
end

local function finishElection(passed)
    local candidateName = election.candidateName
    local candidateId = election.candidateId

    election.active = false
    election.candidateId = 0
    election.candidateName = ''
    election.starterId = 0
    election.votes = {}
    election.expiresAt = 0
    electionCooldownUntil = os.time() + ELECTION_COOLDOWN_SEC

    if passed and isValidPlayerId(candidateId) then
        assignGuide(candidateId, (Branding.electionPassedMessage):format(candidateName))
    else
        TriggerClientEvent('chat:addMessage', -1, {
            color = { Branding.colours.yellow.r, Branding.colours.yellow.g, Branding.colours.yellow.b },
            multiline = true,
            args = { 'Adventure Tours', (Branding.electionFailedMessage):format(candidateName) },
        })
        pushStateToAll()
    end
end

local function resolveElectionIfComplete()
    if not election.active then
        return
    end

    local yesVotes, noVotes, totalVotes = 0, 0, 0
    for _, vote in pairs(election.votes) do
        totalVotes = totalVotes + 1
        if vote then
            yesVotes = yesVotes + 1
        else
            noVotes = noVotes + 1
        end
    end

    local eligibleVoters = 0
    for playerId in pairs(roster) do
        if playerId ~= election.candidateId and isValidPlayerId(playerId) then
            eligibleVoters = eligibleVoters + 1
        end
    end

    if totalVotes < eligibleVoters then
        return
    end

    finishElection(yesVotes > noVotes)
end

local function fanOutFollowing(eventName, ...)
    for playerId, entry in pairs(roster) do
        if playerId ~= guideId and entry.following and isValidPlayerId(playerId) then
            TriggerClientEvent(eventName, playerId, ...)
        end
    end
end

local function checkNextStopVoteThreshold()
    local tally = getNextStopVoteTally()
    if tally.thresholdMet and not nextStopVoteNotified and guideId and isValidPlayerId(guideId) then
        nextStopVoteNotified = true
        TriggerClientEvent('adventure_tours:nextStopVoteThreshold', guideId, tally.votes, tally.passengerCount)
    end
    pushRosterToGuide()
    pushStateToAll()
end

local function onPlayerConnected(playerId)
    recordJoinOrder(playerId)
    addPlayerToRoster(playerId)

    if not guideId or not isValidPlayerId(guideId) then
        assignGuide(playerId, (Branding.guidePromotedMessage):format(getPlayerNameSafe(playerId)))
    else
        TriggerClientEvent('adventure_tours:roleChanged', playerId, false, guideId, getPlayerNameSafe(guideId))
        pushStateToPlayer(playerId)
    end

    if tour.active then
        TriggerClientEvent('adventure_tours:syncTourStop', playerId, tour.stopIndex, tour.locationIndex)
    end

    pushRosterToGuide()
end

-- Seed join order on resource start from connected players.
CreateThread(function()
    Wait(500)
    local players = GetPlayers()
    table.sort(players, function(a, b)
        return tonumber(a) < tonumber(b)
    end)

    local baseTime = os.time()
    for i, playerIdStr in ipairs(players) do
        local playerId = tonumber(playerIdStr)
        if playerId then
            joinOrder[#joinOrder + 1] = {
                id = playerId,
                joinedAt = baseTime + i,
            }
            addPlayerToRoster(playerId)
        end
    end

    if #joinOrder > 0 then
        assignGuide(joinOrder[1].id, nil)
        pushStateToAll()
    end
end)

AddEventHandler('playerJoining', function()
    local playerId = source
    CreateThread(function()
        Wait(1000)
        if isValidPlayerId(playerId) then
            onPlayerConnected(playerId)
        end
    end)
end)

AddEventHandler('playerDropped', function()
    local playerId = source

    removeJoinOrder(playerId)
    removePlayerFromRoster(playerId)

    if election.active then
        if playerId == election.candidateId then
            cancelElection(Branding.electionCancelledMessage)
        elseif election.votes[playerId] then
            election.votes[playerId] = nil
            resolveElectionIfComplete()
        end
    end

    if playerId == guideId then
        guideId = nil
        clearRosterSignals()
        tour.active = false

        local nextGuide = getLongestConnectedPlayer(nil)
        if nextGuide then
            assignGuide(nextGuide, (Branding.guidePromotedMessage):format(getPlayerNameSafe(nextGuide)))
        else
            pushStateToAll()
        end
        return
    end

    pushRosterToGuide()
    pushStateToAll()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    tour.active = false
    guideId = nil
    roster = {}
    joinOrder = {}
    cancelElection(nil)
end)

-- Guide-only events

RegisterNetEvent('adventure_tours:startTourSession', function(stopIndex, locationIndex, busNetId)
    if not isGuide(source) then
        return
    end

    stopIndex = tonumber(stopIndex) or 1
    locationIndex = tonumber(locationIndex) or 1
    busNetId = tonumber(busNetId) or 0

    tour.active = true
    tour.stopIndex = stopIndex
    tour.locationIndex = locationIndex
    tour.busNetId = busNetId

    clearRosterSignals()
    pushRosterToGuide()
    pushStateToAll()
    fanOutFollowing('adventure_tours:syncTourStop', stopIndex, locationIndex)
end)

RegisterNetEvent('adventure_tours:syncTourStop', function(stopIndex, locationIndex, busNetId)
    if not isGuide(source) then
        return
    end

    if not tour.active then
        return
    end

    stopIndex = tonumber(stopIndex) or tour.stopIndex
    locationIndex = tonumber(locationIndex) or tour.locationIndex
    busNetId = tonumber(busNetId) or tour.busNetId

    tour.stopIndex = stopIndex
    tour.locationIndex = locationIndex
    tour.busNetId = busNetId

    clearRosterSignals()
    pushRosterToGuide()
    pushStateToAll()
    fanOutFollowing('adventure_tours:syncTourStop', stopIndex, locationIndex)
end)

RegisterNetEvent('adventure_tours:endTourSession', function()
    if not isGuide(source) then
        return
    end

    tour.active = false
    clearRosterSignals()

    TriggerClientEvent('chat:addMessage', -1, {
        color = { Branding.colours.yellow.r, Branding.colours.yellow.g, Branding.colours.yellow.b },
        multiline = true,
        args = { 'Adventure Tours', Branding.tourEndedMessage },
    })

    pushRosterToGuide()
    pushStateToAll()
end)

RegisterNetEvent('adventure_tours:updateSessionBus', function(busNetId)
    if not isGuide(source) then
        return
    end

    tour.busNetId = tonumber(busNetId) or 0
    pushRosterToGuide()
    pushStateToAll()
end)

RegisterNetEvent('adventure_tours:gatherPassengers', function(mode)
    if not isGuide(source) then
        return
    end

    clearRosterSignals()

    if mode == 'bus' then
        fanOutFollowing('adventure_tours:gatherToBus', tour.busNetId)
        TriggerClientEvent('chat:addMessage', -1, {
            color = { Branding.colours.yellow.r, Branding.colours.yellow.g, Branding.colours.yellow.b },
            multiline = true,
            args = { 'Adventure Tours', Branding.gatherToBusMessage },
        })
    elseif mode == 'stop' then
        fanOutFollowing('adventure_tours:gatherToStop', tour.stopIndex, tour.locationIndex)
        TriggerClientEvent('chat:addMessage', -1, {
            color = { Branding.colours.yellow.r, Branding.colours.yellow.g, Branding.colours.yellow.b },
            multiline = true,
            args = { 'Adventure Tours', Branding.gatherToStopMessage },
        })
    end

    pushRosterToGuide()
    pushStateToAll()
end)

RegisterNetEvent('adventure_tours:transferGuide', function(targetId)
    if not isGuide(source) then
        return
    end

    targetId = tonumber(targetId)
    if not targetId or targetId == source or not isValidPlayerId(targetId) or not roster[targetId] then
        return
    end

    assignGuide(targetId, (Branding.guideTransferredMessage):format(getPlayerNameSafe(targetId)))
end)

RegisterNetEvent('adventure_tours:requestRoster', function()
    if not isGuide(source) then
        pushStateToPlayer(source)
        return
    end

    pushRosterToGuide()
end)

-- Passenger events

RegisterNetEvent('adventure_tours:setFollowing', function(following)
    local playerId = source
    if isGuide(playerId) then
        return
    end

    local entry = roster[playerId]
    if not entry then
        return
    end

    entry.following = following == true
    pushRosterToGuide()
    pushStateToAll()
end)

RegisterNetEvent('adventure_tours:setReady', function(ready)
    local playerId = source
    if isGuide(playerId) then
        return
    end

    local entry = roster[playerId]
    if not entry then
        return
    end

    entry.ready = ready == true
    pushRosterToGuide()
    pushStateToAll()
end)

RegisterNetEvent('adventure_tours:requestHelp', function(helpType)
    local playerId = source
    if isGuide(playerId) then
        return
    end

    local entry = roster[playerId]
    if not entry then
        return
    end

    if helpType == 'stuck' or helpType == 'injured' then
        entry.help = helpType
        if guideId and isValidPlayerId(guideId) then
            local message = helpType == 'stuck'
                and (Branding.helpStuckMessage):format(entry.name)
                or (Branding.helpInjuredMessage):format(entry.name)
            TriggerClientEvent('adventure_tours:helpSignal', guideId, playerId, entry.name, helpType, message)
        end
    else
        entry.help = nil
    end

    pushRosterToGuide()
    pushStateToAll()
end)

RegisterNetEvent('adventure_tours:voteNextStop', function(voted)
    local playerId = source
    if isGuide(playerId) then
        return
    end

    local entry = roster[playerId]
    if not entry then
        return
    end

    entry.nextStopVote = voted == true
    checkNextStopVoteThreshold()
end)

-- Election events

RegisterNetEvent('adventure_tours:startElection', function(candidateId)
    local starterId = source
    if isGuide(starterId) then
        return
    end

    candidateId = tonumber(candidateId)
    if not candidateId or candidateId == starterId or not isValidPlayerId(candidateId) or not roster[candidateId] then
        return
    end

    if election.active then
        return
    end

    if os.time() < electionCooldownUntil then
        return
    end

    election.active = true
    election.candidateId = candidateId
    election.candidateName = getPlayerNameSafe(candidateId)
    election.starterId = starterId
    election.votes = { [starterId] = true }
    election.expiresAt = os.time() + ELECTION_DURATION_SEC

    TriggerClientEvent('chat:addMessage', -1, {
        color = { Branding.colours.yellow.r, Branding.colours.yellow.g, Branding.colours.yellow.b },
        multiline = true,
        args = { 'Adventure Tours', (Branding.electionStartedMessage):format(election.candidateName) },
    })

    for playerId in pairs(roster) do
        if isValidPlayerId(playerId) and playerId ~= candidateId and not election.votes[playerId] then
            TriggerClientEvent('adventure_tours:electionBallot', playerId, candidateId, election.candidateName, election.expiresAt)
        end
    end

    pushStateToAll()
end)

RegisterNetEvent('adventure_tours:castVote', function(yes)
    local playerId = source
    if not election.active or playerId == election.candidateId then
        return
    end

    if election.votes[playerId] then
        return
    end

    election.votes[playerId] = yes == true
    pushStateToAll()
    resolveElectionIfComplete()
end)

RegisterNetEvent('adventure_tours:requestState', function()
    local playerId = source
    if not roster[playerId] then
        onPlayerConnected(playerId)
        return
    end

    pushStateToPlayer(playerId)
    if guideId and isValidPlayerId(playerId) then
        TriggerClientEvent('adventure_tours:roleChanged', playerId, playerId == guideId, guideId, getPlayerNameSafe(guideId))
    end
end)

exports('IsTourGuide', function(playerId)
    return isGuide(playerId)
end)

CreateThread(function()
    while true do
        Wait(1000)

        if election.active and os.time() >= election.expiresAt then
            local yesVotes, noVotes = 0, 0
            for _, vote in pairs(election.votes) do
                if vote then
                    yesVotes = yesVotes + 1
                else
                    noVotes = noVotes + 1
                end
            end
            finishElection(yesVotes > noVotes)
        end
    end
end)
