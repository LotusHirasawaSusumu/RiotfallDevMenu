return function(Services, Config, _State, Library, Tabs, Window,
                ThemeManager, SaveManager)
    local Options = Library.Options

    local MenuBox = Tabs.Settings:AddLeftGroupbox("Menu")

    MenuBox:AddToggle("KeybindMenuOpen", {
        Text     = "Show Keybind Menu",
        Default  = Library.KeybindFrame.Visible,
        Callback = function(v) Library.KeybindFrame.Visible = v end,
    })

    MenuBox:AddToggle("ShowCustomCursor", {
        Text     = "Custom Cursor",
        Default  = Library.ShowCustomCursor,
        Callback = function(v) Library.ShowCustomCursor = v end,
    })

    MenuBox:AddDropdown("NotificationSide", {
        Values   = { "Left", "Right" },
        Default  = "Right",
        Text     = "Notification Side",
        Callback = function(v) Library:SetNotifySide(v) end,
    })

    MenuBox:AddSlider("UICornerSlider", {
        Text     = "Corner Radius",
        Default  = Library.CornerRadius or 6,
        Min      = 0,
        Max      = 20,
        Rounding = 0,
        Callback = function(v) Window:SetCornerRadius(v) end,
    })

    MenuBox:AddDivider()

    MenuBox:AddLabel("Menu Keybind")
        :AddKeyPicker("MenuKeybind", {
            Default = "RightShift",
            NoUI    = true,
            Text    = "Menu keybind",
        })

    MenuBox:AddDivider()

    MenuBox:AddButton({
        Text = "Unload",
        Func = function() Library:Unload() end,
    })

    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("RiotfallDevMenu")
    SaveManager:SetFolder("RiotfallDevMenu/riotfall")
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)
    SaveManager:LoadAutoloadConfig()
end