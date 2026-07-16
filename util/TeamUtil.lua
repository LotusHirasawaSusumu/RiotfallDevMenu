--[[
    TeamUtil.lua
    Team identification helpers.
]]

local Services  = require("core/Services")
local State     = require("core/State")

local TeamUtil  = {}

function TeamUtil.getPlayerTeam(player)
    local s, t = pcall(function() return player.Team end)
    return (s and t) and t.Name or "NONE"
end

function TeamUtil.refreshLocalTeam()
    State.LocalTeamName = TeamUtil.getPlayerTeam(Services.LP)
end

function TeamUtil.isEnemy(player)
    if player == Services.LP then return false end
    return TeamUtil.getPlayerTeam(player) ~= State.LocalTeamName
end

-- Returns all players split into enemy / friendly tables
function TeamUtil.getPlayersSplit()
    local enemies   = {}
    local friendly  = {}
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p == Services.LP then continue end
        if TeamUtil.isEnemy(p) then
            table.insert(enemies, p)
        else
            table.insert(friendly, p)
        end
    end
    return enemies, friendly
end

return TeamUtil