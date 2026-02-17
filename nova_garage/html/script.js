var garageEl = document.getElementById('garage');
var garageType = 'normal';
var impoundPrice = 500;
var locale = {};

function nuiCallback(name, data, cb) {
    fetch('https://nova_garage/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    }).then(function (r) { return r.json(); }).then(function (r) { if (cb) cb(r); });
}

function renderVehicles(vehicles) {
    var list = document.getElementById('vehicle-list');
    if (!vehicles || vehicles.length === 0) {
        list.innerHTML = '<div class="empty-msg">' + (locale.nui_no_vehicles || 'Nenhum veículo encontrado.') + '</div>';
        return;
    }

    list.innerHTML = '';
    vehicles.forEach(function (v) {
        var card = document.createElement('div');
        card.className = 'vehicle-card';

        var stateClass = 'status-out';
        var stateLabel = locale.nui_state_out || 'Fora';
        var actionHtml = '';

        if (v.state === 1) {
            stateClass = 'status-stored';
            stateLabel = locale.nui_state_stored || 'Guardado';
            actionHtml = '<button class="vehicle-action btn-takeout" data-id="' + v.id + '">' + (locale.nui_take_out || 'Retirar') + '</button>';
        } else if (v.state === 2) {
            stateClass = 'status-impound';
            stateLabel = locale.nui_state_impounded || 'Apreendido';
            if (garageType === 'impound') {
                actionHtml = '<button class="vehicle-action btn-recover" data-id="' + v.id + '">' + (locale.nui_recover || 'Recuperar') + ' ($' + impoundPrice + ')</button>';
            } else {
                actionHtml = '<button class="vehicle-action btn-disabled" disabled>' + (locale.nui_state_impounded || 'Apreendido') + '</button>';
            }
        } else {
            actionHtml = '<button class="vehicle-action btn-disabled" disabled>' + (locale.nui_state_out || 'Fora') + '</button>';
        }

        var fuel = Math.floor(v.fuel || 0);
        var engine = Math.floor((v.engine || 0) / 10);
        var body = Math.floor((v.body || 0) / 10);

        card.innerHTML =
            '<div class="vehicle-icon">🚗</div>' +
            '<div class="vehicle-info">' +
                '<div class="vehicle-name">' + (v.vehicle || locale.nui_unknown || 'Desconhecido') + '</div>' +
                '<div class="vehicle-plate">' +
                    '<span class="vehicle-status ' + stateClass + '"></span> ' +
                    v.plate + ' • ' + stateLabel +
                '</div>' +
                '<div class="vehicle-stats">' +
                    '<span class="vehicle-stat">⛽ ' + fuel + '%</span>' +
                    '<span class="vehicle-stat">⚙ ' + engine + '%</span>' +
                    '<span class="vehicle-stat">🛡 ' + body + '%</span>' +
                '</div>' +
            '</div>' +
            actionHtml;

        list.appendChild(card);
    });

    // Event listeners para botões
    document.querySelectorAll('.btn-takeout').forEach(function (btn) {
        btn.addEventListener('click', function () {
            nuiCallback('takeOut', { vehicleId: parseInt(btn.dataset.id) });
        });
    });
    document.querySelectorAll('.btn-recover').forEach(function (btn) {
        btn.addEventListener('click', function () {
            nuiCallback('recoverImpound', { vehicleId: parseInt(btn.dataset.id) });
        });
    });
}

document.getElementById('btn-close').addEventListener('click', function () {
    nuiCallback('close');
});

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') nuiCallback('close');
});

window.addEventListener('message', function (e) {
    var d = e.data;
    if (d.action === 'open') {
        garageEl.style.display = 'flex';
        garageType = d.garageType || 'normal';
        locale = d.locale || {};
        impoundPrice = d.impoundPrice || 500;
        document.getElementById('garage-name').textContent = d.garageName || locale.nui_garage || 'Garagem';
        renderVehicles(d.vehicles || []);
    }
    if (d.action === 'close') {
        garageEl.style.display = 'none';
    }
});
