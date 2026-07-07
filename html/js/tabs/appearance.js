// Appearance tab content.

function renderAppearanceTab() {
    if (!initData?.colours) {
        renderEmptyState('Loading appearance…', 'circle-notch', true);
        return;
    }

    const swatches = Object.entries(initData.colours).map(([key, hex]) =>
        `<button type="button" class="swatch-btn${state.brandColour === key ? ' active' : ''}" data-action="setColour" data-colour="${escapeHtml(key)}" title="${escapeHtml(key)}" aria-label="${escapeHtml(key)}">
            <span class="swatch" style="background:${hex}"></span>
            <span class="swatch-name">${escapeHtml(key)}</span>
        </button>`
    ).join('');

    const busTypes = [
        { id: 'bus', label: 'Transit', icon: 'bus', title: 'Public transport bus' },
        { id: 'tourbus', label: 'Tour', icon: 'van-shuttle', title: 'Tour bus' },
    ];

    const busSwatches = busTypes.map((bus) =>
        `<button type="button" class="swatch-btn${state.busType === bus.id ? ' active' : ''}" data-action="setBusType" data-type="${bus.id}" title="${escapeHtml(bus.title)}" aria-label="${escapeHtml(bus.title)}">
            <span class="swatch-icon">${icon(bus.icon)}</span>
            <span class="swatch-name">${escapeHtml(bus.label)}</span>
        </button>`
    ).join('');

    contentEl.innerHTML = `
        <div class="card-grid">
            <div class="card">
                <div class="card-header">
                    ${icon('palette', 'card-icon')}
                    <div>
                        <div class="card-title">Appearance</div>
                        <div class="card-desc">Tour colour, bus type, vehicle styling, and guide outfit</div>
                    </div>
                </div>
                <div class="brand-options-row">
                    <div class="brand-option-group">
                        <div class="brand-option-label">Colour</div>
                        <div class="colour-swatches">${swatches}</div>
                    </div>
                    <div class="brand-option-group">
                        <div class="brand-option-label">Bus type</div>
                        <div class="colour-swatches">${busSwatches}</div>
                    </div>
                    <div class="brand-option-group">
                        <div class="brand-option-label">Apply</div>
                        <div class="brand-apply-swatches">
                            <button type="button" class="swatch-btn brand-apply-btn primary" data-action="adventurify" title="Adventur-ify current vehicle" aria-label="Adventur-ify current vehicle">
                                <span class="swatch-icon">${icon('wand-magic-sparkles')}</span>
                                <span class="swatch-name">Vehicle</span>
                            </button>
                            <button type="button" class="swatch-btn brand-apply-btn" data-action="applyOutfit" title="Tour guide outfit" aria-label="Tour guide outfit">
                                <span class="swatch-icon">${icon('shirt')}</span>
                                <span class="swatch-name">Outfit</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>`;
}
