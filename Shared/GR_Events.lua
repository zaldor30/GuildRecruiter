local _, ns = ... -- Namespace (myaddon, namespace)

ns.events, ns.observer = {}, {}
local events, observer = ns.events, ns.observer

-- * Observer Routines
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