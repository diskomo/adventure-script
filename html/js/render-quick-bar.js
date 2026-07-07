// Main menu quick status bar and action groups.

function renderQuickBar() {
    if (!state.isGuide) {
        const following = state.following !== false;
        quickStatusEl.innerHTML = `
            <span class="status-item${state.sessionActive ? ' active' : ''}"><span class="status-label">Tour</span> ${state.sessionActive ? 'Active' : 'Waiting'}</span>
            <span class="status-divider"></span>
            <span class="status-item status-item-primary"><span class="status-label">Stop</span> ${escapeHtml(getServerStopName())}</span>
            <span class="status-divider"></span>
            <span class="status-item"><span class="status-label">Guide</span> ${escapeHtml(state.guideName || '—')}</span>
            <span class="status-divider"></span>
            <span class="status-item"><span class="status-label">Follow</span> ${following ? 'On' : 'Off'}</span>
        `;

        const actions = getPassengerQuickActions();
        quickActionsEl.innerHTML = `<div class="quick-action-groups"><div class="quick-group">${actions.map(renderQuickActionButton).join('')}</div></div>`;
        return;
    }

    quickStatusEl.innerHTML = `
        <span class="status-item${state.tourActive ? ' active' : ''}"><span class="status-label">Tour</span> ${state.tourActive ? 'Active' : 'Stopped'}</span>
        <span class="status-divider"></span>
        <span class="status-item status-item-primary"><span class="status-label">Stop</span> ${escapeHtml(getStopName())}</span>
        <span class="status-divider"></span>
        <span class="status-item"><span class="status-label">Vehicle</span> ${escapeHtml(state.spawnVehicleName || '—')}</span>
    `;

    const groupsHtml = getQuickActionGroups().map((group) => renderQuickActionGroup(group.actions)).join('<span class="quick-group-divider" aria-hidden="true"></span>');

    quickActionsEl.innerHTML = `<div class="quick-action-groups">${groupsHtml}</div>`;
}
