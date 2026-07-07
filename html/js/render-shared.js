// Shared render helpers reused across HUD, menu, and mini toolbar.

function renderQuickActionButton(action) {
    const label = resolveActionLabel(action);
    const classes = [...getQuickActionButtonClasses(action), 'btn-icon-only'];
    const disabled = isActionDisabled(action) ? ' disabled' : '';
    let extraAttrs = '';
    if (action.helpType) {
        extraAttrs += ` data-help-type="${escapeHtml(action.helpType)}"`;
    }
    if (action.id === 'setReady') {
        extraAttrs += ` data-ready="${state.ready ? 'false' : 'true'}"`;
    }
    return `<button type="button" class="${classes.join(' ')}" data-action="${action.id}" title="${escapeHtml(label)}" aria-label="${escapeHtml(label)}"${disabled}${extraAttrs}>
        ${icon(action.icon, 'btn-icon')}
    </button>`;
}

function renderMiniActionButton(action) {
    const label = resolveMiniActionLabel(action);
    const title = resolveActionLabel(action);
    const classes = [...getQuickActionButtonClasses(action), 'btn-labeled'];
    const disabled = isActionDisabled(action) ? ' disabled' : '';
    return `<button type="button" class="${classes.join(' ')}" data-action="${action.id}" title="${escapeHtml(title)}" aria-label="${escapeHtml(title)}"${disabled}>
        ${icon(action.icon, 'btn-icon')}
        <span class="btn-label">${escapeHtml(label)}</span>
    </button>`;
}

function renderQuickActionGroup(actions) {
    return `<div class="quick-group">${actions.map(renderQuickActionButton).join('')}</div>`;
}
function renderRainbowToggleButton(stopIndex) {
    const enabled = isStopRainbowEnabled(stopIndex);
    const classes = ['btn', 'btn-icon-only', 'btn-toggle', 'btn-rainbow'];
    if (enabled) classes.push('on');
    return `<button type="button" class="${classes.join(' ')}" data-action="toggleStopRainbow" data-stop="${stopIndex}" title="Rainbow mode" aria-label="Rainbow mode">
        ${icon('rainbow', 'btn-icon')}
    </button>`;
}
function renderEmptyState(message, iconName = 'circle-notch', spinning = false) {
    const spinClass = spinning ? ' fa-spin' : '';
    contentEl.innerHTML = `
        <div class="empty-state">
            <i class="fa-solid fa-${escapeHtml(iconName)} empty-state-icon${spinClass}" aria-hidden="true"></i>
            <p class="empty-state-text">${escapeHtml(message)}</p>
        </div>`;
}

function updateHeader() {
    const tab = getActiveTabMeta();
    if (headerTitleEl) headerTitleEl.textContent = tab.label;
    if (headerSubtitleEl) headerSubtitleEl.textContent = tab.description;
}
function renderCornerMark(cornerId) {
    return `<span class="corner-mark corner-mark-${cornerId}" aria-hidden="true"></span>`;
}
function renderSidebar() {
    const tabs = getTabs();
    sidebarEl.innerHTML = tabs.map((t) =>
        `<button type="button" class="tab-btn${activeTab === t.id ? ' active' : ''}" data-tab="${t.id}">
            ${icon(t.icon, 'tab-icon')}
            <span class="tab-label">${escapeHtml(t.label)}</span>
        </button>`
    ).join('');
}
