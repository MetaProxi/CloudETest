
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
        if action.stat and not state[action.stat] then
            state[action.stat] = 100
        end
        if action.type == "setStat" then
            state[action.stat] = action.value
        elseif action.type == "incrementStat" then
            state[action.stat] = state[action.stat] + action.value
        end
        return state
    end

    dataController:AddReducer("Stats", reducer)
end

return StatController
