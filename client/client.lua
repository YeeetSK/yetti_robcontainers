--
--- Main Loop
--

for k, v in ipairs(Config.ContainerCoords) do
    local inCooldown = false
    local coords = v.coords
    local exit = json.decode('{"x": 5.0, "y": 0.0, "z": 1.0, "h":2.263}')
    
    local claimedBox = false
    local inContainer = false

    exports.ox_target:addBoxZone({
        coords = vector3(coords.x, coords.y, coords.z + 0.25),
        size = vector3(1.2, 1.2, 3.0),
        rotation = 0.0,
        debug = Config.Debug,
        options = {
            {
                label = Config.TargetLabelBreak,
                icon = Config.TargetIconBreak,
                distance = Config.TargetDistance,
                canInteract = function ()
                    return not inCooldown
                end,
                onSelect = function (source)
                    local itemCount = exports.ox_inventory:Search('count', Config.RequiredItem)
                    if itemCount >= 1 then
                        local success = lib.skillCheck({'medium', 'easy', 'medium', 'easy'}, {'e'})
                        if success then
                            DoScreenFadeOut(500)
                            Wait(1500)
                            DoScreenFadeIn(500)
                            SetEntityCoords(PlayerPedId(), coords.x + exit.x, coords.y + exit.y, coords.z - 10 + exit.z)
                            inContainer = true
                        else
                            local breakChance = math.random(1,5)
                            lib.notify({
                                title = Config.FailTitle,
                                description = Config.FailDescription,
                                type = 'error',
                                duration = 5000
                            })
                            if breakChance == 1 then
                                TriggerServerEvent('robcontainers:server:removeItem', Config.RequiredItem)
                            end
                        end
                    else
                        lib.notify({
                            title = Config.NotifyTitle,
                            description = Config.NotifyDescription,
                            type = 'warning',
                            duration = 5000,
                            id = 'required_item'
                        })
                    end
                end,
            }
        }
    })
    
    local shell = CreateObject('container_shell', coords.x, coords.y, coords.z - 10, true)
    SetEntityHeading(shell, 270.7507)
    FreezeEntityPosition(shell, true)

    local box = CreateObject('m23_1_prop_m31_crate_bones', coords.x - 5, coords.y, coords.z - 10, true)
    SetEntityHeading(box, 270.7507)
    FreezeEntityPosition(box, true)


    exports.ox_target:addBoxZone({
        coords = vector3(coords.x + exit.x, coords.y + exit.y, coords.z - 10 + exit.z),
        size = vector3(1.2, 1.2, 3.0),
        rotation = 0.0,
        distance = Config.TargetDistance,
        debug = Config.Debug,
        options = {
            {
                label = Config.TargetLabelExit,
                icon = Config.TargetIconExit,
                distance = Config.TargetDistance,
                onSelect = function ()
                    inContainer = false
                    inCooldown = true
                    DoScreenFadeOut(500)
                    Wait(1500)
                    DoScreenFadeIn(500)
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                    if Config.Dispatch == 'ps' then
                        exports['ps-dispatch']:SuspiciousActivity()
                    elseif Config.Dispatch == 'cd' then
                        local data = exports['cd_dispatch']:GetPlayerInfo()
                        TriggerServerEvent('cd_dispatch:AddNotification', {
                            job_table = Config.PoliceJobs,
                            coords = data.coords,
                            title = Config.DispatchCode,
                            message = Config.DispatchMessage,
                            flash = 0,
                            unique_id = data.unique_id,
                            sound = 1,
                            blip = {
                                sprite = 66, 
                                scale = 0.7, 
                                colour = 0,
                                flashes = false, 
                                text = Config.DispatchCode,
                                time = 5,
                                radius = 0,
                            }
                        })
                    end
                    Wait(Config.Cooldown * 1000)
                    claimedBox = false
                    inCooldown = false
                end,
                canInteract = function ()
                    return inContainer
                end
            }
        }
    })

    exports.ox_target:addBoxZone({
        coords = vector3( coords.x - 5, coords.y, coords.z - 10),
        size = vector3(2.5, 2.5, 3.0),
        rotation = 0.0,
        distance = Config.TargetDistance,
        debug = Config.Debug,
        options = {
            {
                label = Config.TargetLabelBox,
                icon = Config.TargetIconBox,
                distance = Config.TargetDistance,
                onSelect = function ()
                    if lib.progressCircle({
                        duration = 10000,
                        position = 'middle',
                        useWhileDead = false,
                        canCancel = true,
                        label = Config.ProgressBarLabel,
                        disable = {
                            car = true,
                            move = true
                        },
                        anim = {
                            dict = 'mini@repair',
                            clip = 'fixing_a_ped'
                        },
                  }) then
                    claimedBox = true
                    TriggerServerEvent('robcontainers:server:reward', true)
                  end

                end,
                canInteract = function ()
                    if inContainer then
                        return not claimedBox
                    else
                        return false
                    end
                end
            }
        }
    })

end



