local high_ambulancejobOx = {
    {
        name = 'high_morte:ReviveOxPlayer',
        event = 'high_morte:ReviveOxPlayer',
        icon = 'fa-solid fa-person',
        label = 'Rianima',
        canInteract = function(entity, distance, coords, name, bone)
            return true
        end
    },
    {
        name = 'high_morte:CaricaNellAmbulanza',
        event = 'high_morte:CaricaNellAmbulanza',
        icon = 'fa-solid fa-person',
        label = 'Carica nell\'ambulanza',
        canInteract = function(entity, distance, coords, name, bone)
            if not entity or not entity then return false end
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
                local targetPed = entity
                local targetCoords = GetEntityCoords(targetPed)
                local vehicle = GetClosestVehicle(targetCoords.x, targetCoords.y, targetCoords.z, 5.0, 0, 70)
    
                if vehicle and DoesEntityExist(vehicle) then
                    local model = GetEntityModel(vehicle)
                    if model == GetHashKey("ambulance") then
                        return true
                    end
                end
    
                return false
            else
                return false
            end
        end
    },
    {
        name = 'high_morte:Cura',
        event = 'high_morte:Cura',
        icon = 'fa-solid fa-person',
        label = 'Cura',
        canInteract = function(entity, distance, coords, name, bone)
            return ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance'
        end
    },
}

exports.ox_target:addGlobalPlayer(high_ambulancejobOx)

-- EVENTO CARICA NELL'AMBULANZA
local attacatoA = false
local vuoiAttaccare = false
RegisterNetEvent('high_morte:CaricaNellAmbulanza')
AddEventHandler('high_morte:CaricaNellAmbulanza', function(data)
    if not data or not data.entity then return end
    vuoiAttaccare = true
    local playerId = NetworkGetPlayerIndexFromPed(data.entity)

    local serverId = GetPlayerServerId(playerId)
    TriggerServerEvent('high_morte:AttaccaAmbulanza', serverId)
    lib.showTextUI('[G] - Per uscire dall\'ambulanza')

    CreateThread(function()
        while vuoiAttaccare do
            Wait(1)
            if IsControlJustPressed(0, 47) then
                TriggerServerEvent('high_morte:StaccaAmbulanza', serverId)
                vuoiAttaccare = false
                lib.hideTextUI()
            end
        end
    end)

end)

RegisterNetEvent('high_morte:AttaccaAmbulanza')
AddEventHandler('high_morte:AttaccaAmbulanza', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed, true)

    if not DoesEntityExist(vehicle) then
        vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 10.0, 0, 127)
    end
    
    if attacatoA then
        ESX.ShowNotification("Il player è già attaccato.")
        return
    end

    if DoesEntityExist(vehicle) and GetEntityModel(vehicle) == GetHashKey("ambulance") then
        local offset = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.5)

        AttachEntityToEntity(playerPed, vehicle, 0, 0.0, -2.5, 1.5, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
        attacatoA = true
        ESX.ShowNotification("Sei stato caricato nell'ambulanza.")
    else
        ESX.ShowNotification("Nessuna ambulanza nelle vicinanze.")
    end

    CreateThread(function()
        RequestanimDict('mini@cpr@char_b@cpr_def')
        while attacatoA do
            Wait(0)
            if not IsEntityPlayingAnim(PlayerPedId(),'mini@cpr@char_b@cpr_def', "cpr_pumpchest_idle") then
                TaskPlayAnim(PlayerPedId(), 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 8.0, -8.0, -1, 0, 0, 0, 0)
            end
        end
    end)
end)

-- EVENTO STACCA DALL'AMBULANZA
RegisterNetEvent('high_morte:StaccaAmbulanza')
AddEventHandler('high_morte:StaccaAmbulanza', function ()
    local playerPed = PlayerPedId()

    DetachEntity(playerPed, true, true)
    ClearPedTasks(playerPed)
    PlaceObjectOnGroundProperly(playerPed)
    FreezeEntityPosition(playerPed, false)
    attacatoA = false
    ESX.ShowNotification("Sei uscito dall'ambulanza.")
end)

-- EVENTO REVIVE CON MEDIKIT
RegisterNetEvent('high_morte:ReviveOxPlayer')
AddEventHandler('high_morte:ReviveOxPlayer', function(data)

    local medikitcheck = exports.ox_inventory:Search('count', 'medikit') 
    if medikitcheck < 1 then
        ESX.ShowNotification('Ti serve un medikit!', 'error')
        return
    end

    if not data or not data.entity then return end
    local playerId = NetworkGetPlayerIndexFromPed(data.entity)
    
    if playerId and playerId ~= -1 then

        exports.rprogress:Custom({
            maxAngle = 240,
            rotation = -120,
            Label = "Rianimando...",
            Duration = 8000,
            Animation = {
                animationDictionary = "mini@cpr@char_a@cpr_str",
                animationName = "cpr_pumpchest",
            },
            onStart = function ()
                FreezeEntityPosition(PlayerPedId(), true)
            end,
            onComplete = function(cancelled)
                FreezeEntityPosition(PlayerPedId(), false)
                ClearPedTasksImmediately(PlayerPedId())

                local serverId = GetPlayerServerId(playerId)
                TriggerServerEvent('high_morte:ReviveOx', serverId)
            end,
        })
    end
end)

RegisterNetEvent('high_morte:Cura')
AddEventHandler('high_morte:Cura', function (data)
    local bandageCheck = exports.ox_inventory:Search('count', 'bandage')
    if bandageCheck < 1 then
        ESX.ShowNotification('Ti serve una benda!', 'error')
        return
    end

    if not data or not data.entity then return end
    local playerId = NetworkGetPlayerIndexFromPed(data.entity)
    
    if playerId and playerId ~= -1 then

        exports.rprogress:Custom({
            maxAngle = 240,
            rotation = -120,
            Label = "Curando...",
            Duration = 4000,
            onStart = function ()
                FreezeEntityPosition(PlayerPedId(), true)
            end,
            onComplete = function(cancelled)
                FreezeEntityPosition(PlayerPedId(), false)
                ClearPedTasksImmediately(PlayerPedId())

                local serverId = GetPlayerServerId(playerId)
                TriggerServerEvent('high_morte:Cura', serverId)
            end,
        })
    end
end)

RegisterNetEvent('high_morte:Cura:Cl')
AddEventHandler('high_morte:Cura:Cl', function ()
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, 200)
end)