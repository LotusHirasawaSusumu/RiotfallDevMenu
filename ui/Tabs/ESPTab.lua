-- ui/Tabs/ESPTab.lua
return function(Services, Config, _State, Library, Tabs, ESP)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local LeftBox  = Tabs.ESP:AddLeftGroupbox("Chams ESP")
    local TagBox   = Tabs.ESP:AddRightGroupbox("Name Tag")
    local ColorBox = Tabs.ESP:AddRightGroupbox("Colors")

    LeftBox:AddToggle("ESPEnabled", {
        Text    = "Enable ESP",
        Default = false,
        Risky   = true,
        Tooltip = "Chams via CharacterMeshes. Auto-scans every 3s.",
    })

    LeftBox:AddToggle("ESPEnemiesOnly", {
        Text    = "Enemies Only",
        Default = true,
    })

    LeftBox:AddDivider()

    LeftBox:AddSlider("ESPFillTransp", {
        Text     = "Fill Transparency",
        Default  = 40,
        Min      = 0,
        Max      = 100,
        Rounding = 0,
        Suffix   = "%",
    })

    LeftBox:AddSlider("ESPOutlineTransp", {
        Text     = "Outline Transparency",
        Default  = 10,
        Min      = 0,
        Max      = 100,
        Rounding = 0,
        Suffix   = "%",
    })

    -- Name tag
    TagBox:AddToggle("ESPShowName", {
        Text    = "Show Name Tag",
        Default = false,
        Tooltip = "Name, distance, weapon above head",
    })

    TagBox:AddToggle("ESPShowDistance", {
        Text    = "Show Distance",
        Default = true,
    })

    TagBox:AddToggle("ESPShowWeapon", {
        Text    = "Show Weapon",
        Default = true,
    })

    TagBox:AddDivider()

    TagBox:AddSlider("ESPMaxDistance", {
        Text     = "Max Tag Distance",
        Default  = 2000,
        Min      = 50,
        Max      = 5000,
        Rounding = 0,
        Suffix   = "m",
        Tooltip  = "Hide name tag beyond this distance",
    })

    -- Colors
    ColorBox:AddLabel("Enemy Fill Color")
        :AddColorPicker("ESPEnemyFillColor", {
            Default = Config.ESP.EnemyFillColor,
            Title   = "Enemy Fill Color",
        })

    ColorBox:AddLabel("Ally Fill Color")
        :AddColorPicker("ESPAllyFillColor", {
            Default = Config.ESP.AllyFillColor,
            Title   = "Ally Fill Color",
        })

    ColorBox:AddDivider()

    ColorBox:AddLabel("Enemy Name Color")
        :AddColorPicker("ESPEnemyNameColor", {
            Default = Config.ESP.EnemyNameColor,
            Title   = "Enemy Name Color",
        })

    ColorBox:AddLabel("Ally Name Color")
        :AddColorPicker("ESPAllyNameColor", {
            Default = Config.ESP.AllyNameColor,
            Title   = "Ally Name Color",
        })

    -- Wire — all OnChanged after all elements created
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

    Options.ESPMaxDistance:OnChanged(function()
        ESP.setMaxDistance(Options.ESPMaxDistance.Value)
    end)

    Options.ESPFillTransp:OnChanged(function()
        ESP.setFillTransparency(Options.ESPFillTransp.Value / 100)
    end)

    Options.ESPOutlineTransp:OnChanged(function()
        ESP.setOutlineTransparency(Options.ESPOutlineTransp.Value / 100)
    end)

    Options.ESPEnemyFillColor:OnChanged(function()
        Config.ESP.EnemyFillColor    = Options.ESPEnemyFillColor.Value
        Config.ESP.EnemyOutlineColor = Options.ESPEnemyFillColor.Value
        if Toggles.ESPEnabled.Value then ESP.refreshAll() end
    end)

    Options.ESPAllyFillColor:OnChanged(function()
        Config.ESP.AllyFillColor    = Options.ESPAllyFillColor.Value
        Config.ESP.AllyOutlineColor = Options.ESPAllyFillColor.Value
        if Toggles.ESPEnabled.Value then ESP.refreshAll() end
    end)

    Options.ESPEnemyNameColor:OnChanged(function()
        ESP.setEnemyNameColor(Options.ESPEnemyNameColor.Value)
    end)

    Options.ESPAllyNameColor:OnChanged(function()
        ESP.setAllyNameColor(Options.ESPAllyNameColor.Value)
    end)
end