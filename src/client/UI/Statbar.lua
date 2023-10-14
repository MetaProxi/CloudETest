
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local StatBar = Roact.Component:extend("StatBar")

function StatBar:init()
    self:setState({
        value = 45,
        maxValue = 100,
        hovered = false,
    })

    self.styles,self.springApi = RoactSpring.Controller.new({
        percentage = 0.1,
        config = {mass = 0.4,tension = 300} -- Low mass to keep the animation snappy
    })

end

function StatBar:render()
    local value = self.props.value or 0
    local maxValue = self.state.maxValue

    local percentage = value / maxValue

    local displayText = self.state.hovered and string.format("%.1f/%s",value,maxValue) or self.props.Stat

    local color = self.props.Color or Color3.fromRGB(145, 99, 0)
    local fillColor = self.props.FillColor or Color3.fromRGB(221, 159, 25)
    local strokeColor = self.props.StrokeColor or Color3.fromRGB(235, 210, 179)
    local textStrokeColor = self.props.TextStrokeColor or Color3.fromRGB(95, 59, 0)

    textStrokeColor = string.format("rgb(%d,%d,%d)",textStrokeColor.R,textStrokeColor.G,textStrokeColor.B)

    self.springApi:start({
        percentage = percentage
    })

    return Roact.createElement("Frame", {
        Size = self.props.Size,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        AnchorPoint = self.props.AnchorPoint,
    }, {

        gradientOverlay = Roact.createElement("Frame",{
            Size = UDim2.new(1,0,1,0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.5,
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            ZIndex = 3,
        },{
            UIGradient = Roact.createElement("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,0.1),
                    NumberSequenceKeypoint.new(0.3,0.4),
                    NumberSequenceKeypoint.new(0.7,0.6),
                    NumberSequenceKeypoint.new(1,0.3),
                }),
                Rotation = 90,
            })
        }),

        StatText = Roact.createElement("TextLabel", {
            Size = UDim2.new(0.8,0,0.9,0),
            Position = UDim2.new(0.5,0,0,0),
            BackgroundTransparency = 1,
            RichText = true,
            Text = string.format("<stroke thickness='2' color='%s'><b>%s</b></stroke>",textStrokeColor,displayText),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            AnchorPoint = Vector2.new(0.5,0),
            Font = Enum.Font.FredokaOne,
            ZIndex = 2,

            [Roact.Event.MouseEnter] = function()
                self:setState({
                    hovered = true
                })
            end,

            [Roact.Event.MouseLeave] = function()
                self:setState({
                    hovered = false
                })
            end
        }),

        Roact.createElement("UIStroke", {
            Color = strokeColor,
            Thickness = 3,
        }),

        Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0,10),
        }),
        Fill = Roact.createElement("Frame", {
            Size = self.styles.percentage:map(function(percentage)
                return UDim2.new(percentage,0,1,0)
            end),
            BackgroundColor3 = fillColor,
            BorderSizePixel = 0,
        }, {Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0,10),
            })
        }),
    })
end

StatBar = RoactRodux.connect(function(state,props)
    if not state.stats then return {} end
    return {
        value = state.stats[props.Stat] or 0,
        maxValue = 100,
    }
end)(StatBar)

return StatBar