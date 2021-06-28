ESX = nil

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent(AOD.Strings.ESXClient, function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local baitexists, baitLocation, HuntedAnimalTable, busy = 0, nil, {}, false
DecorRegister('MyAnimal', 2) -- don't touch it

isValidZone =  function()
    local zoneInH = GetNameOfZone(GetEntityCoords(PlayerPedId()))
    for k, v in pairs(AOD.HuntingZones) do
        if zoneInH == v then
            return true
        end
    end

end

SetSpawn = function(baitLocation)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local spawnCoords = nil
    while spawnCoords == nil do
        local spawnX = math.random(-AOD.SpawnDistanceRadius, AOD.SpawnDistanceRadius)
        local spawnY = math.random(-AOD.SpawnDistanceRadius, AOD.SpawnDistanceRadius)
        local spawnZ = baitLocation.z
        local vec = vector3(baitLocation.x + spawnX, baitLocation.y + spawnY, spawnZ)
        if #(playerCoords - vec) > AOD.SpawnDistanceRadius then
            spawnCoords = vec
        end
    end
    local worked, groundZ, normal = GetGroundZAndNormalFor_3dCoord(spawnCoords.x, spawnCoords.y, 1023.9)
    spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ)
    return spawnCoords
end

baitDown = function(baitLocation)
    Citizen.CreateThread(function()
        while baitLocation ~= nil do
            local coords = GetEntityCoords(PlayerPedId())
            if #(baitLocation - coords) > AOD.DistanceFromBait then
                if math.random() < AOD.SpawnChance then
                    SpawnAnimal(baitLocation)
                    baitLocation = nil
                end
            end
            Citizen.Wait(15000)
        end
    end)
end

SpawnAnimal = function(location)
    local spawn = SetSpawn(location)
    local model = GetHashKey(AOD.HuntAnimals[math.random(1,#AOD.HuntAnimals)])
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(10) end
    local prey = CreatePed(28, model, spawn, true, true, true)
    DecorSetBool(prey, 'MyAnimal', true)
    TaskGoStraightToCoord(prey, location, 1.0, -1, 0.0, 0.0)
    table.insert(HuntedAnimalTable, {id = prey, animal = model})
    SetModelAsNoLongerNeeded(model)
    Citizen.CreateThread(function()
        local destination = false
        while not IsPedDeadOrDying(prey) and not destination do
            local preyCoords = GetEntityCoords(prey)
            local distance = #(location - preyCoords)
            local guy = PlayerPedId()
            if distance < 0.35 then
                ClearPedTasks(prey)
                Citizen.Wait(1500)
                TaskStartScenarioInPlace(prey, 'WORLD_DEER_GRAZING', 0, true)
                Citizen.SetTimeout(8000, function()
                    destination = true
                end)
            end
            if #(preyCoords - GetEntityCoords(guy)) < AOD.DistanceTooCloseToAnimal then
                ClearPedTasks(prey)
                TaskSmartFleePed(prey, guy,600.0, -1, true, true)
                destination = true
            end
            Citizen.Wait(1000)
        end
        if not IsPedDeadOrDying(prey) then
            TaskSmartFleePed(prey, guy,600.0, -1, true, true)
        end
    end)
end

RegisterNetEvent('AOD-huntingbait')
AddEventHandler('AOD-huntingbait', function()
    if not isValidZone() then
        Notify(AOD.Strings.NotValidZone)
        return
    end
    if busy then
        Notify(AOD.Strings.ExploitDetected)
        Citizen.Wait(2000)
        Notify(AOD.Strings.DontSpawm)
        TriggerServerEvent('AOD-hunt:TakeItem', 'huntingbait')
        return
    end
    if baitexists ~= 0 and GetGameTimer() < (baitexists + 90000) then
        Notify(AOD.Strings.WaitToBait)
        return
    end
    baitexists = nil
    busy = true
    local player = PlayerPedId()
    TaskStartScenarioInPlace(player, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
    exports['progressBars']:startUI((15000), AOD.Strings.PlacingBait)
    Citizen.Wait(15000)
    ClearPedTasks(player)
    baitexists = GetGameTimer()
    local baitLocation = GetEntityCoords(player)
    Notify(AOD.Strings.BaitPlaced)
    TriggerServerEvent('AOD-hunt:TakeItem', 'huntingbait')
    baitDown(baitLocation)
    busy = false
end)

RegisterNetEvent('AOD-huntingknife')
AddEventHandler('AOD-huntingknife', function()
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        for index, value in ipairs(HuntedAnimalTable) do
            local person = PlayerPedId()
            local AnimalCoords = GetEntityCoords(value.id)
            local PlyCoords = GetEntityCoords(person)
            local AnimalHealth = GetEntityHealth(value.id)
            local PlyToAnimal = #(PlyCoords - AnimalCoords)
            local gun = AOD.HuntingWeapon
            local d = GetPedCauseOfDeath(value.id)
            if DoesEntityExist(value.id) and AnimalHealth <= 0 and PlyToAnimal < 2.0 and (gun == d or gun == nil) and not busy then
                busy = true
                LoadAnimDict('amb@medic@standing@kneel@base')
                LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
                TaskTurnPedToFaceEntity(person, value.id, -1)
                Citizen.Wait(1500)
                ClearPedTasksImmediately(person)
                TaskPlayAnim(person, 'amb@medic@standing@kneel@base' ,'base' ,8.0, -8.0, -1, 1, 0, false, false, false )
                TaskPlayAnim(person, 'anim@gangops@facility@servers@bodysearch@' ,'player_search' ,8.0, -8.0, -1, 48, 0, false, false, false )
                exports['progressBars']:startUI((5000), AOD.Strings.Harvest)
                Citizen.Wait(5000)
                ClearPedTasks(person)
                Notify(AOD.Strings.Butchered)
                DeleteEntity(value.id)
                TriggerServerEvent('AOD-butcheranimal', value.animal)
                busy = false
                table.remove(HuntedAnimalTable, index)
            elseif busy then
                Notify(AOD.Strings.ExploitDetected)
            elseif gun ~= d and AnimalHealth <= 0 and PlyToAnimal < 2.0 then
                Notify(AOD.Strings.Roadkill)
                DeleteEntity(value.id)
                table.remove(HuntedAnimalTable, index)
            elseif PlyToAnimal > 3.0 then
                Notify(AOD.Strings.NoAnimal)
            elseif AnimalHealth > 0 then
                Notify(AOD.Strings.NotDead)
            elseif not DoesEntityExist(value.id) and PlyToAnimal < 2.0 then
                Notify(AOD.Strings.NotYours)
            else
                Notify(AOD.Strings.WTF)
            end
        end
    end)
end)

LoadAnimDict = function(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

Notify = function(text, timer)
    if timer == nil then
        timer = 5000
    end
    --exports['mythic_notify']:DoCustomHudText('inform', text, timer)
    -- exports.pNotify:SendNotification({layout = 'centerLeft', text = text, type = 'error', timeout = timer})
    ESX.ShowNotification(text)
end
