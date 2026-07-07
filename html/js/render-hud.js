// On-screen control-hint HUD overlay.

function renderHud(data) {
    if (!data.visible) {
        hudEl.classList.add('hidden');
        return;
    }

    hudEl.classList.remove('hidden');

    if (hudTour) {
        hudTour.textContent = `Tour: ${state.tourActive ? 'Active' : 'Stopped'}`;
        hudTour.classList.toggle('active', !!state.tourActive);
    }

    hudStop.textContent = `Stop: ${getStopName()}`;
    hudVehicle.textContent = `Vehicle: ${state.spawnVehicleName || '—'}`;
    hudSpawn.textContent = `Grid: ${state.spawnModeEnabled ? 'ON' : 'OFF'}`;
    hudSpawn.classList.toggle('active', !!state.spawnModeEnabled);

    hudSuperdrive.textContent = `Superdrive: ${state.superdriveEnabled ? 'ON' : 'OFF'}`;
    hudSuperdrive.classList.toggle('active', !!state.superdriveEnabled);

    const hints = getControlHints();
    const binds = data.variant === 'bus' ? hints.bus : hints.foot;
    hudBinds.innerHTML = binds.map((b) => {
        const keysHtml = renderKeyChips(b.keys, 'hud-key', b.double);
        return `<div class="hud-bind">${keysHtml}<span class="hud-label">${escapeHtml(b.label)}</span></div>`;
    }).join('');
}
