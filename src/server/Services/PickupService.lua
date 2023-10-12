
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local DataService
local InventoryService

--Service
local PickupService = Knit.CreateService {
    Name = "PickupService";
    Client = {};
}

function PickupService:SpawnPickup(pickupId, position)
    DataService:Dispatch({
        type = "spawnPickup";
        pickupId = pickupId;
        position = position;
    })
end

function PickupService:KnitStart()
    DataService = Knit.GetService("DataService")
    InventoryService = Knit.GetService("InventoryService")

    local function pickupReducer(state, action)
        state = state or {}
        local newPickups = state.Pickups or {}

        if action.type == "spawnPickup" then
            newPickups[action.pickupId..action.position] = action.pickupId
        elseif action.type == "despawnPickup" then
            newPickups[action.pickupId..action.position] = nil
        end

        state.Pickups = table.clone(newPickups)
        return state
    end

    DataService:AddReducer(pickupReducer)
end

return PickupService