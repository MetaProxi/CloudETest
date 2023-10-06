
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local ItemButton = Roact.PureComponent:extend("ItemButton")

function ItemButton:init()


    self.defaultProps = {
        itemId = "null",
        itemIcon = "rbxassetid://0",
        itemName = "-{PLACEHOLDER}-",
        quantity = 0,
    } :: {
        itemId: string,
        itemIcon: string,
        itemName: string,
        quantity: number,
    }
    
    self.styles,self.springApi = RoactSpring.Controller.new({
        size = UDim2.new(0,0,0,0),
        config = {mass = 0.4,tension = 300} -- Low mass to keep the animation snappy
    })
    
end

function ItemButton:render()
    local props = self.props
    local state = self.state

    --pop in animation
    task.delay(0.1,function()
        self.springApi:start({
            size = UDim2.new(0.8,0,0.8,0)
        })
    end)

    return Roact.createElement("ImageButton", {
        Size = self.styles.size,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundColor3 = Color3.fromRGB(164, 255, 217),
        BackgroundTransparency = 0,
        Image = props.itemIcon,
        LayoutOrder = props.Id,
        [Roact.Event.Activated] = function()
            print("Clicked")
        end;

        [Roact.Event.MouseEnter] = function()
            self.springApi:start({
                size = UDim2.new(0.9,0,0.9,0)
            })
        end;

        [Roact.Event.MouseLeave] = function()
            self.springApi:start({
                size = UDim2.new(0.8,0,0.8,0)
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

        Roact.createElement("TextLabel", { -- Input Name
            
            Size = UDim2.new(0.9,0,0.3,0),
            TextXAlignment = Enum.TextXAlignment.Left,
            AnchorPoint = Vector2.new(0.5,0),
            Position = UDim2.new(0.5,0,0,0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            RichText = true,
            Font = Enum.Font.FredokaOne,
            Text = string.format("<stroke><b>%s</b></stroke>",props.Id),
        }),

        Roact.createElement("TextLabel", { -- Quantity
            Size = UDim2.new(0.9,0,0.3,0),
            TextXAlignment = Enum.TextXAlignment.Right,
            AnchorPoint = Vector2.new(0.5,1),
            Position = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            RichText = true,
            Font = Enum.Font.FredokaOne,
            Text = string.format("<stroke><b>x%d</b></stroke>",props.quantity),
        })
    })

end

return ItemButton