-- core/State.lua
--[[
    State.lua
    - Team cache: refreshed on demand, not every frame
    - IsEnemy result cache: keyed by player UserId, invalidated on team change
]]

local State = {
    CurrentHP    = 100,
    MaxHP        = 100,
    CurrentAmmo  = "?/?",
    AimbotLocked = nil,
    Connections  = {},

    -- Internal caches
    _localTeamName  = "",
    _teamCacheValid = false,
    _enemyCache     = {},   -- [userId] = bool
}

function State:Track(c)
    table.insert(self.Connections, c)
    return c
end

function State:Cleanup()
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    self.Connections = {}
end

-- Call when team composition changes (PlayerAdded, PlayerRemoving, Team property change)
function State:InvalidateTeamCache()
    self._teamCacheValid = false
    self._enemyCache     = {}
end

-- Returns local team name, rebuilds cache if stale
function State:GetLocalTeam()
    if not self._teamCacheValid then
        local LP = game:GetService("Players").LocalPlayer
        local ok, t = pcall(function() return LP.Team end)
        self._localTeamName  = (ok and t) and t.Name or "NONE"
        self._teamCacheValid = true
    end
    return self._localTeamName
end

-- Returns cached isEnemy result for a player
function State:IsEnemy(player)
    local LP = game:GetService("Players").LocalPlayer
    if player == LP then return false end

    local uid = player.UserId
    if self._enemyCache[uid] ~= nil then
        return self._enemyCache[uid]
    end

    local ok1, lpTeam = pcall(function() return LP.Team end)
    local ok2, pTeam  = pcall(function() return player.Team end)
    local result = not (ok1 and ok2 and lpTeam == pTeam)
    self._enemyCache[uid] = result
    return result
end

return State