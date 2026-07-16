--[[
    Services.lua
    Central service reference cache.
    Import this instead of calling GetService repeatedly.
]]

local Services = {
    Players         = game:GetService("Players"),
    RunService      = game:GetService("RunService"),
    UserInputService= game:GetService("UserInputService"),
    TweenService    = game:GetService("TweenService"),
    Teams           = game:GetService("Teams"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace       = game:GetService("Workspace"),
    StarterGui      = game:GetService("StarterGui"),
    HttpService     = game:GetService("HttpService"),
}

Services.LP     = Services.Players.LocalPlayer
Services.Camera = Services.Workspace.CurrentCamera

return Services