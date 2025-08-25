local M = {}

function M:set_pos(pos)
	go.set_position(pos, self.id)
end

function M:get_pos()
	return go.get_position(self.id)
end

function M:set_xscale(scale)
	self.xscale = scale
	go.set_scale(vmath.vector3(self.xscale * (self.selected and 1.2 or 1), self.selected and 1.2 or 1, 1.0), self.id)
end

function M:is_intersect(x, y)
	local pos = go.get_world_position(self.id)
	local point = vmath.vector3(x, y, 0)
	return vmath.length(pos - point) < 50
end

function M:set_selected(val)
	if self.selected ~= val then
		if val then
			sprite.play_flipbook(msg.url(nil, self.id, "sprite"), "input_letter_bg_selected")
			go.set(msg.url(nil, self.id, "label"), "color", vmath.vector4(1.0, 1.0, 1.0, 1.0))
			go.set_scale(vmath.vector3(self.xscale * 1.2, 1.2, 1.0), self.id)
		else
			sprite.play_flipbook(msg.url(nil, self.id, "sprite"), "input_letter_bg")
			go.set(msg.url(nil, self.id, "label"), "color", vmath.vector4(77/255, 77/255, 77/255, 1.0))
			go.set_scale(vmath.vector3(self.xscale, 1.0, 1.0), self.id)
		end
		self.selected = val
	end
end

function M:new(letter, pos, xscale)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.xscale = 1.0
	o.selected = false
	
	o.letter = letter
	o.id = factory.create("/input_circle/circle#button_factory", pos)
	label.set_text(msg.url(nil, o.id, "label"), utf8.upper(letter))
	
	return o
end


return M