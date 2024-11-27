local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.events, ns.observer = {}, {}
local events, observer = ns.events, ns.observer

-- * Event Routines
function events:StartBaseEvents()
    local function eventPLAYER_LOGOUT()
        ns.code:saveTables()
        ns.analytics:SaveAnalytics()
    end
    local function eventCHAT_MSG_ADDON(...)
        local prefix = ...
        if prefix:match(GR.commPrefix) then
            observer:Notify('eventCHAT_MSG_ADDON', ...) end
    end
    local function eventCHAT_MSG_SYSTEM(...)
        local _, msg = ...

        if not msg then return
        elseif msg:find(L["PLAYER_JOINED_GUILD"]) then observer:Notify('PLAYER_JOINED_GUILD', ...)
        elseif msg:find(L["PLAYER_DECLINED_INVITE"]) then observer:Notify('PLAYER_DECLINED_INVITE', msg)
        elseif msg:find(L["PLAYER_NOT_ONLINE"]) then observer:Notify('PLAYER_NOT_ONLINE', ...)
        elseif msg:find(L["PLAYER_NOT_PLAYING"]) then observer:Notify('PLAYER_NOT_PLAYING', ...)
        elseif msg:find(L["PLAYER_NOT_FOUND"]) then observer:Notify('PLAYER_NOT_FOUND', ...)
        elseif msg:find(L["PLAYER_IN_GUILD"]) then observer:Notify('PLAYER_IN_GUILD', ...)
        elseif msg:find(L["PLAYER_ALREADY_IN_GUILD"]) then observer:Notify('PLAYER_ALREADY_IN_GUILD', ...)
        end
    end

    GR:RegisterEvent('PLAYER_LOGOUT', eventPLAYER_LOGOUT)
    GR:RegisterEvent('CHAT_MSG_ADDON', eventCHAT_MSG_ADDON)
    GR:RegisterEvent('CHAT_MSG_SYSTEM', eventCHAT_MSG_SYSTEM)
end

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