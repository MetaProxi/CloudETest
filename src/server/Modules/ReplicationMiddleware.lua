--Wrapper for various Knit services to be used as middleware for Rodux



return function (remote) --@param remote RemoteEvent The remote event that is used to communicate with the client
    return function (nextDispatch,store)
        return function(action)
            local player = action.player
            local result = nextDispatch(action)
            local newState = store:getState()

            if player then -- If this is modifying a player's state, only fire to that player
                remote:Fire(player,newState)
            else -- If this is modifying a global state, fire to all clients
                remote:FireAll(newState)
            end
            --return result
        end
    end
end
