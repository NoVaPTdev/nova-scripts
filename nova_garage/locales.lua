-- NOVA Garage - Locales (PT/EN)
local _lang = nil

local Strings = {
    pt = {
        vehicle_not_found = 'Veículo não encontrado.',
        vehicle_already_out = 'O veículo já está fora da garagem.',
        vehicle_stored = 'Veículo guardado na garagem.',
        vehicle_taken = 'Veículo retirado da garagem.',
        model_not_found = 'Modelo não encontrado.',
        not_enough_money = 'Precisas de $%s para recuperar.',
        impound_recovered = 'Veículo recuperado! Pagaste $%s',
        -- NUI
        nui_garage = 'Garagem',
        nui_no_vehicles = 'Nenhum veículo encontrado.',
        nui_take_out = 'Retirar',
        nui_recover = 'Recuperar',
        nui_unknown = 'Desconhecido',
        nui_state_stored = 'Guardado',
        nui_state_out = 'Fora',
        nui_state_impounded = 'Apreendido',
        nui_open_garage = '[E] %s',
    },
    en = {
        vehicle_not_found = 'Vehicle not found.',
        vehicle_already_out = 'The vehicle is already out of the garage.',
        vehicle_stored = 'Vehicle stored in the garage.',
        vehicle_taken = 'Vehicle taken from the garage.',
        model_not_found = 'Model not found.',
        not_enough_money = 'You need $%s to recover.',
        impound_recovered = 'Vehicle recovered! You paid $%s',
        nui_garage = 'Garage',
        nui_no_vehicles = 'No vehicles found.',
        nui_take_out = 'Take Out',
        nui_recover = 'Recover',
        nui_unknown = 'Unknown',
        nui_state_stored = 'Stored',
        nui_state_out = 'Out',
        nui_state_impounded = 'Impounded',
        nui_open_garage = '[E] %s',
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

function GarageL(key, ...)
    local lang = GetLang()
    local str = (Strings[lang] and Strings[lang][key]) or Strings['pt'][key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function GarageGetAllStrings()
    local lang = GetLang()
    return Strings[lang] or Strings['pt']
end
