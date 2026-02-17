var messages = document.getElementById('chat-messages');
var inputArea = document.getElementById('chat-input-area');
var input = document.getElementById('chat-input');
var container = document.getElementById('chat-container');
var maxMessages = 80;

function nuiCallback(name, data) {
    fetch('https://nova_chat/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

// ============================================================
// MENSAGENS
// ============================================================

function addMessage(data) {
    var msg = document.createElement('div');
    msg.className = 'chat-msg';
    if (data.msgType) msg.classList.add('type-' + data.msgType);

    var html = '';

    if (data.authorId) {
        html += '<span class="msg-id">[' + data.authorId + ']</span>';
    }

    if (data.author) {
        html += '<span class="msg-author" style="color:' + (data.color || '#e0e0e0') + '">' + escapeHtml(data.author) + ':</span>';
    }

    html += '<span class="msg-text">' + escapeHtml(data.message) + '</span>';
    msg.innerHTML = html;

    messages.appendChild(msg);

    // Limitar número de mensagens
    while (messages.children.length > maxMessages) {
        messages.removeChild(messages.firstChild);
    }

    // Scroll para baixo
    messages.scrollTop = messages.scrollHeight;
}

function escapeHtml(text) {
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// ============================================================
// INPUT
// ============================================================

input.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        var msg = input.value.trim();
        input.value = '';
        nuiCallback('sendMessage', { message: msg });
    }
    if (e.key === 'Escape') {
        e.preventDefault();
        input.value = '';
        nuiCallback('cancelInput');
    }
    e.stopPropagation();
});

// Prevenir que teclas passem para o jogo
input.addEventListener('keyup', function(e) { e.stopPropagation(); });
input.addEventListener('keypress', function(e) { e.stopPropagation(); });

// ============================================================
// NUI MESSAGES
// ============================================================

window.addEventListener('message', function(e) {
    var d = e.data;

    if (d.action === 'addMessage') {
        container.classList.remove('faded');
        addMessage(d);
    }

    if (d.action === 'openInput') {
        container.classList.remove('faded');
        inputArea.style.display = 'block';
        input.value = '';
        input.focus();
    }

    if (d.action === 'closeInput') {
        inputArea.style.display = 'none';
        input.blur();
    }

    if (d.action === 'showChat') {
        container.classList.remove('faded');
    }

    if (d.action === 'fadeChat') {
        container.classList.add('faded');
    }

    if (d.action === 'clearMessages') {
        messages.innerHTML = '';
    }
});
