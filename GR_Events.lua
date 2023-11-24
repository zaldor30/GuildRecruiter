local _, ns = ... -- Namespace (myaddon, namespace)

ns.observer = {}
local observer = ns.observer
function observer:Init()
    self.tblObservers = {}
end
function observer:Register(event, callback)
    if not event or not callback then return end

    if not self.tblObservers[event] then self.tblObservers[event] = {} end
    table.insert(self.tblObservers[event], callback)
end
function observer:Unregister(event, callback)
    if not event or not callback then return end
    if not self.tblObservers[event] then return end
    for i=#self.tblObservers[event],1,-1 do
        if self.tblObservers[event][i] == callback then
            table.remove(self.tblObservers[event], i)
        end
    end
end
function observer:UnregisterAll(event)
    if not event then return end
    if not self.tblObservers[event] then return end
    for i=#self.tblObservers[event],1,-1 do
        table.remove(self.tblObservers[event], i)
    end
end
function observer:Notify(event, ...)
    if not event or not self.tblObservers[event] then return end

    for i=1,#self.tblObservers[event] do
        if self.tblObservers[event][i] then
            self.tblObservers[event][i](...) end
    end
end
observer:Init()

ns.events = {}
local events = ns.events

local function observerSendMessageNotify(event, ...) observer:Notify(event, ...) end
function events:Init()
    self.tblEvents = {}
    self.tblMessages = {}
end
function events:RegisterEvent(event, callback)
    if not event or not callback then return
    elseif self.tblEvents[event] then return end

    self.tblEvents[event] = true
    GR:RegisterEvent(event, callback)
end
function events:RegisterMessage(event, callback ,cb)
    if not event then return
    elseif self.tblEvents[event] then return end

    self.tblMessages[event] = true
    if not cb then GR:RegisterMessage(event, observerSendMessageNotify)
    else GR:RegisterMessage(event, callback) end
end
function events:Unregister(event)
    if not event or not self.tblEvents then return end

    if event == 'ALL_EVENTS' then
        for k in pairs(self.tblEvents or {}) do
            observer:UnregisterAll(k)
            GR:UnregisterEvent(k)
            self.tblEvents[k] = nil
        end
    elseif event == 'ALL_MESSAGES' then
        for k in pairs(self.tblMessages or {}) do
            observer:UnregisterAll(k)
            GR:UnregisterMessage(k)
            self.tblMessages[k] = nil
        end
    elseif self.tblEvents[event] then
        observer:UnregisterAll(event)
        GR:UnregisterEvent(event)
        self.tblEvents[event] = nil
    elseif self.tblMessages[event] then
        observer:UnregisterAll(event)
        GR:UnregisterMessage(event)
        self.tblMessages[event] = nil
    end
end
events:Init()