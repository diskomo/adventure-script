-- Drag-to-grid activity vehicle spawn preview and placement.

local previewCars = { {} }
local isPlacing = false
local startPosition
local spawnHeading
local startForward
local startRight
local arrowRotation = 0.0
local xPadding = 1.5
local yPadding = 1.5

function AdventureTours.GetModelDimensions(model)
    if not AdventureTours.LoadModel(model) then
        return { x = 4.0, y = 2.0, z = 1.5 }
    end

    local minimum, maximum = GetModelDimensions(model)
    return {
        x = maximum.x - minimum.x,
        y = maximum.y - minimum.y,
        z = maximum.z - minimum.z,
    }
end

function AdventureTours.InitializeGridSpawn()
    AdventureTours.Set('spawnTargetDimensions', AdventureTours.GetModelDimensions(AdventureTours.Get('spawnTargetHash')))
end

local function arrowIndicator(pos, angle, size, colour)
    local colourSecondary = {
        r = colour.r - 20,
        g = colour.g - 20,
        b = colour.b - 20,
        a = colour.a,
    }
    local angleCos = math.cos(angle)
    local angleSin = math.sin(angle)
    local width = 0.5 * size
    local length = 1 * size
    local height = 0.25 * size

    DrawPoly(
        pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0), pos.z + 0,
        pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height), pos.z + length + height,
        pos.x + (angleCos * width - angleSin * 0), pos.y + (angleSin * width + angleCos * 0), pos.z + length,
        colourSecondary.r, colourSecondary.g, colourSecondary.b, colourSecondary.a
    )
    DrawPoly(
        pos.x + (angleCos * 0 - angleSin * -height), pos.y + (angleSin * 0 + angleCos * -height), pos.z + length + height,
        pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0), pos.z + 0,
        pos.x + (angleCos * width - angleSin * 0), pos.y + (angleSin * width + angleCos * 0), pos.z + length,
        colourSecondary.r, colourSecondary.g, colourSecondary.b, colourSecondary.a
    )
    DrawPoly(
        pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0), pos.z + 0,
        pos.x + (angleCos * 0 - angleSin * -height), pos.y + (angleSin * 0 + angleCos * -height), pos.z + length + height,
        pos.x + (angleCos * -width - angleSin * 0), pos.y + (angleSin * -width + angleCos * 0), pos.z + length,
        colour.r, colour.g, colour.b, colour.a
    )
    DrawPoly(
        pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height), pos.z + length + height,
        pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0), pos.z + 0,
        pos.x + (angleCos * -width - angleSin * 0), pos.y + (angleSin * -width + angleCos * 0), pos.z + length,
        colour.r, colour.g, colour.b, colour.a
    )
    DrawPoly(
        pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height), pos.z + length + height,
        pos.x + (angleCos * 0 - angleSin * -height), pos.y + (angleSin * 0 + angleCos * -height), pos.z + length + height,
        pos.x + (angleCos * width - angleSin * 0), pos.y + (angleSin * width + angleCos * 0), pos.z + length,
        colourSecondary.r, colourSecondary.g, colourSecondary.b, colourSecondary.a
    )
    DrawPoly(
        pos.x + (angleCos * 0 - angleSin * -height), pos.y + (angleSin * 0 + angleCos * -height), pos.z + length + height,
        pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height), pos.z + length + height,
        pos.x + (angleCos * -width - angleSin * 0), pos.y + (angleSin * -width + angleCos * 0), pos.z + length,
        colour.r, colour.g, colour.b, colour.a
    )
end

