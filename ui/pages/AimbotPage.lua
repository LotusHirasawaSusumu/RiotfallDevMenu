--[[
    AimbotPage.lua
    Builds the Aimbot tab content.
]]

local Components    = require("ui/Components")
local Config        = require("core/Config")

local AimbotPage    = {}

function AimbotPage.build(scroll)
    local CFG = Config.Aimbot
    local lo  = 0
    local function nextOrder() lo = lo + 1 return lo end

    -- Section: Control
    local sec1 = Components.sectionHeader(scroll, "AIMBOT CONTROL")
    sec1.LayoutOrder = nextOrder()

    local abRow = Components.toggle(scroll,
        "Enable Aimbot  (Hold RMB)", CFG.Enabled,
        function(state) CFG.Enabled = state end)
    abRow.LayoutOrder = nextOrder()

    local enemyRow = Components.toggle(scroll,
        "Enemies Only", CFG.EnemyOnly,
        function(state) CFG.EnemyOnly = state end)
    enemyRow.LayoutOrder = nextOrder()

    -- Section: Settings
    local sec2 = Components.sectionHeader(scroll, "AIMBOT SETTINGS")
    sec2.LayoutOrder = nextOrder()

    local fovSlider = Components.slider(scroll,
        "FOV Radius (px)", 10, 500, CFG.FOVRadius, 5,
        function(v) CFG.FOVRadius = v end)
    fovSlider.LayoutOrder = nextOrder()

    local smoothSlider = Components.slider(scroll,
        "Smoothing", 0, 0.99, CFG.Smoothing, 0.01,
        function(v) CFG.Smoothing = v end)
    smoothSlider.LayoutOrder = nextOrder()

    -- Section: Target bone
    local sec3 = Components.sectionHeader(scroll, "TARGET BONE")
    sec3.LayoutOrder = nextOrder()

    -- ✅ Radio group stored entirely in a Lua table
    local bones = {
        { label = "Top    (Head)",  value = "Top"    },
        { label = "Center (Chest)", value = "Center" },
        { label = "Bottom (Legs)", value = "Bottom"  },
    }

    local radioSetters = {}  -- { value → setActive function }

    for _, bone in ipairs(bones) do
        local row, btn, setActive = Components.radioRow(
            scroll, bone.label, CFG.TargetBone == bone.value)
        row.LayoutOrder = nextOrder()

        local boneValue = bone.value  -- capture for closure
        radioSetters[boneValue] = setActive

        btn.MouseButton1Click:Connect(function()
            CFG.TargetBone = boneValue
            -- Deactivate all, activate selected
            for v, setter in pairs(radioSetters) do
                setter(v == boneValue)
            end
        end)
    end
end

return AimbotPage