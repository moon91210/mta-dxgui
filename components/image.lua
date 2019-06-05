Image = Class('Image')


function Image.new(x, y, w, h, path, postGUI, alpha)
	local self = inherit(Component.new('image', x, y, w, h), Image)
	self.path = nil
	self.tex = nil
	self.pix = nil
	self.nativeSize = {}
	self.ratio = nil
	self.fitSize = {}
	self.fitMode = 'stretch'
	self.ow = self.w
	self.oh = self.h
	self.postGUI = postGUI or false
	self.alpha = alpha or 255 -- @TODO this needs to be a component variable (set/getAlpha)

	self:load(path)

	return self
end

function Image:load(path, isPixels)
	if self.path == path or not path then
		return false
	end
	
	if not isPixels and path:find('://') then -- hacky way of checking for urls
		self:loadRemote(path)
		self.path = path
		return true
	end

	if isPixels then
		self:loadPixels(path)
		return true
	end
	
	self:unload()
	self.path = path

	if not fileExists(path) then
		return false
	end

	local f = fileOpen(path, true)
	self.pix = f:read(f.size)

	self.tex = DxTexture(self.pix)
	self:getNativeSize(true)

	f:close()		
	return true
end

function Image:loadRemote(url, callback)
	check('s', {url})
	self:unload()
	requestBrowserDomains({url}, true, function()
		if isBrowserDomainBlocked(url, true) then
			self:loadRemote(url)
			return
		end
		fetchRemote(url, function(data, err)
			assert(err == 0, "Error fetching image. Err: "..err..". URL: "..url, 2)
			self:loadPixels(data)
			if type(callback) == 'function' then
				callback(data)
			end
		end)
	end)
end

function Image:unload()
	self.path = nil
	self.tex = nil
	self.pix = nil
	self.nativeSize = {}
	self.ratio = nil
	self.fitSize = {}
	collectgarbage()
end

function Image:loadPixels(pixels)
	check('s', {pixels})
	self.tex = DxTexture(pixels)
	self.pix = pixels
	self:getNativeSize(true)
end

function Image:saveAs(path)
	check('s', {path})
	local f = File(path)
	if f and self.pix then
		f:write(self.pix)
		f:close()
		return true
	end
	return false
end

function Image:getNativeSize(update)
	if not self.pix then return false end

	if update then
		local w, h = dxGetPixelsSize(self.pix)
		self.nativeSize = {w=w,h=h}
	end

	self.ratio = math.min(self.h/self.nativeSize.h, self.w/self.nativeSize.w)
	self.fitSize.w = math.ceil(self.nativeSize.w*self.ratio)
	self.fitSize.h = math.ceil(self.nativeSize.h*self.ratio)

	return self.nativeSize, self.fitSize, self.ratio
end

function Image:setFitMode(mode)
	check('s', {mode})
	self.fitMode = mode
	return self
end

function Image:draw()
	if self.fitMode == 'nostretch' and self.w ~= self.ow and self.h ~= self.oh then
		self:getNativeSize(false)
		self.ow = self.w
		self.oh = self.h
	end

	if self.tex then
		local size = self.fitMode == 'nostretch' and self.fitSize or {w=self.w,h=self.h}
		dxDrawImage(self.x, self.y, size.w, size.h, self.tex, 0, 0, 0, tocolor(255,255,255,self.alpha), self.postGUI)
	else
		self:drawBorders(1, tocolor(160,160,160,150))
		dxDrawImage(self.x, self.y, 35, 35, 'img/broken.png', 0, 0, 0, tocolor(255,255,255,255), self.postGUI)
	end
end

function Image:getFitMode() return self.fitMode end
function Image:getFitSize() return self.fitSize end
function Image:getPixels() return self.pix end
function Image:getPath() return self.path end
function Image:getTexture() return self.tex end

setmetatable(Image, {__call = function(_, ...) return Image.new(...) end})