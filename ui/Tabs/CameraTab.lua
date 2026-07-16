-- ui/Tabs/CameraTab.lua
return function(Services, Config, _State, Library, Tabs, CamSys)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local L = Tabs.Camera:AddLeftGroupbox("Field of View")
    local R = Tabs.Camera:AddRightGroupbox("Camera Info")

    L:AddToggle("CamFOVEnabled", {
        Text    = "Custom FOV",
        Default = false,
        Tooltip = "Override game default FOV (70°)",
    })

    L:AddSlider("CamFOVValue", {
        Text     = "FOV Value",
        Default  = Config.Camera.DefaultFOV,
        Min      = Config.Camera.MinFOV,
        Max      = Config.Camera.MaxFOV,
        Rounding = 0,
        Suffix   = "°",
    })

    R:AddLabel("CamFOVLbl", { Text = "FOV: 70°",     DoesWrap = false })
    R:AddLabel("CamPosLbl", { Text = "Position: ...", DoesWrap = false })

    Toggles.CamFOVEnabled:OnChanged(function()
        CamSys.setEnabled(Toggles.CamFOVEnabled.Value)
    end)

    Options.CamFOVValue:OnChanged(function()
        CamSys.setFOV(Options.CamFOVValue.Value)
    end)
end