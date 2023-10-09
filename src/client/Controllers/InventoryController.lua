
--API Services
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Hotbar = require(script.Parent.Parent.UI.Hotbar)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)


--Variables
local LocalPlayer = Players.LocalPlayer
local ToolModules = script.Parent.Parent.ToolModules
local ItemData = require(ReplicatedStorage.Common.ItemData)


--Helper Functions
local function ConnectTool(tool)
    for _,tag in pairs(CollectionService:GetTags(tool)) do
        local toolModule = ToolModules:FindFirstChild(tag)
        if toolModule then
            require(toolModule):ConnectTool(tool)
        end
    end
end

local function DisconnectTool(tool)
    for _,tag in pairs(CollectionService:GetTags(tool)) do
        local toolModule = ToolModules:FindFirstChild(tag)
        if toolModule then
            require(toolModule):DisconnectTool(tool)
        end
    end
end

--Controller
local InventoryController = Knit.CreateController {
    Name = "InventoryController";
    Inventory = {};
}


function InventoryController:KnitStart()
    local inventoryService = Knit.GetService("InventoryService")

    local dataController = Knit.GetController("DataController")

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

    local function inventoryReducer(state,action)
        
        if action.type == "addItem" then
            local newInventory = table.clone(state.Inventory)
            local existingItem = newInventory[action.item.itemId]
            if existingItem then -- Item already exists, increment quantity
                existingItem.quantity = existingItem.quantity + action.item.quantity
                state.Inventory = newInventory
            else -- Item doesn't exist, add it and find the tool in backpack
                local playerBackpack = LocalPlayer:FindFirstChild("Backpack")
                local data = ItemData[action.item.itemId]
                local tool = playerBackpack:FindFirstChild(data.Tool.Name)
                action.item.tool = tool
                newInventory[action.item.itemId] = action.item
                state.Inventory = newInventory
                ConnectTool(tool) -- Setup the tool

                
            end
        elseif action.type == "removeItem" then
            local item = action.itemId
            local newInventory = table.clone(state.Inventory)
            newInventory[item].quantity = newInventory[item].quantity - (action.quantity or 1)
            if newInventory[item].quantity <= 0 then
                state.equipped = ""
                DisconnectTool(newInventory[item].tool) -- Disconnect the tool and cleanup
                newInventory[item].tool:Destroy()
                newInventory[item] = nil
            end

            state.Inventory = newInventory
        elseif action.type == "equipItem" then
            state.equipped = action.itemId
            local tool = state.Inventory[action.itemId].tool
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        elseif action.type == "unequipItem" then
            state.equipped = ""
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
        return state
    end

    dataController:AddReducer("Inventory",inventoryReducer)

    

end

return InventoryController