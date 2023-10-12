
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Component
local Component = require(ReplicatedStorage.Packages.Component)

local Hidden = Component.new({
    Tag = "Hidden";
})

function Hidden:Start()
    self.InitialTransparency = self.Instance.Transparency
    self.Instance.Transparency = 1
end

function Hidden:Stop()
    self.Instance.Transparency = self.InitialTransparency
end

return Hidden