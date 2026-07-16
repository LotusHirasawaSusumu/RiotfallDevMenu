-- systems/Camera.lua
return function(Services, Config, _State)
    local Camera = Services.Camera
    local S = { Enabled = false, FOV = Config.Camera.DefaultFOV }
    local M = {}

    function M.step()
        if S.Enabled and Camera.FieldOfView ~= S.FOV then
            Camera.FieldOfView = S.FOV
        end
    end

    function M.setEnabled(v)
        S.Enabled = v
        if not v then Camera.FieldOfView = Config.Camera.DefaultFOV end
    end

    function M.setFOV(v)
        S.FOV = v
        if S.Enabled then Camera.FieldOfView = v end
    end

    function M.disable()
        S.Enabled = false
        Camera.FieldOfView = Config.Camera.DefaultFOV
    end

    return M
end