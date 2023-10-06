
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--Components
local RoduxTest = require(StarterPlayer.StarterPlayerScripts.Client.UI.RoduxTest)

return function(target)
    local store = Rodux.Store.new(function(state,action)
        state = state or {
            value = 0
        }

        if action.type == "increment" then
            return {
                value = state.value + 1
            }
        end

        return state
    end)

    local app = Roact.createElement(RoactRodux.StoreProvider,{
        store = store,
    },{
        RoduxTest = Roact.createElement(RoduxTest)
    })

    local handle = Roact.mount(app,target)

    return function()
        Roact.unmount(handle)
    end


end

