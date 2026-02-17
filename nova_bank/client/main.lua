local isOpen = false
local nearBank = false

-- ============================================================
-- BLIPS
-- ============================================================

CreateThread(function()
    for _, bank in ipairs(BankConfig.Banks) do
        local blip = AddBlipForCoord(bank.coords.x, bank.coords.y, bank.coords.z)
        SetBlipSprite(blip, BankConfig.BlipSprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, BankConfig.BlipScale)
        SetBlipColour(blip, BankConfig.BlipColor)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(bank.label or BankL('nui_bank_account'))
        EndTextCommandSetBlipName(blip)
    end
end)

-- ============================================================
-- INTERAÇÃO
-- ============================================================

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        nearBank = false

        -- Verificar bancos
        for _, bank in ipairs(BankConfig.Banks) do
            local dist = #(pCoords - bank.coords)
            if dist < 10.0 then
                sleep = 0
                if dist < BankConfig.InteractDistance then
                    nearBank = true
                    DrawText3D(bank.coords.x, bank.coords.y, bank.coords.z + 1.0, BankL('nui_open_bank'))
                    if IsControlJustReleased(0, 38) then
                        OpenBank()
                    end
                end
            end
        end

        -- Verificar ATMs
        for _, atm in ipairs(BankConfig.ATMs) do
            local dist = #(pCoords - atm.coords)
            if dist < 10.0 then
                sleep = 0
                if dist < BankConfig.InteractDistance then
                    nearBank = true
                    DrawText3D(atm.coords.x, atm.coords.y, atm.coords.z + 1.0, BankL('nui_use_atm'))
                    if IsControlJustReleased(0, 38) then
                        OpenBank()
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- ============================================================
-- ABRIR / FECHAR BANCO
-- ============================================================

function OpenBank()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)

    exports['nova_core']:TriggerCallback('nova_bank:getData', function(data)
        if not data then
            CloseBank()
            return
        end
        SendNUIMessage({
            action = 'open',
            cash = data.cash,
            bank = data.bank,
            name = data.name,
            transactions = data.transactions,
            locale = BankGetAllStrings(),
        })
    end)
end

function CloseBank()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- Refresh após operação
RegisterNetEvent('nova_bank:refresh')
AddEventHandler('nova_bank:refresh', function()
    if not isOpen then return end
    exports['nova_core']:TriggerCallback('nova_bank:getData', function(data)
        if data then
            SendNUIMessage({
                action = 'refresh',
                cash = data.cash,
                bank = data.bank,
                transactions = data.transactions,
            })
        end
    end)
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseBank()
    cb({ ok = true })
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('nova_bank:deposit', data.amount)
    cb({ ok = true })
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('nova_bank:withdraw', data.amount)
    cb({ ok = true })
end)

RegisterNUICallback('transfer', function(data, cb)
    TriggerServerEvent('nova_bank:transfer', data.targetId, data.amount)
    cb({ ok = true })
end)

-- DrawText3D helper
function DrawText3D(x, y, z, text)
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Desativar controlos enquanto aberto
CreateThread(function()
    while true do
        if isOpen then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true) -- Mouse
            EnableControlAction(0, 2, true) -- Mouse
        end
        Wait(0)
    end
end)
