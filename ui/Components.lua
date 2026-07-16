--[[
    Components.lua
    Reusable UI element factory functions.
    All functions return the created instance(s).
]]

local Theme     = require("ui/Theme")
local Services  = require("core/Services")

local Components = {}

-- ── Primitives ────────────────────────────────────────────────────

function Components.frame(parent, size, pos, color, transparency)
    local f = Instance.new("Frame")
    f.Size                      = size or UDim2.new(1, 0, 0, 32)
    f.Position                  = pos  or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3          = color or Theme.Panel
    f.BackgroundTransparency    = transparency or 0
    f.BorderSizePixel           = 0
    f.Parent                    = parent
    return f
end

function Components.corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius  = UDim.new(0, radius or Theme.CornerRadius)
    c.Parent        = parent
    return c
end

function Components.padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent        = parent
    return p
end

function Components.listLayout(parent, direction, padding, hAlign)
    local l = Instance.new("UIListLayout")
    l.FillDirection         = direction or Enum.FillDirection.Vertical
    l.HorizontalAlignment   = hAlign    or Enum.HorizontalAlignment.Left
    l.SortOrder             = Enum.SortOrder.LayoutOrder
    l.Padding               = UDim.new(0, padding or 4)
    l.Parent                = parent
    return l
end

function Components.label(parent, text, size, color, bold, textSize)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency    = 1
    l.Size                      = size or UDim2.new(1, 0, 0, 20)
    l.Text                      = text or ""
    l.TextColor3                = color or Theme.Text
    l.TextSize                  = textSize or Theme.SizeBody
    l.Font                      = bold and Theme.FontBold or Theme.FontBody
    l.TextXAlignment            = Enum.TextXAlignment.Left
    l.TextTruncate              = Enum.TextTruncate.AtEnd
    l.Parent                    = parent
    return l
end

function Components.button(parent, text, size, pos, color)
    local b = Instance.new("TextButton")
    b.Size              = size or UDim2.new(0, 80, 0, 28)
    b.Position          = pos  or UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3  = color or Theme.Accent
    b.Text              = text or "Button"
    b.TextColor3        = Theme.White
    b.TextSize          = Theme.SizeBody
    b.Font              = Theme.FontBold
    b.BorderSizePixel   = 0
    b.Parent            = parent
    Components.corner(b)
    return b
end

function Components.scrollFrame(parent, size, pos)
    local s = Instance.new("ScrollingFrame")
    s.Size                      = size or UDim2.new(1, 0, 1, 0)
    s.Position                  = pos  or UDim2.new(0, 0, 0, 0)
    s.BackgroundTransparency    = 1
    s.BorderSizePixel           = 0
    s.ScrollBarThickness        = 3
    s.ScrollBarImageColor3      = Theme.Accent
    s.CanvasSize                = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize       = Enum.AutomaticSize.Y
    s.Parent                    = parent
    return s
end

-- ── Compound components ───────────────────────────────────────────

--[[
    Toggle row.
    Returns: rowFrame, toggleButton, setState(bool) function

    Usage:
        local row, btn, setState = Components.toggle(
            parent, "Enable ESP", false,
            function(newState) ... end
        )
]]
function Components.toggle(parent, labelText, initState, onChange)
    local row = Components.frame(parent,
        UDim2.new(1, -12, 0, Theme.RowHeight), nil, Theme.Panel)
    Components.corner(row)
    Components.padding(row, 0, 0, Theme.Padding, Theme.Padding)

    Components.label(row, labelText,
        UDim2.new(1, -60, 1, 0), Theme.Text)

    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.new(0, 46, 0, 22)
    btn.Position        = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3= initState and Theme.OnColor or Theme.OffColor
    btn.Text            = initState and "ON" or "OFF"
    btn.TextColor3      = Theme.White
    btn.TextSize        = Theme.SizeSmall
    btn.Font            = Theme.FontBold
    btn.BorderSizePixel = 0
    btn.Parent          = row
    Components.corner(btn, Theme.ToggleCorner)

    local state = initState

    -- External state setter (used by other modules to sync UI)
    local function setState(newState)
        state               = newState
        btn.Text            = state and "ON" or "OFF"
        btn.BackgroundColor3= state and Theme.OnColor or Theme.OffColor
    end

    btn.MouseButton1Click:Connect(function()
        setState(not state)
        if onChange then onChange(state) end
    end)

    return row, btn, setState
end

