-- NOVA Chat - Locales (PT/EN)
local _lang = nil

local Strings = {
    pt = {
        unknown = 'Desconhecido',
        no_permission = 'Sem permissão.',
        announce = 'Anúncio',
        system = 'Sistema',
        console = 'Consola',
        welcome = 'Bem-vindo, %s! Usa T para abrir o chat.',
        player = 'Jogador',
        placeholder = 'Escreve uma mensagem...',
    },
    en = {
        unknown = 'Unknown',
        no_permission = 'No permission.',
        announce = 'Announcement',
        system = 'System',
        console = 'Console',
        welcome = 'Welcome, %s! Press T to open the chat.',
        player = 'Player',
        placeholder = 'Type a message...',
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

function ChatL(key, ...)
    local lang = GetLang()
    local str = (Strings[lang] and Strings[lang][key]) or Strings['pt'][key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function ChatGetAllStrings()
    local lang = GetLang()
    return Strings[lang] or Strings['pt']
end
