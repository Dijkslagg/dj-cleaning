local activeJobs = {}
local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    exports.oxmysql:update_async('UPDATE cleaning_jobs SET status = "failed" WHERE status = "ongoing"')
end)

CreateThread(function()
    local success1 = exports.oxmysql:query_async([[
        CREATE TABLE IF NOT EXISTS cleaning_jobs (
            id int(11) NOT NULL AUTO_INCREMENT,
            citizenid varchar(50) NOT NULL,
            job_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            payout int(11) NOT NULL DEFAULT 0,
            spots_cleaned int(11) NOT NULL DEFAULT 0,
            total_spots int(11) NOT NULL DEFAULT 0,
            status varchar(20) NOT NULL DEFAULT 'ongoing',
            PRIMARY KEY (id)
        )
    ]])

    local success2 = exports.oxmysql:query_async([[
        CREATE TABLE IF NOT EXISTS cleaning_levels (
            citizenid varchar(50) NOT NULL,
            level int(11) NOT NULL DEFAULT 1,
            experience int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (citizenid)
        )
    ]])
    
    if success1 and success2 then
        print('[dj-cleaning] Database tables initialized successfully')
    else
        print('[dj-cleaning] Failed to initialize database tables')
    end
end)

function GetPlayerCleaningStats(citizenid)
    local result = exports.oxmysql:query_async('SELECT * FROM cleaning_levels WHERE citizenid = ?', {citizenid})
    if not result or not result[1] then
        exports.oxmysql:insert_async('INSERT INTO cleaning_levels (citizenid, level, experience) VALUES (?, ?, ?)', 
            {citizenid, 1, 0})
        return {level = 1, experience = 0}
    end
    return result[1]
end

function GetRecentJobs(citizenid)
    return exports.oxmysql:query_async([[
        SELECT 
            DATE_FORMAT(job_date, "%Y-%m-%d %H:%i") as date,
            payout,
            spots_cleaned,
            total_spots,
            status
        FROM cleaning_jobs 
        WHERE citizenid = ? 
        ORDER BY job_date DESC 
        LIMIT 3
    ]], {citizenid})
end

function GetRequiredXP(level)
    if level <= 5 then
        return 100 * (2 ^ (level - 1)) -- Makes the XP goes x2 till level 5. after that it increases with 20% each level. 
    else
        local baseXP = 1600 
        local multiplier = 1.2
        return math.floor(baseXP + (400 * (level - 5) * multiplier))
    end
end

function AddExperience(citizenid, amount)
    local stats = GetPlayerCleaningStats(citizenid)
    local newExp = stats.experience + amount
    local newLevel = stats.level
    
    local required = GetRequiredXP(newLevel)
    while newExp >= required do
        newExp = newExp - required
        newLevel = newLevel + 1
        required = GetRequiredXP(newLevel) 
        
        local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
        if player then
            TriggerClientEvent('ox_lib:notify', player.PlayerData.source, {
                description = string.format("Level Up! You are now level %d!", newLevel),
                type = 'success'
            })
        end
    end
    
    exports.oxmysql:update('UPDATE cleaning_levels SET level = ?, experience = ? WHERE citizenid = ?',
        {newLevel, newExp, citizenid})
    
    return {
        level = newLevel, 
        experience = newExp,
        required = GetRequiredXP(newLevel)
    }
end

local function isValidSource(src)
    if not src or type(src) ~= "number" then return false end
    local player = QBCore.Functions.GetPlayer(src)
    return player ~= nil
end

