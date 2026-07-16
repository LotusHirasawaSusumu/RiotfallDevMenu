--[[
    ESP System
    - Adornee: Workspace.CharacterMeshes.<name>  (high-poly visual model)
    - Highlight parented inside the mesh model    (bypasses game monitoring)
    - DepthMode.AlwaysOnTop                       (sees through walls)
    - Optional BillboardGui name tags             (ShowName feature)
]]

return function(Services, Config, State)
    local Players         = Services.Players
    local LP              = Services.LP
    local CharacterMeshes = Services.CharacterMeshes

    local HIGHLIGHT_NAME  = "RealVisualChams"
    local NAMETAG_NAME    = "RFNameTag"

    local ESPSettings = {
        Enabled             = false,
        EnemiesOnly         = true,
        ShowName            = false,
        FillTransparency    = Config.ESP.FillTransparency,
        OutlineTransparency = Config.ESP.OutlineTransparency,
    }

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
    -- Parented to the RootPart inside CharacterMeshes.<name>
    -- so it follows the model in world space.

    local function getRootPart(meshModel)
        -- Confirmed from dump: CharacterMeshes.<name> has a child named "RootPart"
        return meshModel:FindFirstChild("RootPart")
    end

    local function removeNameTag(meshModel)
        local root = getRootPart(meshModel)
        if root then
            local tag = root:FindFirstChild(NAMETAG_NAME)
            if tag then tag:Destroy() end
        end
    end

    local function applyNameTag(meshModel, player, color)
        local root = getRootPart(meshModel)
        if not root then return end

        -- Remove existing
        local old = root:FindFirstChild(NAMETAG_NAME)
        if old then old:Destroy() end

        if not ESPSettings.ShowName then return end

        local bb = Instance.new("BillboardGui")
        bb.Name            = NAMETAG_NAME
        bb.Adornee         = root
        bb.Size            = UDim2.new(0, 100, 0, 22)
        bb.StudsOffset     = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop     = true
        bb.LightInfluence  = 0
        bb.ResetOnSpawn    = false
        bb.Parent          = root

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size                   = UDim2.new(1, 0, 1, 0)
        label.Text                   = player.Name
        label.TextColor3             = color
        label.TextSize               = Config.ESP.NameSize
        label.Font                   = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0.4
        label.TextStrokeColor3       = Color3.new(0, 0, 0)
        label.Parent                 = bb
    end

    -- ── Core apply ────────────────────────────────────────────────

    local ESP = {}

    function ESP.applyToMesh(meshModel)
        local player = Players:FindFirstChild(meshModel.Name)
        if not player or player == LP then return end

        if not ESPSettings.Enabled then
            removeHighlight(meshModel)
            removeNameTag(meshModel)
            return
        end

        local enemy = Services.isEnemy(player)

        if ESPSettings.EnemiesOnly and not enemy then
            removeHighlight(meshModel)
            removeNameTag(meshModel)
            return
        end

        local fillColor    = enemy and Config.ESP.EnemyFillColor    or Config.ESP.AllyFillColor
        local outlineColor = enemy and Config.ESP.EnemyOutlineColor  or Config.ESP.AllyOutlineColor

        local hl               = getOrCreateHighlight(meshModel)
        hl.FillColor           = fillColor
        hl.OutlineColor        = outlineColor
        hl.FillTransparency    = ESPSettings.FillTransparency
        hl.OutlineTransparency = ESPSettings.OutlineTransparency

        applyNameTag(meshModel, player, fillColor)
    end

    function ESP.refreshAll()
        if not CharacterMeshes then return end
        for _, model in ipairs(CharacterMeshes:GetChildren()) do
            if model:IsA("Model") then
                ESP.applyToMesh(model)
            end
        end
    end

    function ESP.removeAll()
        if not CharacterMeshes then return end
        for _, model in ipairs(CharacterMeshes:GetChildren()) do
            removeHighlight(model)
            removeNameTag(model)
        end
    end

    -- ── Setting setters (called by UI) ────────────────────────────

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

    function ESP.setFillTransparency(v)
        ESPSettings.FillTransparency = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    function ESP.setOutlineTransparency(v)
        ESPSettings.OutlineTransparency = v
        if ESPSettings.Enabled then ESP.refreshAll() end
    end

    -- ── Listeners ────────────────────────────────────────────────

    if CharacterMeshes then
        State:Track(CharacterMeshes.ChildAdded:Connect(function(child)
            if child:IsA("Model") then
                task.wait(0.1)
                if ESPSettings.Enabled then
                    ESP.applyToMesh(child)
                end
            end
        end))
    end

    for _, player in ipairs(Players:GetPlayers()) do
        State:Track(player:GetPropertyChangedSignal("Team"):Connect(function()
            if not CharacterMeshes then return end
            local mesh = CharacterMeshes:FindFirstChild(player.Name)
            if mesh and ESPSettings.Enabled then
                ESP.applyToMesh(mesh)
            end
        end))
    end

    return ESP
end