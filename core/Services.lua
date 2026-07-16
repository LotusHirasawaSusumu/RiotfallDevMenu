local Players    = game:GetService("Players")
local LP         = Players.LocalPlayer
local Workspace  = game:GetService("Workspace")

local Services = {
    Players           = Players,
    LP                = LP,
    RunService        = game:GetService("RunService"),
    UserInputService  = game:GetService("UserInputService"),
    Teams             = game:GetService("Teams"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace         = Workspace,
    HttpService       = game:GetService("HttpService"),
    Camera            = Workspace.CurrentCamera,
    CharacterMeshes   = Workspace:WaitForChild("CharacterMeshes", 10),
}

function Services.getTeamName(player)
    local ok, t = pcall(function() return player.Team end)
    return (ok and t) and t.Name or "NONE"
end

function Services.isEnemy(player)
    if player == Services.LP then return false end
    local ok, lpTeam = pcall(function() return Services.LP.Team end)
    local ok2, pTeam = pcall(function() return player.Team end)
    if not ok or not ok2 then return true end
    return lpTeam ~= pTeam
end

return Services