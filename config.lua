Config = {}

Config.Debug = false

Config.Dispatch = 'none' -- Dipatch - 'cd' / 'ps' / 'none'
Config.PoliceJobs = {'police', 'lssd', 'sheriff', 'sahp'} -- Jobs that see the dispatch, if using cd dispatch, if ps then in ps dispatch config
Config.DispatchCode = '10-17' -- Code on the dispatch
Config.DispatchMessage = 'Suspicius person exiting container'

Config.RequiredItem = 'lockpick'

Config.ContainerCoords = {
    [1] = vector3(910.5751, -3039.4622, 5.9020),
    [2] = vector3(1005.7899, -3095.9290, 5.9010),
    [3] = vector3(1149.8953, -2987.3542, 5.9010),
    [4] = vector3(845.1858, -3085.2563, 5.9008),
    [5] = vector3(1048.6450, -2992.2795, 5.9010),

    -- Add more if you want
    -- [6] = vector3(1234, 1234, 124),
}

Config.Reward = { -- Rewards to pick randomlny from
    { item = 'weapon_pistol', chance = 50, amount = math.random(3,5) },
    { item = 'money', chance = 100, amount = math.random(300,1000) },
    -- 'weapon_pistol',
    -- 'at_suppressor_light',
    -- 'paperbag'
}

Config.Cooldown = 120 -- In seconds

Config.TargetLabelBreak = 'Break Into Container' -- Label on target to break into
Config.TargetIconBreak = 'fa-solid fa-hammer' -- Icon on target to break into - https://fontawesome.com/icons

Config.TargetLabelExit = 'Exit' -- Label on target to exit
Config.TargetIconExit = 'fa-solid fa-door-open' -- Icon on target to exit - https://fontawesome.com/icons

Config.TargetLabelBox = 'Loot Box' -- Label on target to take loot from box
Config.TargetIconBox = 'fa-solid fa-box' -- Icon on target to take loot from box

Config.TargetDistance = 2

Config.NotifyTitle = 'Required Items'
Config.NotifyDescription = 'You don\'t have the required item to break into the container'

Config.FailTitle = 'Failed'
Config.FailDescription = 'You failed to lockpick the container'

Config.ProgressBarLabel = 'Opening Box'


-- Lock the config to make cheaters unable to edit code
function protect(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function(t, key, value)
            error("attempting to change constant " ..
                   tostring(key) .. " to " .. tostring(value), 2)
        end
    })
end

Config = protect(Config)