local ui = {}

-- Startup Logo (credit to Hexarobi)
-- https://github.com/hexarobi/stand-lua-constructor
ui.showLogo = function()
    local logo = directx.create_texture(filesystem.scripts_dir() .. 'lib\\AdventureScript\\assets\\logo.png')
    local fade_steps = 25
    -- Fade In
    for i = 0, fade_steps do
        directx.draw_texture(logo, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, i / fade_steps)
        util.yield()
    end
    for i = 0, 25 do
        directx.draw_texture(logo, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, 1)
        util.yield()
    end
    -- Fade Out
    for i = fade_steps, 0, -1 do
        directx.draw_texture(logo, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, i / fade_steps)
        util.yield()
    end
end

-- Used to display gamepad controls on screen
local busControlsTexture = directx.create_texture(filesystem.scripts_dir() ..
                                                      'lib\\AdventureScript\\assets\\controls-bus.png')
local footControlsTexture = directx.create_texture(filesystem.scripts_dir() ..
                                                       'lib\\AdventureScript\\assets\\controls-foot.png')
ui.showGamepadControls = function(isDrivingBus)
    if isDrivingBus then
        directx.draw_texture(busControlsTexture, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, 1)
    else
        directx.draw_texture(footControlsTexture, 0.10, 0.10, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, 1)
    end
end

return ui
