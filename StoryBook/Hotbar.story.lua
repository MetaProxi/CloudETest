
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--Packages
local Packages = ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local Rodux = require(Packages.Rodux)
local RoactRodux = require(Packages.RoactRodux)

--Components
local Hotbar = require(StarterPlayer.StarterPlayerScripts.Client.UI.Hotbar)

return function(target)

    local inventoryStore = Rodux.Store.new(function(state,action)
        state = state or {
            Inventory = {},
            Equipped = ""
        }

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
            local item = action.itemId
            if not item then return state end
            local newInventory = table.clone(state.Inventory)
            newInventory[item] = nil
            state.Inventory = newInventory
        elseif action.type == "equipItem" then
            state.Equipped = action.itemId
        elseif action.type == "unequipItem" then
            print("Unequipped")
            state.Equipped = ""
        end

        return state
    end)
    
    local hotBar = Roact.createElement(RoactRodux.StoreProvider,{
        store = inventoryStore,
    },{
        Hotbar = Roact.createElement(Hotbar, {
            Position = UDim2.new(0.5,0,0.9,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            Inventory = {}
        })
    })

    local handle = Roact.mount(hotBar,target)
    
    task.delay(1,function()
        for i = 1, 9 do
            task.wait(0.1)
            local id = string.format("Item%d",i)
            if i == 1 then 
                id = "Apple"
            elseif i == 2 then
                id = "Orange"
            end
            inventoryStore:dispatch({
                type = "addItem",
                item = {
                    itemId = id,
                    itemIcon = "rbxassetid://0",
                    itemName = "Test Item"..i,
                    quantity = math.random(1,300),
                }
            })
        end
        task.wait(4)
        inventoryStore:dispatch({
            type = "removeItem";
            itemId = string.format("Item%d",9);
        })
    end)

    return function()
        Roact.unmount(handle)
    end

end