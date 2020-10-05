local GeoPattern = {}
local Svg = require "geopattern.svg"
local base64 = require "geopattern.base64"
local sha1 = require "geopattern.sha1.init"

local PATTERNS = {'octogons', 'overlappingCircles', 'plusSigns', 'xes', 'sineWaves', 'hexagons', 'overlappingRings',
                  'plaid', 'triangles', 'squares', 'concentricCircles', 'diamonds', 'tessellation', 'nestedSquares',
                  'mosaicSquares', 'chevrons'}

local DEFAULTS = {
    baseColor = "#933c3c"
}

local FILL_COLOR_DARK = '#222';
local FILL_COLOR_LIGHT = '#ddd';
local STROKE_COLOR = '#000';
local STROKE_OPACITY = 0.02;
local OPACITY_MIN = 0.02;
local OPACITY_MAX = 0.15;

local function hex2rgb(hex)
    local hex = hex:gsub("#", "")
    if hex:len() == 3 then
        return {(tonumber("0x" .. hex:sub(1, 1)) * 17) / 255, (tonumber("0x" .. hex:sub(2, 2)) * 17) / 255,
                (tonumber("0x" .. hex:sub(3, 3)) * 17) / 255}
    else
        return {tonumber("0x" .. hex:sub(1, 2)) / 255, tonumber("0x" .. hex:sub(3, 4)) / 255,
                tonumber("0x" .. hex:sub(5, 6)) / 255}
    end
end

local function rgb2hex(rgb)
    local hexadecimal = '0X'
    for key, value in pairs(rgb) do
        local hex = ''

        while (value > 0) do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex
        end

        if (string.len(hex) == 0) then
            hex = '00'

        elseif (string.len(hex) == 1) then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end

    return hexadecimal
end

local function rgb2hsl(rgb)
    local r, g, b, a = rgb[1], rgb[2], rgb[3], rgb[4] or 1
    r, g, b = r / 255, g / 255, b / 255

    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, l = nil, nil, (max + min) / 2

    if max == min then
        h, s = 0, 0 -- achromatic
    else
        local d = max - min
        if l > 0.5 then
            s = d / (2 - max - min)
        else
            s = d / (max + min)
        end
        if max == r then
            h = (g - b) / d
            if g < b then
                h = h + 6
            end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    local hsl = {}
    hsl.h = h
    hsl.s = s
    hsl.l = l
    hsl.a = a
    return hsl
end

--[[
   * Converts an HSL color value to RGB. Conversion formula
   * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
   * Assumes h, s, and l are contained in the set [0, 1] and
   * returns r, g, and b in the set [0, 255].
   *
   * @param   Number  h       The hue
   * @param   Number  s       The saturation
   * @param   Number  l       The lightness
   * @return  Array           The RGB representation
  ]]
local function hsl2rgb(hsl)
    local h, s, l, a = hsl.h, hsl.s, hsl.l, hsl.a or 1
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l -- achromatic
       
    else
        function hue2rgb(p, q, t)
            if t < 0 then
                t = t + 1
            end
            if t > 1 then
                t = t - 1
            end
            if t < 1 / 6 then
                return p + (q - p) * 6 * t
            end
            if t < 1 / 2 then
                return q
            end
            if t < 2 / 3 then
                return p + (q - p) * (2 / 3 - t) * 6
            end
            return p
        end

        local q
        if l < 0.5 then
            q = l * (1 + s)
        else
            q = l + s - l * s
        end
        local p = 2 * l - q

        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1 / 3)
    end

    return {r * 255, g * 255, b * 255, a * 255}
end

local function hexVal(hash, index, length)
    local length = length or 1
    length = length - 1

    local index = index + 1
    local substring = hash:sub(index, index + length)
    local result = tonumber(substring, 16)
    return result + 0.0
end

local function map(value, vMin, vMax, dMin, dMax)
    local vValue = value + 0.0
    local vRange = 0.0 + vMax - vMin
    local dRange = 0.0 + dMax - dMin
    return dMin + ((vValue - vMin) * dRange) / vRange
end

local function fillColor(val)
    val = val + 0.0
    return (val % 2 == 0) and FILL_COLOR_LIGHT or FILL_COLOR_DARK
end

local function fillOpacity(val)
    local opacity = map(val, 0, 15, OPACITY_MIN, OPACITY_MAX)
    return opacity
end

function GeoPattern:new(str, options)
    self.opts = {
        baseColor = DEFAULTS.baseColor
    }

    if options then
        if options.generator then self.opts.generator = options.generator end
        if options.color then self.opts.color = options.color end
        if options.baseColor then self.opts.baseColor = options.baseColor end        
    end

    self.hash = sha1.sha1(str)
    self.svg = Svg()
    self:generateBackground()
    self:generatePattern()
    return self
