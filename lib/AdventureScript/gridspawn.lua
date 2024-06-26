local GRIDSPAWN = {}

---
--- Much of the code for getModelDimensions, arrowIndicator and drawBoundingBox have been adapted from GridSpawn by NotTonk
--- https://discord.com/channels/956618713157763072/1037454538921214082
---
local state = require('lib.AdventureScript.state')
local controls = require('lib.AdventureScript.controls')

local modelMinimum = memory.alloc()
local modelMaximum = memory.alloc()
local boundingBoxMinimum = memory.alloc()
local boundingBoxMaximum = memory.alloc()
local upVectorPointer = memory.alloc()
local rightVectorPointer = memory.alloc()
local forwardVectorPointer = memory.alloc()
local positionPointer = memory.alloc()
local previewCars = {{}}
local up<const> = v3.new(0, 0, 1)
local isPlacing = false
local startPosition
local camStartHeading
local startForward
local startRight
local arrowRotation = 0
local xPadding = 0.5
local yPadding = 0.5

GRIDSPAWN.getModelDimensions = function(model)
    while not HAS_MODEL_LOADED(model) do
        REQUEST_MODEL(model)
        util.yield()
    end
    GET_MODEL_DIMENSIONS(model, modelMinimum, modelMaximum)
    local minimumVec = v3.new(modelMinimum)
    local maximumVec = v3.new(modelMaximum)
    local dimensions = {
        y = maximumVec.y - minimumVec.y,
        x = maximumVec.x - minimumVec.x,
        z = maximumVec.z - minimumVec.z
    }
    return dimensions
end

GRIDSPAWN.initialize = function()
    state.spawnTargetDimensions = GRIDSPAWN.getModelDimensions(state.spawnTargetHash)
end

GRIDSPAWN.arrowIndicator = function(pos, angle, size, color)
    local colorSecondary = {
        r = color.r - 20,
        g = color.g - 20,
        b = color.b - 20,
        a = color.a
    }
    local angleCos = math.cos(angle)
    local angleSin = math.sin(angle)
    local width = 0.5 * size
    local length = 1 * size
    local height = 0.25 * size
    DRAW_POLY(pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0), pos.z + 0,
        pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height), pos.z + length + height,
        pos.x + (angleCos * width - angleSin * 0), pos.y + (angleSin * width + angleCos * 0), pos.z + length,
        colorSecondary.r, colorSecondary.g, colorSecondary.b, colorSecondary.a)
    DRAW_POLY(pos.x + (angleCos * 0 - angleSin * -height), pos.y + (angleSin * 0 + angleCos * -height),
        pos.z + length + height, pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0),
        pos.z + 0, pos.x + (angleCos * width - angleSin * 0), pos.y + (angleSin * width + angleCos * 0), pos.z + length,
        colorSecondary.r, colorSecondary.g, colorSecondary.b, colorSecondary.a)
    DRAW_POLY(pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0), pos.z + 0,
        pos.x + (angleCos * 0 - angleSin * -height), pos.y + (angleSin * 0 + angleCos * -height),
        pos.z + length + height, pos.x + (angleCos * -width - angleSin * 0), pos.y + (angleSin * -width + angleCos * 0),
        pos.z + length, color.r, color.g, color.b, color.a)
    DRAW_POLY(pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height),
        pos.z + length + height, pos.x + (angleCos * 0 - angleSin * 0), pos.y + (angleSin * 0 + angleCos * 0),
        pos.z + 0, pos.x + (angleCos * -width - angleSin * 0), pos.y + (angleSin * -width + angleCos * 0),
        pos.z + length, color.r, color.g, color.b, color.a)
    DRAW_POLY(pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height),
        pos.z + length + height, pos.x + (angleCos * 0 - angleSin * -height),
        pos.y + (angleSin * 0 + angleCos * -height), pos.z + length + height, pos.x + (angleCos * width - angleSin * 0),
        pos.y + (angleSin * width + angleCos * 0), pos.z + length, colorSecondary.r, colorSecondary.g, colorSecondary.b,
        colorSecondary.a)
    DRAW_POLY(pos.x + (angleCos * 0 - angleSin * -height), pos.y + (angleSin * 0 + angleCos * -height),
        pos.z + length + height, pos.x + (angleCos * 0 - angleSin * height), pos.y + (angleSin * 0 + angleCos * height),
        pos.z + length + height, pos.x + (angleCos * -width - angleSin * 0), pos.y + (angleSin * -width + angleCos * 0),
        pos.z + length, color.r, color.g, color.b, color.a)
end

