local isOpen = false
local currentGarage = nil
local spawnedVehicles = {} -- [plate] = netId

-- ============================================================
-- BLIPS
-- ============================================================

CreateThread(function()
    for id, garage in pairs(GarageConfig.Garages) do
        if garage.blip then
            local blip = AddBlipForCoord(garage.coords.x, garage.coords.y, garage.coords.z)
            SetBlipSprite(blip, GarageConfig.BlipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, GarageConfig.BlipScale)
            SetBlipColour(blip, GarageConfig.BlipColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(garage.label)
            EndTextCommandSetBlipName(blip)
        end
    end

    -- Blip apreensão
    local imp = GarageConfig.Impound
    local blip = AddBlipForCoord(imp.coords.x, imp.coords.y, imp.coords.z)
    SetBlipSprite(blip, 68)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(imp.label)
    EndTextCommandSetBlipName(blip)
end)

-- ============================================================
-- INTERAÇÃO
-- ============================================================

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        -- Garagens normais
        for id, garage in pairs(GarageConfig.Garages) do
            local dist = #(pCoords - garage.coords)
            if dist < 15.0 then
                sleep = 0
                if dist < GarageConfig.InteractDistance then
                    DrawText3D(garage.coords.x, garage.coords.y, garage.coords.z + 1.0, '[E] ' .. garage.label)

                    if IsControlJustReleased(0, 38) then
                        -- Se está num veículo, guardar
                        if IsPedInAnyVehicle(ped, false) then
                            StoreVehicle(id)
                        else
                            OpenGarage(id, 'normal')
                        end
                    end
                end
            end
        end

        -- Apreensão
        local impDist = #(pCoords - GarageConfig.Impound.coords)
        if impDist < 15.0 then
            sleep = 0
            if impDist < GarageConfig.InteractDistance then
                DrawText3D(GarageConfig.Impound.coords.x, GarageConfig.Impound.coords.y, GarageConfig.Impound.coords.z + 1.0,
                    '[E] ' .. GarageConfig.Impound.label)
                if IsControlJustReleased(0, 38) then
                    OpenGarage('impound', 'impound')
                end
            end
        end

        Wait(sleep)
    end
end)

-- ============================================================
-- ABRIR / FECHAR GARAGEM
-- ============================================================

function OpenGarage(garageId, garageType)
    if isOpen then return end
    isOpen = true
    currentGarage = garageId
    SetNuiFocus(true, true)

    exports['nova_core']:TriggerCallback('nova_garage:getVehicles', function(vehicles)
        local garageLabel = ''
        if garageType == 'impound' then
            garageLabel = GarageConfig.Impound.label
        else
            garageLabel = GarageConfig.Garages[garageId] and GarageConfig.Garages[garageId].label or garageId
        end

        SendNUIMessage({
            action = 'open',
            vehicles = vehicles or {},
            garageName = garageLabel,
            garageType = garageType,
            impoundPrice = GarageConfig.ImpoundPrice,
            locale = GarageGetAllStrings(),
        })
    end, garageType)
end

function CloseGarage()
    isOpen = false
    currentGarage = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

function StoreVehicle(garageId)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then return end

    local plate = GetVehicleNumberPlateText(vehicle)
    plate = plate:gsub('%s+', '') -- trim

    -- Obter nome do modelo para o caso de ser um veículo novo sem registo na BD
    local modelHash = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(modelHash)
    if modelName then modelName = string.lower(modelName) end

    local props = {
        mods = GetVehicleProperties(vehicle),
        fuel = GetVehicleFuelLevel(vehicle) or 100.0,
        engine = GetVehicleEngineHealth(vehicle),
        body = GetVehicleBodyHealth(vehicle),
        vehicleModel = modelName or 'unknown',
    }

    TaskLeaveVehicle(ped, vehicle, 0)
    Wait(1500)
    DeleteEntity(vehicle)
    spawnedVehicles[plate] = nil

    TriggerServerEvent('nova_garage:store', plate, props, garageId)
end

-- ============================================================
-- SPAWN VEÍCULO
-- ============================================================

