// Guide tab content (passenger view): current guide and elections.

function renderGuideTab() {
    const guideName = state.guideName || 'Unknown';
    const election = state.election;
    const onlinePlayers = (state.onlinePlayers || []).filter((p) => !p.isGuide);

    const electionHtml = election?.active
        ? `<div class="card">
            <div class="card-header">
                ${icon('check-to-slot', 'card-icon')}
                <div>
                    <div class="card-title">Election in progress</div>
                    <div class="card-desc">Vote for ${escapeHtml(election.candidateName)} to become guide</div>
                </div>
            </div>
            <div class="election-tally">
                <span class="election-stat yes">${election.yesVotes || 0} yes</span>
                <span class="election-stat no">${election.noVotes || 0} no</span>
                <span class="election-timer">${election.remainingSec || 0}s remaining</span>
            </div>
        </div>`
        : '';

    const candidatesHtml = onlinePlayers.length
        ? onlinePlayers.map((player) =>
            `<div class="passenger-row">
                <div class="passenger-row-main">
                    <div>
                        <div class="passenger-name">${escapeHtml(player.name)}</div>
                        <div class="passenger-meta">ID ${player.id}</div>
                    </div>
                </div>
                <button type="button" class="btn btn-sm"${election?.active ? ' disabled' : ''} data-action="startElection" data-candidate-id="${player.id}">
                    Nominate
                </button>
            </div>`
        ).join('')
        : `<div class="empty-state empty-state-inline">
            ${icon('user-slash', 'empty-state-icon')}
            <p class="empty-state-text">No other players to nominate.</p>
        </div>`;

    contentEl.innerHTML = `
        <div class="card-grid">
            <div class="card">
                <div class="card-header">
                    ${icon('user-tie', 'card-icon')}
                    <div>
                        <div class="card-title">Current tour guide</div>
                        <div class="card-desc">${escapeHtml(guideName)} is leading the tour</div>
                    </div>
                </div>
            </div>

            ${electionHtml}

            <div class="card">
                <div class="card-header">
                    ${icon('vote-yea', 'card-icon')}
                    <div>
                        <div class="card-title">Elect a new guide</div>
                        <div class="card-desc">Start a server vote to replace the current guide</div>
                    </div>
                </div>
                <div class="passenger-list">${candidatesHtml}</div>
            </div>
        </div>`;
}
