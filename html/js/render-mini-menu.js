// Corner mini toolbar overlay.

function renderMiniCycleButton(action, iconName, label, disabled) {
    const disabledAttr = disabled ? ' disabled' : '';
    return `<button type="button" class="btn btn-icon-only mini-cycle-btn" data-action="${action}" title="${escapeHtml(label)}" aria-label="${escapeHtml(label)}"${disabledAttr}>
        ${icon(iconName, 'btn-icon')}
    </button>`;
}

function renderMiniCycleRow({ prevAction, nextAction, prevLabel, nextLabel, canCycle, iconName, displayName }) {
    return `
        <div class="mini-cycle-row${canCycle ? '' : ' mini-cycle-row-static'}">
            ${renderMiniCycleButton(prevAction, 'chevron-left', prevLabel, !canCycle)}
            <div class="mini-cycle-display">
                ${icon(iconName, 'mini-cycle-icon')}
                <span class="mini-cycle-name">${escapeHtml(displayName)}</span>
            </div>
            ${renderMiniCycleButton(nextAction, 'chevron-right', nextLabel, !canCycle)}
        </div>`;
}

function renderPassengerMiniStopHtml() {
    const following = state.following !== false;
    const guideName = state.guideName || 'Unknown';
    const stopName = getServerStopName();
    const tourLabel = state.sessionActive ? 'Tour active' : 'Waiting';

    return `
        <div class="mini-membership-chip">
            ${icon('user-tie', 'membership-icon')}
            <span>${escapeHtml(tourLabel)} · ${escapeHtml(guideName)}</span>
        </div>
        <div class="mini-stop-header">
            <div class="mini-stop-heading">Current stop</div>
        </div>
        <div class="mini-cycle-row mini-cycle-row-static">
            <div class="mini-cycle-display">
                ${icon('map-location-dot', 'mini-cycle-icon')}
                <span class="mini-cycle-name">${escapeHtml(stopName)}</span>
            </div>
        </div>
        <div class="mini-passenger-signals">
            <button type="button" class="btn btn-sm btn-labeled${state.ready ? ' accent' : ''}" data-action="setReady" data-ready="${state.ready ? 'false' : 'true'}" title="Raise hand" aria-label="Raise hand">
                ${icon('hand', 'btn-icon')}<span class="btn-label">${state.ready ? 'Ready' : 'Ready?'}</span>
            </button>
            <button type="button" class="btn btn-sm btn-labeled muted" data-action="requestHelp" data-help-type="stuck" title="Help, I'm stuck" aria-label="Help, I'm stuck">
                ${icon('triangle-exclamation', 'btn-icon')}<span class="btn-label">Stuck</span>
            </button>
            <button type="button" class="btn btn-sm btn-labeled${following ? '' : ' accent'}" data-action="toggleFollowing" title="Toggle follow tour" aria-label="Toggle follow tour">
                ${icon('location-crosshairs', 'btn-icon')}<span class="btn-label">${following ? 'Following' : 'Free roam'}</span>
            </button>
        </div>`;
}

