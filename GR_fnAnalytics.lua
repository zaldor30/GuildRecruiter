-- Analytics Routines
local _, ns = ... -- Namespace (myaddon, namespace)

ns.Analytics = {}
local analytics = ns.Analytics
function analytics:Init()
    self.p, self.g = nil, nil
    self.tblAnalytics = nil
end
function analytics:UpdateDB() self.p, self.g = ns.dbAnal.profile, ns.dbAnal.global end
function analytics:new()
    return {
        ['Players_Scanned'] = 0,
        ['Invited_Players'] = 0,
        ['Accepted_Players'] = 0,
        ['Declined_Invite'] = 0,
        ['Black_Listed'] = 0,
    }
end
function analytics:save()
    self.p.analytics = self.tblAnalytics.profile
    self.g.analytics = self.tblAnalytics.global
end
function analytics:load()
    self.tblAnalytics = self.tblAnalytics and table.wipe(self.tblAnalytics) or {}
    self.tblAnalytics.global = self.g.analytics and self.g.analytics or analytics:new()
    self.tblAnalytics.profile = self.p.analytics and self.p.analytics or analytics:new()
end
function analytics:get(_, key, isGlobal)
    analytics:UpdateDB()
    if not self.tblAnalytics or not self.tblAnalytics.global or not self.tblAnalytics.profile then
        analytics:load() end

    if isGlobal then return (self.tblAnalytics and self.tblAnalytics.global) and (self.tblAnalytics.global[key] or 0) or 0
    else return (self.tblAnalytics and self.tblAnalytics.profile) and (self.tblAnalytics.profile[key] or 0) or 0 end
end
function analytics:getFields()
    analytics:UpdateDB()
    local tbl, tblSource = {}, analytics:new()
    for k in pairs(tblSource) do table.insert(tbl, k) end
    return tbl
end
function analytics:add(key, amt)
    analytics:UpdateDB()
    if not self.tblAnalytics.global or not self.tblAnalytics.profile then
        analytics:load() end

    self.tblAnalytics.global[key] = (self.tblAnalytics.global[key] or 0) + (amt or 1)
    self.tblAnalytics.profile[key] = (self.tblAnalytics.profile[key] or 0) + (amt or 1)
    ns.Analytics:save()
end
analytics:Init()