# FiveM Cleaning Job Script

A customizable cleaning job script for FiveM QBCore servers with leveling system, job tracking, and a sleek dashboard UI.

![Dashboard](https://github.com/user-attachments/assets/8adb0cf1-33a5-416d-bfa1-edb3126a273a)

Check the showcase video [here](https://youtu.be/vfryNrKkkq4)

## Features
- 🎯 Progressive leveling system
- 💰 Dynamic payout with level multipliers
- 📊 Clean and modern dashboard UI
- 📈 Job history tracking
- 🚛 Vehicle spawning system
- 💾 Database integration for persistent data

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

Config.NPCCoords = vector3(175.64, -1460.46, 29.24)
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
Config.MaxLevel = 15 -- Set to 0 for no level cap

Config.CleaningLocations = {
    [1] = {
        trashSpots = {
            vector3(127.21, -1453.47, 29.29),
            vector3(120.72, -1458.6, 29.33),
            vector3(123.8, -1464.57, 29.32),
        }
    },
    [2] = {
        trashSpots = {
            vector3(128.96, -1515.42, 29.15),
            vector3(107.75, -1530.86, 29.35),
        }
    },
    -- [3] = {
    --     trashSpots = {
    --         vector3(0, 0, 0),
    --         more trash spots...
    --     }
    -- },
}

Config.TrashProps = {
    "prop_rub_litter_01",
    "prop_rub_litter_02",
    "prop_rub_litter_03",
    "prop_rub_litter_04",
    "prop_rub_litter_05",
    "prop_rub_litter_06",
    "prop_rub_litter_07",
}

Config.StartJobMessage = "A Location has been marked on your GPS! Go clean!"
Config.FailedJobMessage = "You failed to clean all trash spots. No payout for you."
Config.PayoutNotification = "You cleaned all spots! Head back to the NPC to collect your payout."
Config.PayoutMessage = "You received $%d for your hard work!"
Config.ReturnTruckMessage = "Return to the Cleaning Manager to hand in your truck and end the job."

```