function renderMiniStopHtml() {
    if (!state.isGuide) {
        return renderPassengerMiniStopHtml();
    }

    const tourActive = !!state.tourActive;
    const stop = tourActive ? getCurrentStop() : null;
    const location = tourActive ? getCurrentStopLocation() : null;
    const vehicle = tourActive ? getCurrentStopVehicle() : null;
    const stopCount = initData?.tourStops?.length || 0;
    const locationCount = stop?.locations?.length || 0;
    const vehicleCount = stop?.vehicles?.length || 0;
    const stopIndex = tourActive ? state.currentTourStopIndex : 0;
    const stopName = tourActive ? (stop ? stop.name : getStopName()) : 'No stop selected';
    const locationName = tourActive ? (location?.name || state.currentTourLocationName || '—') : '—';
    const vehicleName = tourActive ? (vehicle?.name || state.spawnVehicleName || '—') : '—';
    const vehicleIcon = vehicle?.icon || 'car';
    const rainbowControl = stopIndex && stopIndex > 0
        ? renderRainbowToggleButton(stopIndex)
        : `<button type="button" class="btn btn-icon-only btn-toggle btn-rainbow disabled" title="Rainbow mode" aria-label="Rainbow mode" disabled>
            ${icon('rainbow', 'btn-icon')}
        </button>`;
    const canReset = tourActive && stopIndex > 0;
    const resetControl = `<button type="button" class="btn btn-icon-only muted${canReset ? '' : ' disabled'}" data-action="resetStop" title="Reset stop" aria-label="Reset stop"${canReset ? '' : ' disabled'}>
        ${icon('arrow-rotate-left', 'btn-icon')}
    </button>`;

    return `
        <div class="mini-stop-header">
            <div class="mini-stop-heading">Current stop</div>
            <div class="mini-stop-controls">
                ${rainbowControl}
                ${resetControl}
            </div>
        </div>
        ${renderMiniCycleRow({
            prevAction: 'cycleStopPrev',
            nextAction: 'cycleStopNext',
            prevLabel: 'Previous stop',
            nextLabel: 'Next stop',
            canCycle: tourActive && stopCount > 1,
            iconName: 'map-location-dot',
            displayName: stopName,
        })}
        ${renderMiniCycleRow({
            prevAction: 'cycleLocationPrev',
            nextAction: 'cycleLocationNext',
            prevLabel: 'Previous location',
            nextLabel: 'Next location',
            canCycle: tourActive && locationCount > 1,
            iconName: 'location-dot',
            displayName: locationName,
        })}
        ${renderMiniCycleRow({
            prevAction: 'cycleVehiclePrev',
            nextAction: 'cycleVehicleNext',
            prevLabel: 'Previous vehicle',
            nextLabel: 'Next vehicle',
            canCycle: tourActive && vehicleCount > 1,
            iconName: vehicleIcon,
            displayName: vehicleName,
        })}`;
}

function renderMiniTransportBusIconHtml(superdriveOn) {
    if (superdriveOn) {
        return `<span class="mini-transport-icons">
            ${icon('bus', 'mini-transport-icon')}
            ${icon('rocket', 'mini-transport-icon mini-transport-rocket')}
        </span>`;
    }
    return icon('bus', 'mini-transport-icon');
}

function renderMiniTourTransportHtml() {
    const playing = !!state.tourActive;
    const inBus = !!state.isDrivingBus;
    const superdriveOn = inBus && !!state.superdriveEnabled;
    const canPlay = inBus && !playing;
    const playTitle = canPlay ? 'Play tour' : inBus ? 'Play tour' : 'Play tour (drive the tour bus first)';
    const busAction = inBus ? 'toggleSuperdrive' : 'spawnBus';
    const busTitle = inBus
        ? (superdriveOn ? 'Superdrive on — click to disable' : 'Superdrive off — click to enable')
        : 'Spawn bus';
    const busLabel = inBus ? (superdriveOn ? 'Super' : 'Bus') : 'Bus';
    const busClasses = [
        'mini-transport-btn',
        'mini-transport-bus',
        'lit',
        superdriveOn ? 'superdrive' : '',
    ].filter(Boolean).join(' ');

    return `<div class="mini-tour-transport">
        <button type="button" class="mini-transport-btn mini-transport-play${canPlay ? ' lit' : ''}" data-action="startTour" title="${escapeHtml(playTitle)}" aria-label="${escapeHtml(playTitle)}"${canPlay ? '' : ' disabled'}>
            ${icon('play', 'mini-transport-icon')}
            <span class="mini-transport-label">Play</span>
        </button>
        <button type="button" class="mini-transport-btn mini-transport-stop${playing ? ' lit' : ''}" data-action="stopTour" title="Stop tour" aria-label="Stop tour">
            ${icon('stop', 'mini-transport-icon')}
            <span class="mini-transport-label">Stop</span>
        </button>
        <button type="button" class="${busClasses}" data-action="${busAction}" title="${escapeHtml(busTitle)}" aria-label="${escapeHtml(busTitle)}">
            ${renderMiniTransportBusIconHtml(superdriveOn)}
            <span class="mini-transport-label">${escapeHtml(busLabel)}</span>
        </button>
    </div>`;
}

