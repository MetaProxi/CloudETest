
--API Services
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local DataController
local Hotbar = require(script.Parent.Parent.UI.Hotbar)
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)

--Variables
local LocalPlayer = Players.LocalPlayer
local ToolModules = script.Parent.Parent.ToolModules
local ItemData = require(ReplicatedStorage.Common.ItemData)


--Helper Functions
local function ConnectTool(tool)
    print("Connect tool?")
    for _,tag in pairs(CollectionService:GetTags(tool)) do
        local toolModule = ToolModules:FindFirstChild(tag)
        print("weewoo")
        if toolModule then
            print("Matched tool")
            require(toolModule):ConnectTool(tool)
        end
    end
end

local function DisconnectTool(tool)
    for _,tag in pairs(CollectionService:GetTags(tool)) do
        local toolModule = ToolModules:FindFirstChild(tag)
        if toolModule then
            require(toolModule):DisconnectTool(tool)
        end
    end
end

--Controller
local InventoryController = Knit.CreateController {
    Name = "InventoryController";
}

function InventoryController:EquipTool(toolId)
    local tool = LocalPlayer.Backpack:FindFirstChild(toolId)
    if tool then
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
        tool.Parent = Character
        Humanoid:EquipTool(tool)
    end
end

function InventoryController:UnequipTool()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
    Humanoid:UnequipTools()
end

function InventoryController:KnitStart()
    DataController = Knit.GetController("DataController")

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

    DataController:GetStore().changed:connect(function(newState,oldState)
        local newInventory = newState.inventory
        local oldInventory = oldState.inventory or {}

        if newInventory then
            for key,item in pairs(newInventory) do
                if not oldInventory[key] then
                    local tool = item.tool
                    if tool then
                        ConnectTool(tool)
                    end
                end
            end
        end

        if oldInventory then
            for key,item in pairs(oldInventory) do
                if not newInventory[key] then
                    local tool = item.tool
                    if tool then
                        DisconnectTool(tool)
                        tool:Destroy()
                    end
                end
            end
        end
    end)

end

return InventoryController