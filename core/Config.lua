local Config = {
    VERSION = "2.2",

    Folders = {
        Characters        = "Characters",
        CharacterMeshes   = "CharacterMeshes",
        PlayerHighlights  = "PlayerHighlights",
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
        NameColor           = Color3.fromRGB(255, 255, 255),
        NameSize            = 14,
    },

    Aimbot = {
        FOVRadius   = 120,
        Smoothing   = 0.15,
        TargetBone  = "Top",
        VisCheck    = true,
    },

    Camera = {
        DefaultFOV = 70,
        MinFOV     = 40,
        MaxFOV     = 120,
    },

    -- FOV circle: thin ring drawn via a Frame with UIStroke
    FOVCircle = {
        Thickness    = 1,       -- px, thin line
        Transparency = 0.35,
        Color        = Color3.fromRGB(255, 255, 255),
        Segments     = 64,      -- unused (UIStroke approach has no segments)
    },
}

return Config