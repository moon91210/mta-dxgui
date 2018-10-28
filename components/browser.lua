Browser = {}
Browser.__index = Browser


function Browser.new(x, y, w, h, url)
    local self = setmetatable(Component.new('browser', x, y, w, h), Browser)
    self.browser = createBrowser(w, h, false, true)

    local function onCreated()
        if url then
            self:loadURL(url)
        end
        dxCallEvent(self, 'created')
    end

    local function onReady()
        dxCallEvent(self, 'documentReady')
    end

    self:on('destroy', function()
        removeEventHandler("onClientBrowserCreated", self.browser, onCreated)
        removeEventHandler("onClientBrowserDocumentReady", self.browser, onReady)
        self.browser:destroy()
    end)

    addEventHandler("onClientBrowserCreated", self.browser, onCreated)
    addEventHandler("onClientBrowserDocumentReady", self.browser, onReady)
    
    return self
end

function Browser:loadURL(url)
    self.browser:loadURL(url)
end

function Browser:getSource(callback)
   return self.browser:getSource(callback)
end

function Browser:draw()
    dxDrawImage(self.x, self.y, self.w, self.h, self.browser, 0, 0, 0, tocolor(255, 255, 255, 255))
end

setmetatable(Browser, {__call = function(_, ...) return Browser.new(...) end})