-- core/Services.lua
local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Services = {
    Players           = Players,
    LP                = Players.LocalPlayer,
    RunService        = game:GetService("RunService"),
    UserInputService  = game:GetService("UserInputService"),
    Teams             = game:GetService("Teams"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace         = Workspace,
    HttpService       = game:GetService("HttpService"),
    Camera            = Workspace.CurrentCamera,
    CharacterMeshes     = Workspace:WaitForChild("CharacterMeshes",     10),
    Characters          = Workspace:WaitForChild("Characters",          10),
    CharacterCollisions = Workspace:WaitForChild("CharacterCollisions", 10),
}

return Services