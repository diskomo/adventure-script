// NUI entry point: action dispatch, event wiring, and message router.

function dispatchAction(action, el) {
    switch (action) {
        case 'goToLocation':
            nuiPost('goToLocation', { name: el.dataset.name });
            break;
        case 'toggleStopRainbow':
            nuiPost('toggleStopRainbow', { stopIndex: parseInt(el.dataset.stop, 10) });
            break;
        case 'setVehicle':
            nuiPost('setVehicle', {
                stopIndex: parseInt(el.dataset.stop, 10),
                id: el.dataset.id,
                name: el.dataset.name,
            });
            break;
        case 'playAction':
            nuiPost('playAction', {
                id: el.dataset.id,
                variants: el.dataset.variants ? el.dataset.variants.split(',') : null,
            });
            break;
        case 'cancelAction':
            nuiPost('cancelAction');
            break;
        case 'sendChat':
            nuiPost('sendChat', { chatId: el.dataset.chat });
            break;
        case 'setColour':
            nuiPost('setColour', { colour: el.dataset.colour });
            break;
        case 'setBusType':
            nuiPost('setBusType', { busType: el.dataset.type });
            break;
        case 'applyOutfit':
            nuiPost('applyOutfit');
            break;
        case 'toggleControls':
            nuiPost('toggleControls');
            break;
        case 'toggleMiniMenu':
            state.miniMenuEnabled = !state.miniMenuEnabled;
            updateMiniMenu();
            if (!menuEl.classList.contains('hidden')) {
                renderContent();
            }
            nuiPost('toggleMiniMenu');
            break;
        case 'setMiniMenuCorner':
            state.miniMenuCorner = el.dataset.corner;
            updateMiniMenu();
            if (!menuEl.classList.contains('hidden')) {
                renderContent();
            }
            nuiPost('setMiniMenuCorner', { corner: el.dataset.corner });
            break;
        case 'openMainMenu':
            nuiPost('openMainMenu');
            break;
        case 'toggleSuperdrive':
            state.superdriveEnabled = !state.superdriveEnabled;
            updateMiniMenu();
            nuiPost('toggleSuperdrive');
            break;
        case 'toggleAutoChat':
            nuiPost('toggleAutoChat');
            break;
        case 'startTour':
        case 'stopTour':
            nuiPost(action);
            break;
        case 'spawnBus':
        case 'prevStop':
        case 'nextStop':
        case 'cycleStopPrev':
        case 'cycleStopNext':
        case 'cycleLocationPrev':
        case 'cycleLocationNext':
        case 'cycleVehiclePrev':
        case 'cycleVehicleNext':
        case 'toggleSpawn':
        case 'undoSpawn':
        case 'resetStop':
        case 'clearArea':
        case 'adventurify':
            nuiPost(action);
            break;
        case 'gatherToBus':
        case 'gatherToStop':
        case 'refreshPlayers':
            nuiPost(action);
            break;
        case 'transferGuide': {
            const targetId = parseInt(el.dataset.targetId, 10);
            const targetName = el.closest('.passenger-row')?.querySelector('.passenger-name')?.textContent || 'this player';
            if (targetId && window.confirm(`Make ${targetName} the tour guide?`)) {
                nuiPost('transferGuide', { targetId });
            }
            break;
        }
        case 'toggleFollowing':
            nuiPost('toggleFollowing');
            break;
        case 'setReady':
            nuiPost('setReady', {
                ready: el.dataset.ready != null ? el.dataset.ready === 'true' : !state.ready,
            });
            break;
        case 'requestHelp':
            nuiPost('requestHelp', { helpType: el.dataset.helpType || null });
            break;
        case 'voteNextStop':
            nuiPost('voteNextStop', { voted: el.dataset.voted === 'true' });
            break;
        case 'startElection':
            nuiPost('startElection', { candidateId: parseInt(el.dataset.candidateId, 10) });
            break;
        case 'castVote':
            nuiPost('castVote', { yes: el.dataset.yes === 'true' });
            break;
    }
}

function handleMenuClick(e) {
    const tabBtn = e.target.closest('[data-tab]');
    if (tabBtn) {
        e.preventDefault();
        activeTab = tabBtn.dataset.tab;
        if (activeTab === 'passengers' || activeTab === 'guide') {
            nuiPost('refreshPlayers');
        }
        renderContent();
        return;
    }

    const stopEl = e.target.closest('[data-stop]');
    if (stopEl && !stopEl.dataset.action) {
        selectedStopIndex = parseInt(stopEl.dataset.stop, 10);
        renderTourTab();
        return;
    }

    const el = e.target.closest('[data-action]');
    if (!el || el.disabled) return;

    const action = el.dataset.action;
    dispatchAction(action, el);
}

function handleMiniMenuClick(e) {
    const el = e.target.closest('[data-action]');
    if (!el || el.disabled) return;
    dispatchAction(el.dataset.action, el);
}

function handleMenuInput(e) {
    if (e.target.id === 'tour-search') {
        tourSearchQuery = e.target.value;
        renderTourTab();
        const input = document.getElementById('tour-search');
        if (input) {
            input.focus();
            input.setSelectionRange(input.value.length, input.value.length);
        }
        return;
    }
    if (e.target.id === 'anim-search') {
        animSearchQuery = e.target.value;
        renderAnimationsTab();
        const input = document.getElementById('anim-search');
        if (input) {
            input.focus();
            input.setSelectionRange(input.value.length, input.value.length);
        }
    }
}

menuPanelEl.addEventListener('click', handleMenuClick);
menuPanelEl.addEventListener('input', handleMenuInput);
if (miniMenuEl) {
    miniMenuEl.addEventListener('click', handleMiniMenuClick);
}
closeBtn.addEventListener('click', closeMenu);

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !menuEl.classList.contains('hidden')) {
        closeMenu();
    }
});

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'menu:init':
            handleInit(data);
            break;
        case 'menu:state':
            handleState(data);
            break;
        case 'miniMenu':
            if (data.state) {
                state = { ...state, ...data.state };
            }
            if (typeof data.enabled === 'boolean') {
                state.miniMenuEnabled = data.enabled;
            }
            if (data.corner) {
                state.miniMenuCorner = data.corner;
            }
            updateMiniMenu();
            break;
        case 'menu:open':
            openMenu();
            break;
        case 'menu:close':
            menuEl.classList.add('hidden');
            updateMiniMenu();
            break;
        case 'banner:b64':
            applyBannerBase64(data.data);
            break;
        case 'hud':
            if (data.state) {
                state = { ...state, ...data.state };
            }
            renderHud(data);
            updateMiniMenu();
            break;
        case 'l3Menu':
            if (typeof data.spawnModeEnabled === 'boolean') {
                state.spawnModeEnabled = data.spawnModeEnabled;
            }
            if (typeof data.spawnUndoCount === 'number') {
                state.spawnUndoCount = data.spawnUndoCount;
            }
            if (typeof data.tourActive === 'boolean') {
                state.tourActive = data.tourActive;
            }
            if (typeof data.isDrivingBus === 'boolean') {
                state.isDrivingBus = data.isDrivingBus;
            }
            if (data.variant) {
                state.l3MenuVariant = data.variant;
            }
            renderL3Menu(data);
            break;
    }
});

window.addEventListener('load', () => {
    loadBanner();
    nuiPost('nuiReady');
});
