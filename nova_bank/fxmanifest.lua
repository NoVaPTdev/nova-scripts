fx_version 'cerulean'
game 'gta5'

name 'nova_bank'
description 'NOVA Framework - Sistema Bancário'
author 'NOVA Development'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'config.lua',
    'locales.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
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
