
--Get Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

--Setup Knit
Knit.AddServicesDeep(script.Services)
Knit.Start():catch(warn)
