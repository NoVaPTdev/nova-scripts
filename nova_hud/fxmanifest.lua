fx_version 'cerulean'
game 'gta5'

name 'nova_hud'
description 'NOVA Framework - HUD Básica'
author 'NOVA Development'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'locales.lua',
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

exports {
    'ToggleHud',
    'IsHudVisible',
    'ProgressBar',
    'CancelProgressBar',
    'IsProgressActive',
}
