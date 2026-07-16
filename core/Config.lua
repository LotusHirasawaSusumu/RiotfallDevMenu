--[[
    Config.lua
    All tunable settings for the dev menu.
    Edit values here — no need to touch other files.
]]

local Config = {

    -- ── Meta ─────────────────────────────
    VERSION         = "1.1",
    MENU_TITLE      = "RIOTFALL  DEV MENU",
    TOGGLE_KEY      = Enum.KeyCode.Insert,

    -- ── Window ───────────────────────────
    MENU_W          = 360,
    MENU_H          = 540,
    MENU_START_X    = 60,
    MENU_START_Y    = 60,

    -- ── ESP defaults ─────────────────────
    ESP = {
        Enabled             = false,
        EnemiesOnly         = true,
        FillTransparency    = 0.6,
        OutlineTransparency = 0.0,
        EnemyFillColor      = Color3.fromRGB(255, 60,  60),
        EnemyOutlineColor   = Color3.fromRGB(180, 0,   0),
        TeamFillColor       = Color3.fromRGB(60,  120, 255),
        TeamOutlineColor    = Color3.fromRGB(0,   60,  180),
        -- Game defaults (restore on disable)
        DefaultFillColor    = Color3.fromRGB(255, 0,   0),
        DefaultOutlineColor = Color3.fromRGB(159, 0,   0),
    },

    -- ── Aimbot defaults ──────────────────
    Aimbot = {
        Enabled     = false,
        EnemyOnly   = true,
        FOVRadius   = 120,      -- pixels
        Smoothing   = 0.15,     -- 0 = instant snap, 0.99 = very slow
        TargetBone  = "Top",    -- "Top" | "Center" | "Bottom"
        TriggerKey  = Enum.UserInputType.MouseButton2,
    },

    -- ── Camera defaults ──────────────────
    Camera = {
        FOVEnabled  = false,
        FOVValue    = 90,
        DefaultFOV  = 70,
    },

    -- ── Info display ─────────────────────
    Display = {
        ShowLoadout = true,
        ShowAmmo    = true,
        ShowHP      = true,
    },

    -- ── Workspace folder names ───────────
    -- (change here if game updates folder names)
    Folders = {
        Characters          = "Characters",
        CharacterMeshes     = "CharacterMeshes",
        CharacterCollisions = "CharacterCollisions",
        PlayerHighlights    = "PlayerHighlights",
        VoiceOrigins        = "VoiceOrigins",
    },

    -- ── ReplicatedStorage paths ──────────
    Events = {
        ClientToClient      = "clientToClient",
        HealthEvent         = "updateSimulationHealthEffects",
        DamageEvent         = "updateSimulationIncomingDamage",
        AmmoEvent           = "updWeaponHudAmmo",
    },

}

return Config