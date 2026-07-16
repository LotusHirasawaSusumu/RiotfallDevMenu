--[[
    Window.lua
    Builds the main window frame, title bar, status bar.
    Handles drag, minimize, close.
]]

local Config        = require("core/Config")
local Theme         = require("ui/Theme")
local Components    = require("ui/Components")
local State         = require("core/State")
local Services      = require("core/Services")

local Window        = {}
local UIS           = Services.UserInputService

-- Public references (set after build)
Window.Main         = nil
Window.TitleBar     = nil
Window.TabBarFrame  = nil
Window.ContentArea  = nil
Window.StatusLabel  = nil
Window.Shadow       = nil

function Window.build(screenGui)
    local W = Config.MENU_W
    local H = Config.MENU_H

    -- Shadow
    local shadow = Components.frame(screenGui,
        UDim2.new(0, W + 20, 0, H + 20),
        UDim2.new(0, Config.MENU_START_X - 10, 0, Config.MENU_START_Y - 10),
        Color3.fromRGB(0, 0, 0), 0.5)
    shadow.ZIndex = 0
    Components.corner(shadow, 10)
    Window.Shadow = shadow

    -- Main frame
    local main = Components.frame(screenGui,
        UDim2.new(0, W, 0, H),
        UDim2.new(0, Config.MENU_START_X, 0, Config.MENU_START_Y),
        Theme.BG)
    main.ZIndex = 1
    Components.corner(main, 8)
    Window.Main = main

    -- ── Title bar ────────────────────────
    local titleBar = Components.frame(main,
        UDim2.new(1, 0, 0, Theme.TitleBarHeight), nil, Theme.Header)
    Components.corner(titleBar, 8)
    -- Cover bottom-left/right inner corners
    Components.frame(main,
        UDim2.new(1, 0, 0, 8),
        UDim2.new(0, 0, 0, 30),
        Theme.Header)
    Window.TitleBar = titleBar

    -- Accent left bar
    local accentBar = Components.frame(titleBar,
        UDim2.new(0, 4, 1, 0), nil, Theme.Accent)
    Components.corner(accentBar, 2)

    -- Title text
    local titleLbl = Components.label(titleBar,
        "  " .. Config.MENU_TITLE .. "  v" .. Config.VERSION,
        UDim2.new(1, -80, 0, 22),
        Theme.White, true, Theme.SizeTitle)
    titleLbl.Position = UDim2.new(0, 8, 0, 2)

    local subLbl = Components.label(titleBar,
        "  github.com/your-repo",
        UDim2.new(1, -80, 0, 14),
        Theme.TextDim, false, Theme.SizeTiny)
    subLbl.Position = UDim2.new(0, 8, 0, 22)

    -- Minimize button
    local minBtn = Components.button(titleBar, "─",
        UDim2.new(0, 28, 0, 28),
        UDim2.new(1, -68, 0, 5),
        Theme.Header)
    minBtn.TextColor3 = Theme.TextDim

    -- Close button
    local closeBtn = Components.button(titleBar, "✕",
        UDim2.new(0, 28, 0, 28),
        UDim2.new(1, -36, 0, 5),
        Theme.AccentDim)

    -- ── Tab bar ──────────────────────────
    local tabBar = Components.frame(main,
        UDim2.new(1, 0, 0, Theme.TabHeight),
        UDim2.new(0, 0, 0, Theme.TitleBarHeight),
        Theme.Panel)
    Components.listLayout(tabBar,
        Enum.FillDirection.Horizontal, 2,
        Enum.HorizontalAlignment.Left)
    Components.padding(tabBar, 4, 4, 6, 6)
    Window.TabBarFrame = tabBar

    -- ── Content area ─────────────────────
    local contentY  = Theme.TitleBarHeight + Theme.TabHeight
    local contentH  = H - contentY - Theme.StatusBarHeight
    local content   = Components.frame(main,
        UDim2.new(1, 0, 0, contentH),
        UDim2.new(0, 0, 0, contentY),
        Theme.BG)
    Window.ContentArea = content

    -- ── Status bar ───────────────────────
    local statusBar = Components.frame(main,
        UDim2.new(1, 0, 0, Theme.StatusBarHeight),
        UDim2.new(0, 0, 1, -Theme.StatusBarHeight),
        Theme.Header)

    local statusLbl = Components.label(statusBar,
        " ● Initializing...",
        UDim2.new(1, 0, 1, 0),
        Theme.TextDim, false, Theme.SizeSmall)
    Window.StatusLabel = statusLbl

    -- ── Drag logic ───────────────────────
    do
        local dragging, dragStart, startPos = false, nil, nil

        titleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging    = true
                dragStart   = inp.Position
                startPos    = main.Position
            end
        end)

        UIS.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local d = inp.Position - dragStart
                main.Position   = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
                shadow.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X - 10,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y - 10)
            end
        end)

        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- ── Minimize ─────────────────────────
    minBtn.MouseButton1Click:Connect(function()
        State.Minimized = not State.Minimized
        content.Visible     = not State.Minimized
        statusBar.Visible   = not State.Minimized
        tabBar.Visible      = not State.Minimized
        main.Size   = State.Minimized
            and UDim2.new(0, W, 0, Theme.TitleBarHeight + 8)
            or  UDim2.new(0, W, 0, H)
        shadow.Size = State.Minimized
            and UDim2.new(0, W + 20, 0, Theme.TitleBarHeight + 28)
            or  UDim2.new(0, W + 20, 0, H + 20)
        minBtn.Text = State.Minimized and "□" or "─"
    end)

    -- ── Close ────────────────────────────
    closeBtn.MouseButton1Click:Connect(function()
        Window.close(screenGui)
    end)

    return Window
end

function Window.close(screenGui)
    -- Handled by main.lua shutdown routine
    screenGui:SetAttribute("_RequestClose", true)
end

return Window