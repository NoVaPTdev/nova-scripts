CreateThread(function()
    while not exports['nova_core']:IsFrameworkReady() do Wait(100) end
end)

-- ============================================================
-- COMPRA DE ITENS (Lojas Gerais)
-- ============================================================

RegisterNetEvent('nova_shops:buyItem')
AddEventHandler('nova_shops:buyItem', function(itemName, quantity)
    local src = source
    quantity = tonumber(quantity) or 1
    if quantity <= 0 or quantity > 100 then return end

    local player = exports['nova_core']:GetPlayer(src)
    if not player then return end

    local itemPrice = nil
    local itemLabel = itemName

    for _, store in ipairs(ShopConfig.Stores) do
        if store.type == 'general' and store.items then
            for _, item in ipairs(store.items) do
                if item.name == itemName then
                    itemPrice = item.price
                    itemLabel = item.label or itemName
                    break
                end
            end
        end
        if itemPrice then break end
    end

    if not itemPrice then
        TriggerClientEvent('nova:client:notify', src, ShopL('item_unavailable'), 'error')
        return
    end

    local totalCost = itemPrice * quantity
    local cash = (player.money and player.money.cash) or 0

    if cash < totalCost then
        TriggerClientEvent('nova:client:notify', src, ShopL('not_enough_money', totalCost), 'error')
        return
    end

    local ok, result = pcall(function()
        return exports['nova_inventory']:AddItem(src, itemName, quantity)
    end)

    if not ok or not result then
        exports['nova_core']:RemovePlayerMoney(src, 'cash', totalCost)
        pcall(function()
            local p = exports['nova_core']:GetPlayer(src)
            if p then p:AddItem(itemName, quantity) end
        end)
    else
        exports['nova_core']:RemovePlayerMoney(src, 'cash', totalCost)
    end

    TriggerClientEvent('nova:client:notify', src, ShopL('bought_item', quantity, itemLabel, totalCost), 'success')
end)

-- ============================================================
-- GUARDAR APARÊNCIA (Roupas/Barbeiro/Tatuagens)
-- ============================================================

RegisterNetEvent('nova_shops:saveLook')
AddEventHandler('nova_shops:saveLook', function(skinData, shopType)
    local src = source
    local player = exports['nova_core']:GetPlayer(src)
    if not player then return end

    local price = ShopConfig.Prices[shopType] or 0
    local cash = (player.money and player.money.cash) or 0

    if cash < price then
        TriggerClientEvent('nova:client:notify', src, ShopL('not_enough_money', price), 'error')
        return
    end

    if price > 0 then
        exports['nova_core']:RemovePlayerMoney(src, 'cash', price)
    end

    exports['nova_core']:SetPlayerSkin(src, skinData)
    exports['nova_core']:SavePlayer(src)

    local labels = {
        clothing = ShopL('look_updated'),
        barber = ShopL('new_style'),
        tattoo = ShopL('tattoo_applied'),
    }
    TriggerClientEvent('nova:client:notify', src, labels[shopType] or ShopL('appearance_saved'), 'success')
end)
