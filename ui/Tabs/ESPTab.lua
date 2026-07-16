-- ui/Tabs/ESPTab.lua
return function(Services, Config, _State, Library, Tabs, ESP)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local LeftBox  = Tabs.ESP:AddLeftGroupbox("Chams ESP")
    local RightBox = Tabs.ESP:AddRightGroupbox("Name Tag")
    local ColorBox = Tabs.ESP:AddRightGroupbox("Colors")

    -- Left: core toggles
    LeftBox:AddToggle("ESPEnabled", {
        Text    = "Enable ESP",
        Default = false,
        Risky   = true,
        Tooltip = "Chams via CharacterMeshes (bypasses game monitoring)",
    })

    LeftBox:AddToggle("ESPEnemiesOnly", {
        Text    = "Enemies Only",
        Default = true,
    })

    LeftBox:AddDivider()

    LeftBox:AddSlider("ESPFillTransp", {
        Text     = "Fill Transparency",
        Default  = 40,
        Min      = 0, Max = 100, Rounding = 0, Suffix = "%",
    })

    LeftBox:AddSlider("ESPOutlineTransp", {
        Text     = "Outline Transparency",
        Default  = 10,
        Min      = 0, Max = 100, Rounding = 0, Suffix = "%",
    })

    -- Right: name tag settings (CS2-style)
    RightBox:AddToggle("ESPShowName", {
        Text    = "Show Name Tag",
        Default = false,
        Tooltip = "CS2-style tag: name, distance, weapon, HP bar",
    })

    RightBox:AddToggle("ESPShowDistance", {
        Text    = "Show Distance",
        Default = true,
    })

    RightBox:AddToggle("ESPShowWeapon", {
        Text    = "Show Weapon",
        Default = true,
    })

    RightBox:AddToggle("ESPShowHealthBar", {
        Text    = "Show Health Bar",
        Default = true,
    })

    RightBox:AddDivider()

    RightBox:AddSlider("ESPMaxDistance", {
        Text     = "Max Tag Distance",
        Default  = Config.ESP.MaxNameDistance,
        Min      = 20, Max = 500, Rounding = 0, Suffix = "m",
        Tooltip  = "Hide name tag beyond this many meters",
    })

    -- Colors
    ColorBox:AddLabel("Enemy Color")
        :AddColorPicker("ESPEnemyColor", {
            Default = Config.ESP.EnemyFillColor,
            Title   = "Enemy Color",
        })

    ColorBox:AddLabel("Ally Color")
        :AddColorPicker("ESPAllyColor", {
            Default = Config.ESP.AllyFillColor,
            Title   = "Ally Color",
        })

    -- Wire
    Toggles.ESPEnabled:OnChanged(function()
        ESP.setEnabled(Toggles.ESPEnabled.Value)
    end)

    Toggles.ESPEnemiesOnly:OnChanged(function()
        ESP.setEnemiesOnly(Toggles.ESPEnemiesOnly.Value)
    end)

    Toggles.ESPShowName:OnChanged(function()
        ESP.setShowName(Toggles.ESPShowName.Value)
    end)

    Toggles.ESPShowDistance:OnChanged(function()
        ESP.setShowDistance(Toggles.ESPShowDistance.Value)
        if Toggles.ESPEnabled.Value then ESP.refreshAll() end
    end)

    Toggles.ESPShowWeapon:OnChanged(function()
        ESP.setShowWeapon(Toggles.ESPShowWeapon.Value)
        if Toggles.ESPEnabled.Value then ESP.refreshAll() end
    end)

    Toggles.ESPShowHealthBar:OnChanged(function()
        ESP.setShowHealthBar(Toggles.ESPShowHealthBar.Value)
        if Toggles.ESPEnabled.Value then ESP.refreshAll() end
    end)

    Options.ESPMaxDistance:OnChanged(function()
        ESP.setMaxDistance(Options.ESPMaxDistance.Value)
    end)

    Options.ESPFillTransp:OnChanged(function()
        ESP.setFillTransparency(Options.ESPFillTransp.Value / 100)
    end)

    Options.ESPOutlineTransp:OnChanged(function()
        ESP.setOutlineTransparency(Options.ESPOutlineTransp.Value / 100)
    end)

    Options.ESPEnemyColor:OnChanged(function()
        Config.ESP.EnemyFillColor    = Options.ESPEnemyColor.Value
        Config.ESP.EnemyOutlineColor = Options.ESPEnemyColor.Value
        if Toggles.ESPEnabled.Value then ESP.refreshAll() end
    end)

    Options.ESPAllyColor:OnChanged(function()
        Config.ESP.AllyFillColor    = Options.ESPAllyColor.Value
        Config.ESP.AllyOutlineColor = Options.ESPAllyColor.Value
        if Toggles.ESPEnabled.Value then ESP.refreshAll() end
    end)
end