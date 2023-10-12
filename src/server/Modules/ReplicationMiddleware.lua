--Wrapper for various Knit services to be used as middleware for Rodux


return function (remote) --@param remote RemoteEvent The remote event that is used to communicate with the client
    return function (nextDispatch,store)
        return function(action)
            local player = action.player
            local result = nextDispatch(action)
            local afterState = store:getState()
            remote:Fire(player,action)
            return result
        end
    end
end
