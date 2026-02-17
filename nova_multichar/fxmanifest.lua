fx_version 'cerulean'
game 'gta5'

name 'nova_multichar'
description 'NOVA Framework - Seleção e Criação de Personagem'
author 'NOVA Development'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@oxmysql/lib/MySQL.lua',
    'locales.lua',
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

dependencies {
    'nova_core',
}
