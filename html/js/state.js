// NUI page state, accent theming, and init/state handlers from the client.

let initData = null;
let state = {};
let activeTab = 'tour';
let selectedStopIndex = 1;
let tourSearchQuery = '';
let animSearchQuery = '';
let resourceName = typeof GetParentResourceName === 'function'
    ? GetParentResourceName()
    : 'adventure_tours';

let bannerLoaded = false;
function nuiPost(action, data = {}) {
    return fetch(`https://${resourceName}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    }).catch(() => {});
}

function setAccent(hex) {
    if (!hex) return;
    document.documentElement.style.setProperty('--accent', hex);
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    document.documentElement.style.setProperty('--accent-dim', `rgba(${r}, ${g}, ${b}, 0.12)`);
    document.documentElement.style.setProperty('--accent-glow', `rgba(${r}, ${g}, ${b}, 0.25)`);
}
function handleInit(data) {
    initData = {
        resource: data.resource,
        version: data.version,
        tourStops: data.tourStops || [],
        actions: data.actions || [],
        colours: data.colours || {},
        chat: data.chat || {},
        controlHints: data.controlHints || { foot: [], bus: [], l3MenuFoot: [], l3MenuBus: [] },
    };
    resourceName = data.resource || resourceName;
    loadBanner(data.resource, data.bannerSrc);
    if (data.accentHex) setAccent(data.accentHex);
    updateMiniMenu();
    if (!menuEl.classList.contains('hidden')) {
        renderContent();
    }
}

function handleState(data) {
    const next = { ...data };
    delete next.action;
    const roleChanged = typeof next.isGuide === 'boolean' && next.isGuide !== state.isGuide;
    state = { ...state, ...next };
    if (next.accentHex) setAccent(next.accentHex);
    if (roleChanged) {
        ensureValidActiveTab();
    }
    updateMiniMenu();
    if (!menuEl.classList.contains('hidden')) {
        renderContent();
    }
}
