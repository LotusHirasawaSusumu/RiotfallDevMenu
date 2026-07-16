return function(Services, Config, _State, Library, Tabs, ESP)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local LeftBox  = Tabs.ESP:AddLeftGroupbox("Chams ESP")
    local ColorBox = Tabs.ESP:AddRightGroupbox("Colors")

    -- Controls
    LeftBox:AddToggle("ESPEnabled", {
        Text    = "Enable Chams ESP",
        Default = false,
        Tooltip = "Highlights via CharacterMeshes (bypasses game monitoring)",
        Risky   = true,
    })

    LeftBox:AddToggle("ESPEnemiesOnly", {
        Text    = "Enemies Only",
        Default = true,
        Tooltip = "Only highlight the enemy team",
    })

    LeftBox:AddToggle("ESPShowName", {
        Text    = "Show Names",
        Default = false,
        Tooltip = "Renders player name above each character",
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