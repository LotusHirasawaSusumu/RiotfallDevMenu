-- core/Config.lua
local Config = {
    VERSION = "2.3",

    Folders = {
        Characters          = "Characters",
        CharacterMeshes     = "CharacterMeshes",
        CharacterCollisions = "CharacterCollisions",
        PlayerHighlights    = "PlayerHighlights",
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
        -- Name tag defaults
        NameColor           = Color3.fromRGB(255, 255, 255),
        NameSize            = 13,
        ShowDistance        = true,
        ShowWeapon          = true,
        ShowHealthBar       = true,
        MaxNameDistance     = 200,  -- studs, beyond this name tag hidden
    },

    -- Aimbot bone priority map
    -- Primary: CharacterCollisions MeshPart names (animated, follows skeleton)
    -- Fallback: Characters static part names
    Aimbot = {
        FOVRadius   = 120,
        Smoothing   = 0.15,
        VisCheck    = true,
        -- Bone configs
        Bones = {
            Head = {
                -- Ordered by preference
                collision = { "Neck" },
                fallback  = "Top",
                -- Velocity prediction multiplier (seconds ahead)
                -- Head moves more erratically, predict less
                predictScale = 0.06,
            },
            Chest = {
                collision = { "MidUpperSpine", "LowerSpine" },
                fallback  = "Center",
                predictScale = 0.08,
            },
            Pelvis = {
                collision = { "LowerSpine" },
                fallback  = "Center",
                predictScale = 0.10,
            },
            Legs = {
                collision = { "UpperLeg.L", "UpperLeg.R" },
                fallback  = "Bottom",
                predictScale = 0.05,
            },
        },
        DefaultBone = "Head",
    },

    Camera = {
        DefaultFOV = 70,
        MinFOV     = 40,
        MaxFOV     = 120,
    },

    FOVCircle = {
        -- UIStroke thickness in pixels — 1 = thinnest crisp ring
        Thickness    = 1,
        Transparency = 0.3,
        Color        = Color3.fromRGB(255, 255, 255),
    },
}

return Config