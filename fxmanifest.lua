fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'DJ Cleaning Job'
version '1.0.0'
author 'Dijkslag#0'

shared_script 'config.lua'
server_script '@oxmysql/lib/MySQL.lua'
server_script 'server/server.lua'
client_script 'client/client.lua'

dependencies {
    'ox_lib',
    'scully_emotemenu'
}

files {
    'html/dashboard.html',
    'html/dashboard.css',
    'html/dashboard.js'
}

ui_page 'html/dashboard.html'


