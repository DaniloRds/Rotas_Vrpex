fx_version 'bodacious'
game 'gta5'

author 'Rurian Jost [RKG]'
description 'Edited By Unity FiveM | discord.gg/pbT5wVp8e9' 
version '2.0.5'

shared_script {
	'@vrp/lib/utils.lua', 
	'config/config.lua'
}

server_scripts {
	'@vrp/lib/utils.lua', 
	'config/server/*.lua', 
	'server/*.lua'
}

client_scripts {
	'config/client/*.lua', 
	'client/*.lua'
}