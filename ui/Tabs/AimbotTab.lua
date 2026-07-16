return function(Services, Config, _State, Library, Tabs, Aimbot, FOVCircle)
    local Options = Library.Options
    local Toggles = Library.Toggles

    local LeftBox = Tabs.Aimbot:AddLeftGroupbox("Aimbot")
    local RightBox = Tabs.Aimbot:AddRightGroupbox("Target Bone")

    LeftBox:AddToggle("AimbotEnabled", {
        Text    = "Enable Aimbot",
        Default = false,
        Tooltip = "Hold RMB to lock onto nearest target",
        Risky   = true,
    })

    LeftBox:AddToggle("AimbotEnemyOnly", {
        Text    = "Enemies Only",
        Default = true,
    })

    LeftBox:AddToggle("AimbotVisCheck", {
        Text    = "Visibility Check",
        Default = true,
        Tooltip = "Only aim at targets with clear line of sight",
    })

    LeftBox:AddDivider()

    LeftBox:AddSlider("AimbotFOV", {
        Text     = "FOV Radius",
        Default  = Config.Aimbot.FOVRadius,
        Min      = 10,
        Max      = 500,
        Rounding = 0,
        Suffix   = "px",
        Tooltip  = "Screen pixel radius to search for targets",
    })

    LeftBox:AddSlider("AimbotSmoothing", {
        Text     = "Smoothing",
        Default  = 15,
        Min      = 0,
        Max      = 99,
        Rounding = 0,
        Suffix   = "%",
        Tooltip  = "0% = instant snap | 99% = very slow",
    })

    LeftBox:AddDivider()

    LeftBox:AddToggle("FOVCircleVisible", {
        Text    = "Show FOV Circle",
        Default = false,
        Tooltip = "Thin 1px ring showing aimbot FOV radius",
    })

    LeftBox:AddLabel("FOV Circle Color")
        :AddColorPicker("FOVCircleColor", {
            Default = Config.FOVCircle.Color,
            Title   = "FOV Circle Color",
        })

    -- Bone selector
    RightBox:AddDropdown("AimbotBone", {
        Values  = { "Top (Head)", "Center (Chest)", "Bottom (Legs)" },
        Default = 1,
        Text    = "Target Bone",
        Tooltip = "Top = head | Center = chest | Bottom = legs",
    })

    RightBox:AddDivider()
    RightBox:AddLabel("Top    → head  (+1.25 above Center)", true)
    RightBox:AddLabel("Center → chest (reference point)",    true)
    RightBox:AddLabel("Bottom → legs  (-1.25 below Center)", true)

    -- Wire
    local boneMap = {
        ["Top (Head)"]     = "Top",
        ["Center (Chest)"] = "Center",
        ["Bottom (Legs)"]  = "Bottom",
    }

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
        Aimbot.setBone(boneMap[Options.AimbotBone.Value] or "Top")
    end)

    Toggles.FOVCircleVisible:OnChanged(function()
        FOVCircle.setEnabled(Toggles.FOVCircleVisible.Value)
    end)

    Options.FOVCircleColor:OnChanged(function()
        FOVCircle.setColor(Options.FOVCircleColor.Value)
    end)

    -- Render loop hook: pass current FOV radius to FOVCircle each frame
    -- This is done in main.lua's RenderStepped via FOVCircle.update(Aimbot.getFOV())
end