-- main.lua
local RAW    = "https://raw.githubusercontent.com/LotusHirasawaSusumu/RiotfallDevMenu/main/"
local _cache = {}

local function _require(path)
    if _cache[path] then return _cache[path] end
    local ok, src = pcall(function() return game:HttpGet(RAW .. path .. ".lua") end)
    if not ok then
        error("[DevMenu] HttpGet failed: " .. path .. " → " .. tostring(src))
    end
    local fn, err = loadstring(src, path)
    if not fn then
        error("[DevMenu] Parse error: " .. path .. " → " .. tostring(err))
    end
    local result = fn()
    _cache[path] = result
    return result
end

local Services = _require("core/Services")
local Config   = _require("core/Config")
local State    = _require("core/State")

local ESP    = _require("systems/ESP")   (Services, Config, State)
local Aimbot = _require("systems/Aimbot")(Services, Config, State)
local CamSys = _require("systems/Camera")(Services, Config, State)
local Events = _require("systems/Events")(Services, Config, State)

local repo         = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options      = Library.Options
local Toggles      = Library.Toggles

local Window = Library:CreateWindow({
    Title            = "RIOTFALL Dev Menu",
    Footer           = "v" .. Config.VERSION,
    ShowCustomCursor = true,
    NotifySide       = "Right",
    AutoShow         = true,
})

local Tabs = {
    ESP      = Window:AddTab("ESP",      "eye"),
    Aimbot   = Window:AddTab("Aimbot",   "crosshair"),
    Camera   = Window:AddTab("Camera",   "camera"),
    Players  = Window:AddTab("Players",  "users"),
    Settings = Window:AddTab("Settings", "settings"),
}

local FOVCircle   = _require("ui/FOVCircle")        (Services, Config, State)
local ESPTab      = _require("ui/Tabs/ESPTab")      (Services, Config, State, Library, Tabs, ESP)
local AimbotTab   = _require("ui/Tabs/AimbotTab")   (Services, Config, State, Library, Tabs, Aimbot, FOVCircle)
local CameraTab   = _require("ui/Tabs/CameraTab")   (Services, Config, State, Library, Tabs, CamSys)
local PlayersTab  = _require("ui/Tabs/PlayersTab")  (Services, Config, State, Library, Tabs)
local SettingsTab = _require("ui/Tabs/SettingsTab") (Services, Config, State, Library, Tabs, Window,
                                                     ThemeManager, SaveManager)

local Players = Services.Players
local LP      = Services.LP

State:Track(Players.PlayerRemoving:Connect(function(player)
    State:InvalidateTeamCache()
    ESP.removePlayer(player)
end))

Library:OnUnload(function()
    ESP.removeAll()
    CamSys.disable()
    FOVCircle.destroy()
    State:Cleanup()
end)

local RunService = Services.RunService
local Camera     = Services.Camera

-- RenderStepped: aimbot (needs frame-sync for mouse input) + FOV circle
State:Track(RunService.RenderStepped:Connect(function()
    if Library.Unloaded then return end
    Aimbot.step()
    FOVCircle.update(Aimbot.getFOV())
    CamSys.step()
end))

-- Heartbeat: camera labels (no frame-sync needed)
State:Track(RunService.Heartbeat:Connect(function()
    if Library.Unloaded then return end
    if Options.CamFOVLbl then
        Options.CamFOVLbl:SetText("FOV: " .. math.floor(Camera.FieldOfView) .. "°")
    end
    if Options.CamPosLbl then
        local ok, pos = pcall(function() return Camera.CFrame.Position end)
        if ok then
            Options.CamPosLbl:SetText(string.format(
                "Pos: %.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z))
        end
    end
end))

task.spawn(function()
    State:InvalidateTeamCache()
    Events.connect()
    task.wait(1)
    Library:Notify({
        Title       = "RIOTFALL Dev Menu v" .. Config.VERSION,
        Description = "Team: " .. State:GetLocalTeam() .. "  |  RightShift = toggle",
        Time        = 4,
    })
end)