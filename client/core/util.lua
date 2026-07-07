-- Model/anim loading, entity cleanup, teleport, and camera math helpers.

AdventureTours = AdventureTours or {}

function AdventureTours.LoadModel(hash)
    if not IsModelInCdimage(hash) then
        return false
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(0)
    end

    return true
end

function AdventureTours.LoadAnimDict(dict)
    if not dict then
        return false
    end

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(0)
    end
    return true
end

function AdventureTours.DeleteEntitySafe(entity)
    if entity and DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, true, true)
        DeleteEntity(entity)
    end
end

function AdventureTours.RotationToDirection(rotation)
    local rotX = math.rad(rotation.x)
    local rotZ = math.rad(rotation.z)
    local cosX = math.abs(math.cos(rotX))

    return vector3(
        -math.sin(rotZ) * cosX,
        math.cos(rotZ) * cosX,
        math.sin(rotX)
    )
end

function AdventureTours.GetGroundZ(x, y, fallbackZ)
    local found, groundZ = GetGroundZFor_3dCoord(x, y, fallbackZ + 50.0, false)
    if found then
        return groundZ
    end
    return fallbackZ
end

function AdventureTours.TeleportPedOrVehicle(coords)
    if not coords then
        return
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        SetEntityCoords(vehicle, coords.x, coords.y, coords.z, false, false, false, false)
        SetVehicleOnGroundProperly(vehicle)
    else
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    end
end
