local LettersZone = require "game.game_logic.letters_zone"
local InputZone = require "game.game_logic.input_zone"

local M = {}

local function get_letters_from_word(word)
	local res = {}
	for i = 1, utf8.len(word) do
		local letter = utf8.sub(word, i, i)
		res[letter] = (res[letter] == nil) and 1 or res[letter] + 1
	end
	return res
end

function M:get_letters(words)
	local res = {}
	for _, w in ipairs(words) do
		local letters = get_letters_from_word(w)
		for k, v in pairs(letters) do
			if res[k] then
				res[k] = math.max(res[k], v)
			else
				res[k] = v
			end
		end
	end

	local letters = {}
	for k, v in pairs(res) do
		for i = 1, v do
			table.insert(letters, k)
		end
	end
	
	return letters
end

function M:load_level(level_num)
	-- TODO: load from json
	self.words = {"брат","араб","тара","бар","раб","бра"}
	self.open_word_indexes = {}
	
	self.letter_zone = LettersZone:new(self, self.words)

	self.letters = self:get_letters(self.words)
	self.input_zone = InputZone:new(self, self.letters)
end

function M:on_window_resize(coeff)
	self.letter_zone:on_window_resize(coeff)
	self.input_zone:on_window_resize(coeff)
end

function M:on_input(action)
	self.input_zone:on_input(action)
end

function M:enter_word(word)
	for i, w in ipairs(self.words) do
		if not self.open_word_indexes[i] and word == w then
			self.open_word_indexes[i] = true
			self.letter_zone:show_word(word)
		end
	end
end

function M:new(level_num)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o:load_level(level_num)
	
	return o
end


return M