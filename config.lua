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
