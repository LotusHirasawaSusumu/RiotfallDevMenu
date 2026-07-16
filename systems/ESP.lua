-- systems/ESP.lua
--[[
    ESP System v2.3
    - Highlight: parented inside CharacterMeshes model, bypasses game monitoring
    - Name tag: CS2-style BillboardGui with name, distance, weapon, health bar
    - StudsOffset calculated from model top, not body center
]]

return function(Services, Config, State)
    local Players         = Services.Players
    local LP              = Services.LP
    local CharacterMeshes = Services.CharacterMeshes
    local Characters      = Services.Characters
    local Camera          = Services.Camera
    local Workspace       = Services.Workspace

    local HIGHLIGHT_NAME  = "RealVisualChams"
    local NAMETAG_NAME    = "RF_NameTag"

    local ESPSettings = {
        Enabled             = false,
        EnemiesOnly         = true,
        ShowName            = false,
        ShowDistance        = true,
        ShowWeapon          = true,
        ShowHealthBar       = true,
        FillTransparency    = Config.ESP.FillTransparency,
        OutlineTransparency = Config.ESP.OutlineTransparency,
        NameColor           = Config.ESP.NameColor,
        NameSize            = Config.ESP.NameSize,
        MaxNameDistance     = Config.ESP.MaxNameDistance,
    }

    -- ── Utility ───────────────────────────────────────────────────

    -- Find the topmost MeshPart in the model to anchor the name tag
    -- Uses the part with the highest Y position center
    local function getTopPart(meshModel)
        local topPart = nil
        local topY    = -math.huge
        for _, child in ipairs(meshModel:GetChildren()) do
            if child:IsA("MeshPart") or child:IsA("Part") then
                local ok, pos = pcall(function() return child.Position end)
                if ok and pos.Y > topY then
                    topY    = pos.Y
                    topPart = child
                end
            end
        end
        -- Fallback to RootPart
        return topPart or meshModel:FindFirstChild("RootPart")
    end

    local function getCharacterData(player)
        if not Characters then return nil end
        return Characters:FindFirstChild(player.Name)
    end

    local function getLoadoutPrimary(player)
        local charData = getCharacterData(player)
        if not charData then return nil end
        local ldInst = charData:FindFirstChild("LoadoutData")
        if not ldInst then return nil end
        local ok, raw = pcall(function()
            return Services.HttpService:JSONDecode(ldInst.Value)
        end)
        if not ok or not raw then return nil end
        local FriendlyNames = {
            weapon_m4a1 = "M4A1", weapon_g17 = "G17",
        }
        local id = raw.loadout_primary and raw.loadout_primary.id
        if not id then return nil end
        return FriendlyNames[id] or id
    end

    -- ── Highlight ─────────────────────────────────────────────────

    local function getOrCreateHighlight(meshModel)
        local hl = meshModel:FindFirstChild(HIGHLIGHT_NAME)
        if not hl then
            hl           = Instance.new("Highlight")
            hl.Name      = HIGHLIGHT_NAME
            hl.Adornee   = meshModel
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent    = meshModel
        end
        return hl
    end

    local function removeHighlight(meshModel)
        local hl = meshModel:FindFirstChild(HIGHLIGHT_NAME)
        if hl then hl:Destroy() end
    end

    -- ── CS2-style Name Tag ────────────────────────────────────────
    --[[
        Layout (top to bottom, centered above head):

        ┌─────────────────────┐
        │  PlayerName   123m  │   ← name + distance
        │  M4A1               │   ← weapon (if enabled)
        │ ████████░░░░░░░░░░  │   ← health bar (if enabled)
        └─────────────────────┘

        Anchored to the highest MeshPart in the model.
        AlwaysOnTop = true, so visible through walls when ESP is on.
    ]]

    local function buildNameTag(meshModel, player, fillColor)
        -- Clean up old tag
        local old = meshModel:FindFirstChild(NAMETAG_NAME, true)
        if old then old:Destroy() end

        if not ESPSettings.ShowName then return end

        local anchorPart = getTopPart(meshModel)
        if not anchorPart then return end

        -- Measure how far above the top part we should offset
        -- Top part's own half-height + small margin
        local ok, sz = pcall(function() return anchorPart.Size end)
        local halfH  = (ok and sz) and sz.Y * 0.5 or 0.5
        local margin = 0.3   -- studs above the part top

        -- Billboard dimensions
        local bbW = 120   -- px width
        local lineH = 16  -- px per text line

        -- Count active rows
        local rowCount = 1  -- name always shown
        if ESPSettings.ShowWeapon   then rowCount = rowCount + 1 end
        if ESPSettings.ShowHealthBar then rowCount = rowCount + 1 end

        local bbH = rowCount * lineH + 4

        local bb = Instance.new("BillboardGui")
        bb.Name             = NAMETAG_NAME
        bb.Adornee          = anchorPart
        -- Offset upward from the top of the part into open space
        bb.StudsOffset      = Vector3.new(0, halfH + margin, 0)
        bb.Size             = UDim2.fromOffset(bbW, bbH)
        bb.AlwaysOnTop      = true
        bb.LightInfluence   = 0
        bb.ResetOnSpawn     = false
        bb.MaxDistance      = ESPSettings.MaxNameDistance
        bb.Parent           = meshModel   -- parent to mesh model, not anchorPart

        -- Container frame
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size                   = UDim2.new(1, 0, 1, 0)
        container.Parent                 = bb

        local layout = Instance.new("UIListLayout")
        layout.FillDirection       = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder           = Enum.SortOrder.LayoutOrder
        layout.Padding             = UDim.new(0, 1)
        layout.Parent              = container

        -- ── Row 1: Name + Distance ────────────────────────────────
        local nameRow = Instance.new("Frame")
        nameRow.BackgroundTransparency = 1
        nameRow.Size                   = UDim2.new(1, 0, 0, lineH)
        nameRow.LayoutOrder            = 1
        nameRow.Parent                 = container

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size                   = UDim2.new(0.75, 0, 1, 0)
        nameLabel.Text                   = player.Name
        nameLabel.TextColor3             = fillColor
        nameLabel.TextSize               = ESPSettings.NameSize
        nameLabel.Font                   = Enum.Font.GothamBold
        nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3       = Color3.new(0, 0, 0)
        nameLabel.TextTruncate           = Enum.TextTruncate.AtEnd
        nameLabel.Name                   = "NameLabel"
        nameLabel.Parent                 = nameRow

        if ESPSettings.ShowDistance then
            local distLabel = Instance.new("TextLabel")
            distLabel.BackgroundTransparency = 1
            distLabel.Size                   = UDim2.new(0.25, 0, 1, 0)
            distLabel.Position               = UDim2.new(0.75, 0, 0, 0)
            distLabel.Text                   = "0m"
            distLabel.TextColor3             = Color3.fromRGB(200, 200, 200)
            distLabel.TextSize               = ESPSettings.NameSize - 1
            distLabel.Font                   = Enum.Font.Gotham
            distLabel.TextXAlignment         = Enum.TextXAlignment.Right
            distLabel.TextStrokeTransparency = 0.5
            distLabel.TextStrokeColor3       = Color3.new(0, 0, 0)
            distLabel.Name                   = "DistLabel"
            distLabel.Parent                 = nameRow
        end

        -- ── Row 2: Weapon ─────────────────────────────────────────
        if ESPSettings.ShowWeapon then
            local weaponLabel = Instance.new("TextLabel")
            weaponLabel.BackgroundTransparency = 1
            weaponLabel.Size                   = UDim2.new(1, 0, 0, lineH)
            weaponLabel.Text                   = getLoadoutPrimary(player) or "Unknown"
            weaponLabel.TextColor3             = Color3.fromRGB(210, 210, 210)
            weaponLabel.TextSize               = ESPSettings.NameSize - 2
            weaponLabel.Font                   = Enum.Font.Gotham
            weaponLabel.TextXAlignment         = Enum.TextXAlignment.Left
            weaponLabel.TextStrokeTransparency = 0.5
            weaponLabel.TextStrokeColor3       = Color3.new(0, 0, 0)
            weaponLabel.LayoutOrder            = 2
            weaponLabel.Name                   = "WeaponLabel"
            weaponLabel.Parent                 = container
        end

        -- ── Row 3: Health bar ─────────────────────────────────────
        if ESPSettings.ShowHealthBar then
            local barRow = Instance.new("Frame")
            barRow.BackgroundColor3      = Color3.fromRGB(40, 40, 40)
            barRow.BackgroundTransparency= 0.3
            barRow.Size                  = UDim2.new(1, 0, 0, 5)
            barRow.LayoutOrder           = 3
            barRow.Name                  = "HealthBarBG"
            barRow.Parent                = container

            local barFill = Instance.new("Frame")
            barFill.BackgroundColor3      = Color3.fromRGB(80, 220, 80)
            barFill.BackgroundTransparency= 0
            barFill.Size                  = UDim2.new(1, 0, 1, 0)   -- full = 100 HP
            barFill.BorderSizePixel       = 0
            barFill.Name                  = "HealthBarFill"
            barFill.Parent                = barRow

            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(0, 2)
            barCorner.Parent       = barRow

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 2)
            fillCorner.Parent       = barFill
        end

        return bb
    end

    -- ── Per-player update (called from Heartbeat for live data) ───
    -- Updates distance label and health bar without rebuilding the billboard

    local function updateNameTagData(meshModel, player)
        local bb = meshModel:FindFirstChild(NAMETAG_NAME)
        if not bb then return end

        -- Distance
        if ESPSettings.ShowDistance then
            local distLabel = bb:FindFirstChild("DistLabel", true)
            if distLabel then
                local rootPart = meshModel:FindFirstChild("RootPart")
                if rootPart then
                    local ok, rPos = pcall(function() return rootPart.Position end)
                    if ok then
                        local camPos = Camera.CFrame.Position
                        local studs  = (rPos - camPos).Magnitude
                        local meters = math.floor(studs * 0.28)  -- 1 stud ≈ 0.28m
                        distLabel.Text = meters .. "m"
                    end
                end
            end
        end

        -- Health bar (based on VoiceOrigins Humanoid if available, else fixed)
        if ESPSettings.ShowHealthBar then
            local fill = meshModel:FindFirstChild("HealthBarFill", true)
            if fill then
                -- Try VoiceOrigins humanoid
                local voiceOri = Workspace:FindFirstChild("VoiceOrigins")
                local hpPct    = 1
                if voiceOri then
                    for _, teamFolder in ipairs(voiceOri:GetChildren()) do
                        local plrModel = teamFolder:FindFirstChild(player.Name)
                        if plrModel then
                            local hum = plrModel:FindFirstChildOfClass("Humanoid")
                            if hum then
                                local ok1, hp    = pcall(function() return hum.Health end)
                                local ok2, maxhp = pcall(function() return hum.MaxHealth end)
                                if ok1 and ok2 and maxhp > 0 then
                                    hpPct = math.clamp(hp / maxhp, 0, 1)
                                end
                            end
                            break
                        end
                    end
                end
                fill.Size = UDim2.new(hpPct, 0, 1, 0)
                -- Color: green → yellow → red
                local r = math.floor(255 * (1 - hpPct))
                local g = math.floor(255 * hpPct)
                fill.BackgroundColor3 = Color3.fromRGB(r, g, 0)
            end
        end
    end

    -- ── Core apply ────────────────────────────────────────────────

    local ESP = {}

    function ESP.applyToMesh(meshModel)
        local player = Players:FindFirstChild(meshModel.Name)
        if not player or player == LP then return end

        if not ESPSettings.Enabled then
            removeHighlight(meshModel)
            local old = meshModel:FindFirstChild(NAMETAG_NAME)
            if old then old:Destroy() end
            return
        end

        local enemy = State:IsEnemy(player)

        if ESPSettings.EnemiesOnly and not enemy then
            removeHighlight(meshModel)
            local old = meshModel:FindFirstChild(NAMETAG_NAME)
            if old then old:Destroy() end
            return
        end

        local fillColor    = enemy and Config.ESP.EnemyFillColor    or Config.ESP.AllyFillColor
        local outlineColor = enemy and Config.ESP.EnemyOutlineColor  or Config.ESP.AllyOutlineColor

        local hl               = getOrCreateHighlight(meshModel)
        hl.FillColor           = fillColor
        hl.OutlineColor        = outlineColor
        hl.FillTransparency    = ESPSettings.FillTransparency
        hl.OutlineTransparency = ESPSettings.OutlineTransparency

        buildNameTag(meshModel, player, fillColor)
    end

    function ESP.applyToPlayer(player)
        if not CharacterMeshes then return end
        local mesh = CharacterMeshes:FindFirstChild(player.Name)
        if mesh then ESP.applyToMesh(mesh) end
    end

    function ESP.refreshAll()
        if not CharacterMeshes then return end
        for _, model in ipairs(CharacterMeshes:GetChildren()) do
            if model:IsA("Model") then
                ESP.applyToMesh(model)
            end
        end
    end

    function ESP.removePlayer(player)
        if not CharacterMeshes then return end
        local mesh = CharacterMeshes:FindFirstChild(player.Name)
        if not mesh then return end
        removeHighlight(mesh)
        local tag = mesh:FindFirstChild(NAMETAG_NAME)
        if tag then tag:Destroy() end
    end

    function ESP.removeAll()
        if not CharacterMeshes then return end
        for _, model in ipairs(CharacterMeshes:GetChildren()) do
            removeHighlight(model)
            local tag = model:FindFirstChild(NAMETAG_NAME)
            if tag then tag:Destroy() end
        end
    end

    -- Setters
    function ESP.setEnabled(v)
        ESPSettings.Enabled = v
        if v then ESP.refreshAll() else ESP.removeAll() end
    end

    function ESP.setEnemiesOnly(v)
        ESPSettings.EnemiesOnly = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    function ESP.setShowName(v)
        ESPSettings.ShowName = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    function ESP.setShowDistance(v)
        ESPSettings.ShowDistance = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    function ESP.setShowWeapon(v)
        ESPSettings.ShowWeapon = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    function ESP.setShowHealthBar(v)
        ESPSettings.ShowHealthBar = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    function ESP.setMaxDistance(v)
        ESPSettings.MaxNameDistance = v
        -- Update existing billboards' MaxDistance without full rebuild
        if CharacterMeshes then
            for _, model in ipairs(CharacterMeshes:GetChildren()) do
                local bb = model:FindFirstChild(NAMETAG_NAME)
                if bb and bb:IsA("BillboardGui") then
                    bb.MaxDistance = v
                end
            end
        end
    end

    function ESP.setFillTransparency(v)
        ESPSettings.FillTransparency = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    function ESP.setOutlineTransparency(v)
        ESPSettings.OutlineTransparency = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    -- ── Heartbeat: live name tag data (distance + HP) ─────────────
    -- Runs on Heartbeat, NOT RenderStepped (no frame-sync needed)
    -- Only active when ShowName is enabled to avoid wasted work
    local nameTagConn = nil

    local function startNameTagUpdater()
        if nameTagConn then return end
        nameTagConn = game:GetService("RunService").Heartbeat:Connect(function()
            if not ESPSettings.Enabled or not ESPSettings.ShowName then return end
            if not CharacterMeshes then return end
            for _, model in ipairs(CharacterMeshes:GetChildren()) do
                if not model:IsA("Model") then continue end
                local player = Players:FindFirstChild(model.Name)
                if player and player ~= LP then
                    updateNameTagData(model, player)
                end
            end
        end)
    end

    local function stopNameTagUpdater()
        if nameTagConn then
            nameTagConn:Disconnect()
            nameTagConn = nil
        end
    end

    -- Override setShowName to also manage updater
    local _setShowName = ESP.setShowName
    function ESP.setShowName(v)
        ESPSettings.ShowName = v
        if v then
            startNameTagUpdater()
        else
            stopNameTagUpdater()
        end
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    -- Listeners
    if CharacterMeshes then
        State:Track(CharacterMeshes.ChildAdded:Connect(function(child)
            if child:IsA("Model") and ESPSettings.Enabled then
                task.wait(0.1)
                ESP.applyToMesh(child)
            end
        end))
    end

    return ESP
end