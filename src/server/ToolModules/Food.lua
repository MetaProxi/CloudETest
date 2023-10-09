--SERVER
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm
local Knit = require(ReplicatedStorage.Packages.Knit)

local Food = {Tools = {}}

function Food:ConnectTool(player: Player, tool: Tool)

    local dataService = Knit.GetService("DataService")

    local toolComm = Comm.new(tool,"Food")
    local toolTable = {
        player = player,
        tool = tool,
        toolComm = toolComm
    }

    toolComm:CreateSignal("Eat"):Connect(function()
        print("Eating")
        dataService:Dispatch({
            type = "incrementStat",
            stat = "Hunger",
            value = 10,
            player = player
        })

        dataService:Dispatch({
            type = "removeItem",
            itemId = tool.Name,
            player = player,
            quantity = 1
        })
    end)

    self.Tools[tool] = toolTable
end

function Food:DisconnectTool(tool: Tool)
    local toolTable = self.Tools[tool]
    if toolTable then
        toolTable.toolComm:Destroy()
        self.Tools[tool] = nil
    end
end

return Food
