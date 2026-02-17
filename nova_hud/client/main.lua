local hudVisible = false
local playerLoaded = false
local progressActive = false
local progressCallback = nil
local progressCancelled = false

exports('ToggleHud', function(state)
    hudVisible = state
    SendNUIMessage({ action = 'toggleHud', visible = state })
end)

exports('IsHudVisible', function()
    return hudVisible
end)

-- ============================================================
-- PROGRESS BAR
-- ============================================================

exports('ProgressBar', function(label, duration, opts)
    if progressActive then return false end
    progressActive = true
    progressCancelled = false

    local options = opts or {}
    local canCancel = options.canCancel ~= false

    SendNUIMessage({
        action = 'startProgress',
        label = label or HudL('processing'),
        duration = duration or 3000,
    })

    -- Animação do ped (opcional)
    if options.animation then
        local ped = PlayerPedId()
        local anim = options.animation
        RequestAnimDict(anim.dict)
        local timeout = 0
        while not HasAnimDictLoaded(anim.dict) and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end
        if HasAnimDictLoaded(anim.dict) then
            TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, duration, anim.flag or 49, 0, false, false, false)
        end
    end

    -- Prop (opcional)
    local propEntity = nil
    if options.prop then
        local ped = PlayerPedId()
        local propHash = GetHashKey(options.prop.model)
        RequestModel(propHash)
        local timeout = 0
        while not HasModelLoaded(propHash) and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end
        if HasModelLoaded(propHash) then
            local coords = GetEntityCoords(ped)
            propEntity = CreateObject(propHash, coords.x, coords.y, coords.z, true, true, true)
            local bone = options.prop.bone or 60309
            AttachEntityToEntity(propEntity, ped, GetPedBoneIndex(ped, bone),
                options.prop.pos and options.prop.pos.x or 0.0,
                options.prop.pos and options.prop.pos.y or 0.0,
                options.prop.pos and options.prop.pos.z or 0.0,
                options.prop.rot and options.prop.rot.x or 0.0,
                options.prop.rot and options.prop.rot.y or 0.0,
                options.prop.rot and options.prop.rot.z or 0.0,
                true, true, false, true, 1, true)
        end
    end

    -- Bloquear controles e permitir cancelamento
    CreateThread(function()
        local startTime = GetGameTimer()
        while progressActive do
            if options.disableControls ~= false then
                DisableControlAction(0, 21, true)  -- Sprint
                DisableControlAction(0, 24, true)  -- Attack
                DisableControlAction(0, 25, true)  -- Aim
                DisableControlAction(0, 47, true)  -- Weapon
            end
            if canCancel and IsControlJustReleased(0, 73) then -- X para cancelar
                CancelProgressBar()
            end
            if (GetGameTimer() - startTime) > (duration + 1000) then
                break
            end
            Wait(0)
        end
    end)

    -- Esperar resultado
    while progressActive do Wait(50) end

    -- Limpar prop
    if propEntity and DoesEntityExist(propEntity) then
        DeleteEntity(propEntity)
    end

    -- Limpar animação
    if options.animation then
        ClearPedTasks(PlayerPedId())
    end

    return not progressCancelled
end)

function CancelProgressBar()
    if not progressActive then return end
    progressActive = false
    progressCancelled = true
    SendNUIMessage({ action = 'cancelProgress' })
    ClearPedTasks(PlayerPedId())
end

exports('CancelProgressBar', CancelProgressBar)

exports('IsProgressActive', function()
    return progressActive
end)

RegisterNUICallback('progressComplete', function(_, cb)
    progressActive = false
    progressCancelled = false
    cb({ ok = true })
end)

RegisterNetEvent('nova:client:onPlayerLoaded')
AddEventHandler('nova:client:onPlayerLoaded', function()
    playerLoaded = true
    hudVisible = true
    SendNUIMessage({ action = 'toggleHud', visible = true, locale = HudGetAllStrings() })
end)

RegisterNetEvent('nova:client:onLogout')
AddEventHandler('nova:client:onLogout', function()
    playerLoaded = false
    hudVisible = false
    SendNUIMessage({ action = 'toggleHud', visible = false })
end)

-- Loop principal de atualização
CreateThread(function()
    while true do
        if playerLoaded and hudVisible then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local armor = GetPedArmour(ped)
            local inVehicle = IsPedInAnyVehicle(ped, false)

            local healthPct = math.floor(((health - 100) / (maxHealth - 100)) * 100)
            if healthPct < 0 then healthPct = 0 end
            if healthPct > 100 then healthPct = 100 end

            -- Dados do jogador
            local pData = {}
            local ok, data = pcall(function() return exports['nova_core']:GetPlayerData() end)
            if ok and data then pData = data end

            local cash = 0
            local bank = 0
            local hunger = 100
            local thirst = 100
            local stress = 0
            local jobName = HudL('unemployed')
            local onDuty = false
            local serverId = GetPlayerServerId(PlayerId())

            if pData.money then
                cash = pData.money.cash or 0
                bank = pData.money.bank or 0
            end

            if pData.metadata then
                hunger = pData.metadata.hunger or 100
                thirst = pData.metadata.thirst or 100
                stress = pData.metadata.stress or 0
            end

            if pData.job then
                jobName = pData.job.label or pData.job.name or HudL('unemployed')
                onDuty = pData.job.duty or false
            end

            -- Velocidade (se em veículo)
            local speed = 0
            if inVehicle then
                speed = math.floor(GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * 3.6)
            end

            SendNUIMessage({
                action = 'update',
                health = healthPct,
                armor = armor,
                hunger = math.floor(hunger),
                thirst = math.floor(thirst),
                stress = math.floor(stress),
                cash = cash,
                bank = bank,
                job = jobName,
                onDuty = onDuty,
                serverId = serverId,
                inVehicle = inVehicle,
                speed = speed,
            })
        end
        Wait(200)
    end
end)

-- Esconder minimap quando a pé e HUD desligada
CreateThread(function()
    while true do
        if not hudVisible then
            DisplayRadar(false)
        else
            DisplayRadar(true)
        end
        Wait(500)
    end
end)

-- Esconder HUD quando inventário está aberto
RegisterNetEvent('nova_hud:toggle')
AddEventHandler('nova_hud:toggle', function(state)
    hudVisible = state
    SendNUIMessage({ action = 'toggleHud', visible = state })
end)
