
--API Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local DataService
local InventoryService

--Variables
local ItemData = require(ReplicatedStorage.Common.ItemData)
local SPAWN_TABLE = {"Apple", "Orange"}

--Service
local PickupService = Knit.CreateService {
    Name = "PickupService";
    Client = {
        PickupRequest = Knit:CreateSignal();
    };
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
        local newPickups = state.pickups or {}

        if action.type == "spawnPickup" then
            newPickups[action.pickupId..tostring(action.position)] = {
                PickupId = action.pickupId;
                Position = action.position;
            }
        elseif action.type == "despawnPickup" then
            newPickups[action.pickupId..tostring(action.position)] = nil
        end

        state.pickups = table.clone(newPickups)
        return state
    end

    local function pickupSyncFunction(clientState,serverState)
        local newClientState = clientState or {}
        newClientState.pickups = serverState.pickups and table.clone(serverState.pickups) or {}
        return newClientState
    end

    DataService:AddReducer("PickupReducer",pickupReducer)
    DataService:AddSyncFunction("Pickups", pickupSyncFunction) -- Give new players the pickups that have already spawned.

    self.Client.PickupRequest:Connect(function(player,pickupId,pickupPosition)
        local pickup = DataService:GetStore():getState().pickups[pickupId..tostring(pickupPosition)]
        if pickup then
            local playerCharacter = player.Character
            if not playerCharacter then return end
            local rootPart = playerCharacter.PrimaryPart
            if not rootPart then return end
            local distance = (rootPart.Position - pickup.Position).Magnitude
            if distance < 7 then
                DataService:Dispatch({
                    type = "despawnPickup";
                    pickupId = pickupId;
                    position = pickupPosition;
                })
                DataService:Dispatch({
                    type = "addItem";
                    player = player;
                    item = {
                        itemId = pickupId;
                        quantity = 1;
                    }
                })
            end
        end
    end)

    local spawnClock = os.clock()
    RunService.Stepped:Connect(function()
        if os.clock() - spawnClock > 5 then
            spawnClock = os.clock()
            local pickupId = SPAWN_TABLE[math.random(1,#SPAWN_TABLE)]
            local position = Vector3.new(math.random(-200,200),50,math.random(-200,200)) --TODO, Set this system up to spawn off zones if continued development.

            --Raycast down to find the ground
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local raycastResult = workspace:Raycast(position,Vector3.new(0,-100,0),raycastParams)
            if raycastResult then
                position = raycastResult.Position
            end

            PickupService:SpawnPickup(pickupId, position)
        end
    end)
end

return PickupService