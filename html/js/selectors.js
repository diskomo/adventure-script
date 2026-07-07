// Derived tour/spawn state and quick-action model helpers.

function getControlHints() {
    return initData?.controlHints || { foot: [], bus: [], l3MenuFoot: [], l3MenuBus: [] };
}
function getTourControlAction() {
    if (state.tourActive) {
        return { id: 'stopTour', label: 'Stop tour', icon: 'stop', tone: 'stop' };
    }
    return { id: 'startTour', label: 'Play tour', icon: 'play', tone: 'play' };
}

function getServerStopName() {
    if (!initData?.tourStops?.length || !state.serverStopIndex || state.serverStopIndex < 1) {
        return 'No stop selected';
    }
    const stop = initData.tourStops[state.serverStopIndex - 1];
    return stop ? stop.name : 'No stop selected';
}

function getQuickActionGroups(includeTour = true) {
    const groups = [
        {
            id: 'tour',
            actions: [
                getTourControlAction(),
            ],
        },
        {
            id: 'bus',
            actions: [
                { id: 'spawnBus', label: 'Spawn bus', icon: 'bus', accent: true },
            ],
        },
        {
            id: 'grid-spawn',
            actions: [
                { id: 'toggleSpawn', label: 'Grid spawn', icon: 'border-all', toggle: true, stateKey: 'spawnModeEnabled' },
                { id: 'undoSpawn', label: 'Undo', icon: 'rotate-left', muted: true, disabledUnless: 'spawnUndoCount' },
            ],
        },
        {
            id: 'stop-tools',
            actions: [
                { id: 'resetStop', label: 'Reset stop', icon: 'arrow-rotate-left', muted: true },
                { id: 'clearArea', label: 'Clear area', icon: 'broom', danger: true },
            ],
        },
    ];

    if (!includeTour) {
        return groups.filter((group) => group.id !== 'tour');
    }

    return groups;
}

function getPassengerQuickActions() {
    return [
        { id: 'setReady', label: state.ready ? 'Not ready' : 'Ready', icon: 'hand', toggle: true, stateKey: 'ready' },
        { id: 'requestHelp', label: 'Stuck', icon: 'triangle-exclamation', helpType: 'stuck' },
        { id: 'requestHelp', label: 'Injured', icon: 'kit-medical', helpType: 'injured', danger: true },
    ];
}

function resolveActionLabel(action) {
    if (action.id === 'undoSpawn') {
        const count = state.spawnUndoCount || 0;
        return count > 0 ? `Undo (${count})` : action.label;
    }
    return action.label;
}

function resolveMiniActionLabel(action) {
    return action.label;
}

function isActionDisabled(action) {
    if (!action.disabledUnless) {
        return false;
    }
    return !(state[action.disabledUnless] > 0);
}

function getQuickActionButtonClasses(action) {
    const classes = ['btn'];
    if (action.tone === 'play') classes.push('btn-play');
    if (action.tone === 'stop') classes.push('btn-stop');
    if (action.accent) classes.push('accent');
    if (action.danger) classes.push('danger');
    if (action.muted) classes.push('muted');
    if (action.toggle) {
        classes.push('btn-toggle');
        if (state[action.stateKey]) classes.push('on');
    }
    if (isActionDisabled(action)) classes.push('disabled');
    return classes;
}
function getCurrentStop() {
    if (!initData?.tourStops?.length || !state.currentTourStopIndex || state.currentTourStopIndex < 1) {
        return null;
    }
    return initData.tourStops[state.currentTourStopIndex - 1] || null;
}

function getCurrentStopVehicle() {
    const stop = getCurrentStop();
    if (!stop?.vehicles?.length) {
        return null;
    }

    const selectedName = state.spawnVehicleName;
    if (selectedName) {
        const match = stop.vehicles.find((vehicle) => vehicle.name === selectedName);
        if (match) {
            return match;
        }
    }

    return stop.vehicles[0];
}

function getCurrentStopLocation() {
    const stop = getCurrentStop();
    if (!stop?.locations?.length) {
        return null;
    }

    const index = state.currentTourLocationIndex;
    if (index && index >= 1 && index <= stop.locations.length) {
        return stop.locations[index - 1];
    }

    if (state.currentTourLocationName) {
        const match = stop.locations.find((location) => location.name === state.currentTourLocationName);
        if (match) {
            return match;
        }
    }

    return stop.locations[0];
}

function getStopName() {
    if (state.currentStopName) {
        return state.currentStopName;
    }
    if (!initData?.tourStops?.length || !state.currentTourStopIndex || state.currentTourStopIndex < 1) {
        return 'No stop selected';
    }
    const stop = initData.tourStops[state.currentTourStopIndex - 1];
    return stop ? stop.name : 'No stop selected';
}

function isStopRainbowEnabled(stopIndex) {
    const modes = state.stopRainbowModes;
    if (modes == null) {
        const stop = initData?.tourStops?.[stopIndex - 1];
        return !!stop?.rainbowModeDefault;
    }
    if (Array.isArray(modes)) {
        return !!modes[stopIndex - 1];
    }
    return !!modes[stopIndex] || !!modes[String(stopIndex)];
}
function getActiveTabMeta() {
    const tabs = getTabs();
    return tabs.find((t) => t.id === activeTab) || tabs[0];
}
