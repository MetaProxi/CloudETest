
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local ReplicationMiddleware = require(script.Parent.Parent.Modules.ReplicationMiddleware)

--Types
type PlayerInventory = {
    items: {[string]: {quantity: number}}; 
    equipped: string;
}

--Service
local InventoryService = Knit.CreateService {
    Name = "InventoryService";
    Inventory = {},
    Client = {
        InventoryAction = Knit:CreateSignal(); -- Middleware passes all actions handled through the inventory store.
        PromptEquip = Knit:CreateSignal(); -- Player wants to equip an item
        PromptUnequip = Knit:CreateSignal(); -- Player wants to unequip an item
    };
}

function InventoryService.Client:GetInventory()
    return self.Server.Inventory[Players.LocalPlayer]
end

function InventoryService:EquipItem(itemId: string)
   local item = self.Inventory[Players.LocalPlayer].Inventory[itemId]
   
end

function InventoryService:KnitInit()

    local function inventoryReducer(action,store)
        store = store or {}
        if not action.player then return store end -- If the action doesn't have a player, we don't care about it.
        if action.type == "addPlayer" then
            store[action.player] = {
                Inventory = {};
                Equipped = "";
            }
        elseif action.type == "removePlayer" then
            store[action.player] = nil
        elseif action.type == "addItem" then
            local newInventory = table.clone(store[action.player].Inventory)
            local existingItem = newInventory[action.item.itemId]
            if existingItem then
                existingItem.quantity = existingItem.quantity + action.item.quantity
                store[action.player].Inventory = newInventory
            else
                newInventory[action.item.itemId] = action.item
                store[action.player].Inventory = newInventory
            end
        elseif action.type == "removeItem" then
            local item = action.itemId
            local newInventory = table.clone(store[action.player].Inventory)
            newInventory[item] = nil
            store[action.player].Inventory = newInventory
        elseif action.type == "equipItem" then
            store[action.player].equipped = action.itemId
        elseif action.type == "unequipItem" then
            store[action.player].equipped = ""
        end

        return store
    end
    
    self.Inventory = Rodux.Store.new(inventoryReducer,{},{ReplicationMiddleware(self.Client.InventoryAction)})

end

function InventoryService:KnitStart()
    Players.PlayerAdded:Connect(function(player)
        self.Inventory:dispatch({
            type = "addPlayer";
            player = player;
        })

        task.delay(1,function()
            for i = 1, 9 do
                task.wait(1)
                self.Inventory:dispatch({
                    type = "addItem";
                    player = player;
                    item = {
                        id = tostring(i);
                        itemId = "Apple";
                        quantity = math.random(1,10);
                    }
                })
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self.Inventory:dispatch({
            type = "removePlayer";
            player = player;
        })
    end)

end

return InventoryService