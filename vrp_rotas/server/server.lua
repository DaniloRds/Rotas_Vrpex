local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

api = {}
Tunnel.bindInterface('vrp_rotas', api)

function api.checkPermission(permission)
	local source = source
	return serverConfig.userHasPermissionToStartRoute(source, permission)
end

function api.giveRouteItems(routeName)
	local source = source
	local user_id = vRP.getUserId(source)
	local selectedRoute = CONFIG.ROUTES[routeName]
	
	if selectedRoute then
		if selectedRoute.RANDOM_ITEMS then
			local routeItems = selectedRoute.ITEMS
			local selectedItem = math.random(#routeItems)
			local itemName = routeItems[selectedItem].NAME
			local itemAmount = math.random(routeItems[selectedItem].MINIMUM, routeItems[selectedItem].MAXIMUM)
			
			if serverConfig.userHasSpaceInBackpack(source, itemName, itemAmount) then
				
				if vRP.hasPermission(user_id,"boostUm.permissao") then
					serverConfig.giveInventoryItem(source, itemName, itemAmount + 3)
				elseif vRP.hasPermission(user_id,"boostDois.permissao") then
					serverConfig.giveInventoryItem(source, itemName, itemAmount + 5) 
				elseif vRP.hasPermission(user_id,"boostTres.permissao") then
					serverConfig.giveInventoryItem(source, itemName, itemAmount*2 + 3)
				elseif vRP.hasPermission(user_id,"boostQuatro.permissao") then
					serverConfig.giveInventoryItem(source, itemName, itemAmount*2 + 6)

				else
					serverConfig.giveInventoryItem(source, itemName, itemAmount)
				end
			end
		else
			for key,value in pairs(selectedRoute.ITEMS) do	
				local itemName = value.NAME
				--print(itemName)
				local itemAmount = math.random(value.MINIMUM, value.MAXIMUM)
				if serverConfig.userHasSpaceInBackpack(source, itemName, itemAmount) then

					if vRP.hasPermission(user_id,"boostUm.permissao") then
						serverConfig.giveInventoryItem(source, itemName, itemAmount + 3)
					elseif vRP.hasPermission(user_id,"boostDois.permissao") then
						serverConfig.giveInventoryItem(source, itemName, itemAmount + 5) 
					elseif vRP.hasPermission(user_id,"boostTres.permissao") then
						serverConfig.giveInventoryItem(source, itemName, itemAmount*2+3)
					elseif vRP.hasPermission(user_id,"boostQuatro.permissao") then
						serverConfig.giveInventoryItem(source, itemName, itemAmount*2+6)

					else
						serverConfig.giveInventoryItem(source, itemName, itemAmount)
					end
				end
			end
		end
	end
end

-- [ONRESOURCESTART] --
AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	print('^2'..resourceName..' ^0UNITY: '..'^6SCRIPT INICIADO E FUNCIONANDO COM SUCESSO!^0')
  end) 