var characters = [];
var maxChars = 3;
var selectedGender = 0;
var locale = {};

function applyLocale() {
    var m = {
        'i18n-subtitle': 'nui_subtitle',
        'i18n-create-title': 'nui_create_char',
        'i18n-lbl-firstname': 'nui_firstname',
        'i18n-lbl-lastname': 'nui_lastname',
        'i18n-lbl-dob': 'nui_dob',
        'i18n-lbl-nationality': 'nui_nationality',
        'i18n-lbl-gender': 'nui_gender',
        'i18n-male': 'nui_male',
        'i18n-female': 'nui_female',
        'i18n-back-select': 'nui_back',
        'i18n-go-appearance': 'nui_next_appearance',
        'i18n-appearance-title': 'nui_appearance',
        'i18n-tab-face': 'nui_tab_face',
        'i18n-tab-hair': 'nui_tab_hair',
        'i18n-tab-clothes': 'nui_tab_clothes',
        'i18n-mother': 'nui_mother',
        'i18n-father': 'nui_father',
        'i18n-resemblance': 'nui_resemblance',
        'i18n-skin-tone': 'nui_skin_tone',
        'i18n-eyebrows': 'nui_eyebrows',
        'i18n-hair': 'nui_hair',
        'i18n-hair-color': 'nui_hair_color',
        'i18n-beard': 'nui_beard',
        'i18n-beard-color': 'nui_beard_color',
        'i18n-shirt': 'nui_shirt',
        'i18n-undershirt': 'nui_undershirt',
        'i18n-pants': 'nui_pants',
        'i18n-shoes': 'nui_shoes',
        'i18n-back-create': 'nui_back',
        'i18n-finish': 'nui_create_btn',
    };
    for (var id in m) {
        var el = document.getElementById(id);
        if (el && locale[m[id]]) {
            el.textContent = locale[m[id]];
        }
    }
    // Update placeholders
    var fn = document.getElementById('inp-firstname');
    if (fn && locale.nui_firstname) fn.placeholder = locale.nui_firstname;
    var ln = document.getElementById('inp-lastname');
    if (ln && locale.nui_lastname) ln.placeholder = locale.nui_lastname;
    var dob = document.getElementById('inp-dob');
    if (dob && locale.nui_dob_placeholder) dob.placeholder = locale.nui_dob_placeholder;
    var nat = document.getElementById('inp-nationality');
    if (nat && locale.nui_nationality) nat.placeholder = locale.nui_nationality;
}

function nuiCallback(name, data, cb) {
    fetch('https://nova_multichar/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    }).then(function (r) { return r.json(); }).then(function (r) { if (cb) cb(r); });
}

function showScreen(id) {
    document.getElementById('select-screen').style.display = 'none';
    document.getElementById('create-screen').style.display = 'none';
    document.getElementById('appearance-screen').style.display = 'none';
    document.getElementById(id).style.display = id === 'select-screen' ? 'flex' : 'block';
}

function renderCharacters(chars) {
    characters = chars || [];
    var list = document.getElementById('char-list');
    list.innerHTML = '';

    chars.forEach(function (c) {
        var card = document.createElement('div');
        card.className = 'char-card';
        var initial = (c.firstname || 'N').charAt(0).toUpperCase();
        var money = '$' + formatMoney(c.cash || 0);
        var jobLabel = c.job_label || c.job || locale.nui_unemployed || 'Desempregado';

        card.innerHTML =
            '<div class="char-avatar">' + initial + '</div>' +
            '<div class="char-name">' + (c.firstname || '') + ' ' + (c.lastname || '') + '</div>' +
            '<div class="char-job">' + jobLabel + '</div>' +
            '<div class="char-money">' + money + '</div>' +
            '<button class="delete-btn" data-cid="' + c.citizenid + '">' + (locale.nui_delete || 'Eliminar') + '</button>';

        card.addEventListener('click', function (e) {
            if (e.target.classList.contains('delete-btn')) return;
            nuiCallback('selectCharacter', { citizenid: c.citizenid });
        });

        card.querySelector('.delete-btn').addEventListener('click', function (e) {
            e.stopPropagation();
            if (confirm(locale.nui_confirm_delete || 'Tens a certeza que queres eliminar este personagem?')) {
                nuiCallback('deleteCharacter', { citizenid: c.citizenid }, function (res) {
                    if (res && res.ok) renderCharacters(res.characters);
                });
            }
        });

        list.appendChild(card);
    });

    if (chars.length < maxChars) {
        var createCard = document.createElement('div');
        createCard.className = 'char-card create-new';
        createCard.innerHTML = '<div class="create-icon">+</div><div class="char-name">' + (locale.nui_create_new || 'Criar Novo') + '</div>';
        createCard.addEventListener('click', function () {
            showScreen('create-screen');
            selectedGender = 0;
            updateGenderButtons();
            nuiCallback('startCreation', { gender: 0 });
        });
        list.appendChild(createCard);
    }
}

function formatMoney(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

function updateGenderButtons() {
    document.querySelectorAll('.gender-btn').forEach(function (btn) {
        btn.classList.toggle('active', parseInt(btn.dataset.gender) === selectedGender);
    });
}

// Género
document.querySelectorAll('.gender-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
        selectedGender = parseInt(btn.dataset.gender);
        updateGenderButtons();
        nuiCallback('changeGender', { gender: selectedGender });
    });
});

