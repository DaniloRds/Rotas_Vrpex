local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRP = Proxy.getInterface('vRP')

clientConfig = {
    userGettingItemsFromRoute = function(ped)
        LocalPlayer.state:set('Commands', true, false)
        LocalPlayer.state:set('Cancel', true, false)

        TriggerEvent('Progress', 5000, 'Procurando...')
        
        clientConfig.playAnim(ped, 'amb@prop_human_parking_meter@female@idle_a', 'idle_a_female')

        Wait(5000)

        LocalPlayer.state:set('Commands', false, false)
        LocalPlayer.state:set('Cancel', false, false)

        ClearPedTasks(ped)
    end, 

    isPedDead = function(ped)
        return GetEntityHealth(ped) <= 101
    end, 

    isPedInVehicle = function(ped)
        return IsPedInAnyVehicle(ped)
    end, 

    playAnim = function(ped, animDict, animName)
        ClearPedTasks(ped)

        CreateThread(function()
            RequestAnimDict(animDict)

            while not HasAnimDictLoaded(animDict) do
                RequestAnimDict(animDict)

                Wait(10)
            end

            if HasAnimDictLoaded(animDict) then
                TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 1, 0, 0, 0, 0)
            end
        end)
    end
}