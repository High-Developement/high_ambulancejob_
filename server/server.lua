ESX = exports["es_extended"]:getSharedObject()

local morti = {}

RegisterCommand('rianima', function(src, args)
    local targetId = tonumber(args[1])
    if targetId then
        local xPlayer = ESX.GetPlayerFromId(src)
        local GroupXplayer = xPlayer.getGroup()
        if GroupXplayer == "admin" then
            TriggerClientEvent("high_morte:ReviveEvent", targetId)
        end
    end
end, false)

RegisterServerEvent("high_morte:AggiornaMorte")
AddEventHandler("high_morte:AggiornaMorte", function(bool)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier

    if morti[identifier] ~= bool then
        morti[identifier] = bool
        TriggerClientEvent("high_morte:AggiornaMorte", src, morti[identifier])
    end
end)