// Voltar da criação para seleção
document.getElementById('i18n-back-select').addEventListener('click', function () {
    showScreen('select-screen');
    nuiCallback('cancelCreation', {}, function (res) {
        if (res && res.ok) renderCharacters(res.characters);
    });
});

// Ir para aparência
document.getElementById('i18n-go-appearance').addEventListener('click', function () {
    var fn = document.getElementById('inp-firstname').value.trim();
    var ln = document.getElementById('inp-lastname').value.trim();
    if (!fn || !ln) { alert(locale.nui_fill_name || 'Preenche o nome e apelido.'); return; }
    showScreen('appearance-screen');
});

// Voltar da aparência para criação
document.getElementById('i18n-back-create').addEventListener('click', function () {
    showScreen('create-screen');
});

// Tabs
document.querySelectorAll('.tab').forEach(function (tab) {
    tab.addEventListener('click', function () {
        document.querySelectorAll('.tab').forEach(function (t) { t.classList.remove('active'); });
        document.querySelectorAll('.tab-content').forEach(function (c) { c.classList.remove('active'); });
        tab.classList.add('active');
        document.getElementById('tab-' + tab.dataset.tab).classList.add('active');
    });
});

// Sliders de aparência
var sliderMap = {
    'sl-mom': 'mom', 'sl-dad': 'dad',
    'sl-shapemix': null, 'sl-skinmix': null,
    'sl-eyebrows': 'eyebrows',
    'sl-hair': 'hair', 'sl-haircolor': 'hairColor',
    'sl-beard': 'beard', 'sl-beardcolor': 'beardColor',
    'sl-torso': 'torso', 'sl-undershirt': 'undershirt',
    'sl-legs': 'legs', 'sl-shoes': 'shoes'
};

Object.keys(sliderMap).forEach(function (id) {
    var el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('input', function () {
        var data = {};
        if (id === 'sl-shapemix') { data.shapeMix = parseInt(el.value) / 100; }
        else if (id === 'sl-skinmix') { data.skinMix = parseInt(el.value) / 100; }
        else { data[sliderMap[id]] = parseInt(el.value); }
        nuiCallback('updateAppearance', data);
    });
});

// Rodar ped
document.getElementById('btn-rotate-left').addEventListener('click', function () {
    nuiCallback('rotatePed', { direction: -30 });
});
document.getElementById('btn-rotate-right').addEventListener('click', function () {
    nuiCallback('rotatePed', { direction: 30 });
});

// Terminar criação
document.getElementById('i18n-finish').addEventListener('click', function () {
    var fn = document.getElementById('inp-firstname').value.trim();
    var ln = document.getElementById('inp-lastname').value.trim();
    var dob = document.getElementById('inp-dob').value.trim() || '01/01/2000';
    var nat = document.getElementById('inp-nationality').value.trim() || locale.nui_nationality_default || 'Desconhecida';

    nuiCallback('finishCreation', {
        firstname: fn, lastname: ln,
        dateofbirth: dob, nationality: nat
    });
});

// Escutar mensagens do client
window.addEventListener('message', function (e) {
    var d = e.data;
    if (d.action === 'open') {
        locale = d.locale || {};
        applyLocale();
        document.getElementById('app').style.display = 'flex';
        maxChars = d.maxCharacters || 3;
        showScreen('select-screen');
        renderCharacters(d.characters || []);
        // Reset form
        document.getElementById('inp-firstname').value = '';
        document.getElementById('inp-lastname').value = '';
        document.getElementById('inp-dob').value = '';
        document.getElementById('inp-nationality').value = locale.nui_nationality_default || 'Portuguesa';
    }
    if (d.action === 'close') {
        document.getElementById('app').style.display = 'none';
    }
});
