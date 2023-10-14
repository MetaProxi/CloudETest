--Rodux main service

--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local ReplicationMiddleware = require(script.Parent.Parent.Modules.ReplicationMiddleware)

--Service
local DataService = Knit.CreateService {
    Name = "DataService";
    Reducers = {};
    SyncFunctions = {};
    Client = {
        Action = Knit:CreateSignal();
        DataSync = Knit:CreateSignal();
    }
}

function DataService:Dispatch(actionTable)
    if not self.Store then warn("Store not initialized") return end
    self.Store:dispatch(actionTable)
end

function DataService:AddReducer(name: string, reducer: () -> {})
    if not self.Store then warn("Store not initialized") return end
    self.Reducers[name] = reducer
end

function DataService:AddSyncFunction(name: string, syncFunction: () -> {}) -- Used by global reducers to provide clients with non-specific data
    if not self.Store then warn("Store not initialized") return end
    self.SyncFunctions[name] = syncFunction
end

function DataService:GetStore()
    return self.Store
end

function DataService:GetState()
    return self.Store:getState()
end

function DataService:KnitInit()


    -- Create a global reducer that combines all of the reducers in the service. This allows us to form one central store for all of our data and allow us to dynamically add reducers to the store.
    local function globalReducer(state,action)
        state = state or {}
        for _,reducer in pairs(self.Reducers) do
            state = reducer(state,action)
        end

        --[[if action.type == "removePlayer" then -- Remove player from state when they leave
            state.players[action.player.UserId] = nil
        end]]

        return state
    end

    self.Store = Rodux.Store.new(globalReducer,{players = {}},{ReplicationMiddleware(self.Client.Action)})

    Players.PlayerRemoving:Connect(function(player)
        self.Store:dispatch({
            type = "removePlayer";
            player = player;
        })
    end)

end

return DataService