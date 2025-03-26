ESX = exports["es_extended"]:getSharedObject()

AddEventHandler("onClientMapStart", function()
    exports.spawnmanager:spawnPlayer()
    Wait(1500)
    exports.spawnmanager:setAutoSpawn(false)
end)

local isDead = false
local isKnock = false

AddEventHandler('gameEventTriggered', function(name, data)
    if name == "CEventNetworkEntityDamage" and data[1] == PlayerPedId() and data[6] and data[6] == 1 then
        if not isKnock and not isDead then
            isKnock = true
            TriggerServerEvent("high_morte:AggiornaMorte", true)
        end
    end
end)

function ResetVariables()
    isKnock = false
    isDead = false
end

RegisterNetEvent("high_morte:AggiornaMorte")
AddEventHandler("high_morte:AggiornaMorte", function(bool)
    isKnock = bool
    if isKnock then
        StartDeathAnimation()
    else
        ResetVariables()
    end
end)

RequestanimDict = function (animazione)
    if not HasAnimDictLoaded(animazione) then
		RequestAnimDict(animazione)
		while not HasAnimDictLoaded(animazione) do
			Wait(1)
		end
	end
end

function StartDeathAnimation()

    LocalPlayer.state:set("dead", true, true)
    LocalPlayer.state.injuries = true

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    ClearPedTasksImmediately(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, false, false)
    SetEntityInvincible(ped, true)

    RequestanimDict('random@dealgonewrong')
    RequestanimDict('move_injured_ground')

    TaskPlayAnim(ped, 'random@dealgonewrong', 'idle_a', 8.0, 8.0, -1, 1, 0, 0, 0, 0)

    HandleMovementAnimation(ped)

    Citizen.CreateThread(function()
        while isKnock do
            Wait(0)

            local ped = PlayerPedId()
            local camRot = Citizen.InvokeNative(0x837765A25378F0BB, 0, Citizen.ResultAsVector())
            SetEntityHeading(ped, camRot.z)

            if IsControlPressed(0, 32) then
                if not IsEntityPlayingAnim(ped, 'move_injured_ground', 'sidel_loop', 3) then
                    TaskPlayAnim(ped, 'move_injured_ground', 'sidel_loop', 1.0, -8.0, -1, 1, 0, 0, 0, 0)
                end
            elseif not IsEntityPlayingAnim(ped, 'random@dealgonewrong', 'idle_a', 3) then
                TaskPlayAnim(ped, 'random@dealgonewrong', 'idle_a', 2.0, -8.0, -1, 0, 0, 0, 0, 0)
            end
        end
    end)

    CreateThread(function()
        local success = lib.progressCircle({
            duration = Config.tempoKnock,
            position = 'bottom',
            useWhileDead = true,
            canCancel = false,
        })

        if success then
            EndDeathAnimation()
        else
            print('respawnato')
        end
    end)
end

function HandleMovementAnimation(ped)
    if IsControlPressed(0, 32) then
        if not IsEntityPlayingAnim(ped, 'move_injured_ground', 'sidel_loop', 3) then
            TaskPlayAnim(ped, 'move_injured_ground', 'sidel_loop', 1.0, -8.0, -1, 1, 0, 0, 0, 0)
        end
    elseif not IsEntityPlayingAnim(ped, 'random@dealgonewrong', 'idle_a', 3) then
        TaskPlayAnim(ped, 'random@dealgonewrong', 'idle_a', 2.0, -8.0, -1, 0, 0, 0, 0, 0)
    end
end

function EndDeathAnimation()

    if lib.progressActive() then
        lib.cancelProgress()
    end
    isKnock = false
    isDead = true
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    RequestanimDict('dead')

    if not IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3) then
        TaskPlayAnim(ped, 'dead', 'dead_a', 8.0, -8.0, -1, 0, 0, 0, 0)
    end

    Citizen.CreateThread(function ()
        local startTime = GetGameTimer()
        local timer = Config.TimerMorte
        while isDead do
            Wait(0)
            TaskPlayAnim(ped, 'dead', 'dead_a', 8.0, -8.0, -1, 0, 0, 0, 0)

            local elapsed = (GetGameTimer() - startTime) / 1000
            local remaining = timer - elapsed
            local playerCoords = GetEntityCoords(PlayerPedId())

            if remaining > 0 then
                ESX.Game.Utils.DrawText3D(playerCoords + vector3(0, 0, 0.1), 'Premi [G] per chiamare i medici', 1, 4)
                ESX.Game.Utils.DrawText3D(playerCoords + vector3(0, 0, 0.2), 'Tempo rimanente: ' .. math.ceil(remaining) .. ' secondi', 1, 4)
                if IsControlJustReleased(0, 47) then
                    print('Medici avvisati')
                end
            else
                ESX.Game.Utils.DrawText3D(playerCoords + vector3(0, 0, 0.2), 'Premi [E] per respawnare', 1, 4)
                ESX.Game.Utils.DrawText3D(playerCoords + vector3(0, 0, 0.1), 'Premi [G] per chiamare i medici', 1, 4)
                if IsControlJustReleased(0, 47) then
                    print('Medici avvisati')
                end
                if IsControlJustReleased(0, 38) then
                    RespawnOspedale()
                    break
                end
            end
        end
    end)

    DoScreenFadeOut(400)
    Wait(400)
    DoScreenFadeIn(400)
end

-- RESPAWN OSPEDALE

RespawnOspedale = function ()
    if lib.progressActive() then
        lib.cancelProgress()
    end
    ResetVariables()

    LocalPlayer.state:set("dead", false,false)
    LocalPlayer.state.injuries = false

    TriggerServerEvent("high_morte:AggiornaMorte", false)

    local ped = PlayerPedId()
    ClearPedTasks(ped)
    Wait(1)
    ClearPedTasks(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetEntityCoordsNoOffset(ped, 295.5511, -583.1954, 43.1578, false, false, false, true)
    NetworkResurrectLocalPlayer(295.5511, -583.1954, 43.1578, 70.0005, false, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    DoScreenFadeOut(400)
    Wait(400)
    DoScreenFadeIn(400)
end

-- EVENTO REVIVE

RegisterNetEvent('high_morte:ReviveEvent')
AddEventHandler('high_morte:ReviveEvent', function()
    if lib.progressActive() then
        lib.cancelProgress()
    end

    LocalPlayer.state:set("dead", false, false)
    LocalPlayer.state.injuries = false

    ResetVariables()
    TriggerServerEvent("high_morte:AggiornaMorte", false)

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    SetEntityHealth(ped, GetEntityMaxHealth(ped))    
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    Wait(1)
    ClearPedTasks(ped)

    DoScreenFadeIn(300)
    Wait(350)
    DoScreenFadeIn(400)
end)