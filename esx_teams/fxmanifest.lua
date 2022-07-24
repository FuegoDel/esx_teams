fx_version 'adamant'
author 'Fuego'
description 'A Script designed to help servers achieve achieve creating their own criminal/team/organization system'
game 'gta5'
lua54 'yes'
  


client_scripts {    
    'client.lua', 
} 

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    'server.lua'
}

ui_page "html/index.html"

files{
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'html/fonts/*.woff',
    'html/fonts/*.ttf',
    'html/fonts/*.woff2'
}

shared_scripts {
    'config.lua'
}