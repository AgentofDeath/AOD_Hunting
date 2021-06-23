
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('huntingknife', function(source)
    TriggerClientEvent('AOD-huntingknife', source)
end)

ESX.RegisterUsableItem('huntingbait', function(source)
    TriggerClientEvent('AOD-huntingbait', source)
end)

RegisterServerEvent('AOD-butcheranimal')
AddEventHandler('AOD-butcheranimal', function(animal, hit)
    local xPlayer = ESX.GetPlayerFromId(source)
    local found = false
    local multiplier = 1
    
    if hit == 31086 then 
        multiplier = Config.HeadshotBonus 
        if Config.Debug then
            print('Headshot Detected')
        end
    end

    for _, aData in pairs(Config.Rewards) do
        if animal == aData.hash then
            found = true
            xPlayer.addInventoryItem(aData.rewardMeat, math.random(Config.RewardMeatMinimum, Config.RewardMeatMaximum) * multiplier)
            xPlayer.addInventoryItem(aData.rewardOther, math.random(Config.RewardOtherMinimum, Config.RewardOtherMaximum) * multiplier)
        end
    end

    if not found then
        print('AOD_Hunting: Reward type not found. Is this animal configured correctly?')
    end
end)

RegisterServerEvent('AOD-hunt:TakeItem')
AddEventHandler('AOD-hunt:TakeItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, 1)
end)
