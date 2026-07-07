// Main menu shell: tab routing, open/close, and full re-render.

function renderTabContent() {
    switch (activeTab) {
        case 'tour': renderTourTab(); break;
        case 'passengers': renderPassengersTab(); break;
        case 'my-tour': renderMyTourTab(); break;
        case 'guide': renderGuideTab(); break;
        case 'animations': renderAnimationsTab(); break;
        case 'chat': renderChatTab(); break;
        case 'appearance': renderAppearanceTab(); break;
        case 'settings': renderSettingsTab(); break;
        default: renderEmptyState('Unknown tab.', 'circle-question');
    }
}

function ensureValidActiveTab() {
    const tabs = getTabs();
    if (!tabs.some((tab) => tab.id === activeTab)) {
        activeTab = tabs[0].id;
    }
}

function renderContent() {
    ensureValidActiveTab();
    updateHeader();
    renderSidebar();
    renderQuickBar();
    renderTabContent();
}

function openMenu() {
    menuEl.classList.remove('hidden');
    updateMiniMenu();
    loadBanner(initData?.resource, initData?.bannerSrc);
    if (state.currentTourStopIndex > 0) {
        selectedStopIndex = state.currentTourStopIndex;
    }
    renderContent();
}

function closeMenu() {
    menuEl.classList.add('hidden');
    updateMiniMenu();
    nuiPost('closeMenu');
}
