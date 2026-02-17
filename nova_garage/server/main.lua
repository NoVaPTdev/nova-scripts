local Nova = nil

CreateThread(function()
    while not exports['nova_core']:IsFrameworkReady() do Wait(100) end
    Nova = exports['nova_core']:GetObject()
end)

-- ============================================================
-- CALLBACKS
-- ============================================================

exports['nova_core']:CreateCallback('nova_garage:getVehicles', function(source, cb, garageType)
    local player = exports['nova_core']:GetPlayer(source)
    if not player then cb({}) return end

    local citizenid = player.citizenid
    local query = ''
    local params = { ['@cid'] = citizenid }

    if garageType == 'impound' then
        query = 'SELECT * FROM nova_vehicles WHERE citizenid = @cid AND state = 2'
    else
        query = 'SELECT * FROM nova_vehicles WHERE citizenid = @cid AND (state = 0 OR state = 1)'
    end

    local vehicles = MySQL.Sync.fetchAll(query, params)

    local result = {}
    for _, v in ipairs(vehicles or {}) do
        local mods = {}
        if v.mods and v.mods ~= '' then
            mods = json.decode(v.mods) or {}
        end

        table.insert(result, {
            id = v.id,
            plate = v.plate,
            vehicle = v.vehicle,
            state = v.state, -- 0=fora, 1=guardado, 2=apreendido
            fuel = v.fuel or 100,
            engine = v.engine or 1000.0,
            body = v.body or 1000.0,
            mods = mods,
            garage = v.garage or 'legion',
        })
    end

    cb(result)
end)

-- ============================================================
-- RETIRAR VEÍCULO
-- ============================================================

RegisterNetEvent('nova_garage:takeOut')
AddEventHandler('nova_garage:takeOut', function(vehicleId, garageId)
    local src = source
    local player = exports['nova_core']:GetPlayer(src)
    if not player then return end

    local veh = MySQL.Sync.fetchAll(
        'SELECT * FROM nova_vehicles WHERE id = @id AND citizenid = @cid LIMIT 1',
        { ['@id'] = vehicleId, ['@cid'] = player.citizenid }
    )

    if not veh or not veh[1] then
        TriggerClientEvent('nova:client:notify', src, GarageL('vehicle_not_found'), 'error')
        return
    end

    local v = veh[1]
    if v.state == 0 then
        TriggerClientEvent('nova:client:notify', src, GarageL('vehicle_already_out'), 'error')
        return
    end

    MySQL.Async.execute(
        'UPDATE nova_vehicles SET state = 0, garage = @garage WHERE id = @id',
        { ['@id'] = vehicleId, ['@garage'] = garageId }
    )

    local mods = {}
    if v.mods and v.mods ~= '' then mods = json.decode(v.mods) or {} end

    TriggerClientEvent('nova_garage:spawnVehicle', src, {
        model = v.vehicle,
        plate = v.plate,
        fuel = v.fuel or 100,
        engine = v.engine or 1000.0,
        body = v.body or 1000.0,
        mods = mods,
        garageId = garageId,
    })
end)

-- ============================================================
-- GUARDAR VEÍCULO
-- ============================================================

RegisterNetEvent('nova_garage:store')
AddEventHandler('nova_garage:store', function(plate, props, garageId)
    local src = source
    local player = exports['nova_core']:GetPlayer(src)
    if not player then return end

    -- Verificar se o veículo já existe na BD
    local existing = MySQL.Sync.fetchAll(
        'SELECT id FROM nova_vehicles WHERE plate = @plate AND citizenid = @cid LIMIT 1',
        { ['@plate'] = plate, ['@cid'] = player.citizenid }
    )

    if existing and existing[1] then
        -- Atualizar veículo existente
        MySQL.Async.execute(
            'UPDATE nova_vehicles SET state = 1, mods = @mods, fuel = @fuel, engine = @engine, body = @body, garage = @garage WHERE plate = @plate AND citizenid = @cid',
            {
                ['@plate'] = plate,
                ['@cid'] = player.citizenid,
                ['@mods'] = json.encode(props.mods or {}),
                ['@fuel'] = props.fuel or 100,
                ['@engine'] = props.engine or 1000.0,
                ['@body'] = props.body or 1000.0,
                ['@garage'] = garageId,
            }
        )
    else
        -- Veículo não existe na BD (ex: addcar antigo sem registo) - inserir
        local model = props.vehicleModel or 'unknown'
        MySQL.Async.execute(
            'INSERT INTO nova_vehicles (citizenid, vehicle, plate, state, garage, fuel, engine, body, mods) VALUES (@cid, @vehicle, @plate, 1, @garage, @fuel, @engine, @body, @mods)',
            {
                ['@cid'] = player.citizenid,
                ['@vehicle'] = model,
                ['@plate'] = plate,
                ['@garage'] = garageId,
                ['@fuel'] = props.fuel or 100,
                ['@engine'] = props.engine or 1000.0,
                ['@body'] = props.body or 1000.0,
                ['@mods'] = json.encode(props.mods or {}),
            }
        )
    end

    TriggerClientEvent('nova:client:notify', src, GarageL('vehicle_stored'), 'success')
end)

-- ============================================================
-- RECUPERAR APREENSÃO
-- ============================================================

RegisterNetEvent('nova_garage:recoverImpound')
AddEventHandler('nova_garage:recoverImpound', function(vehicleId)
    local src = source
    local player = exports['nova_core']:GetPlayer(src)
    if not player then return end

    local veh = MySQL.Sync.fetchAll(
        'SELECT * FROM nova_vehicles WHERE id = @id AND citizenid = @cid AND state = 2 LIMIT 1',
        { ['@id'] = vehicleId, ['@cid'] = player.citizenid }
    )

    if not veh or not veh[1] then
        TriggerClientEvent('nova:client:notify', src, GarageL('vehicle_not_found'), 'error')
        return
    end

    local cash = (player.money and player.money.cash) or 0
    if cash < GarageConfig.ImpoundPrice then
        TriggerClientEvent('nova:client:notify', src, GarageL('not_enough_money', GarageConfig.ImpoundPrice), 'error')
        return
    end

    exports['nova_core']:RemovePlayerMoney(src, 'cash', GarageConfig.ImpoundPrice)
    MySQL.Async.execute('UPDATE nova_vehicles SET state = 0 WHERE id = @id', { ['@id'] = vehicleId })

    local v = veh[1]
    local mods = {}
    if v.mods and v.mods ~= '' then mods = json.decode(v.mods) or {} end

    TriggerClientEvent('nova_garage:spawnVehicle', src, {
        model = v.vehicle,
        plate = v.plate,
        fuel = v.fuel or 100,
        engine = v.engine or 1000.0,
        body = v.body or 1000.0,
        mods = mods,
        garageId = 'impound',
    })

    TriggerClientEvent('nova:client:notify', src, GarageL('impound_recovered', GarageConfig.ImpoundPrice), 'success')
end)
