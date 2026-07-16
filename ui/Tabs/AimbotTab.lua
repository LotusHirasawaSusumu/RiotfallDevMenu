-- ui/Tabs/AimbotTab.lua
return function(Services, Config, _State, Library, Tabs, Aimbot, FOVCircle)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local LeftBox  = Tabs.Aimbot:AddLeftGroupbox("Aimbot")
    local RightBox = Tabs.Aimbot:AddRightGroupbox("Target Bone")

    LeftBox:AddToggle("AimbotEnabled", {
        Text    = "Enable Aimbot",
        Default = false,
        Risky   = true,
        Tooltip = "Hold RMB to aim at nearest target",
    })

    LeftBox:AddToggle("AimbotEnemyOnly", {
        Text    = "Enemies Only",
        Default = true,
    })

    LeftBox:AddToggle("AimbotVisCheck", {
        Text    = "Visibility Check",
        Default = true,
        Tooltip = "Skip targets behind walls",
    })

    LeftBox:AddDivider()

    LeftBox:AddSlider("AimbotFOV", {
        Text     = "FOV Radius",
        Default  = Config.Aimbot.FOVRadius,
        Min      = 10, Max = 500, Rounding = 0, Suffix = "px",
        Tooltip  = "Pixel radius — circle diameter = this value × 2",
    })

    LeftBox:AddSlider("AimbotSmoothing", {
        Text     = "Smoothing",
        Default  = 15,
        Min      = 0, Max = 99, Rounding = 0, Suffix = "%",
        Tooltip  = "0% = instant | 99% = very slow",
    })

    LeftBox:AddDivider()

    LeftBox:AddToggle("FOVCircleVisible", {
        Text    = "Show FOV Circle",
        Default = false,
        Tooltip = "Thin 1px ring at aimbot FOV radius",
    })

    LeftBox:AddLabel("FOV Circle Color")
        :AddColorPicker("FOVCircleColor", {
            Default = Config.FOVCircle.Color,
            Title   = "FOV Circle Color",
        })

    -- Bone selector
    RightBox:AddDropdown("AimbotBone", {
        Values  = { "Head", "Chest", "Pelvis", "Legs" },
        Default = 1,
        Text    = "Target Bone",
        Tooltip = "Uses animated CharacterCollisions bones with static fallback",
    })

    RightBox:AddDivider()
    RightBox:AddLabel("Head   → Neck bone (animated)", true)
    RightBox:AddLabel("Chest  → MidUpperSpine (animated)", true)
    RightBox:AddLabel("Pelvis → LowerSpine (animated)", true)
    RightBox:AddLabel("Legs   → UpperLeg.L/R (animated)", true)
    RightBox:AddDivider()
    RightBox:AddLabel("Velocity prediction enabled.", true)
    RightBox:AddLabel("Fallback to static parts if", true)
    RightBox:AddLabel("collision model unavailable.", true)

    -- Wire
    Toggles.AimbotEnabled:OnChanged(function()
        Aimbot.setEnabled(Toggles.AimbotEnabled.Value)
    end)

    Toggles.AimbotEnemyOnly:OnChanged(function()
        Aimbot.setEnemyOnly(Toggles.AimbotEnemyOnly.Value)
    end)

    Toggles.AimbotVisCheck:OnChanged(function()
        Aimbot.setVisCheck(Toggles.AimbotVisCheck.Value)
    end)

    Options.AimbotFOV:OnChanged(function()
        Aimbot.setFOV(Options.AimbotFOV.Value)
    end)

    Options.AimbotSmoothing:OnChanged(function()
        Aimbot.setSmoothing(Options.AimbotSmoothing.Value / 100)
    end)

    Options.AimbotBone:OnChanged(function()
        Aimbot.setBone(Options.AimbotBone.Value)
    end)

    Toggles.FOVCircleVisible:OnChanged(function()
        FOVCircle.setEnabled(Toggles.FOVCircleVisible.Value)
    end)

    Options.FOVCircleColor:OnChanged(function()
        FOVCircle.setColor(Options.FOVCircleColor.Value)
    end)
end