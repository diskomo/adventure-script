// L3 radial quick-actions overlay.

function isL3RadialItemDisabled(item, context) {
    if (!item.disabledUnless) {
        return false;
    }

    if (item.disabledUnless === 'spawnUndoCount') {
        return !(context.spawnUndoCount > 0);
    }

    if (item.disabledUnless === 'tourActive') {
        return !context.tourActive;
    }

    if (item.disabledUnless === 'isDrivingBus') {
        return !!context.isDrivingBus;
    }

    return false;
}

function renderL3RadialItem(item, context) {
    const disabled = isL3RadialItemDisabled(item, context);
    const on = item.toggle && context.spawnModeEnabled;
    const label = item.id === 'undoSpawn' && context.spawnUndoCount > 0
        ? `Undo (${context.spawnUndoCount})`
        : item.label;
    const status = item.toggle
        ? `<span class="l3-radial-status">${on ? 'ON' : 'OFF'}</span>`
        : '';

    return `<div class="l3-radial-option l3-radial-${item.direction}${on ? ' on' : ''}${disabled ? ' disabled' : ''}">
        <span class="l3-radial-key">${renderKeyChip(`dpad-${item.direction}`, 'l3-radial-key-chip')}</span>
        <div class="l3-radial-option-body">
            ${icon(item.icon, 'l3-radial-icon')}
            <span class="l3-radial-name">${escapeHtml(label)}</span>
            ${status}
        </div>
    </div>`;
}

function renderL3RadialHub(variant, tourActive, isDrivingBus) {
    if (!l3RadialHub) return;

    const playing = !!tourActive;
    const isBus = variant === 'bus';
    const canPlay = isBus && !playing;
    const canStop = playing;
    const iconName = playing ? 'stop' : 'play';
    const label = playing ? 'Stop tour' : isBus ? 'Play tour' : 'Stop tour';
    const classes = ['l3-radial-hub-inner'];
    if (playing) classes.push('stop');
    if (canPlay || (!isBus && canStop)) classes.push('lit');
    if (!canPlay && !canStop && isBus) classes.push('disabled');
    if (!isBus && !canStop) classes.push('disabled');

    l3RadialHub.innerHTML = `
        <div class="${classes.join(' ')}">
            <span class="l3-radial-key">${renderKeyChip('X', 'l3-radial-key-chip')}</span>
            ${icon(iconName, 'l3-radial-hub-icon')}
            <span class="l3-radial-hub-label">${escapeHtml(label)}</span>
        </div>`;
}

function renderL3Menu(data) {
    if (!data.visible) {
        l3MenuEl.classList.add('hidden');
        return;
    }

    l3MenuEl.classList.remove('hidden');

    const variant = data.variant === 'bus' ? 'bus' : 'foot';
    const spawnModeEnabled = data.spawnModeEnabled ?? state.spawnModeEnabled;
    const spawnUndoCount = data.spawnUndoCount ?? state.spawnUndoCount ?? 0;
    const tourActive = data.tourActive ?? state.tourActive;
    const isDrivingBus = data.isDrivingBus ?? state.isDrivingBus;
    const items = L3_RADIAL_ITEMS;
    const context = { spawnModeEnabled, spawnUndoCount, tourActive, isDrivingBus };

    l3MenuList.innerHTML = items
        .map((item) => renderL3RadialItem(item, context))
        .join('');

    renderL3RadialHub(variant, tourActive, isDrivingBus);
}
