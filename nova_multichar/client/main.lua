local isOpen = false
local charPed = nil
local charCam = nil
local selectedChar = nil
local creatingChar = false
local currentSkin = {}
local hasAutoOpened = false

-- Posição exterior segura
local pedCoords = vector4(-1038.13, -2740.65, 13.85, 326.0)
local camCoords = vector3(-1037.0, -2738.2, 15.75)

-- ============================================================
-- AUTO-ABRIR ao entrar no servidor
-- ============================================================

CreateThread(function()
    -- Esperar o jogador estar ativo na rede
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
    end

    -- Esperar o core estar pronto
    while GetResourceState('nova_core') ~= 'started' do
        Wait(100)
    end
    Wait(1000)

    -- Verificar se o jogador já tem personagem carregado
    local isLoaded = false
    pcall(function()
        isLoaded = exports['nova_core']:IsPlayerLoaded()
    end)

    if not isLoaded and not hasAutoOpened then
        hasAutoOpened = true
        OpenMultichar()
    end
end)

-- Evento manual (caso outro script queira reabrir)
RegisterNetEvent('nova:client:showCharacterSelect')
AddEventHandler('nova:client:showCharacterSelect', function()
    OpenMultichar()
end)

RegisterNetEvent('nova:client:requestCharacterSelect')
AddEventHandler('nova:client:requestCharacterSelect', function()
    OpenMultichar()
end)

function OpenMultichar()
    if isOpen then return end
    isOpen = true
    creatingChar = false

    DoScreenFadeOut(500)
    Wait(600)

    -- Esconder o ped do jogador e mover para o local da câmara
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, camCoords.x, camCoords.y, camCoords.z, false, false, false, false)
    SetEntityVisible(playerPed, false, false)
    FreezeEntityPosition(playerPed, true)

    SetupCamera()
    SetupPed()

    exports['nova_core']:TriggerCallback('nova:server:getCharacters', function(characters)
        local maxChars = 3
        local ok, cfg = pcall(function() return exports['nova_core']:GetConfig() end)
        if ok and cfg and cfg.MaxCharacters then maxChars = cfg.MaxCharacters end

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            characters = characters or {},
            maxCharacters = maxChars,
            locale = MCGetAllStrings(),
        })

        DoScreenFadeIn(500)
    end)
end

function SetupCamera()
    if charCam then
        DestroyCam(charCam, false)
    end

    charCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(charCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(charCam, pedCoords.x, pedCoords.y, pedCoords.z + 1.0)
    SetCamFov(charCam, 40.0)
    SetCamActive(charCam, true)
    RenderScriptCams(true, false, 0, true, true)
end

function SetupPed(gender)
    if charPed and DoesEntityExist(charPed) then
        DeleteEntity(charPed)
        charPed = nil
    end

    local model = gender == 1 and `mp_f_freemode_01` or `mp_m_freemode_01`
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    if not HasModelLoaded(model) then return end

    charPed = CreatePed(2, model, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, true)
    SetEntityInvincible(charPed, true)
    FreezeEntityPosition(charPed, true)
    SetBlockingOfNonTemporaryEvents(charPed, true)
    SetEntityAlpha(charPed, 255, false)
    SetModelAsNoLongerNeeded(model)
    TaskStandStill(charPed, -1)
    PlaceObjectOnGroundProperly(charPed)

    -- Garantir que a câmara aponta para o novo ped
    if charCam then
        PointCamAtCoord(charCam, pedCoords.x, pedCoords.y, pedCoords.z + 1.0)
    end
end

function ApplySkinToPed(skin)
    if not charPed or not DoesEntityExist(charPed) then return end
    if not skin then return end

    -- Componentes de aparência
    if skin.hair then SetPedComponentVariation(charPed, 2, skin.hair, 0, 0) end
    if skin.hairColor then SetPedHairColor(charPed, skin.hairColor, skin.hairHighlight or 0) end

    -- Face features (0-19)
    if skin.faceFeatures then
        for i = 0, 19 do
            SetPedFaceFeature(charPed, i, skin.faceFeatures[tostring(i)] or 0.0)
        end
    end

    -- Head blend (herança)
    local mom = skin.mom or 0
    local dad = skin.dad or 0
    local mix = skin.shapeMix or 0.5
    local skinMix = skin.skinMix or 0.5
    SetPedHeadBlendData(charPed, mom, dad, 0, mom, dad, 0, mix, skinMix, 0.0, false)

    -- Barba
    if skin.beard then
        SetPedHeadOverlay(charPed, 1, skin.beard, skin.beardOpacity or 1.0)
        if skin.beardColor then SetPedHeadOverlayColor(charPed, 1, 1, skin.beardColor, skin.beardColor) end
    end

    -- Sobrancelhas
    if skin.eyebrows then
        SetPedHeadOverlay(charPed, 2, skin.eyebrows, skin.eyebrowsOpacity or 1.0)
        if skin.eyebrowsColor then SetPedHeadOverlayColor(charPed, 2, 1, skin.eyebrowsColor, skin.eyebrowsColor) end
    end

    -- Roupa básica
    if skin.torso then SetPedComponentVariation(charPed, 3, skin.torso, 0, 0) end
    if skin.undershirt then SetPedComponentVariation(charPed, 8, skin.undershirt, 0, 0) end
    if skin.legs then SetPedComponentVariation(charPed, 4, skin.legs, 0, 0) end
    if skin.shoes then SetPedComponentVariation(charPed, 6, skin.shoes, 0, 0) end
    if skin.arms then SetPedComponentVariation(charPed, 3, skin.arms, 0, 0) end
end

function CleanupMultichar()
    isOpen = false
    creatingChar = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    if charCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(charCam, false)
        charCam = nil
    end
    if charPed and DoesEntityExist(charPed) then
        DeleteEntity(charPed)
        charPed = nil
    end

    -- Restaurar o ped do jogador
    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, true, false)
    FreezeEntityPosition(playerPed, false)
