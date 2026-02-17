local Nova = nil

CreateThread(function()
    while not exports['nova_core']:IsFrameworkReady() do Wait(100) end
    Nova = exports['nova_core']:GetObject()
end)

local function logTransaction(citizenid, txType, amount, targetCid, description)
    MySQL.Async.execute(
        'INSERT INTO nova_transactions (citizenid, type, amount, target_citizenid, description) VALUES (@cid, @type, @amount, @target, @desc)',
        { ['@cid'] = citizenid, ['@type'] = txType, ['@amount'] = amount, ['@target'] = targetCid, ['@desc'] = description or '' }
    )
end

local function getPlayerData(source)
    local player = exports['nova_core']:GetPlayer(source)
    if not player then return nil end

    local cash = (player.money and player.money.cash) or 0
    local bank = (player.money and player.money.bank) or 0
    local citizenid = player.citizenid
    local name = (player.charinfo and (player.charinfo.firstname .. ' ' .. player.charinfo.lastname)) or BankL('unknown')

    return { cash = cash, bank = bank, citizenid = citizenid, name = name, source = source }
end

-- ============================================================
-- CALLBACKS
-- ============================================================

exports['nova_core']:CreateCallback('nova_bank:getData', function(source, cb)
    local data = getPlayerData(source)
    if not data then cb(nil) return end

    local transactions = MySQL.Sync.fetchAll(
        'SELECT * FROM nova_transactions WHERE citizenid = @cid ORDER BY timestamp DESC LIMIT @limit',
        { ['@cid'] = data.citizenid, ['@limit'] = BankConfig.HistoryLimit }
    )

    cb({
        cash = data.cash,
        bank = data.bank,
        name = data.name,
        transactions = transactions or {},
    })
end)

-- ============================================================
-- OPERAÇÕES
-- ============================================================

RegisterNetEvent('nova_bank:deposit')
AddEventHandler('nova_bank:deposit', function(amount)
    local src = source
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    local data = getPlayerData(src)
    if not data then return end

    if data.cash < amount then
        TriggerClientEvent('nova:client:notify', src, BankL('not_enough_cash'), 'error')
        return
    end

    exports['nova_core']:RemovePlayerMoney(src, 'cash', amount)
    exports['nova_core']:AddPlayerMoney(src, 'bank', amount)
    logTransaction(data.citizenid, 'deposit', amount, nil, BankL('deposit_desc'))
    TriggerClientEvent('nova_bank:refresh', src)
end)

RegisterNetEvent('nova_bank:withdraw')
AddEventHandler('nova_bank:withdraw', function(amount)
    local src = source
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    local data = getPlayerData(src)
    if not data then return end

    if data.bank < amount then
        TriggerClientEvent('nova:client:notify', src, BankL('not_enough_bank'), 'error')
        return
    end

    exports['nova_core']:RemovePlayerMoney(src, 'bank', amount)
    exports['nova_core']:AddPlayerMoney(src, 'cash', amount)
    logTransaction(data.citizenid, 'withdraw', amount, nil, BankL('withdraw_desc'))
    TriggerClientEvent('nova_bank:refresh', src)
end)

RegisterNetEvent('nova_bank:transfer')
AddEventHandler('nova_bank:transfer', function(targetId, amount)
    local src = source
    amount = tonumber(amount)
    targetId = tonumber(targetId)
    if not amount or amount <= 0 or not targetId then return end

    if amount > BankConfig.TransferLimit then
        TriggerClientEvent('nova:client:notify', src, BankL('transfer_limit', BankConfig.TransferLimit), 'error')
        return
    end

    local data = getPlayerData(src)
    if not data then return end

    if data.bank < amount then
        TriggerClientEvent('nova:client:notify', src, BankL('not_enough_bank'), 'error')
        return
    end

    local targetData = getPlayerData(targetId)
    if not targetData then
        TriggerClientEvent('nova:client:notify', src, BankL('player_not_found'), 'error')
        return
    end

    if src == targetId then
        TriggerClientEvent('nova:client:notify', src, BankL('self_transfer'), 'error')
        return
    end

    exports['nova_core']:RemovePlayerMoney(src, 'bank', amount)
    exports['nova_core']:AddPlayerMoney(targetId, 'bank', amount)

    logTransaction(data.citizenid, 'transfer_out', amount, targetData.citizenid, BankL('transfer_to', targetData.name))
    logTransaction(targetData.citizenid, 'transfer_in', amount, data.citizenid, BankL('transfer_from', data.name))

    TriggerClientEvent('nova:client:notify', src, BankL('transfer_sent', amount, targetData.name), 'success')
    TriggerClientEvent('nova:client:notify', targetId, BankL('transfer_received', amount, data.name), 'success')
    TriggerClientEvent('nova_bank:refresh', src)
end)