local function drawBoundingBox(entity, colour)
    local forwardVector, rightVector, upVector = GetEntityMatrix(entity)
    local minimum, maximum = GetModelDimensions(GetEntityModel(entity))
    local dimensions = {
        x = maximum.y - minimum.y,
        y = maximum.x - minimum.x,
        z = maximum.z - minimum.z,
    }

    local topRight = GetOffsetFromEntityInWorldCoords(entity, maximum.x, maximum.y, maximum.z)
    local topRightBack = vector3(
        forwardVector.x * -dimensions.y + topRight.x,
        forwardVector.y * -dimensions.y + topRight.y,
        forwardVector.z * -dimensions.y + topRight.z
    )
    local bottomRightBack = vector3(
        upVector.x * -dimensions.z + topRightBack.x,
        upVector.y * -dimensions.z + topRightBack.y,
        upVector.z * -dimensions.z + topRightBack.z
    )
    local bottomLeftBack = vector3(
        -rightVector.x * dimensions.x + bottomRightBack.x,
        -rightVector.y * dimensions.x + bottomRightBack.y,
        -rightVector.z * dimensions.x + bottomRightBack.z
    )
    local topLeft = vector3(
        -rightVector.x * dimensions.x + topRight.x,
        -rightVector.y * dimensions.x + topRight.y,
        -rightVector.z * dimensions.x + topRight.z
    )
    local bottomRight = vector3(
        -upVector.x * dimensions.z + topRight.x,
        -upVector.y * dimensions.z + topRight.y,
        -upVector.z * dimensions.z + topRight.z
    )
    local bottomLeft = vector3(
        forwardVector.x * dimensions.y + bottomLeftBack.x,
        forwardVector.y * dimensions.y + bottomLeftBack.y,
        forwardVector.z * dimensions.y + bottomLeftBack.z
    )
    local topLeftBack = vector3(
        upVector.x * dimensions.z + bottomLeftBack.x,
        upVector.y * dimensions.z + bottomLeftBack.y,
        upVector.z * dimensions.z + bottomLeftBack.z
    )

    DrawLine(topRight.x, topRight.y, topRight.z, topRightBack.x, topRightBack.y, topRightBack.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(topRight.x, topRight.y, topRight.z, topLeft.x, topLeft.y, topLeft.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(topRight.x, topRight.y, topRight.z, bottomRight.x, bottomRight.y, bottomRight.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(bottomLeftBack.x, bottomLeftBack.y, bottomLeftBack.z, bottomRightBack.x, bottomRightBack.y, bottomRightBack.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(bottomLeftBack.x, bottomLeftBack.y, bottomLeftBack.z, bottomLeft.x, bottomLeft.y, bottomLeft.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(bottomLeftBack.x, bottomLeftBack.y, bottomLeftBack.z, topLeftBack.x, topLeftBack.y, topLeftBack.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(topLeftBack.x, topLeftBack.y, topLeftBack.z, topRightBack.x, topRightBack.y, topRightBack.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(topLeftBack.x, topLeftBack.y, topLeftBack.z, topLeft.x, topLeft.y, topLeft.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(bottomRightBack.x, bottomRightBack.y, bottomRightBack.z, topRightBack.x, topRightBack.y, topRightBack.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(bottomLeft.x, bottomLeft.y, bottomLeft.z, topLeft.x, topLeft.y, topLeft.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(bottomLeft.x, bottomLeft.y, bottomLeft.z, bottomRight.x, bottomRight.y, bottomRight.z, colour.r, colour.g, colour.b, colour.a)
    DrawLine(bottomRightBack.x, bottomRightBack.y, bottomRightBack.z, bottomRight.x, bottomRight.y, bottomRight.z, colour.r, colour.g, colour.b, colour.a)
end

local function cleanupPreviewCars()
    for _, row in pairs(previewCars) do
        for _, car in pairs(row) do
            if DoesEntityExist(car) then
                AdventureTours.DeleteEntitySafe(car)
            end
        end
    end
    previewCars = { {} }
end

function AdventureTours.CleanupGridSpawn()
    cleanupPreviewCars()
    isPlacing = false
end

function AdventureTours.HandleGridSpawn()
    if not AdventureTours.Get('spawnModeEnabled') then
        return
    end

    DisableControlAction(0, 142, true)

    arrowRotation = arrowRotation + GetFrameTime() * 45.0
    local camPos = GetFinalRenderedCamCoord()
    local camRot = GetFinalRenderedCamRot(2)
    local dir = AdventureTours.RotationToDirection(camRot)
    dir = dir * 200.0
    local target = camPos + dir

    local handle = StartExpensiveSynchronousShapeTestLosProbe(
        camPos.x, camPos.y, camPos.z,
        target.x, target.y, target.z,
        1, 0, 4
    )

    local _, hit, endCoords = GetShapeTestResult(handle)
    if hit ~= 1 then
        return
    end

    arrowIndicator(endCoords, math.rad(arrowRotation), 1.0, { r = 204, g = 132, b = 0, a = 255 })

    local spawnTargetHash = AdventureTours.Get('spawnTargetHash')
    local spawnTargetDimensions = AdventureTours.Get('spawnTargetDimensions')
    if not spawnTargetDimensions then
        return
    end

    if IsDisabledControlJustPressed(0, 24) then
        isPlacing = true
        startPosition = endCoords
        local playerPed = PlayerPedId()
        spawnHeading = GetEntityHeading(playerPed)
        local headingRad = math.rad(spawnHeading)
        startForward = vector3(-math.sin(headingRad), math.cos(headingRad), 0.0)
        startRight = vector3(math.cos(headingRad), math.sin(headingRad), 0.0)
    elseif IsDisabledControlJustReleased(0, 24) then
        isPlacing = false
        local batch = {}
        for _, row in pairs(previewCars) do
            for _, car in pairs(row) do
                if DoesEntityExist(car) then
                    local pos = GetEntityCoords(car)
                    AdventureTours.DeleteEntitySafe(car)

                    local newCar = CreateVehicle(spawnTargetHash, pos.x, pos.y, pos.z, spawnHeading, true, false)
                    if newCar ~= 0 then
                        SetEntityAsMissionEntity(newCar, true, true)
                        AdventureTours.TrackSpawnedVehicle(newCar)
                        AdventureTours.MakeAdventureVehicle(newCar)
                        batch[#batch + 1] = newCar
                    end
                end
            end
        end
        AdventureTours.PushSpawnUndoBatch(batch)
        if #batch > 0 then
            AdventureTours.AfterAction()
        end
        previewCars = { {} }
    end

    if isPlacing then
        if not startPosition or not startForward or not startRight then
            return
        end

        arrowIndicator(startPosition, math.rad(arrowRotation), 1.0, { r = 255, g = 50, b = 50, a = 255 })

        local delta = endCoords - startPosition
        local rightDistance = delta.x * startRight.x + delta.y * startRight.y
        local forwardDistance = delta.x * startForward.x + delta.y * startForward.y

        local spawnTargetXPlusPad = spawnTargetDimensions.x + xPadding
        local spawnTargetYPlusPad = spawnTargetDimensions.y + yPadding
        local xCount = math.min(math.floor(math.abs(rightDistance) / spawnTargetXPlusPad), 9)
        local yCount = math.min(math.floor(math.abs(forwardDistance) / spawnTargetYPlusPad), 9)

        local multX = rightDistance < 0 and -1 or 1
        local multY = forwardDistance < 0 and -1 or 1

        for x = 0, xCount do
            previewCars[x] = previewCars[x] or {}
            for y = 0, yCount do
                local tempForward = startForward * ((spawnTargetYPlusPad * y) * multY)
                local tempRight = startRight * ((spawnTargetXPlusPad * x) * multX)
                local coords = startPosition + tempForward + tempRight
                coords = vector3(coords.x, coords.y, AdventureTours.GetGroundZ(coords.x, coords.y, startPosition.z))

                local car = previewCars[x][y]
                if not car or not DoesEntityExist(car) then
                    car = CreateVehicle(spawnTargetHash, coords.x, coords.y, coords.z, spawnHeading, false, false)
                    if car ~= 0 then
                        SetEntityAlpha(car, 51, false)
                        SetEntityCollision(car, false, false)
                        FreezeEntityPosition(car, true)
                        AdventureTours.MakeAdventureVehicle(car)
                        previewCars[x][y] = car
                    end
                end

                if car and DoesEntityExist(car) then
                    SetEntityCoordsNoOffset(car, coords.x, coords.y, coords.z + spawnTargetDimensions.z * 0.5, false, false, false)
                    SetEntityHeading(car, spawnHeading)
                    drawBoundingBox(car, { r = 204, g = 132, b = 0, a = 100 })
                end
            end
        end

        for x, row in pairs(previewCars) do
            for y, car in pairs(row) do
                if x > xCount or y > yCount then
                    if DoesEntityExist(car) then
                        AdventureTours.DeleteEntitySafe(car)
                    end
                    previewCars[x][y] = nil
                end
            end
        end
    end
end
