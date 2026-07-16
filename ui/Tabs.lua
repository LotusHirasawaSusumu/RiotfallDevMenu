--[[
    Tabs.lua
    Tab bar system.

    BUG FIX: Previous version used `btn.TabName = name` which tried
    to set a custom property on a Roblox Instance — not allowed.
    Fix: store tab metadata in a plain Lua table (tabRegistry)
    keyed by the TextButton instance itself, never on the Instance.
]]

local Theme         = require("ui/Theme")
local Components    = require("ui/Components")
local State         = require("core/State")

local Tabs          = {}

-- Internal registry: maps Instance → tab name string
-- This is the fix — Lua table, not Instance properties
local tabRegistry   = {}   -- { [TextButton] = "ESP" }
local tabPages      = {}   -- { ["ESP"] = Frame }
local tabButtons    = {}   -- ordered list of TextButtons

local tabBar        = nil  -- the tab bar Frame
local contentArea   = nil  -- the content area Frame

function Tabs.init(tabBarFrame, contentAreaFrame, tabNames)
    tabBar      = tabBarFrame
    contentArea = contentAreaFrame

    for i, name in ipairs(tabNames) do
        -- ── Create page frame ─────────────────
        local page = Components.frame(contentArea,
            UDim2.new(1, 0, 1, 0), nil, Theme.BG)
        page.Visible    = false
        page.Name       = "Page_" .. name

        local scroll    = Components.scrollFrame(page,
            UDim2.new(1, 0, 1, -4),
            UDim2.new(0, 0, 0, 4))
        Components.listLayout(scroll, nil, 4)
        Components.padding(scroll, 6, 6, 6, 6)

        tabPages[name]  = { page = page, scroll = scroll }

        -- ── Create tab button ─────────────────
        local isFirst   = (i == 1)
        local btn       = Instance.new("TextButton")
        btn.Size            = UDim2.new(0, 78, 1, 0)
        btn.BackgroundColor3= isFirst and Theme.Accent or Theme.Header
        btn.Text            = name
        btn.TextColor3      = isFirst and Theme.White or Theme.TextDim
        btn.TextSize        = Theme.SizeSmall
        btn.Font            = Theme.FontBold
        btn.BorderSizePixel = 0
        btn.LayoutOrder     = i
        btn.Parent          = tabBar
        Components.corner(btn)

        -- ✅ FIX: store name in Lua table, NOT as Instance property
        tabRegistry[btn] = name
        table.insert(tabButtons, btn)

        btn.MouseButton1Click:Connect(function()
            -- Read name from Lua registry — safe, no Instance property access
            Tabs.switch(tabRegistry[btn])
        end)
    end

    -- Show first tab by default
    if #tabNames > 0 then
        Tabs.switch(tabNames[1])
    end
end

function Tabs.switch(name)
    State.ActiveTab = name

    -- Show/hide pages
    for pageName, data in pairs(tabPages) do
        data.page.Visible = (pageName == name)
    end

    -- Update button appearance
    for _, btn in ipairs(tabButtons) do
        local isActive = (tabRegistry[btn] == name)
        btn.BackgroundColor3 = isActive and Theme.Accent or Theme.Header
        btn.TextColor3       = isActive and Theme.White  or Theme.TextDim
    end
end

-- Returns the scroll frame for a given tab name (used by page builders)
function Tabs.getScroll(name)
    local data = tabPages[name]
    return data and data.scroll or nil
end

return Tabs