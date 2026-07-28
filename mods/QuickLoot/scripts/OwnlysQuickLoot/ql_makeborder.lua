local ui = require('openmw.ui')
local util = require('openmw.util')

local v2 = util.vector2

------------------------------ textures ------------------------------
local textureCache = {}
local function getTexture(path)
	if not textureCache[path] then
		textureCache[path] = ui.texture{ path = path }
	end
	return textureCache[path]
end

------------------------------ border pieces ------------------------------
local sideParts = {
	left = v2(0, 0),
	right = v2(1, 0),
	top = v2(0, 0),
	bottom = v2(0, 1),
}
local cornerParts = {
	top_left = v2(0, 0),
	top_right = v2(1, 0),
	bottom_left = v2(0, 1),
	bottom_right = v2(1, 1),
}
local borderPieceCache = {}

------------------------------ border builder ------------------------------
-- outset reaches past the content so an auto sizing Container grows around the frame
-- inset keeps the frame within a parent that already carries a size
local function makeBorder(path, thickness, color, borderSize, background, padding, outset)
	local pieces = borderPieceCache[path..thickness]
	if not pieces then
		pieces = {}
		for part in pairs(sideParts) do
			local horizontal = part == 'top' or part == 'bottom'
			pieces[part] = {
				type = ui.TYPE.Image,
				props = {
					resource = getTexture(path..('menu_%s_border_%s.dds'):format(thickness, part)),
					tileH = horizontal,
					tileV = not horizontal,
				},
			}
		end
		for part in pairs(cornerParts) do
			pieces[part] = {
				type = ui.TYPE.Image,
				props = {
					resource = getTexture(path..('menu_%s_border_%s_corner.dds'):format(thickness, part)),
				},
			}
		end
		borderPieceCache[path..thickness] = pieces
	end
	local borderV = v2(1, 1) * borderSize
	-- slot sits this far in, padding buys clearance on top of the frame itself
	local inset = borderSize + (padding or 0)
	local insetV = v2(1, 1) * inset
	-- outset pieces land this far past the content, which is what drags a Container's size out
	local reach = 2 * inset - borderSize
	local borders = {
		content = ui.content {},
	}
	if background then
		-- the parent grew, stretch the background back over the whole frame
		if outset then background.props.size = insetV * 2 end
		borders.content:add(background)
	end
	for part, v in pairs(sideParts) do
		local horizontal = part == 'top' or part == 'bottom'
		local direction = horizontal and v2(1, 0) or v2(0, 1)
		local position = (direction - v) * borderSize
		local size = (v2(1, 1) - direction * 3) * borderSize
		if outset then
			position = direction * borderSize + v * reach
			size = (v2(1, 1) - direction) * borderSize + direction * (reach - borderSize)
		end
		borders.content:add {
			template = pieces[part],
			props = {
				position = position,
				relativePosition = v,
				size = size,
				relativeSize = direction,
				color = color,
				alpha = color and color.a or nil,
			}
		}
	end
	for part, v in pairs(cornerParts) do
		borders.content:add {
			template = pieces[part],
			props = {
				position = outset and v * reach or -v * borderSize,
				relativePosition = v,
				size = borderV,
				color = color,
				alpha = color and color.a or nil,
			},
		}
	end
	local slot = {
		external = { slot = true },
		props = {
			position = insetV,
			relativeSize = v2(1, 1),
		}
	}
	-- inset has no room to grow into, pull the slot in instead
	if not outset then slot.props.size = insetV * -2 end
	borders.content:add(slot)
	return borders
end

return makeBorder
