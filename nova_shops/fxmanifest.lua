fx_version 'cerulean'
game 'gta5'

name 'nova_shops'
description 'NOVA Framework - Lojas (Roupas, Barbeiro, Tatuagens, Lojas Gerais)'
version '1.0.0'

dependencies {
    'nova_core',
}

shared_scripts {
    'config.lua',
    'locales.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
