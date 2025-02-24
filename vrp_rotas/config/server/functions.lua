local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRPclient = Tunnel.getInterface('vRP')
vRP = Proxy.getInterface('vRP')

serverConfig = {
    getUserId = function(userSource)
        return vRP.getUserId(userSource) or vRP.Passport(userSource)
    end, 
    
    userHasPermissionToStartRoute = function(userSource, permission)
        local userId = serverConfig.getUserId(userSource)
	
        if type(permission) == 'table' then
            for _, perm in ipairs(permission) do
                if vRP.hasPermission(userId, perm) then
                    return true
                end
            end

            return false
        else
            if vRP.hasPermission(userId, permission) then
                return true
            end

            return false
        end
    end, 

    getInventoryWeight = function(userId)
        return vRP.getInventoryWeight(userId) or vRP.computeInvWeight(userId) or vRP.InventoryWeight(userId)
    end, 

    getInventoryMaxWeight = function(userId)
        return vRP.getInventoryMaxWeight(userId) or vRP.getBackpack(userId) or vRP.getWeight(userId) or vRP.GetWeight(userId)
    end, 

    giveInventoryItem = function(userSource, itemName, itemAmount)
        local userId = serverConfig.getUserId(userSource)

        vRP.giveInventoryItem(userId, itemName, itemAmount, true)
       
        -- vRP.GiveItem(userId, itemName, itemAmount, true) -- CrNetwork
    end, 

    getItemWeight = function(itemName)
        return vRP.itemWeightList(itemName) or vRP.getItemWeight(itemName) or 1
    end, 

    userHasSpaceInBackpack = function(userSource, itemName, itemAmount)
        local userId = serverConfig.getUserId(userSource)
       
        local invWeight = serverConfig.getInventoryWeight(userId)
        local invMaxWeight = serverConfig.getInventoryMaxWeight(userId)

        local itemWeight = serverConfig.getItemWeight(itemName)

        if invWeight + itemWeight * itemAmount > invMaxWeight then
            CONFIG.NOTIFY(userSource, 'denied', CONFIG.LANGUAGE.FULL_BACKPACK, 10000)

            return false
        end

        return true
    end
}