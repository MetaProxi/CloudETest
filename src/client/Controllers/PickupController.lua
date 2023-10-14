
--API Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies 
local DataController
local PickupService

--Variables
local ItemData = require(ReplicatedStorage.Common.ItemData)

--Controller
local PickupController = Knit.CreateController {
    Name = "PickupController";
    PickupModels = {};
}

function PickupController:KnitStart()
    DataController = Knit.GetController("DataController")
    PickupService = Knit.GetService("PickupService")

    DataController:GetStore().changed:connect(function(newState,oldState)
        local newPickups = newState.pickups
        local oldPickups = oldState.pickups or {}

        for key,pickup in pairs(newPickups) do
            if not oldPickups[key] then
                local model = ItemData[pickup.PickupId].Model:Clone()
                model:PivotTo(CFrame.new(pickup.Position) * CFrame.new(0,3,0))
                model.Parent = workspace
                model.Anchored = true
                model.CanCollide = false

                CollectionService:AddTag(model,"Hover")

                self.PickupModels[pickup.PickupId..tostring(pickup.Position)] = model

                --SETUP PROXIMITYPROMPT
                local proximityPrompt = Instance.new("ProximityPrompt")
                proximityPrompt.Parent = model
                proximityPrompt.HoldDuration = 0.1
                proximityPrompt.ActionText = "Pick up"
                proximityPrompt.MaxActivationDistance = 5
                proximityPrompt.ObjectText = ItemData[pickup.PickupId].Name

                proximityPrompt.Triggered:Connect(function()
                    PickupService.PickupRequest:Fire(pickup.PickupId,pickup.Position)
                end)

            end
        end

        for key,pickup in pairs(oldPickups) do
            if not newPickups[key] then
                local pickupModel = self.PickupModels[pickup.PickupId..tostring(pickup.Position)]
                if pickupModel then
                    pickupModel:Destroy()
                    self.PickupModels[pickup.PickupId..tostring(pickup.Position)] = nil
                end
            end
        end
    end)


end

return PickupController
