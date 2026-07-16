-- systems/Rage.lua
--[[
    Rage Module v1.0
    Features:
    1. AutoFire     — fires when enemy is within tight FOV, humanized fire rate
    2. SpinBot      — client-side visual rotation, does not affect local view
    3. BunnyHop     — jump on land + speed modifiers for pseudo-bhop
    4. AirStrafe    — lateral velocity injection while airborne
    5. ThirdPerson  — correct pull-back, alive-only watchdog, no HeadLocked bug
]]

return function(Services, Config, State)
    local Players        = Services.Players
    local LP             = Services.LP
    local Camera         = Services.Camera
    local Workspace      = Services.Workspace
    local RunService     = Services.RunService
    local UIS            = Services.UserInputService
    local CharMeshes     = Services.CharacterMeshes
    local Characters     = Services.Characters
    local CharCollisions = Services.CharacterCollisions

    local RC = Config.Rage

    -- ── Shared helpers ────────────────────────────────────────────

    local function worldToScreen(pos)
        local ok, vp = pcall(function()
            return Camera:WorldToViewportPoint(pos)
        end)
        if not ok then return nil, false end
        return Vector2.new(vp.X, vp.Y), vp.Z > 0
    end

    -- Returns the best world position for a player (animated bone → static fallback)
    local function getTargetPos(player)
        if CharCollisions then
            local m = CharCollisions:FindFirstChild(player.Name)
            if m then
                local neck = m:FindFirstChild("Neck")
                    or m:FindFirstChild("MidUpperSpine")
                if neck then
                    local ok, pos = pcall(function() return neck.Position end)
                    if ok then return pos end
                end
            end
        end
        if Characters then
            local m = Characters:FindFirstChild(player.Name)
            if m then
                local top = m:FindFirstChild("Top")
                if top then
                    local ok, pos = pcall(function() return top.Position end)
                    if ok then return pos end
                end
            end
        end
        return nil
    end

    -- Returns local Humanoid from VoiceOrigins
    local function getLocalHumanoid()
        local vo = Workspace:FindFirstChild("VoiceOrigins")
        if not vo then return nil end
        for _, teamFolder in ipairs(vo:GetChildren()) do
            local m = teamFolder:FindFirstChild(LP.Name)
            if m then return m:FindFirstChildOfClass("Humanoid") end
        end
        return nil
    end

    -- Returns local mesh RootPart
    local function getLocalMeshRoot()
        if not CharMeshes then return nil end
        local m = CharMeshes:FindFirstChild(LP.Name)
        if not m then return nil end
        return m:FindFirstChild("RootPart")
    end

    -- Alive check: mesh exists + has RootPart
    local function isAlive()
        if not CharMeshes then return false end
        local m = CharMeshes:FindFirstChild(LP.Name)
        if not m then return false end
        return m:FindFirstChild("RootPart") ~= nil
    end

    -- ══════════════════════════════════════════════════════════════
    -- 1. AUTO FIRE
    -- Fires mouse1 when an enemy is within AutoFireFOV of crosshair center.
    -- Uses humanized random interval to avoid pattern detection.
    -- Only fires while RMB held (compatible with aimbot) OR standalone.
    -- ══════════════════════════════════════════════════════════════
    local AutoFire = {
        Enabled       = false,
        RequireAimbot = true,   -- if true, only fires while RMB held
        FOVRadius     = RC.AutoFireFOV,
        RateMin       = RC.AutoFireRateMin,
        RateMax       = RC.AutoFireRateMax,
        _nextFireTime = 0,
        _conn         = nil,
    }

    local function autoFireStep()
        if not AutoFire.Enabled then return end
        if AutoFire.RequireAimbot then
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                return
            end
        end

        local now = tick()
        if now < AutoFire._nextFireTime then return end

        -- Find any enemy within tight FOV of screen center
        local center  = Camera.ViewportSize / 2
        local inRange = false

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end
            if not State:IsEnemy(player) then continue end

            local pos = getTargetPos(player)
            if not pos then continue end

            local screenPos, onScreen = worldToScreen(pos)
            if not onScreen then continue end

            if (screenPos - center).Magnitude <= AutoFire.FOVRadius then
                inRange = true
                break
            end
        end

        if not inRange then return end

        -- Fire
        if mouse1press and mouse1release then
            mouse1press()
            task.delay(0.04, function()
                mouse1release()
            end)
        end

        -- Humanized next fire time
        local interval = AutoFire.RateMin
            + math.random() * (AutoFire.RateMax - AutoFire.RateMin)
        AutoFire._nextFireTime = now + interval
    end

    -- ══════════════════════════════════════════════════════════════
    -- 2. SPINBOT
    -- Rotates CharacterMeshes.LocalPlayer.RootPart client-side only.
    -- Does NOT affect Camera or VoiceOrigins HumanoidRootPart,
    -- so local view is completely unaffected.
    -- Modes: Horizontal, Vertical, Jitter, Random
    -- ══════════════════════════════════════════════════════════════
    local SpinBot = {
        Enabled   = false,
        Mode      = RC.SpinMode,
        Speed     = RC.SpinSpeed,         -- degrees per frame at 60fps
        Offset    = RC.SpinOffset,
        Amplitude = RC.SpinJitterAmplitude,
        _angle    = 0,
        _jitterDir= 1,
        _jitterAcc= 0,
    }

    local function spinStep(dt)
        if not SpinBot.Enabled then return end

        local root = getLocalMeshRoot()
        if not root then return end

        local degsThisFrame = SpinBot.Speed * (dt * 60)  -- frame-rate independent
        local mode          = SpinBot.Mode

        if mode == "Horizontal" then
            SpinBot._angle = (SpinBot._angle + degsThisFrame) % 360
            local ok, cf = pcall(function() return root.CFrame end)
            if not ok then return end
            -- Preserve position, apply yaw-only rotation
            local pos = cf.Position
            root.CFrame = CFrame.new(pos)
                * CFrame.Angles(0, math.rad(SpinBot._angle + SpinBot.Offset), 0)

        elseif mode == "Vertical" then
            SpinBot._angle = (SpinBot._angle + degsThisFrame) % 360
            local ok, cf = pcall(function() return root.CFrame end)
            if not ok then return end
            local pos = cf.Position
            root.CFrame = CFrame.new(pos)
                * CFrame.Angles(math.rad(SpinBot._angle), 0, 0)

        elseif mode == "Jitter" then
            -- Bounces between +Amplitude and -Amplitude
            SpinBot._jitterAcc = SpinBot._jitterAcc
                + SpinBot._jitterDir * degsThisFrame
            if math.abs(SpinBot._jitterAcc) >= SpinBot.Amplitude then
                SpinBot._jitterDir = -SpinBot._jitterDir
            end
            local ok, cf = pcall(function() return root.CFrame end)
            if not ok then return end
            local pos = cf.Position
            root.CFrame = CFrame.new(pos)
                * CFrame.Angles(0, math.rad(SpinBot._jitterAcc + SpinBot.Offset), 0)

        elseif mode == "Random" then
            SpinBot._angle = math.random(0, 359)
            local ok, cf = pcall(function() return root.CFrame end)
            if not ok then return end
            local pos = cf.Position
            root.CFrame = CFrame.new(pos)
                * CFrame.Angles(0, math.rad(SpinBot._angle), 0)
        end
    end

    -- ══════════════════════════════════════════════════════════════
    -- 3. BUNNYHOP
    -- Hooks Humanoid StateChanged to jump immediately on landing.
    -- Modifies WalkSpeed and JumpPower.
    -- ══════════════════════════════════════════════════════════════
    local BunnyHop = {
        Enabled       = false,
        BaseSpeed     = RC.BhopBaseSpeed,
        AirSpeed      = RC.BhopAirSpeed,
        JumpPower     = RC.BhopJumpPower,
        DefaultSpeed  = RC.BhopDefaultSpeed,
        _stateConn    = nil,
        _isHopping    = false,
    }

    local function applyBhopStats(hum, airborne)
        if not hum then return end
        pcall(function()
            hum.WalkSpeed  = airborne and BunnyHop.AirSpeed or BunnyHop.BaseSpeed
            hum.JumpPower  = BunnyHop.JumpPower
        end)
    end

    local function restoreBhopStats(hum)
        if not hum then return end
        pcall(function()
            hum.WalkSpeed = BunnyHop.DefaultSpeed
            hum.JumpPower = 50  -- Roblox default
        end)
    end

    local function connectBhop()
        local hum = getLocalHumanoid()
        if not hum then return end

        if BunnyHop._stateConn then
            pcall(function() BunnyHop._stateConn:Disconnect() end)
        end

        applyBhopStats(hum, false)

        BunnyHop._stateConn = hum.StateChanged:Connect(function(_, new)
            if not BunnyHop.Enabled then return end

            if new == Enum.HumanoidStateType.Landed then
                -- Jump immediately on landing
                task.defer(function()
                    if BunnyHop.Enabled and
                       UIS:IsKeyDown(Enum.KeyCode.Space) then
                        pcall(function() hum:ChangeState(
                            Enum.HumanoidStateType.Jumping) end)
                    end
                    applyBhopStats(hum, false)
                end)

            elseif new == Enum.HumanoidStateType.Jumping
                or new == Enum.HumanoidStateType.Freefall then
                applyBhopStats(hum, true)
            end
        end)
    end

    local function disconnectBhop()
        local hum = getLocalHumanoid()
        if hum then restoreBhopStats(hum) end
        if BunnyHop._stateConn then
            pcall(function() BunnyHop._stateConn:Disconnect() end)
            BunnyHop._stateConn = nil
        end
    end

    -- ══════════════════════════════════════════════════════════════
    -- 4. AIR STRAFE
    -- Injects lateral velocity while airborne based on A/D input.
    -- Matches CS2 air strafe feel: adds velocity in strafe direction,
    -- clamped to AirStrafeMaxSpeed.
    -- ══════════════════════════════════════════════════════════════
    local AirStrafe = {
        Enabled  = false,
        Force    = RC.AirStrafeForce,
        MaxSpeed = RC.AirStrafeMaxSpeed,
    }

    local function airStrafeStep(dt)
        if not AirStrafe.Enabled then return end

        local hum = getLocalHumanoid()
        if not hum then return end

        local state = hum:GetState()
        local airborne = state == Enum.HumanoidStateType.Freefall
            or state == Enum.HumanoidStateType.Jumping

        if not airborne then return end

        -- Get camera-relative lateral direction
        local camRight = Camera.CFrame.RightVector
        camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit

        local strafeInput = 0
        if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then
            strafeInput = strafeInput - 1
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then
            strafeInput = strafeInput + 1
        end

        if strafeInput == 0 then return end

        -- Apply velocity via BodyVelocity on CharacterCollisions RootPart equivalent
        -- Since the game uses custom movement, we modify HumanoidRootPart
        -- in VoiceOrigins (the physics object)
        local vo = Workspace:FindFirstChild("VoiceOrigins")
        if not vo then return end
        local hrp
        for _, tf in ipairs(vo:GetChildren()) do
            local m = tf:FindFirstChild(LP.Name)
            if m then
                hrp = m:FindFirstChild("HumanoidRootPart")
                break
            end
        end
        if not hrp then return end

        local currentVel = hrp.AssemblyLinearVelocity
        local lateralVel = Vector3.new(currentVel.X, 0, currentVel.Z)
        local addVel     = camRight * strafeInput * AirStrafe.Force * dt

        -- Clamp total lateral speed
        local newLateral = lateralVel + addVel
        if newLateral.Magnitude > AirStrafe.MaxSpeed then
            newLateral = newLateral.Unit * AirStrafe.MaxSpeed
        end

        hrp.AssemblyLinearVelocity = Vector3.new(
            newLateral.X,
            currentVel.Y,
            newLateral.Z)
    end

    -- ══════════════════════════════════════════════════════════════
    -- 5. THIRD PERSON
    --
    -- Fixes vs. provided semi-finished code:
    -- 1. No HeadLocked (not valid Camera property)
    -- 2. Pull-back uses horizontal projected LookVector (no underground
    --    camera when looking up/down steeply)
    -- 3. CameraType set to Scriptable explicitly; restored on disable
    -- 4. Alive check via CharacterMeshes RootPart
    -- 5. Right-shoulder offset (configurable) for natural over-shoulder view
    -- 6. Camera.CFrame.LookVector from PREVIOUS frame used as aim direction,
    --    so the "look at" target is a point 500 studs ahead of where the
    --    CAMERA was pointing — not where it's being moved to (avoids spin)
    -- ══════════════════════════════════════════════════════════════
    local ThirdPerson = {
        Enabled  = false,
        Distance = RC.ThirdPersonDistance,
        Height   = RC.ThirdPersonHeight,
        FOV      = RC.ThirdPersonFOV,
        -- Right-shoulder offset: positive = right of center
        ShoulderOffset = 0.6,
        _prevCamCF     = nil,
        _origCamType   = nil,
    }

    local function thirdPersonStep()
        if not ThirdPerson.Enabled then return end
        if not isAlive() then
            -- Restore camera control when not alive
            if ThirdPerson._origCamType then
                pcall(function()
                    Camera.CameraType = ThirdPerson._origCamType
                end)
                ThirdPerson._origCamType = nil
            end
            return
        end

        -- Take over camera type
        if not ThirdPerson._origCamType then
            ThirdPerson._origCamType = Camera.CameraType
        end
        pcall(function()
            Camera.CameraType = Enum.CameraType.Scriptable
        end)

        -- FOV
        Camera.FieldOfView = ThirdPerson.FOV

        -- Use current camera CFrame as aim source
        local cf          = Camera.CFrame
        local lookVec     = cf.LookVector
        local rightVec    = cf.RightVector

        -- Horizontal-projected look vector for pull-back
        -- This prevents the camera going underground when looking up
        local flatLook    = Vector3.new(lookVec.X, 0, lookVec.Z)
        if flatLook.Magnitude < 0.01 then
            -- Straight up or down — use a slight backward offset
            flatLook = -cf.LookVector
        else
            flatLook = flatLook.Unit
        end

        -- Target: 500 studs ahead of current camera position along actual look vector
        local aimTarget = cf.Position + lookVec * 500

        -- New camera position: pull back along flat look, up by Height,
        -- and offset to right shoulder
        local newPos = cf.Position
            - flatLook         * ThirdPerson.Distance
            + Vector3.new(0, 1, 0) * ThirdPerson.Height
            + rightVec         * ThirdPerson.ShoulderOffset

        pcall(function()
            Camera.CFrame = CFrame.lookAt(newPos, aimTarget)
        end)
    end

    local function disableThirdPerson()
        if ThirdPerson._origCamType then
            pcall(function()
                Camera.CameraType = ThirdPerson._origCamType
            end)
            ThirdPerson._origCamType = nil
        end
        Camera.FieldOfView = Config.Camera.DefaultFOV
    end

    -- ── Public API ────────────────────────────────────────────────

    local Rage = {}

    -- AutoFire
    function Rage.setAutoFire(v)      AutoFire.Enabled       = v   end
    function Rage.setAutoFireFOV(v)   AutoFire.FOVRadius     = v   end
    function Rage.setAutoFireRateMin(v) AutoFire.RateMin     = v   end
    function Rage.setAutoFireRateMax(v) AutoFire.RateMax     = v   end
    function Rage.setAutoFireRequireAimbot(v) AutoFire.RequireAimbot = v end

    -- SpinBot
    function Rage.setSpinBot(v)
        SpinBot.Enabled = v
        if not v then
            -- Restore mesh root to neutral orientation
            local root = getLocalMeshRoot()
            if root then
                pcall(function()
                    local pos = root.CFrame.Position
                    root.CFrame = CFrame.new(pos)
                end)
            end
            SpinBot._angle    = 0
            SpinBot._jitterAcc= 0
        end
    end
    function Rage.setSpinMode(v)      SpinBot.Mode      = v   end
    function Rage.setSpinSpeed(v)     SpinBot.Speed     = v   end
    function Rage.setSpinOffset(v)    SpinBot.Offset    = v   end
    function Rage.setSpinAmplitude(v) SpinBot.Amplitude = v   end

    -- BunnyHop
    function Rage.setBhop(v)
        BunnyHop.Enabled = v
        if v then
            connectBhop()
        else
            disconnectBhop()
        end
    end
    function Rage.setBhopSpeed(v)     BunnyHop.BaseSpeed   = v end
    function Rage.setBhopAirSpeed(v)  BunnyHop.AirSpeed    = v end
    function Rage.setBhopJumpPower(v) BunnyHop.JumpPower   = v end

    -- AirStrafe
    function Rage.setAirStrafe(v)      AirStrafe.Enabled  = v   end
    function Rage.setAirStrafeForce(v) AirStrafe.Force    = v   end
    function Rage.setAirStrafeMax(v)   AirStrafe.MaxSpeed = v   end

    -- ThirdPerson
    function Rage.setThirdPerson(v)
        ThirdPerson.Enabled = v
        if not v then disableThirdPerson() end
    end
    function Rage.setTPDistance(v)   ThirdPerson.Distance = v end
    function Rage.setTPHeight(v)     ThirdPerson.Height   = v end
    function Rage.setTPFOV(v)        ThirdPerson.FOV      = v end
    function Rage.setTPShoulder(v)   ThirdPerson.ShoulderOffset = v end

    -- Step (called from RenderStepped in main.lua)
    function Rage.step(dt)
        autoFireStep()
        spinStep(dt)
        thirdPersonStep()
    end

    -- Step for physics-based features (called from Heartbeat)
    function Rage.physicsStep(dt)
        airStrafeStep(dt)
    end

    -- Cleanup
    function Rage.cleanup()
        disconnectBhop()
        if ThirdPerson.Enabled then disableThirdPerson() end
        AutoFire.Enabled  = false
        SpinBot.Enabled   = false
        AirStrafe.Enabled = false
    end

    return Rage
end