end

function GeoPattern:generateBackground()
    local baseColor = {}
    local hueOffset = {}
    local rgb = {}
    local satOffset = {}

    if self.opts.color then
        rgb = hex2rgb(self.opts.color)
    else
        local hue = hexVal(self.hash, 14, 3)
        hueOffset = map(hue, 0, 4095, 0, 359)
        satOffset = hexVal(self.hash, 17)

        baseColor = rgb2hsl(hex2rgb(self.opts.baseColor))
        baseColor.h = (((baseColor.h * 360 - hueOffset) + 360) % 360) / 360;

        if satOffset % 2 == 0 then
            baseColor.s = math.min(1, ((baseColor.s * 100) + satOffset) / 100);
        else
            baseColor.s = math.max(0, ((baseColor.s * 100) - satOffset) / 100);
        end
        rgb = hsl2rgb(baseColor)
    end

    self.color = rgb
    self.svg:rect(0, 0, '100%', '100%', {
        fill = string.format('rgb(%d, %d, %d)', rgb[1] * 255, rgb[2] * 255, rgb[3] * 255)
    })
end

function table.indexOf(t, object)
    if type(t) ~= "table" then
        error("table expected, got " .. type(t), 2)
    end

    for i, v in pairs(t) do
        if object == v then
            return i
        end
    end
end

function GeoPattern:toSvg()
    return self.svg:toString()
end

function GeoPattern:toBase64()
    local str = self:toSvg():gsub("\n", "")
    return base64.encode(str)
end

function GeoPattern:generatePattern()
    local generator = self.opts.generator

    if generator then
        if table.indexOf(PATTERNS, generator) < 0 then
            error("Generator doesn't exist", 1)
        end
    else
        local index = hexVal(self.hash, 20) % #PATTERNS + 1
        generator = PATTERNS[index]
    end
    
    return self[generator](self);
end

local function buildHexagonShape(sideLength)
    local c = sideLength
    local a = c / 2
    local b = math.sin(60 * math.pi / 180) * c

    return string.format('0, %f, %f, 0, %f, 0, %f, %f, %f, %f, %f, %f, 0, %f', b, a, a + c, 2 * c, b, a + c, 2 * b, a,
               2 * b, b)
end

function GeoPattern:hexagons()
    local scale = hexVal(self.hash, 0)
    local sideLength = map(scale, 0, 15, 8, 60)
    local hexHeight = sideLength * math.sqrt(3)
    local hexWidth = sideLength * 2
    local hex = buildHexagonShape(sideLength)

    self.svg:setWidth(hexWidth * 3 + sideLength * 3)
    self.svg:setHeight(hexHeight * 6)

    local dy, fill, opacity, styles, val = {}, {}, {}, {}, {}
    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            val = hexVal(self.hash, i)
            dy = x % 2 == 0 and y * hexHeight or y * hexHeight + hexHeight / 2
            opacity = fillOpacity(val)
            fill = fillColor(val)
            styles = {
                ['fill'] = fill,
                ['opacity'] = opacity,
                ['stroke'] = STROKE_COLOR,
                ['stroke-opacity'] = STROKE_OPACITY,
                ['transform'] = string.format('translate(%f, %f)', x * sideLength * 1.5 - hexWidth / 2,
                    dy - hexHeight / 2)
            };
            self.svg:polyline(hex, styles)

            if x == 0 then
                styles.transform = string.format('translate(%f, %f)', 6 * sideLength * 1.5 - hexWidth / 2,
                                       dy - hexHeight / 2)
                self.svg:polyline(hex, styles)
            end

            if y == 0 then
                dy = x % 2 == 0 and 6 * hexHeight or 6 * hexHeight + hexHeight / 2
                styles.transform = string.format('translate(%f, %f)', x * sideLength * 1.5 - hexWidth / 2,
                                       dy - hexHeight / 2)
                self.svg:polyline(hex, styles)
            end

            if x == 0 and y == 0 then
                styles.transform = string.format('translate(%f, %f)', 6 * sideLength * 1.5 - hexWidth / 2,
                                       5 * hexHeight + hexHeight / 2)
                self.svg:polyline(hex, styles)
            end
            i = i + 1
        end
    end
end

