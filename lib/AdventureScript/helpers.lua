---
--- Parts of the code for get_model_dimensions, arrow_indicator and draw_bounding_box have been adapted from GridSpawn by NotTonk
--- https://discord.com/channels/956618713157763072/1037454538921214082
---
local model_minimum = memory.alloc()
local model_maximum = memory.alloc()
local function get_model_dimensions(model)
    while not STREAMING.HAS_MODEL_LOADED(model) do
        STREAMING.REQUEST_MODEL(model)
        util.yield()
    end
    MISC.GET_MODEL_DIMENSIONS(model, model_minimum, model_maximum)
    local minimum_vec = v3.new(model_minimum)
    local maximum_vec = v3.new(model_maximum)
    local dimensions = {
        y = maximum_vec.y - minimum_vec.y,
        x = maximum_vec.x - minimum_vec.x,
        z = maximum_vec.z - minimum_vec.z
    }
    return dimensions
end
local function arrow_indicator(pos, angle, size, colour)
    local colour_b = {
        r = colour.r - 20,
        g = colour.g - 20,
        b = colour.b - 20,
        a = colour.a
    }
    local angle_cos = math.cos(angle)
    local angle_sin = math.sin(angle)
    local width = 0.5 * size
    local length = 1 * size
    local height = 0.25 * size
    GRAPHICS.DRAW_POLY(pos.x + (angle_cos * 0 - angle_sin * 0), pos.y + (angle_sin * 0 + angle_cos * 0), pos.z + 0,
        pos.x + (angle_cos * 0 - angle_sin * height), pos.y + (angle_sin * 0 + angle_cos * height),
        pos.z + length + height, pos.x + (angle_cos * width - angle_sin * 0),
        pos.y + (angle_sin * width + angle_cos * 0), pos.z + length, colour_b.r, colour_b.g, colour_b.b, colour_b.a)
    GRAPHICS.DRAW_POLY(pos.x + (angle_cos * 0 - angle_sin * -height), pos.y + (angle_sin * 0 + angle_cos * -height),
        pos.z + length + height, pos.x + (angle_cos * 0 - angle_sin * 0), pos.y + (angle_sin * 0 + angle_cos * 0),
        pos.z + 0, pos.x + (angle_cos * width - angle_sin * 0), pos.y + (angle_sin * width + angle_cos * 0),
        pos.z + length, colour_b.r, colour_b.g, colour_b.b, colour_b.a)
    GRAPHICS.DRAW_POLY(pos.x + (angle_cos * 0 - angle_sin * 0), pos.y + (angle_sin * 0 + angle_cos * 0), pos.z + 0,
        pos.x + (angle_cos * 0 - angle_sin * -height), pos.y + (angle_sin * 0 + angle_cos * -height),
        pos.z + length + height, pos.x + (angle_cos * -width - angle_sin * 0),
        pos.y + (angle_sin * -width + angle_cos * 0), pos.z + length, colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_POLY(pos.x + (angle_cos * 0 - angle_sin * height), pos.y + (angle_sin * 0 + angle_cos * height),
        pos.z + length + height, pos.x + (angle_cos * 0 - angle_sin * 0), pos.y + (angle_sin * 0 + angle_cos * 0),
        pos.z + 0, pos.x + (angle_cos * -width - angle_sin * 0), pos.y + (angle_sin * -width + angle_cos * 0),
        pos.z + length, colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_POLY(pos.x + (angle_cos * 0 - angle_sin * height), pos.y + (angle_sin * 0 + angle_cos * height),
        pos.z + length + height, pos.x + (angle_cos * 0 - angle_sin * -height),
        pos.y + (angle_sin * 0 + angle_cos * -height), pos.z + length + height,
        pos.x + (angle_cos * width - angle_sin * 0), pos.y + (angle_sin * width + angle_cos * 0), pos.z + length,
        colour_b.r, colour_b.g, colour_b.b, colour_b.a)
    GRAPHICS.DRAW_POLY(pos.x + (angle_cos * 0 - angle_sin * -height), pos.y + (angle_sin * 0 + angle_cos * -height),
        pos.z + length + height, pos.x + (angle_cos * 0 - angle_sin * height),
        pos.y + (angle_sin * 0 + angle_cos * height), pos.z + length + height,
        pos.x + (angle_cos * -width - angle_sin * 0), pos.y + (angle_sin * -width + angle_cos * 0), pos.z + length,
        colour.r, colour.g, colour.b, colour.a)
end
local bounding_box_minimum = memory.alloc()
local bounding_box_maximum = memory.alloc()
local upVector_pointer = memory.alloc()
local rightVector_pointer = memory.alloc()
local forwardVector_pointer = memory.alloc()
local position_pointer = memory.alloc()
local draw_bounding_box = function(entity, colour)
    ENTITY.GET_ENTITY_MATRIX(entity, rightVector_pointer, forwardVector_pointer, upVector_pointer, position_pointer);
    local forward_vector = v3.new(forwardVector_pointer)
    local right_vector = v3.new(rightVector_pointer)
    local up_vector = v3.new(upVector_pointer)
    MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(entity), bounding_box_minimum, bounding_box_maximum)
    local minimum_vec = v3.new(bounding_box_minimum)
    local maximum_vec = v3.new(bounding_box_maximum)
    local dimensions = {
        x = maximum_vec.y - minimum_vec.y,
        y = maximum_vec.x - minimum_vec.x,
        z = maximum_vec.z - minimum_vec.z
    }
    local top_right = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, maximum_vec.x, maximum_vec.y, maximum_vec.z)
    local top_right_back = {
        x = forward_vector.x * -dimensions.y + top_right.x,
        y = forward_vector.y * -dimensions.y + top_right.y,
        z = forward_vector.z * -dimensions.y + top_right.z
    }
    local bottom_right_back = {
        x = up_vector.x * -dimensions.z + top_right_back.x,
        y = up_vector.y * -dimensions.z + top_right_back.y,
        z = up_vector.z * -dimensions.z + top_right_back.z
    }
    local bottom_left_back = {
        x = -right_vector.x * dimensions.x + bottom_right_back.x,
        y = -right_vector.y * dimensions.x + bottom_right_back.y,
        z = -right_vector.z * dimensions.x + bottom_right_back.z
    }
    local top_left = {
        x = -right_vector.x * dimensions.x + top_right.x,
        y = -right_vector.y * dimensions.x + top_right.y,
        z = -right_vector.z * dimensions.x + top_right.z
    }
    local bottom_right = {
        x = -up_vector.x * dimensions.z + top_right.x,
        y = -up_vector.y * dimensions.z + top_right.y,
        z = -up_vector.z * dimensions.z + top_right.z
    }
    local bottom_left = {
        x = forward_vector.x * dimensions.y + bottom_left_back.x,
        y = forward_vector.y * dimensions.y + bottom_left_back.y,
        z = forward_vector.z * dimensions.y + bottom_left_back.z
    }
    local top_left_back = {
        x = up_vector.x * dimensions.z + bottom_left_back.x,
        y = up_vector.y * dimensions.z + bottom_left_back.y,
        z = up_vector.z * dimensions.z + bottom_left_back.z
    }
    GRAPHICS.DRAW_LINE(top_right.x, top_right.y, top_right.z, top_right_back.x, top_right_back.y, top_right_back.z,
        colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(top_right.x, top_right.y, top_right.z, top_left.x, top_left.y, top_left.z, colour.r, colour.g,
        colour.b, colour.a)
    GRAPHICS.DRAW_LINE(top_right.x, top_right.y, top_right.z, bottom_right.x, bottom_right.y, bottom_right.z, colour.r,
        colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(bottom_left_back.x, bottom_left_back.y, bottom_left_back.z, bottom_right_back.x,
        bottom_right_back.y, bottom_right_back.z, colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(bottom_left_back.x, bottom_left_back.y, bottom_left_back.z, bottom_left.x, bottom_left.y,
        bottom_left.z, colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(bottom_left_back.x, bottom_left_back.y, bottom_left_back.z, top_left_back.x, top_left_back.y,
        top_left_back.z, colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(top_left_back.x, top_left_back.y, top_left_back.z, top_right_back.x, top_right_back.y,
        top_right_back.z, colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(top_left_back.x, top_left_back.y, top_left_back.z, top_left.x, top_left.y, top_left.z, colour.r,
        colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(bottom_right_back.x, bottom_right_back.y, bottom_right_back.z, top_right_back.x,
        top_right_back.y, top_right_back.z, colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(bottom_left.x, bottom_left.y, bottom_left.z, top_left.x, top_left.y, top_left.z, colour.r,
        colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(bottom_left.x, bottom_left.y, bottom_left.z, bottom_right.x, bottom_right.y, bottom_right.z,
        colour.r, colour.g, colour.b, colour.a)
    GRAPHICS.DRAW_LINE(bottom_right_back.x, bottom_right_back.y, bottom_right_back.z, bottom_right.x, bottom_right.y,
        bottom_right.z, colour.r, colour.g, colour.b, colour.a)
end

local helpers = {
    get_model_dimensions = get_model_dimensions,
    arrow_indicator = arrow_indicator,
    draw_bounding_box = draw_bounding_box,
    clear_objects = function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        menu.trigger_commands('clearobjects on')
        menu.trigger_commands('clearvehicles off')
        menu.trigger_commands('cleararea')
    end,
    clear_vehicles = function()
        menu.trigger_commands('clearobjects off')
        menu.trigger_commands('clearvehicles on')
        menu.trigger_commands('cleararea')
    end,
    set_super_drive = function(value)
        menu.trigger_commands('superdrive' .. ' ' .. value)
        menu.trigger_commands('superhandbrake' .. ' ' .. value)
    end,
    toggle_super_drive = function()
        menu.trigger_commands('superdrive')
        menu.trigger_commands('superhandbrake')
    end
}

return helpers
