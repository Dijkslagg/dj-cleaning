local props = {}
local blips = {}
local cleanedLocations = {}
local npcPed = nil
local currentTruck = nil
local currentJobLocations = {}
local isCleaningInProgress = false
local jobCompleted = false
local hasActiveTruck = false
local zoneIds = {}

RegisterNUICallback('startJob', function(data, cb)
    showDashboard(false) 
    hasActiveTruck = true
    TriggerServerEvent('dj-cleaning:startJob')
    cb({ status = 'ok' })
end)

function updateDashboard(level, xp, required, progress, recentJobs)
    SendNUIMessage({
        type = 'updateDashboard',
        level = level,
        experience = xp,
        required = required,
        progress = progress,
        recentJobs = recentJobs
    })
end

RegisterNetEvent('dj-cleaning:assignJob')
AddEventHandler('dj-cleaning:assignJob', function(jobCoords, trashData)
    local truckModel = GetHashKey(Config.TruckModel)
    RequestModel(truckModel)
    while not HasModelLoaded(truckModel) do
        Wait(0)
    end
    
    local truck = CreateVehicle(truckModel, Config.TruckSpawnLocation.x, Config.TruckSpawnLocation.y, Config.TruckSpawnLocation.z, Config.TruckHeading, true, false)
    currentTruck = truck 
    SetEntityAsMissionEntity(truck, true, true)
    SetVehicleNumberPlateText(truck, "CLEAN"..math.random(100, 999))
    
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(truck))
    
    local ped = PlayerPedId()
    TaskWarpPedIntoVehicle(ped, truck, -1)
    
    for i, trashInfo in ipairs(trashData) do
        local propModel = GetHashKey(trashInfo.prop)
        RequestModel(propModel)
        while not HasModelLoaded(propModel) do
            Wait(0)
        end
        
        local coords = trashInfo.coords
        local prop = CreateObject(propModel, coords.x, coords.y, coords.z - 1.0, true, true, false)
        PlaceObjectOnGroundProperly(prop)
        FreezeEntityPosition(prop, true)
        props[i] = prop
        
        local zoneId = 'trash_' .. GetGameTimer() .. '_' .. i
        zoneIds[i] = zoneId
        
        exports.ox_target:addSphereZone({
            coords = vector3(coords.x, coords.y, coords.z),
            radius = 1.25,
            name = zoneId, 
            options = {
                {
                    name = 'clean_trash',
                    event = 'dj-cleaning:startCleaning',
                    label = 'Clean this spot',
                    icon = 'fas fa-broom',
                    locationIndex = i
                }
            }
        })
        
        currentJobLocations[i] = coords
    end
    
    if jobCoords then
        createBlip(jobCoords)
    end
    
    exports.ox_lib:notify({
        title = "Job Started",
        description = Config.StartJobMessage,
        type = 'success'
    })
end)

RegisterNetEvent('dj-cleaning:endJob')
AddEventHandler('dj-cleaning:endJob', function()
    local recentJobs = {} 
    local payouts = {'$100'}
    updateDashboard(1, 100, 50, recentJobs, payouts)
end)

RegisterNetEvent('dj-cleaning:notify')
AddEventHandler('dj-cleaning:notify', function(message)
    exports.ox_lib:notify({
        description = message,
        type = 'primary'
    })
end)

RegisterNetEvent('dj-cleaning:assignTruck')
AddEventHandler('dj-cleaning:assignTruck', function()
    local truckModel = GetHashKey(Config.TruckModel)
    RequestModel(truckModel)
    while not HasModelLoaded(truckModel) do
        Wait(0)
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local truck = CreateVehicle(truckModel, coords.x + 5.0, coords.y, coords.z, 0.0, true, false)
    SetVehicleNumberPlateText(truck, "CLEANER")
    exports.ox_lib:notify({
        description = "Your truck is ready. Get to work!",
        type = 'success'
    })
end)

