--Rodux Data Controller


--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--Controller
local DataController = Knit.CreateController {
    Name = "DataController";
    Reducers = {};
}

function DataController:Dispatch(actionTable) -- Ideally this would only be used by replication to keep game state in sync
    if not self.Store then warn("Store not initialized") return end
    self.Store:dispatch(actionTable)
end

function DataController:AddReducer(name, reducer)
    if not self.Store then warn("Store not initialized") return end
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
        return state
    end

    self:AddReducer("Replication",function(state,action)
        if action.type == "syncState" then
            state = action.newState
        end
        return state
    end)

    dataService.Action:Connect(function(action)
        self:Dispatch(action)
    end)

    self.Store = Rodux.Store.new(globalReducer,{inventory = {}, stats = {}, equipped = ""},{})
end

return DataController
