local M = {}

M.level = 1
M.words = {}

function M:load()
	local filename = sys.get_save_file("OPEN_GAME", "save")
	local data = sys.load(filename)
	
	self.level = data.level or 1
	self.words = data.words or {}
end

function M:save()
	local filename = sys.get_save_file("OPEN_GAME", "save")
	sys.save(filename, {level = self.level, words = self.words})
end

function M:increase_level()
	self.level = self.level + 1
	self.words = {}
	self:save()
end

return M