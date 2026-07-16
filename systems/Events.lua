return function(Services, Config, State)
    local RS = Services.ReplicatedStorage

    local Events = {}

    function Events.connect()
        local c2c = RS:WaitForChild(Config.Events.ClientToClient, 10)
        if not c2c then return end

        local hEvt = c2c:FindFirstChild(Config.Events.HealthEvent)
        if hEvt and hEvt:IsA("BindableEvent") then
            State:Track(hEvt.Event:Connect(function(data)
                if type(data) == "table" then
                    State.CurrentHP = data.health or data.hp
                        or data.currentHealth or State.CurrentHP
                    State.MaxHP = data.maxHealth or data.maxHp or State.MaxHP
                elseif type(data) == "number" then
                    State.CurrentHP = data
                end
            end))
        end

        local aEvt = c2c:FindFirstChild(Config.Events.AmmoEvent)
        if aEvt and aEvt:IsA("BindableEvent") then
            State:Track(aEvt.Event:Connect(function(data)
                if type(data) == "table" then
                    local cur = data.ammo or data.current or data.currentAmmo or "?"
                    local res = data.reserve or data.reserveAmmo or data.total or "?"
                    State.CurrentAmmo = tostring(cur) .. "/" .. tostring(res)
                elseif type(data) == "number" then
                    State.CurrentAmmo = tostring(data) .. "/?"
                end
            end))
        end
    end

    return Events
end