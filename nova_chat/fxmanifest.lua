fx_version 'cerulean'
game 'gta5'

name 'nova_chat'
description 'NOVA Framework - Chat'
version '1.0.0'

provide 'chat'

shared_scripts {
    'locales.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