function GeoPattern:sineWaves()
    local period = math.floor(map(hexVal(self.hash, 0), 0, 15, 100, 400));
    local amplitude = math.floor(map(hexVal(self.hash, 1), 0, 15, 30, 100));
    local waveWidth = math.floor(map(hexVal(self.hash, 2), 0, 15, 3, 30));

    self.svg:setWidth(period)
    self.svg:setHeight(waveWidth * 36)

    for i = 0, 35 do
        local val = hexVal(self.hash, i)
        local opacity = fillOpacity(val)
        local fill = fillColor(val)
        local xOffset = period / 4 * 0.7

        local str =
            'M0 ' .. amplitude .. ' C ' .. xOffset .. ' 0, ' .. (period / 2 - xOffset) .. ' 0, ' .. (period / 2) .. ' ' ..
                amplitude .. ' S ' .. (period - xOffset) .. ' ' .. (amplitude * 2) .. ', ' .. period .. ' ' .. amplitude ..
                ' S ' .. (period * 1.5 - xOffset) .. ' 0, ' .. (period * 1.5) .. ', ' .. amplitude

        local styles = {
            ['fill'] = 'none',
            ['stroke'] = fill,
            ['transform'] = string.format("translate(-%f, %f)", period / 4, waveWidth * i - amplitude * 1.5),
            ['style'] = {
                ['opacity'] = opacity,
                ['stroke-width'] = string.format("%fpx", waveWidth)
            }
        }
        self.svg:path(str, styles)

        styles['transform'] = string.format("translate(-%f, %f)", period / 4,
                                  waveWidth * i - amplitude * 1.5 + waveWidth * 36)
        self.svg:path(str, styles)
    end
end

function GeoPattern:overlappingCircles()
    local scale = hexVal(self.hash, 0)
    local diameter = map(scale, 0, 15, 25, 200)
    local radius = diameter / 2

    self.svg:setWidth(radius * 6)
    self.svg:setHeight(radius * 6)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local styles = {
                ['fill'] = fill,
                ['opacity'] = opacity
            }

            self.svg:circle(x * radius, y * radius, radius, styles)

            if x == 0 then
                self.svg:circle(x * radius, 6 * radius, radius, styles)
            end

            if x == 0 and y == 0 then
                self.svg:circle(6 * radius, 6 * radius, radius, styles)
            end

            i = i + 1
        end
    end
end

function GeoPattern:squares()
    local squareSize = map(hexVal(self.hash, 0), 0, 15, 10, 60);

    self.svg:setWidth(squareSize * 6)
    self.svg:setHeight(squareSize * 6)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local styles = {
                ['fill'] = fill,
                ['fill-opacity'] = opacity,
                ['stroke'] = STROKE_COLOR,
                ['stroke-opacity'] = STROKE_OPACITY
            }
            self.svg:rect(x * squareSize, y * squareSize, squareSize, squareSize, styles)

            i = i + 1
        end
    end
end

local function buildOctogonShape(squareSize)
    local s = squareSize
    local c = s * 0.33
    return string.format("%f, %f, %f, %f, %f, %f, %f, %f,%f, %f, %f, %f, %f, %f, %f, %f, %f,%f", c, 0, s - c, 0, s, c,
               s, s - c, s - c, s, c, s, 0, s - c, 0, c, c, 0)
end

function GeoPattern:octogons()
    local squareSize = map(hexVal(self.hash, 0), 0, 15, 10, 60);
    local tile = buildOctogonShape(squareSize)

    self.svg:setWidth(squareSize * 6)
    self.svg:setHeight(squareSize * 6)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local styles = {
                ['fill'] = fill,
                ['fill-opacity'] = opacity,
                ['stroke'] = STROKE_COLOR,
                ['stroke-opacity'] = STROKE_OPACITY,
                ['transform'] = string.format("translate(%f, %f)", x * squareSize, y * squareSize)
            }

            self.svg:polyline(tile, styles)
            i = i + 1
        end
    end
end

local function buildTriangleShape(sideLength, height)
    local halfWidth = sideLength / 2
    return string.format("%f, %f, %f, %f, %f, %f, %f, %f", halfWidth, 0, sideLength, height, 0, height, halfWidth, 0)
end

function GeoPattern:triangles()
    local scale = hexVal(self.hash, 0)
    local sideLength = map(scale, 0, 15, 15, 80)
    local triangleHeight = sideLength / 2 * math.sqrt(3)
    local triangle = buildTriangleShape(sideLength, triangleHeight)

    self.svg:setWidth(sideLength * 3)
    self.svg:setHeight(triangleHeight * 6)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local rotation = 0
            if y % 2 == 0 then
                rotation = x % 2 == 0 and 180 or 0
            else
                rotation = x % 2 ~= 0 and 180 or 0
            end

            local styles = {
                ['fill'] = fill,
                ['fill-opacity'] = opacity,
                ['stroke'] = STROKE_COLOR,
                ['stroke-opacity'] = STROKE_OPACITY,
                ['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)",
                    x * sideLength * 0.5 - sideLength / 2, triangleHeight * y, rotation, sideLength / 2,
                    triangleHeight / 2)
            }

            self.svg:polyline(triangle, styles)

            if x == 0 then
                styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)",
                                          6 * sideLength * 0.5 - sideLength / 2, triangleHeight * y, rotation,
                                          sideLength / 2, triangleHeight / 2)
                self.svg:polyline(triangle, styles)
            end

            i = i + 1
        end
    end
