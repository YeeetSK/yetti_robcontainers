fx_version "cerulean"
game "gta5"
lua54 'yes'

author 'Yetti Development'
description 'Container Robbery Script'

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

escrow_ignore {
    'config.lua'
}

