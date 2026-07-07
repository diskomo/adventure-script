// My Tour tab content (passenger view).

function renderMyTourTab() {
    const guideName = state.guideName || 'Unknown';
    const tourStatus = state.sessionActive ? 'Tour in progress' : 'Waiting to start';
    const stopName = getServerStopName();
    const following = state.following !== false;
    const nextStopVote = state.nextStopVote || { votes: 0, passengerCount: 0, threshold: 0, thresholdMet: false };
    const helpState = state.helpState;

    const voteLabel = state.nextStopVoted ? 'Remove next-stop vote' : 'Vote: next stop';
    const voteTally = nextStopVote.passengerCount > 0
        ? `${nextStopVote.votes} of ${nextStopVote.passengerCount} voted`
        : 'No votes yet';

    contentEl.innerHTML = `
        <div class="card-grid">
            <div class="card">
                <div class="card-header">
                    ${icon('route', 'card-icon')}
                    <div>
                        <div class="card-title">Tour status</div>
                        <div class="card-desc">${escapeHtml(tourStatus)} · Guide: ${escapeHtml(guideName)}</div>
                    </div>
                </div>
                <div class="tour-status-grid">
                    <div class="tour-status-item">
                        <span class="tour-status-label">Current stop</span>
                        <span class="tour-status-value">${escapeHtml(stopName)}</span>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    ${icon('location-crosshairs', 'card-icon')}
                    <div>
                        <div class="card-title">Follow tour</div>
                        <div class="card-desc">When off, you won't be teleported with the group</div>
                    </div>
                </div>
                <div class="setting-row">
                    <div class="setting-info">
                        ${icon('person-walking', 'setting-icon')}
                        <div>
                            <div class="setting-label">Follow teleports</div>
                            <div class="setting-desc">${following ? 'You follow tour teleports and gathers' : 'You are exploring independently'}</div>
                        </div>
                    </div>
                    <div class="toggle${following ? ' on' : ''}" data-action="toggleFollowing" role="switch" aria-checked="${following ? 'true' : 'false'}"></div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    ${icon('hand', 'card-icon')}
                    <div>
                        <div class="card-title">Signals</div>
                        <div class="card-desc">Let the guide know how you're doing</div>
                    </div>
                </div>
                <div class="passenger-actions-row">
                    <button type="button" class="btn${state.ready ? ' accent' : ''}" data-action="setReady" data-ready="${state.ready ? 'false' : 'true'}">
                        ${icon('hand', 'btn-icon')}<span class="btn-label">${state.ready ? 'Lower hand' : 'Raise hand (ready)'}</span>
                    </button>
                    <button type="button" class="btn${helpState === 'stuck' ? ' accent' : ''}" data-action="requestHelp" data-help-type="stuck">
                        ${icon('triangle-exclamation', 'btn-icon')}<span class="btn-label">Help, I'm stuck</span>
                    </button>
                    <button type="button" class="btn danger${helpState === 'injured' ? ' accent' : ''}" data-action="requestHelp" data-help-type="injured">
                        ${icon('kit-medical', 'btn-icon')}<span class="btn-label">Help, I'm injured</span>
                    </button>
                    ${helpState ? `<button type="button" class="btn muted" data-action="requestHelp" data-help-type="clear">
                        ${icon('xmark', 'btn-icon')}<span class="btn-label">Clear help signal</span>
                    </button>` : ''}
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    ${icon('forward', 'card-icon')}
                    <div>
                        <div class="card-title">Next stop vote</div>
                        <div class="card-desc">${escapeHtml(voteTally)}</div>
                    </div>
                </div>
                <button type="button" class="btn${state.nextStopVoted ? ' accent' : ''}" data-action="voteNextStop" data-voted="${state.nextStopVoted ? 'false' : 'true'}">
                    ${icon('check-to-slot', 'btn-icon')}<span class="btn-label">${escapeHtml(voteLabel)}</span>
                </button>
            </div>
        </div>`;
}
