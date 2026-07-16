return function(Services, Config, _State)
    local Camera = Services.Camera

    local CamSettings = {
        Enabled = false,
        FOV     = Config.Camera.DefaultFOV,
    }

    local CamSys = {}

    function CamSys.step()
        if CamSettings.Enabled and Camera.FieldOfView ~= CamSettings.FOV then
            Camera.FieldOfView = CamSettings.FOV
        end
    end

    function CamSys.setEnabled(v)
        CamSettings.Enabled = v
        if not v then Camera.FieldOfView = Config.Camera.DefaultFOV end
    end

    function CamSys.setFOV(v)
        CamSettings.FOV = v
        if CamSettings.Enabled then Camera.FieldOfView = v end
    end

    function CamSys.disable()
        CamSettings.Enabled    = false
        Camera.FieldOfView     = Config.Camera.DefaultFOV
    end

    return CamSys
end