local function isPlayerInValidRange(coords, maxDistance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - coords) <= maxDistance
end

RegisterNetEvent('dj-cleaning:updateLocations')
AddEventHandler('dj-cleaning:updateLocations', function(updatedLocations)
    cleanedLocations = updatedLocations
    clearBlips()
    for i, location in ipairs(Config.CleaningLocations) do
        if not cleanedLocations[i] then
            createBlip(location)
        end
    end
end)

if Config.CleaningLocations then
    for i, location in ipairs(Config.CleaningLocations) do
        if location and location.x and location.y and location.z then
            exports.ox_target:addSphereZone({
                coords = vector3(location.x, location.y, location.z),
                radius = 1.25,
                options = {
                    {
                        name = 'clean_location_' .. i,
                        event = 'dj-cleaning:startCleaning',
                        icon = 'fas fa-broom',
                        label = 'Clean this spot',
                        locationIndex = i
                    }
                }
            })
        end
    end
else
    print("Error: Config.CleaningLocations is nil")
end

RegisterNetEvent('dj-cleaning:startCleaning')
AddEventHandler('dj-cleaning:startCleaning', function(data)
    if isCleaningInProgress then return end
    if not data or not data.locationIndex then return end
    
    local locationIndex = data.locationIndex
    local locationCoords = currentJobLocations[locationIndex]
    if not locationCoords or not isPlayerInValidRange(locationCoords, 3.0) then
        return
    end
    
    isCleaningInProgress = true
    
    local emote = exports['scully_emotemenu']:playEmoteByCommand('broom')
    
    if exports.ox_lib:progressBar({
        duration = Config.CleaningDuration,
        label = 'Cleaning trash...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        }
    }) then
        exports['scully_emotemenu']:cancelEmote()
        
        if props[locationIndex] and DoesEntityExist(props[locationIndex]) then
            DeleteEntity(props[locationIndex])
            props[locationIndex] = nil
        end
        
        if zoneIds[locationIndex] then
            exports.ox_target:removeZone(zoneIds[locationIndex])
            zoneIds[locationIndex] = nil
        end
        
        TriggerServerEvent('dj-cleaning:completeSpot', locationIndex)
        
        local totalSpots = #currentJobLocations
        local completedSpots = 0
        for i = 1, totalSpots do
            if not props[i] then 
                completedSpots = completedSpots + 1 
            end
        end
        
        exports.ox_lib:notify({
            description = string.format('Cleaned spot %d/%d', completedSpots, totalSpots),
            type = 'success'
        })
        
        if completedSpots >= totalSpots then
            jobCompleted = true
            updateDashboardButton('Collect Payout', 'collectPayout')
            exports.ox_lib:notify({
                description = Config.PayoutNotification,
                type = 'success'
            })
        end
    else
        exports['scully_emotemenu']:cancelEmote()
        exports.ox_lib:notify({
            description = 'Cleaning cancelled',
            type = 'error'
        })
    end
    
    isCleaningInProgress = false
end)

function updateDashboardButton(text, action)
    SendNUIMessage({
        type = 'updateButton',
        buttonText = text,
        action = action
    })
end

function createBlip(location)
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Cleaning Location")
    EndTextCommandSetBlipName(blip)
    table.insert(blips, blip)
end

function clearBlips()
    for _, blip in ipairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

function spawnNPC()
    local npcModel = GetHashKey(Config.NPCModel)
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(0)
    end
    
    local npcCoords = Config.NPCCoords
    npcPed = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1, Config.NpcHeading, false, true)
    
    FreezeEntityPosition(npcPed, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    SetEntityAsMissionEntity(npcPed, true, true)
    
    exports.ox_target:addLocalEntity({npcPed}, {
        {
            name = 'talk_to_npc',
            event = 'dj-cleaning:talkToNPC',
            icon = 'fas fa-comments',
            label = 'Talk to Cleaning Manager',
            distance = 2.5
        }
    })
end

CreateThread(function()
    spawnNPC()
    if Config.NpcBlip then
        local blip = AddBlipForCoord(Config.NPCCoords)
        SetBlipSprite(blip, 280)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 2)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Cleaning Manager")
        EndTextCommandSetBlipName(blip)
    end
end)

