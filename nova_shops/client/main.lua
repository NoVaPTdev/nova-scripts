local isInShop = false
local currentShop = nil
local shopCam = nil
local originalSkin = nil
local activeTattoos = {}

-- ============================================================
-- BLIPS
-- ============================================================

CreateThread(function()
    for _, store in ipairs(ShopConfig.Stores) do
        if store.blip and store.locations then
            for _, loc in ipairs(store.locations) do
                local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
                SetBlipSprite(blip, store.blip.sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, store.blip.scale or 0.7)
                SetBlipColour(blip, store.blip.color or 0)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString(store.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)

-- ============================================================
-- INTERAÇÃO COM LOJAS
-- ============================================================

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local loaded = false
        pcall(function() loaded = exports['nova_core']:IsPlayerLoaded() end)

        if loaded and not isInShop then
            for _, store in ipairs(ShopConfig.Stores) do
                for _, loc in ipairs(store.locations) do
                    local dist = #(pCoords - loc)
                    if dist < ShopConfig.InteractDistance + 5 then
                        sleep = 0
                        if dist < ShopConfig.InteractDistance then
                            DrawText3D(loc.x, loc.y, loc.z + 1.0, '[E] ' .. store.label)
                            if IsControlJustReleased(0, 38) then
                                OpenShop(store)
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

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

-- ============================================================
-- ABRIR / FECHAR LOJA
-- ============================================================

function OpenShop(store)
    if isInShop then return end
    isInShop = true
    currentShop = store

    if store.type == 'clothing' or store.type == 'barber' or store.type == 'tattoo' then
        originalSkin = CaptureCurrentAppearance()
        if store.type == 'tattoo' then
            activeTattoos = GetActiveTattoos()
        end
        SetupShopCamera(store.type)
    end

    local nuiData = {
        action = 'open',
        shopType = store.type,
        shopLabel = store.label,
    }

    if store.type == 'general' then
        nuiData.items = store.items
    elseif store.type == 'clothing' then
        nuiData.categories = BuildClothingData()
    elseif store.type == 'barber' then
        nuiData.categories = BuildBarberData()
    elseif store.type == 'tattoo' then
        nuiData.tattoos = ShopConfig.Tattoos
        nuiData.activeTattoos = activeTattoos
        nuiData.zones = { 'head', 'torso', 'left_arm', 'right_arm', 'left_leg', 'right_leg' }
        nuiData.zoneLabels = {
            head = ShopL('zone_head'), torso = ShopL('zone_torso'),
            left_arm = ShopL('zone_left_arm'), right_arm = ShopL('zone_right_arm'),
            left_leg = ShopL('zone_left_leg'), right_leg = ShopL('zone_right_leg'),
        }
    end

    nuiData.price = ShopConfig.Prices[store.type] or 0
    nuiData.locale = ShopGetAllStrings()

    SetNuiFocus(true, true)
    SendNUIMessage(nuiData)
    pcall(function() TriggerEvent('nova_hud:toggle', false) end)
end

function CloseShop(save)
    if not isInShop then return end

    if not save and originalSkin and (currentShop.type == 'clothing' or currentShop.type == 'barber' or currentShop.type == 'tattoo') then
        RestoreAppearance(originalSkin)
        if currentShop.type == 'tattoo' then
            RestoreTattoos(activeTattoos)
        end
    end

    if shopCam then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(shopCam, false)
        shopCam = nil
    end

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)

    isInShop = false
    currentShop = nil
    originalSkin = nil

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    pcall(function() TriggerEvent('nova_hud:toggle', true) end)
end

-- ============================================================
-- CÂMARA
-- ============================================================

