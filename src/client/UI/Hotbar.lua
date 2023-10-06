
--API Services
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Packages = ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local RoactRodux = require(Packages.RoactRodux)

--Components
local ItemButton = require(script.Parent.ItemButton)

local hotBar = Roact.Component:extend("Hotbar") :: Roact.Component

--Types(I find it extremely difficult to use types with Roact, but here's trying!)
type Props = {
    Inventory: {[string]: {itemId: string, itemIcon: string, itemName: string, quantity: number}}?;
    onSelect: (string) -> ();
    Position: UDim2?;
    AnchorPoint: Vector2?;
}

type State = {
    SelectedId: string?;
}

function hotBar:init()
    self:setState({
        SelectedId = Roact.None;
    })

    
end

function hotBar:setSelected(id: string) : string -- Simple function to update the selected state, returns the id for use in the callback

    local inventory = self.props.Inventory
    if not inventory[id] or self.state.SelectedId == id then
        id = ""
    end
    self:setState({
        SelectedId = id
    })
    return id -- Used by the callback to update the store
end

function hotBar:didMount()
    
    local props = self.props :: Props
    local state = self.state :: State

    local function selected(id: string) -- Update the selected state before calling the onClick callback
        props.onSelect(self:setSelected(id))
    end

    ContextActionService:BindAction("SelectItemKeyboard", function(_, inputState: Enum.UserInputState, inputObject: InputObject)
        --NOTE: 48 is the keycode for 0, 49 is the keycode for 1, etc.
        local numberValue = inputObject.KeyCode.Value - 48 -- Convert the keycode to a number via the enum value

        if inputState == Enum.UserInputState.Begin then
            local id = tostring(numberValue)
            selected(id)
        end
    end, false, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine)

    ContextActionService:BindAction("SelectItemController", function(_, inputState, inputObject)
        local currentSelection = state.SelectedId
        local left = inputObject.KeyCode == Enum.KeyCode.DPadLeft or inputObject.KeyCode == Enum.KeyCode.ButtonL2
        local right = inputObject.KeyCode == Enum.KeyCode.DPadRight or inputObject.KeyCode == Enum.KeyCode.ButtonR2

        if inputState ~= Enum.UserInputState.Begin then return end

        if left then
            local id = (currentSelection == "") and "9" or tostring(tonumber(currentSelection) - 1)
            selected(id)
        elseif right then
            local id = (currentSelection == "") and "1" or tostring(tonumber(currentSelection) + 1)
            selected(id)
        end

    end, false, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadDown)

end


function hotBar:render() : Roact.Element


    local props = self.props:: Props
    local position = props.Position or UDim2.new(0,0,0,0)
    local anchorPoint = props.AnchorPoint or Vector2.new(0,0)

    local inventory = props.Inventory :: {[string]: {itemId: string, itemIcon: string, itemName: string, quantity: number}} 
    local buttons = {} :: {[string]: Roact.Element}

    local function selected(id: string) -- Update the selected state before calling the onClick callback
        props.onSelect(self:setSelected(id))
    end


    for id, item in inventory do
        buttons[id] = Roact.createElement(ItemButton, {
            Id = id, -- This is the layout order and the input id on the hotbar
            itemId = item.itemId, -- This is the id of the item in the database
            itemIcon = item.itemIcon, -- This is the icon of the item in the database
            itemName = item.itemName, -- This is the name of the item in the database, shows up on hover
            quantity = item.quantity, -- This is the quantity of the item in the database
            selected = self.state.SelectedId == id, -- This is a boolean that determines if the item is selected
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

function hotBar:willUnmount()
    --NOTE: This seemingly causes an issue with hoarcekat when hot reloading, but it doesn't seem to cause any issues with the actual game
    -- If you wish to test input, manually deselect and reselect the storybook using it, giving some time between for this to run.
    ContextActionService:UnbindAction("SelectItemKeyboard")
    ContextActionService:UnbindAction("SelectItemController")

    
end

hotBar = RoactRodux.connect(
    function(state: {Inventory: {[string]: {itemId: string, itemIcon: string, itemName: string, quantity: number}}})
        return {
            Inventory = state.Inventory
        }
    end,
    function(dispatch: (any) -> ())
        return {
            onSelect = function(id)
                local actionType = (id ~= "") and "equipItem" or "unequipItem"
                dispatch({
                    type = actionType,
                    id = id
                })
            end
        }
    end
)(hotBar)

return hotBar