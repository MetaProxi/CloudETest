
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
            Inventory = {}
        }

        if action.type == "addItem" then
            local newInventory = table.clone(state.Inventory)
            local existingItem = newInventory[action.item.Id]
            if existingItem then
                existingItem.quantity = existingItem.quantity + action.item.quantity
                return {
                    Inventory = newInventory
                }
            else
                newInventory[action.item.Id] = action.item
                return {
                    Inventory = newInventory
                }
            end
        elseif action.type == "removeItem" then
            local item = action.id or "1"
            local newInventory = table.clone(state.Inventory)
            newInventory[item] = nil
            return {
                Inventory = newInventory
            }
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
            inventoryStore:dispatch({
                type = "addItem",
                item = {
                    Id = tostring(i),
                    itemId = tostring(i),
                    itemIcon = "rbxassetid://0",
                    itemName = "Test Item"..i,
                    quantity = 1,
                }
            })
        end
        task.wait(4)
        inventoryStore:dispatch({
            type = "removeItem";
            id = "9";
        })
    end)

    return function()
        Roact.unmount(handle)
    end

end