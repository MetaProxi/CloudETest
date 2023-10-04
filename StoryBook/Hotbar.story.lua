
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

--Packages
local Packages = ReplicatedStorage.Packages
local Roact = require(Packages.Roact)

--Components
local Hotbar = require(StarterPlayer.StarterPlayerScripts.Client.UI.Hotbar)

return function(target)

    
    local hotBar = Roact.createElement(Hotbar,{
        Size = UDim2.new(0.4,0,0,100),
        Position = UDim2.new(0.5,0,0.9,0),
        AnchorPoint = Vector2.new(0.5,0.5),
    })

    local handle = Roact.mount(hotBar,target)

    return function()
        Roact.unmount(handle)
    end

end