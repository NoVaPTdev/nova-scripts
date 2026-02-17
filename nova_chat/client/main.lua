local isChatOpen = false
local chatVisible = true
local hideTimer = nil
local chatEnabled = true

-- ============================================================
-- ABRIR / FECHAR CHAT
-- ============================================================

CreateThread(function()
    while true do
        if chatEnabled and IsControlJustReleased(0, 245) then -- T
            if not isChatOpen then
                OpenChat()
            end
        end
        Wait(0)
    end
end)

-- Compatibilidade: chat:addMessage do client-side
RegisterNetEvent('chat:addMessage')
AddEventHandler('chat:addMessage', function(data)
    if not data then return end
    local author = ''
    local message = ''
    local color = '#e0e0e0'

    if type(data) == 'string' then
        message = data
    elseif type(data) == 'table' then
        author = data.author or data.title or ''
        if type(data.args) == 'table' then
            message = table.concat(data.args, ' ')
        elseif type(data.args) == 'string' then
            message = data.args
        elseif data.message then
            message = data.message
        end
        if data.color and type(data.color) == 'table' and #data.color >= 3 then
            color = string.format('#%02x%02x%02x', data.color[1], data.color[2], data.color[3])
        elseif type(data.color) == 'string' then
            color = data.color
        end
    end

    SendNUIMessage({
        action = 'addMessage',
        author = author,
        message = message,
        color = color,
        msgType = 'system',
    })
end)

function OpenChat()
    if isChatOpen then return end
    isChatOpen = true
    SetNuiFocus(true, false)
    SendNUIMessage({ action = 'openInput' })
end

function CloseChat()
    if not isChatOpen then return end
    isChatOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeInput' })
end

-- ============================================================
-- NUI CALLBACKS
-- ============================================================

RegisterNUICallback('sendMessage', function(data, cb)
    if data.message and data.message ~= '' then
        TriggerServerEvent('nova_chat:send', data.message)
    end
    CloseChat()
    cb({ ok = true })
end)

RegisterNUICallback('cancelInput', function(_, cb)
    CloseChat()
    cb({ ok = true })
end)

-- ============================================================
-- RECEBER MENSAGENS
-- ============================================================

RegisterNetEvent('nova_chat:receive')
AddEventHandler('nova_chat:receive', function(data)
    SendNUIMessage({
        action = 'addMessage',
        author = data.author,
        authorId = data.authorId,
        message = data.message,
        color = data.color,
        msgType = data.type,
    })

    -- Mostrar chat se estiver escondido
    if not chatVisible then
        chatVisible = true
        SendNUIMessage({ action = 'showChat' })
    end

    -- Auto-hide após 10s sem mensagens
    if hideTimer then
        hideTimer = nil
    end
    hideTimer = true
    SetTimeout(10000, function()
        if hideTimer and not isChatOpen then
            chatVisible = false
            SendNUIMessage({ action = 'fadeChat' })
            hideTimer = nil
        end
    end)
end)

RegisterNetEvent('nova_chat:clear')
AddEventHandler('nova_chat:clear', function()
    SendNUIMessage({ action = 'clearMessages' })
end)

-- Encaminhar comandos para o sistema nativo do FiveM
RegisterNetEvent('nova_chat:executeCommand')
AddEventHandler('nova_chat:executeCommand', function(rawCmd)
    ExecuteCommand(rawCmd)
end)
