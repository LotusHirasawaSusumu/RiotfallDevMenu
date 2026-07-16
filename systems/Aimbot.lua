-- systems/Aimbot.lua
--[[
    Aimbot v2.3
    - Primary targeting: CharacterCollisions animated bone MeshParts
    - Fallback: Characters static Top/Center/Bottom parts
    - Velocity prediction: samples position delta over two frames
    - Raycast filter: built once, reused, rebuilt only on demand
    - FOV stored internally, exposed via getFOV()
]]

return function(Services, Config, State)
    local Players           = Services.Players
    local LP                = Services.LP
    local Camera            = Services.Camera
    local Workspace         = Services.Workspace
    local UIS               = Services.UserInputService
    local CharCollisions    = Services.CharacterCollisions
    local Characters        = Services.Characters

    local AimbotSettings = {
        Enabled    = false,
        EnemyOnly  = true,
        VisCheck   = true,
        FOVRadius  = Config.Aimbot.FOVRadius,
        Smoothing  = Config.Aimbot.Smoothing,
        BoneName   = Config.Aimbot.DefaultBone,   -- "Head"|"Chest"|"Pelvis"|"Legs"
    }

    -- ── Raycast filter (lazy rebuild) ─────────────────────────────
    local RCP = RaycastParams.new()
    RCP.FilterType = Enum.RaycastFilterType.Exclude
    local rcpDirty = true   -- rebuild on next use

    local function markRCPDirty() rcpDirty = true end

    local function getRCP()
        if not rcpDirty then return RCP end
        local ex = {}
        local lc = LP.Character
        if lc then table.insert(ex, lc) end
        if CharCollisions then table.insert(ex, CharCollisions) end
        if Services.CharacterMeshes then table.insert(ex, Services.CharacterMeshes) end
        RCP.FilterDescendantsInstances = ex
        rcpDirty = false
        return RCP
    end

    -- Rebuild when local character changes
    local function watchCharacter()
        State:Track(LP.CharacterAdded:Connect(function()
            markRCPDirty()
        end))
    end
    watchCharacter()

    -- ── Visibility check ──────────────────────────────────────────
    local function isVisible(pos)
        local origin = Camera.CFrame.Position
        local dir    = pos - origin
        local result = Workspace:Raycast(origin, dir, getRCP())
        if not result then return true end
        -- Hit something inside Characters folder = target's own hitbox part = visible
        return Characters and result.Instance:IsDescendantOf(Characters)
    end

    -- ── Bone resolution ───────────────────────────────────────────
    -- Returns world Position of the best available bone for the given config

    local function resolveTargetPart(player)
        local boneCfg = Config.Aimbot.Bones[AimbotSettings.BoneName]
        if not boneCfg then
            boneCfg = Config.Aimbot.Bones["Head"]
        end

        -- 1. Try CharacterCollisions animated bones (follows skeleton animation)
        if CharCollisions then
            local collModel = CharCollisions:FindFirstChild(player.Name)
            if collModel then
                for _, boneName in ipairs(boneCfg.collision) do
                    local part = collModel:FindFirstChild(boneName)
                    if part then return part, boneCfg.predictScale end
                end
            end
        end

        -- 2. Fallback: Characters static parts
        if Characters then
            local charModel = Characters:FindFirstChild(player.Name)
            if charModel then
                local part = charModel:FindFirstChild(boneCfg.fallback)
                if part then return part, boneCfg.predictScale * 0.5 end
            end
        end

        return nil, 0
    end

    -- ── Velocity prediction ───────────────────────────────────────
    -- Stores previous position per player to estimate velocity
    local prevPositions = {}   -- [userId] = { pos = Vector3, t = tick() }

    local function getPredictedPosition(player, part, predictScale)
        local ok, curPos = pcall(function() return part.Position end)
        if not ok then return nil end

        local uid  = player.UserId
        local now  = tick()
        local prev = prevPositions[uid]

        prevPositions[uid] = { pos = curPos, t = now }

        if not prev then return curPos end

        local dt = now - prev.t
        if dt <= 0 or dt > 0.5 then return curPos end  -- stale, don't predict

        local velocity = (curPos - prev.pos) / dt
        -- Predict predictScale seconds ahead (tuned per bone)
        return curPos + velocity * predictScale
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
        local bestPos  = nil

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            if AimbotSettings.EnemyOnly and not State:IsEnemy(player) then continue end

            local part, predictScale = resolveTargetPart(player)
            if not part then continue end

            local predictedPos = getPredictedPosition(player, part, predictScale)
            if not predictedPos then continue end

            if AimbotSettings.VisCheck and not isVisible(predictedPos) then continue end

            local screenPos, onScreen = worldToScreen(predictedPos)
            if not onScreen then continue end

            local dist = (screenPos - center).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestPos  = predictedPos
            end
        end

        return bestPos
    end

    -- ── Step (called every RenderStepped) ─────────────────────────
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

        local targetPos = findBestTarget()
        State.AimbotLocked = targetPos

        if not targetPos then return end

        local screenPos, onScreen = worldToScreen(targetPos)
        if not onScreen then return end

        local center = Camera.ViewportSize / 2
        local delta  = (screenPos - center) * (1 - AimbotSettings.Smoothing)

        if mousemoverel then
            mousemoverel(delta.X, delta.Y)
        end
    end

    function Aimbot.getFOV()      return AimbotSettings.FOVRadius end
    function Aimbot.setEnabled(v) AimbotSettings.Enabled   = v;  markRCPDirty() end
    function Aimbot.setEnemyOnly(v) AimbotSettings.EnemyOnly = v end
    function Aimbot.setVisCheck(v)  AimbotSettings.VisCheck  = v end
    function Aimbot.setFOV(v)       AimbotSettings.FOVRadius = v end
    function Aimbot.setSmoothing(v) AimbotSettings.Smoothing = v end
    function Aimbot.setBone(v)      AimbotSettings.BoneName  = v end

    return Aimbot
end