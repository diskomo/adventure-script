-- Guide animations, tour-guide outfit, superdrive, and default guide setup.

local function findGuideAction(actionId)
    for _, action in ipairs(Branding.actions) do
        if action.id == actionId then
            return action
        end
    end
end

local superdriveThreadRunning = false

function AdventureTours.CancelGuideAction()
    ClearPedTasks(PlayerPedId())
end

function AdventureTours.PlayGuideAction(actionId, variants)
    local action = findGuideAction(actionId)
    if not action then
        return
    end

    local ped = PlayerPedId()
    AdventureTours.CancelGuideAction()

    if action.type == 'scen' and action.scenario then
        TaskStartScenarioInPlace(ped, action.scenario, 0, true)
        return
    end

    if not action.dict or not action.clip then
        return
    end

    if not AdventureTours.LoadAnimDict(action.dict) then
        AdventureTours.Notify('Failed to load animation.', 'error')
        return
    end

    local clip = action.clip
    if action.clips and variants then
        local variantIndex = math.random(#variants)
        clip = action.clips[variantIndex] or action.clips[1]
    end

    TaskPlayAnim(ped, action.dict, clip, 8.0, -8.0, -1, 49, 0, false, false, false)
end

local FREEMODE_MALE <const> = joaat('mp_m_freemode_01')

local function ensureFreemodeMale()
    if GetEntityModel(PlayerPedId()) == FREEMODE_MALE then
        return true
    end

    if not AdventureTours.LoadModel(FREEMODE_MALE) then
        return false
    end

    SetPlayerModel(PlayerId(), FREEMODE_MALE)
    SetModelAsNoLongerNeeded(FREEMODE_MALE)
    -- SetPlayerModel spawns a fresh ped with randomised default components.
    SetPedDefaultComponentVariation(PlayerPedId())
    return true
end

-- Freemode head overlays (facial hair, etc.) and hair tint require head blend
-- data. Without it, SetPedHeadOverlay / SetPedHairColor silently do nothing.
-- See https://wiki.rage.mp/wiki/Player::setHeadOverlay
local function ensureHeadBlend(ped)
    SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.0, false)
    local timeout = GetGameTimer() + 1000
    while not HasPedHeadBlendFinished(ped) and GetGameTimer() < timeout do
        Wait(0)
    end
end

local function mergeOutfitTable(base, overlay)
    if not overlay then
        return base
    end

    local merged = {}
    for k, v in pairs(base or {}) do
        merged[k] = v
    end
    for k, v in pairs(overlay) do
        merged[k] = v
    end
    return merged
end

local function buildTourGuideOutfit(colourKey)
    local base = Branding.tourGuideOutfit
    if not base then
        return nil
    end

    local colourOutfit = Branding.tourGuideOutfitColours and Branding.tourGuideOutfitColours[colourKey]
    return {
        components = mergeOutfitTable(base.components, colourOutfit and colourOutfit.components),
        props = mergeOutfitTable(base.props, colourOutfit and colourOutfit.props),
        hairColour = base.hairColour,
        hairHighlight = base.hairHighlight,
        facialHair = base.facialHair,
    }
end

function AdventureTours.ApplyTourGuideOutfit(ensureModel)
    if ensureModel and not ensureFreemodeMale() then
        AdventureTours.Notify('Could not load the freemode ped model.', 'error')
        return
    end

    local ped = PlayerPedId()
    local colourKey = AdventureTours.Get('brandColour') or 'yellow'
    local outfit = buildTourGuideOutfit(colourKey)
    if not outfit then
        return
    end

    if outfit.components then
        for componentId, data in pairs(outfit.components) do
            SetPedComponentVariation(ped, componentId, data.drawable, data.texture, 0)
        end
    end

    if outfit.props then
        for propId, data in pairs(outfit.props) do
            if data.drawable >= 0 then
                SetPedPropIndex(ped, propId, data.drawable, data.texture, true)
            else
                ClearPedProp(ped, propId)
            end
        end
    end

    -- Head blend must be set after components (hair changes reset overlay state).
    ensureHeadBlend(ped)

    SetPedHairColor(ped, outfit.hairColour, outfit.hairHighlight or outfit.hairColour)

    if outfit.facialHair then
        -- Overlay id 1 = Facial Hair (indexes 0–28). Color type 1 = hair palette.
        -- https://wiki.rage.mp/wiki/Player::setHeadOverlay
        -- https://wiki.rage.mp/wiki/Hair_Colors
        SetPedHeadOverlay(ped, 1, outfit.facialHair.index, 1.0)
        SetPedHeadOverlayColor(ped, 1, 1, outfit.facialHair.colour, outfit.facialHair.colour)
    end

    UpdatePedVariation(ped, false, false, false, false)

    AdventureTours.Set('outfitApplied', true)
