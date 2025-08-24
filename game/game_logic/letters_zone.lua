local M = {}


function M:set_cells()
	for _, v in ipairs(self.letters) do
		go.delete(v)
	end
	self.letters = {}
	self.word_map = {}
	self.max_word_len = 0

	local center_pos = go.get_world_position("/letter_field/letter_field")
	local word_count = #self.words
	for i, word in ipairs(self.words) do
		local vshift = (i - 0.5 - word_count/2.0) * 78
		local word_length = utf8.len(word)
		self.max_word_len = math.max(word_length, self.max_word_len)
		self.word_map[word] = {}
		for j = 1, word_length do
			local letter = utf8.sub(word, j, j)
			local hshift = (j - 0.5 - word_length/2.0) * 78
			local letter_obj = factory.create("/letter_field/letter_field#letter_factory", vmath.vector3(center_pos.x + hshift, center_pos.y + vshift, center_pos.z))
			table.insert(self.word_map[word], letter_obj)
			table.insert(self.letters, letter_obj)
			label.set_text(msg.url(nil, letter_obj, "label"), utf8.upper(letter))
			msg.post(msg.url(nil, letter_obj, "label"), "disable")
		end
	end
	self:update_scale()
end

function M:update_scale()
	local word_count = #self.words

	local scale1 =  ((640 - 100) / self.xscale) / (self.max_word_len * 78)
	local scale2 =  400 / (word_count * 78)
	local scale = math.min(scale1, scale2)
	
	local center_pos = go.get_world_position("/letter_field/letter_field")
	
	for i, word in ipairs(self.words) do
		local objs = self.word_map[word]
		local vshift = (i - 0.5 - word_count/2.0) * 78 * scale
		local word_length = utf8.len(word)
		for j = 1, word_length do
			local hshift = (j - 0.5 - word_length/2.0) * 78 * scale * self.xscale
			go.set_position(vmath.vector3(center_pos.x + hshift, center_pos.y + vshift, center_pos.z), objs[j])
			go.set_scale(vmath.vector3(scale * self.xscale, scale, 1.0), objs[j])
		end
	end
end

function M:on_window_resize(coeff)
	self.xscale = coeff
	self:update_scale()
end

function M:show_word(word)
	if self.word_map[word] then
		for i, obj in ipairs(self.word_map[word]) do
			msg.post(msg.url(nil, obj, "label"), "enable")
			go.set(msg.url(nil, obj, "label"), "color", vmath.vector4(1.0))
			sprite.play_flipbook(msg.url(nil, obj, "sprite"), "cell_bg_selected")
		end
	end
end

function M:new(level, words)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.level = level
	o.xscale = 1.0
	
	o.words = words
	o.letters = {}
	o.word_map = {}

	o:set_cells()
	
	return o
end

return M