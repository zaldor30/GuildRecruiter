-- Analytics Routines
local _, ns = ... -- Namespace (myaddon, namespace)

ns.Analytics = {}
local analytics = ns.Analytics
function analytics:Init()
    self.tblAnalytics = nil
end
function analytics:new()
    return {
        ['Players_Scanned'] = 0,
        ['Invited_Players'] = 0,
        ['Accepted_Invite'] = 0,
        ['Declined_Invite'] = 0,
        ['Black_Listed'] = 0,
    }
end
function analytics:save()
    ns.dbAnal.global.analytics = self.tblAnalytics.global
    ns.dbAnal.profile.analytics = self.tblAnalytics.profile
end
function analytics:load()
    self.tblAnalytics = self.tblAnalytics and table.wipe(self.tblAnalytics) or {}
    self.tblAnalytics.global = ns.dbAnal.global.analytics and ns.dbAnal.global.analytics or analytics:new()
    self.tblAnalytics.profile = ns.dbAnal.profile.analytics and ns.dbAnal.profile.analytics or analytics:new()
end
function analytics:get(key, isGlobal)
    if not self.tblAnalytics or not self.tblAnalytics.global or not self.tblAnalytics.profile then analytics:load() end

    if isGlobal then return (self.tblAnalytics and self.tblAnalytics.global) and (self.tblAnalytics.global[key] or 0) or 0
    else return (self.tblAnalytics and self.tblAnalytics.profile) and (self.tblAnalytics.profile[key] or 0) or 0 end
end
function analytics:add(key, amt)
    if not self.tblAnalytics or not self.tblAnalytics.global or not self.tblAnalytics.profile then analytics:load() end

    self.tblAnalytics.global[key] = (self.tblAnalytics.global[key] or 0) + (amt or 1)
    self.tblAnalytics.profile[key] = (self.tblAnalytics.profile[key] or 0) + (amt or 1)
    ns.Analytics:save()
end
function analytics:getFields()
    local tbl, tblSource = {}, analytics:new()
    for k in pairs(tblSource) do tinsert(tbl, k) end
    return tbl
end