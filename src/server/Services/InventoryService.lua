
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--Service
local InventoryService = Knit.CreateService {
    Name = "InventoryService";
    Client = {};
}

function InventoryService:KnitStart()
    
end

return InventoryService