local entered = {}
local cooldown = {}

function DistanceCheckLocations(src, locations)
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    local dist

    for k, v in pairs(locations) do
        dist = #(pCoords - v)
        if #(pCoords - v) < Config.TargetDistance + 0.5 then
            dist = #(pCoords- v)
            break
        end
    end

    if dist > 5 then
        DropPlayer(src, 'Attempted Cheating - yetti_robcontainers - server')
        return false
    end

    return true
end

function IsNearCrate(src)
    local pCoords = GetEntityCoords(GetPlayerPed(src))

    for _, v in pairs(Config.ContainerCoords) do
        -- crate spawns with offsets: -5 X, -10 Z
        local crateCoords = vector3(v.x - 5, v.y, v.z - 10)
        local dist = #(pCoords - crateCoords)

        if dist <= Config.TargetDistance + 0.5 then
            return true
        end
    end

    DropPlayer(src, 'Attempted Cheating - yetti_robcontainers - server')

    return false
end

RegisterNetEvent('yetti_robcontainers:server:left', function ()
    local src = source

    if DistanceCheckLocations(src, Config.ContainerCoords) then
        entered[src] = false
    end
end)

RegisterNetEvent('yetti_robcontainers:server:entered', function ()
    local src = source

    -- print('recieved')
    if DistanceCheckLocations(src, Config.ContainerCoords) then
        -- print('passed check')
        entered[src] = true
    end
end)

RegisterNetEvent('yetti_robcontainers:server:removeItem', function (item)
    if not entered[source] then
        exports.ox_inventory:RemoveItem(source, item, 1)
    end
end)

RegisterNetEvent('yetti_robcontainers:server:reward', function ()
    local src = source
    -- check for cooldown, if entered, and if is near
    if not cooldown[src] then
        if entered[src] then
            if IsNearCrate(src) then
                Citizen.CreateThread(function ()
                    cooldown[src] = true
                    Wait(Config.Cooldown - 2 * 1000) -- abit shorter just incase of delay
                    cooldown[src] = false
                end)

                for k, v in ipairs(Config.Reward) do
                    local chance = math.random(1,100)
                    if chance < v.chance then
                        exports.ox_inventory:AddItem(src, v.item, v.amount)
                    end
                end

                return -- return so person doesn't get kicked 
            end
        end
    end

    DropPlayer(src, 'Attempted Cheating - yetti_robcontainers - server')
end)