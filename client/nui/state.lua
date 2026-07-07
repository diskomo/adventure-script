-- NUI state serialization, HUD/mini-menu/L3 overlays, and client push helpers.

local lastHudVisible = nil
local lastL3MenuVisible = nil
local lastL3MenuVariant = nil
local lastL3MenuSpawnEnabled = nil
local lastL3MenuUndoCount = nil
local lastL3MenuTourActive = nil
local lastL3MenuDrivingBus = nil
local lastL3MenuToggleAt = 0
local L3_MENU_TOGGLE_DEBOUNCE_MS = 300

local MINI_MENU_STATE_KEYS = {
    'currentTourStopIndex',
    'currentStopName',
    'currentTourLocationIndex',
    'currentTourLocationName',
    'spawnModeEnabled',
    'superdriveEnabled',
    'spawnVehicleName',
    'spawnUndoCount',
    'tourActive',
    'isDrivingBus',
    'miniMenuEnabled',
    'miniMenuCorner',
    'isGuide',
    'guideName',
    'following',
    'ready',
    'helpState',
    'nextStopVoted',
    'serverStopIndex',
    'currentStopName',
}

local HUD_STATE_KEYS = {
    'currentTourStopIndex',
    'currentStopName',
    'spawnModeEnabled',
    'superdriveEnabled',
    'spawnVehicleName',
    'tourActive',
}

local function pick(state, keys)
    local subset = {}
    for _, key in ipairs(keys) do
        subset[key] = state[key]
    end
    return subset
end

local function resetL3MenuCache()
    lastL3MenuVisible = false
    lastL3MenuVariant = nil
    lastL3MenuSpawnEnabled = nil
    lastL3MenuUndoCount = nil
    lastL3MenuTourActive = nil
    lastL3MenuDrivingBus = nil
end

local function rgbToHex(colour)
    return ('#%02X%02X%02X'):format(colour.r or 0, colour.g or 0, colour.b or 0)
end

local function brandColourHex()
    return rgbToHex(GetBrandColour(AdventureTours.Get('brandColour')))
end

local function serializeTourStops()
    local stops = {}
    for _, tourStop in ipairs(TourStops) do
        local locations = {}
        for _, location in ipairs(tourStop.locations or {}) do
            locations[#locations + 1] = {
                name = location.name,
                id = location.id,
            }
        end

        local vehicles = {}
        for _, vehicle in ipairs(tourStop.vehicles or {}) do
            vehicles[#vehicles + 1] = {
                name = vehicle.name,
                id = vehicle.id,
                icon = vehicle.icon or 'car',
            }
        end

        stops[#stops + 1] = {
            name = tourStop.name,
            description = tourStop.description,
            rainbowModeDefault = tourStop.rainbowMode == true,
            locations = locations,
            vehicles = vehicles,
        }
    end
    return stops
end

local function serializeActions()
    local actions = {}
    for _, action in ipairs(Branding.actions) do
        actions[#actions + 1] = {
            id = action.id,
            name = action.name,
            icon = action.icon,
            type = action.type,
            variants = action.variants,
        }
    end
    return actions
end

local function serializeColours()
    local colours = {}
    for colourKey, colour in pairs(Branding.colours) do
        colours[colourKey] = rgbToHex(colour)
    end
    return colours
end

function AdventureTours.AfterAction(opts)
    opts = opts or {}
    if opts.pushState ~= false then
        AdventureTours.PushNuiState()
    end
end

function AdventureTours.BuildNuiState()
    local stopIndex = AdventureTours.Get('currentTourStopIndex')
    local stopName = 'No stop selected'
    if stopIndex and stopIndex > 0 and TourStops[stopIndex] then
        stopName = TourStops[stopIndex].name
    end

    local locationIndex = AdventureTours.Get('currentTourLocationIndex') or 1
    local locationName = '—'
    if stopIndex and stopIndex > 0 and TourStops[stopIndex] then
        local tourStop = TourStops[stopIndex]
        local location = tourStop.locations and tourStop.locations[locationIndex]
        if location then
            locationName = location.name
        elseif tourStop.locations and tourStop.locations[1] then
            locationName = tourStop.locations[1].name
        end
    end

    return {
        currentTourStopIndex = stopIndex,
        currentStopName = stopName,
        currentTourLocationIndex = locationIndex,
        currentTourLocationName = locationName,
        spawnModeEnabled = AdventureTours.Get('spawnModeEnabled'),
        superdriveEnabled = AdventureTours.Get('superdriveEnabled'),
        busType = AdventureTours.Get('busType'),
        brandColour = AdventureTours.Get('brandColour'),
        stopRainbowModes = AdventureTours.GetStopRainbowModesForNui(),
        showOnScreenControls = AdventureTours.Get('showOnScreenControls'),
        miniMenuEnabled = AdventureTours.Get('miniMenuEnabled'),
        miniMenuCorner = AdventureTours.Get('miniMenuCorner'),
        tourActive = AdventureTours.Get('tourActive'),
        autoChat = AdventureTours.Get('autoChat'),
        isDrivingBus = AdventureTours.IsDrivingBus(),
        spawnVehicleName = AdventureTours.Get('spawnTargetName') or '—',
        spawnUndoCount = AdventureTours.GetSpawnUndoCount(),
        accentHex = brandColourHex(),
        isGuide = AdventureTours.IsTourGuide(),
        guideId = AdventureTours.Get('guideId'),
        guideName = AdventureTours.Get('guideName'),
        following = AdventureTours.IsFollowingTour(),
        ready = AdventureTours.Get('ready') == true,
        helpState = AdventureTours.Get('helpState'),
        nextStopVoted = AdventureTours.Get('nextStopVoted') == true,
        tourRoster = AdventureTours.GetTourRosterForNui(),
        onlinePlayers = AdventureTours.GetOnlinePlayersForNui(),
        rosterCounts = AdventureTours.Get('rosterCounts') or { passengers = 0 },
        sessionActive = AdventureTours.Get('sessionActive') == true,
        nextStopVote = AdventureTours.Get('nextStopVote') or { votes = 0, passengerCount = 0, threshold = 0, thresholdMet = false },
        election = AdventureTours.Get('election'),
        serverStopIndex = AdventureTours.Get('serverStopIndex') or 0,
        serverLocationIndex = AdventureTours.Get('serverLocationIndex') or 1,
    }
