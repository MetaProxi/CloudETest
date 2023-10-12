
--API Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- Components
local Statbar = require(script.Parent.Statbar)

local Stats = Roact.Component:extend("Stats")

function Stats:init()
    self:setState({
        Hunger = 100,
    })

    self.styles,self.springApi = RoactSpring.Controller.new({
        position = UDim2.new(0.5,0,1.3,0),
    })

end

function Stats:render()

    --Cool hover in animation
    self.springApi:start({
        position = self.props.Position or UDim2.new(0.5,0,0.5,0)
    })

    return Roact.createElement("Frame", {
        Size = UDim2.new(0.5,0,0.05,0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AnchorPoint = self.props.AnchorPoint,
        Position = self.styles.position
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0,10),
        }),
        HungerBar = Roact.createElement(Statbar,{
            Stat = "Hunger",
            Size = UDim2.new(0.3,0,0,30),
        })
    })

end

return Stats
