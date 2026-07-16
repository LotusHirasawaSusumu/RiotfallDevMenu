return function(Services, Config, _State, Library, Tabs, CamSys)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local LeftBox  = Tabs.Camera:AddLeftGroupbox("Field of View")
    local RightBox = Tabs.Camera:AddRightGroupbox("Camera Info")

    LeftBox:AddToggle("CamFOVEnabled", {
        Text    = "Custom FOV",
        Default = false,
        Tooltip = "Override game default FOV (70)",
    })

    LeftBox:AddSlider("CamFOVValue", {
        Text     = "FOV Value",
        Default  = Config.Camera.DefaultFOV,
        Min      = Config.Camera.MinFOV,
        Max      = Config.Camera.MaxFOV,
        Rounding = 0,
        Suffix   = "°",
    })

    RightBox:AddLabel("CamFOVLbl", { Text = "FOV: 70°",     DoesWrap = false })
    RightBox:AddLabel("CamPosLbl", { Text = "Position: ...", DoesWrap = false })

    Toggles.CamFOVEnabled:OnChanged(function()
        CamSys.setEnabled(Toggles.CamFOVEnabled.Value)
    end)

    Options.CamFOVValue:OnChanged(function()
        CamSys.setFOV(Options.CamFOVValue.Value)
    end)
end