--[[
    Slider row.
    Returns: containerFrame

    Usage:
        local slider = Components.slider(
            parent, "FOV Radius", 10, 500, 120, 5,
            function(value) ... end
        )
]]
function Components.slider(parent, labelText, minV, maxV, initV, step, onChange)
    local container = Components.frame(parent,
        UDim2.new(1, -12, 0, Theme.SliderHeight), nil, Theme.Panel)
    Components.corner(container)
    Components.padding(container, 6, 6, Theme.Padding, Theme.Padding)

    -- Top row: label + value display
    local topRow = Components.frame(container,
        UDim2.new(1, 0, 0, 18), nil, Theme.Transparent, 1)

    Components.label(topRow, labelText,
        UDim2.new(0.7, 0, 1, 0), Theme.Text)

    local valLabel = Components.label(topRow, tostring(initV),
        UDim2.new(0.3, 0, 1, 0), Theme.Accent, true)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Position       = UDim2.new(0.7, 0, 0, 0)

    -- Track
    local track = Components.frame(container,
        UDim2.new(1, 0, 0, 6),
        UDim2.new(0, 0, 0, 26),
        Theme.SliderBar)
    Components.corner(track, 3)

    local pct  = (initV - minV) / (maxV - minV)
    local fill = Components.frame(track,
        UDim2.new(pct, 0, 1, 0), nil, Theme.SliderFill)
    Components.corner(fill, 3)

    local knob = Components.frame(track,
        UDim2.new(0, 12, 0, 12),
        UDim2.new(pct, -6, 0.5, -6),
        Theme.White)
    Components.corner(knob, 6)

    -- Drag logic
    local dragging = false
    local UIS      = Services.UserInputService

    local function setValue(relX)
        relX        = math.clamp(relX, 0, 1)
        local raw   = minV + (maxV - minV) * relX
        if step and step > 0 then
            raw = math.round(raw / step) * step
        end
        raw             = math.clamp(raw, minV, maxV)
        fill.Size       = UDim2.new(relX, 0, 1, 0)
        knob.Position   = UDim2.new(relX, -6, 0.5, -6)
        valLabel.Text   = tostring(math.floor(raw * 100 + 0.5) / 100)
        if onChange then onChange(raw) end
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relX = (inp.Position.X - track.AbsolutePosition.X)
                / track.AbsoluteSize.X
            setValue(relX)
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = (inp.Position.X - track.AbsolutePosition.X)
                / track.AbsoluteSize.X
            setValue(relX)
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return container
end

--[[
    Section separator header.
    Returns: frame
]]
function Components.sectionHeader(parent, text)
    local wrapper = Components.frame(parent,
        UDim2.new(1, -12, 0, Theme.HeaderHeight),
        nil, Theme.Transparent, 1)

    -- Full-width separator line
    Components.frame(wrapper,
        UDim2.new(1, 0, 0, 1),
        UDim2.new(0, 0, 0.5, 0),
        Theme.Separator)

    -- Label background cutout
    local textWidth = #text * 7 + 16
    local bg = Components.frame(wrapper,
        UDim2.new(0, textWidth, 0, 18),
        UDim2.new(0, 8, 0, 1),
        Theme.BG)

    local lbl = Components.label(bg,
        "  " .. text .. "  ",
        UDim2.new(1, 0, 1, 0),
        Theme.Accent, true, Theme.SizeSmall)

    return wrapper
end

--[[
    Radio button row (for mutually exclusive choices like bone selection).
    Returns: rowFrame, selectButton, isSelected() function
]]
function Components.radioRow(parent, labelText, isActive)
    local row = Components.frame(parent,
        UDim2.new(1, -12, 0, 30), nil, Theme.Panel)
    Components.corner(row)
    Components.padding(row, 0, 0, Theme.Padding, Theme.Padding)

    Components.label(row, labelText,
        UDim2.new(1, -54, 1, 0), Theme.Text)

    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.new(0, 40, 0, 20)
    btn.Position        = UDim2.new(1, -44, 0.5, -10)
    btn.BackgroundColor3= isActive and Theme.Accent or Theme.Header
    btn.Text            = isActive and "●" or "○"
    btn.TextColor3      = Theme.White
    btn.TextSize        = 14
    btn.Font            = Theme.FontBold
    btn.BorderSizePixel = 0
    btn.Parent          = row
    Components.corner(btn)

    local function setActive(active)
        btn.BackgroundColor3 = active and Theme.Accent or Theme.Header
        btn.Text             = active and "●" or "○"
    end

    return row, btn, setActive
end

return Components