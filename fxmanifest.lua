fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Robert Trainor <trainordevelopments@outlook.com>'
description 'Simple police request resource.'
version '3.0.0'

dependency 'qb-core'

lua54 'yes'

shared_scripts {
    'Shared/Config.lua',
    '@ox_lib/init.lua',
    'Shared/Utils.lua'
}

client_script 'Client/CL_Main.lua'

server_script 'Server/SV_Main.lua'