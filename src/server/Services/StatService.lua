--Handles Hunger and various other stats for players.


--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local ReplicationMiddleware = require(script.Parent.Parent.Modules.ReplicationMiddleware)
local DefaultStats = require(ReplicatedStorage.Common.DefaultStats)

--Variables
local DEFAULT_STATS = DefaultStats -- Anything in here will be added to the player's state table when they join.


--Service
local StatService = Knit.CreateService {
    Name = "StatService", 
    Client = {
        StatAction = Knit:CreateSignal();
    }
}


function StatService:KnitStart()

    local dataService = Knit.GetService("DataService")

    local function statReducer(state,action)
        state = state or {}
        if not action.player then return state end -- If the action doesn't have a player, we don't care about it.
        if action.type == "addPlayer" then
            local playerState = state[action.player] or {}
            for stat,value in pairs(DEFAULT_STATS) do
                playerState[stat] = value
            end
            state[action.player] = playerState
        elseif action.type == "setStat" then
            state[action.player][action.stat] = action.value
        elseif action.type == "incrementStat" then
            state[action.player][action.stat] = state[action.player][action.stat] + action.value
        end
        return state
    end

    dataService:AddReducer("Stats",statReducer)
end


return StatService