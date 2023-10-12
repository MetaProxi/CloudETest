--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--Dependencies
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--Components
local Stats = require(StarterPlayer.StarterPlayerScripts.Client.UI.Stats)


return function(target)
    local store = Rodux.Store.new(function(state,action)
        state = state or {}
        local stats = state.stats or {
            Hunger = 0,
        }

        if action.type == "setStat" then
            stats[action.stat] = action.value
        elseif action.type == "incrementStat" then
            stats[action.stat] = state.Stats[action.stat] + action.value
        end

        state.stats = table.clone(stats)
        print("State updated")
        return state
    end)

    local app = Roact.createElement(RoactRodux.StoreProvider,{
        store = store,
    },{
        Stats = Roact.createElement(Stats,{
            AnchorPoint = Vector2.new(0.5,1),
            Position = UDim2.new(0.5,0,1,-10),
        })
    })

    local handle = Roact.mount(app,target)


    task.delay(1,function()
        store:dispatch({
            type = "setStat",
            stat = "Hunger",
            value = 100,
        })

        for _ = 1,10 do
            task.wait(1)
            store:dispatch({
                type = "incrementStat",
                stat = "Hunger",
                value = -10,
            })
        end
    end)

    return function()
        Roact.unmount(handle)
    end
end