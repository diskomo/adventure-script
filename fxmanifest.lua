fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'adventure_tours'
author 'The Vanilla Panther (META IIII)'
description 'Guided communal tour host tool for FiveM'
version '2.0.0'

dependencies {
    'ox_lib',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/banner.jpg',
    'html/css/base.css',
    'html/css/buttons.css',
    'html/css/cards.css',
    'html/css/search.css',
    'html/css/menu-shell.css',
    'html/css/quick-bar.css',
    'html/css/hud.css',
    'html/css/mini-menu.css',
    'html/css/l3-menu.css',
    'html/css/tabs/tour.css',
    'html/css/tabs/animations.css',
    'html/css/tabs/appearance.css',
    'html/css/tabs/chat.css',
    'html/css/tabs/passengers.css',
    'html/css/tabs/settings.css',
    'html/js/dom.js',
    'html/js/state.js',
    'html/js/util.js',
    'html/js/selectors.js',
    'html/js/render-shared.js',
    'html/js/render-hud.js',
    'html/js/render-l3-menu.js',
    'html/js/render-quick-bar.js',
    'html/js/render-mini-menu.js',
    'html/js/tabs/tour.js',
    'html/js/tabs/animations.js',
    'html/js/tabs/appearance.js',
    'html/js/tabs/chat.js',
    'html/js/tabs/passengers.js',
    'html/js/tabs/my-tour.js',
    'html/js/tabs/guide.js',
    'html/js/tabs/settings.js',
    'html/js/content.js',
    'html/js/main.js',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/presets.lua',
    'config/branding.lua',
    'config/stops.lua',
    'config/controls.lua',
}

client_scripts {
    'client/core/state.lua',
    'client/core/util.lua',
    'client/core/notify.lua',
    'client/world/vehicles.lua',
    'client/world/gridspawn.lua',
    'client/world/actions.lua',
    'client/tour/tour.lua',
    'client/tour/passengers.lua',
    'client/nui/state.lua',
    'client/nui/menu.lua',
    'client/nui/callbacks.lua',
    'client/input/controls.lua',
    'client/main.lua',
}

server_scripts {
    'server/tour.lua',
    'server/main.lua',
}