end

local function buildPlusShape(squareSize)
    return {string.format('<rect x = "%f" y = "%f" width = "%f" height = "%f"/>', squareSize, 0, squareSize,
        squareSize * 3),
            string.format('<rect x = "%f" y = "%f" width = "%f" height = "%f"/>', 0, squareSize, squareSize * 3,
        squareSize)}
end

function GeoPattern:plusSigns()
    local squareSize = map(hexVal(self.hash, 0), 0, 15, 10, 25)
    local plusSize = squareSize * 3
    local plusShape = buildPlusShape(squareSize)

    self.svg:setWidth(squareSize * 12)
    self.svg:setHeight(squareSize * 12)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)
            local dx = y % 2 == 0 and 0 or 1

            local styles = {
                ['fill'] = fill,
                ['stroke'] = STROKE_COLOR,
                ['stroke-opacity'] = STROKE_OPACITY,
                ['fill-opacity'] = opacity,
                ['transform'] = string.format("translate(%f, %f)",
                    x * plusSize - x * squareSize + dx * squareSize - squareSize,
                    y * plusSize - y * squareSize - plusSize / 2)
            }

            self.svg:group(plusShape, styles)

            if x == 0 then
                styles['transform'] = string.format("translate(%f, %f)",
                                          4 * plusSize - x * squareSize + dx * squareSize - squareSize,
                                          y * plusSize - y * squareSize - plusSize / 2)
                self.svg:group(plusShape, styles)
            end

            if y == 0 then
                styles['transform'] = string.format("translate(%f, %f)",
                                          x * plusSize - x * squareSize + dx * squareSize - squareSize,
                                          4 * plusSize - y * squareSize - plusSize / 2)
                self.svg:group(plusShape, styles)
            end

            if x == 0 and y == 0 then
                styles['transform'] = string.format("translate(%f, %f)",
                                          4 * plusSize - x * squareSize + dx * squareSize - squareSize,
                                          4 * plusSize - y * squareSize - plusSize / 2)
                self.svg:group(plusShape, styles)
            end

            i = i + 1
        end
    end
end

function GeoPattern:xes()
    local squareSize = map(hexVal(self.hash, 0), 0, 15, 10, 25)
    local xShape = buildPlusShape(squareSize)
    local xSize = squareSize * 3 * 0.943

    self.svg:setWidth(xSize * 3)
    self.svg:setHeight(xSize * 3)

    local i = 0
    for x = 0, 5 do
        for y = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)
            local dy = x % 2 == 0 and y * xSize - xSize * 0.5 or y * xSize - xSize * 0.5 + xSize / 4

            local styles = {
                ['fill'] = fill,
                ['opacity'] = opacity,
                ['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", x * xSize / 2 - xSize / 2,
                    dy - y * xSize / 2, 45, xSize / 2, xSize / 2)
            }

            self.svg:group(xShape, styles)

            if x == 0 then
                styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", 6 * xSize / 2 - xSize / 2,
                                          dy - y * xSize / 2, 45, xSize / 2, xSize / 2)
                self.svg:group(xShape, styles)
            end

            if y == 0 then
                dy = x % 2 == 0 and 6 * xSize - xSize / 2 or 6 * xSize - xSize / 2 + xSize / 4
                styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", x * xSize / 2 - xSize / 2,
                                          dy - 6 * xSize / 2, 45, xSize / 2, xSize / 2)
                self.svg:group(xShape, styles)
            end

            if y == 5 then
                styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", x * xSize / 2 - xSize / 2,
                                          dy - 11 * xSize / 2, 45, xSize / 2, xSize / 2)
                self.svg:group(xShape, styles)
            end

            if x == 0 and y == 0 then
                styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", 6 * xSize / 2 - xSize / 2,
                                          dy - 6 * xSize / 2, 45, xSize / 2, xSize / 2)
                self.svg:group(xShape, styles)
            end

            i = i + 1
        end
    end
end

