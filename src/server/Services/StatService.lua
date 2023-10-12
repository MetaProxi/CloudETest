--Handles Hunger and various other stats for players.


--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local DataService
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

    DataService = Knit.GetService("DataService")

    local function statReducer(state,action)
        if not action.player then return state end -- If the action doesn't have a player, we don't care about it.
        local newPlayerState = state[action.player] or {}
        local newStats = newPlayerState.stats or {}
        if action.stat and not newStats[action.stat] then
            newStats[action.stat] = DEFAULT_STATS[action.stat]
        end
        
        if action.type == "addCharacter" then
            for stat,value in pairs(DEFAULT_STATS) do
                newStats[stat] = value
            end
           
        elseif action.type == "setStat" then
            newStats[action.stat] = action.value
        elseif action.type == "incrementStat" then
            newStats[action.stat] += math.clamp(action.value,0,100)
            newStats[action.stat] = math.clamp(newStats[action.stat],0,100)
        else return state
        end
        newPlayerState.stats = table.clone(newStats)
        state[action.player] = table.clone(newPlayerState)
        return state
    end

    DataService:AddReducer("Stats",statReducer)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            DataService:Dispatch({
                type = "addCharacter",
                character = character,
                player = player,
            })
        end)
        
        if player.Character then
            DataService:Dispatch({
                type = "addCharacter",
                character = player.Character,
                player = player,
            })
        end
    end)

     -- Simple solution to preserve bandwidth, for a more complex solution we'd interpolate the value on the client and update it every second or so.
     -- This is a good enough solution for now.
    local drainClock = os.clock()
    RunService.Heartbeat:Connect(function(dt)
        for _,player in pairs(Players:GetPlayers()) do
            if os.clock() - drainClock > 0.1 then
                drainClock = os.clock()
                DataService:Dispatch({
                    type = "incrementStat",
                    player = player,
                    stat = "Hunger",
                    value = -0.1,
                })
            end
        end
    end)

end


return StatService