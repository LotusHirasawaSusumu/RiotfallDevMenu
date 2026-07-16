-- systems/Aimbot.lua
--[[
    Aimbot v2.4
    Fixes:
    - FOV: read directly from AimbotSettings.FOVRadius (not a stale copy)
      AND AimbotTab calls Aimbot.setFOV(Options.AimbotFOV.Value) immediately on load
    - Bounce fix: only call mousemoverel when delta.Magnitude > MinDeltaMagnitude
      so sub-pixel corrections don't cause snap-back when target is lost
    - Raycast filter lazy-rebuild via dirty flag
    - Velocity prediction preserved
]]

return function(Services, Config, State)
    local Players        = Services.Players
    local LP             = Services.LP
    local Camera         = Services.Camera
    local Workspace      = Services.Workspace
    local UIS            = Services.UserInputService
    local CharCollisions = Services.CharacterCollisions
    local Characters     = Services.Characters

    -- Single source of truth for all aimbot settings
    -- UI MUST call setters to write here; never read Config directly at runtime
    local S = {
        Enabled    = false,
        EnemyOnly  = true,
        VisCheck   = true,
        FOVRadius  = Config.Aimbot.FOVRadius,
        Smoothing  = Config.Aimbot.Smoothing,
        BoneName   = Config.Aimbot.DefaultBone,
    }

    -- ── Raycast filter ────────────────────────────────────────────
    local RCP = RaycastParams.new()
    RCP.FilterType = Enum.RaycastFilterType.Exclude
    local rcpDirty = true

    local function markRCPDirty() rcpDirty = true end

    local function getRCP()
        if not rcpDirty then return RCP end
        local ex = {}
        local lc = LP.Character
        if lc then table.insert(ex, lc) end
        if CharCollisions          then table.insert(ex, CharCollisions) end
        if Services.CharacterMeshes then table.insert(ex, Services.CharacterMeshes) end
        RCP.FilterDescendantsInstances = ex
        rcpDirty = false
        return RCP
    end

    State:Track(LP.CharacterAdded:Connect(markRCPDirty))

    -- ── Visibility ────────────────────────────────────────────────
    local function isVisible(pos)
        local origin = Camera.CFrame.Position
        local dir    = pos - origin
        local result = Workspace:Raycast(origin, dir, getRCP())
        if not result then return true end
        return Characters and result.Instance:IsDescendantOf(Characters)
    end

    -- ── Bone resolution ───────────────────────────────────────────
    local function resolveTargetPos(player)
        local boneCfg = Config.Aimbot.Bones[S.BoneName]
            or Config.Aimbot.Bones["Head"]

        -- Primary: animated collision bones
        if CharCollisions then
            local model = CharCollisions:FindFirstChild(player.Name)
            if model then
                for _, boneName in ipairs(boneCfg.collision) do
                    local part = model:FindFirstChild(boneName)
                    if part then
                        local ok, pos = pcall(function() return part.Position end)
                        if ok then return pos, boneCfg.predictScale end
                    end
                end
            end
        end

        -- Fallback: static Characters parts
        if Characters then
            local model = Characters:FindFirstChild(player.Name)
            if model then
                local part = model:FindFirstChild(boneCfg.fallback)
                if part then
                    local ok, pos = pcall(function() return part.Position end)
                    if ok then return pos, boneCfg.predictScale * 0.5 end
                end
            end
        end

        return nil, 0
    end

    -- ── Velocity prediction ───────────────────────────────────────
    local prevPos = {}   -- [userId] = { pos, t }

    local function predictedPos(player, rawPos, scale)
        local uid  = player.UserId
        local now  = tick()
        local prev = prevPos[uid]
        prevPos[uid] = { pos = rawPos, t = now }
        if not prev then return rawPos end
        local dt = now - prev.t
        if dt <= 0 or dt > 0.5 then return rawPos end
        local vel = (rawPos - prev.pos) / dt
        return rawPos + vel * scale
    end

    -- ── Screen helper ─────────────────────────────────────────────
    local function worldToScreen(pos)
        local ok, vp = pcall(function()
            return Camera:WorldToViewportPoint(pos)
        end)
        if not ok then return nil, false end
        return Vector2.new(vp.X, vp.Y), vp.Z > 0
    end

    -- ── Find best target ─────────────────────────────────────────
    -- Reads S.FOVRadius directly — always current, never stale
    local function findBestTarget()
        local center   = Camera.ViewportSize / 2
        local bestDist = S.FOVRadius          -- ← reads live value every call
        local bestPos  = nil

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            if S.EnemyOnly and not State:IsEnemy(player) then continue end

            local rawPos, scale = resolveTargetPos(player)
            if not rawPos then continue end

            local predPos = predictedPos(player, rawPos, scale)

            if S.VisCheck and not isVisible(predPos) then continue end

            local screenPos, onScreen = worldToScreen(predPos)
            if not onScreen then continue end

            local dist = (screenPos - center).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestPos  = predPos
            end
        end

        return bestPos
    end

    -- ── Step ──────────────────────────────────────────────────────
    local Aimbot = {}
    local MIN_DELTA = Config.Aimbot.MinDeltaMagnitude

    function Aimbot.step()
        if not S.Enabled then
            State.AimbotLocked = nil
            return
        end

        -- Only active while RMB held
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            State.AimbotLocked = nil
            return
        end

        local targetPos = findBestTarget()
        State.AimbotLocked = targetPos

        -- No target in FOV: do nothing (no mousemoverel call)
        -- This prevents the snap-back that occurs when mousemoverel(0,0) is called
        if not targetPos then return end

        local screenPos, onScreen = worldToScreen(targetPos)
        if not onScreen then return end

        local center = Camera.ViewportSize / 2
        local delta  = (screenPos - center) * (1 - S.Smoothing)

        -- Sub-pixel guard: don't move mouse for tiny corrections
        -- This prevents jitter/bounce on close targets and after kills
        if delta.Magnitude < MIN_DELTA then return end

        if mousemoverel then
            mousemoverel(delta.X, delta.Y)
        end
    end

    function Aimbot.getFOV()       return S.FOVRadius end

    -- All setters write to S immediately
    function Aimbot.setEnabled(v)  S.Enabled   = v ; markRCPDirty() end
    function Aimbot.setEnemyOnly(v) S.EnemyOnly = v end
    function Aimbot.setVisCheck(v)  S.VisCheck  = v end
    function Aimbot.setSmoothing(v) S.Smoothing = v end
    function Aimbot.setBone(v)      S.BoneName  = v end

    -- setFOV: the critical fix — writes to S.FOVRadius which findBestTarget reads live
    function Aimbot.setFOV(v)
        S.FOVRadius = v
    end

    return Aimbot
end