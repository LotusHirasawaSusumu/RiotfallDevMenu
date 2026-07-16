--[[
    State.lua
    Shared runtime state across all modules.
    All systems READ and WRITE to this table.
]]

local State = {
    -- Player / team
    LocalTeamName   = "",

    -- Health (updated by Events.lua)
    CurrentHP       = 100,
    MaxHP           = 100,

    -- Ammo (updated by Events.lua)
    CurrentAmmo     = "?/?",

    -- Aimbot
    AimbotLocked    = nil,      -- current target BasePart or nil

    -- UI
    MenuVisible     = true,
    Minimized       = false,
    ActiveTab       = "ESP",

    -- Connections (stored for cleanup on close)
    Connections     = {},
}

-- Helper: register a connection for cleanup
function State:Track(conn)
    table.insert(self.Connections, conn)
    return conn
end

-- Helper: disconnect all tracked connections
function State:Cleanup()
    for _, conn in ipairs(self.Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    self.Connections = {}
end

return State