end

-- ============================================================
-- NUI CALLBACKS
-- ============================================================

RegisterNUICallback('selectCharacter', function(data, cb)
    if not data.citizenid then cb({ ok = false }) return end
    selectedChar = data.citizenid
    CleanupMultichar()
    DoScreenFadeOut(500)
    Wait(600)
    TriggerServerEvent('nova:server:loadCharacter', data.citizenid)

    -- Aplicar skin após carregar
    Wait(2000)
    local playerPed = PlayerPedId()
    exports['nova_core']:TriggerCallback('nova_multichar:getSkin', function(skin)
        if skin then
            ApplySkinToPlayerPed(skin)
        end
        DoScreenFadeIn(500)
    end, data.citizenid)

    cb({ ok = true })
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    if not data.citizenid then cb({ ok = false }) return end
    TriggerServerEvent('nova:server:deleteCharacter', data.citizenid)
    Wait(500)

    exports['nova_core']:TriggerCallback('nova:server:getCharacters', function(characters)
        cb({ ok = true, characters = characters or {} })
    end)
end)

RegisterNUICallback('startCreation', function(data, cb)
    creatingChar = true
    local gender = data.gender or 0
    SetupPed(gender)
    currentSkin = { gender = gender, mom = 0, dad = 0, shapeMix = 0.5, skinMix = 0.5 }
    cb({ ok = true })
end)

RegisterNUICallback('updateAppearance', function(data, cb)
    if not charPed or not DoesEntityExist(charPed) then cb({ ok = false }) return end

    for k, v in pairs(data) do
        currentSkin[k] = v
    end
    ApplySkinToPed(currentSkin)
    cb({ ok = true })
end)

RegisterNUICallback('changeGender', function(data, cb)
    local gender = data.gender or 0
    currentSkin.gender = gender
    SetupPed(gender)
    Wait(200)
    ApplySkinToPed(currentSkin)
    cb({ ok = true })
end)

RegisterNUICallback('finishCreation', function(data, cb)
    if not data.firstname or not data.lastname then cb({ ok = false }) return end

    local charData = {
        firstname = data.firstname,
        lastname = data.lastname,
        dateofbirth = data.dateofbirth or '01/01/2000',
        gender = currentSkin.gender or 0,
        nationality = data.nationality or MCL('unknown_nationality'),
    }

    TriggerServerEvent('nova:server:createCharacter', charData)

    -- Esperar o personagem ser criado e obter o citizenid
    local timeout = 0
    local newCitizenId = nil

    RegisterNetEvent('nova:client:characterCreated')
    AddEventHandler('nova:client:characterCreated', function(citizenid)
        newCitizenId = citizenid
    end)

    while not newCitizenId and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end

    if newCitizenId then
        TriggerServerEvent('nova_multichar:saveSkin', newCitizenId, currentSkin)
        Wait(300)

        CleanupMultichar()
        DoScreenFadeOut(500)
        Wait(600)
        TriggerServerEvent('nova:server:loadCharacter', newCitizenId)
        Wait(2000)
        ApplySkinToPlayerPed(currentSkin)
        DoScreenFadeIn(500)
    end

    cb({ ok = true })
end)

RegisterNUICallback('cancelCreation', function(data, cb)
    creatingChar = false
    SetupPed()

    exports['nova_core']:TriggerCallback('nova:server:getCharacters', function(characters)
        cb({ ok = true, characters = characters or {} })
    end)
end)

