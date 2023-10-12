
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--Variables

--Controller
local StatController = Knit.CreateController { Name = "StatController" }

function StatController:KnitStart()

    local dataController = Knit.GetController("DataController")

    local reducer = function(state, action)
        state = state or {}
        local newStats = state.stats
        if action.stat and not state.stats[action.stat] then
            newStats[action.stat] = 100
        end
        if action.type == "setStat" then
            newStats[action.stat] = action.value
        elseif action.type == "incrementStat" then
            newStats[action.stat] += action.value
            newStats[action.stat] = math.clamp(newStats[action.stat],0,100)
        else return state
        end
        state.stats = table.clone(newStats)
        return state
    end

    dataController:AddReducer("Stats", reducer)
end

return StatController
