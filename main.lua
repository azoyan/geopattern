local GeoPattern = require "geopattern.lib"

local pattern1 = GeoPattern:new("GitHub") -- without options 
local svg1 = pattern1:toSvg()

local pattern2 = GeoPattern:new("GitHub", { generator = "concentricCircles" })
local svg2 = pattern2:toSvg()

local pattern3 = GeoPattern:new("GitHub", { color = "#00ffff" })
local base64 = pattern3:toBase64()

local options = {
    generator = "concentricCircles",
    color = "#00ffff", 
    baseColor = "#af39b3"
}
local pattern4 = GeoPattern:new("GitHub", options) -- with all available options
local svg4 = pattern4:toSvg()

for i = 1, #GeoPattern.patterns do
    local pattern = GeoPattern:new("GitHub", { generator = GeoPattern.patterns[i] })
    
    pattern:toBase64()
    local file = io.open(GeoPattern.patterns[i] .. ".svg", "w")
    file:write(pattern:toSvg())
    file:close()
end

