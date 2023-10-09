
--API Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local ReplicationMiddleware = require(script.Parent.Parent.Modules.ReplicationMiddleware)

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

function InventoryService:EquipItem(itemId: string)
   local item = self.Inventory[Players.LocalPlayer].Inventory[itemId]   
end


function InventoryService:KnitStart()

    local dataService = Knit.GetService("DataService")

    local function inventoryReducer(state,action)
        state = state or {}
         if action.type == "addPlayer" then
            local playerState = state[action.player] or {}
            playerState.Inventory = {}
            playerState.equipped = ""
            state[action.player] = playerState
         elseif action.type == "removePlayer" then
            state[action.player] = nil
         elseif action.type == "addItem" then
            print("Adding item")
            local newInventory = table.clone(state[action.player].Inventory)
            local existingItem = newInventory[action.item.itemId]

            local playerBackpack = action.player:FindFirstChild("Backpack")
 
            if existingItem then --Item exists, add to quantity
                existingItem.quantity = existingItem.quantity + action.item.quantity
                state[action.player].Inventory = newInventory
            else -- Item doesn't exist, add it to the inventory and set it up.
                print("Giving tool")
                local data = ItemData[action.item.itemId]
                local tool = data.Tool:Clone()
                tool.Parent = playerBackpack
                action.item.tool = tool
                newInventory[action.item.itemId] = action.item

                ConnectTool(action.player,tool) -- Setup the tool

                state[action.player].Inventory = newInventory
            end
         elseif action.type == "removeItem" then
            local item = action.itemId
            local newInventory = table.clone(state[action.player].Inventory)

            

            newInventory[item].quantity = newInventory[item].quantity - (action.quantity or 1)
            if newInventory[item].quantity <= 0 then

                DisconnectTool(action.player,newInventory[item].tool) -- Disconnect the tool and cleanup

                newInventory.equipped = ""
                newInventory[item] = nil
            end

             state[action.player].Inventory = newInventory
         elseif action.type == "equipItem" then
             state[action.player].equipped = action.itemId
         elseif action.type == "unequipItem" then
             state[action.player].equipped = ""
         end
 
         return state
     end
    
    dataService:AddReducer("Inventory",inventoryReducer)

    Players.PlayerAdded:Connect(function(player)
        dataService:Dispatch({
            type = "addPlayer";
            player = player;
        })

        task.delay(1,function()
            for i = 1, 9 do
                task.wait(1)
                dataService:Dispatch({
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

    Players.PlayerRemoving:Connect(function(player)
        dataService:Dispatch({
            type = "removePlayer";
            player = player;
        })
    end)

end

return InventoryService