
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Component
local Component = require(ReplicatedStorage.Packages.Component)

local Hover = Component.new({
    Tag = "Hover";
})

function Hover:Start()
    self.BaseHeight = self.Instance.Position.Y
end

function Hover:HeartbeatUpdate(deltaTime)
    local part:BasePart = self.Instance
    
    local heightDifference = self.BaseHeight - part.Position.Y

    local yOffset = math.cos(os.clock()) * 0.4

    part.CFrame = part.CFrame * CFrame.new(0,yOffset + heightDifference,0) * CFrame.Angles(0,math.rad(90 * deltaTime),0)
end

return Hover