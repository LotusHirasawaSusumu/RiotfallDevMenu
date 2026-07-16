return function(Services, Config, State)
    local Players        = Services.Players
    local LP             = Services.LP
    local Camera         = Services.Camera
    local Workspace      = Services.Workspace
    local UIS            = Services.UserInputService

    local AimbotSettings = {
        Enabled    = false,
        EnemyOnly  = true,
        FOVRadius  = Config.Aimbot.FOVRadius,
        Smoothing  = Config.Aimbot.Smoothing,
        TargetBone = Config.Aimbot.TargetBone,
        VisCheck   = Config.Aimbot.VisCheck,
    }

    -- ── Raycast filter (rebuilt each VisCheck call) ───────────────
    local RCP = RaycastParams.new()
    RCP.FilterType = Enum.RaycastFilterType.Exclude

    local function buildFilter()
        local ex = {}
        local lc = LP.Character
        if lc then table.insert(ex, lc) end
        local cm = Services.CharacterMeshes
        if cm then table.insert(ex, cm) end
        local cc = Workspace:FindFirstChild("CharacterCollisions")
        if cc then table.insert(ex, cc) end
        RCP.FilterDescendantsInstances = ex
    end

    local function isVisible(pos)
        buildFilter()
        local origin = Camera.CFrame.Position
        local dir    = pos - origin
        local result = Workspace:Raycast(origin, dir, RCP)
        if not result then return true end
        local charsFolder = Workspace:FindFirstChild(Config.Folders.Characters)
        return charsFolder and result.Instance:IsDescendantOf(charsFolder)
    end

    -- ── Target part ───────────────────────────────────────────────
    local function getTargetPart(player)
        local folder = Workspace:FindFirstChild(Config.Folders.Characters)
        if not folder then return nil end
        local model = folder:FindFirstChild(player.Name)
        if not model then return nil end
        return model:FindFirstChild(AimbotSettings.TargetBone)
    end

    -- ── Screen helpers ────────────────────────────────────────────
    local function worldToScreen(pos)
        local ok, vp = pcall(function()
            return Camera:WorldToViewportPoint(pos)
        end)
        if not ok then return nil, false end
        return Vector2.new(vp.X, vp.Y), vp.Z > 0
    end

    -- ── Find best target ─────────────────────────────────────────
    local function findBestTarget()
        local center   = Camera.ViewportSize / 2
        local bestDist = AimbotSettings.FOVRadius
        local bestPart = nil

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            if AimbotSettings.EnemyOnly and not Services.isEnemy(player) then continue end

            local part = getTargetPart(player)
            if not part then continue end

            local ok, pos = pcall(function() return part.Position end)
            if not ok then continue end

            if AimbotSettings.VisCheck and not isVisible(pos) then continue end

            local screenPos, onScreen = worldToScreen(pos)
            if not onScreen then continue end

            local dist = (screenPos - center).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestPart = part
            end
        end

        return bestPart
    end

    -- ── Public API ────────────────────────────────────────────────
    local Aimbot = {}

    function Aimbot.step()
        if not AimbotSettings.Enabled then
            State.AimbotLocked = nil
            return
        end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            State.AimbotLocked = nil
            return
        end

        local target = findBestTarget()
        State.AimbotLocked = target
        if not target then return end

        local ok, pos = pcall(function() return target.Position end)
        if not ok then return end

        local screenPos, onScreen = worldToScreen(pos)
        if not onScreen then return end

        local center = Camera.ViewportSize / 2
        local delta  = (screenPos - center) * (1 - AimbotSettings.Smoothing)

        if mousemoverel then
            mousemoverel(delta.X, delta.Y)
        end
    end

    function Aimbot.setEnabled(v)    AimbotSettings.Enabled    = v    end
    function Aimbot.setEnemyOnly(v)  AimbotSettings.EnemyOnly  = v    end
    function Aimbot.setVisCheck(v)   AimbotSettings.VisCheck   = v    end
    function Aimbot.setFOV(v)        AimbotSettings.FOVRadius  = v    end
    function Aimbot.setSmoothing(v)  AimbotSettings.Smoothing  = v    end
    function Aimbot.setBone(v)       AimbotSettings.TargetBone = v    end
    function Aimbot.getFOV()         return AimbotSettings.FOVRadius  end

    return Aimbot
end