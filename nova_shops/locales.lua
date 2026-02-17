-- NOVA Shops - Locales (PT/EN)
local _lang = nil

local Strings = {
    pt = {
        item_unavailable = 'Item não disponível.',
        not_enough_money = 'Não tens dinheiro suficiente. Precisas de $%s',
        bought_item = 'Compraste %sx %s por $%s',
        look_updated = 'Look atualizado!',
        new_style = 'Novo estilo!',
        tattoo_applied = 'Tatuagem aplicada!',
        appearance_saved = 'Aparência guardada!',
        -- NUI
        nui_shop = 'Loja',
        nui_customize = 'Personalizar',
        nui_price = 'Preço',
        nui_buy = 'Comprar',
        nui_model = 'Modelo',
        nui_texture = 'Textura',
        nui_style = 'Estilo',
        nui_color = 'Cor',
        nui_no_tattoos = 'Sem tatuagens disponíveis',
        nui_confirm = 'Confirmar',
        nui_cancel = 'Cancelar',
        nui_rotate_left = 'Rodar Esquerda',
        nui_rotate_right = 'Rodar Direita',
        -- Tattoo zones
        zone_head = 'Cabeça',
        zone_torso = 'Torso',
        zone_left_arm = 'Braço Esquerdo',
        zone_right_arm = 'Braço Direito',
        zone_left_leg = 'Perna Esquerda',
        zone_right_leg = 'Perna Direita',
    },
    en = {
        item_unavailable = 'Item not available.',
        not_enough_money = 'You don\'t have enough money. You need $%s',
        bought_item = 'You bought %sx %s for $%s',
        look_updated = 'Look updated!',
        new_style = 'New style!',
        tattoo_applied = 'Tattoo applied!',
        appearance_saved = 'Appearance saved!',
        nui_shop = 'Shop',
        nui_customize = 'Customize',
        nui_price = 'Price',
        nui_buy = 'Buy',
        nui_model = 'Model',
        nui_texture = 'Texture',
        nui_style = 'Style',
        nui_color = 'Color',
        nui_no_tattoos = 'No tattoos available',
        nui_confirm = 'Confirm',
        nui_cancel = 'Cancel',
        nui_rotate_left = 'Rotate Left',
        nui_rotate_right = 'Rotate Right',
        zone_head = 'Head',
        zone_torso = 'Torso',
        zone_left_arm = 'Left Arm',
        zone_right_arm = 'Right Arm',
        zone_left_leg = 'Left Leg',
        zone_right_leg = 'Right Leg',
    },
}

local function GetLang()
    if _lang then return _lang end
    _lang = 'pt'
    pcall(function()
        local cfg = exports['nova_core']:GetConfig()
        if cfg and cfg.Locale then _lang = cfg.Locale end
    end)
    return _lang
end

function ShopL(key, ...)
    local lang = GetLang()
    local str = (Strings[lang] and Strings[lang][key]) or Strings['pt'][key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function ShopGetAllStrings()
    local lang = GetLang()
    return Strings[lang] or Strings['pt']
end

ShopStrings = Strings
