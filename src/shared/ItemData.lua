--Simple Item data table, contains various info by item id

--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Variables
local AssetFolder = ReplicatedStorage.Assets
local ToolFolder = AssetFolder:WaitForChild("Tools")

export type ItemData = {
    Name: string; -- Display name
    Icon: string; -- Display icon
    Description: string; -- Used for tooltips
    Tool: Tool; -- Tool to equip when used
}

local ItemData = {
    Apple = {
        Name = "Apple",
        Icon = "rbxassetid://0", 
        Description = "A delicious apple",
        Tool = ToolFolder.Apple
    },
    Orange = {
        Name = "Orange",
        Icon = "rbxassetid://0", 
        Description = "A delicious orange",
        Tool = ToolFolder.Orange
    }
} :: {[string]: ItemData}


return ItemData