end

function AdventureTours.RemoveGuideWeapons()
    RemoveAllPedWeapons(PlayerPedId(), true)
end

local SUPERDRIVE_FLY_CONTROL = 73 -- INPUT_VEH_DUCK (A on gamepad / X on keyboard)
local SUPERDRIVE_HANDBRAKE_CONTROL = 76 -- INPUT_VEH_HANDBRAKE (RB / R1)
local SUPERDRIVE_STICK_LR = 59 -- INPUT_VEH_MOVE_LR
local SUPERDRIVE_STICK_UD = 60 -- INPUT_VEH_MOVE_UD
local SUPERDRIVE_MAX_SPEED = 100.0
local SUPERDRIVE_ACCEL_RATE = 5.0
local SUPERDRIVE_COAST_DECEL = 22.0
local SUPERDRIVE_GROUND_CLEARANCE = 2.0
local SUPERDRIVE_HOVER_ROT_SPEED = 90.0
local SUPERDRIVE_HOVER_ROLL_SPEED = 45.0
local SUPERDRIVE_COAST_STOP_SPEED = 0.5

local superdriveCurrentSpeed = 0.0
local superdriveCoastDirection = nil
local superdriveSuspendedVehicle = 0
local superdriveSuspendAnchor = nil
local superdriveGravityDisabledVehicle = 0

local function superdriveControlPressed(control)
    return IsControlPressed(0, control) or IsDisabledControlPressed(0, control)
end

local function superdriveControlNormal(control)
    local value = GetControlNormal(0, control)
    if value == 0.0 then
        value = GetDisabledControlNormal(0, control)
    end
    return value
end

local function superdriveNormalize(vector)
    local magnitude = math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    if magnitude < 0.0001 then
        return vec3(0.0, 1.0, 0.0)
    end
    return vec3(vector.x / magnitude, vector.y / magnitude, vector.z / magnitude)
end

local function superdriveEaseSpeed(current, target, dt, rate)
    if dt <= 0.0 then
        return current
    end
    local blend = 1.0 - math.exp(-rate * dt)
    return current + (target - current) * blend
end

local function superdriveRestoreGravity(vehicle)
    if superdriveGravityDisabledVehicle == 0 then
        return
    end

    if vehicle == 0 or vehicle == superdriveGravityDisabledVehicle then
        SetVehicleGravity(superdriveGravityDisabledVehicle, true)
        superdriveGravityDisabledVehicle = 0
    end
end

local function superdriveDisableGravity(vehicle)
    if superdriveGravityDisabledVehicle ~= vehicle then
        superdriveRestoreGravity(superdriveGravityDisabledVehicle)
        SetVehicleGravity(vehicle, false)
        superdriveGravityDisabledVehicle = vehicle
    end
end

local function superdriveComputeThrustDirection(vehicle)
    local direction = AdventureTours.RotationToDirection(GetGameplayCamRot(2))
    local coords = GetEntityCoords(vehicle)
    local groundZ = AdventureTours.GetGroundZ(coords.x, coords.y, coords.z)
    local nearGround = (coords.z - groundZ) < SUPERDRIVE_GROUND_CLEARANCE

    if nearGround and direction.z < 0.0 then
        return superdriveNormalize(vec3(direction.x, direction.y, 0.0))
    end

    return superdriveNormalize(direction)
end

local function superdriveApplyThrust(vehicle, speed, direction)
    SetEntityVelocity(
        vehicle,
        direction.x * speed,
        direction.y * speed,
        direction.z * speed
    )
end

local function releaseSuspension()
    superdriveSuspendedVehicle = 0
    superdriveSuspendAnchor = nil
end

local function superdriveClearCoast()
    superdriveCurrentSpeed = 0.0
    superdriveCoastDirection = nil
