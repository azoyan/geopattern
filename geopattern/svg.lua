local Svg = {}

Svg.__index = Svg

setmetatable(Svg, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:_new(...)
        return self
    end
})

function Svg:_new()
    self.width = 100
    self.height = 100
    self.svg_string = ""
end

function Svg:height()
    return self.height
end

function Svg:setHeight(height)
    self.height = math.floor(height)
end

function Svg:setWidth(width)
    self.width = math.floor(width)
end

function Svg:header()
    local header = '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">'
    return header:format(self.width, self.height)
end

function Svg:closer()
    return '</svg>'
end

function Svg:toString()
    return table.concat({self:header(), self.svg_string, self:closer()}, '')
end

local function formattingSymbolAndNumber(number)
    if type(number) == "number" then
        return {
            symbol = "%0.16f",
            value = number
        }
    else
        return {
            symbol = "%s",
            value = number
        }
    end
end

function Svg:rect(x, y, width, height, args)
    local width = formattingSymbolAndNumber(width)
    local height = formattingSymbolAndNumber(height)
    local template = '<rect x="%f" y="%f" width="' .. width.symbol .. '" height="' .. height.symbol .. '" %s/>'
    local str = template:format(x, y, width.value, height.value, self:write_args(args))
    self.svg_string = self.svg_string .. str
end

function Svg:circle(x, y, radius, args)
    local radius = formattingSymbolAndNumber(radius)
    local template = '<circle cx="%f" cy="%f" r="' .. radius.symbol .. '" %s/>'
    local str = template:format(x, y, radius.value, self:write_args(args))
    self.svg_string = self.svg_string .. str

end

function Svg:path(str, args)
    self.svg_string = self.svg_string .. string.format('<path d="%s" %s/>', str, self:write_args(args))
end

function Svg:polyline_str(str, args)
    return string.format('<polyline points="%s" %s/>', str, self:write_args(args))
end

function Svg:polyline(str, args)
    self.svg_string = self.svg_string .. string.format('<polyline points="%s" %s/>', str, self:write_args(args))
end

function Svg:group(elements, args)
    self.svg_string = self.svg_string .. string.format('<g %s>', self:write_args(args))
    if type(elements) == "string" then
        self.svg_string = self.svg_string .. elements
    else
        for key, value in pairs(elements) do
            self.svg_string = self.svg_string .. ' ' .. value
        end
    end
    self.svg_string = self.svg_string .. '</g>'
end

function Svg:write_args(args)
    local str = ''
    for key, value in pairs(args) do
        if type(value) == "table" then
            for k, v in pairs(value) do
                str = str .. string.format(' %s="%s"', k, v)
            end
        else
            str = str .. string.format(' %s="%s"', key, value)
        end
    end
    return str
end

return Svg