GRIDSPAWN.drawBoundingBox = function(entity, color)
    GET_ENTITY_MATRIX(entity, rightVectorPointer, forwardVectorPointer, upVectorPointer, positionPointer);
    local forwardVector = v3.new(forwardVectorPointer)
    local rightVector = v3.new(rightVectorPointer)
    local upVector = v3.new(upVectorPointer)
    GET_MODEL_DIMENSIONS(GET_ENTITY_MODEL(entity), boundingBoxMinimum, boundingBoxMaximum)
    local minimumVec = v3.new(boundingBoxMinimum)
    local maximumVec = v3.new(boundingBoxMaximum)
    local dimensions = {
        x = maximumVec.y - minimumVec.y,
        y = maximumVec.x - minimumVec.x,
        z = maximumVec.z - minimumVec.z
    }
    local topRight = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, maximumVec.x, maximumVec.y, maximumVec.z)
    local topRightBack = {
        x = forwardVector.x * -dimensions.y + topRight.x,
        y = forwardVector.y * -dimensions.y + topRight.y,
        z = forwardVector.z * -dimensions.y + topRight.z
    }
    local bottomRightBack = {
        x = upVector.x * -dimensions.z + topRightBack.x,
        y = upVector.y * -dimensions.z + topRightBack.y,
        z = upVector.z * -dimensions.z + topRightBack.z
    }
    local bottomLeftBack = {
        x = -rightVector.x * dimensions.x + bottomRightBack.x,
        y = -rightVector.y * dimensions.x + bottomRightBack.y,
        z = -rightVector.z * dimensions.x + bottomRightBack.z
    }
    local topLeft = {
        x = -rightVector.x * dimensions.x + topRight.x,
        y = -rightVector.y * dimensions.x + topRight.y,
        z = -rightVector.z * dimensions.x + topRight.z
    }
    local bottomRight = {
        x = -upVector.x * dimensions.z + topRight.x,
        y = -upVector.y * dimensions.z + topRight.y,
        z = -upVector.z * dimensions.z + topRight.z
    }
    local bottomLeft = {
        x = forwardVector.x * dimensions.y + bottomLeftBack.x,
        y = forwardVector.y * dimensions.y + bottomLeftBack.y,
        z = forwardVector.z * dimensions.y + bottomLeftBack.z
    }
    local topLeftBack = {
        x = upVector.x * dimensions.z + bottomLeftBack.x,
        y = upVector.y * dimensions.z + bottomLeftBack.y,
        z = upVector.z * dimensions.z + bottomLeftBack.z
    }
    DRAW_LINE(topRight.x, topRight.y, topRight.z, topRightBack.x, topRightBack.y, topRightBack.z, color.r, color.g,
        color.b, color.a)
    DRAW_LINE(topRight.x, topRight.y, topRight.z, topLeft.x, topLeft.y, topLeft.z, color.r, color.g, color.b, color.a)
    DRAW_LINE(topRight.x, topRight.y, topRight.z, bottomRight.x, bottomRight.y, bottomRight.z, color.r, color.g,
        color.b, color.a)
    DRAW_LINE(bottomLeftBack.x, bottomLeftBack.y, bottomLeftBack.z, bottomRightBack.x, bottomRightBack.y,
        bottomRightBack.z, color.r, color.g, color.b, color.a)
    DRAW_LINE(bottomLeftBack.x, bottomLeftBack.y, bottomLeftBack.z, bottomLeft.x, bottomLeft.y, bottomLeft.z, color.r,
        color.g, color.b, color.a)
    DRAW_LINE(bottomLeftBack.x, bottomLeftBack.y, bottomLeftBack.z, topLeftBack.x, topLeftBack.y, topLeftBack.z,
        color.r, color.g, color.b, color.a)
    DRAW_LINE(topLeftBack.x, topLeftBack.y, topLeftBack.z, topRightBack.x, topRightBack.y, topRightBack.z, color.r,
        color.g, color.b, color.a)
    DRAW_LINE(topLeftBack.x, topLeftBack.y, topLeftBack.z, topLeft.x, topLeft.y, topLeft.z, color.r, color.g, color.b,
        color.a)
    DRAW_LINE(bottomRightBack.x, bottomRightBack.y, bottomRightBack.z, topRightBack.x, topRightBack.y, topRightBack.z,
        color.r, color.g, color.b, color.a)
    DRAW_LINE(bottomLeft.x, bottomLeft.y, bottomLeft.z, topLeft.x, topLeft.y, topLeft.z, color.r, color.g, color.b,
        color.a)
    DRAW_LINE(bottomLeft.x, bottomLeft.y, bottomLeft.z, bottomRight.x, bottomRight.y, bottomRight.z, color.r, color.g,
        color.b, color.a)
    DRAW_LINE(bottomRightBack.x, bottomRightBack.y, bottomRightBack.z, bottomRight.x, bottomRight.y, bottomRight.z,
        color.r, color.g, color.b, color.a)
end

