
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Packages
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)

local RoduxTest = Roact.Component:extend("RoduxTest")

function RoduxTest:init()
    
end

function RoduxTest:render()
    local props = self.props
    local store = props.store

    local clickNumber = props.value
    local onClick = props.onClick

    return Roact.createElement("TextButton", {
        Text = "Clicks: "..clickNumber,
        Size = UDim2.new(0,100,0,100),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),

        [Roact.Event.Activated] = onClick
    })
end


RoduxTest = RoactRodux.connect(
    function(state)
        return {
            value = state.value
        }
    end,
    function(dispatch)
        return {
            onClick = function()
                dispatch({
                    type = "increment"
                })
            end
        }
    end
)(RoduxTest)


return RoduxTest