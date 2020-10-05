# geopattern
![geopattern example](https://github.com/azoyan/geopattern/blob/media/geopattern.gif)

**Lua** implemenation of [geopatterns (Ruby library)][2] by [Jason Long][1].

Generate beautiful SVG patterns from a string.

[1]: https://github.com/jasonlong/
[2]: https://github.com/jasonlong/geopatterns/

## Installation
```shell
git clone https://github.com/azoyan/geopattern.git
```

## Usage
Create a new pattern by calling `GeoPattern:new()` with a string and a
generator (the result of this string/generator pair is the above image).

```Lua
local GeoPattern = require "geopattern"

local geo = GeoPattern:new("GitHub")
print(geo:toSvg())
```

### API

#### `GeoPattern:new(string, options)`

Returns a newly-generated, tiling SVG Pattern.

- `string` Will be hashed using the SHA1 algorithm, and the resulting hash will be used as the seed for generation.

- `options.color` Specify an exact background color. This is a CSS hexadecimal color value.

- `options.baseColor` Controls the relative background color of the generated image. The color is not identical to that used in the pattern because the hue is rotated by the generator. This is a CSS hexadecimal color value, which defaults to `#933c3c`.

- `options.generator` Determines the pattern. [All of the original patterns](https://github.com/jasonlong/geo_pattern#available-patterns) are available in this port, and their names are camelCased.
  
  Available Patterns:
  - `"octogons"`
  - `"overlappingCircles"`
  - `"plusSigns"`
  - `"xes'"`
  - `"sineWaves"`
  - `"hexagons"`
  - `"overlappingRings"`
  - `"plaid"`
  - `"triangles"`
  - `"squares"`
  - `"concentricCircles"`
  - `"diamonds"`
  - `"tessellation"`
  - `"nestedSquares'"`
  - `"mosaicSquares"`
  - `"chevrons"`

```Lua
local GeoPattern = require "geopattern"

local pattern1 = GeoPattern:new("GitHub") -- without options 
local pattern3 = GeoPattern:new("GitHub", { color = "#00ffff" })
local pattern2 = GeoPattern:new("GitHub", { generator = "concentricCircles" })

local options = {
    generator = "concentricCircles",
    color = "#00ffff", 
    baseColor = "#af39b3"
}
local pattern4 = GeoPattern:new("GitHub", options) -- with all available options
```

#### `GeoPattern:toSvg()`
Returns the SVG string representing the pattern.

```Lua
local GeoPattern = require "geopattern"

local pattern = GeoPattern:new("GitHub")
local svg = pattern:toSvg() -- string in SVG format

print(svg)
```
#### Output:
```xml
<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160"><rect x="0" y="0" width="100%" height="100%"  fill="rgb(69, 93, 137)"/><rect x="0" y="0" width="26.666666666667" height="26.666666666667"  fill-opacity="0.063333333333333" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="26" y="0" width="26.666666666667" height="26.666666666667"  fill-opacity="0.054666666666667" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="53" y="0" width="26.666666666667" height="26.666666666667"  fill-opacity="0.054666666666667" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="80" y="0" width="26.666666666667" height="26.666666666667"  fill-opacity="0.037333333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="106" y="0" width="26.666666666667" height="26.666666666667"  fill-opacity="0.14133333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="133" y="0" width="26.666666666667" height="26.666666666667"  fill-opacity="0.037333333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="0" y="26" width="26.666666666667" height="26.666666666667"  fill-opacity="0.11533333333333" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="26" y="26" width="26.666666666667" height="26.666666666667"  fill-opacity="0.072" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="53" y="26" width="26.666666666667" height="26.666666666667"  fill-opacity="0.054666666666667" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="80" y="26" width="26.666666666667" height="26.666666666667"  fill-opacity="0.15" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="106" y="26" width="26.666666666667" height="26.666666666667"  fill-opacity="0.10666666666667" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="133" y="26" width="26.666666666667" height="26.666666666667"  fill-opacity="0.02" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="0" y="53" width="26.666666666667" height="26.666666666667"  fill-opacity="0.098" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="26" y="53" width="26.666666666667" height="26.666666666667"  fill-opacity="0.080666666666667" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="53" y="53" width="26.666666666667" height="26.666666666667"  fill-opacity="0.072" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="80" y="53" width="26.666666666667" height="26.666666666667"  fill-opacity="0.054666666666667" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="106" y="53" width="26.666666666667" height="26.666666666667"  fill-opacity="0.11533333333333" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="133" y="53" width="26.666666666667" height="26.666666666667"  fill-opacity="0.098" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="0" y="80" width="26.666666666667" height="26.666666666667"  fill-opacity="0.15" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="26" y="80" width="26.666666666667" height="26.666666666667"  fill-opacity="0.063333333333333" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="53" y="80" width="26.666666666667" height="26.666666666667"  fill-opacity="0.098" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="80" y="80" width="26.666666666667" height="26.666666666667"  fill-opacity="0.046" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="106" y="80" width="26.666666666667" height="26.666666666667"  fill-opacity="0.089333333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="133" y="80" width="26.666666666667" height="26.666666666667"  fill-opacity="0.072" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="0" y="106" width="26.666666666667" height="26.666666666667"  fill-opacity="0.080666666666667" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="26" y="106" width="26.666666666667" height="26.666666666667"  fill-opacity="0.14133333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="53" y="106" width="26.666666666667" height="26.666666666667"  fill-opacity="0.063333333333333" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="80" y="106" width="26.666666666667" height="26.666666666667"  fill-opacity="0.098" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="106" y="106" width="26.666666666667" height="26.666666666667"  fill-opacity="0.10666666666667" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="133" y="106" width="26.666666666667" height="26.666666666667"  fill-opacity="0.098" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="0" y="133" width="26.666666666667" height="26.666666666667"  fill-opacity="0.080666666666667" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="26" y="133" width="26.666666666667" height="26.666666666667"  fill-opacity="0.037333333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="53" y="133" width="26.666666666667" height="26.666666666667"  fill-opacity="0.098" stroke="#000" stroke-opacity="0.02" fill="#222"/><rect x="80" y="133" width="26.666666666667" height="26.666666666667"  fill-opacity="0.037333333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="106" y="133" width="26.666666666667" height="26.666666666667"  fill-opacity="0.124" stroke="#000" stroke-opacity="0.02" fill="#ddd"/><rect x="133" y="133" width="26.666666666667" height="26.666666666667"  fill-opacity="0.089333333333333" stroke="#000" stroke-opacity="0.02" fill="#ddd"/></svg>
```

#### `GeoPattern:toBase64()`
Returns Base64-encoded string representing the pattern.

```Lua
local GeoPattern = require "geopattern"

local pattern = GeoPattern:new("GitHub")
local base64 = pattern:toBae64() -- encode to Base64 string

print(base64)
```
#### Output:
```base64
PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNjAiIGhlaWdodD0iMTYwIj48cmVjdCB4PSIwIiB5PSIwIiB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiAgZmlsbD0icmdiKDY5LCA5MywgMTM3KSIvPjxyZWN0IHg9IjAiIHk9IjAiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjA2MzMzMzMzMzMzMzMzMyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iIzIyMiIvPjxyZWN0IHg9IjI2IiB5PSIwIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wNTQ2NjY2NjY2NjY2NjciIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSI1MyIgeT0iMCIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMDU0NjY2NjY2NjY2NjY3IiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjZGRkIi8+PHJlY3QgeD0iODAiIHk9IjAiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjAzNzMzMzMzMzMzMzMzMyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iI2RkZCIvPjxyZWN0IHg9IjEwNiIgeT0iMCIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMTQxMzMzMzMzMzMzMzMiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSIxMzMiIHk9IjAiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjAzNzMzMzMzMzMzMzMzMyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iI2RkZCIvPjxyZWN0IHg9IjAiIHk9IjI2IiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4xMTUzMzMzMzMzMzMzMyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iIzIyMiIvPjxyZWN0IHg9IjI2IiB5PSIyNiIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMDcyIiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjZGRkIi8+PHJlY3QgeD0iNTMiIHk9IjI2IiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wNTQ2NjY2NjY2NjY2NjciIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSI4MCIgeT0iMjYiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjE1IiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjMjIyIi8+PHJlY3QgeD0iMTA2IiB5PSIyNiIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMTA2NjY2NjY2NjY2NjciIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSIxMzMiIHk9IjI2IiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wMiIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iI2RkZCIvPjxyZWN0IHg9IjAiIHk9IjUzIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wOTgiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiMyMjIiLz48cmVjdCB4PSIyNiIgeT0iNTMiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjA4MDY2NjY2NjY2NjY2NyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iIzIyMiIvPjxyZWN0IHg9IjUzIiB5PSI1MyIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMDcyIiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjZGRkIi8+PHJlY3QgeD0iODAiIHk9IjUzIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wNTQ2NjY2NjY2NjY2NjciIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSIxMDYiIHk9IjUzIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4xMTUzMzMzMzMzMzMzMyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iIzIyMiIvPjxyZWN0IHg9IjEzMyIgeT0iNTMiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjA5OCIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iIzIyMiIvPjxyZWN0IHg9IjAiIHk9IjgwIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4xNSIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iIzIyMiIvPjxyZWN0IHg9IjI2IiB5PSI4MCIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMDYzMzMzMzMzMzMzMzMzIiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjMjIyIi8+PHJlY3QgeD0iNTMiIHk9IjgwIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wOTgiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiMyMjIiLz48cmVjdCB4PSI4MCIgeT0iODAiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjA0NiIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iIzIyMiIvPjxyZWN0IHg9IjEwNiIgeT0iODAiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjA4OTMzMzMzMzMzMzMzMyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iI2RkZCIvPjxyZWN0IHg9IjEzMyIgeT0iODAiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjA3MiIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iI2RkZCIvPjxyZWN0IHg9IjAiIHk9IjEwNiIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMDgwNjY2NjY2NjY2NjY3IiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjMjIyIi8+PHJlY3QgeD0iMjYiIHk9IjEwNiIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMTQxMzMzMzMzMzMzMzMiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSI1MyIgeT0iMTA2IiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wNjMzMzMzMzMzMzMzMzMiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiMyMjIiLz48cmVjdCB4PSI4MCIgeT0iMTA2IiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wOTgiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiMyMjIiLz48cmVjdCB4PSIxMDYiIHk9IjEwNiIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMTA2NjY2NjY2NjY2NjciIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSIxMzMiIHk9IjEwNiIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMDk4IiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjMjIyIi8+PHJlY3QgeD0iMCIgeT0iMTMzIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wODA2NjY2NjY2NjY2NjciIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiMyMjIiLz48cmVjdCB4PSIyNiIgeT0iMTMzIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wMzczMzMzMzMzMzMzMzMiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSI1MyIgeT0iMTMzIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wOTgiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiMyMjIiLz48cmVjdCB4PSI4MCIgeT0iMTMzIiB3aWR0aD0iMjYuNjY2NjY2NjY2NjY3IiBoZWlnaHQ9IjI2LjY2NjY2NjY2NjY2NyIgIGZpbGwtb3BhY2l0eT0iMC4wMzczMzMzMzMzMzMzMzMiIHN0cm9rZT0iIzAwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuMDIiIGZpbGw9IiNkZGQiLz48cmVjdCB4PSIxMDYiIHk9IjEzMyIgd2lkdGg9IjI2LjY2NjY2NjY2NjY2NyIgaGVpZ2h0PSIyNi42NjY2NjY2NjY2NjciICBmaWxsLW9wYWNpdHk9IjAuMTI0IiBzdHJva2U9IiMwMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjAyIiBmaWxsPSIjZGRkIi8+PHJlY3QgeD0iMTMzIiB5PSIxMzMiIHdpZHRoPSIyNi42NjY2NjY2NjY2NjciIGhlaWdodD0iMjYuNjY2NjY2NjY2NjY3IiAgZmlsbC1vcGFjaXR5PSIwLjA4OTMzMzMzMzMzMzMzMyIgc3Ryb2tlPSIjMDAwIiBzdHJva2Utb3BhY2l0eT0iMC4wMiIgZmlsbD0iI2RkZCIvPjwvc3ZnPg==
```
