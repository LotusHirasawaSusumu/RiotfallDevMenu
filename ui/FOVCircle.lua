-- ui/FOVCircle.lua
return function(Services, Config, _State)
    local LP = Services.LP

    local gui = Instance.new("ScreenGui")
    gui.Name           = "RF_FOVCircle"
    gui.ResetOnSpawn   = false
    gui.DisplayOrder   = 997
    gui.IgnoreGuiInset = true
    gui.Parent         = LP.PlayerGui

    local ring = Instance.new("Frame")
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel        = 0
    ring.AnchorPoint            = Vector2.new(0.5, 0.5)
    ring.Visible                = false
    ring.Parent                 = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent       = ring

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode    = Enum.LineJoinMode.Round
    stroke.Thickness       = 1
    stroke.Transparency    = Config.FOVCircle.Transparency
    stroke.Color           = Config.FOVCircle.Color
    stroke.Parent          = ring

    local enabled = false
    local color   = Config.FOVCircle.Color

    local M = {}

    function M.update(fovRadius)
        if not enabled then
            ring.Visible = false
            return
        end
        local center   = Services.Camera.ViewportSize / 2
        local diameter = fovRadius * 2    -- fovRadius is px radius; size = diameter
        ring.Visible  = true
        ring.Size     = UDim2.fromOffset(diameter, diameter)
        ring.Position = UDim2.fromOffset(center.X, center.Y)
        stroke.Color  = color
    end

    function M.setEnabled(v)
        enabled = v
        if not v then ring.Visible = false end
    end

    function M.setColor(c) color = c; stroke.Color = c end
    function M.destroy()   gui:Destroy() end

    return M
end