function GeoPattern:overlappingRings()
    local scale = hexVal(self.hash, 0)
    local ringSize = map(scale, 0, 15, 10, 60)
    local strokeWidth = ringSize / 4

    self.svg:setWidth(ringSize * 6)
    self.svg:setHeight(ringSize * 6)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local styles = {
                ['fill'] = 'none',
                ['stroke'] = fill,
                ['opacity'] = opacity,
                ['stroke-width'] = string.format("%fpx", strokeWidth)
            }

            self.svg:circle(x * ringSize, y * ringSize, ringSize - strokeWidth / 2, styles)

            if x == 0 then
                self.svg:circle(6 * ringSize, y * ringSize, ringSize - strokeWidth / 2, styles)
            end

            if y == 0 then
                self.svg:circle(x * ringSize, 6 * ringSize, ringSize - strokeWidth / 2, styles)
            end

            if x == 0 and y == 0 then
                self.svg:circle(6 * ringSize, 6 * ringSize, ringSize - strokeWidth / 2, styles)
            end

            i = i + 1
        end
    end
end

function GeoPattern:concentricCircles()
    local scale = hexVal(self.hash, 0)
    local ringSize = map(scale, 0, 15, 10, 60)
    local strokeWidth = ringSize / 5

    self.svg:setWidth((ringSize + strokeWidth) * 6)
    self.svg:setHeight((ringSize + strokeWidth) * 6)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local styles = {
                ['fill'] = 'none',
                ['stroke'] = fill,
                ['opacity'] = opacity,
                ['stroke-width'] = string.format("%fpx", strokeWidth)
            }

            self.svg:circle(x * ringSize + x * strokeWidth + (ringSize + strokeWidth) / 2,
                y * ringSize + y * strokeWidth + (ringSize + strokeWidth) / 2, ringSize / 2, styles)

            val = hexVal(self.hash, 39 - i)
            opacity = fillOpacity(val)
            fill = fillColor(val)

            styles['fill'] = fill
            styles['fill-opacity'] = opacity
            self.svg:circle(x * ringSize + x * strokeWidth + (ringSize + strokeWidth) / 2,
                y * ringSize + y * strokeWidth + (ringSize + strokeWidth) / 2, ringSize / 4, styles)

            i = i + 1
        end
    end
end

local function buildChevronShape(width, height)
    local e = height * 0.66
    return string.format(
               '<polyline point="%f, %f, %f, %f, %f, %f, %f, %f, %f, %f"></polyline><polyline point="%f, %f, %f, %f, %f, %f, %f, %f, %f, %f"></polyline>',
               0, 0, width / 2, height - e, width / 2, height, 0, e, 0, 0, width / 2, height - e, width, 0, width, e,
               width / 2, height, width / 2, height - e)
end

function GeoPattern:chevrons()
    local chevronWidth = map(hexVal(self.hash, 0), 0, 15, 30, 80)
    local chevronHeight = map(hexVal(self.hash, 0), 0, 15, 30, 80)
    local chevron = buildChevronShape(chevronWidth, chevronHeight)

    self.svg:setWidth(chevronWidth * 6)
    self.svg:setHeight(chevronWidth * 6 * 0.66)

    local i = 0

    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local styles = {
                ['stroke'] = STROKE_COLOR,
                ['stroke-opacity'] = STROKE_OPACITY,
                ['fill'] = fill,
                ['fill-opacity'] = opacity,
                ['stroke-width'] = 1,
                ['transform'] = string.format("translate(%f, %f)", x * chevronWidth,
                    y * chevronHeight * 0.66 - chevronHeight / 2)
            }
            self.svg:group(chevron, styles)

            if y == 0 then
                styles['transform'] = string.format("translate(%f, %f)", x * chevronWidth,
                                          6 * chevronHeight * 0.66 - chevronHeight / 2)
                self.svg:group(chevron, styles)
            end

            i = i + 1
        end
    end
end

local function buildDiamondShape(width, height)
    return string.format('%f, %f, %f, %f, %f, %f, %f, %f', width / 2, 0, width, height / 2, width / 2, height, 0,
               height / 2)
end