RegisterNUICallback('rotatePed', function(data, cb)
    if charPed and DoesEntityExist(charPed) then
        local heading = GetEntityHeading(charPed) + (data.direction or 10)
        SetEntityHeading(charPed, heading)
    end
    cb({ ok = true })
end)

-- Aplicar skin ao ped do jogador real
function ApplySkinToPlayerPed(skin)
    local ped = PlayerPedId()
    if not skin then return end

    local model = skin.gender == 1 and `mp_f_freemode_01` or `mp_m_freemode_01`
    if GetEntityModel(ped) ~= model then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        ped = PlayerPedId()
    end

    -- Base: head blend
    local mom = skin.mom or 0
    local dad = skin.dad or 0
    SetPedHeadBlendData(ped, mom, dad, 0, mom, dad, 0, skin.shapeMix or 0.5, skin.skinMix or 0.5, 0.0, false)

    -- Face features
    if skin.faceFeatures then
        for i = 0, 19 do SetPedFaceFeature(ped, i, skin.faceFeatures[tostring(i)] or 0.0) end
    end

    -- Hair (legacy fields)
    if skin.hair then SetPedComponentVariation(ped, 2, skin.hair, 0, 0) end
    if skin.hairColor then SetPedHairColor(ped, skin.hairColor, skin.hairHighlight or 0) end

    -- Legacy overlays (multichar format)
    if skin.beard then
        SetPedHeadOverlay(ped, 1, skin.beard, skin.beardOpacity or 1.0)
        if skin.beardColor then SetPedHeadOverlayColor(ped, 1, 1, skin.beardColor, skin.beardColor) end
    end
    if skin.eyebrows then
        SetPedHeadOverlay(ped, 2, skin.eyebrows, skin.eyebrowsOpacity or 1.0)
        if skin.eyebrowsColor then SetPedHeadOverlayColor(ped, 2, 1, skin.eyebrowsColor, skin.eyebrowsColor) end
    end

    -- Legacy clothing (multichar format)
    if skin.torso then SetPedComponentVariation(ped, 3, skin.torso, 0, 0) end
    if skin.undershirt then SetPedComponentVariation(ped, 8, skin.undershirt, 0, 0) end
    if skin.legs then SetPedComponentVariation(ped, 4, skin.legs, 0, 0) end
    if skin.shoes then SetPedComponentVariation(ped, 6, skin.shoes, 0, 0) end

    -- Extended components (from nova_shops clothing)
    if skin.components then
        for compId, compData in pairs(skin.components) do
            local cid = tonumber(compId)
            if cid and compData.drawable then
                SetPedComponentVariation(ped, cid, compData.drawable, compData.texture or 0, 0)
            end
        end
    end

    -- Extended props (from nova_shops clothing)
    if skin.props then
        for propId, propData in pairs(skin.props) do
            local pid = tonumber(propId)
            if pid then
                if propData.drawable and propData.drawable >= 0 then
                    SetPedPropIndex(ped, pid, propData.drawable, propData.texture or 0, true)
                else
                    ClearPedProp(ped, pid)
                end
            end
        end
    end

    -- Extended overlays (from nova_shops barber)
    if skin.overlays then
        for ovId, ovData in pairs(skin.overlays) do
            local oid = tonumber(ovId)
            if oid and ovData.index then
                SetPedHeadOverlay(ped, oid, ovData.index, ovData.opacity or 1.0)
                if ovData.color then
                    SetPedHeadOverlayColor(ped, oid, 1, ovData.color, ovData.color)
                end
            end
        end
    end

    -- Tattoos (from nova_shops tattoo)
    if skin.tattoos then
        ClearPedDecorations(ped)
        for _, tat in pairs(skin.tattoos) do
            if tat.collection and tat.overlay then
                AddPedDecorationFromHashes(ped, tat.collection, tat.overlay)
            end
        end
    end
end

-- Reaplicar skin quando o jogador carrega
RegisterNetEvent('nova:client:onPlayerLoaded')
AddEventHandler('nova:client:onPlayerLoaded', function(data)
    Wait(1000)
    local pData = exports['nova_core']:GetPlayerData()
    if pData and pData.citizenid then
        exports['nova_core']:TriggerCallback('nova_multichar:getSkin', function(skin)
            if skin then ApplySkinToPlayerPed(skin) end
        end, pData.citizenid)
    end
end)

-- Desativar controlos enquanto aberto
CreateThread(function()
    while true do
        if isOpen then
            DisableAllControlActions(0)
        end
        Wait(0)
    end
end)
