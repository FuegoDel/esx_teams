Config = {}


Config.MenuKey = 167

Config.TeamSettings = {
    MaxLevelXp = {
        [1] = 1000,
        [2] = 2000,
        [3] = 3000
    }
}

Config.NPC = {
    Model = 's_m_y_devinsec_01',
    Coords = vector3(781.94,1280.98,360.3),
    Heading = 276.58,
    UsesBlip = true,
    BlipSprite = 437,
    BlipColour = 0,
    BlipName = 'Team Creation',
    DrawingDistance = 5.0,
    UsesDrawText = true,
    UsesHelpNotification = false,
    DrawingNotification = "Press [~r~E~w~] to open ~g~Creation~w~ menu"
}

Config.Icons = { --Key is grade
    [0] = 'fal fa-user',
    [1] = 'fal fa-user-headset',
    [2] = 'fal fa-user-crown'
}

Config.RewardsONKill = {
    UsesRewards = true,
    GivesExperience = true,
    ExperienceAmount = 5,
    BlackListedLocations = {
        [vector3(2627.4,3662.36,101.58)] = 20.0 -- Radius
    }
}

Config.Privilages = {
   ['stamina'] =   {privilageName = 'stamina', label = 'Unlimited Stamina', cost = 250, fontIcon = 'fal fa-battery-full', requiredLevel = 1},
   ['recoil'] =    {privilageName = 'recoil', label = 'No Recoil', cost = 250, fontIcon = 'fal fa-dot-circle', requiredLevel = 1},
   ['healthreg'] = {privilageName = 'healthreg', label = 'Health Regen', cost = 350, fontIcon = 'fal fa-heartbeat', requiredLevel = 2},
   ['vestreg'] =   {privilageName = 'vestreg', label = 'Vest Regen', cost = 150, fontIcon = 'fal fa-vest', requiredLevel = 2},
}