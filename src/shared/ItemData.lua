--Simple Item data table, contains various info by item id

--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Variables
local AssetFolder = ReplicatedStorage.Assets
local ToolFolder = AssetFolder:WaitForChild("Tools")
local ModelFolder = AssetFolder:WaitForChild("ItemModels")

export type ItemData = {
    --ANY
    Name: string; -- Display name
    Icon: string; -- Display icon,UNUSED
    Description: string; -- Used for tooltips, UNUSED
    Tool: Tool; -- Tool to equip when used
    Model: Model; -- Model to display in inventory

    --FOOD
    Saturation: number?; -- If item is a Food, how much saturation does it give?
}

local ItemData = {
    Apple = {
        Name = "Apple",
        Icon = "rbxassetid://0", 
        Description = "A delicious apple",
        Saturation = 25,
        Tool = ToolFolder.Apple,
        Model = ModelFolder.Apple
    },
    Orange = {
        Name = "Orange",
        Icon = "rbxassetid://0", 
        Description = "A delicious orange",
        Saturation = 10,
        Tool = ToolFolder.Orange,
        Model = ModelFolder.Orange
    }
} :: {[string]: ItemData}


return ItemData