--[[
    Loadout.lua
    Parses the LoadoutData JSON StringValue from Workspace.Characters.<name>
]]

local Services  = require("core/Services")
local Config    = require("core/Config")

local Loadout   = {}

-- Weapon ID → display name mapping (expand as more weapons are discovered)
local WeaponNames = {
    weapon_m4a1     = "M4A1",
    weapon_g17      = "G17",
    equipment_frag  = "Frag",
    equipment_stun  = "Stun",
    -- Attachments
    attachment_reflexSight      = "Reflex Sight",
    attachment_muzzleBrake      = "Muzzle Brake",
    attachment_ctrStock         = "CTR Stock",
    attachment_verticalForeGrip = "Vertical Grip",
    -- Perks
    perk_endurance  = "Endurance",
    perk_fastHands  = "Fast Hands",
    perk_anchor     = "Anchor",
    -- Camos
    camo_camoA      = "Camo A",
}

function Loadout.friendlyName(id)
    if not id or id == "" then return "None" end
    return WeaponNames[id] or id
end

function Loadout.parse(player)
    local WS            = Services.Workspace
    local charsFolder   = WS:FindFirstChild(Config.Folders.Characters)
    if not charsFolder then return nil end

    local charModel = charsFolder:FindFirstChild(player.Name)
    if not charModel then return nil end

    local ldInst = charModel:FindFirstChild("LoadoutData")
    if not ldInst then return nil end

    local s, raw = pcall(function()
        return Services.HttpService:JSONDecode(ldInst.Value)
    end)
    if not s or not raw then return nil end

    local function att(category, weaponKey)
        local wData = raw[weaponKey]
        if not wData then return "None" end
        local atts = wData.loadout_weaponAttachments
        if not atts then return "None" end
        local cat = atts[category]
        if not cat or not cat.id then return "None" end
        return Loadout.friendlyName(cat.id)
    end

    return {
        displayName = raw.displayName or "Custom Loadout",
        primary     = Loadout.friendlyName(raw.loadout_primary   and raw.loadout_primary.id),
        secondary   = Loadout.friendlyName(raw.loadout_secondary  and raw.loadout_secondary.id),
        lethal      = Loadout.friendlyName(raw.loadout_lethal     and raw.loadout_lethal.id),
        tactical    = Loadout.friendlyName(raw.loadout_tactical   and raw.loadout_tactical.id),
        perk1       = Loadout.friendlyName(raw.loadout_perk1      and raw.loadout_perk1.id),
        perk2       = Loadout.friendlyName(raw.loadout_perk2      and raw.loadout_perk2.id),
        perk3       = Loadout.friendlyName(raw.loadout_perk3      and raw.loadout_perk3.id),
        -- Primary attachments (confirmed from dump data)
        optic       = att("attachmentCategory_optic",       "loadout_primary"),
        muzzle      = att("attachmentCategory_muzzle",      "loadout_primary"),
        stock       = att("attachmentCategory_stock",       "loadout_primary"),
        underbarrel = att("attachmentCategory_underbarrel", "loadout_primary"),
        grip        = att("attachmentCategory_grip",        "loadout_primary"),
    }
end

-- Returns target Part (Top/Center/Bottom) for aimbot
function Loadout.getTargetPart(player, boneName)
    local WS          = Services.Workspace
    local charsFolder = WS:FindFirstChild(Config.Folders.Characters)
    if not charsFolder then return nil end
    local charModel = charsFolder:FindFirstChild(player.Name)
    if not charModel then return nil end
    return charModel:FindFirstChild(boneName or "Top")
end

return Loadout