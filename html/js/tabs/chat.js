// Chat tab content.

function renderChatTab() {
    if (!initData?.chat) {
        renderEmptyState('Loading chat messages…', 'circle-notch', true);
        return;
    }

    const cards = [
        { id: 'welcome', title: 'Welcome', icon: 'hand-sparkles', preview: initData.chat.welcome },
        { id: 'rules', title: 'Rules', icon: 'list-check', preview: initData.chat.rulesPreview },
        { id: 'invite', title: 'Invite', icon: 'bullhorn', preview: initData.chat.invite },
        { id: 'thankyou', title: 'Thank You', icon: 'heart', preview: initData.chat.thankyou },
    ];

    contentEl.innerHTML = cards.map((c) =>
        `<div class="chat-card" data-action="sendChat" data-chat="${c.id}">
            <div class="chat-card-header">
                ${icon(c.icon, 'chat-card-icon')}
                <div class="chat-card-title">${escapeHtml(c.title)}</div>
            </div>
            <div class="chat-card-preview">${escapeHtml(c.preview)}</div>
        </div>`
    ).join('');
}
