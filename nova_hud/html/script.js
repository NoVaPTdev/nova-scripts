var hud = document.getElementById('hud');
var circumference = 2 * Math.PI * 15.9;
var locale = {};

var progressContainer = document.getElementById('progress-container');
var progressLabel = document.getElementById('progress-label');
var progressFill = document.getElementById('progress-bar-fill');
var progressTimer = null;

function setRing(id, pct) {
    var el = document.getElementById(id);
    if (!el) return;
    var offset = circumference - (pct / 100) * circumference;
    el.style.strokeDasharray = circumference;
    el.style.strokeDashoffset = offset;
}

function formatMoney(n) {
    if (n == null) n = 0;
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

function nuiCallback(name, data) {
    fetch('https://nova_hud/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

window.addEventListener('message', function (e) {
    var d = e.data;

    if (d.action === 'toggleHud') {
        if (d.locale) locale = d.locale;
        hud.style.display = d.visible ? 'block' : 'none';
        if (locale.on_duty) {
            document.getElementById('duty-badge').textContent = locale.on_duty;
        }
        return;
    }

    if (d.action === 'update') {
        setRing('fill-health', d.health || 0);
        setRing('fill-armor', d.armor || 0);
        setRing('fill-hunger', d.hunger || 0);
        setRing('fill-thirst', d.thirst || 0);

        document.getElementById('cash-value').textContent = '$' + formatMoney(d.cash);
        document.getElementById('bank-value').textContent = '$' + formatMoney(d.bank);
        document.getElementById('server-id').textContent = 'ID: ' + (d.serverId || 0);
        document.getElementById('job-label').textContent = d.job || locale.unemployed || 'Desempregado';

        var dutyBadge = document.getElementById('duty-badge');
        dutyBadge.style.display = d.onDuty ? 'inline' : 'none';

        var speedContainer = document.getElementById('speed-container');
        if (d.inVehicle) {
            speedContainer.style.display = 'block';
            document.getElementById('speed-value').textContent = d.speed || 0;
        } else {
            speedContainer.style.display = 'none';
        }

        var armorRing = document.getElementById('ring-armor');
        armorRing.style.opacity = (d.armor > 0) ? '1' : '0.3';
    }

    // ============================================================
    // PROGRESS BAR
    // ============================================================

    if (d.action === 'startProgress') {
        if (progressTimer) { clearInterval(progressTimer); progressTimer = null; }

        progressLabel.textContent = d.label || 'A processar...';
        progressFill.style.width = '0%';
        progressContainer.style.display = 'block';

        var duration = d.duration || 3000;
        var startTime = Date.now();

        progressTimer = setInterval(function () {
            var elapsed = Date.now() - startTime;
            var pct = Math.min((elapsed / duration) * 100, 100);
            progressFill.style.width = pct + '%';

            if (pct >= 100) {
                clearInterval(progressTimer);
                progressTimer = null;
                setTimeout(function () {
                    progressContainer.style.display = 'none';
                    progressFill.style.width = '0%';
                    nuiCallback('progressComplete', {});
                }, 200);
            }
        }, 50);
    }

    if (d.action === 'cancelProgress') {
        if (progressTimer) { clearInterval(progressTimer); progressTimer = null; }
        progressContainer.style.display = 'none';
        progressFill.style.width = '0%';
    }
});
