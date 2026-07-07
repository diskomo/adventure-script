// DOM element refs and static menu lookup data.

const hudEl = document.getElementById('hud');
const miniMenuEl = document.getElementById('mini-menu');
const miniOpenEl = document.getElementById('mini-open');
const miniStopEl = document.getElementById('mini-stop');
const miniActionsEl = document.getElementById('mini-actions');
const hudTour = document.getElementById('hud-tour');
const hudStop = document.getElementById('hud-stop');
const hudVehicle = document.getElementById('hud-vehicle');
const hudSpawn = document.getElementById('hud-spawn');
const hudSuperdrive = document.getElementById('hud-superdrive');
const hudBinds = document.getElementById('hud-binds');

const l3MenuEl = document.getElementById('l3-menu');
const l3MenuList = document.getElementById('l3-menu-list');
const l3RadialHub = document.getElementById('l3-radial-hub');

const menuEl = document.getElementById('menu');
const menuPanelEl = document.querySelector('.menu-panel');
const bannerEl = document.getElementById('banner');
const closeBtn = document.getElementById('close-btn');
const headerTitleEl = document.getElementById('header-title');
const headerSubtitleEl = document.getElementById('header-subtitle');
const quickStatusEl = document.getElementById('quick-status');
const quickActionsEl = document.getElementById('quick-actions');
const sidebarEl = document.getElementById('sidebar');
const contentEl = document.getElementById('content');
const GUIDE_TABS = [
    { id: 'tour', label: 'Tour Stops', icon: 'map-location-dot', description: 'Browse stops, teleport, and set spawn vehicles' },
    { id: 'passengers', label: 'Passengers', icon: 'users', description: 'Manage the tour group and keep everyone together' },
    { id: 'animations', label: 'Animations', icon: 'person-walking', description: 'Guide poses and scenarios' },
    { id: 'chat', label: 'Chat', icon: 'comments', description: 'Broadcast tour messages to all players' },
    { id: 'appearance', label: 'Appearance', icon: 'palette', description: 'Tour colour, bus type, vehicle styling, and guide outfit' },
    { id: 'settings', label: 'Settings', icon: 'gear', description: 'Gameplay toggles and controls' },
];

const PASSENGER_TABS = [
    { id: 'my-tour', label: 'My Tour', icon: 'route', description: 'Tour status, follow mode, signals, and next-stop vote' },
    { id: 'guide', label: 'Guide', icon: 'user-tie', description: 'Current guide and elections' },
    { id: 'animations', label: 'Animations', icon: 'person-walking', description: 'Emotes and poses' },
    { id: 'settings', label: 'Settings', icon: 'gear', description: 'Toolbar and control preferences' },
];

function getTabs(roleState = state) {
    return roleState?.isGuide ? GUIDE_TABS : PASSENGER_TABS;
}

const TABS = GUIDE_TABS;

function getControlHints() {
    return initData?.controlHints || { foot: [], bus: [], l3MenuFoot: [], l3MenuBus: [] };
}

const MINI_MENU_CORNERS = [
    { id: 'top-left', label: 'Top left' },
    { id: 'top-right', label: 'Top right' },
    { id: 'bottom-left', label: 'Bottom left' },
    { id: 'bottom-right', label: 'Bottom right' },
];

const L3_RADIAL_ITEMS = [
    { direction: 'up', id: 'toggleSpawn', label: 'Grid spawn', icon: 'border-all', toggle: true },
    { direction: 'right', id: 'clearArea', label: 'Clear area', icon: 'broom' },
    { direction: 'left', id: 'undoSpawn', label: 'Undo', icon: 'rotate-left', disabledUnless: 'spawnUndoCount' },
    { direction: 'down', id: 'spawnBus', label: 'Spawn bus', icon: 'bus', disabledUnless: 'isDrivingBus' },
];

const OPEN_MAIN_MENU_ACTION = { id: 'openMainMenu', label: 'Open main menu', icon: 'bars' };
