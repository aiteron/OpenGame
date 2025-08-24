local M = {}

function M:set_buttons()
	for _, v in ipairs(self.buttons) do
		go.delete(v.btn)
	end
	self.buttons = {}

	local count = #self.letters
	local rotation_angle_shift = vmath.quat_rotation_z((math.pi*2)/count)
	local center = go.get_world_position("/input_circle/circle")
	local pos = go.get_world_position("/input_circle/letter_pos") - center
	for i = 1, count do
		local button = factory.create("/input_circle/circle#button_factory", center + vmath.vector3(pos.x * self.xscale, pos.y, pos.z))
		go.set_scale(vmath.vector3(self.xscale, 1.0, 1.0), button)
		table.insert(self.buttons, {btn = button, letter = self.letters[i]})
		label.set_text(msg.url(nil, button, "label"), utf8.upper(self.letters[i]))
		pos = vmath.rotate(rotation_angle_shift, pos)
	end
end

function M:set_word()
	for _, v in ipairs(self.word_objs) do
		go.delete(v)
	end
	self.word_objs = {}

	local count = #self.entered_letters
	local center_pos = go.get_world_position("/input_circle/word_pos")
	for i = 1, count do
		local shift = (i - 0.5 - count/2.0) * 46
		local letter_obj = factory.create("/input_circle/circle#letter_factory", vmath.vector3(center_pos.x + shift*self.xscale, center_pos.y, center_pos.z))
		go.set_scale(vmath.vector3(self.xscale, 1.0, 1.0), letter_obj)
		table.insert(self.word_objs, letter_obj)
		label.set_text(msg.url(nil, letter_obj, "label"), utf8.upper(self.entered_letters[i]))
	end
end

function M:on_window_resize(coeff)
	self.xscale = coeff
	self:set_buttons()
	self:set_word()
	go.set_scale(vmath.vector3(coeff, 1.0, 1.0), "/input_circle/circle#background")
end

function M:update_buttons_color()
	for i, data in ipairs(self.buttons) do
		if self.selected_indexes[i] then
			sprite.play_flipbook(msg.url(nil, data.btn, "sprite"), "input_letter_bg_selected")
			go.set(msg.url(nil, data.btn, "label"), "color", vmath.vector4(1.0, 1.0, 1.0, 1.0))
		else
			sprite.play_flipbook(msg.url(nil, data.btn, "sprite"), "input_letter_bg")
			go.set(msg.url(nil, data.btn, "label"), "color", vmath.vector4(77/255, 77/255, 77/255, 1.0))
		end
	end
end

function M:on_input(action)
	--pprint(action)
	if action.pressed then
		if not self.is_input then
			self.is_input = true
		end
	elseif action.released then
		if self.is_input then
			if #self.entered_letters > 0 then
				local str = table.concat(self.entered_letters)
				self.level:enter_word(str)
			end
			self.is_input = false
			self.selected_indexes = {}
			self.entered_letters = {}
			self:set_word()
			self:update_buttons_color()
		end
	else
		if self.is_input then
			local point_vec = vmath.vector3(action.x, action.y, 0);
			for i, data in ipairs(self.buttons) do
				if not self.selected_indexes[i] then
					if vmath.length(go.get_world_position(data.btn) - point_vec) < 55 then
						self.selected_indexes[i] = true
						table.insert(self.entered_letters, data.letter)
						self:set_word()
						self:update_buttons_color()
					end
				end
			end
		end
	end
end

function M:new(level, letters)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.level = level
	o.xscale = 1
	
	o.letters = letters
	o.buttons = {}
	o:set_buttons()

	o.is_input = false
	o.entered_letters = {}
	o.selected_indexes = {}
	o.word_objs = {}
	o:set_word()
	
	return o
end

return M