--Get Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

--Setup Knit
Knit.AddControllersDeep(script.Controllers)
Knit.Start():catch(warn)
