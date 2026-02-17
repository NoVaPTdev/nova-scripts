var shopType = null;
var categories = [];
var selectedCat = 0;
var tattooZones = [];
var tattooData = {};
var tattooLabels = {};
var activeTattooKeys = {};
var selectedZone = null;
var locale = {};

function nuiCallback(name, data, cb) {
    fetch('https://nova_shops/' + name, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    }).then(function(r) { return r.json(); }).then(function(r) { if (cb) cb(r); });
}

function closeShop() {
    nuiCallback('close');
}

function confirmPurchase() {
    nuiCallback('confirmPurchase');
}

function rotatePed(dir) {
    nuiCallback('rotatePed', { direction: dir });
}

// ============================================================
// NUI MESSAGES
// ============================================================

window.addEventListener('message', function(e) {
    var d = e.data;

    if (d.action === 'open') {
        locale = d.locale || {};
        shopType = d.shopType;

        if (shopType === 'general') {
            document.getElementById('shop-general').style.display = 'flex';
            document.getElementById('shop-customize').style.display = 'none';
            document.getElementById('general-title').textContent = d.shopLabel || locale.nui_shop || 'Loja';
            renderGeneralItems(d.items || []);
        } else {
            document.getElementById('shop-general').style.display = 'none';
            document.getElementById('shop-customize').style.display = 'flex';
            document.getElementById('custom-title').textContent = d.shopLabel || locale.nui_customize || 'Personalizar';
            document.getElementById('price-tag').innerHTML = (locale.nui_price || 'Preço') + ': <span>$' + (d.price || 0) + '</span>';

            if (shopType === 'clothing' || shopType === 'barber') {
                categories = normalizeArray(d.categories || []);
                selectedCat = 0;
                renderCategories();
                renderControls();
            } else if (shopType === 'tattoo') {
                tattooZones = d.zones || [];
                tattooData = d.tattoos || {};
                tattooLabels = d.zoneLabels || {};
                activeTattooKeys = {};
                if (d.activeTattoos) {
                    var at = normalizeArray(d.activeTattoos);
                    for (var i = 0; i < at.length; i++) {
                        if (at[i] && at[i].collName && at[i].ovlName) {
                            activeTattooKeys[at[i].collName + ':' + at[i].ovlName] = true;
                        }
                    }
                }
                selectedZone = tattooZones.length > 0 ? tattooZones[0] : null;
                renderTattooCategories();
                renderTattooList();
            }
        }
    }

    if (d.action === 'close') {
        document.getElementById('shop-general').style.display = 'none';
        document.getElementById('shop-customize').style.display = 'none';
        shopType = null;
    }
});

// Handle arrays from Lua (may come as 0-indexed arrays or string-keyed objects)
function normalizeArray(data) {
    if (Array.isArray(data)) return data;
    var arr = [];
    for (var key in data) {
        if (data.hasOwnProperty(key)) {
            arr.push(data[key]);
        }
    }
    return arr;
}

// ============================================================
// LOJA GERAL
// ============================================================

function renderGeneralItems(items) {
    var grid = document.getElementById('items-grid');
    grid.innerHTML = '';

    for (var i = 0; i < items.length; i++) {
        var item = items[i];
        var card = document.createElement('div');
        card.className = 'item-card';
        card.innerHTML =
            '<div class="item-icon">' + (item.icon || '📦') + '</div>' +
            '<div class="item-name">' + (item.label || item.name) + '</div>' +
            '<div class="item-price">$' + item.price + '</div>' +
            '<button class="item-buy" data-name="' + item.name + '">' + (locale.nui_buy || 'Comprar') + '</button>';
        grid.appendChild(card);
    }

    grid.querySelectorAll('.item-buy').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            nuiCallback('buyItem', { name: this.dataset.name, quantity: 1 });
        });
    });
}

// ============================================================
// ROUPA / BARBEIRO
// ============================================================

