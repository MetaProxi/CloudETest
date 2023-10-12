
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies 
local DataController

--Controller
local PickupController = Knit.CreateController {
    Name = "PickupController";
}

function PickupController:KnitStart()
    
end

return PickupController
