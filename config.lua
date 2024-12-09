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
Config.CashItem = "cash"

Config.JobLocations = {
    -- [1] = {
    --     trashSpots = {
    --         vector3(-310.5, -979.5, 31.08),
    --         vector3(-309.5, -980.5, 31.08),
    --         vector3(-311.0, -981.0, 31.08),
    --     }
    -- },
    -- [2] = {
    --     trashSpots = {
    --         vector3(-316.0, -984.5, 31.08),
    --         vector3(-314.5, -986.0, 31.08),
    --         vector3(-315.5, -985.5, 31.08),
    --     }
    -- },
    [1] = {
        trashSpots = {
            vector3(159.17, -1452.53, 29.14),
            -- vector3(-309.5, -980.5, 31.08),
            -- vector3(-311.0, -981.0, 31.08),
        }
    },

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
Config.EndJobMessage = "You have successfully completed your cleaning job!"
Config.FailedJobMessage = "You failed to clean all trash spots. No payout for you."
Config.PayoutNotification = "You cleaned all spots! Head back to the NPC to collect your payout."
Config.PayoutMessage = "You received $%d for your hard work!"
