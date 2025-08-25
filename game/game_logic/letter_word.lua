local M = {}

function M:set_pos(pos)
	self.center_pos = pos
	self:update_layout()
end

function M:set_xscale(scale)
	self.xscale = scale
	self:update_layout()
end

function M:add_letter(letter)
	local id = factory.create("/input_circle/circle#letter_factory")
	label.set_text(msg.url(nil, id, "label"), utf8.upper(letter))
	table.insert(self.letters, id)
	
	self:update_layout()
end

function M:remove_letter()
	go.delete(self.letters[#self.letters])
	table.remove(self.letters, #self.letters)
	
	self:update_layout()
end

function M:update_layout()
	for i = 1, #self.letters do
		local id = self.letters[i]
		local shift = (i - 0.5 - #self.letters/2.0) * 46
		go.set_position(vmath.vector3(self.center_pos.x + shift*self.xscale, self.center_pos.y, self.center_pos.z), id)
		go.set_scale(vmath.vector3(self.xscale, 1.0, 1.0), id)		
	end
end

function M:clear()
	for i = 1, #self.letters do
		go.delete(self.letters[i])
	end
	self.letters = {}
end

function M:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.center_pos = {x = 0, y = 0, z = 0}
	o.letters = {}
	o.xscale = 1.0
	
	return o
end


return M