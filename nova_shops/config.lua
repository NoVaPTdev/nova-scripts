ShopConfig = {}

ShopConfig.InteractDistance = 2.0

ShopConfig.Prices = {
    clothing = 150,
    barber = 75,
    tattoo = 250,
}

-- ============================================================
-- CATEGORIAS DE ROUPA
-- ============================================================

ShopConfig.ClothingCategories = {
    { id = 'tops',        label = 'Camisola / Casaco', componentId = 11, type = 'component' },
    { id = 'undershirt',  label = 'Roupa Interior',    componentId = 8,  type = 'component' },
    { id = 'torso',       label = 'Torso / Braços',    componentId = 3,  type = 'component' },
    { id = 'pants',       label = 'Calças',            componentId = 4,  type = 'component' },
    { id = 'shoes',       label = 'Sapatos',           componentId = 6,  type = 'component' },
    { id = 'accessories', label = 'Acessórios',        componentId = 7,  type = 'component' },
    { id = 'bags',        label = 'Mochilas / Malas',  componentId = 5,  type = 'component' },
    { id = 'hats',        label = 'Chapéus',           propId = 0,       type = 'prop' },
    { id = 'glasses',     label = 'Óculos',            propId = 1,       type = 'prop' },
    { id = 'ears',        label = 'Brincos',           propId = 2,       type = 'prop' },
    { id = 'watches',     label = 'Relógios',          propId = 6,       type = 'prop' },
}

-- ============================================================
-- CATEGORIAS DO BARBEIRO
-- ============================================================

ShopConfig.BarberCategories = {
    { id = 'hair_style',     label = 'Estilo de Cabelo',     type = 'component', componentId = 2 },
    { id = 'hair_color',     label = 'Cor do Cabelo',        type = 'hair_color' },
    { id = 'hair_highlight', label = 'Mechas',               type = 'hair_highlight' },
    { id = 'beard',          label = 'Barba',                type = 'overlay', overlayId = 1 },
    { id = 'beard_color',    label = 'Cor da Barba',         type = 'overlay_color', overlayId = 1 },
    { id = 'eyebrows',       label = 'Sobrancelhas',         type = 'overlay', overlayId = 2 },
    { id = 'eyebrow_color',  label = 'Cor das Sobrancelhas', type = 'overlay_color', overlayId = 2 },
    { id = 'makeup',         label = 'Maquilhagem',          type = 'overlay', overlayId = 4 },
    { id = 'blush',          label = 'Blush',                type = 'overlay', overlayId = 5 },
    { id = 'lipstick',       label = 'Batom',                type = 'overlay', overlayId = 8 },
}

-- ============================================================
-- TATUAGENS
-- ============================================================

