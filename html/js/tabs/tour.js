// Tour Stops tab content.

function renderTourTab() {
    if (!initData?.tourStops?.length) {
        renderEmptyState('Loading tour stops…', 'circle-notch', true);
        return;
    }

    const stops = initData.tourStops;
    if (selectedStopIndex < 1) {
        selectedStopIndex = state.currentTourStopIndex > 0 ? state.currentTourStopIndex : 1;
    }

    const filteredStops = filterList(
        stops.map((s, i) => ({ ...s, index: i + 1 })),
        tourSearchQuery,
        ['name', 'description']
    );

    // innerHTML rebuilds wipe scroll; keep the stop list where the user left it
    const prevStopList = contentEl.querySelector('.stop-list');
    const stopListScrollTop = prevStopList ? prevStopList.scrollTop : 0;

    if (!filteredStops.length) {
        contentEl.innerHTML = `
            <div class="tour-layout">
                <div class="tour-sidebar">
                    <div class="search-wrap">
                        <input class="search-input" id="tour-search" type="text" placeholder="Search stops…" value="${escapeHtml(tourSearchQuery)}" />
                    </div>
                    <div class="stop-list">
                        <div class="empty-state empty-state-inline">
                            <i class="fa-solid fa-magnifying-glass empty-state-icon" aria-hidden="true"></i>
                            <p class="empty-state-text">No stops match your search</p>
                        </div>
                    </div>
                </div>
                <div class="stop-detail">
                    <div class="empty-state empty-state-inline">
                        <i class="fa-solid fa-map-location-dot empty-state-icon" aria-hidden="true"></i>
                        <p class="empty-state-text">Select a stop from the list</p>
                    </div>
                </div>
            </div>`;
        return;
    }

    const visibleSelected = filteredStops.find((s) => s.index === selectedStopIndex);
    if (!visibleSelected) {
        selectedStopIndex = filteredStops[0].index;
    }

    const stop = stops[selectedStopIndex - 1];
    if (!stop) {
        renderEmptyState('No tour stop found.', 'map-location-dot');
        return;
    }

    const locHtml = stop.locations.map((loc) =>
        `<div class="item-row" data-action="goToLocation" data-name="${escapeHtml(loc.name)}">
            <div class="item-row-main">
                ${icon('location-dot', 'item-icon')}
                <div>
                    <div class="item-name">${escapeHtml(loc.name)}</div>
                    <div class="item-desc">Teleport here</div>
                </div>
            </div>
            ${icon('chevron-right', 'item-chevron')}
        </div>`
    ).join('');

    const vehHtml = stop.vehicles.map((v) => {
        const selected = state.spawnVehicleName === v.name;
        return `<div class="item-row${selected ? ' selected' : ''}" data-action="setVehicle" data-stop="${selectedStopIndex}" data-id="${escapeHtml(v.id)}" data-name="${escapeHtml(v.name)}">
            <div class="item-row-main">
                ${icon(v.icon || 'car', 'item-icon')}
                <div>
                    <div class="item-name">${escapeHtml(v.name)}</div>
                    <div class="item-desc">Set as spawn vehicle</div>
                </div>
            </div>
            ${selected ? icon('check', 'item-check') : icon('chevron-right', 'item-chevron')}
        </div>`;
    }).join('');

    const stopListHtml = filteredStops.map((s) => {
        const isSelected = s.index === selectedStopIndex;
        const isCurrent = s.index === state.currentTourStopIndex;
        return `<div class="stop-item${isSelected ? ' active' : ''}" data-stop="${s.index}">
            <div class="stop-item-header">
                <span class="stop-item-name">${escapeHtml(s.name)}</span>
                ${isCurrent ? '<span class="badge badge-current">Current</span>' : ''}
            </div>
            <div class="stop-item-desc">${escapeHtml(s.description)}</div>
        </div>`;
    }).join('');

    contentEl.innerHTML = `
        <div class="tour-layout">
            <div class="tour-sidebar">
                <div class="search-wrap">
                    <input class="search-input" id="tour-search" type="text" placeholder="Search stops…" value="${escapeHtml(tourSearchQuery)}" />
                </div>
                <div class="stop-list">${stopListHtml}</div>
            </div>
            <div class="stop-detail">
                <div class="stop-detail-header">
                    <div class="stop-detail-heading">
                        <h3>${escapeHtml(stop.name)}</h3>
                        <p class="stop-detail-desc">${escapeHtml(stop.description)}</p>
                    </div>
                    ${renderRainbowToggleButton(selectedStopIndex)}
                </div>
                <div class="section-title">Locations</div>
                <div class="item-grid">${locHtml}</div>
                <div class="section-title">Vehicles</div>
                <div class="item-grid">${vehHtml}</div>
            </div>
        </div>`;

    const stopList = contentEl.querySelector('.stop-list');
    if (stopList) {
        stopList.scrollTop = stopListScrollTop;
    }
}
