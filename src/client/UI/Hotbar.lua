
--API Services
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Packages = ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local RoactRodux = require(Packages.RoactRodux)
local ItemData = require(ReplicatedStorage.Common.ItemData)

--Components
local ItemButton = require(script.Parent.ItemButton)

local HotBar = Roact.Component:extend("Hotbar") :: Roact.Component

--Types(I find it extremely difficult to use types with Roact, but here's trying!)
type Props = {
    Inventory: {[string]: {itemId: string, itemIcon: string, itemName: string, quantity: number}}; -- This is the inventory table from the store
    onSelect: (string) -> ();
    Position: UDim2?;
    AnchorPoint: Vector2?;
}

type State = {
    SelectedId: string?;
}

function HotBar:init()
    self:setState({
        SelectedId = Roact.None;
    })

    self.ButtonNumbers = {} :: {[number]: string} -- This is used to keep track of which button is which number, so we can use keyboard shortcuts
end

function HotBar:setSelected(id: string) : string -- Simple function to update the selected state, returns the id for use in the callback

    local inventory = self.props.Inventory
    if not inventory[id] or self.state.SelectedId == id then
        id = ""
    end
    self:setState({
        SelectedId = id
    })
    return id -- Used by the callback to update the store
end

function HotBar:didMount()
    
    local props = self.props :: Props
    local state = self.state :: State

    local function selected(itemId: string) -- Update the selected state before calling the onClick callback
        props.onSelect(self:setSelected(itemId))
    end


    ContextActionService:BindAction("SelectItemKeyboard", function(_, inputState: Enum.UserInputState, inputObject: InputObject)
        --NOTE: 48 is the keycode for 0, 49 is the keycode for 1, etc.
        local numberValue = inputObject.KeyCode.Value - 48 -- Convert the keycode to a number via the enum value

        if inputState == Enum.UserInputState.Begin then
            local itemId = self.ButtonNumbers[numberValue]
            selected(itemId or "")
        end
    end, false, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine)

end


function HotBar:render() : Roact.Element


    local props = self.props:: Props
    local position = props.Position or UDim2.new(0,0,0,0)
    local anchorPoint = props.AnchorPoint or Vector2.new(0,0)

    local inventory = props.Inventory :: {[string]: {itemId: string, itemIcon: string, itemName: string, quantity: number}} 
    local buttons = {} :: {[string]: Roact.Element}

    local function selected(itemId: string) -- Update the selected state before calling the onClick callback
        props.onSelect(self:setSelected(itemId))
    end

    --This is kind of gross for time complexity, but it's not like we're dealing with a lot of items

    --Clear buttonnumbers with no items
    for i = 1, 9 do
        if not inventory[self.ButtonNumbers[i]] then
            self.ButtonNumbers[i] = nil
        end
    end

    for itemId, item in inventory do

        if not itemId then
            continue
        end
        local buttonNumber = ""

        --Find a number that isn't already taken
        for i = 1, 9 do
            if self.ButtonNumbers[i] == itemId then
                buttonNumber = tostring(i)
                break
            elseif self.ButtonNumbers[i] == nil then
                self.ButtonNumbers[i] = itemId
                buttonNumber = tostring(i)
                break
            end
        end
        
        local tool: Tool? = nil
        if ItemData[itemId] then
            tool = ItemData[itemId].Tool
        end

        buttons[itemId] = Roact.createElement(ItemButton, {
            itemId = item.itemId, -- This is the id of the item in the database
            itemName = item.itemName, -- This is the name of the item in the database, shows up on hover
            tool = tool, -- This is cloned into a viewportframe.
            quantity = item.quantity, -- This is the quantity of the item in the database
            buttonNumber = buttonNumber, -- This is the string that shows up on the button
            selected = self.state.SelectedId == itemId, -- This is a boolean that determines if the item is selected
            onSelect = selected, -- This is the callback that is called when the item is clicked
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

function HotBar:willUnmount()
    --NOTE: This seemingly causes an issue with hoarcekat when hot reloading, but it doesn't seem to cause any issues with the actual game
    -- If you wish to test input, manually deselect and reselect the storybook using it, giving some time between for this to run.
    ContextActionService:UnbindAction("SelectItemKeyboard")
    ContextActionService:UnbindAction("SelectItemController")

    
end

HotBar = RoactRodux.connect(
    function(state: {inventory: {[string]: {itemId: string, itemIcon: string, itemName: string, quantity: number}}})
        return {
            Inventory = state.inventory
        }
    end,
    function(dispatch: (any) -> ())
        return {
            onSelect = function(itemId)
                local actionType = (itemId ~= "") and "equipItem" or "unequipItem"
                print("OnSelect: ".. itemId)
                dispatch({
                    type = actionType,
                    itemId = itemId
                })
            end
        }
    end
)(HotBar)

return HotBar