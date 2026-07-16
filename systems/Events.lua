--[[
    Events.lua
    Hooks into clientToClient BindableEvents for HP, ammo, damage.
]]

local Services  = require("core/Services")
local Config    = require("core/Config")
local State     = require("core/State")

local Events    = {}

function Events.connect()
    local RS        = Services.ReplicatedStorage
    local c2c       = RS:WaitForChild(Config.Events.ClientToClient, 10)
    if not c2c then
        warn("[Events] clientToClient not found")
        return
    end

    -- ── Health ─────────────────────────────
    local healthEvt = c2c:FindFirstChild(Config.Events.HealthEvent)
    if healthEvt and healthEvt:IsA("BindableEvent") then
        State:Track(healthEvt.Event:Connect(function(data)
            if type(data) == "table" then
                State.CurrentHP = data.health
                    or data.hp
                    or data.currentHealth
                    or State.CurrentHP
                State.MaxHP     = data.maxHealth
                    or data.maxHp
                    or State.MaxHP
            elseif type(data) == "number" then
                State.CurrentHP = data
            end
        end))
    end

    -- ── Ammo ───────────────────────────────
    local ammoEvt = c2c:FindFirstChild(Config.Events.AmmoEvent)
    if ammoEvt and ammoEvt:IsA("BindableEvent") then
        State:Track(ammoEvt.Event:Connect(function(data)
            if type(data) == "table" then
                local cur = data.ammo
                    or data.current
                    or data.currentAmmo
                    or "?"
                local res = data.reserve
                    or data.reserveAmmo
                    or data.total
                    or "?"
                State.CurrentAmmo = tostring(cur) .. "/" .. tostring(res)
            elseif type(data) == "number" then
                State.CurrentAmmo = tostring(data) .. "/?"
            end
        end))
    end

    -- ── Incoming Damage (reserved for future damage indicator) ──
    local dmgEvt = c2c:FindFirstChild(Config.Events.DamageEvent)
    if dmgEvt and dmgEvt:IsA("BindableEvent") then
        State:Track(dmgEvt.Event:Connect(function(_data)
            -- Future: flash damage indicator on screen
        end))
    end
end

return Events