GRIDSPAWN.handleSpawn = function(spawnTargetHash, spawnTargetDimensions, manipulateVehicle)
    arrowRotation = arrowRotation + GET_FRAME_TIME() * 45
    local camPos = v3.new(GET_FINAL_RENDERED_CAM_COORD())
    local camRot = v3.new(GET_FINAL_RENDERED_CAM_ROT(2))
    local dir = v3.toDir(camRot)
    v3.mul(dir, 200)
    v3.add(dir, camPos)
    local handle = START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(camPos.x, camPos.y, camPos.z, dir.x, dir.y, dir.z,
        1, 0, 4)

    local hit = memory.alloc(8)
    local endPosition = memory.alloc()
    local surfaceNormal = memory.alloc()
    local ent = memory.alloc_int()
    GET_SHAPE_TEST_RESULT(handle, hit, endPosition, surfaceNormal, ent)

    if memory.read_byte(hit) ~= 0 then
        endPosition = v3.new(endPosition)
        GRIDSPAWN.arrowIndicator(endPosition, math.rad(arrowRotation), 1, {
            r = 204,
            g = 132,
            b = 0,
            a = 255
        })

        if controls.leftClickDown() then
            isPlacing = true
            startPosition = v3.new(endPosition)
            local camStartRotation = v3.new(GET_FINAL_RENDERED_CAM_ROT(2))
            camStartRotation.x = 0
            camStartHeading = v3.getHeading(camStartRotation)
            startForward = v3.toDir(camStartRotation)
            startRight = v3.crossProduct(startForward, up)
        elseif controls.leftClickUp() then
            isPlacing = false
            for _, tbl in pairs(previewCars) do
                for _, car in pairs(tbl) do
                    local pos = GET_ENTITY_COORDS(car, false)
                    entities.delete_by_handle(car)
                    local newCar = CREATE_VEHICLE(spawnTargetHash, pos.x, pos.y, pos.z, camStartHeading, true, false,
                        false)
                    table.insert(state.spawnedVehicles, newCar)
                    manipulateVehicle(newCar)
                    util.yield()
                end
            end
            previewCars = {{}}
        end

        if isPlacing then
            GRIDSPAWN.arrowIndicator(startPosition, math.rad(arrowRotation), 1, {
                r = 255,
                g = 50,
                b = 50,
                a = 255
            })
            local angle = -math.rad(camStartHeading)
            local angleCos = math.cos(angle)
            local angleSin = math.sin(angle)
            endPosition = v3.new(startPosition.x +
                                     (angleCos * (endPosition.x - startPosition.x) - angleSin *
                                         (endPosition.y - startPosition.y)), startPosition.y +
                (angleSin * (endPosition.x - startPosition.x) + angleCos * (endPosition.y - startPosition.y)),
                endPosition.z)
            local spawnTargetXPlusPad = spawnTargetDimensions.x + xPadding
            local spawnTargetYPlusPad = spawnTargetDimensions.y + yPadding

            local xCount = math.min(math.floor(math.abs((startPosition.x - endPosition.x) / spawnTargetXPlusPad)), 9)
            local yCount = math.min(math.floor(math.abs((startPosition.y - endPosition.y) / spawnTargetYPlusPad)), 9)
            for x = 0, xCount, 1 do
                for y = 0, yCount, 1 do
                    local multX = startPosition.x > endPosition.x and -1 or 1
                    local multY = startPosition.y > endPosition.y and -1 or 1
                    local tempForward = v3.new(startForward)
                    local tempRight = v3.new(startRight)
                    v3.mul(tempForward, (spawnTargetYPlusPad * y) * multY)
                    v3.mul(tempRight, (spawnTargetXPlusPad * x) * multX)
                    v3.add(tempForward, tempRight)
                    v3.add(tempForward, startPosition)
                    local coords = tempForward

                    local zFound, zCoord = util.get_ground_z(coords.x, coords.y)
                    if zFound then
                        coords.z = zCoord
                    else
                        coords.z = startPosition.z
                    end
                    local car
                    if previewCars[x] then
                        if previewCars[x][y] then
                            car = previewCars[x][y]
                        end
                    else
                        previewCars[x] = {}
                    end
                    if not car then
                        car = CREATE_VEHICLE(spawnTargetHash, coords.x, coords.y, coords.z, camStartHeading, false,
                            false, false)
                        SET_ENTITY_ALPHA(car, 51, false)
                        SET_ENTITY_COLLISION(car, false, false)
                        FREEZE_ENTITY_POSITION(car, true)
                        manipulateVehicle(car)
                        previewCars[x][y] = car
                    end
                    SET_ENTITY_COORDS_NO_OFFSET(car, coords.x, coords.y, coords.z + spawnTargetDimensions.z * 0.5,
                        false, false, false)
                    GRIDSPAWN.drawBoundingBox(car, {
                        r = 204,
                        g = 132,
                        b = 0,
                        a = 100
                    })
                end
            end
            for x, tbl in pairs(previewCars) do
                for y, car in pairs(tbl) do
                    if x > xCount or y > yCount then
                        entities.delete_by_handle(car)
                        previewCars[x][y] = nil
                    end
                end
            end
        end
    end
end

GRIDSPAWN.handleCleanup = function()
    for _, tbl in pairs(previewCars) do
        for _, car in pairs(tbl) do
            entities.delete_by_handle(car)
        end
    end
end

return GRIDSPAWN
