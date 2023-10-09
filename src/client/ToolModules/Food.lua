--CLIENT
--Handles the functionality for food items.

--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Comm = require(ReplicatedStorage.Packages.Comm).ClientComm

local Food = {Tools = {}}

function Food:ConnectTool(tool: Tool)
    local toolComm = Comm.new(tool,true,"Food")
    

    
    local activateEvent = tool.Activated:Connect(function()
        toolComm:GetSignal("Eat"):Fire()
    end)

    local toolTable = {
        tool = tool,
        toolComm = toolComm,
        activateEvent = activateEvent
    }

    self.Tools[tool] = toolTable
end

function Food:DisconnectTool(tool: Tool)
    local toolTable = self.Tools[tool]
    if toolTable then
        toolTable.toolComm:Destroy()
        toolTable.activateEvent:Disconnect()
        self.Tools[tool] = nil
    end
end

return Food
