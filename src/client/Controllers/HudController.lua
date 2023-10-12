
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--Dependencies

local RoactRodux = require(ReplicatedStorage.Packages.RoactRodux)
local Roact = require(ReplicatedStorage.Packages.Roact)

--UI
local Hotbar = require(script.Parent.Parent.UI.Hotbar)
local Stats = require(script.Parent.Parent.UI.Stats)

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

            Main = Roact.createElement("Frame", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
            }, {
                Hotbar = Roact.createElement(Hotbar, {
                    Position = UDim2.new(0.5,0,0.95,-10),
                    AnchorPoint = Vector2.new(0.5,1),
                    Inventory = {},
                }),
                Stats = Roact.createElement(Stats,{
                    AnchorPoint = Vector2.new(0.5,1),
                    Position = UDim2.new(0.5,0,1,-10),
                }),
            })
            
        })
    })

    local handle = Roact.mount(ui,LocalPlayer.PlayerGui)
end

return HudController