function renderMiniOpenHtml() {
    return renderMiniActionButton(OPEN_MAIN_MENU_ACTION);
}

function renderMiniGridSpawnRowHtml() {
    const toggleAction = {
        id: 'toggleSpawn',
        label: 'Grid spawn',
        icon: 'border-all',
        toggle: true,
        stateKey: 'spawnModeEnabled',
    };
    const undoAction = {
        id: 'undoSpawn',
        label: 'Undo',
        icon: 'rotate-left',
        muted: true,
        disabledUnless: 'spawnUndoCount',
    };

    return `<div class="mini-grid-spawn-row">
        <button type="button" class="${[...getQuickActionButtonClasses(toggleAction), 'btn-labeled', 'mini-grid-toggle'].join(' ')}" data-action="toggleSpawn" title="Grid spawn" aria-label="Grid spawn">
            ${icon(toggleAction.icon, 'btn-icon')}
            <span class="btn-label">${escapeHtml(toggleAction.label)}</span>
        </button>
        <button type="button" class="${[...getQuickActionButtonClasses(undoAction), 'btn-labeled', 'mini-grid-undo'].join(' ')}" data-action="undoSpawn" title="${escapeHtml(resolveActionLabel(undoAction))}" aria-label="${escapeHtml(resolveActionLabel(undoAction))}"${isActionDisabled(undoAction) ? ' disabled' : ''}>
            ${icon(undoAction.icon, 'btn-icon')}
            <span class="btn-label">${escapeHtml(undoAction.label)}</span>
        </button>
    </div>`;
}

function renderMiniActionGroupsHtml() {
    if (!state.isGuide) {
        return '';
    }

    const groups = getQuickActionGroups(false)
        .map((group) => group.actions.filter((action) =>
            action.id !== 'resetStop'
            && action.id !== 'spawnBus'
            && action.id !== 'toggleSpawn'
            && action.id !== 'undoSpawn'
        ))
        .filter((actions) => actions.length > 0);

    return `${renderMiniTourTransportHtml()}
        ${renderMiniGridSpawnRowHtml()}
        ${groups.map((actions) =>
            `<div class="mini-action-group">${actions.map(renderMiniActionButton).join('')}</div>`
        ).join('')}`;
}

function renderCornerMark(cornerId) {
    return `<span class="corner-mark corner-mark-${cornerId}" aria-hidden="true"></span>`;
}

function applyMiniMenuCorner(corner) {
    if (!miniMenuEl) return;
    MINI_MENU_CORNERS.forEach(({ id }) => {
        miniMenuEl.classList.toggle(`corner-${id}`, id === corner);
    });
}

function renderMiniMenu() {
    if (!miniMenuEl || !miniOpenEl || !miniStopEl || !miniActionsEl) return;

    miniOpenEl.innerHTML = renderMiniOpenHtml();
    miniStopEl.innerHTML = renderMiniStopHtml();
    miniActionsEl.innerHTML = renderMiniActionGroupsHtml();
}

function updateMiniMenu() {
    if (!miniMenuEl) return;

    const show = !!state.miniMenuEnabled;
    miniMenuEl.classList.toggle('hidden', !show);
    miniMenuEl.classList.toggle('passenger-mode', !state.isGuide);

    if (!show) return;

    applyMiniMenuCorner(state.miniMenuCorner || 'top-right');
    renderMiniMenu();
}
