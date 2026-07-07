// Passengers tab content (guide view).

function formatPresenceLabel(presence) {
    switch (presence) {
        case 'guide': return 'Tour guide';
        case 'on_bus': return 'On bus';
        case 'near_stop': return 'At stop';
        case 'away': return 'Away';
        default: return '';
    }
}

function formatSignalBadges(entry) {
    const badges = [];
    if (entry.ready) badges.push('<span class="signal-badge ready">Ready</span>');
    if (entry.help === 'stuck') badges.push('<span class="signal-badge stuck">Stuck</span>');
    if (entry.help === 'injured') badges.push('<span class="signal-badge injured">Injured</span>');
    if (entry.nextStopVote) badges.push('<span class="signal-badge vote">Next stop</span>');
    if (entry.following === false) badges.push('<span class="signal-badge away">Not following</span>');
    return badges.join('');
}

function renderPassengersTab() {
    const roster = state.tourRoster || [];
    const counts = state.rosterCounts || { passengers: 0 };
    const nextStopVote = state.nextStopVote || { votes: 0, passengerCount: 0, threshold: 0, thresholdMet: false };
    const hasRoster = roster.length > 0;

    const rosterHtml = hasRoster
        ? roster.map((entry) => {
            const presenceLabel = formatPresenceLabel(entry.presence);
            const signals = formatSignalBadges(entry);
            const badgeClass = entry.isGuide ? 'guide' : (entry.presence === 'away' ? 'away' : 'in_tour');
            const transferBtn = entry.isGuide || entry.id === state.guideId
                ? ''
                : `<button type="button" class="btn btn-sm accent" data-action="transferGuide" data-target-id="${entry.id}">Make guide</button>`;
            return `<div class="passenger-row">
                <div class="passenger-row-main">
                    <span class="passenger-badge ${badgeClass}"></span>
                    <div>
                        <div class="passenger-name">${escapeHtml(entry.name)}</div>
                        <div class="passenger-meta">${escapeHtml(presenceLabel)} · ID ${entry.id}</div>
                        ${signals ? `<div class="passenger-signals">${signals}</div>` : ''}
                    </div>
                </div>
                ${transferBtn}
            </div>`;
        }).join('')
        : `<div class="empty-state empty-state-inline">
            ${icon('users', 'empty-state-icon')}
            <p class="empty-state-text">No players online yet.</p>
        </div>`;

    const voteTallyHtml = nextStopVote.passengerCount > 0
        ? `<div class="card-desc${nextStopVote.thresholdMet ? ' vote-threshold-met' : ''}">
            ${nextStopVote.votes} of ${nextStopVote.passengerCount} passengers voted for the next stop
            ${nextStopVote.thresholdMet ? ' — ready to move on!' : ` (need ${nextStopVote.threshold})`}
        </div>`
        : '<div class="card-desc">No passenger votes yet</div>';

    contentEl.innerHTML = `
        <div class="card-grid">
            <div class="card">
                <div class="card-header">
                    ${icon('users', 'card-icon')}
                    <div>
                        <div class="card-title">Tour group</div>
                        <div class="card-desc">${counts.passengers || 0} passengers online</div>
                    </div>
                </div>
                <div class="passenger-actions-row">
                    <button type="button" class="btn" data-action="gatherToBus">
                        ${icon('bus', 'btn-icon')}<span class="btn-label">Gather to bus</span>
                    </button>
                    <button type="button" class="btn" data-action="gatherToStop">
                        ${icon('location-dot', 'btn-icon')}<span class="btn-label">Gather to stop</span>
                    </button>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    ${icon('forward', 'card-icon')}
                    <div>
                        <div class="card-title">Next stop vote</div>
                        ${voteTallyHtml}
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    ${icon('list', 'card-icon')}
                    <div>
                        <div class="card-title">Roster</div>
                        <div class="card-desc">Everyone on the server</div>
                    </div>
                    <button type="button" class="btn btn-sm muted passenger-refresh-btn" data-action="refreshPlayers">
                        ${icon('rotate', 'btn-icon')}<span class="btn-label">Refresh</span>
                    </button>
                </div>
                <div class="passenger-list">${rosterHtml}</div>
            </div>
        </div>`;
}
