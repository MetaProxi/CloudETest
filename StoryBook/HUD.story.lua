
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local HotbarStory = require(script.Parent["Hotbar.story"])
local HungerStory = require(script.Parent["Stats.story"])

return function(target)
    local destroy1 = HotbarStory(target)
    local destroy2 = HungerStory(target)
    return function()
        destroy1()
        destroy2()
    end
end

