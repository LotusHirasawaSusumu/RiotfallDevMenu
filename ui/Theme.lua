--[[
    Theme.lua
    All colors, sizes, and font settings for the UI.
    Change the palette here to retheme the entire menu.
]]

local Theme = {

    -- ── Color palette ────────────────────
    BG          = Color3.fromRGB(12,  12,  18),
    Panel       = Color3.fromRGB(20,  20,  30),
    Header      = Color3.fromRGB(30,  30,  48),
    Accent      = Color3.fromRGB(255, 60,  60),
    AccentDim   = Color3.fromRGB(180, 30,  30),
    OnColor     = Color3.fromRGB(60,  200, 100),
    OffColor    = Color3.fromRGB(200, 60,  60),
    Text        = Color3.fromRGB(230, 230, 230),
    TextDim     = Color3.fromRGB(140, 140, 160),
    Separator   = Color3.fromRGB(40,  40,  60),
    SliderBar   = Color3.fromRGB(50,  50,  70),
    SliderFill  = Color3.fromRGB(255, 60,  60),
    White       = Color3.fromRGB(255, 255, 255),
    Transparent = Color3.fromRGB(0,   0,   0),

    -- ── Typography ───────────────────────
    FontBody    = Enum.Font.Gotham,
    FontBold    = Enum.Font.GothamBold,
    SizeBody    = 13,
    SizeSmall   = 11,
    SizeTitle   = 14,
    SizeTiny    = 10,

    -- ── Layout ───────────────────────────
    CornerRadius    = 6,
    ToggleCorner    = 11,
    Padding         = 8,
    RowHeight       = 32,
    SliderHeight    = 48,
    HeaderHeight    = 20,
    TabHeight       = 34,
    TitleBarHeight  = 38,
    StatusBarHeight = 22,
}

return Theme