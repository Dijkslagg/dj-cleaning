local activeJobs = {}

RegisterNetEvent('dj-cleaning:startJob')
AddEventHandler('dj-cleaning:startJob', function()
    local src = source
    if activeJobs[src] then
        TriggerClientEvent('ox_lib:notify', src, {description = "You already have an active job!", type = "error"})
        return
    end

    local jobLocationIndex = math.random(#Config.JobLocations)
    local selectedLocation = Config.JobLocations[jobLocationIndex]

    local trash = {}
    for _, spotCoords in ipairs(selectedLocation.trashSpots) do
        local randomProp = Config.TrashProps[math.random(#Config.TrashProps)]
        table.insert(trash, {coords = spotCoords, prop = randomProp})
    end

    local jobCoords = selectedLocation.trashSpots[1]

    activeJobs[src] = {
        location = jobCoords,
        trash = trash,
        completed = 0
    }

    TriggerClientEvent('dj-cleaning:assignJob', src, jobCoords, trash)
end)

RegisterNetEvent('dj-cleaning:completeSpot')
AddEventHandler('dj-cleaning:completeSpot', function(locationIndex)
    local src = source
    if not activeJobs[src] then return end

    activeJobs[src].completed = activeJobs[src].completed + 1

    if activeJobs[src].completed >= #activeJobs[src].trash then
        TriggerClientEvent('dj-cleaning:endJob', src)
        activeJobs[src] = nil
    end
end)

RegisterNetEvent('dj-cleaning:collectPayout')
AddEventHandler('dj-cleaning:collectPayout', function()
    local src = source
    local reward = math.random(Config.Reward.min, Config.Reward.max)
    local QBCore = exports['qb-core']:GetCoreObject()
    local player = QBCore.Functions.GetPlayer(src)

    if player then
        player.Functions.AddMoney('cash', reward, 'cleaning job payout')
        TriggerClientEvent('ox_lib:notify', src, {
            description = string.format(Config.PayoutMessage, reward),
            type = "success"
        })
    else
        print("[dj-cleaning] Player not found for payout")
    end
end)

RegisterNetEvent('dj-cleaning:endJob')
AddEventHandler('dj-cleaning:endJob', function()
    local src = source
    if activeJobs[src] then
        activeJobs[src] = nil
    end
    -- TriggerClientEvent('ox_lib:notify', src, {description = Config.EndJobMessage, type = "success"})
end)
