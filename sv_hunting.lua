ESX = nil

TriggerEvent(AOD.Strings.ESXServer, function(obj) ESX = obj end)

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
    local coyote = 1682622302
    if animal == boar then
        xPlayer.addInventoryItem('boarmeat', AOD.BoarMeat)
        xPlayer.addInventoryItem('boartusk', AOD.BoarTusk)
    elseif animal == deer then
        xPlayer.addInventoryItem('deerskin', AOD.DeerSkin)
        xPlayer.addInventoryItem('deermeat', AOD.DeerMeat)
    elseif animal == coyote then
        xPlayer.addInventoryItem('coyotefur', AOD.CoyoteFur)
        xPlayer.addInventoryItem('coyotemeat', AOD.CoyoteMeat)
    else
        print('exploit detected')
        --add your ban event here for cheating
    end
end)

RegisterServerEvent('AOD-hunt:TakeItem')
AddEventHandler('AOD-hunt:TakeItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, 1)

end)