function GeoPattern:diamonds()
    local diamondWidth = map(hexVal(self.hash, 0), 0, 15, 10, 50)
    local diamondHeight = map(hexVal(self.hash, 1), 0, 15, 10, 50)
    local diamond = buildDiamondShape(diamondWidth, diamondHeight)

    self.svg:setWidth(diamondWidth * 6)
    self.svg:setHeight(diamondHeight * 3)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)
            local dx = y % 2 == 0 and 0 or diamondWidth / 2

            local styles = {
                ['fill'] = fill,
                ['fill-opacity'] = opacity,
                ['stroke'] = STROKE_COLOR,
                ['stroke-opacity'] = STROKE_OPACITY,
                ['transform'] = string.format("translate(%f, %f)", x * diamondWidth - diamondWidth / 2 + dx,
                    diamondHeight / 2 * y - diamondHeight / 2)
            }

            self.svg:polyline(diamond, styles)

            if x == 0 then
                styles['transform'] = string.format("translate(%f, %f)", 6 * diamondWidth - diamondWidth / 2 + dx,
                                          diamondHeight / 2 * y - diamondHeight / 2)
                self.svg:polyline(diamond, styles)
            end

            if y == 0 then
                styles['transform'] = string.format("translate(%f, %f)", x * diamondWidth - diamondWidth / 2 + dx,
                                          diamondHeight / 2 * 6 - diamondHeight / 2)
                self.svg:polyline(diamond, styles)
            end

            if x == 0 and y == 0 then
                styles['transform'] = string.format("translate(%f, %f)", 6 * diamondWidth - diamondWidth / 2 + dx,
                                          diamondHeight / 2 * 6 - diamondHeight / 2)
                self.svg:polyline(diamond, styles)
            end

            i = i + 1
        end
    end
end

function GeoPattern:nestedSquares()
    local blockSize = map(hexVal(self.hash, 0), 0, 15, 4, 12)
    local squareSize = blockSize * 7
    local fill, i, opacity, styles, val, x, y

    self.svg:setWidth((squareSize + blockSize) * 6 + blockSize * 6)
    self.svg:setHeight((squareSize + blockSize) * 6 + blockSize * 6)

    local i = 0
    for y = 0, 5 do
        for x = 0, 5 do
            local val = hexVal(self.hash, i)
            local opacity = fillOpacity(val)
            local fill = fillColor(val)

            local styles = {
                ['fill'] = 'none',
                ['stroke'] = fill,
                ['opacity'] = opacity,
                ['stroke-width'] = string.format('%fpx', blockSize)
            }

            self.svg:rect(x * squareSize + x * blockSize * 2 + blockSize / 2,
                y * squareSize + y * blockSize * 2 + blockSize / 2, squareSize, squareSize, styles)

            val = hexVal(self.hash, 39 - i);
            opacity = fillOpacity(val);
            fill = fillColor(val);

            styles = {
                ['fill'] = 'none',
                ['stroke'] = fill,
                ['opacity'] = opacity,
                ['stroke-width'] = string.format('%fpx', blockSize)
            }

            self.svg:rect(x * squareSize + x * blockSize * 2 + blockSize / 2 + blockSize * 2,
                y * squareSize + y * blockSize * 2 + blockSize / 2 + blockSize * 2, blockSize * 3, blockSize * 3, styles)

            i = i + 1
        end
    end
end

function GeoPattern:plaid()
    local height = 0
    local width = 0

    local i = 0
    while i < 35 do
        local space = hexVal(self.hash, i)
        height = height + space + 5

        local val = hexVal(self.hash, i + 1)
        local opacity = fillOpacity(val)
        local fill = fillColor(val)
        local stripeHeight = val + 5

        self.svg:rect(0, height, '100%', stripeHeight, {
            ['opacity'] = opacity,
            ['fill'] = fill
        });

        height = height + stripeHeight
        i = i + 2
    end

    i = 0
    while i < 35 do
        local space = hexVal(self.hash, i)
        width = width + space + 5

        local val = hexVal(self.hash, i + 1)
        local opacity = fillOpacity(val)
        local fill = fillColor(val)
        local stripeWidth = val + 5

        self.svg:rect(width, 0, stripeWidth, '100%', {
            ['opacity'] = opacity,
            ['fill'] = fill
        });

        width = width + stripeWidth
        i = i + 2
    end

    self.svg:setWidth(width)
    self.svg:setHeight(height)
end

local function buildRotatedTriangleShape(sideLength, triangleWidth)
    local halfHeight = sideLength / 2
    return string.format('%f, %f, %f, %f, %f, %f, %f, %f', 0, 0, triangleWidth, halfHeight, 0, sideLength, 0, 0)
end

