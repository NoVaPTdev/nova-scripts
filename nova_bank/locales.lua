-- NOVA Bank - Locales (PT/EN)
local _lang = nil

local Strings = {
    pt = {
        unknown = 'Desconhecido',
        not_enough_cash = 'Não tens dinheiro suficiente.',
        not_enough_bank = 'Saldo insuficiente no banco.',
        transfer_limit = 'Limite máximo de transferência: $%s',
        player_not_found = 'Jogador não encontrado.',
        self_transfer = 'Não podes transferir para ti mesmo.',
        transfer_sent = 'Transferiste $%s para %s',
        transfer_received = 'Recebeste $%s de %s',
        deposit_desc = 'Depósito em dinheiro',
        withdraw_desc = 'Levantamento de dinheiro',
        transfer_to = 'Transferência para %s',
        transfer_from = 'Transferência de %s',
        -- NUI
        nui_hello = 'Olá, %s',
        nui_bank_account = 'Conta Bancária',
        nui_cash = 'Dinheiro',
        nui_deposit = 'Depositar',
        nui_withdraw = 'Levantar',
        nui_transfer = 'Transferir',
        nui_history = 'Histórico',
        nui_deposit_amount = 'Valor a depositar',
        nui_withdraw_amount = 'Valor a levantar',
        nui_player_id = 'ID do Jogador',
        nui_amount = 'Valor',
        nui_no_transactions = 'Sem transações',
        nui_tx_deposit = 'Depósito',
        nui_tx_withdraw = 'Levantamento',
        nui_tx_transfer_in = 'Recebido',
        nui_tx_transfer_out = 'Enviado',
        nui_open_bank = '[E] Abrir Banco',
        nui_use_atm = '[E] Usar ATM',
    },
    en = {
        unknown = 'Unknown',
        not_enough_cash = 'You don\'t have enough cash.',
        not_enough_bank = 'Insufficient bank balance.',
        transfer_limit = 'Maximum transfer limit: $%s',
        player_not_found = 'Player not found.',
        self_transfer = 'You can\'t transfer to yourself.',
        transfer_sent = 'You transferred $%s to %s',
        transfer_received = 'You received $%s from %s',
        deposit_desc = 'Cash deposit',
        withdraw_desc = 'Cash withdrawal',
        transfer_to = 'Transfer to %s',
        transfer_from = 'Transfer from %s',
        nui_hello = 'Hello, %s',
        nui_bank_account = 'Bank Account',
        nui_cash = 'Cash',
        nui_deposit = 'Deposit',
        nui_withdraw = 'Withdraw',
        nui_transfer = 'Transfer',
        nui_history = 'History',
        nui_deposit_amount = 'Amount to deposit',
        nui_withdraw_amount = 'Amount to withdraw',
        nui_player_id = 'Player ID',
        nui_amount = 'Amount',
        nui_no_transactions = 'No transactions',
        nui_tx_deposit = 'Deposit',
        nui_tx_withdraw = 'Withdrawal',
        nui_tx_transfer_in = 'Received',
        nui_tx_transfer_out = 'Sent',
        nui_open_bank = '[E] Open Bank',
        nui_use_atm = '[E] Use ATM',
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

function BankL(key, ...)
    local lang = GetLang()
    local str = (Strings[lang] and Strings[lang][key]) or Strings['pt'][key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function BankGetAllStrings()
    local lang = GetLang()
    return Strings[lang] or Strings['pt']
end
