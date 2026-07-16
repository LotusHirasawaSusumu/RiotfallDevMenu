--[[
    Camera.lua
    Custom FOV management.
    Maintains FOV every frame since the game uses Scriptable camera
    and may reset FieldOfView.
]]

local Services  = require("core/Services")
local Config    = require("core/Config")

local CameraSystem  = {}
local CFG           = Config.Camera

function CameraSystem.apply()
    if CFG.FOVEnabled then
        Services.Camera.FieldOfView = CFG.FOVValue
    else
        Services.Camera.FieldOfView = CFG.DefaultFOV
    end
end

-- Called every frame — only writes if value drifted
function CameraSystem.step()
    if CFG.FOVEnabled then
        if Services.Camera.FieldOfView ~= CFG.FOVValue then
            Services.Camera.FieldOfView = CFG.FOVValue
        end
    end
end

function CameraSystem.enable(fovValue)
    if fovValue then CFG.FOVValue = fovValue end
    CFG.FOVEnabled = true
    CameraSystem.apply()
end

function CameraSystem.disable()
    CFG.FOVEnabled = false
    CameraSystem.apply()
end

return CameraSystem