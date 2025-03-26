fx_version 'adamant'
game 'gta5'
lua54 'yes'
author 'High Studio'

client_scripts {
    'client/client.lua',
    'client/client_job.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/server_job.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}