local jobInProgress = false
local jobParticipants = {}
local cleanedLocations = {}

RegisterNetEvent('dj-cleaning:startJob')
AddEventHandler('dj-cleaning:startJob', function()
    local src = source
    if not jobParticipants[src] then
        jobParticipants[src] = true
        TriggerClientEvent('dj-cleaning:notify', src, "Job started. Go to your truck!")
        TriggerClientEvent('dj-cleaning:assignTruck', src)
        if not jobInProgress then
            jobInProgress = true
            TriggerClientEvent('dj-cleaning:notify', -1, "A cleaning job has started in the area!")
        end
        TriggerClientEvent('dj-cleaning:spawnProps', src, Config.CleaningLocations)
        TriggerClientEvent('dj-cleaning:updateLocations', src, cleanedLocations)
    end
end)

RegisterNetEvent('dj-cleaning:cleanLocation')
AddEventHandler('dj-cleaning:cleanLocation', function(locationIndex)
    local src = source
    if cleanedLocations[locationIndex] then
        TriggerClientEvent('ox_lib:notify', src, {description = "This location is already cleaned!", type = "error"})
        return
    end
    cleanedLocations[locationIndex] = true
    TriggerClientEvent('dj-cleaning:updateLocations', -1, cleanedLocations)
    TriggerClientEvent('dj-cleaning:removeProp', -1, locationIndex)
    TriggerClientEvent('ox_lib:notify', src, {description = "You cleaned the location!", type = "success"})
end)

AddEventHandler('playerDropped', function()
    local src = source
    if jobParticipants[src] then
        jobParticipants[src] = nil
        if next(jobParticipants) == nil then
            jobInProgress = false
            cleanedLocations = {}
            TriggerClientEvent('dj-cleaning:notify', -1, "The cleaning job has ended!")
        end
    end
end)
