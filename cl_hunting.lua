ESX = nil

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local baitexists, baitLocation, HuntedAnimalTable, busy = 0, nil, {}, false
DecorRegister("MyAnimal", 2) -- don't touch it

function isValidZone()
    local zoneInH = GetNameOfZone(GetEntityCoords(PlayerPedId()))
    for _, zone in pairs(Config.HuntingZones) do
        if zoneInH == zone then
            return true
        end
    end
end

function SetSpawn(baitLocation)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local spawnCoords = nil
    while spawnCoords == nil do
        local spawnX = math.random(-Config.SpawnDistance, Config.SpawnDistance)
        local spawnY = math.random(-Config.SpawnDistance, Config.SpawnDistance)
        local spawnZ = baitLocation.z
        local vec = vector3(baitLocation.x + spawnX, baitLocation.y + spawnY, spawnZ)
        if #(playerCoords - vec) > Config.SpawnDistance then
            spawnCoords = vec
        end
    end
    local worked, groundZ, normal = GetGroundZAndNormalFor_3dCoord(spawnCoords.x, spawnCoords.y, 1023.9)
    spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ)
    return spawnCoords
end

function baitDown(baitLocation)
    Citizen.CreateThread(function()
        while baitLocation ~= nil do
            local coords = GetEntityCoords(PlayerPedId())
            if Config.Debug then
                print('Distance from bait: ' .. #(baitLocation - coords))
            end
            if #(baitLocation - coords) > Config.DistanceFromBait then
                if Config.ChanceToSpawnAnimal < 1.0 then
                    if math.random() < Config.ChanceToSpawnAnimal then
                        SpawnAnimal(baitLocation)
                        baitLocation = nil
                    end
                end
            end
            Citizen.Wait(15000)
        end
    end)
end


function SpawnAnimal(location)
    if Config.Debug then
        print('Attempting to spawn an animal...')
    end
    local spawn = SetSpawn(location)
    local model = GetHashKey(Config.Animals[math.random(1, #Config.Animals)])
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(10) end
    local prey = CreatePed(28, model, spawn, true, true, true)
    DecorSetBool(prey, "MyAnimal", true)
    TaskGoStraightToCoord(prey, location, 1.0, -1, 0.0, 0.0)
    table.insert(HuntedAnimalTable, {id = prey, animal = model})
    SetModelAsNoLongerNeeded(model)
    Citizen.CreateThread(function()
        local destination = false
        while not IsPedDeadOrDying(prey) and not destination do
            local preyCoords = GetEntityCoords(prey)
            local distance = #(location - preyCoords)

            if distance < 0.35 then
                ClearPedTasks(prey)
                Citizen.Wait(1500)
                TaskStartScenarioInPlace(prey, "WORLD_DEER_GRAZING", 0, true)
                Citizen.SetTimeout(8000, function()
                    destination = true
                end)
            end
            if #(preyCoords - GetEntityCoords(PlayerPedId())) < 15.0 then
                ClearPedTasks(prey)
                TaskSmartFleePed(prey, PlayerPedId(),600.0, -1, true, true)
                destination = true
            end
            Citizen.Wait(1000)
        end
        if not IsPedDeadOrDying(prey) then
            TaskSmartFleePed(prey, PlayerPedId(),600.0, -1, true, true)
        end
    end)
end

RegisterNetEvent('AOD-huntingbait')
AddEventHandler('AOD-huntingbait', function()
    if not isValidZone() then
        Notify(Config.Notifications.cannot_place_bait)
        return
    end
    if busy then
        Notify(Config.Notifications.exploit_detected)
        return
    end
    if baitexists ~= 0 and GetGameTimer() < (baitexists + 90000) then
        Notify(Config.Notifications.wait_to_place_bait)
        return
    end
    baitexists = nil
    busy = true
    local player = PlayerPedId()
    TaskStartScenarioInPlace(player, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    exports['progressBars']:startUI((15000), Config.Notifications.baiting)
    Citizen.Wait(15000)
    ClearPedTasks(player)
    baitexists = GetGameTimer()
    Notify(string.format(Config.Notifications.bait_placed, Config.DistanceFromBait))
    TriggerServerEvent('AOD-hunt:TakeItem', 'huntingbait')
    baitDown(GetEntityCoords(PlayerPedId()))
    busy = false
end)

RegisterNetEvent('AOD-huntingknife')
AddEventHandler('AOD-huntingknife', function()
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        for index, value in ipairs(HuntedAnimalTable) do
            local AnimalCoords = GetEntityCoords(value.id)
            local PlyCoords = GetEntityCoords(PlayerPedId())
            local AnimalHealth = GetEntityHealth(value.id)
            local PlyToAnimal = #(PlyCoords - AnimalCoords)
            local gun = Config.HuntingWeapon
                    
            local d = GetPedCauseOfDeath(value.id)
            if DoesEntityExist(value.id) and AnimalHealth <= 0 and PlyToAnimal < 2.0 and (gun == d or gun == nil) and not busy then
                busy = true
                LoadAnimDict('amb@medic@standing@kneel@base')
                LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
                TaskTurnPedToFaceEntity(PlayerPedId(), value.id, -1)
                Citizen.Wait(1500)
                ClearPedTasksImmediately(PlayerPedId())
                TaskPlayAnim(player, "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
                TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
                exports['progressBars']:startUI((5000), Config.Notifications.harvesting)
                Citizen.Wait(5000)
                ClearPedTasks(PlayerPedId())
                DeleteEntity(value.id)
                TriggerServerEvent('AOD-butcheranimal', value.animal)
                busy = false
                table.remove(HuntedAnimalTable, index)
            elseif busy then
                Notify(Config.Notifications.exploit_detected)
            elseif gun then
                if gun ~= d and AnimalHealth <= 0 and PlyToAnimal < 2.0 then
                    Notify(Config.Notifications.animal_destroyed)
                    DeleteEntity(value.id)
                    table.remove(HuntedAnimalTable, index)
                end
            elseif PlyToAnimal > 3.0 then
                Notify(Config.Notifications.no_animal_nearby)
            elseif AnimalHealth > 0 then
                Notify(Config.Notifications.animal_not_dead)
            elseif not DoesEntityExist(value.id) and PlyToAnimal < 2.0 then
                Notify(Config.Notifications.animal_invalid)
            end
        end
    end)
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function Notify(text)
	ESX.ShowNotification(text)
end

