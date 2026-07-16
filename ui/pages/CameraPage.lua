--[[
    CameraPage.lua
    Builds the Camera tab content.
]]

local Components    = require("ui/Components")
local Config        = require("core/Config")
local CameraSystem  = require("systems/Camera")
local Theme         = require("ui/Theme")

local CameraPage    = {}

-- Public label references so RenderLoop can update them
CameraPage.fovLabel = nil
CameraPage.posLabel = nil

function CameraPage.build(scroll)
    local CFG = Config.Camera
    local lo  = 0
    local function nextOrder() lo = lo + 1 return lo end

    -- Section: FOV
    local sec1 = Components.sectionHeader(scroll, "FIELD OF VIEW")
    sec1.LayoutOrder = nextOrder()

    local fovToggleRow = Components.toggle(scroll,
        "Custom FOV", CFG.FOVEnabled,
        function(state)
            if state then
                CameraSystem.enable(CFG.FOVValue)
            else
                CameraSystem.disable()
            end
        end)
    fovToggleRow.LayoutOrder = nextOrder()

    local fovValSlider = Components.slider(scroll,
        "FOV Value", 40, 120, CFG.FOVValue, 1,
        function(v)
            CFG.FOVValue = v
            if CFG.FOVEnabled then CameraSystem.enable(v) end
        end)
    fovValSlider.LayoutOrder = nextOrder()

    -- Section: Info
    local sec2 = Components.sectionHeader(scroll, "CAMERA INFO")
    sec2.LayoutOrder = nextOrder()

    local infoFrame = Components.frame(scroll,
        UDim2.new(1, -12, 0, 72), nil, Theme.Panel)
    infoFrame.LayoutOrder = nextOrder()
    Components.corner(infoFrame)
    Components.padding(infoFrame, 6, 6, 10, 10)
    Components.listLayout(infoFrame, nil, 2)

    Components.label(infoFrame,
        "Type: Scriptable",
        UDim2.new(1, 0, 0, 14), Theme.TextDim, false, Theme.SizeSmall)

    CameraPage.fovLabel = Components.label(infoFrame,
        "FOV: 70",
        UDim2.new(1, 0, 0, 14), Theme.TextDim, false, Theme.SizeSmall)

    Components.label(infoFrame,
        "Subject: Humanoid",
        UDim2.new(1, 0, 0, 14), Theme.TextDim, false, Theme.SizeSmall)

    CameraPage.posLabel = Components.label(infoFrame,
        "Pos: ...",
        UDim2.new(1, 0, 0, 14), Theme.TextDim, false, Theme.SizeSmall)
end

return CameraPage