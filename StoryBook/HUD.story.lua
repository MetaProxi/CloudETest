
--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local HotbarStory = require(script.Parent["Hotbar.story"])

return function(target)
    local destroy1 = HotbarStory(target)
    return function()
        destroy1()
    end
end

