--[[
    Aimbot.lua
    Hold RMB (configurable) to lock onto nearest enemy within FOV radius.
    Uses Top/Center/Bottom Parts from Workspace.Characters.<name>
]]

local Services  = require("core/Services")
local Config    = require("core/Config")
local State     = require("core/State")
local TeamUtil  = require("util/TeamUtil")
local Loadout   = require("util/Loadout")

local Aimbot    = {}
local CFG       = Config.Aimbot

local function worldToScreen(pos)
    local s, vp = pcall(function()
        return Services.Camera:WorldToViewportPoint(pos)
    end)
    if not s then return nil, false end
    return Vector2.new(vp.X, vp.Y), vp.Z > 0
end

local function screenCenter()
    return Services.Camera.ViewportSize / 2
end

local function findBestTarget()
    local center    = screenCenter()
    local bestDist  = CFG.FOVRadius
    local bestPart  = nil

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == Services.LP then continue end
        if CFG.EnemyOnly and not TeamUtil.isEnemy(player) then continue end

        local part = Loadout.getTargetPart(player, CFG.TargetBone)
        if not part then continue end

        local s, pos = pcall(function() return part.Position end)
        if not s then continue end

        local screenPos, onScreen = worldToScreen(pos)
        if not onScreen then continue end

        local dist = (screenPos - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestPart = part
        end
    end

    return bestPart
end

-- Called every RenderStepped
function Aimbot.step()
    if not CFG.Enabled then
        State.AimbotLocked = nil
        return
    end

    local UIS = Services.UserInputService
    if not UIS:IsMouseButtonPressed(CFG.TriggerKey) then
        State.AimbotLocked = nil
        return
    end

    local target = findBestTarget()
    State.AimbotLocked = target
    if not target then return end

    local s, pos = pcall(function() return target.Position end)
    if not s then return end

    local screenPos, onScreen = worldToScreen(pos)
    if not onScreen then return end

    local delta = (screenPos - screenCenter()) * (1 - CFG.Smoothing)

    if mousemoverel then
        mousemoverel(delta.X, delta.Y)
    end
end

return Aimbot