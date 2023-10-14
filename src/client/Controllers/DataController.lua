--Rodux Data Controller


--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--Variables
local LocalPlayer = Players.LocalPlayer

--Controller
local DataController = Knit.CreateController {
    Name = "DataController";
    Reducers = {};
}

function DataController:Dispatch(actionTable) -- Ideally this would only be used by replication to keep game state in sync
    if not self.Store then warn("Store not initialized - Dispatch: ",debug.traceback(3)) return end
    self.Store:dispatch(actionTable)
end

function DataController:AddReducer(name, reducer)
    if not self.Store then warn("Store not initialized - AddReducer: ",debug.traceback(3)) return end
    self.Reducers[name] = reducer
end

function DataController:GetStore()
    return self.Store
end

function DataController:KnitInit()
    local dataService = Knit.GetService("DataService")

    local function globalReducer(state,action)
        state = state or {}
        for _,reducer in pairs(self.Reducers) do
            state = reducer(state,action)
        end

        -- Replication Middleware
        if action.type == "replicate" then
            print(action.newState)
            return action.newState
        end

        return state
    end

    self.Store = Rodux.Store.new(globalReducer,{},{})

    dataService.Action:Connect(function(newState)
        local playerTable = newState.players[tostring(LocalPlayer.UserId)]
        --Merge player table into local player state
        for key,value in playerTable do
            newState[key] = value
        end
        newState.players = nil

        self:Dispatch({
            type = "replicate",
            newState = newState
        })
    end)
end

return DataController
