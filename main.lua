--[[
    RIOTFALL Dev Menu v2.2
    GitHub: https://github.com/LotusHirasawaSusumu/RiotfallDevMenu
    Load: loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/LotusHirasawaSusumu/RiotfallDevMenu/main/main.lua"
    ))()
]]

-- ── HTTP module loader ────────────────────────────────────────────
local RAW = "https://raw.githubusercontent.com/LotusHirasawaSusumu/RiotfallDevMenu/main/"
local _cache = {}

local function _require(path)
    if _cache[path] then return _cache[path] end
    local src = game:HttpGet(RAW .. path .. ".lua")
    local fn, err = loadstring(src, path)
    if not fn then
        error("[RiotfallDevMenu] Failed to load module '" .. path .. "': " .. tostring(err))
    end
    local result = fn()
    _cache[path] = result
    return result
end

-- ── Load core (no dependencies) ──────────────────────────────────
local Services = _require("core/Services")
local Config   = _require("core/Config")
local State    = _require("core/State")

-- ── Inject shared globals into each module via environment ───────
-- Systems and UI modules receive these as function arguments,
-- avoiding any require() call inside them.

-- ── Load systems ─────────────────────────────────────────────────
local ESP     = _require("systems/ESP")    (Services, Config, State)
local Aimbot  = _require("systems/Aimbot") (Services, Config, State)
local CamSys  = _require("systems/Camera") (Services, Config, State)
local Events  = _require("systems/Events") (Services, Config, State)

-- ── Obsidian bootstrap ───────────────────────────────────────────
local repo         = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options      = Library.Options
local Toggles      = Library.Toggles

-- ── Window ───────────────────────────────────────────────────────
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

-- ── Load UI modules ──────────────────────────────────────────────
local FOVCircle  = _require("ui/FOVCircle")  (Services, Config, State)
local ESPTab     = _require("ui/Tabs/ESPTab")     (Services, Config, State, Library, Tabs, ESP)
local AimbotTab  = _require("ui/Tabs/AimbotTab")  (Services, Config, State, Library, Tabs, Aimbot, FOVCircle)
local CameraTab  = _require("ui/Tabs/CameraTab")  (Services, Config, State, Library, Tabs, CamSys)
local PlayersTab = _require("ui/Tabs/PlayersTab") (Services, Config, State, Library, Tabs)
local SettingsTab= _require("ui/Tabs/SettingsTab")(Services, Config, State, Library, Tabs, Window,
                                                    ThemeManager, SaveManager)

-- ── Player lifecycle ─────────────────────────────────────────────
local Players = Services.Players
local LP      = Services.LP

State:Track(Players.PlayerAdded:Connect(function(player)
    State.LocalTeamName = Services.getTeamName(LP)
    if Toggles.ESPEnabled and Toggles.ESPEnabled.Value then
        task.delay(2, function()
            if player and player.Parent then ESP.refreshAll() end
        end)
    end
    State:Track(player:GetPropertyChangedSignal("Team"):Connect(function()
        local mesh = Services.CharacterMeshes
            and Services.CharacterMeshes:FindFirstChild(player.Name)
        if mesh and Toggles.ESPEnabled and Toggles.ESPEnabled.Value then
            ESP.applyToMesh(mesh)
        end
    end))
end))

State:Track(Players.PlayerRemoving:Connect(function()
    State.LocalTeamName = Services.getTeamName(LP)
end))

-- ── Unload ───────────────────────────────────────────────────────
Library:OnUnload(function()
    ESP.removeAll()
    CamSys.disable()
    FOVCircle.destroy()
    State:Cleanup()
end)

-- ── Render loop ──────────────────────────────────────────────────
local RunService = Services.RunService
local Camera     = Services.Camera

State:Track(RunService.RenderStepped:Connect(function()
    if Library.Unloaded then return end

    State.LocalTeamName = Services.getTeamName(LP)
    Aimbot.step()
    CamSys.step()
    FOVCircle.update()

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

-- ── Init ─────────────────────────────────────────────────────────
task.spawn(function()
    State.LocalTeamName = Services.getTeamName(LP)
    Events.connect()
    task.wait(1)
    Library:Notify({
        Title       = "RIOTFALL Dev Menu v" .. Config.VERSION,
        Description = "Team: " .. State.LocalTeamName .. "  |  RightShift = toggle",
        Time        = 4,
    })
end)