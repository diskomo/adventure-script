local config = {}

config.scriptVersion = '1.2.0'
config.auto_update_config = {
    source_url = "https://raw.githubusercontent.com/diskomo/adventure-script/main/AdventureScript.lua",
    script_relpath = SCRIPT_RELPATH,
    project_url = "https://github.com/diskomo/adventure-script",
    branch = "main",
    dependencies = {"lib/AdventureScript/config.lua", "lib/AdventureScript/controls.lua",
                    "lib/AdventureScript/data.lua", "lib/AdventureScript/gridspawn.lua", "lib/AdventureScript/menu.lua",
                    "lib/AdventureScript/passengers.lua", "lib/AdventureScript/state.lua",
                    "lib/AdventureScript/tour.lua", "lib/AdventureScript/ui.lua", "lib/AdventureScript/vehicles.lua",
                    "lib/AdventureScript/assets/banner.jpg", "lib/AdventureScript/assets/controls-bus.png",
                    "lib/AdventureScript/assets/controls-foot.png", "lib/AdventureScript/assets/logo.png"}
}

return config
