--Rodux main service

--API Services
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
    Client = {
        Action = Knit:CreateSignal();
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

function DataService:GetStore()
    return self.Store
end

function DataService:KnitInit()


    -- Create a global reducer that combines all of the reducers in the service. This allows us to form one central store for all of our data and allow us to dynamically add reducers to the store.
    local function globalReducer(state,action)
        state = state or {}
        for _,reducer in pairs(self.Reducers) do
            state = reducer(state,action)
        end
        return state
    end

    self.Store = Rodux.Store.new(globalReducer,{},{ReplicationMiddleware(self.Client.Action)})

end

return DataService