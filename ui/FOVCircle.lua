-- ui/FOVCircle.lua
--[[
    FOV Circle v2.3
    Fix: Frame + UICorner(0.5) + UIStroke is the correct thin-ring method.
    Previous bug: the circle SIZE was set to the raw FOV value passed in,
    but the FOV value is a RADIUS in pixels — so diameter = FOV * 2.
    The update() function now correctly sets Size to diameter x diameter.
]]

return function(Services, Config, _State)
    local LP = Services.LP

    local gui = Instance.new("ScreenGui")
    gui.Name             = "RF_FOVCircle"
    gui.ResetOnSpawn     = false
    gui.DisplayOrder     = 997
    gui.IgnoreGuiInset   = true
    gui.Parent           = LP.PlayerGui

    -- Hollow circle via Frame + UICorner(50%) + UIStroke
    local ring = Instance.new("Frame")
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel        = 0
    ring.AnchorPoint            = Vector2.new(0.5, 0.5)
    ring.Visible                = false
    ring.Parent                 = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)   -- 50% = perfect circle
    corner.Parent       = ring

    -- UIStroke renders ON the frame border
    -- Thickness=1 = single pixel, crisp, no blur
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

        local cam    = Services.Camera
        local center = cam.ViewportSize / 2
        -- fovRadius is the RADIUS in pixels
        -- Frame size must be DIAMETER x DIAMETER for UICorner(50%) to make a circle
        local diameter = fovRadius * 2

        ring.Visible  = true
        ring.Size     = UDim2.fromOffset(diameter, diameter)
        ring.Position = UDim2.fromOffset(center.X, center.Y)
        stroke.Color  = color
    end

    function M.setEnabled(v)
        enabled = v
        if not v then ring.Visible = false end
    end

    function M.setColor(c)
        color        = c
        stroke.Color = c
    end

    function M.destroy()
        gui:Destroy()
    end

    return M
end