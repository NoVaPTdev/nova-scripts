local chatCommands = {}

-- ============================================================
-- ENVIAR MENSAGEM GLOBAL
-- ============================================================

RegisterNetEvent('nova_chat:send')
AddEventHandler('nova_chat:send', function(message)
    local src = source
    if not message or message == '' then return end
    if #message > 500 then message = string.sub(message, 1, 500) end

    local name = GetPlayerName(src) or ChatL('unknown')
    local id = src

    -- Tentar obter nome do personagem via core
    local charName = nil
    pcall(function()
        local player = exports['nova_core']:GetPlayer(src)
        if player and player.charinfo then
            charName = player.charinfo.firstname .. ' ' .. player.charinfo.lastname
        end
    end)

    local displayName = charName or name

    -- Verificar se é um comando
    if string.sub(message, 1, 1) == '/' then
        local args = {}
        for word in string.gmatch(message, '%S+') do
            args[#args + 1] = word
        end
        local cmd = string.lower(string.sub(args[1], 2))
        table.remove(args, 1)
        
        if chatCommands[cmd] then
            chatCommands[cmd](src, args, message)
        else
            -- Encaminhar para o sistema de comandos nativo do FiveM (RegisterCommand)
            local rawCmd = string.sub(message, 2) -- remover a /
            TriggerClientEvent('nova_chat:executeCommand', src, rawCmd)
        end
        return
    end

    -- Mensagem global (OOC)
    TriggerClientEvent('nova_chat:receive', -1, {
        author = displayName,
        authorId = id,
        message = message,
        color = '#e0e0e0',
        type = 'global',
    })
end)

-- ============================================================
-- COMANDOS DE CHAT
-- ============================================================

-- /me [ação]
chatCommands['me'] = function(src, args)
    if #args == 0 then return end
    local name = GetPlayerName(src)
    pcall(function()
        local player = exports['nova_core']:GetPlayer(src)
        if player and player.charinfo then
            name = player.charinfo.firstname .. ' ' .. player.charinfo.lastname
        end
    end)
    local action = table.concat(args, ' ')
    TriggerClientEvent('nova_chat:receive', -1, {
        author = '',
        message = '* ' .. name .. ' ' .. action,
        color = '#c084fc',
        type = 'me',
    })
end

-- /ooc [mensagem]
chatCommands['ooc'] = function(src, args)
    if #args == 0 then return end
    local name = GetPlayerName(src)
    local msg = table.concat(args, ' ')
    TriggerClientEvent('nova_chat:receive', -1, {
        author = '[OOC] ' .. name,
        authorId = src,
        message = msg,
        color = '#94a3b8',
        type = 'ooc',
    })
end

-- /anuncio [mensagem] (admin only)
chatCommands['anuncio'] = function(src, args)
    local isAdmin = false
    pcall(function()
        isAdmin = exports['nova_core']:IsAdmin(src)
    end)
    if not isAdmin then
        TriggerClientEvent('nova_chat:receive', src, {
            author = ChatL('system'),
            message = ChatL('no_permission'),
            color = '#ef4444',
            type = 'system',
        })
        return
    end
    if #args == 0 then return end
    local msg = table.concat(args, ' ')
    TriggerClientEvent('nova_chat:receive', -1, {
        author = '📢 ' .. ChatL('announce'),
        message = msg,
        color = '#facc15',
        type = 'announce',
    })
end

-- /limpar
chatCommands['limpar'] = function(src)
    TriggerClientEvent('nova_chat:clear', src)
end

-- ============================================================
-- EXPORT PARA OUTROS SCRIPTS
-- ============================================================

exports('SendMessage', function(source, author, message, color)
    TriggerClientEvent('nova_chat:receive', source or -1, {
        author = author or ChatL('system'),
        message = message or '',
        color = color or '#e0e0e0',
        type = 'system',
    })
end)

-- ============================================================
-- COMPATIBILIDADE COM chat:addMessage (FiveM padrão)
-- ============================================================

RegisterNetEvent('chat:addMessage')
AddEventHandler('chat:addMessage', function(data)
    if not data then return end
    local author = ''
    local message = ''
    local color = '#e0e0e0'
    local r, g, b

    if type(data) == 'string' then
        message = data
    elseif type(data) == 'table' then
        author = data.author or data.title or ''
        if type(data.args) == 'table' then
            message = table.concat(data.args, ' ')
        elseif type(data.args) == 'string' then
            message = data.args
        elseif data.template then
            message = data.template
        elseif data.message then
            message = data.message
        end
        if data.color and type(data.color) == 'table' and #data.color >= 3 then
            r, g, b = data.color[1], data.color[2], data.color[3]
            color = string.format('#%02x%02x%02x', r, g, b)
        elseif type(data.color) == 'string' then
            color = data.color
        end
    end

    TriggerClientEvent('nova_chat:receive', source or -1, {
        author = author,
        message = message,
        color = color,
        type = 'system',
    })
end)

-- /say command compatibility
RegisterCommand('say', function(source, args)
    if source == 0 then
        TriggerClientEvent('nova_chat:receive', -1, {
            author = ChatL('console'),
            message = table.concat(args, ' '),
            color = '#ef4444',
            type = 'system',
        })
    end
end, true)

-- Mensagem de boas-vindas
AddEventHandler('nova:server:onPlayerLoaded', function(source, player)
    local name = ChatL('player')
    if player and player.charinfo then
        name = player.charinfo.firstname
    end
    TriggerClientEvent('nova_chat:receive', source, {
        author = 'NOVA',
        message = ChatL('welcome', name),
        color = '#84cc16',
        type = 'system',
    })
end)
