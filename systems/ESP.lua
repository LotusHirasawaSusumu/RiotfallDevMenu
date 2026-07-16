--[[
    ESP.lua
    Controls Workspace.PlayerHighlights highlights.
    The game pre-creates Highlight objects for all enemies
    with FillTransparency=1, OutlineTransparency=1 (invisible).
    We simply adjust those values — no new instances needed.
]]

local Services  = require("core/Services")
local Config    = require("core/Config")
local TeamUtil  = require("util/TeamUtil")

local ESP       = {}
local CFG       = Config.ESP

local function getHighlight(player)
    local folder = Services.Workspace:FindFirstChild(
        Config.Folders.PlayerHighlights)
    if not folder then return nil end
    return folder:FindFirstChild(player.Name)
end

local function applyToPlayer(player, enabled)
    local hl = getHighlight(player)
    if not hl then return end

    if not enabled then
        -- Restore game defaults
        hl.FillColor            = CFG.DefaultFillColor
        hl.OutlineColor         = CFG.DefaultOutlineColor
        hl.FillTransparency     = 1
        hl.OutlineTransparency  = 1
        return
    end

    local enemy = TeamUtil.isEnemy(player)

    -- Enemies-only mode: keep teammates invisible
    if CFG.EnemiesOnly and not enemy then
        hl.FillTransparency     = 1
        hl.OutlineTransparency  = 1
        return
    end

    hl.FillColor            = enemy and CFG.EnemyFillColor   or CFG.TeamFillColor
    hl.OutlineColor         = enemy and CFG.EnemyOutlineColor or CFG.TeamOutlineColor
    hl.FillTransparency     = CFG.FillTransparency
    hl.OutlineTransparency  = CFG.OutlineTransparency
end

function ESP.refreshAll()
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Services.LP then
            applyToPlayer(player, CFG.Enabled)
        end
    end
end

function ESP.enable()
    CFG.Enabled = true
    ESP.refreshAll()
end

function ESP.disable()
    CFG.Enabled = false
    ESP.refreshAll()
end

function ESP.toggle()
    if CFG.Enabled then ESP.disable() else ESP.enable() end
    return CFG.Enabled
end

-- Called when per-setting changes (transparency, color, mode)
function ESP.onSettingChanged()
    if CFG.Enabled then ESP.refreshAll() end
end

return ESP