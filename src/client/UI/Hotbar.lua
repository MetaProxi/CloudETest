
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Packages = ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local RoactRodux = require(Packages.RoactRodux)

local hotBar = Roact.Component:extend("Hotbar")

function hotBar:init()
    self:setState({
        hotbar = {}
    })
end

function hotBar:render()

    local props = self.props
    local size = props.Size or UDim2.new(0,100,0,100)
    local position = props.Position or UDim2.new(0,0,0,0)
    local anchorPoint = props.AnchorPoint or Vector2.new(0,0)

    return Roact.createElement("Frame",{
            Size = size,
            Position = position,
            AnchorPoint = anchorPoint,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.4
        }, {
            Roact.createElement("UIListLayout",{
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0,0),
            }),
            Roact.createElement("UICorner",{
                CornerRadius = UDim.new(0,5),
            }),
            Roact.createElement("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,Color3.fromRGB(132, 240, 177)),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(0, 255, 255)),
                }),
                Rotation = 90,
            })
        }
    )
end

return hotBar