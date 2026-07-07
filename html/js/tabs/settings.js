// Settings tab content.

function renderSettingsTab() {
    const isGuide = !!state.isGuide;

    const guideSettings = isGuide ? `
                <div class="setting-row">
                    <div class="setting-info">
                        ${icon('rocket', 'setting-icon')}
                        <div>
                            <div class="setting-label">Superdrive</div>
                            <div class="setting-desc">Hold A to fly toward camera; handbrake to hover and aim with the left stick</div>
                        </div>
                    </div>
                    <div class="toggle${state.superdriveEnabled ? ' on' : ''}" data-action="toggleSuperdrive" role="switch" aria-checked="${state.superdriveEnabled ? 'true' : 'false'}"></div>
                </div>
                <div class="setting-row">
                    <div class="setting-info">
                        ${icon('comments', 'setting-icon')}
                        <div>
                            <div class="setting-label">Auto-chat</div>
                            <div class="setting-desc">Send welcome and thank-you chat when starting and stopping a tour</div>
                        </div>
                    </div>
                    <div class="toggle${state.autoChat ? ' on' : ''}" data-action="toggleAutoChat" role="switch" aria-checked="${state.autoChat ? 'true' : 'false'}"></div>
                </div>` : '';

    contentEl.innerHTML = `
        <div class="card-grid">
            <div class="card">
                <div class="card-header">
                    ${icon('gamepad', 'card-icon')}
                    <div>
                        <div class="card-title">Gameplay</div>
                        <div class="card-desc">${isGuide ? 'Controls, superdrive, and tour chat' : 'Toolbar and control preferences'}</div>
                    </div>
                </div>
                ${guideSettings}
                <div class="setting-row">
                    <div class="setting-info">
                        ${icon('keyboard', 'setting-icon')}
                        <div>
                            <div class="setting-label">Show Controls</div>
                            <div class="setting-desc">Display keybind hints while holding modifier</div>
                        </div>
                    </div>
                    <div class="toggle${state.showOnScreenControls ? ' on' : ''}" data-action="toggleControls" role="switch" aria-checked="${state.showOnScreenControls ? 'true' : 'false'}"></div>
                </div>
                <div class="setting-row">
                    <div class="setting-info">
                        ${icon('grip-vertical', 'setting-icon')}
                        <div>
                            <div class="setting-label">Mini Toolbar</div>
                            <div class="setting-desc">Always show a compact toolbar with quick actions in a screen corner</div>
                        </div>
                    </div>
                    <div class="toggle${state.miniMenuEnabled ? ' on' : ''}" data-action="toggleMiniMenu" role="switch" aria-checked="${state.miniMenuEnabled ? 'true' : 'false'}"></div>
                </div>
                ${state.miniMenuEnabled ? `<div class="setting-row setting-row-stack">
                    <div class="setting-info">
                        ${icon('up-down-left-right', 'setting-icon')}
                        <div>
                            <div class="setting-label">Toolbar Corner</div>
                            <div class="setting-desc">Where the mini toolbar appears on screen</div>
                        </div>
                    </div>
                    <div class="corner-picker">
                        ${MINI_MENU_CORNERS.map((corner) =>
                            `<button type="button" class="corner-btn${state.miniMenuCorner === corner.id ? ' active' : ''}" data-action="setMiniMenuCorner" data-corner="${corner.id}" title="${escapeHtml(corner.label)}" aria-label="${escapeHtml(corner.label)}">
                                ${renderCornerMark(corner.id)}
                            </button>`
                        ).join('')}
                    </div>
                </div>` : ''}
            </div>
        </div>
        <div class="version-tag">Adventure Tours v${escapeHtml(initData.version || '')}</div>`;
}
