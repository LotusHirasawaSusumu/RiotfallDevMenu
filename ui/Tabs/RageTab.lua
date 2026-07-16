-- ui/Tabs/RageTab.lua

return function(Services, Config, _State, Library, Tabs, Rage)
    local Options = Library.Options
    local Toggles = Library.Toggles
    local RC      = Config.Rage

    -- ── AutoFire ─────────────────────────────────────────────────
    local AFBox = Tabs.Rage:AddLeftGroupbox("Auto Fire")

    AFBox:AddToggle("AutoFireEnabled", {
        Text    = "Enable Auto Fire",
        Default = false,
        Risky   = true,
        Tooltip = "Fires automatically when enemy is within FOV radius of crosshair",
    })

    AFBox:AddToggle("AutoFireRequireAimbot", {
        Text    = "Require RMB (Aimbot sync)",
        Default = true,
        Tooltip = "Only fires while Right Mouse Button is held",
    })

    AFBox:AddSlider("AutoFireFOV", {
        Text     = "Auto Fire FOV",
        Default  = RC.AutoFireFOV,
        Min      = 1,
        Max      = 200,
        Rounding = 0,
        Suffix   = "px",
        Tooltip  = "Screen radius — only fires if enemy is this close to crosshair center",
    })

    AFBox:AddSlider("AutoFireRateMin", {
        Text     = "Fire Rate Min",
        Default  = math.floor(RC.AutoFireRateMin * 1000),
        Min      = 10,
        Max      = 500,
        Rounding = 0,
        Suffix   = "ms",
    })

    AFBox:AddSlider("AutoFireRateMax", {
        Text     = "Fire Rate Max",
        Default  = math.floor(RC.AutoFireRateMax * 1000),
        Min      = 10,
        Max      = 500,
        Rounding = 0,
        Suffix   = "ms",
        Tooltip  = "Random interval between min and max for humanization",
    })

    -- ── SpinBot ──────────────────────────────────────────────────
    local SpinBox = Tabs.Rage:AddRightGroupbox("SpinBot")

    SpinBox:AddToggle("SpinBotEnabled", {
        Text    = "Enable SpinBot",
        Default = false,
        Risky   = true,
        Tooltip = "Rotates your visual model only — does not affect your camera or aiming",
    })

    SpinBox:AddDropdown("SpinBotMode", {
        Values  = { "Horizontal", "Vertical", "Jitter", "Random" },
        Default = 1,
        Text    = "Spin Mode",
    })

    SpinBox:AddSlider("SpinBotSpeed", {
        Text     = "Spin Speed",
        Default  = RC.SpinSpeed,
        Min      = 1,
        Max      = 60,
        Rounding = 1,
        Suffix   = "°/f",
        Tooltip  = "Degrees rotated per frame at 60fps",
    })

    SpinBox:AddSlider("SpinBotOffset", {
        Text     = "Base Angle Offset",
        Default  = RC.SpinOffset,
        Min      = 0,
        Max      = 360,
        Rounding = 0,
        Suffix   = "°",
    })

    SpinBox:AddSlider("SpinBotAmplitude", {
        Text     = "Jitter Amplitude",
        Default  = RC.SpinJitterAmplitude,
        Min      = 5,
        Max      = 180,
        Rounding = 0,
        Suffix   = "°",
        Tooltip  = "Only used in Jitter mode",
    })

    -- ── BunnyHop ─────────────────────────────────────────────────
    local BhopBox = Tabs.Rage:AddLeftGroupbox("Bunny Hop")

    BhopBox:AddToggle("BhopEnabled", {
        Text    = "Enable Bunny Hop",
        Default = false,
        Tooltip = "Auto-jumps on landing while Space is held. Modifies WalkSpeed.",
    })

    BhopBox:AddSlider("BhopBaseSpeed", {
        Text     = "Ground Speed",
        Default  = RC.BhopBaseSpeed,
        Min      = 10,
        Max      = 100,
        Rounding = 1,
        Suffix   = "su/s",
        Tooltip  = "WalkSpeed while on ground during bhop",
    })

    BhopBox:AddSlider("BhopAirSpeed", {
        Text     = "Air Speed",
        Default  = RC.BhopAirSpeed,
        Min      = 10,
        Max      = 150,
        Rounding = 1,
        Suffix   = "su/s",
        Tooltip  = "WalkSpeed while airborne",
    })

    BhopBox:AddSlider("BhopJumpPower", {
        Text     = "Jump Power",
        Default  = RC.BhopJumpPower,
        Min      = 10,
        Max      = 150,
        Rounding = 1,
        Suffix   = "",
    })

    -- ── AirStrafe ────────────────────────────────────────────────
    local ASBox = Tabs.Rage:AddRightGroupbox("Air Strafe")

    ASBox:AddToggle("AirStrafeEnabled", {
        Text    = "Enable Air Strafe",
        Default = false,
        Tooltip = "Injects lateral velocity while airborne (A/D keys). CS2-style.",
    })

    ASBox:AddSlider("AirStrafeForce", {
        Text     = "Strafe Force",
        Default  = RC.AirStrafeForce,
        Min      = 5,
        Max      = 300,
        Rounding = 1,
        Suffix   = "su/s²",
    })

    ASBox:AddSlider("AirStrafeMax", {
        Text     = "Max Air Speed",
        Default  = RC.AirStrafeMaxSpeed,
        Min      = 10,
        Max      = 200,
        Rounding = 1,
        Suffix   = "su/s",
    })

    -- ── Third Person ─────────────────────────────────────────────
    local TPBox = Tabs.Rage:AddLeftGroupbox("Third Person")

    TPBox:AddToggle("ThirdPersonEnabled", {
        Text    = "Enable Third Person",
        Default = false,
        Tooltip = "Over-shoulder camera. Automatically disables when dead/spectating.",
    })

    TPBox:AddSlider("TPDistance", {
        Text     = "Camera Distance",
        Default  = RC.ThirdPersonDistance,
        Min      = 2,
        Max      = 30,
        Rounding = 1,
        Suffix   = "su",
    })

    TPBox:AddSlider("TPHeight", {
        Text     = "Height Offset",
        Default  = RC.ThirdPersonHeight,
        Min      = 0,
        Max      = 5,
        Rounding = 2,
        Suffix   = "su",
    })

    TPBox:AddSlider("TPShoulder", {
        Text     = "Shoulder Offset",
        Default  = 60,   -- stored as ×0.01 → 0.60 studs
        Min      = -200,
        Max      = 200,
        Rounding = 0,
        Suffix   = "cm",
        Tooltip  = "Positive = right shoulder, negative = left",
    })

    TPBox:AddSlider("TPFovValue", {
        Text     = "Third Person FOV",
        Default  = RC.ThirdPersonFOV,
        Min      = 40,
        Max      = 120,
        Rounding = 0,
        Suffix   = "°",
    })

    -- ── Wire all ─────────────────────────────────────────────────

    -- AutoFire
    Toggles.AutoFireEnabled:OnChanged(function()
        Rage.setAutoFire(Toggles.AutoFireEnabled.Value)
    end)
    Toggles.AutoFireRequireAimbot:OnChanged(function()
        Rage.setAutoFireRequireAimbot(Toggles.AutoFireRequireAimbot.Value)
    end)
    Options.AutoFireFOV:OnChanged(function()
        Rage.setAutoFireFOV(Options.AutoFireFOV.Value)
    end)
    Options.AutoFireRateMin:OnChanged(function()
        Rage.setAutoFireRateMin(Options.AutoFireRateMin.Value / 1000)
    end)
    Options.AutoFireRateMax:OnChanged(function()
        Rage.setAutoFireRateMax(Options.AutoFireRateMax.Value / 1000)
    end)

    -- SpinBot
    Toggles.SpinBotEnabled:OnChanged(function()
        Rage.setSpinBot(Toggles.SpinBotEnabled.Value)
    end)
    Options.SpinBotMode:OnChanged(function()
        Rage.setSpinMode(Options.SpinBotMode.Value)
    end)
    Options.SpinBotSpeed:OnChanged(function()
        Rage.setSpinSpeed(Options.SpinBotSpeed.Value)
    end)
    Options.SpinBotOffset:OnChanged(function()
        Rage.setSpinOffset(Options.SpinBotOffset.Value)
    end)
    Options.SpinBotAmplitude:OnChanged(function()
        Rage.setSpinAmplitude(Options.SpinBotAmplitude.Value)
    end)

    -- BunnyHop
    Toggles.BhopEnabled:OnChanged(function()
        Rage.setBhop(Toggles.BhopEnabled.Value)
    end)
    Options.BhopBaseSpeed:OnChanged(function()
        Rage.setBhopSpeed(Options.BhopBaseSpeed.Value)
    end)
    Options.BhopAirSpeed:OnChanged(function()
        Rage.setBhopAirSpeed(Options.BhopAirSpeed.Value)
    end)
    Options.BhopJumpPower:OnChanged(function()
        Rage.setBhopJumpPower(Options.BhopJumpPower.Value)
    end)

    -- AirStrafe
    Toggles.AirStrafeEnabled:OnChanged(function()
        Rage.setAirStrafe(Toggles.AirStrafeEnabled.Value)
    end)
    Options.AirStrafeForce:OnChanged(function()
        Rage.setAirStrafeForce(Options.AirStrafeForce.Value)
    end)
    Options.AirStrafeMax:OnChanged(function()
        Rage.setAirStrafeMax(Options.AirStrafeMax.Value)
    end)

    -- ThirdPerson
    Toggles.ThirdPersonEnabled:OnChanged(function()
        Rage.setThirdPerson(Toggles.ThirdPersonEnabled.Value)
    end)
    Options.TPDistance:OnChanged(function()
        Rage.setTPDistance(Options.TPDistance.Value)
    end)
    Options.TPHeight:OnChanged(function()
        Rage.setTPHeight(Options.TPHeight.Value)
    end)
    Options.TPShoulder:OnChanged(function()
        Rage.setTPShoulder(Options.TPShoulder.Value / 100)
    end)
    Options.TPFovValue:OnChanged(function()
        Rage.setTPFOV(Options.TPFovValue.Value)
    end)

    -- Apply initial values immediately
    Rage.setAutoFireFOV(Options.AutoFireFOV.Value)
    Rage.setAutoFireRateMin(Options.AutoFireRateMin.Value / 1000)
    Rage.setAutoFireRateMax(Options.AutoFireRateMax.Value / 1000)
    Rage.setSpinSpeed(Options.SpinBotSpeed.Value)
    Rage.setTPDistance(Options.TPDistance.Value)
    Rage.setTPShoulder(Options.TPShoulder.Value / 100)
    Rage.setTPFOV(Options.TPFovValue.Value)
end