--Get Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

--Setup Knit
Knit.AddControllersDeep(script.Controllers)
Knit.Start():catch(warn)


--Setup components, just need to require them, they will register themselves
for _, componentModule: ModuleScript in pairs(script.Components:GetDescendants()) do
    if not componentModule:IsA("ModuleScript") then continue end
    require(componentModule)
end