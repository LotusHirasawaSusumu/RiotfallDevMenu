return function(Services, Config, _State, Library, Tabs)
    local Players  = Services.Players
    local LP       = Services.LP
    local Workspace = Services.Workspace
    local Options  = Library.Options

    local LeftBox  = Tabs.Players:AddLeftGroupbox("ORANGE Team")
    local RightBox = Tabs.Players:AddRightGroupbox("BLUE Team")
    local ActBox   = Tabs.Players:AddRightGroupbox("Actions")

    local built = {}

    local FriendlyNames = {
        weapon_m4a1                 = "M4A1",
        weapon_g17                  = "G17",
        equipment_frag              = "Frag",
        equipment_stun              = "Stun",
        perk_endurance              = "Endurance",
        perk_fastHands              = "Fast Hands",
        perk_anchor                 = "Anchor",
        attachment_reflexSight      = "Reflex Sight",
        attachment_muzzleBrake      = "Muzzle Brake",
        attachment_ctrStock         = "CTR Stock",
        attachment_verticalForeGrip = "Vertical Grip",
        camo_camoA                  = "Camo A",
    }

    local function fn(id)
        if not id or id == "" then return "None" end
        return FriendlyNames[id] or id
    end

    local function getAtt(wData, cat)
        if not wData then return "None" end
        local a = wData.loadout_weaponAttachments
        if not a then return "None" end
        local c = a[cat]
        return (c and c.id) and fn(c.id) or "None"
    end

    local function parseLoadout(player)
        local folder = Workspace:FindFirstChild(Config.Folders.Characters)
        if not folder then return nil end
        local model = folder:FindFirstChild(player.Name)
        if not model then return nil end
        local inst = model:FindFirstChild("LoadoutData")
        if not inst then return nil end
        local ok, raw = pcall(function()
            return Services.HttpService:JSONDecode(inst.Value)
        end)
        if not ok or not raw then return nil end
        local pri = raw.loadout_primary
        local sec = raw.loadout_secondary
        return {
            primary   = fn(pri and pri.id),
            secondary = fn(sec and sec.id),
            lethal    = fn(raw.loadout_lethal   and raw.loadout_lethal.id),
            tactical  = fn(raw.loadout_tactical and raw.loadout_tactical.id),
            perk1     = fn(raw.loadout_perk1    and raw.loadout_perk1.id),
            perk2     = fn(raw.loadout_perk2    and raw.loadout_perk2.id),
            perk3     = fn(raw.loadout_perk3    and raw.loadout_perk3.id),
        }
    end

    local function buildCard(player)
        if built[player.Name] then return end
        built[player.Name] = true

        local enemy = Services.isEnemy(player)
        local box   = enemy and RightBox or LeftBox
        local n     = player.Name
        local ld    = parseLoadout(player)

        box:AddLabel("PC_" .. n .. "_name", {
            Text = (enemy and "[E] " or "[T] ") .. n, DoesWrap = false })

        if ld then
            box:AddLabel("PC_" .. n .. "_pri",  {
                Text = "  " .. ld.primary .. " / " .. ld.secondary,
                DoesWrap = false })
            box:AddLabel("PC_" .. n .. "_eq",   {
                Text = "  " .. ld.lethal .. " | " .. ld.tactical,
                DoesWrap = false })
            box:AddLabel("PC_" .. n .. "_perk", {
                Text = "  " .. ld.perk1 .. " / " .. ld.perk2 .. " / " .. ld.perk3,
                DoesWrap = true })
        else
            box:AddLabel("PC_" .. n .. "_ld", {
                Text = "  (loading...)", DoesWrap = false })
        end

        box:AddDivider()
    end

    task.delay(2, function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then buildCard(p) end
        end
    end)

    ActBox:AddButton({
        Text = "Refresh Loadouts",
        Func = function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LP then continue end
                local ld = parseLoadout(p)
                if not ld then continue end
                local n = p.Name
                local function trySet(key, text)
                    local ok, opt = pcall(function() return Options["PC_" .. n .. key] end)
                    if ok and opt and opt.SetText then opt:SetText(text) end
                end
                trySet("_pri",  "  " .. ld.primary .. " / " .. ld.secondary)
                trySet("_eq",   "  " .. ld.lethal  .. " | " .. ld.tactical)
                trySet("_perk", "  " .. ld.perk1   .. " / " .. ld.perk2 .. " / " .. ld.perk3)
            end
            Library:Notify({ Title = "Loadouts Refreshed", Description = "Done.", Time = 2 })
        end,
    })
end