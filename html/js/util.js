// HTML escaping, icons, key chips, list filtering, and banner loading.

function applyBannerSrc(src) {
    if (!bannerEl || !src) return;
    bannerEl.onload = () => { bannerLoaded = true; };
    bannerEl.src = src;
}

function loadBanner(explicitResource, explicitUrl) {
    if (!bannerEl || bannerLoaded) return;

    const res = explicitResource || resourceName;
    const urls = [];

    if (explicitUrl) urls.push(explicitUrl);
    urls.push(
        `https://cfx-nui-${res}/html/banner.jpg`,
        `https://${res}/html/banner.jpg`,
        `nui://${res}/html/banner.jpg`,
    );

    let attempt = 0;

    const tryNext = () => {
        if (bannerLoaded || attempt >= urls.length) {
            if (!bannerLoaded) {
                fetch(`https://cfx-nui-${res}/html/banner.jpg`)
                    .then((response) => (response.ok ? response.blob() : Promise.reject()))
                    .then((blob) => applyBannerSrc(URL.createObjectURL(blob)))
                    .catch(() => nuiPost('requestBanner'));
            }
            return;
        }

        const url = urls[attempt];
        attempt += 1;
        bannerEl.onerror = tryNext;
        applyBannerSrc(url);
    };

    tryNext();
}

function applyBannerBase64(b64) {
    if (!bannerEl || !b64 || bannerLoaded) return;
    bannerEl.onload = () => { bannerLoaded = true; };
    bannerEl.src = `data:image/jpeg;base64,${b64}`;
}
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text ?? '';
    return div.innerHTML;
}

function icon(name, extraClass = '') {
    const safeName = escapeHtml(name || 'circle');
    const cls = extraClass ? ` ${extraClass}` : '';
    return `<i class="fa-solid fa-${safeName}${cls}" aria-hidden="true"></i>`;
}

const KEY_ARROW_ICONS = {
    'dpad-down': 'arrow-down',
    'dpad-up': 'arrow-up',
    'dpad-left': 'arrow-left',
    'dpad-right': 'arrow-right',
};

function renderPlayStationSquareKey(chipClass = 'hud-key', extraClass = '') {
    const cls = `${chipClass}${extraClass ? ` ${extraClass}` : ''} ps-square-key`;
    return `<span class="${cls}" aria-label="Square"><svg class="ps-square-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="6.5" y="6.5" width="11" height="11" rx="1.5"/></svg></span>`;
}

function renderKeyChip(key, chipClass = 'hud-key', extraClass = '') {
    if (key === 'X' || key === 'ps-square') {
        return renderPlayStationSquareKey(chipClass, extraClass);
    }

    const arrowIcon = KEY_ARROW_ICONS[key];
    const cls = `${chipClass}${extraClass ? ` ${extraClass}` : ''}`;
    if (arrowIcon) {
        return `<span class="${cls}">${icon(arrowIcon, 'key-arrow-icon')}</span>`;
    }
    return `<span class="${cls}">${escapeHtml(key)}</span>`;
}

function renderKeyChips(keys, chipClass = 'hud-key', double = false) {
    const extraClass = double ? 'double' : '';
    return keys.map((k) => renderKeyChip(k, chipClass, extraClass)).join('');
}

function filterList(items, query, keys) {
    const q = (query || '').trim().toLowerCase();
    if (!q) return items;
    return items.filter((item) =>
        keys.some((key) => String(item[key] ?? '').toLowerCase().includes(q))
    );
}
