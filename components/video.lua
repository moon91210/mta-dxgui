Video = {}
Video.__index = Video


function Video.new(x, y, w, h, src)
    local self = setmetatable(Component.new('video', x, y, w, h), Video)
    self.browser = Browser(w, h, true, true)

    local function loadUrl()
        self.browser:loadURL(src)
    end

    self:on('destroy', function()
        removeEventHandler("onClientBrowserCreated", self.browser, loadUrl)
        self.browser:destroy()
    end)

    addEventHandler("onClientBrowserCreated", self.browser, loadUrl)
    
    return self
end

function Video:draw()
    dxDrawImage(self.x, self.y, self.w, self.h, self.browser, 0, 0, 0, tocolor(255, 255, 255, 255))
end

setmetatable(Video, {__call = function(_, ...) return Video.new(...) end})