function GeoPattern:tessellation()
    local sideLength = map(hexVal(self.hash, 0), 0, 15, 5, 40)
    local hexHeight = sideLength * math.sqrt(3)
    local hexWidth = sideLength * 2
    local triangleHeight = sideLength / 2 * math.sqrt(3)
    local triangle = buildRotatedTriangleShape(sideLength, triangleHeight)
    local tileWidth = sideLength * 3 + triangleHeight * 2
    local tileHeight = (hexHeight * 2) + (sideLength * 2)

    self.svg:setWidth(tileWidth)
    self.svg:setHeight(tileHeight)

    for i = 0, 19 do
        local val = hexVal(self.hash, i)
        local opacity = fillOpacity(val)
        local fill = fillColor(val)

        local styles = {
            ['stroke'] = STROKE_COLOR,
            ['stroke-opacity'] = STROKE_OPACITY,
            ['fill'] = fill,
            ['fill-opacity'] = opacity,
            ['stroke-width'] = 1
        }

        if i == 0 then
            self.svg:rect(-sideLength / 2, -sideLength / 2, sideLength, sideLength, styles)
            self.svg:rect(tileWidth - sideLength / 2, -sideLength / 2, sideLength, sideLength, styles)
            self.svg:rect(-sideLength / 2, tileHeight - sideLength / 2, sideLength, sideLength, styles)
            self.svg:rect(tileWidth - sideLength / 2, tileHeight - sideLength / 2, sideLength, sideLength, styles)
        elseif i == 1 then
            self.svg:rect(hexWidth / 2 + triangleHeight, hexHeight / 2, sideLength, sideLength, styles)
        elseif i == 2 then
            self.svg:rect(-sideLength / 2, tileHeight / 2 - sideLength / 2, sideLength, sideLength, styles)
            self.svg:rect(tileWidth - sideLength / 2, tileHeight / 2 - sideLength / 2, sideLength, sideLength, styles)
        elseif i == 3 then
            self.svg:rect(hexWidth / 2 + triangleHeight, hexHeight * 1.5 + sideLength, sideLength, sideLength, styles)
        elseif i == 4 then
            styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", sideLength / 2, -sideLength / 2,
                                      0, sideLength / 2, triangleHeight / 2)
            self.svg:polyline(triangle, styles)

            styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f) scale(%f, %f)", sideLength / 2,
                                      tileHeight - -sideLength / 2, 0, sideLength / 2, triangleHeight / 2, 1, -1)
            self.svg:polyline(triangle, styles)
        elseif i == 5 then
            styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f) scale(%f, %f)",
                                      tileWidth - sideLength / 2, -sideLength / 2, 0, sideLength / 2,
                                      triangleHeight / 2, -1, 1)
            self.svg:polyline(triangle, styles)

            styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f) scale(%f, %f)",
                                      tileWidth - sideLength / 2, tileHeight + sideLength / 2, 0, sideLength / 2,
                                      triangleHeight / 2, -1, -1)
            self.svg:polyline(triangle, styles)
        elseif i == 6 then
            styles['transform'] = string.format("translate(%f, %f)", tileWidth / 2 + sideLength / 2, hexHeight / 2)
            self.svg:polyline(triangle, styles)
        elseif i == 7 then
            styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)",
                                      tileWidth - tileWidth / 2 - sideLength / 2, hexHeight / 2, -1, 1)
            self.svg:polyline(triangle, styles)
        elseif i == 8 then
            styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", tileWidth / 2 + sideLength / 2,
                                      tileHeight - hexHeight / 2, 1, -1)
            self.svg:polyline(triangle, styles)
        elseif i == 9 then
            styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)",
                                      tileWidth - tileWidth / 2 - sideLength / 2, tileHeight - hexHeight / 2, -1, -1)
            self.svg:polyline(triangle, styles)
        elseif i == 10 then
            styles['transform'] = string.format("translate(%f, %f)", sideLength / 2, tileHeight / 2 - sideLength / 2)
            self.svg:polyline(triangle, styles)
        elseif i == 11 then
            styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", tileWidth - sideLength / 2,
                                      tileHeight / 2 - sideLength / 2, -1, 1)
            self.svg:polyline(triangle, styles)
        elseif i == 12 then
            styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", sideLength / 2, sideLength / 2,
                                      -30, 0, 0)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        elseif i == 13 then
            styles['transform'] = string.format("scale(%f, %f) translate(%f, %f) rotate(%f, %f, %f)", -1, 1,
                                      -tileWidth + sideLength / 2, sideLength / 2, -30, 0, 0)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        elseif i == 14 then
            styles['transform'] = string.format("translate(%f, %f) rotate(%f, %f, %f)", sideLength / 2,
                                      tileHeight / 2 - sideLength / 2 - sideLength, 30, 0, sideLength)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        elseif i == 15 then
            styles['transform'] = string.format("scale(%f, %f) translate(%f, %f) rotate(%f, %f, %f)", -1, 1,
                                      -tileWidth + sideLength / 2, tileHeight / 2 - sideLength / 2 - sideLength, 30, 0,
                                      sideLength)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        elseif i == 16 then
            styles['transform'] = string.format("scale(%f, %f) translate(%f, %f) rotate(%f, %f, %f)", 1, -1,
                                      sideLength / 2, -tileHeight + tileHeight / 2 - sideLength / 2 - sideLength, 30, 0,
                                      sideLength)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        elseif i == 17 then
            styles['transform'] = string.format("scale(%f, %f) translate(%f, %f) rotate(%f, %f, %f)", -1, -1,
                                      -tileWidth + sideLength / 2,
                                      -tileHeight + tileHeight / 2 - sideLength / 2 - sideLength, 30, 0, sideLength)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        elseif i == 18 then
            styles['transform'] = string.format("scale(%f, %f) translate(%f, %f) rotate(%f, %f, %f)", 1, -1,
                                      sideLength / 2, -tileHeight + sideLength / 2, -30, 0, 0)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        elseif i == 19 then
            styles['transform'] = string.format("scale(%f, %f) translate(%f, %f) rotate(%f, %f, %f)", -1, -1,
                                      -tileWidth + sideLength / 2, -tileHeight + sideLength / 2, -30, 0, 0)
            self.svg:rect(0, 0, sideLength, sideLength, styles)
        end
    end
