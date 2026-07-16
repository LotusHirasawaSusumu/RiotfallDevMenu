local State = {
    LocalTeamName = "",
    CurrentHP     = 100,
    MaxHP         = 100,
    CurrentAmmo   = "?/?",
    AimbotLocked  = nil,
    Connections   = {},
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

return State