ShopConfig.Tattoos = {
    torso = {
        { label = 'Águia Ocidental',   collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_000_M',   female = 'MP_MP_Biker_Tat_000_F' },
        { label = 'Dragão Tribal',     collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_001_M',   female = 'MP_MP_Biker_Tat_001_F' },
        { label = 'Leão Real',         collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_003_M',   female = 'MP_MP_Biker_Tat_003_F' },
        { label = 'Crânio Piloto',     collection = 'mpairraces_overlays',  male = 'MP_Airraces_Tattoo_000_M', female = 'MP_Airraces_Tattoo_000_F' },
        { label = 'Asas de Anjo',      collection = 'mphipster_overlays',   male = 'FM_Hip_M_Tat_000',        female = 'FM_Hip_F_Tat_000' },
        { label = 'Caveira Stunt',     collection = 'mpstunt_overlays',     male = 'MP_MP_Stunt_tat_000_M',   female = 'MP_MP_Stunt_tat_000_F' },
        { label = 'Rosa Negra',        collection = 'mplowrider_overlays',  male = 'MP_LR_Tat_006_M',         female = 'MP_LR_Tat_006_F' },
        { label = 'Coração Sagrado',   collection = 'mpchristmas2_overlays', male = 'MP_Xmas2_M_Tat_000',     female = 'MP_Xmas2_F_Tat_000' },
    },
    left_arm = {
        { label = 'Serpente',          collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_004_M',   female = 'MP_MP_Biker_Tat_004_F' },
        { label = 'Caveira Mexicana',  collection = 'mpchristmas2_overlays', male = 'MP_Xmas2_M_Tat_003',     female = 'MP_Xmas2_F_Tat_003' },
        { label = 'Tribal Antigo',     collection = 'mplowrider_overlays',  male = 'MP_LR_Tat_000_M',         female = 'MP_LR_Tat_000_F' },
        { label = 'Lobo Selvagem',     collection = 'mpgunrunning_overlays', male = 'MP_Gunrunning_Tattoo_000_M', female = 'MP_Gunrunning_Tattoo_000_F' },
        { label = 'Flor de Lótus',     collection = 'mphipster_overlays',   male = 'FM_Hip_M_Tat_002',        female = 'FM_Hip_F_Tat_002' },
    },
    right_arm = {
        { label = 'Pistão Motor',      collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_008_M',   female = 'MP_MP_Biker_Tat_008_F' },
        { label = 'Cruz Ornamentada',  collection = 'mpchristmas2_overlays', male = 'MP_Xmas2_M_Tat_006',     female = 'MP_Xmas2_F_Tat_006' },
        { label = 'Robô Futurista',    collection = 'mpstunt_overlays',     male = 'MP_MP_Stunt_tat_002_M',   female = 'MP_MP_Stunt_tat_002_F' },
        { label = 'Bússola',           collection = 'mpsmuggler_overlays',  male = 'MP_Smuggler_Tattoo_000_M', female = 'MP_Smuggler_Tattoo_000_F' },
        { label = 'Relógio Antigo',    collection = 'mphipster_overlays',   male = 'FM_Hip_M_Tat_003',        female = 'FM_Hip_F_Tat_003' },
    },
    left_leg = {
        { label = 'Corrente de Ferro', collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_011_M',   female = 'MP_MP_Biker_Tat_011_F' },
        { label = 'Estrela Náutica',   collection = 'mpchristmas2_overlays', male = 'MP_Xmas2_M_Tat_009',     female = 'MP_Xmas2_F_Tat_009' },
        { label = 'Tubarão',           collection = 'mpsmuggler_overlays',  male = 'MP_Smuggler_Tattoo_004_M', female = 'MP_Smuggler_Tattoo_004_F' },
        { label = 'Âncora',            collection = 'mphipster_overlays',   male = 'FM_Hip_M_Tat_006',        female = 'FM_Hip_F_Tat_006' },
    },
    right_leg = {
        { label = 'Engrenagem',        collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_013_M',   female = 'MP_MP_Biker_Tat_013_F' },
        { label = 'Chama Tribal',      collection = 'mpstunt_overlays',     male = 'MP_MP_Stunt_tat_004_M',   female = 'MP_MP_Stunt_tat_004_F' },
        { label = 'Polvo',             collection = 'mpsmuggler_overlays',  male = 'MP_Smuggler_Tattoo_006_M', female = 'MP_Smuggler_Tattoo_006_F' },
        { label = 'Diamante',          collection = 'mphipster_overlays',   male = 'FM_Hip_M_Tat_007',        female = 'FM_Hip_F_Tat_007' },
    },
    head = {
        { label = 'Teia de Aranha',    collection = 'mpbiker_overlays',     male = 'MP_MP_Biker_Tat_009_M',   female = 'MP_MP_Biker_Tat_009_F' },
        { label = 'Terceiro Olho',     collection = 'mphipster_overlays',   male = 'FM_Hip_M_Tat_005',        female = 'FM_Hip_F_Tat_005' },
        { label = 'Lágrima',           collection = 'mpchristmas2_overlays', male = 'MP_Xmas2_M_Tat_012',     female = 'MP_Xmas2_F_Tat_012' },
        { label = 'Cicatriz Tribal',   collection = 'mpgunrunning_overlays', male = 'MP_Gunrunning_Tattoo_003_M', female = 'MP_Gunrunning_Tattoo_003_F' },
    },
}

-- ============================================================
-- LOJAS E LOCALIZAÇÕES
-- ============================================================

ShopConfig.Stores = {
    {
        type = 'general',
        label = 'Loja 24/7',
        blip = { sprite = 59, color = 2, scale = 0.7 },
        items = {
            { name = 'bread',        label = 'Pão',               price = 5,   icon = '🍞' },
            { name = 'water',        label = 'Água',              price = 3,   icon = '💧' },
            { name = 'sandwich',     label = 'Sandes',            price = 8,   icon = '🥪' },
            { name = 'coffee',       label = 'Café',              price = 4,   icon = '☕' },
            { name = 'energy_drink', label = 'Energético',        price = 6,   icon = '⚡' },
            { name = 'bandage',      label = 'Ligadura',          price = 50,  icon = '🩹' },
            { name = 'medikit',      label = 'Kit Médico',        price = 150, icon = '🏥' },
            { name = 'phone',        label = 'Telemóvel',         price = 500, icon = '📱' },
            { name = 'radio',        label = 'Rádio',             price = 250, icon = '📻' },
        },
        locations = {
            vector3(25.7, -1347.3, 29.5),
            vector3(-47.0, -1758.7, 29.4),
            vector3(373.6, 325.2, 103.6),
            vector3(2557.4, 382.3, 108.6),
            vector3(-3039.5, 585.0, 7.9),
            vector3(-3243.3, 1000.7, 12.8),
            vector3(1729.2, 6414.1, 35.0),
            vector3(1960.1, 3740.5, 32.3),
            vector3(549.1, 2671.0, 42.2),
        },
    },
    {
        type = 'general',
        label = 'Loja de Ferramentas',
        blip = { sprite = 402, color = 31, scale = 0.7 },
        items = {
            { name = 'lockpick',  label = 'Lockpick',         price = 150, icon = '🔧' },
            { name = 'repairkit', label = 'Kit de Reparação',  price = 300, icon = '🔩' },
            { name = 'jerrycan',  label = 'Jerrycan',          price = 200, icon = '⛽' },
        },
        locations = {
            vector3(45.7, -1749.0, 29.6),
            vector3(2747.7, 3472.9, 55.7),
        },
    },
    {
        type = 'general',
        label = 'Loja de Armas',
        blip = { sprite = 110, color = 1, scale = 0.8 },
        items = {
            { name = 'weapon_pistol',       label = 'Pistola',          price = 2500,  icon = '🔫' },
            { name = 'weapon_combatpistol', label = 'Pistola Combate',  price = 3500,  icon = '🔫' },
            { name = 'weapon_snspistol',    label = 'Pistola SNS',      price = 1800,  icon = '🔫' },
            { name = 'weapon_bat',          label = 'Taco Basebol',     price = 500,   icon = '🏏' },
            { name = 'weapon_knife',        label = 'Faca',             price = 350,   icon = '🔪' },
            { name = 'weapon_flashlight',   label = 'Lanterna',         price = 200,   icon = '🔦' },
            { name = 'ammo_pistol',         label = 'Munição Pistola',  price = 100,   icon = '💥' },
            { name = 'armor',               label = 'Colete Balístico', price = 5000,  icon = '🛡️' },
        },
        locations = {
            vector3(-662.2, -935.3, 21.8),
            vector3(810.2, -2157.6, 29.6),
            vector3(1693.4, 3760.2, 34.7),
            vector3(-330.2, 6083.9, 31.5),
            vector3(252.4, -50.0, 69.9),
            vector3(22.5, -1107.2, 29.8),
            vector3(2567.7, 294.4, 108.7),
            vector3(-1117.6, 2698.6, 18.6),
            vector3(842.4, -1033.4, 28.2),
        },
    },
    {
        type = 'clothing',
        label = 'Loja de Roupas',
        blip = { sprite = 73, color = 47, scale = 0.7 },
        locations = {
            vector3(72.3, -1399.1, 29.4),
            vector3(-703.8, -152.3, 37.4),
            vector3(-167.9, -299.0, 39.7),
            vector3(428.7, -800.1, 29.5),
            vector3(-829.4, -1073.7, 11.3),
            vector3(-1447.8, -242.5, 49.8),
            vector3(11.6, 6514.2, 31.9),
            vector3(1696.3, 4829.3, 42.1),
            vector3(618.1, 2759.6, 42.1),
            vector3(-1193.4, -767.2, 17.3),
        },
    },
    {
        type = 'barber',
        label = 'Barbeiro',
        blip = { sprite = 71, color = 0, scale = 0.7 },
        locations = {
            vector3(-814.3, -183.8, 37.6),
            vector3(136.8, -1708.4, 29.3),
            vector3(-1282.6, -1116.8, 6.7),
            vector3(1931.5, 3729.7, 32.8),
            vector3(1212.8, -472.9, 66.2),
            vector3(-32.9, -152.3, 57.1),
            vector3(-278.1, 6228.5, 31.7),
        },
    },
    {
        type = 'tattoo',
        label = 'Estúdio de Tatuagens',
        blip = { sprite = 75, color = 1, scale = 0.7 },
        locations = {
            vector3(1322.6, -1651.9, 52.3),
            vector3(-1153.7, -1425.7, 4.9),
            vector3(322.1, 180.4, 103.6),
            vector3(-3169.4, 1075.0, 20.8),
            vector3(1864.1, 3747.9, 33.0),
        },
    },
}
