
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local ItemButton = Roact.PureComponent:extend("ItemButton") :: Roact.Component

--Types
type Props = {
    itemId: string,
    itemIcon: string,
    itemName: string,
    quantity: number,
    selected: boolean,
    onSelect: (number) -> (),
}

function ItemButton:init()


    self.defaultProps = {
        itemId = "null",
        itemIcon = "rbxassetid://0",
        itemName = "-{PLACEHOLDER}-",
        quantity = 0,
        selected = false,
        onSelect = function() end,
    } :: Props
    

    --TODO: Type these.
    self.styles,self.springApi = RoactSpring.Controller.new({
        size = UDim2.new(0,0,0,0),
        highlightColor = Color3.fromRGB(255, 255, 255),
        backgroundColor = Color3.fromRGB(164, 255, 217),
        config = {mass = 0.4,tension = 300} -- Low mass to keep the animation snappy
    })

end

function ItemButton:render()
    local props = self.props :: Props
    local baseSize = props.selected and UDim2.new(0.9,0,0.9,0) or UDim2.new(0.8,0,0.8,0)

    
    --pop in animation
    self.springApi:start({
        size = baseSize,
        config = {mass = 0.4,tension = 400, friction = 7} -- Bounce in!
    })

    if props.selected then
        self.springApi:start({
            backgroundColor = Color3.fromRGB(149, 221, 255),
            size = UDim2.new(0.9,0,0.9,0),
        })
    else
        self.springApi:start({
            backgroundColor = Color3.fromRGB(164, 255, 217),
            size = UDim2.new(0.8,0,0.8,0),
        })
    end


    props.inputString = props.inputString or 0

    return Roact.createElement("ImageButton", {
        Size = self.styles.size,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundColor3 = self.styles.backgroundColor,
        BackgroundTransparency = 0,
        Image = props.itemIcon,
        AutoButtonColor = false,
        LayoutOrder = props.buttonNumber,
        [Roact.Event.Activated] = function()
            if not props.onSelect then return end
            props.onSelect(props.itemId)
        end;

        [Roact.Event.MouseButton1Down] = function()
            self.springApi:start({
                size = UDim2.new(0.7,0,0.7,0),
            })
        end;

        [Roact.Event.MouseButton1Up] = function()
            self.springApi:start({
                size = UDim2.new(0.9,0,0.9,0),
                config = {mass = 0.6,tension = 500,friction = 10} -- Make it bounce a little to make it feel more impactful
            })
        end;

        [Roact.Event.MouseEnter] = function()
            self.springApi:start({
                size = UDim2.new(0.9,0,0.9,0),
                highlightColor = Color3.fromRGB(247, 255, 137),
                config = {mass = 0.2,tension = 500} -- Make it bounce a little to make it feel more impactful
            })
        end;

        [Roact.Event.MouseLeave] = function()
            self.springApi:start({
                size = baseSize,
                highlightColor = Color3.fromRGB(255, 255, 255),
            })
        end;
    }, {
        Roact.createElement("UICorner",{
            CornerRadius = UDim.new(0,5),
        }),

        Roact.createElement("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5,Color3.fromRGB(221, 221, 221)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(233, 233, 233)),
            }),
            Rotation = 90,
        }),

        Roact.createElement("UIStroke", {
            Color = self.styles.highlightColor,
            Thickness = 3,
        }),

        Roact.createElement("TextLabel", { -- Input Name
            
            Size = UDim2.new(0.9,0,0.3,0),
            TextXAlignment = Enum.TextXAlignment.Left,
            AnchorPoint = Vector2.new(0.5,0),
            Position = UDim2.new(0.5,0,0,0),
            BackgroundTransparency = 1,
            TextColor3 = self.styles.highlightColor,
            TextScaled = true,
            RichText = true,
            Font = Enum.Font.FredokaOne,
            Text = string.format("<stroke><b>%s</b></stroke>",props.buttonNumber),
        }),

        Roact.createElement("TextLabel", { -- Quantity
            Size = UDim2.new(0.9,0,0.3,0),
            TextXAlignment = Enum.TextXAlignment.Right,
            AnchorPoint = Vector2.new(0.5,1),
            Position = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextColor3 = self.styles.highlightColor,
            TextScaled = true,
            RichText = true,
            Font = Enum.Font.FredokaOne,
            Visible = props.quantity > 1,
            Text = string.format("<stroke><b>x%d</b></stroke>",props.quantity),
        })
    })

end

return ItemButton