function SetupShopCamera(shopType)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    FreezeEntityPosition(ped, true)

    local rad = heading * math.pi / 180.0
    local camDist = shopType == 'barber' and 1.2 or 2.5

    local camX = coords.x + math.sin(rad) * camDist
    local camY = coords.y + math.cos(rad) * camDist

    shopCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    if shopType == 'barber' then
        SetCamCoord(shopCam, camX, camY, coords.z + 0.65)
        PointCamAtCoord(shopCam, coords.x, coords.y, coords.z + 0.6)
        SetCamFov(shopCam, 30.0)
    elseif shopType == 'tattoo' then
        SetCamCoord(shopCam, camX, camY, coords.z + 0.3)
        PointCamAtCoord(shopCam, coords.x, coords.y, coords.z + 0.2)
        SetCamFov(shopCam, 50.0)
    else
        SetCamCoord(shopCam, camX, camY, coords.z + 0.3)
        PointCamAtCoord(shopCam, coords.x, coords.y, coords.z + 0.2)
        SetCamFov(shopCam, 50.0)
    end

    SetCamActive(shopCam, true)
    RenderScriptCams(true, true, 500, true, true)
end

-- ============================================================
-- CAPTURA / RESTAURO DE APARÊNCIA
-- ============================================================

function CaptureCurrentAppearance()
    local ped = PlayerPedId()
    local data = { components = {}, props = {}, overlays = {}, hairColor = 0, hairHighlight = 0 }

    for compId = 0, 11 do
        data.components[compId] = {
            drawable = GetPedDrawableVariation(ped, compId),
            texture = GetPedTextureVariation(ped, compId),
        }
    end

    for _, propId in ipairs({0, 1, 2, 6, 7}) do
        data.props[propId] = {
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId),
        }
    end

    for _, ovId in ipairs({1, 2, 4, 5, 8, 10}) do
        local val, _ = GetPedHeadOverlayData(ped, ovId)
        data.overlays[ovId] = {
            index = GetPedHeadOverlayValue(ped, ovId),
            opacity = 1.0,
            color = 0,
        }
    end

    data.hairColor = GetPedHairColor(ped)
    data.hairHighlight = GetPedHairHighlightColor(ped)

    return data
end

function RestoreAppearance(data)
    local ped = PlayerPedId()
    if not data then return end

    for compId, compData in pairs(data.components or {}) do
        SetPedComponentVariation(ped, compId, compData.drawable, compData.texture, 0)
    end

    for propId, propData in pairs(data.props or {}) do
        if propData.drawable >= 0 then
            SetPedPropIndex(ped, propId, propData.drawable, propData.texture, true)
        else
            ClearPedProp(ped, propId)
        end
    end

    for ovId, ovData in pairs(data.overlays or {}) do
        SetPedHeadOverlay(ped, ovId, ovData.index, ovData.opacity or 1.0)
        if ovData.color then
            SetPedHeadOverlayColor(ped, ovId, 1, ovData.color, ovData.color)
        end
    end

    if data.hairColor then
        SetPedHairColor(ped, data.hairColor, data.hairHighlight or 0)
    end
end

-- ============================================================
-- DADOS PARA NUI
-- ============================================================

