-- NOVA HUD - Locales (PT/EN)
local _lang = nil

local Strings = {
    pt = {
        unemployed = 'Desempregado',
        on_duty = 'EM SERVIÇO',
        processing = 'A processar...',
    },
    en = {
        unemployed = 'Unemployed',
        on_duty = 'ON DUTY',
        processing = 'Processing...',
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

function HudL(key, ...)
    local lang = GetLang()
    local str = (Strings[lang] and Strings[lang][key]) or Strings['pt'][key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function HudGetAllStrings()
    local lang = GetLang()
    return Strings[lang] or Strings['pt']
end
