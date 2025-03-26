RegisterServerEvent('high_morte:ReviveOx')
AddEventHandler('high_morte:ReviveOx', function(targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xPlayer or not xTarget then return end
    if xPlayer.getInventoryItem('medikit').count < 1 then
        xPlayer.showNotification("Ti serve un medikit!")
        return
    end

    xPlayer.removeInventoryItem('medikit', 1)
    TriggerClientEvent('high_morte:ReviveEvent', targetId)
end)

RegisterNetEvent('high_morte:AttaccaAmbulanza')
AddEventHandler('high_morte:AttaccaAmbulanza', function (targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xPlayer or not xTarget then return end
    TriggerClientEvent('high_morte:AttaccaAmbulanza', targetId)
end)

RegisterNetEvent('high_morte:StaccaAmbulanza')
AddEventHandler('high_morte:StaccaAmbulanza', function (targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xPlayer or not xTarget then return end
    TriggerClientEvent('high_morte:StaccaAmbulanza', targetId)
end)

RegisterNetEvent('high_morte:Cura')
AddEventHandler('high_morte:Cura', function (targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if not xPlayer or not xTarget then return end
    TriggerClientEvent('high_morte:Cura:Cl', targetId)
end)