function renderCategories() {
    var list = document.getElementById('categories-list');
    list.innerHTML = '';

    for (var i = 0; i < categories.length; i++) {
        var cat = categories[i];
        var btn = document.createElement('button');
        btn.className = 'cat-btn' + (i === selectedCat ? ' active' : '');
        btn.textContent = cat.label;
        btn.dataset.index = i;
        btn.addEventListener('click', function() {
            selectedCat = parseInt(this.dataset.index);
            renderCategories();
            renderControls();
        });
        list.appendChild(btn);
    }
}

function renderControls() {
    var area = document.getElementById('controls-area');
    area.innerHTML = '';
    if (selectedCat < 0 || selectedCat >= categories.length) return;

    var cat = categories[selectedCat];

    if (cat.type === 'component' || (shopType === 'barber' && cat.type === 'component')) {
        area.innerHTML = buildNavRow(locale.nui_model || 'Modelo', cat.drawable, cat.maxDrawable, 'drawable') +
                         buildNavRow(locale.nui_texture || 'Textura', cat.texture, cat.maxTexture, 'texture');
    } else if (cat.type === 'prop') {
        area.innerHTML = buildNavRow(locale.nui_model || 'Modelo', cat.drawable, cat.maxDrawable, 'drawable') +
                         buildNavRow(locale.nui_texture || 'Textura', cat.texture, cat.maxTexture, 'texture');
    } else if (cat.type === 'overlay') {
        area.innerHTML = buildNavRow(locale.nui_style || 'Estilo', cat.value, cat.maxValue, 'value');
    } else if (cat.type === 'overlay_color' || cat.type === 'hair_color' || cat.type === 'hair_highlight') {
        area.innerHTML = buildNavRow(locale.nui_color || 'Cor', cat.value, cat.maxValue, 'value');
    }

    area.querySelectorAll('.btn-nav').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var prop = this.dataset.prop;
            var dir = parseInt(this.dataset.dir);
            changeValue(prop, dir);
        });
    });
}

function buildNavRow(label, current, max, prop) {
    return '<div class="control-row">' +
        '<span class="control-label">' + label + '</span>' +
        '<div class="control-nav">' +
            '<button class="btn-nav" data-prop="' + prop + '" data-dir="-1">&#60;</button>' +
            '<span class="control-value">' + current + ' / ' + Math.max(0, max) + '</span>' +
            '<button class="btn-nav" data-prop="' + prop + '" data-dir="1">&#62;</button>' +
        '</div>' +
    '</div>';
}

function changeValue(prop, dir) {
    var cat = categories[selectedCat];
    if (!cat) return;

    if (shopType === 'clothing') {
        if (prop === 'drawable') {
            var newD = cat.drawable + dir;
            if (cat.type === 'prop') {
                if (newD < -1) newD = cat.maxDrawable;
                if (newD > cat.maxDrawable) newD = -1;
            } else {
                if (newD < 0) newD = cat.maxDrawable;
                if (newD > cat.maxDrawable) newD = 0;
            }
            cat.drawable = newD;
            cat.texture = 0;

            var id = cat.type === 'component' ? cat.componentId : cat.propId;
            nuiCallback('changeClothing', {
                catType: cat.type, id: id, drawable: newD, texture: 0
            }, function(r) {
                if (r && r.maxTexture !== undefined) {
                    cat.maxTexture = r.maxTexture;
                }
                renderControls();
            });
        } else if (prop === 'texture') {
            var newT = cat.texture + dir;
            if (newT < 0) newT = cat.maxTexture;
            if (newT > cat.maxTexture) newT = 0;
            cat.texture = newT;

            var id2 = cat.type === 'component' ? cat.componentId : cat.propId;
            nuiCallback('changeClothing', {
                catType: cat.type, id: id2, drawable: cat.drawable, texture: newT
            });
            renderControls();
        }
    } else if (shopType === 'barber') {
        if (cat.type === 'component') {
            if (prop === 'drawable') {
                var newD2 = cat.drawable + dir;
                if (newD2 < 0) newD2 = cat.maxDrawable;
                if (newD2 > cat.maxDrawable) newD2 = 0;
                cat.drawable = newD2;
                cat.texture = 0;
                nuiCallback('changeBarber', {
                    catType: 'component', componentId: cat.componentId, drawable: newD2, texture: 0
                }, function(r) {
                    if (r && r.maxTexture !== undefined) cat.maxTexture = r.maxTexture;
                    renderControls();
                });
            } else if (prop === 'texture') {
                var newT2 = cat.texture + dir;
                if (newT2 < 0) newT2 = cat.maxTexture;
                if (newT2 > cat.maxTexture) newT2 = 0;
                cat.texture = newT2;
                nuiCallback('changeBarber', {
                    catType: 'component', componentId: cat.componentId, drawable: cat.drawable, texture: newT2
                });
                renderControls();
            }
        } else {
            var newV = cat.value + dir;
            if (newV < 0) newV = cat.maxValue;
            if (newV > cat.maxValue) newV = 0;
            cat.value = newV;

            nuiCallback('changeBarber', {
                catType: cat.type,
                overlayId: cat.overlayId,
                componentId: cat.componentId,
                value: newV
            });
            renderControls();
        }
    }
}

