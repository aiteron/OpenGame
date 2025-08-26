local LettersZone = require "game.game_logic.letters_zone"
local InputZone = require "game.game_logic.input_zone"
local GlobalState = require "game.game_logic.global_state"

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

function M:load_words(level_num)
	local data_index = (level_num-1)%3 + 1

	local file_path = "/assets/level_data/" .. data_index .. ".json"
	local content = sys.load_resource(file_path)
	if content then
		local success, data = pcall(json.decode, content)
		if success then
			return data.words
		else
			print("JSON parse error (" .. file_path .. "): " .. data)
		end
	else
		print("Load json file error: " .. file_path)
	end
	return {"error"}
end

function M:load_level(level_num)
	self.words = self:load_words(level_num)
	table.sort(self.words, function(a, b) return utf8.len(a) > utf8.len(b) end)

	self.opened_words_indexes = {}
	self.opened_word_count = 0

	self.letter_zone = LettersZone:new(self, self.words)

	for i, w in ipairs(self.words) do
		if GlobalState.words[w] then
			self.opened_words_indexes[i] = true
			self.opened_word_count = self.opened_word_count + 1
			self.letter_zone:show_word(w)
		end
	end
	self:check_win()

	self.letters = self:get_letters(self.words)
	self.input_zone = InputZone:new(self, self.letters)
end

function M:on_window_resize(coeff)
	self.letter_zone:on_window_resize(coeff)
	self.input_zone:on_window_resize(coeff)
end

function M:on_input(id, action)
	self.input_zone:on_input(id, action)
end

function M:update(dt)
	self.input_zone:update(dt)
end

function M:check_win()
	if self.opened_word_count == #self.words then
		msg.post("_entry_point:/manager#script", "win")
	end
end

function M:enter_word(word)
	for i, w in ipairs(self.words) do
		if not self.opened_words_indexes[i] and word == w then
			self.opened_words_indexes[i] = true
			self.opened_word_count = self.opened_word_count + 1
			self.letter_zone:show_word(word)
			GlobalState.words[word] = true
			GlobalState:save()
			self:check_win()
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