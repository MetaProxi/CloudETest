
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Packages = ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local RoactRodux = require(Packages.RoactRodux)

--Components
local ItemButton = require(script.Parent.ItemButton)

local hotBar = Roact.Component:extend("Hotbar")

function hotBar:init()
    self:setState({
        Inventory = {}
    })
end

function hotBar:render()

    

    local props = self.props
    local position = props.Position or UDim2.new(0,0,0,0)
    local anchorPoint = props.AnchorPoint or Vector2.new(0,0)

    local inventory = props.Inventory

    local buttons = {}

    for id, item in inventory do
        print(id, item)
        buttons[id] = Roact.createElement(ItemButton, {
            Id = id, -- This is the layout order and the input id on the hotbar
            itemId = item.itemId, -- This is the id of the item in the database
            itemIcon = item.itemIcon, -- This is the icon of the item in the database
            itemName = item.itemName,
            quantity = item.quantity,
        })
    end

    return Roact.createElement("Frame",{
            Size = UDim2.new(0.5,0,0,100),
            Position = position,
            AnchorPoint = anchorPoint,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1
        }, {
            Roact.createElement("UIListLayout",{
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0,10),
            }),
            Roact.createFragment(buttons) -- Easy to wrap all the buttons in a fragment due to the way we're creating them
        }
    )
end

hotBar = RoactRodux.connect(
    function(state)
        return {
            Inventory = state.Inventory
        }
    end
)(hotBar)

return hotBar