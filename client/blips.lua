local blips = {}
local props = {}
local cleanedLocations = {}

RegisterNetEvent('dj-cleaning:notify')
AddEventHandler('dj-cleaning:notify', function(message)
    lib.notify({
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
    lib.notify({
        description = "Your truck is ready. Get to work!",
        type = 'success'
    })
end)

RegisterNetEvent('dj-cleaning:spawnProps')
AddEventHandler('dj-cleaning:spawnProps', function(locations)
    for i, location in ipairs(locations) do
        local propModel = GetHashKey(location.prop)
        RequestModel(propModel)
        while not HasModelLoaded(propModel) do
            Wait(0)
        end
        local prop = CreateObject(propModel, location.x, location.y, location.z - 1.0, true, true, false)
        PlaceObjectOnGroundProperly(prop)
        FreezeEntityPosition(prop, true)
        props[i] = prop
    end
end)

RegisterNetEvent('dj-cleaning:removeProp')
AddEventHandler('dj-cleaning:removeProp', function(index)
    if props[index] then
        DeleteObject(props[index])
        props[index] = nil
    end
end)

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

for i, location in ipairs(Config.CleaningLocations) do
    exports.ox_target:addSphereZone({
        coords = vector3(location.x, location.y, location.z),
        radius = 2.0,
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

RegisterNetEvent('dj-cleaning:startCleaning')
AddEventHandler('dj-cleaning:startCleaning', function(data)
    local locationIndex = data.locationIndex
    exports['scully_emotemenu']:playEmote('cleaning')
    lib.progressCircle({
        duration = Config.CleaningDuration,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        onFinish = function()
            TriggerServerEvent('dj-cleaning:cleanLocation', locationIndex)
        end,
        onCancel = function()
            lib.notify({
                description = "Cleaning canceled.",
                type = 'error'
            })
        end
    })
end)

function createBlip(location)
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    table.insert(blips, blip)
end

function clearBlips()
    for _, blip in ipairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end
