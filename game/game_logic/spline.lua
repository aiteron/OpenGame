local SPLINE_DETAIL = 250

local M = {}

function M:draw_spline(points)
	if points == nil then return end
	drawpixels.fill(self.buffer_info, 0, 0, 0, 0)

	for i = 1, #points, 2 do
		drawpixels.filled_circle(self.buffer_info, points[i], points[i+1], 25, 99, 142, 196, 255, false)
	end

	resource.set_texture(self.resource_path, self.header, self.buffer_info.buffer)
end

function M:clear()
	drawpixels.fill(self.buffer_info, 0, 0, 0, 0)
	resource.set_texture(self.resource_path, self.header, self.buffer_info.buffer)
end

function M:calc_spline(tab)
	if(tab and (#tab >= 4)) then
		local Points = {}
		for i=1, (#tab-2), 2 do
			local p1x = tab[i]
			local p1y = tab[i+1]
			local p2x = tab[i+2]
			local p2y = tab[i+3]

			local p0x = tab[i-2]
			local p0y = tab[i-1]
			local p3x = tab[i+4]
			local p3y = tab[i+5]

			--Create a colinearity function to test how colinear three points are:
			local colinearity = 0
			local function GetColinearity(x1, y1, x2, y2, x3, y3)
				local ux = x2 - x1
				local uy = y2 - y1
				local vx = x3 - x2
				local vy = y3 - y2
				local udv = (ux*vx + uy*vy)
				local udu = (ux*ux + uy*uy)
				local vdv = (vx*vx + vy*vy)
				local scalar = 1
				if(udv < 0) then	--the angle is greater than 90 degrees.
					scalar = 0
				end
				return scalar * ((udv*udv) / (udu*vdv))
			end

			--Calculate the colinearity and the control points for the section:
			local t1x = 0
			local t1y = 0
			local colin1 = 0
			if(p0x and p0y) then
				t1x = 0.5 * (p2x - p0x)
				t1y = 0.5 * (p2y - p0y)
				colin1 = GetColinearity(p0x, p0y, p1x, p1y, p2x, p2y)
			else
				colin1 = nil
			end
			local t2x = 0
			local t2y = 0
			local colin2 = 0
			if(p3x and p3y) then
				t2x = 0.5 * (p3x - p1x)
				t2y = 0.5 * (p3y - p1y)
				colin2 = GetColinearity(p1x, p1y, p2x, p2y, p3x, p3y)
			else
				colin2 = nil
			end
			if(colin1 and colin2) then
				colinearity = ((colin1+colin2)/2)
			elseif(colin1) then
				colinearity = colin1
			elseif(colin2) then
				colinearity = colin2
			else
				colinearity = 0
			end

			--Get the proper detail using the computed colinearity, then calculate the spline points:
			local rdetail = (SPLINE_DETAIL * (1.5-colinearity))
			for j=0, rdetail do
				local s = j/rdetail
				local s2 = s*s
				local s3 = s*s*s
				local h1 = 2*s3 - 3*s2 + 1
				local h2 = -2*s3 + 3*s2
				local h3 = s3 - 2*s2 + s
				local h4 = s3 - s2
				local px = (h1*p1x) + (h2*p2x) + (h3*t1x) + (h4*t2x)
				local py = (h1*p1y) + (h2*p2y) + (h3*t1y) + (h4*t2y)
				table.insert(Points, px)
				table.insert(Points, py)
			end
			if(math.ceil(rdetail) > rdetail) then
				table.insert(Points, p2x)
				table.insert(Points, p2y)
			end
		end
		return Points
	end
end

function M:render()
	local t = self:calc_spline(self.control_points)
	self:draw_spline(t)
end

function M:add_point(x, y)
	table.insert(self.control_points, #self.control_points-1, x - self.shift_x)
	table.insert(self.control_points, #self.control_points-1, y - self.shift_y)
end

function M:remove_point()
	table.remove(self.control_points, #self.control_points-2)
	table.remove(self.control_points, #self.control_points-2)
	self:clear()
end

-- Last point coords is mouse pos coords
function M:update_mouse_point(x, y)
	self.control_points[#self.control_points-1] = x - self.shift_x
	self.control_points[#self.control_points] = y - self.shift_y
end

function M:clear_points()
	self.control_points = {0, 0}
	self:clear()
end

function M:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	local center_pos = go.get_world_position("/input_circle/circle")
	o.shift_x = center_pos.x - 512
	o.shift_y = center_pos.y - 512
	o.control_points = {0, 0} 
	
	o.resource_path = go.get("/input_circle/spline#sprite", "texture0")
	local width = 1024
	local height = 2048
	local channels = 4

	o.buffer_info = {
		buffer = buffer.create(width * height, {{name = hash("rgba"), type = buffer.VALUE_TYPE_UINT8, count = channels}}),
		width = width,
		height = height,
		channels = channels
	}

	o.header = {width = width, height = height, type = resource.TEXTURE_TYPE_2D, format = resource.TEXTURE_FORMAT_RGBA, num_mip_maps = 1}
	
	return o
end


return M 