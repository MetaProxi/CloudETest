
--API Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local DataService

--Variables
local ToolModules = script.Parent.Parent.ToolModules
local ItemData = require(ReplicatedStorage.Common.ItemData)

--Types

--Helper Functions
local function ConnectTool(player: Player,tool: Tool)
    for _,tag in CollectionService:GetTags(tool) do
        local toolModule = ToolModules:FindFirstChild(tag)
        if toolModule then
            require(toolModule):ConnectTool(player,tool)
        end
    end
end

local function DisconnectTool(player: Player,tool: Tool)
    for _,tag in CollectionService:GetTags(tool) do
        local toolModule = ToolModules:FindFirstChild(tag)
        if toolModule then
            require(toolModule):DisconnectTool(tool)
        end
    end
end

--Service
local InventoryService = Knit.CreateService {
    Name = "InventoryService";
    Inventory = {},
    Client = {
    };
}

function InventoryService.Client:GetInventory()
    return self.Server.Inventory[Players.LocalPlayer]
end


function InventoryService:KnitStart()

    DataService = Knit.GetService("DataService")

    local function inventoryReducer(state,action)
        state = state or {}
        
        local newPlayerState = state[action.player] or {}

        if action.type == "addPlayer" then
        
        newPlayerState.inventory = {}
        newPlayerState.equipped = ""

        elseif action.type == "addItem" then
        local newInventory = newPlayerState.inventory
        local existingItem = newInventory[action.item.itemId]

        local playerBackpack = action.player:FindFirstChild("Backpack")

        if existingItem then --Item exists, add to quantity
            existingItem.quantity = existingItem.quantity + action.item.quantity
            newPlayerState.inventory = newInventory
        else -- Item doesn't exist, add it to the inventory and set it up.
            local data = ItemData[action.item.itemId]
            local tool = data.Tool:Clone()
            tool.Parent = playerBackpack
            action.item.tool = tool
            newInventory[action.item.itemId] = action.item

            ConnectTool(action.player,tool) -- Setup the tool

            newPlayerState.inventory = newInventory
        end

        elseif action.type == "removeItem" then
        local item = action.itemId
        local newInventory = newPlayerState.inventory

        

        newInventory[item].quantity = newInventory[item].quantity - (action.quantity or 1)
        if newInventory[item].quantity <= 0 then

            DisconnectTool(action.player,newInventory[item].tool)

            newInventory.equipped = ""
            newInventory[item] = nil
        end

            newPlayerState.inventory = newInventory
        elseif action.type == "equipItem" then
            newPlayerState.equipped = action.itemId

        elseif action.type == "unequipItem" then
            newPlayerState.equipped = ""

        else
            return state
        end
        state[action.player] = table.clone(newPlayerState)
        return state
     end
    
    DataService:AddReducer("Inventory",inventoryReducer)

    Players.PlayerAdded:Connect(function(player)
        DataService:Dispatch({
            type = "addPlayer";
            player = player;
        })

        task.delay(1,function()
            for i = 1, 9 do
                task.wait(1)
                DataService:Dispatch({
                    type = "addItem";
                    player = player;
                    item = {
                        itemId = math.random(1,2) == 1 and "Apple" or "Orange";
                        quantity = math.random(1,5);
                    }
                })
            end
        end)
    end)

end

return InventoryService