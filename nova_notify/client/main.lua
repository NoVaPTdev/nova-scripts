local function ShowNotification(message, nType, duration)
    SendNUIMessage({
        action = 'notify',
        message = message,
        type = nType or 'info',
        duration = duration or 5000,
    })
end

-- Export principal
exports('ShowNotification', ShowNotification)

-- Alias: o core chama SendNotification(type, message, duration)
exports('SendNotification', function(nType, message, duration)
    ShowNotification(message, nType, duration)
end)

RegisterNetEvent('nova:client:notify')
AddEventHandler('nova:client:notify', function(data, nType, duration)
    -- O core envia uma tabela { message, type, duration }, aceitar ambos os formatos
    if type(data) == 'table' then
        ShowNotification(data.message, data.type, data.duration)
    else
        ShowNotification(data, nType, duration)
    end
end)

RegisterNetEvent('nova_notify:show')
AddEventHandler('nova_notify:show', function(message, nType, duration)
    ShowNotification(message, nType, duration)
end)
