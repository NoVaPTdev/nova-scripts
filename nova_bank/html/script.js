var bankEl = document.getElementById('bank');
var locale = {};

function applyBankLocale() {
    var m = {
        'i18n-bank-label': 'nui_bank_account',
        'i18n-cash-label': 'nui_cash',
        'i18n-tab-deposit': 'nui_deposit',
        'i18n-tab-withdraw': 'nui_withdraw',
        'i18n-tab-transfer': 'nui_transfer',
        'i18n-tab-history': 'nui_history',
        'i18n-deposit-label': 'nui_deposit_amount',
        'i18n-btn-deposit': 'nui_deposit',
        'i18n-withdraw-label': 'nui_withdraw_amount',
        'i18n-btn-withdraw': 'nui_withdraw',
        'i18n-player-id-label': 'nui_player_id',
        'i18n-amount-label': 'nui_amount',
        'i18n-btn-transfer': 'nui_transfer',
        'i18n-no-tx': 'nui_no_transactions',
    };
    for (var id in m) {
        var el = document.getElementById(id);
        if (el && locale[m[id]]) {
            el.textContent = locale[m[id]];
        }
    }
}

function nuiCallback(name, data, cb) {
    fetch('https://nova_bank/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    }).then(function (r) { return r.json(); }).then(function (r) { if (cb) cb(r); });
}

function formatMoney(n) {
    if (n == null) n = 0;
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

function updateBalances(cash, bank) {
    document.getElementById('val-cash').textContent = '$' + formatMoney(cash);
    document.getElementById('val-bank').textContent = '$' + formatMoney(bank);
}

function renderHistory(transactions) {
    var list = document.getElementById('history-list');
    if (!transactions || transactions.length === 0) {
        list.innerHTML = '<div class="history-empty">' + (locale.nui_no_transactions || 'Sem transações') + '</div>';
        return;
    }

    list.innerHTML = '';
    transactions.forEach(function (tx) {
        var item = document.createElement('div');
        item.className = 'history-item';

        var typeLabels = { deposit: locale.nui_tx_deposit || 'Depósito', withdraw: locale.nui_tx_withdraw || 'Levantamento', transfer_in: locale.nui_tx_transfer_in || 'Recebido', transfer_out: locale.nui_tx_transfer_out || 'Enviado' };
        var isPositive = tx.type === 'deposit' || tx.type === 'transfer_in';
        var sign = isPositive ? '+' : '-';
        var dateStr = tx.timestamp ? new Date(tx.timestamp).toLocaleDateString() : '';

        item.innerHTML =
            '<div class="history-info">' +
                '<div class="history-type">' + (typeLabels[tx.type] || tx.type) + '</div>' +
                '<div class="history-desc">' + (tx.description || '') + '</div>' +
            '</div>' +
            '<div style="text-align:right">' +
                '<div class="history-amount ' + (isPositive ? 'positive' : 'negative') + '">' + sign + '$' + formatMoney(tx.amount) + '</div>' +
                '<div class="history-date">' + dateStr + '</div>' +
            '</div>';

        list.appendChild(item);
    });
}

// TABS
document.querySelectorAll('.bank-tab').forEach(function (tab) {
    tab.addEventListener('click', function () {
        document.querySelectorAll('.bank-tab').forEach(function (t) { t.classList.remove('active'); });
        document.querySelectorAll('.tab-panel').forEach(function (p) { p.classList.remove('active'); });
        tab.classList.add('active');
        document.getElementById('panel-' + tab.dataset.tab).classList.add('active');
    });
});

// AÇÕES
document.getElementById('i18n-btn-deposit').addEventListener('click', function () {
    var amount = parseInt(document.getElementById('inp-deposit').value);
    if (!amount || amount <= 0) return;
    nuiCallback('deposit', { amount: amount });
    document.getElementById('inp-deposit').value = '';
});

document.getElementById('i18n-btn-withdraw').addEventListener('click', function () {
    var amount = parseInt(document.getElementById('inp-withdraw').value);
    if (!amount || amount <= 0) return;
    nuiCallback('withdraw', { amount: amount });
    document.getElementById('inp-withdraw').value = '';
});

document.getElementById('i18n-btn-transfer').addEventListener('click', function () {
    var targetId = parseInt(document.getElementById('inp-target').value);
    var amount = parseInt(document.getElementById('inp-transfer-amount').value);
    if (!targetId || !amount || amount <= 0) return;
    nuiCallback('transfer', { targetId: targetId, amount: amount });
    document.getElementById('inp-target').value = '';
    document.getElementById('inp-transfer-amount').value = '';
});

document.getElementById('btn-close').addEventListener('click', function () {
    nuiCallback('close');
});

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') nuiCallback('close');
});

// NUI Messages
window.addEventListener('message', function (e) {
    var d = e.data;
    if (d.action === 'open') {
        bankEl.style.display = 'flex';
        locale = d.locale || {};
        applyBankLocale();
        document.getElementById('bank-user').textContent = (locale.nui_hello || 'Olá, %s').replace('%s', d.name || 'Jogador');
        updateBalances(d.cash || 0, d.bank || 0);
        renderHistory(d.transactions);
        // Reset to first tab
        document.querySelectorAll('.bank-tab')[0].click();
    }
    if (d.action === 'close') {
        bankEl.style.display = 'none';
    }
    if (d.action === 'refresh') {
        updateBalances(d.cash || 0, d.bank || 0);
        renderHistory(d.transactions);
    }
});