RegisterNetEvent('dj-cleaning:startJob')
AddEventHandler('dj-cleaning:startJob', function()
    local src = source
    if not isValidSource(src) then return end
    
    if activeJobs[src] then
        TriggerClientEvent('ox_lib:notify', src, {description = "You already have an active job!", type = "error"})
        return
    end
    
    if not Config.CleaningLocations or #Config.CleaningLocations == 0 then
        print("[dj-cleaning] No job locations defined")
        return
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if activeJobs[src] then
        TriggerClientEvent('ox_lib:notify', src, {description = "You already have an active job!", type = "error"})
        return
    end

    if not Config.CleaningLocations or #Config.CleaningLocations == 0 then
        print("[dj-cleaning] No job locations defined in Config.CleaningLocations")
        return
    end

    local jobLocationIndex = math.random(#Config.CleaningLocations)
    local selectedLocation = Config.CleaningLocations[jobLocationIndex]

    if not Config.TrashProps or #Config.TrashProps == 0 then
        print("[dj-cleaning] No trash props defined in Config.TrashProps")
        return
    end

    local trash = {}
    for _, spotCoords in ipairs(selectedLocation.trashSpots) do
        local randomProp = Config.TrashProps[math.random(#Config.TrashProps)]
        table.insert(trash, {
            coords = spotCoords,
            prop = randomProp
        })
    end

    local totalSpots = #selectedLocation.trashSpots
    exports.oxmysql:insert_async('INSERT INTO cleaning_jobs (citizenid, spots_cleaned, total_spots, status) VALUES (?, ?, ?, ?)',
        {Player.PlayerData.citizenid, 0, totalSpots, 'ongoing'})
    
    activeJobs[src] = {
        location = selectedLocation,
        trash = trash,
        completed = 0,
        total = totalSpots
    }

    TriggerClientEvent('dj-cleaning:assignJob', src, selectedLocation.trashSpots[1], trash)
end)

RegisterNetEvent('dj-cleaning:completeSpot')
AddEventHandler('dj-cleaning:completeSpot', function(locationIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not activeJobs[src] then return end

    activeJobs[src].completed = activeJobs[src].completed + 1

    exports.oxmysql:query_async('UPDATE cleaning_jobs SET spots_cleaned = spots_cleaned + 1 WHERE citizenid = ? AND status = "ongoing"',
        {Player.PlayerData.citizenid})

    if activeJobs[src].completed >= #activeJobs[src].trash then
        TriggerClientEvent('dj-cleaning:endJob', src)
        activeJobs[src] = nil
    end
end)

RegisterNetEvent('dj-cleaning:collectPayout')
AddEventHandler('dj-cleaning:collectPayout', function()
    local src = source
    if not isValidSource(src) then return end
    
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    
    local jobStatus = exports.oxmysql:query_async('SELECT status FROM cleaning_jobs WHERE citizenid = ? ORDER BY id DESC LIMIT 1', {citizenid})
    if not jobStatus[1] or jobStatus[1].status ~= 'ongoing' then
        print("[dj-cleaning] Potential exploit attempt: Invalid payout request")
        return
    end

    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local stats = GetPlayerCleaningStats(citizenid)
    local levelMultiplier = 1 + (Config.LevelMultiplier * (stats.level - 1))
    
    local baseReward = math.random(Config.Reward.min, Config.Reward.max)
    local finalReward = math.floor(baseReward * levelMultiplier)
    
    exports.oxmysql:update_async('UPDATE cleaning_jobs SET status = ?, payout = ? WHERE citizenid = ? AND status = "ongoing"',
        {'completed', finalReward, citizenid})
    
    Player.Functions.AddMoney('cash', finalReward, 'cleaning job payout')
    local newStats = AddExperience(citizenid, 10)
    
    local playerStats = GetPlayerStats(citizenid)
    local recentJobs = GetRecentJobs(citizenid)
    
    TriggerClientEvent('dj-cleaning:updateStats', src, {
        level = newStats.level,
        experience = newStats.experience,
        required = GetRequiredXP(newStats.level),
        recentJobs = recentJobs,
        total_jobs = playerStats.total_jobs,
        total_earnings = playerStats.total_earnings
    })
    
    TriggerClientEvent('ox_lib:notify', src, {
        description = string.format("Level %d Bonus: +%d%% (Total: $%d)", 
            newStats.level, 
            math.floor(levelMultiplier * 100 - 100), 
            finalReward),
        type = 'success'
    })
end)

RegisterNetEvent('dj-cleaning:endJob')
AddEventHandler('dj-cleaning:endJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports.oxmysql:update_async([[
        UPDATE cleaning_jobs 
        SET status = 'failed' 
        WHERE citizenid = ? 
        AND status = 'ongoing' 
        AND spots_cleaned < total_spots
    ]], {Player.PlayerData.citizenid})

    if activeJobs[src] then
        activeJobs[src] = nil
    end
end)

function GetPlayerStats(citizenid)
    local stats = GetPlayerCleaningStats(citizenid)
    
    local totalStats = exports.oxmysql:query_async([[
        SELECT 
            COUNT(*) as total_jobs,
            COALESCE(SUM(payout), 0) as total_earnings
        FROM cleaning_jobs 
        WHERE citizenid = ? AND status = 'completed'
    ]], {citizenid})

    local total_jobs = totalStats and totalStats[1] and totalStats[1].total_jobs or 0
    local total_earnings = totalStats and totalStats[1] and totalStats[1].total_earnings or 0

    return {
        level = stats.level,
        experience = stats.experience,
        total_jobs = total_jobs,
        total_earnings = total_earnings
    }
end

RegisterNetEvent('dj-cleaning:requestJobHistory')
AddEventHandler('dj-cleaning:requestJobHistory', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local stats = GetPlayerStats(citizenid)
    local recentJobs = GetRecentJobs(citizenid)
    
    TriggerClientEvent('dj-cleaning:receiveJobHistory', src, {
        level = stats.level,
        experience = stats.experience,
        required = GetRequiredXP(stats.level),
        recentJobs = recentJobs,
        total_jobs = stats.total_jobs,
        total_earnings = stats.total_earnings
    })
end)
