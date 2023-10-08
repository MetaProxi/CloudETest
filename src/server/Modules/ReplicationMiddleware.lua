--Wrapper for various Knit services to be used as middleware for Rodux


return function (remote)
    return function (nextDispatch,store)
        return function(action)
            local player = action.player
            if player then action.player = nil end
            local beforeState = store:getState()
            local result = nextDispatch(action)
            local afterState = store:getState()
            if beforeState ~= afterState then
                remote:Fire(player,action,beforeState,afterState)
            end
        end
    end
end
