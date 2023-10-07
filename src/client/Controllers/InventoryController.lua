
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Hotbar = require(script.Parent.Parent.UI.Hotbar)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)

--Variables
local LocalPlayer = Players.LocalPlayer

--Controller
local InventoryController = Knit.CreateController {
    Name = "InventoryController";
    Inventory = {};
}


function InventoryController:KnitStart()
    local inventoryService = Knit.GetService("InventoryService")

    self.Inventory = Rodux.Store.new(function(state,action)

        if action.type == "addItem" then
            local newInventory = table.clone(state.Inventory)
            local existingItem = newInventory[action.item.itemId]
            if existingItem then
                existingItem.quantity = existingItem.quantity + action.item.quantity
                state.Inventory = newInventory
            else
                newInventory[action.item.itemId] = action.item
                state.Inventory = newInventory
            end
        elseif action.type == "removeItem" then
            local item = action.itemId or "1"
            local newInventory = table.clone(state.Inventory)
            newInventory[item] = nil
            state.Inventory = newInventory
        elseif action.type == "equipItem" then
            state.equipped = action.itemId
        elseif action.type == "unequipItem" then
            state.equipped = ""
        end
        return state
    end,{Inventory = {}; Equipped = "";})

    inventoryService.InventoryAction:Connect(function(action)
        print("Got action: ",action.type)
        self.Inventory:dispatch(action)
    end)

    local ui = Roact.createElement("ScreenGui",{},{
        Hotbar = Roact.createElement(RoactRodux.StoreProvider,{
            store = self.Inventory,
        },{
            Hotbar = Roact.createElement(Hotbar, {
                Position = UDim2.new(0.5,0,0.9,0),
                AnchorPoint = Vector2.new(0.5,0.5),
                Inventory = {}
            })
        })
    })

    local handle = Roact.mount(ui,LocalPlayer.PlayerGui)



end

return InventoryController