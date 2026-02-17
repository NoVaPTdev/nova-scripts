fx_version 'cerulean'
game 'gta5'

name 'nova_notify'
description 'NOVA Framework - Sistema de Notificações'
author 'NOVA Development'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

exports {
    'ShowNotification',
    'SendNotification',
}