function showDashboard(show)
    SetNuiFocus(show, show)
    SendNUIMessage({
        type = 'toggleDashboard',
        show = show
    })
end

RegisterNetEvent('dj-cleaning:talkToNPC')
AddEventHandler('dj-cleaning:talkToNPC', function()
    if npcPed then
        TaskTurnPedToFaceEntity(npcPed, PlayerPedId(), -1)
        TriggerServerEvent('dj-cleaning:requestJobHistory')
        SetTimeout(100, function()
            if hasActiveTruck and not jobCompleted then
                updateDashboardButton('End Job & Return Truck', 'endJob')
            elseif jobCompleted then
                updateDashboardButton('Collect Payout', 'collectPayout')
            else
                updateDashboardButton('Start Job', 'startJob')
            end
            
            showDashboard(true)
        end)
    end
end)

RegisterNetEvent('dj-cleaning:receiveJobHistory')
AddEventHandler('dj-cleaning:receiveJobHistory', function(data)
    if data then
        SendNUIMessage({
            type = 'updateDashboard',
            level = data.level or 1,
            experience = data.experience or 0,
            required = data.required or 100,
            progress = ((data.experience or 0) / (data.required or 100)) * 100,
            recentJobs = data.recentJobs or {},
            total_jobs = data.total_jobs or 0,
            total_earnings = data.total_earnings or 0
        })
    end
end)

RegisterNUICallback('closeDashboard', function(data, cb)
    showDashboard(false)
    cb({})
end)

RegisterNUICallback('endJob', function(data, cb)
    showDashboard(false)
    cleanupJob()
    
    if not jobCompleted then
        exports.ox_lib:notify({
            description = Config.FailedJobMessage,
            type = 'error'
        })
    else
        exports.ox_lib:notify({
            description = Config.EndJobMessage,
            type = 'success'
        })
    end
    
    TriggerServerEvent('dj-cleaning:endJob')
    hasActiveTruck = false
    cb({})
end)

RegisterNUICallback('collectPayout', function(data, cb)
    if jobCompleted then
        showDashboard(false)
        cleanupJob()
        hasActiveTruck = false 
        TriggerServerEvent('dj-cleaning:collectPayout')
        cb({})
    end
end)

if npcPed then
    exports.ox_target:addLocalEntity(npcPed, {
        {
            name = 'talk_to_npc',
            event = 'dj-cleaning:talkToNPC',
            icon = 'fas fa-comments',
            label = 'Talk to Cleaning Manager'
        }
    })
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    for _, prop in pairs(props) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    props = {}

    if currentTruck and DoesEntityExist(currentTruck) then
        DeleteEntity(currentTruck)
    end

    clearBlips()

    if npcPed and DoesEntityExist(npcPed) then
        DeleteEntity(npcPed)
    end
end)

RegisterNetEvent('dj-cleaning:cleanupJob')
AddEventHandler('dj-cleaning:cleanupJob', function()
    cleanupJob()
end)

function cleanupJob()
    if currentTruck and DoesEntityExist(currentTruck) then
        DeleteVehicle(currentTruck)
        currentTruck = nil
    end

    for _, prop in pairs(props) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    props = {}
    
    for _, zoneId in pairs(zoneIds) do
        exports.ox_target:removeZone(zoneId)
    end
    zoneIds = {}
    
    currentJobLocations = {}
    clearBlips()
    isCleaningInProgress = false
    jobCompleted = false
    hasActiveTruck = false 
end

RegisterNetEvent('dj-cleaning:updateStats')
AddEventHandler('dj-cleaning:updateStats', function(data)
    local progress = (data.experience / 100) * 100
    updateDashboard(data.level, data.experience, progress, data.recentJobs)
end)