end

local function superdriveTick(vehicle)
    if vehicle == 0 then
        return
    end

    local dt = GetFrameTime()
    local handbrakeHeld = superdriveControlPressed(SUPERDRIVE_HANDBRAKE_CONTROL)
    local flyHeld = superdriveControlPressed(SUPERDRIVE_FLY_CONTROL)

    -- While the handbrake is held, pin the vehicle's world position and rotate
    -- it manually with the left stick. Releasing the handbrake restores gravity.
    if handbrakeHeld then
        superdriveClearCoast()
        if superdriveSuspendedVehicle ~= vehicle then
            superdriveSuspendedVehicle = vehicle
            superdriveSuspendAnchor = GetEntityCoords(vehicle)
        end

        superdriveDisableGravity(vehicle)
        DisableControlAction(0, 71, true) -- INPUT_VEH_ACCELERATE
        DisableControlAction(0, 72, true) -- INPUT_VEH_BRAKE

        SetEntityVelocity(vehicle, 0.0, 0.0, 0.0)
        local anchor = superdriveSuspendAnchor
        if anchor then
            SetEntityCoordsNoOffset(vehicle, anchor.x, anchor.y, anchor.z, true, true, true)
        end

        local stickX = superdriveControlNormal(SUPERDRIVE_STICK_LR)
        local stickY = superdriveControlNormal(SUPERDRIVE_STICK_UD)
        if stickX ~= 0.0 or stickY ~= 0.0 then
            local rotation = GetEntityRotation(vehicle, 2)
            SetEntityRotation(
                vehicle,
                rotation.x + stickY * SUPERDRIVE_HOVER_ROT_SPEED * dt,
                rotation.y + stickX * stickY * SUPERDRIVE_HOVER_ROLL_SPEED * dt,
                rotation.z - stickX * SUPERDRIVE_HOVER_ROT_SPEED * dt,
                2,
                true
            )
        end
        return
    end

    if superdriveSuspendedVehicle ~= 0 then
        releaseSuspension()
    end

    if flyHeld then
        superdriveCoastDirection = nil
        superdriveDisableGravity(vehicle)
        superdriveCurrentSpeed = superdriveEaseSpeed(
            superdriveCurrentSpeed,
            SUPERDRIVE_MAX_SPEED,
            dt,
            SUPERDRIVE_ACCEL_RATE
        )
        superdriveApplyThrust(vehicle, superdriveCurrentSpeed, superdriveComputeThrustDirection(vehicle))
        return
    end

    if superdriveCurrentSpeed > SUPERDRIVE_COAST_STOP_SPEED then
        if not superdriveCoastDirection then
            superdriveCoastDirection = superdriveComputeThrustDirection(vehicle)
        end

        superdriveDisableGravity(vehicle)
        superdriveCurrentSpeed = math.max(0.0, superdriveCurrentSpeed - SUPERDRIVE_COAST_DECEL * dt)
        superdriveApplyThrust(vehicle, superdriveCurrentSpeed, superdriveCoastDirection)
        return
    end

    superdriveClearCoast()
    superdriveRestoreGravity(vehicle)
end

function AdventureTours.SetSuperdriveEnabled(enabled)
    AdventureTours.Set('superdriveEnabled', enabled)

    if enabled and not superdriveThreadRunning then
        superdriveThreadRunning = true
        CreateThread(function()
            while AdventureTours.Get('superdriveEnabled') do
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then
                    superdriveTick(GetVehiclePedIsIn(ped, false))
                else
                    superdriveClearCoast()
                    if superdriveSuspendedVehicle ~= 0 then
                        releaseSuspension()
                    end
                    superdriveRestoreGravity(superdriveGravityDisabledVehicle)
                end
                Wait(0)
            end
            superdriveThreadRunning = false
        end)
    end

    if not enabled then
        superdriveClearCoast()
        releaseSuspension()
        superdriveRestoreGravity(superdriveGravityDisabledVehicle)
    end
end

function AdventureTours.InitializeGuideDefaults()
    AdventureTours.ApplyTourGuideOutfit()
    AdventureTours.RemoveGuideWeapons()
    AdventureTours.SetSuperdriveEnabled(true)
    AdventureTours.InitializeStopRainbowModes()
end
