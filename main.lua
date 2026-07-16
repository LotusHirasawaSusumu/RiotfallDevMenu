--[[
    ╔══════════════════════════════════════════╗
    ║   RIOTFALL Dev Menu  v1.1                ║
    ║   main.lua — Entry point                 ║
    ║                                          ║
    ║   GitHub: github.com/your-repo           ║
    ║   Game: RIOTFALL [Beta] on Roblox        ║
    ╚══════════════════════════════════════════╝

    Execution order:
        1. Load core modules (Config, Services, State)
        2. Load system modules (ESP, Aimbot, Camera, Events)
        3. Build UI (Window → Tabs → Pages)
        4. Connect events & player hooks
        5. Start render loop
]]

-- ── Module loader ─────────────────────────────────────────────────
-- In a single-file executor environment, paste all modules inline
-- above this section and replace require() with direct table refs.
-- For GitHub multi-file usage, use a loader like:
--   local function require(path) ... end

-- ── Executor single-file shim ─────────────────────────────────────
-- All module code is defined in the sections above (inlined).
-- In the GitHub repo, each file is separate and require() works normally.

local Config        = require("core/Config")
local Services      = require("core/Services")
local State         = require("core/State")

local ESP           = require("systems/ESP")
local Aimbot        = require("systems/Aimbot")
local CameraSystem  = require("systems/Camera")
local Events        = require("systems/Events")

local Theme         = require("ui/Theme")
local Window        = require("ui/Window")
local Tabs          = require("ui/Tabs")

local ESPPage       = require("ui/pages/ESPPage")
local AimbotPage    = require("ui/pages/AimbotPage")
local CameraPage    = require("ui/pages/CameraPage")
local PlayersPage   = require("ui/pages/PlayersPage")

local TeamUtil      = require("util/TeamUtil")

local LP            = Services.LP
local UIS           = Services.UserInputService
local Players       = Services.Players
local RunService    = Services.RunService

-- ── Clean up any existing instance ───────────────────────────────
local oldGui = LP.PlayerGui:FindFirstChild("RiotfallDevMenu")
if oldGui then oldGui:Destroy() end

-- ── Build ScreenGui ───────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name              = "RiotfallDevMenu"
ScreenGui.ResetOnSpawn      = false
ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder      = 999
ScreenGui.IgnoreGuiInset    = true
ScreenGui.Parent            = LP.PlayerGui

-- ── Build Window ──────────────────────────────────────────────────
Window.build(ScreenGui)

-- ── Build Tabs ────────────────────────────────────────────────────
local TAB_NAMES = { "ESP", "AIMBOT", "CAMERA", "PLAYERS" }
Tabs.init(Window.TabBarFrame, Window.ContentArea, TAB_NAMES)

-- ── Build Pages ───────────────────────────────────────────────────
ESPPage.build(    Tabs.getScroll("ESP"))
AimbotPage.build( Tabs.getScroll("AIMBOT"))
CameraPage.build( Tabs.getScroll("CAMERA"))
PlayersPage.build(Tabs.getScroll("PLAYERS"))

-- ── Init systems ──────────────────────────────────────────────────
TeamUtil.refreshLocalTeam()
Events.connect()

-- ── Player lifecycle hooks ────────────────────────────────────────
State:Track(Players.PlayerAdded:Connect(function(player)
    TeamUtil.refreshLocalTeam()
    PlayersPage.onPlayerAdded(player)
    if Config.ESP.Enabled then
        task.delay(1.5, function()
            if player and player.Parent then
                ESP.refreshAll()
            end
        end)
    end
end))

State:Track(Players.PlayerRemoving:Connect(function(player)
    PlayersPage.removeCard(player.Name)
end))

-- ── INSERT key to toggle visibility ──────────────────────────────
State:Track(UIS.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if inp.KeyCode == Config.TOGGLE_KEY then
        State.MenuVisible           = not State.MenuVisible
        Window.Main.Visible         = State.MenuVisible
        Window.Shadow.Visible       = State.MenuVisible
    end
end))

-- ── Render loop ───────────────────────────────────────────────────
local renderConn
renderConn = RunService.RenderStepped:Connect(function()

    -- Close requested by Window module
    if ScreenGui:GetAttribute("_RequestClose") then
        renderConn:Disconnect()
        State.Cleanup()
        Config.ESP.Enabled  = false
        ESP.refreshAll()
        CameraSystem.disable()
        ScreenGui:Destroy()
        return
    end

    -- Per-frame systems
    TeamUtil.refreshLocalTeam()
    Aimbot.step()
    CameraSystem.step()

    -- Status bar
    if Window.StatusLabel then
        Window.StatusLabel.Text = string.format(
            " ● %s | HP: %s/%s | Ammo: %s | Lock: %s",
            State.LocalTeamName,
            tostring(State.CurrentHP),
            tostring(State.MaxHP),
            State.CurrentAmmo,
            State.AimbotLocked
                and State.AimbotLocked.Parent
                and State.AimbotLocked.Parent.Name
                or "none"
        )
    end

    -- Camera tab live info
    if State.ActiveTab == "CAMERA" and CameraPage.fovLabel then
        local cam = Services.Camera
        CameraPage.fovLabel.Text = "FOV: " .. math.floor(cam.FieldOfView)
        local s, pos = pcall(function() return cam.CFrame.Position end)
        if s and CameraPage.posLabel then
            CameraPage.posLabel.Text = string.format(
                "Pos: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
        end
    end

    -- Players tab live refresh
    if State.ActiveTab == "PLAYERS" then
        PlayersPage.refresh()
    end
end)
State:Track(renderConn)

-- ── Notification ──────────────────────────────────────────────────
task.spawn(function()
    task.wait(0.5)
    Services.StarterGui:SetCore("SendNotification", {
        Title    = "RIOTFALL Dev Menu v" .. Config.VERSION,
        Text     = "[INSERT] toggle | ESP + Aimbot ready",
        Duration = 5,
    })
end)