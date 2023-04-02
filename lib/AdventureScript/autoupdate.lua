---
--- Auto-Updater
--- from https://github.com/hexarobi/stand-lua-auto-updater
---
local currentVersion = '0.9.4'
local status, auto_updater = pcall(require, 'auto-updater')

local function requireDependency(path)
    local dep_status, required_dep = pcall(require, path)
    if not dep_status then
        error('Could not load ' .. path .. ': ' .. required_dep)
    else
        return required_dep
    end
end

local UPDATER = {
    currentVersion = currentVersion,
    requireDependency = requireDependency,
    runAutoUpdate = function()
        if not status then
            local auto_update_complete = nil
            util.toast('Installing auto-updater...', TOAST_ALL)
            async_http.init('raw.githubusercontent.com', '/hexarobi/stand-lua-auto-updater/main/auto-updater.lua',
                function(result, headers, status_code)
                    local function parse_auto_update_result(result, headers, status_code)
                        local error_prefix = 'Error downloading auto-updater: '
                        if status_code ~= 200 then
                            util.toast(error_prefix .. status_code, TOAST_ALL)
                            return false
                        end
                        if not result or result == '' then
                            util.toast(error_prefix .. 'Found empty file.', TOAST_ALL)
                            return false
                        end
                        filesystem.mkdir(filesystem.scripts_dir() .. 'lib')
                        local file = io.open(filesystem.scripts_dir() .. 'lib\\auto-updater.lua', 'wb')
                        if file == nil then
                            util.toast(error_prefix .. 'Could not open file for writing.', TOAST_ALL)
                            return false
                        end
                        file:write(result)
                        file:close()
                        util.toast('Successfully installed auto-updater lib', TOAST_ALL)
                        return true
                    end
                    auto_update_complete = parse_auto_update_result(result, headers, status_code)
                end, function()
                    util.toast('Error downloading auto-updater lib. Update failed to download.', TOAST_ALL)
                end)
            async_http.dispatch()
            local i = 1
            while (auto_update_complete == nil and i < 40) do
                util.yield(250)
                i = i + 1
            end
            if auto_update_complete == nil then
                error('Error downloading auto-updater lib. HTTP Request timeout')
            end
            auto_updater = require('auto-updater')
        end
        if auto_updater == true then
            error('Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again')
        end

        local DEFAULT_CHECK_INTERVAL = 604800
        local auto_update_config = {
            source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/AdventureScript.lua',
            script_relpath = SCRIPT_RELPATH,
            switch_to_branch = 'main',
            verify_file_begins_with = '--',
            check_interval = DEFAULT_CHECK_INTERVAL,
            dependencies = {{
                name = 'autoupdate',
                source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/autoupdate.lua',
                script_relpath = 'lib/AdventureScript/autoupdate.lua',
                verify_file_begins_with = '--',
                check_interval = DEFAULT_CHECK_INTERVAL,
                is_required = true
            }, {
                name = 'data',
                source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/data.lua',
                script_relpath = 'lib/AdventureScript/data.lua',
                verify_file_begins_with = '--',
                check_interval = DEFAULT_CHECK_INTERVAL,
                is_required = true
            }, {
                name = 'controls',
                source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/controls.lua',
                script_relpath = 'lib/AdventureScript/controls.lua',
                verify_file_begins_with = '--',
                check_interval = DEFAULT_CHECK_INTERVAL,
                is_required = true
            }, {
                name = 'gridspawn',
                source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/gridspawn.lua',
                script_relpath = 'lib/AdventureScript/gridspawn.lua',
                verify_file_begins_with = '--',
                check_interval = DEFAULT_CHECK_INTERVAL,
                is_required = true
            }, {
                name = 'helpers',
                source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/HELPERS.lua',
                script_relpath = 'lib/AdventureScript/HELPERS.lua',
                verify_file_begins_with = '--',
                check_interval = DEFAULT_CHECK_INTERVAL,
                is_required = true
            }, {
                name = 'logo',
                source_url = 'https://raw.githubusercontent.com/diskomo/adventure-script/main/lib/AdventureScript/logo.png',
                script_relpath = 'lib/AdventureScript/logo.png',
                check_interval = DEFAULT_CHECK_INTERVAL
            }}
        }
        local update_success = auto_updater.run_auto_update(auto_update_config)
        local missing_required_dependencies = {}
        for _, dependency in pairs(auto_update_config.dependencies) do
            if dependency.is_required then
                local var_name = dependency.name
                if dependency.loaded_lib ~= nil then
                    _G[var_name] = dependency.loaded_lib
                else
                    local lib_require_status, loaded_lib = pcall(require, dependency.script_relpath:gsub('[.]lua$', ''))
                    if lib_require_status then
                        _G[var_name] = loaded_lib
                    else
                        table.insert(missing_required_dependencies, dependency.name)
                    end
                end
            end
        end
        if #missing_required_dependencies > 0 then
            local missing_files = table.concat(missing_required_dependencies, ', ')
            if not update_success then
                error('Error: Install Failed. Auto-update failed and required files are missing (' .. missing_files ..
                          ') Please re-install from the project zip file @ https://github.com/diskomo/adventure-script')
            else
                menu.readonly(menu.my_root(), 'Error: Load Failed',
                    'Required files are missing. (' .. missing_files .. ')')
                error(
                    'Error: Load Failed. Auto-update successful but required files are missing. This is likely a bug. Please report this issue on Discord @ https://discord.gg/2u5HbHPB9y')
            end
        end
    end
}

return UPDATER