end

function AdventureTours.PushMiniMenuOverlay()
    local state = AdventureTours.BuildNuiState()
    SendNUIMessage({
        action = 'miniMenu',
        enabled = AdventureTours.Get('miniMenuEnabled'),
        corner = AdventureTours.Get('miniMenuCorner'),
        state = pick(state, MINI_MENU_STATE_KEYS),
    })
end

function AdventureTours.PushNuiState()
    local state = AdventureTours.BuildNuiState()
    state.action = 'menu:state'
    SendNUIMessage(state)
    AdventureTours.PushMiniMenuOverlay()
end

function AdventureTours.SendNuiInit()
    local resource = GetCurrentResourceName()
    SendNUIMessage({
        action = 'menu:init',
        resource = resource,
        bannerSrc = ('https://cfx-nui-%s/html/banner.jpg'):format(resource),
        accentHex = brandColourHex(),
        version = Branding.scriptVersion,
        tourStops = serializeTourStops(),
        actions = serializeActions(),
        colours = serializeColours(),
        controlHints = ControlHints,
        chat = {
            welcome = Branding.welcomeMessage,
            rulesPreview = Branding.tourRules[1] or 'Tour rules',
            invite = Branding.callToActionMessage,
            thankyou = Branding.thankYouMessage,
        },
    })
end

function AdventureTours.UpdateControlsOverlay()
    local visible = AdventureTours.Get('showOnScreenControls') and AdventureTours.Get('modifierHeld') or false
    local variant = AdventureTours.IsDrivingBus() and 'bus' or 'foot'
    local state = AdventureTours.BuildNuiState()

    if not visible then
        if lastHudVisible then
            lastHudVisible = false
            SendNUIMessage({ action = 'hud', visible = false })
        end
        return
    end

    lastHudVisible = true

    SendNUIMessage({
        action = 'hud',
        visible = true,
        variant = variant,
        state = pick(state, HUD_STATE_KEYS),
    })
end

function AdventureTours.HideControlsOverlay()
    lastHudVisible = false
    SendNUIMessage({ action = 'hud', visible = false })
end

function AdventureTours.UpdateL3MenuOverlay()
    local visible = AdventureTours.Get('l3MenuOpen') or false
    local state = AdventureTours.BuildNuiState()

    if not visible then
        if lastL3MenuVisible then
            resetL3MenuCache()
            SendNUIMessage({ action = 'l3Menu', visible = false })
        end
        return
    end

    local variant = AdventureTours.GetL3MenuVariant()
    local spawnModeEnabled = state.spawnModeEnabled
    local spawnUndoCount = state.spawnUndoCount
    local tourActive = state.tourActive
    local isDrivingBus = state.isDrivingBus

    if lastL3MenuVisible
        and lastL3MenuVariant == variant
        and lastL3MenuSpawnEnabled == spawnModeEnabled
        and lastL3MenuUndoCount == spawnUndoCount
        and lastL3MenuTourActive == tourActive
        and lastL3MenuDrivingBus == isDrivingBus then
        return
    end

    lastL3MenuVisible = true
    lastL3MenuVariant = variant
    lastL3MenuSpawnEnabled = spawnModeEnabled
    lastL3MenuUndoCount = spawnUndoCount
    lastL3MenuTourActive = tourActive
    lastL3MenuDrivingBus = isDrivingBus

    SendNUIMessage({
        action = 'l3Menu',
        visible = true,
        variant = variant,
        spawnModeEnabled = spawnModeEnabled,
        spawnUndoCount = spawnUndoCount,
        tourActive = tourActive,
        isDrivingBus = isDrivingBus,
    })
end

function AdventureTours.OpenL3Menu()
    if not AdventureTours.CanUseL3Menu() then
        return
    end

    AdventureTours.Set('l3MenuOpen', true)
    resetL3MenuCache()
    AdventureTours.UpdateMiniMenuFocus()
    AdventureTours.UpdateL3MenuOverlay()
end

function AdventureTours.CloseL3Menu()
    AdventureTours.HideL3MenuOverlay()
end

function AdventureTours.ToggleL3Menu()
    local now = GetGameTimer()
    if now - lastL3MenuToggleAt < L3_MENU_TOGGLE_DEBOUNCE_MS then
        return
    end
    lastL3MenuToggleAt = now

    if AdventureTours.Get('l3MenuOpen') then
        AdventureTours.CloseL3Menu()
        return
    end

    if not AdventureTours.CanUseL3Menu() then
        return
    end

    AdventureTours.OpenL3Menu()
end

function AdventureTours.HideL3MenuOverlay()
    AdventureTours.Set('l3MenuOpen', false)
    resetL3MenuCache()
    SendNUIMessage({ action = 'l3Menu', visible = false })
    AdventureTours.UpdateMiniMenuFocus()
end

RegisterNetEvent('adventure_tours:receiveBanner', function(b64)
    if type(b64) ~= 'string' or b64 == '' then
        return
    end

    SendNUIMessage({
        action = 'banner:b64',
        data = b64,
    })
end)
