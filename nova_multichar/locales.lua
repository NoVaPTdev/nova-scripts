-- NOVA Multichar - Locales (PT/EN)
local _lang = nil

local Strings = {
    pt = {
        unknown_nationality = 'Desconhecida',
        -- NUI
        nui_title = 'NOVA',
        nui_title_accent = 'Framework',
        nui_subtitle = 'Seleciona o teu personagem',
        nui_create_new = 'Criar Novo',
        nui_delete = 'Eliminar',
        nui_confirm_delete = 'Tens a certeza que queres eliminar este personagem?',
        nui_create_char = 'Criar Personagem',
        nui_firstname = 'Nome',
        nui_lastname = 'Apelido',
        nui_dob = 'Data de Nascimento',
        nui_dob_placeholder = 'DD/MM/AAAA',
        nui_nationality = 'Nacionalidade',
        nui_nationality_default = 'Portuguesa',
        nui_gender = 'Género',
        nui_male = 'Masculino',
        nui_female = 'Feminino',
        nui_back = 'Voltar',
        nui_next_appearance = 'Aparência →',
        nui_appearance = 'Aparência',
        nui_tab_face = 'Rosto',
        nui_tab_hair = 'Cabelo',
        nui_tab_clothes = 'Roupa',
        nui_mother = 'Mãe',
        nui_father = 'Pai',
        nui_resemblance = 'Semelhança',
        nui_skin_tone = 'Tom de Pele',
        nui_eyebrows = 'Sobrancelhas',
        nui_hair = 'Cabelo',
        nui_hair_color = 'Cor do Cabelo',
        nui_beard = 'Barba',
        nui_beard_color = 'Cor da Barba',
        nui_shirt = 'Camisola',
        nui_undershirt = 'Interior',
        nui_pants = 'Calças',
        nui_shoes = 'Sapatos',
        nui_create_btn = 'Criar',
        nui_fill_name = 'Preenche o nome e apelido.',
        nui_unemployed = 'Desempregado',
        nui_cash = 'Dinheiro',
        nui_bank = 'Banco',
    },
    en = {
        unknown_nationality = 'Unknown',
        nui_title = 'NOVA',
        nui_title_accent = 'Framework',
        nui_subtitle = 'Select your character',
        nui_create_new = 'Create New',
        nui_delete = 'Delete',
        nui_confirm_delete = 'Are you sure you want to delete this character?',
        nui_create_char = 'Create Character',
        nui_firstname = 'First Name',
        nui_lastname = 'Last Name',
        nui_dob = 'Date of Birth',
        nui_dob_placeholder = 'DD/MM/YYYY',
        nui_nationality = 'Nationality',
        nui_nationality_default = 'Portuguese',
        nui_gender = 'Gender',
        nui_male = 'Male',
        nui_female = 'Female',
        nui_back = 'Back',
        nui_next_appearance = 'Appearance →',
        nui_appearance = 'Appearance',
        nui_tab_face = 'Face',
        nui_tab_hair = 'Hair',
        nui_tab_clothes = 'Clothes',
        nui_mother = 'Mother',
        nui_father = 'Father',
        nui_resemblance = 'Resemblance',
        nui_skin_tone = 'Skin Tone',
        nui_eyebrows = 'Eyebrows',
        nui_hair = 'Hair',
        nui_hair_color = 'Hair Color',
        nui_beard = 'Beard',
        nui_beard_color = 'Beard Color',
        nui_shirt = 'Shirt',
        nui_undershirt = 'Undershirt',
        nui_pants = 'Pants',
        nui_shoes = 'Shoes',
        nui_create_btn = 'Create',
        nui_fill_name = 'Please fill in first and last name.',
        nui_unemployed = 'Unemployed',
        nui_cash = 'Cash',
        nui_bank = 'Bank',
    },
}

local function GetLang()
    if _lang then return _lang end
    _lang = 'pt'
    pcall(function()
        local cfg = exports['nova_core']:GetConfig()
        if cfg and cfg.Locale then _lang = cfg.Locale end
    end)
    return _lang
end

function MCL(key, ...)
    local lang = GetLang()
    local str = (Strings[lang] and Strings[lang][key]) or Strings['pt'][key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function MCGetAllStrings()
    local lang = GetLang()
    return Strings[lang] or Strings['pt']
end
