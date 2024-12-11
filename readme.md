# FiveM Cleaning Job Script

A highly customizable cleaning job script for FiveM QBCore servers with leveling system, job tracking, and a sleek dashboard UI.

![Dashboard UI](your_screenshot_url_here)

## Features
- 🎯 Progressive leveling system
- 💰 Dynamic payout with level multipliers
- 📊 Clean and modern dashboard UI
- 📈 Job history tracking
- 🚛 Vehicle spawning system
- 💾 Database integration for persistent data
- ⚡ Performance optimized
- 🛠️ Highly configurable

## Dependencies
- [QBCore Framework](https://github.com/qbcore-framework)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- [scully_emotemenu](https://github.com/Scullyy/scully_emotemenu)

## Installation
1. Import the provided SQL file from `sql/cleaning.sql`
2. Add the resource to your server's resource folder
3. Add `ensure dj-cleaning` to your server.cfg
4. Configure the script in `config.lua`
5. Restart your server

## Configuration
```lua
Config = {}

Config.NPCCoords = vector3(176.58, -1460.48, 29.24)
Config.NPCModel = "s_m_y_garbage"
Config.NpcHeading = 120.34

Config.NpcBlip = true
Config.TrashSpotBlip = true

Config.TruckModel = "benson"
Config.TruckSpawnLocation = vector3(165.56, -1466.69, 29.12)
Config.TruckHeading = 49.8

Config.CleaningDuration = 5000
Config.Reward = {min = 100, max = 300}
Config.LevelMultiplier = 0.2 -- 20% increase per level

Config.CleaningLocations = {
    [1] = {
        trashSpots = {
            vector3(159.17, -1452.53, 29.14),
        }
    },
    [2] = {
        trashSpots = {
            vector3(-316.0, -984.5, 31.08),
            vector3(-314.5, -986.0, 31.08),
            vector3(-315.5, -985.5, 31.08),
        }
    }
}

Config.TrashProps = {
    "prop_rub_litter_01",
    "prop_rub_litter_02",
    "prop_rub_litter_03",
    "prop_rub_litter_04",
    "prop_rub_litter_05",
    "prop_rub_litter_06",
    "prop_rub_litter_07"
}

-- Messages
Config.StartJobMessage = "A Location has been marked on your GPS! Go clean!"
Config.EndJobMessage = "You have successfully completed your cleaning job!"
Config.FailedJobMessage = "You failed to clean all trash spots. No payout for you."
Config.PayoutNotification = "You cleaned all spots! Head back to the NPC to collect your payout."
Config.PayoutMessage = "You received $%d for your hard work!"
```