end

local function buildRightTriangleShape(sideLength)
    return string.format('%f, %f, %f, %f, %f, %f, %f, %f', 0, 0, sideLength, sideLength, 0, sideLength, 0, 0)
end

local function drawInnerMosaicTile(svg, x, y, triangleSize, vals)
    local triangle = buildRightTriangleShape(triangleSize)
    local opacity = fillOpacity(vals[1])
    local fill = fillColor(vals[1])
    local styles = {
        ['stroke'] = STROKE_COLOR,
        ['stroke-opacity'] = STROKE_OPACITY,
        ['fill-opacity'] = opacity,
        ['fill'] = fill,
        ['transform'] = string.format("translate(%f, %f) scale(%f, %f)", x + triangleSize, y, -1, 1)
    }
    svg:polyline(triangle, styles)

    styles['transform'] =
        string.format("translate(%f, %f) scale(%f, %f)", x + triangleSize, y + triangleSize * 2, 1, -1)
    svg:polyline(triangle, styles)

    opacity = fillOpacity(vals[2]);
    fill = fillColor(vals[2]);
    styles = {
        ['stroke'] = STROKE_COLOR,
        ['stroke-opacity'] = STROKE_OPACITY,
        ['fill-opacity'] = opacity,
        ['fill'] = fill
    }
    styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", x + triangleSize, y + triangleSize * 2, -1,
                              -1)
    svg:polyline(triangle, styles)

    styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", x + triangleSize, y, 1, 1)
    svg:polyline(triangle, styles)
end

local function drawOuterMosaicTile(svg, x, y, triangleSize, val)
    local opacity = fillOpacity(val);
    local fill = fillColor(val);
    local triangle = buildRightTriangleShape(triangleSize);
    local styles = {
        ['stroke'] = STROKE_COLOR,
        ['stroke-opacity'] = STROKE_OPACITY,
        ['fill-opacity'] = opacity,
        ['fill'] = fill
    }

    styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", x, y + triangleSize, 1, -1)
    svg:polyline(triangle, styles)

    styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", x + triangleSize * 2, y + triangleSize, -1,
                              -1)
    svg:polyline(triangle, styles)

    styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", x, y + triangleSize, 1, 1)
    svg:polyline(triangle, styles)

    styles['transform'] = string.format("translate(%f, %f) scale(%f, %f)", x + triangleSize * 2, y + triangleSize, 1, 1)
    svg:polyline(triangle, styles)
end

function GeoPattern:mosaicSquares()
    local triangleSize = map(hexVal(self.hash, 0), 0, 15, 15, 50)

    self.svg:setWidth(triangleSize * 8)
    self.svg:setHeight(triangleSize * 8)

    local i = 0
    for y = 0, 3 do
        for x = 0, 3 do
            if x % 2 == 0 then
                if y % 2 == 0 then
                    drawOuterMosaicTile(self.svg, x * triangleSize * 2, y * triangleSize * 2, triangleSize,
                        hexVal(self.hash, i))
                else
                    drawInnerMosaicTile(self.svg, x * triangleSize * 2, y * triangleSize * 2, triangleSize,
                        {hexVal(self.hash, i), hexVal(self.hash, i + 1)})
                end
            else
                if y % 2 == 0 then
                    drawInnerMosaicTile(self.svg, x * triangleSize * 2, y * triangleSize * 2, triangleSize,
                        {hexVal(self.hash, i), hexVal(self.hash, i + 1)})
                else
                    drawOuterMosaicTile(self.svg, x * triangleSize * 2, y * triangleSize * 2, triangleSize,
                        hexVal(self.hash, i))
                end
            end

            i = i + 1
        end
    end

end

return GeoPattern