RegisterNetEvent('nova_garage:spawnVehicle')
AddEventHandler('nova_garage:spawnVehicle', function(data)
    local garageId = data.garageId
    local spawnPoint

    if garageId == 'impound' then
        spawnPoint = GarageConfig.Impound.spawn
    elseif GarageConfig.Garages[garageId] then
        spawnPoint = GarageConfig.Garages[garageId].spawn
    else
        return
    end

    local model = GetHashKey(data.model)
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    if not HasModelLoaded(model) then
        TriggerEvent('nova:client:notify', GarageL('model_not_found'), 'error')
        return
    end

    local veh = CreateVehicle(model, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, false)
    SetVehicleNumberPlateText(veh, data.plate)
    SetVehicleFuelLevel(veh, data.fuel or 100.0)
    SetVehicleEngineHealth(veh, data.engine or 1000.0)
    SetVehicleBodyHealth(veh, data.body or 1000.0)

    if data.mods then
        SetVehicleProperties(veh, data.mods)
    end

    SetModelAsNoLongerNeeded(model)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

    spawnedVehicles[data.plate] = VehToNet(veh)

    CloseGarage()
    TriggerEvent('nova:client:notify', GarageL('vehicle_taken'), 'success')
end)

-- ============================================================
-- VEHICLE PROPERTIES HELPERS
-- ============================================================

function GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return {} end
    local props = {}
    props.model = GetEntityModel(vehicle)
    props.plate = GetVehicleNumberPlateText(vehicle)
    props.color1, props.color2 = GetVehicleColours(vehicle)
    props.pearlescentColor, props.wheelColor = GetVehicleExtraColours(vehicle)
    props.wheels = GetVehicleWheelType(vehicle)
    props.tint = GetVehicleWindowTint(vehicle)
    props.livery = GetVehicleLivery(vehicle)

    props.mods = {}
    for i = 0, 49 do
        props.mods[tostring(i)] = GetVehicleMod(vehicle, i)
    end

    props.neonEnabled = {
        IsVehicleNeonLightEnabled(vehicle, 0),
        IsVehicleNeonLightEnabled(vehicle, 1),
        IsVehicleNeonLightEnabled(vehicle, 2),
        IsVehicleNeonLightEnabled(vehicle, 3),
    }

    local r, g, b = GetVehicleNeonLightsColour(vehicle)
    props.neonColor = { r = r, g = g, b = b }

    local tr, tg, tb = GetVehicleTyreSmokeColor(vehicle)
    props.tyreSmokeColor = { r = tr, g = tg, b = tb }

    return props
end

function SetVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) or not props then return end

    if props.color1 and props.color2 then
        SetVehicleColours(vehicle, props.color1, props.color2)
    end
    if props.pearlescentColor and props.wheelColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor)
    end
    if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
    if props.tint then SetVehicleWindowTint(vehicle, props.tint) end
    if props.livery then SetVehicleLivery(vehicle, props.livery) end

    if props.mods then
        SetVehicleModKit(vehicle, 0)
        for k, v in pairs(props.mods) do
            local modType = tonumber(k)
            if modType then SetVehicleMod(vehicle, modType, v, false) end
        end
    end

    if props.neonEnabled then
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(vehicle, i, props.neonEnabled[i + 1] or false)
        end
    end
    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor.r or 0, props.neonColor.g or 0, props.neonColor.b or 0)
    end
    if props.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor.r or 0, props.tyreSmokeColor.g or 0, props.tyreSmokeColor.b or 0)
    end
end

-- ============================================================
-- NUI CALLBACKS
-- ============================================================

RegisterNUICallback('close', function(data, cb)
    CloseGarage()
    cb({ ok = true })
end)

RegisterNUICallback('takeOut', function(data, cb)
    TriggerServerEvent('nova_garage:takeOut', data.vehicleId, currentGarage)
    cb({ ok = true })
end)

RegisterNUICallback('recoverImpound', function(data, cb)
    TriggerServerEvent('nova_garage:recoverImpound', data.vehicleId)
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
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end
        Wait(0)
    end
end)
