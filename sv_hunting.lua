
ESX = nil


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterUsableItem('huntingknife', function(source)
    TriggerClientEvent('AOD-huntingknife',source)
end)

ESX.RegisterUsableItem('huntingbait', function(source)
    TriggerClientEvent('AOD-huntingbait', source)
end)

RegisterServerEvent('AOD-butcheranimal')
AddEventHandler('AOD-butcheranimal', function(animal)
    local xPlayer = ESX.GetPlayerFromId(source)
    local boar = -832573324
    local deer = -664053099
    local cayote = 1682622302

    if animal == boar then
        local bmeat = math.random(5)
        xPlayer.addInventoryItem('boarmeat', bmeat)
        xPlayer.addInventoryItem('boartusk', 2)
    elseif animal == deer then
        local dmeat = math.random(5)
        xPlayer.addInventoryItem('deerskin', 1)
        xPlayer.addInventoryItem('deermeat', dmeat)
    elseif animal == cayote then
        local cmeat = math.random(5)
        xPlayer.addInventoryItem('coyotefur', 1)
        xPlayer.addInventoryItem('coyotemeat', cmeat)
    else
        print('exploit detected')
        --you should ban the player if they somehow get to this point lol
    end
end)


RegisterServerEvent('AOD-hunt:TakeItem')
AddEventHandler('AOD-hunt:TakeItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, 1)

end)
