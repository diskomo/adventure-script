// Animations tab content.

function renderAnimButton(a) {
    return `<button type="button" class="anim-btn" data-action="playAction" data-id="${escapeHtml(a.id)}"${a.variants ? ` data-variants="${escapeHtml(a.variants.join(','))}"` : ''}>
        ${icon(a.icon || 'person-walking', 'anim-icon')}
        <span class="anim-label">${escapeHtml(a.name)}</span>
    </button>`;
}

function renderAnimationsTab() {
    if (!initData?.actions?.length) {
        renderEmptyState('Loading animations…', 'circle-notch', true);
        return;
    }

    const filtered = filterList(initData.actions, animSearchQuery, ['name']);
    const poses = filtered.filter((a) => a.type === 'anim');
    const scenarios = filtered.filter((a) => a.type === 'scen');
    const other = filtered.filter((a) => a.type !== 'anim' && a.type !== 'scen');

    const cancelHtml = `<button type="button" class="anim-btn cancel" data-action="cancelAction">
        ${icon('ban', 'anim-icon')}
        <span class="anim-label">Cancel Animation</span>
    </button>`;

    let groupsHtml = '';
    if (!filtered.length) {
        groupsHtml = `
            <div class="empty-state empty-state-inline">
                <i class="fa-solid fa-magnifying-glass empty-state-icon" aria-hidden="true"></i>
                <p class="empty-state-text">No animations match your search</p>
            </div>`;
    } else {
        if (poses.length) {
            groupsHtml += `<div class="section-title">Poses &amp; Animations</div><div class="anim-grid">${poses.map(renderAnimButton).join('')}</div>`;
        }
        if (scenarios.length) {
            groupsHtml += `<div class="section-title${poses.length ? ' section-spaced' : ''}">Scenarios</div><div class="anim-grid">${scenarios.map(renderAnimButton).join('')}</div>`;
        }
        if (other.length) {
            groupsHtml += `<div class="section-title section-spaced">Other</div><div class="anim-grid">${other.map(renderAnimButton).join('')}</div>`;
        }
    }

    contentEl.innerHTML = `
        <div class="search-wrap">
            <input class="search-input" id="anim-search" type="text" placeholder="Search animations…" value="${escapeHtml(animSearchQuery)}" />
        </div>
        <div class="anim-cancel-row">${cancelHtml}</div>
        ${groupsHtml}`;
}