function BuildClothingData()
    local ped = PlayerPedId()
    local cats = {}

    for _, cat in ipairs(ShopConfig.ClothingCategories) do
        local entry = { id = cat.id, label = cat.label, type = cat.type }

        if cat.type == 'component' then
            entry.componentId = cat.componentId
            entry.drawable = GetPedDrawableVariation(ped, cat.componentId)
            entry.maxDrawable = GetNumberOfPedDrawableVariations(ped, cat.componentId) - 1
            entry.texture = GetPedTextureVariation(ped, cat.componentId)
            entry.maxTexture = GetNumberOfPedTextureVariations(ped, cat.componentId, entry.drawable) - 1
        elseif cat.type == 'prop' then
            entry.propId = cat.propId
            entry.drawable = GetPedPropIndex(ped, cat.propId)
            entry.maxDrawable = GetNumberOfPedPropDrawableVariations(ped, cat.propId) - 1
            entry.texture = GetPedPropTextureIndex(ped, cat.propId)
            entry.maxTexture = GetNumberOfPedPropTextureVariations(ped, cat.propId, math.max(0, entry.drawable)) - 1
        end

        cats[#cats + 1] = entry
    end

    return cats
end

function BuildBarberData()
    local ped = PlayerPedId()
    local cats = {}

    for _, cat in ipairs(ShopConfig.BarberCategories) do
        local entry = { id = cat.id, label = cat.label, type = cat.type }

        if cat.type == 'component' then
            entry.componentId = cat.componentId
            entry.drawable = GetPedDrawableVariation(ped, cat.componentId)
            entry.maxDrawable = GetNumberOfPedDrawableVariations(ped, cat.componentId) - 1
            entry.texture = GetPedTextureVariation(ped, cat.componentId)
            entry.maxTexture = GetNumberOfPedTextureVariations(ped, cat.componentId, entry.drawable) - 1
        elseif cat.type == 'overlay' then
            entry.overlayId = cat.overlayId
            entry.value = GetPedHeadOverlayValue(ped, cat.overlayId)
            entry.maxValue = GetNumHeadOverlayValues(cat.overlayId) - 1
        elseif cat.type == 'overlay_color' then
            entry.overlayId = cat.overlayId
            entry.value = 0
            entry.maxValue = 63
        elseif cat.type == 'hair_color' then
            entry.value = GetPedHairColor(ped)
            entry.maxValue = 63
        elseif cat.type == 'hair_highlight' then
            entry.value = GetPedHairHighlightColor(ped)
            entry.maxValue = 63
        end

        cats[#cats + 1] = entry
    end

    return cats
end

-- ============================================================
-- TATUAGENS
-- ============================================================

function GetActiveTattoos()
    return activeTattoos or {}
end

function RestoreTattoos(tattoos)
    local ped = PlayerPedId()
    ClearPedDecorations(ped)
    for _, tat in ipairs(tattoos or {}) do
        AddPedDecorationFromHashes(ped, tat.collection, tat.overlay)
    end
end

function IsMalePed()
    return GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01')
end

function ApplyTattooList(tattoos)
    local ped = PlayerPedId()
    ClearPedDecorations(ped)
    for _, tat in ipairs(tattoos) do
        AddPedDecorationFromHashes(ped, tat.collection, tat.overlay)
    end
end

-- ============================================================
-- NUI CALLBACKS
-- ============================================================

RegisterNUICallback('close', function(_, cb)
    CloseShop(false)
    cb({ ok = true })
end)

RegisterNUICallback('buyItem', function(data, cb)
    TriggerServerEvent('nova_shops:buyItem', data.name, data.quantity or 1)
    cb({ ok = true })
end)

-- Roupa: mudar componente
RegisterNUICallback('changeClothing', function(data, cb)
    local ped = PlayerPedId()
    local catType = data.catType
    local id = data.id
    local drawable = data.drawable
    local texture = data.texture

    if catType == 'component' then
        SetPedComponentVariation(ped, id, drawable, texture, 0)
        local maxTex = GetNumberOfPedTextureVariations(ped, id, drawable) - 1
        cb({ ok = true, maxTexture = maxTex })
    elseif catType == 'prop' then
        if drawable < 0 then
            ClearPedProp(ped, id)
        else
            SetPedPropIndex(ped, id, drawable, texture, true)
        end
        local maxTex = GetNumberOfPedPropTextureVariations(ped, id, math.max(0, drawable)) - 1
        cb({ ok = true, maxTexture = maxTex })
    else
        cb({ ok = false })
    end
end)

-- Barbeiro: mudar overlay / cor
RegisterNUICallback('changeBarber', function(data, cb)
    local ped = PlayerPedId()
    local catType = data.catType

    if catType == 'component' then
        SetPedComponentVariation(ped, data.componentId, data.drawable, data.texture or 0, 0)
        local maxTex = GetNumberOfPedTextureVariations(ped, data.componentId, data.drawable) - 1
        cb({ ok = true, maxTexture = maxTex })
    elseif catType == 'overlay' then
        SetPedHeadOverlay(ped, data.overlayId, data.value, 1.0)
        cb({ ok = true })
    elseif catType == 'overlay_color' then
        SetPedHeadOverlayColor(ped, data.overlayId, 1, data.value, data.value)
        cb({ ok = true })
    elseif catType == 'hair_color' then
        SetPedHairColor(ped, data.value, GetPedHairHighlightColor(ped))
        cb({ ok = true })
    elseif catType == 'hair_highlight' then
        SetPedHairColor(ped, GetPedHairColor(ped), data.value)
        cb({ ok = true })
    else
        cb({ ok = false })
    end
end)

-- Tatuagem: toggle
RegisterNUICallback('toggleTattoo', function(data, cb)
    local ped = PlayerPedId()
    local isMale = IsMalePed()
    local overlayName = isMale and data.male or data.female
    local collHash = GetHashKey(data.collection)
    local ovlHash = GetHashKey(overlayName)

    local found = false
    for i, tat in ipairs(activeTattoos) do
        if tat.collName == data.collection and tat.ovlName == overlayName then
            table.remove(activeTattoos, i)
            found = true
            break
        end
    end

    if not found then
        activeTattoos[#activeTattoos + 1] = {
            collection = collHash,
            overlay = ovlHash,
            collName = data.collection,
            ovlName = overlayName,
        }
    end

    ApplyTattooList(activeTattoos)
    cb({ ok = true, active = not found })
end)

-- Rodar personagem
RegisterNUICallback('rotatePed', function(data, cb)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped) + (data.direction or 10)
    SetEntityHeading(ped, heading)

    if shopCam then
        local coords = GetEntityCoords(ped)
        local rad = heading * math.pi / 180.0
        local camType = currentShop and currentShop.type or 'clothing'
        local camDist = camType == 'barber' and 1.2 or 2.5

        SetCamCoord(shopCam,
            coords.x + math.sin(rad) * camDist,
            coords.y + math.cos(rad) * camDist,
            camType == 'barber' and coords.z + 0.65 or coords.z + 0.3
        )
        PointCamAtCoord(shopCam, coords.x, coords.y,
            camType == 'barber' and coords.z + 0.6 or coords.z + 0.2
        )
    end

    cb({ ok = true })
end)

-- Confirmar compra (roupa/barbeiro/tatuagem)
RegisterNUICallback('confirmPurchase', function(data, cb)
    local skinData = CaptureFullSkinData()

    if currentShop and currentShop.type == 'tattoo' then
        skinData.tattoos = {}
        for _, tat in ipairs(activeTattoos) do
            skinData.tattoos[#skinData.tattoos + 1] = {
                collection = tat.collection,
                overlay = tat.overlay,
                collName = tat.collName,
                ovlName = tat.ovlName,
            }
        end
    end

    TriggerServerEvent('nova_shops:saveLook', skinData, currentShop and currentShop.type or 'clothing')
    CloseShop(true)
    cb({ ok = true })
end)

-- ============================================================
-- CAPTURA COMPLETA DE SKIN (para salvar)
-- ============================================================

function CaptureFullSkinData()
    local ped = PlayerPedId()

    local pData = nil
    pcall(function() pData = exports['nova_core']:GetPlayerData() end)
    local existingSkin = (pData and pData.skin) or {}

    local skin = {}
    for k, v in pairs(existingSkin) do
        skin[k] = v
    end

    skin.components = {}
    for compId = 0, 11 do
        skin.components[tostring(compId)] = {
            drawable = GetPedDrawableVariation(ped, compId),
            texture = GetPedTextureVariation(ped, compId),
        }
    end

    skin.props = {}
    for _, propId in ipairs({0, 1, 2, 6, 7}) do
        skin.props[tostring(propId)] = {
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId),
        }
    end

    skin.hair = GetPedDrawableVariation(ped, 2)
    skin.hairColor = GetPedHairColor(ped)
    skin.hairHighlight = GetPedHairHighlightColor(ped)

    skin.overlays = {}
    for _, ovId in ipairs({1, 2, 4, 5, 8, 10}) do
        skin.overlays[tostring(ovId)] = {
            index = GetPedHeadOverlayValue(ped, ovId),
            opacity = 1.0,
            color = 0,
        }
    end

    return skin
end

-- Desativar controlos enquanto na loja
CreateThread(function()
    while true do
        if isInShop and currentShop and currentShop.type ~= 'general' then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end
        Wait(0)
    end
end)
