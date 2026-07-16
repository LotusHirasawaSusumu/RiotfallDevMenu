--[[
    ESPPage.lua
    Builds the ESP tab content.
]]

local Components    = require("ui/Components")
local Config        = require("core/Config")
local ESP           = require("systems/ESP")

local ESPPage       = {}

function ESPPage.build(scroll)
    local CFG = Config.ESP
    local lo  = 0
    local function nextOrder() lo = lo + 1 return lo end

    -- Section: Wallhack
    local sec1 = Components.sectionHeader(scroll, "WALLHACK ESP")
    sec1.LayoutOrder = nextOrder()

    local _, _, setESPState = Components.toggle(scroll,
        "Enable ESP Wallhack", CFG.Enabled,
        function(state)
            if state then ESP.enable() else ESP.disable() end
        end)
    _.LayoutOrder = nextOrder()

    -- Section: Visibility
    local sec2 = Components.sectionHeader(scroll, "VISIBILITY")
    sec2.LayoutOrder = nextOrder()

    local enemyRow = Components.toggle(scroll,
        "Enemies Only", CFG.EnemiesOnly,
        function(state)
            CFG.EnemiesOnly = state
            ESP.onSettingChanged()
        end)
    enemyRow.LayoutOrder = nextOrder()

    -- Section: Fill
    local sec3 = Components.sectionHeader(scroll, "TRANSPARENCY")
    sec3.LayoutOrder = nextOrder()

    local fillSlider = Components.slider(scroll,
        "Fill Transparency", 0, 1, CFG.FillTransparency, 0.05,
        function(v)
            CFG.FillTransparency = v
            ESP.onSettingChanged()
        end)
    fillSlider.LayoutOrder = nextOrder()

    local outlineSlider = Components.slider(scroll,
        "Outline Transparency", 0, 1, CFG.OutlineTransparency, 0.05,
        function(v)
            CFG.OutlineTransparency = v
            ESP.onSettingChanged()
        end)
    outlineSlider.LayoutOrder = nextOrder()
end

return ESPPage