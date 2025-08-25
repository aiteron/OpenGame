local Spline = require "game.game_logic.spline"
local LetterButton = require "game.game_logic.letter_button"
local LetterWord = require "game.game_logic.letter_word"

local M = {}

function M:get_selected_button(x, y)
	for _, btn in ipairs(self.buttons) do
		if btn:is_intersect(x, y) then
			return btn
		end
	end
end

function M:on_input(id, action)
	if id == hash("touch") then
		if action.pressed then
			-- Maybe problem if unclick not on the screen
			if not self.input_action then
				self.input_action = { selected = {}, current = nil, selected_list = {} }
			end
		elseif action.released then
			if self.input_action then
				if #self.input_action.selected_list > 0 then
					local tab = {}
					for _, v in ipairs(self.input_action.selected_list) do
						table.insert(tab, v.letter)
					end
					self.level:enter_word(table.concat(tab))
				end
				
				for btn, _ in pairs(self.input_action.selected) do
					btn:set_selected(false)
				end
				self.word:clear()
				self.spline:clear_points()
				self.input_action = { selected = {}, current = nil, selected_list = {} }
			end
		else
			self.spline:update_mouse_point(action.x, action.y)

			if self.input_action then
				local button = self:get_selected_button(action.x, action.y)
				if button then
					if not self.input_action.selected[button] then
						if not self.input_action.current then
							self.word:add_letter(button.letter)
							self.input_action.selected[button] = true
							self.input_action.current = button
							button:set_selected(true)
							table.insert(self.input_action.selected_list, button)
							local btn_pos = button:get_pos()
							self.spline:add_point(btn_pos.x, btn_pos.y)
						end
					else
						if not self.input_action.current then
							local btn_list = self.input_action.selected_list
							if button == btn_list[#btn_list-1] then
								self.word:remove_letter()
								self.input_action.selected[btn_list[#btn_list]] = nil
								self.input_action.current = button
								btn_list[#btn_list]:set_selected(false)
								table.remove(btn_list, #btn_list)
								self.spline:remove_point()
							end
						end
					end
				else
					if self.input_action.current then
						self.input_action.current = nil
					end
				end
			end
		end
	end
end

function M:update(dt)
	self.spline:render()
end

function M:init_buttons(letters)
	self.buttons = {}
	for i = 1, #letters do
		local button = LetterButton:new(letters[i])
		table.insert(self.buttons, button)
	end
end

function M:on_window_resize(coeff)
	self.xscale = coeff

	-- update buttons pos, scale
	local rotation_angle = vmath.quat_rotation_z((math.pi*2)/#self.buttons)
	local center = go.get_world_position("/input_circle/circle")
	local button_pos = go.get_world_position("/input_circle/letter_pos") - center
	for _, btn in ipairs(self.buttons) do
		btn:set_pos(center + vmath.vector3(button_pos.x * self.xscale, button_pos.y, button_pos.z))
		btn:set_xscale(coeff)
		button_pos = vmath.rotate(rotation_angle, button_pos)
	end

	-- update word
	self.word:set_pos(go.get_world_position("/input_circle/word_pos"))
	self.word:set_xscale(coeff)

	-- update background circle
	go.set_scale(vmath.vector3(coeff, 1.0, 1.0), "/input_circle/circle#background")
end

function M:new(level, letters)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.input_active = false
	
	o.level = level
	o.xscale = 1

	o.spline = Spline:new()
	o.word = LetterWord:new()
	
	o:init_buttons(letters)
	o:on_window_resize(o.xscale)
	
	return o
end

return M