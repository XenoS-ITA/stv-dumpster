local dumpsterItems = { 
    [1] = {
        id = 'bread', 
        quantity = 3
    },
    [2] = {
        id = 'WEAPON_BAT', 
        quantity = 250
    },
}

local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('stv-dumpster:GiveReward')
AddEventHandler('stv-dumpster:GiveReward', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- give 1 or 2 item
    for i=1, math.random(1, 2) do
        local item = dumpsterItems[math.random(1, #dumpsterItems)]

        if string.find(item.id:upper(), "WEAPON_") then
            xPlayer.addWeapon(item.id, item.quantity)
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'success', text = 'You\'ve found a weapon', })
        else
            xPlayer.addInventoryItem(item.id, item.quantity)
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'success', text = 'You\'ve found an item', })
        end
    end
end)
