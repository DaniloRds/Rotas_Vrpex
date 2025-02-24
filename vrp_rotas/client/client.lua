local Tunnel = module('vrp', 'lib/Tunnel')

apiServer = Tunnel.getInterface('vrp_rotas')

api = {}
Tunnel.bindInterface('vrp_rotas', api)

local inRoute = false
local routeName = nil
local routeBlip = nil
local routeSelected = nil
local routePosition = 1

local userTimeout = GetGameTimer()

local loadedPeds = {}

CreateThread(function()
    while true do
        local sleepTime = 1000
       
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
       
        for orgName, orgInfos in pairs(CONFIG.ROUTES) do
            local distance = #(pedCoords - orgInfos.PED.LOCATION)
           
            if distance <= 15.0 then
                if loadedPeds[orgName] == nil then
                    local pedHash = GetHashKey(orgInfos.PED.HASHS[2])

                    RequestModel(pedHash)
                   
                    while not HasModelLoaded(pedHash) do
                        Wait(10)
                    end

                    loadedPeds[orgName] = CreatePed(4, orgInfos.PED.HASHS[1], orgInfos.PED.LOCATION.x, orgInfos.PED.LOCATION.y, orgInfos.PED.LOCATION.z - 1, orgInfos.PED.HEADING, false, true)

                    FreezeEntityPosition(loadedPeds[orgName], true)
                    SetEntityInvincible(loadedPeds[orgName], true)
                    SetBlockingOfNonTemporaryEvents(loadedPeds[orgName], true)
                    SetModelAsNoLongerNeeded(pedHash)
                end
            else
                if loadedPeds[orgName] then
                    DeleteEntity(loadedPeds[orgName])
                    
                    loadedPeds[orgName] = nil
                end
            end
        end

        Wait(sleepTime)
    end
end)

CreateThread(function()
    while true do
        local sleepTime = 1000
        
        if not inRoute then
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)

            for orgName, orgInfos in pairs(CONFIG.ROUTES) do
                local distance = #(pedCoords - orgInfos.PED.LOCATION)
               
                if distance <= 1 then
                    sleepTime = 0
                    
                    DrawText3Ds(orgInfos.PED.LOCATION.x, orgInfos.PED.LOCATION.y, orgInfos.PED.LOCATION.z + 1, orgInfos.PED.TEXT)
                   
                    if distance <= 1 then
                        if IsControlJustPressed(1, 38) and apiServer.checkPermission(orgInfos.PERMISSIONS) and not clientConfig.isPedInVehicle(ped) and not clientConfig.isPedDead(ped) then
                            inRoute = true
                            routeName = orgName
                            routeSelected = orgInfos.ROUTE_LOCATIONS
                            routeRandom = orgInfos.RANDOM_ROUTES
                            
                            createRouteThread()
                            setNextPositionBlip()
                            createBlipPosition()
                           
                            CONFIG.NOTIFY('sucess', CONFIG.LANGUAGE.ROUTE_STARTED, 10000)
                        end
                    end
                end
            end
        end

        Wait(sleepTime)
    end
end)

function createRouteThread()
    CreateThread(function()
        while inRoute do
            local sleepTime = 1000
          
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local distance = #(pedCoords - routeSelected[routePosition])
            
            if distance <= 20.0 then
                sleepTime = 1
                
                DrawMarker(21, routeSelected[routePosition], 0, 0, 0, 0.0, 0, 0, 0.5, 0.5, 0.4, 255, 0, 0, 50, 0, 0, 0, 1)
                
                if distance <= 2.0 then
                    drawTxt("PRESSIONE  ~r~E~w~  PARA COLETAR",1,0.5,0.93,0.5,255,255,255,180)
                    if IsControlJustPressed(1, 38) and userTimeout <= GetGameTimer() and not clientConfig.isPedInVehicle(ped) and not clientConfig.isPedDead(ped) then
                        userTimeout = GetGameTimer() + 2000
                        
                        clientConfig.userGettingItemsFromRoute(ped)

                        setNextPositionBlip()
                        createBlipPosition()

                        apiServer.giveRouteItems(routeName)
                    end
                end
            end
    
            Wait(sleepTime)
        end
    end)
end

RegisterKeyMapping('vRP:LeaveRoute', CONFIG.LANGUAGE.COMMAND_LABEL, 'keyboard', CONFIG.CONTROL_TO_STOP_ROUTE)
RegisterCommand('vRP:LeaveRoute', function()
    if inRoute then
        inRoute = false
        routeName = nil
        routeSelected = nil
        routePosition = 1

        if DoesBlipExist(routeBlip) then
            RemoveBlip(routeBlip)
    
            routeBlip = nil
        end 

        CONFIG.NOTIFY('sucess', CONFIG.LANGUAGE.ROUTE_STOPED, 10000)
    end
end)

-- [Funções] --

function setNextPositionBlip()
    if routeRandom then
        routePosition = math.random(#routeSelected)
    else
        if routePosition == #routeSelected then
            routePosition = 1
        else
            routePosition = routePosition + 1
        end
    end
end

function createBlipPosition()
    if DoesBlipExist(routeBlip) then
        RemoveBlip(routeBlip)

        routeBlip = nil
    end 
    
    routeBlip = AddBlipForCoord(routeSelected[routePosition])
    
	if DoesBlipExist(routeBlip) then
        SetBlipColour(routeBlip, 5)
        SetBlipScale(routeBlip, 0.4)
        SetBlipSprite(routeBlip, 1)
        SetBlipAsShortRange(routeBlip, false)
        SetBlipRoute(routeBlip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(CONFIG.LANGUAGE.BLIP_LABEL)
        EndTextCommandSetBlipName(routeBlip)
	end

end

function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        SetTextScale(0.39, 0.39)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 235)
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.005 + factor, 0.04, 0, 0, 0, 145)
    end
end

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end