RegisterNetEvent('robcontainers:server:removeItem', function (item)
    exports.ox_inventory:RemoveItem(source, item, 1)
end)

RegisterNetEvent('robcontainers:server:reward', function (check)
    if check then
        for k, v in ipairs(Config.Reward) do
            print(v)
            exports.ox_inventory:AddItem(source, v, 1)
        end
    end
end)