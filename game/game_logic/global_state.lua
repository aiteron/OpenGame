local M = {}

M.level = 1

function M:loadSave()
	self.level = 1	-- TEMP
end

function M:increase_level()
	self.level = self.level + 1
end

return M