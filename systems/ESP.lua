-- systems/ESP.lua
--[[
    ESP v2.4
    Fixes:
    - Corpse removal: listens to VoiceOrigins Humanoid.Died + CharacterMeshes.ChildRemoved
    - Auto-detection: periodic scan every 3s + ChildAdded (no race condition)
    - New player support: scans on Players.PlayerAdded after short delay
    - Name color adjustable, bright defaults
    - Health bar removed
    - MaxDistance large (2000 studs)
]]

return function(Services, Config, State)
    local Players         = Services.Players
    local LP              = Services.LP
    local CharacterMeshes = Services.CharacterMeshes
    local Characters      = Services.Characters
    local Camera          = Services.Camera
    local Workspace       = Services.Workspace
    local RunService      = Services.RunService

    local HIGHLIGHT_NAME = "RealVisualChams"
    local NAMETAG_NAME   = "RF_NameTag"

    -- Mutable settings written by UI
    local S = {
        Enabled             = false,
        EnemiesOnly         = true,
        ShowName            = false,
        ShowDistance        = true,
        ShowWeapon          = true,
        FillTransparency    = Config.ESP.FillTransparency,
        OutlineTransparency = Config.ESP.OutlineTransparency,
        EnemyNameColor      = Config.ESP.EnemyNameColor,
        AllyNameColor       = Config.ESP.AllyNameColor,
        NameSize            = Config.ESP.NameSize,
        MaxNameDistance     = Config.ESP.MaxNameDistance,
    }

    -- ── Utility ───────────────────────────────────────────────────

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
        return topPart or meshModel:FindFirstChild("RootPart")
    end

    local function getLoadoutPrimary(player)
        if not Characters then return nil end
        local model = Characters:FindFirstChild(player.Name)
        if not model then return nil end
        local inst = model:FindFirstChild("LoadoutData")
        if not inst then return nil end
        local ok, raw = pcall(function()
            return Services.HttpService:JSONDecode(inst.Value)
        end)
        if not ok or not raw then return nil end
        local Names = { weapon_m4a1 = "M4A1", weapon_g17 = "G17" }
        local id = raw.loadout_primary and raw.loadout_primary.id
        return id and (Names[id] or id) or nil
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

    -- ── Name tag ──────────────────────────────────────────────────

    local function removeNameTag(meshModel)
        local tag = meshModel:FindFirstChild(NAMETAG_NAME)
        if tag then tag:Destroy() end
    end

    local function buildNameTag(meshModel, player, nameColor)
        removeNameTag(meshModel)
        if not S.ShowName then return end

        local anchorPart = getTopPart(meshModel)
        if not anchorPart then return end

        local ok, sz = pcall(function() return anchorPart.Size end)
        local halfH  = (ok and sz) and sz.Y * 0.5 or 0.5

        local lineH    = 16
        local rowCount = 1
        if S.ShowWeapon   then rowCount = rowCount + 1 end

        local bb = Instance.new("BillboardGui")
        bb.Name           = NAMETAG_NAME
        bb.Adornee        = anchorPart
        bb.StudsOffset    = Vector3.new(0, halfH + 0.4, 0)
        bb.Size           = UDim2.fromOffset(130, rowCount * lineH + 4)
        bb.AlwaysOnTop    = true
        bb.LightInfluence = 0
        bb.ResetOnSpawn   = false
        bb.MaxDistance    = S.MaxNameDistance
        bb.Parent         = meshModel

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

        -- Row 1: name + distance
        local nameRow = Instance.new("Frame")
        nameRow.BackgroundTransparency = 1
        nameRow.Size                   = UDim2.new(1, 0, 0, lineH)
        nameRow.LayoutOrder            = 1
        nameRow.Parent                 = container

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size                   = UDim2.new(0.72, 0, 1, 0)
        nameLabel.Text                   = player.Name
        nameLabel.TextColor3             = nameColor
        nameLabel.TextSize               = S.NameSize
        nameLabel.Font                   = Enum.Font.GothamBold
        nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
        nameLabel.TextStrokeTransparency = 0.25
        nameLabel.TextStrokeColor3       = Color3.new(0, 0, 0)
        nameLabel.TextTruncate           = Enum.TextTruncate.AtEnd
        nameLabel.Name                   = "NameLabel"
        nameLabel.Parent                 = nameRow

        if S.ShowDistance then
            local distLabel = Instance.new("TextLabel")
            distLabel.BackgroundTransparency = 1
            distLabel.Size                   = UDim2.new(0.28, 0, 1, 0)
            distLabel.Position               = UDim2.new(0.72, 0, 0, 0)
            distLabel.Text                   = "0m"
            distLabel.TextColor3             = Color3.fromRGB(220, 220, 220)
            distLabel.TextSize               = S.NameSize - 2
            distLabel.Font                   = Enum.Font.Gotham
            distLabel.TextXAlignment         = Enum.TextXAlignment.Right
            distLabel.TextStrokeTransparency = 0.4
            distLabel.TextStrokeColor3       = Color3.new(0, 0, 0)
            distLabel.Name                   = "DistLabel"
            distLabel.Parent                 = nameRow
        end

        -- Row 2: weapon
        if S.ShowWeapon then
            local weaponLabel = Instance.new("TextLabel")
            weaponLabel.BackgroundTransparency = 1
            weaponLabel.Size                   = UDim2.new(1, 0, 0, lineH)
            weaponLabel.Text                   = getLoadoutPrimary(player) or "Unknown"
            weaponLabel.TextColor3             = Color3.fromRGB(210, 210, 210)
            weaponLabel.TextSize               = S.NameSize - 2
            weaponLabel.Font                   = Enum.Font.Gotham
            weaponLabel.TextXAlignment         = Enum.TextXAlignment.Left
            weaponLabel.TextStrokeTransparency = 0.4
            weaponLabel.TextStrokeColor3       = Color3.new(0, 0, 0)
            weaponLabel.LayoutOrder            = 2
            weaponLabel.Name                   = "WeaponLabel"
            weaponLabel.Parent                 = container
        end
    end

    -- ── Live name tag data update ─────────────────────────────────

    local function updateNameTagData(meshModel, player)
        local bb = meshModel:FindFirstChild(NAMETAG_NAME)
        if not bb then return end

        if S.ShowDistance then
            local distLabel = bb:FindFirstChild("DistLabel", true)
            if distLabel then
                local rootPart = meshModel:FindFirstChild("RootPart")
                if rootPart then
                    local ok, rPos = pcall(function() return rootPart.Position end)
                    if ok then
                        local studs  = (rPos - Camera.CFrame.Position).Magnitude
                        local meters = math.floor(studs * 0.28 + 0.5)
                        distLabel.Text = meters .. "m"
                    end
                end
            end
        end
    end

    -- ── Core apply ────────────────────────────────────────────────

    -- Registry: meshModel name → corpseDiedConn
    local corpseDiedConns = {}

    local function watchForDeath(meshModel, player)
        -- Disconnect any previous watcher for this player
        if corpseDiedConns[player.Name] then
            pcall(function() corpseDiedConns[player.Name]:Disconnect() end)
            corpseDiedConns[player.Name] = nil
        end

        -- Watch VoiceOrigins Humanoid.Died
        local voiceOri = Workspace:FindFirstChild(Config.Folders.VoiceOrigins)
        if not voiceOri then return end

        for _, teamFolder in ipairs(voiceOri:GetChildren()) do
            local plrModel = teamFolder:FindFirstChild(player.Name)
            if plrModel then
                local hum = plrModel:FindFirstChildOfClass("Humanoid")
                if hum then
                    corpseDiedConns[player.Name] = hum.Died:Connect(function()
                        -- Small delay so death animation starts, then remove ESP
                        task.delay(0.2, function()
                            if meshModel and meshModel.Parent then
                                removeHighlight(meshModel)
                                removeNameTag(meshModel)
                            end
                        end)
                    end)
                end
                break
            end
        end
    end

    local ESP = {}

    function ESP.applyToMesh(meshModel)
        local player = Players:FindFirstChild(meshModel.Name)
        if not player or player == LP then return end

        if not S.Enabled then
            removeHighlight(meshModel)
            removeNameTag(meshModel)
            return
        end

        local enemy = State:IsEnemy(player)

        if S.EnemiesOnly and not enemy then
            removeHighlight(meshModel)
            removeNameTag(meshModel)
            return
        end

        local fillColor    = enemy and Config.ESP.EnemyFillColor    or Config.ESP.AllyFillColor
        local outlineColor = enemy and Config.ESP.EnemyOutlineColor  or Config.ESP.AllyOutlineColor
        local nameColor    = enemy and S.EnemyNameColor             or S.AllyNameColor

        local hl               = getOrCreateHighlight(meshModel)
        hl.FillColor           = fillColor
        hl.OutlineColor        = outlineColor
        hl.FillTransparency    = S.FillTransparency
        hl.OutlineTransparency = S.OutlineTransparency

        buildNameTag(meshModel, player, nameColor)
        watchForDeath(meshModel, player)
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
        if corpseDiedConns[player.Name] then
            pcall(function() corpseDiedConns[player.Name]:Disconnect() end)
            corpseDiedConns[player.Name] = nil
        end
        if not CharacterMeshes then return end
        local mesh = CharacterMeshes:FindFirstChild(player.Name)
        if not mesh then return end
        removeHighlight(mesh)
        removeNameTag(mesh)
    end

    function ESP.removeAll()
        for name, conn in pairs(corpseDiedConns) do
            pcall(function() conn:Disconnect() end)
        end
        corpseDiedConns = {}
        if not CharacterMeshes then return end
        for _, model in ipairs(CharacterMeshes:GetChildren()) do
            removeHighlight(model)
            removeNameTag(model)
        end
    end

    -- Setters
    function ESP.setEnabled(v)
        S.Enabled = v
        if v then ESP.refreshAll() else ESP.removeAll() end
    end

    function ESP.setEnemiesOnly(v)
        S.EnemiesOnly = v
        if S.Enabled then ESP.refreshAll() end
    end

    function ESP.setShowName(v)
        S.ShowName = v
        if S.Enabled then ESP.refreshAll() end
    end

    function ESP.setShowDistance(v)
        S.ShowDistance = v
        if S.Enabled then ESP.refreshAll() end
    end

    function ESP.setShowWeapon(v)
        S.ShowWeapon = v
        if S.Enabled then ESP.refreshAll() end
    end

    function ESP.setMaxDistance(v)
        S.MaxNameDistance = v
        if not CharacterMeshes then return end
        for _, model in ipairs(CharacterMeshes:GetChildren()) do
            local bb = model:FindFirstChild(NAMETAG_NAME)
            if bb and bb:IsA("BillboardGui") then
                bb.MaxDistance = v
            end
        end
    end

    function ESP.setFillTransparency(v)
        S.FillTransparency = v
        if S.Enabled then ESP.refreshAll() end
    end

    function ESP.setOutlineTransparency(v)
        S.OutlineTransparency = v
        if S.Enabled then ESP.refreshAll() end
    end

    function ESP.setEnemyNameColor(c)
        S.EnemyNameColor = c
        if S.Enabled then ESP.refreshAll() end
    end

    function ESP.setAllyNameColor(c)
        S.AllyNameColor = c
        if S.Enabled then ESP.refreshAll() end
    end

    -- ── Auto-detection listeners ──────────────────────────────────

    -- ChildAdded: new model appears in CharacterMeshes
    if CharacterMeshes then
        State:Track(CharacterMeshes.ChildAdded:Connect(function(child)
            if not child:IsA("Model") then return end
            -- Wait for MeshParts to fully replicate before applying
            task.delay(0.15, function()
                if child and child.Parent and S.Enabled then
                    ESP.applyToMesh(child)
                end
            end)
        end))

        -- ChildRemoved: model removed (player died/left) → clean up
        State:Track(CharacterMeshes.ChildRemoved:Connect(function(child)
            -- Remove any highlight/nametag that got orphaned
            removeHighlight(child)
            removeNameTag(child)
        end))
    end

    -- Periodic scan: catches models that ChildAdded may have missed
    -- (e.g. re-entering a match, map transition, late replication)
    local scanConn
    scanConn = RunService.Heartbeat:Connect(function()
        -- Run every 3 seconds using tick()
    end)
    -- Replace with a proper interval scanner
    if scanConn then scanConn:Disconnect() end

    local lastScanTime = 0
    State:Track(RunService.Heartbeat:Connect(function()
        if not S.Enabled then return end
        local now = tick()
        if now - lastScanTime < 3 then return end
        lastScanTime = now
        ESP.refreshAll()
    end))

    -- Players.PlayerAdded: hook team change + initial apply
    State:Track(Players.PlayerAdded:Connect(function(player)
        State:InvalidateTeamCache()
        task.delay(2.5, function()
            if player and player.Parent and S.Enabled then
                ESP.applyToPlayer(player)
            end
        end)
        State:Track(player:GetPropertyChangedSignal("Team"):Connect(function()
            State:InvalidateTeamCache()
            if S.Enabled then
                task.delay(0.1, function()
                    if player and player.Parent then
                        ESP.applyToPlayer(player)
                    end
                end)
            end
        end))
    end))

    -- Name tag live updater (Heartbeat, only when ShowName on)
    local nameTagConn = nil

    local function startNameTagUpdater()
        if nameTagConn then return end
        nameTagConn = RunService.Heartbeat:Connect(function()
            if not S.Enabled or not S.ShowName then return end
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

    local _origSetShowName = ESP.setShowName
    function ESP.setShowName(v)
        S.ShowName = v
        if v then
            startNameTagUpdater()
        else
            if nameTagConn then
                nameTagConn:Disconnect()
                nameTagConn = nil
            end
        end
        if S.Enabled then ESP.refreshAll() end
    end

    return ESP
end