-- core/Config.lua
local Config = {
    VERSION = "2.4",

    Folders = {
        Characters          = "Characters",
        CharacterMeshes     = "CharacterMeshes",
        CharacterCollisions = "CharacterCollisions",
        PlayerHighlights    = "PlayerHighlights",
        VoiceOrigins        = "VoiceOrigins",
    },

    Events = {
        ClientToClient = "clientToClient",
        HealthEvent    = "updateSimulationHealthEffects",
        DamageEvent    = "updateSimulationIncomingDamage",
        AmmoEvent      = "updWeaponHudAmmo",
    },

    ESP = {
        EnemyFillColor      = Color3.fromRGB(255, 50,  50),
        EnemyOutlineColor   = Color3.fromRGB(255, 50,  50),
        AllyFillColor       = Color3.fromRGB(0,   150, 255),
        AllyOutlineColor    = Color3.fromRGB(0,   150, 255),
        FillTransparency    = 0.4,
        OutlineTransparency = 0.1,
        NameColor           = Color3.fromRGB(255, 220, 80),  -- bright yellow, visible on all maps
        EnemyNameColor      = Color3.fromRGB(255, 80,  80),
        AllyNameColor       = Color3.fromRGB(80,  180, 255),
        NameSize            = 13,
        ShowDistance        = true,
        ShowWeapon          = true,
        MaxNameDistance     = 2000,  -- studs, large map support
    },

    Aimbot = {
        FOVRadius   = 150,
        Smoothing   = 0.15,
        VisCheck    = true,
        Bones = {
            Head = {
                collision    = { "Neck" },
                fallback     = "Top",
                predictScale = 0.06,
            },
            Chest = {
                collision    = { "MidUpperSpine", "LowerSpine" },
                fallback     = "Center",
                predictScale = 0.08,
            },
            Pelvis = {
                collision    = { "LowerSpine" },
                fallback     = "Center",
                predictScale = 0.10,
            },
            Legs = {
                collision    = { "UpperLeg.L", "UpperLeg.R" },
                fallback     = "Bottom",
                predictScale = 0.05,
            },
        },
        DefaultBone     = "Head",
        MinDeltaMagnitude = 0.5,  -- px, ignore sub-pixel movements to prevent bounce
    },

    Camera = {
        DefaultFOV = 70,
        MinFOV     = 40,
        MaxFOV     = 120,
    },

    FOVCircle = {
        Thickness    = 1,
        Transparency = 0.3,
        Color        = Color3.fromRGB(255, 255, 255),
    },
    Rage = {
        -- AutoFire
        AutoFireFOV         = 15,    -- px radius, tight — only fires when crosshair near target
        AutoFireRateMin     = 0.08,  -- seconds between shots minimum
        AutoFireRateMax     = 0.12,  -- seconds between shots maximum (humanized)

        -- SpinBot
        SpinSpeed           = 15,    -- degrees per frame
        SpinMode            = "Horizontal",  -- "Horizontal"|"Vertical"|"Jitter"|"Random"
        SpinJitterAmplitude = 45,    -- degrees, for jitter mode
        SpinOffset          = 180,   -- base yaw offset in degrees

        -- BunnyHop
        BhopBaseSpeed       = 24,    -- WalkSpeed override while hopping (game default unknown)
        BhopAirSpeed        = 30,    -- speed applied at peak of jump
        BhopJumpPower       = 50,    -- JumpPower override
        BhopDefaultSpeed    = 16,    -- restore value on disable

        -- AirStrafe
        AirStrafeForce      = 60,    -- studs/s² lateral force while airborne
        AirStrafeMaxSpeed   = 40,

        -- ThirdPerson
        ThirdPersonDistance = 8,
        ThirdPersonHeight   = 1.6,
        ThirdPersonFOV      = 90,
    },
}

return Config