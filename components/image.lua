function Image(x, y, w, h, path, alpha)
	local self = Component.new('image', x, y, w, h)
	local src
	local tex
	local pix
	local nativeSize = {}
	local ratio
	local fitSize = {}
	local fitMode = 'stretch'
	local ow = self.w
	local oh = self.h

	self.alpha = alpha or 255 -- this needs to be a component variable (set/getAlpha)

	function self:load(path, isPixels)
		if (src == path) then
			return false
		end
		
		if (not isPixels and path:find('://')) then -- hacky way of checking for urls
			self:loadRemote(path)
			src = path
			return true
		end

		if (isPixels) then
			self:loadPixels(path)
			return true
		end
		
		self:unload()
		src = path

		if (not fileExists(path)) then
			return false
		end

		local f = fileOpen(path, true)
	 	pix = f:read(f.size)

		tex = DxTexture(pix)
		self:getNativeSize(true)

		f:close()		
		return true
	end

	function self:loadRemote(url)
		requestBrowserDomains({url}, true, function()
			if (isBrowserDomainBlocked(url, true)) then
				self:loadRemote(url)
				return
			end
			fetchRemote(url, function(pix, err)
				if (err > 0) then
					assert(err == 0, "Error fetching image. Code: "..err)
				end
				self:loadPixels(pix)
			end)
		end)
	end

	function self:unload()
		src = nil
		tex = nil
		pix = nil
		nativeSize = {}
		ratio = nil
		fitSize = {}
		collectgarbage()
	end

	function self:loadPixels(pixels)
		tex = DxTexture(pixels)
		pix = pixels
		self:getNativeSize(true)
	end

	function self:getNativeSize(update)
		if (not pix) then return false end

		if (update) then
			local w, h = dxGetPixelsSize(pix)
			nativeSize = {w=w,h=h}
		end

		ratio = math.min(self.h/nativeSize.h, self.w/nativeSize.w)
		fitSize.w = math.ceil(nativeSize.w*ratio)
		fitSize.h = math.ceil(nativeSize.h*ratio)

		return nativeSize, fitSize, ratio
	end

	function self:draw()
		if (fitMode == "nostretch" and self.w ~= ow and self.h ~= oh) then
			self:getNativeSize(false)
			ow = self.w
			oh = self.h
		end

		if (tex) then
			local size = fitMode == "nostretch" and fitSize or {w=self.w,h=self.h}
			dxDrawImage(self.x, self.y, size.w, size.h, tex, 0, 0, 0, tocolor(255,255,255,self.alpha))
		else
			local color = tocolor(160,160,160,150)
			dxDrawLine(self.x, self.y, self.x+self.w, self.y, color) -- top
			dxDrawLine(self.x, self.y+self.h, self.x+self.w, self.y+self.h, color) -- bottom
			dxDrawLine(self.x, self.y, self.x, self.y+self.h, color) -- left
			dxDrawLine(self.x+self.w, self.y, self.x+self.w, self.y+self.h, color) -- right
			dxDrawImage(self.x, self.y, 35, 35, "img/broken.png")
		end
	end

	function self:setFitMode(mode) fitMode = mode return self end
	function self:getFitMode() return fitMode end
	function self:getFitSize() return fitSize end
	function self:getPixels() return pix end
	function self:getSrc() return src end

	self:load(path)

	return self
end