
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies
local Hotbar = require(script.Parent.Parent.UI.Hotbar)
local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)
local Roact = require(ReplicatedStorage.Packages.Roact)

--Variables
local LocalPlayer = Players.LocalPlayer

--Controller
local HudController = Knit.CreateController { Name = "HudController" }

function HudController:KnitStart()
    local dataController = Knit.GetController("DataController")

    local ui = Roact.createElement("ScreenGui",{},{
        StoreProvider = Roact.createElement(RoactRodux.StoreProvider,{
            store = dataController:GetStore();
        },{
            Hotbar = Roact.createElement(Hotbar, {
                Position = UDim2.new(0.5,0,0.9,0),
                AnchorPoint = Vector2.new(0.5,0.5),
                Inventory = {},
            })
        })
    })

    local handle = Roact.mount(ui,LocalPlayer.PlayerGui)
end

return HudController