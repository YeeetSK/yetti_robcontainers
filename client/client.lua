--
--- Main Loop
--

function SendDispatch()
    if Config.Dispatch == 'none' then return end

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
end

for k, v in ipairs(Config.ContainerCoords) do
    local inCooldown = false
    local coords = v
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
                            TriggerServerEvent('yetti_robcontainers:server:entered')
                            DoScreenFadeOut(500)
                            Wait(750)
                            SetEntityCoords(PlayerPedId(), coords.x + exit.x, coords.y + exit.y, coords.z - 10 + exit.z)
                            Wait(750)
                            DoScreenFadeIn(500)

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
                                TriggerServerEvent('yetti_robcontainers:server:removeItem', Config.RequiredItem)
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
    
    lib.requestModel('container_shell')
    local shell = CreateObject('container_shell', coords.x, coords.y, coords.z - 10, false)
    SetEntityHeading(shell, 270.7507)
    FreezeEntityPosition(shell, true)
    SetModelAsNoLongerNeeded('container_shell')

    lib.requestModel('m23_1_prop_m31_crate_bones')
    local box = CreateObject('m23_1_prop_m31_crate_bones', coords.x - 5, coords.y, coords.z - 10, false)
    SetEntityHeading(box, 270.7507)
    FreezeEntityPosition(box, true)
    SetModelAsNoLongerNeeded('m23_1_prop_m31_crate_bones')

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
                    Wait(750)
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                    Wait(750)
                    DoScreenFadeIn(500)

                    TriggerServerEvent('yetti_robcontainers:server:left')
                    SendDispatch()

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
                    TriggerServerEvent('yetti_robcontainers:server:reward')
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



