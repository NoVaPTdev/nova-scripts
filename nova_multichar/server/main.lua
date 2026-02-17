local Nova = nil

CreateThread(function()
    while not exports['nova_core']:IsFrameworkReady() do Wait(100) end
    Nova = exports['nova_core']:GetObject()
end)

-- Salvar skin do personagem
RegisterNetEvent('nova_multichar:saveSkin')
AddEventHandler('nova_multichar:saveSkin', function(citizenid, skinData)
    local src = source
    if not citizenid or not skinData then return end
    MySQL.Async.execute(
        'UPDATE nova_characters SET skin = @skin WHERE citizenid = @cid',
        { ['@skin'] = json.encode(skinData), ['@cid'] = citizenid }
    )
end)

-- Obter skin de um personagem
exports['nova_core']:CreateCallback('nova_multichar:getSkin', function(source, cb, citizenid)
    local result = MySQL.Sync.fetchAll(
        'SELECT skin FROM nova_characters WHERE citizenid = @cid LIMIT 1',
        { ['@cid'] = citizenid }
    )
    if result and result[1] and result[1].skin then
        cb(json.decode(result[1].skin))
    else
        cb(nil)
    end
end)
