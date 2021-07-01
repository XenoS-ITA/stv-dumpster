-- ESX
local ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)


local searched = {}
local timer = {}
local canSearch = true
local dumpsters = {218085040, 666561306, -58485588, -206690185, 1511880420, 682791951}

-- bt-target
exports['bt-target']:AddTargetModel(dumpsters, {
    options = {
        {
            event = 'stv-dumpster:SearchDumpster',
            icon = 'fas fa-dumpster',
            label = 'Search Dumpster'
        },
    },
    job = {'all'},
    distance = 1.5
})

-- Callback of the bt-target
RegisterNetEvent('stv-dumpster:SearchDumpster')
AddEventHandler('stv-dumpster:SearchDumpster', function()
    local pos = GetEntityCoords(PlayerPedId())

    -- If it cannot search in the dumpster simply return 0, so that the code more ahead does not come executed
    if not canSearch then
        return
    end

    for i = 1, #dumpsters do
        local dumpster = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.0, dumpsters[i], false, false, false)

        if dumpster ~= 0 then
            -- If has already been searched
            if searched[dumpster] then
                exports['mythic_notify']:DoHudText('error', 'This dumpster has already been searched')
            else -- If is new
                exports['mythic_notify']:DoHudText('inform', 'You begin to search the dumpster')
                
                StartSearching(dumpster)
                searched[dumpster] = true
            end

            break -- We have already found the dumpster, so we stop the loop to not waste resources
        end
    end
end)

function StartSearching(dumpster)
    canSearch = false
    local ped = PlayerPedId()

    if not HasAnimDictLoaded("amb@prop_human_bum_bin@base") then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(0)
        end
    end

    exports['mythic_progbar']:Progress({
        name = "unique_action_name",
        duration = 30000,
        label = 'Searching Dumpster',
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@prop_human_bum_bin@base",
            anim = "base",
        },
    })
    Citizen.Wait(30000)
    Wait(0)
    if not DoesEntityExist(ped) then
        ped = PlayerPedId()
    end

    ClearPedTasks(ped)
    TriggerServerEvent("stv:giveDumpsterReward")
    
    timer[dumpster] = 10
    canSearch = true
end

-- Timer
Citizen.CreateThread(function()
    while true do
        for entity,time in pairs(timer) do
            if time == 0 then
                searched[entity] = false
                timer[entity] = nil
            else
                time = time - 1
            end
        end
        Citizen.Wait(60000)
    end
end)
