--[[
    FOV Circle
    Fixed: previous version used ImageLabel with a blurry PNG.
    New approach: a thin Frame ring using UICorner (makes it a circle)
    with a UIStroke for a crisp 1px outline — no texture, no blur.

    Method:
        Outer Frame (circle shape via UICorner radius=50%)
            → BackgroundTransparency = 1  (hollow)
            → UIStroke thickness = 1px    (crisp single-pixel ring)
        This gives a perfectly thin, sharp circle at any radius.
]]

return function(Services, Config, _State)
    local LP = Services.LP

    local fovGui = Instance.new("ScreenGui")
    fovGui.Name             = "RiotfallFOVCircle"
    fovGui.ResetOnSpawn     = false
    fovGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    fovGui.DisplayOrder     = 997
    fovGui.IgnoreGuiInset   = true
    fovGui.Parent           = LP.PlayerGui

    -- Hollow circle frame
    local ring = Instance.new("Frame")
    ring.Name                   = "FOVRing"
    ring.BackgroundTransparency = 1      -- hollow interior
    ring.BorderSizePixel        = 0
    ring.AnchorPoint            = Vector2.new(0.5, 0.5)
    ring.Visible                = false
    ring.Parent                 = fovGui

    -- Make it a circle
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent       = ring

    -- Thin crisp stroke — THIS replaces the blurry PNG approach
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode    = Enum.LineJoinMode.Round
    stroke.Thickness       = 1          -- 1px = thinnest possible, sharp
    stroke.Transparency    = Config.FOVCircle.Transparency
    stroke.Color           = Config.FOVCircle.Color
    stroke.Parent          = ring

    local FOVCircleSettings = {
        Enabled = false,
        Color   = Config.FOVCircle.Color,
    }

    local FOVCircle = {}

    function FOVCircle.update(fovRadius)
        if not FOVCircleSettings.Enabled then
            ring.Visible = false
            return
        end

        local r      = fovRadius or 120
        local center = Services.Camera.ViewportSize / 2
        local diam   = r * 2

        ring.Visible  = true
        ring.Position = UDim2.fromOffset(center.X, center.Y)
        ring.Size     = UDim2.fromOffset(diam, diam)
        stroke.Color  = FOVCircleSettings.Color
    end

    function FOVCircle.setEnabled(v)
        FOVCircleSettings.Enabled = v
        if not v then ring.Visible = false end
    end

    function FOVCircle.setColor(c)
        FOVCircleSettings.Color = c
        stroke.Color = c
    end

    function FOVCircle.destroy()
        fovGui:Destroy()
    end

    return FOVCircle
end