// ============================================================
// TATUAGENS
// ============================================================

function renderTattooCategories() {
    var list = document.getElementById('categories-list');
    list.innerHTML = '';

    for (var i = 0; i < tattooZones.length; i++) {
        var zone = tattooZones[i];
        var btn = document.createElement('button');
        btn.className = 'cat-btn' + (zone === selectedZone ? ' active' : '');
        btn.textContent = tattooLabels[zone] || zone;
        btn.dataset.zone = zone;
        btn.addEventListener('click', function() {
            selectedZone = this.dataset.zone;
            renderTattooCategories();
            renderTattooList();
        });
        list.appendChild(btn);
    }
}

function renderTattooList() {
    var area = document.getElementById('controls-area');
    area.innerHTML = '';

    if (!selectedZone || !tattooData[selectedZone]) {
        area.innerHTML = '<div style="padding:12px;color:rgba(255,255,255,0.4);font-size:12px;">' + (locale.nui_no_tattoos || 'Sem tatuagens disponíveis') + '</div>';
        return;
    }

    var tattoos = normalizeArray(tattooData[selectedZone]);
    var container = document.createElement('div');
    container.className = 'tattoo-list';

    for (var i = 0; i < tattoos.length; i++) {
        var tat = tattoos[i];
        var key = tat.collection + ':' + (tat.male || tat.female);
        var isActive = activeTattooKeys[key] || activeTattooKeys[tat.collection + ':' + tat.female] || false;

        var item = document.createElement('div');
        item.className = 'tattoo-item';
        item.innerHTML =
            '<span class="tattoo-name">' + tat.label + '</span>' +
            '<span class="tattoo-toggle' + (isActive ? ' active' : '') + '">' +
            (isActive ? '&#10003;' : '') + '</span>';

        item.dataset.collection = tat.collection;
        item.dataset.male = tat.male || '';
        item.dataset.female = tat.female || '';
        item.dataset.label = tat.label;

        item.addEventListener('click', function() {
            var el = this;
            nuiCallback('toggleTattoo', {
                collection: el.dataset.collection,
                male: el.dataset.male,
                female: el.dataset.female,
            }, function(r) {
                if (r && r.ok) {
                    var k1 = el.dataset.collection + ':' + el.dataset.male;
                    var k2 = el.dataset.collection + ':' + el.dataset.female;
                    if (r.active) {
                        activeTattooKeys[k1] = true;
                        activeTattooKeys[k2] = true;
                    } else {
                        delete activeTattooKeys[k1];
                        delete activeTattooKeys[k2];
                    }
                    renderTattooList();
                }
            });
        });

        container.appendChild(item);
    }

    area.appendChild(container);
}

// ============================================================
// TECLADO
// ============================================================

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeShop();
    }
});
