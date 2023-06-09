-- Guild Recruiter Global Functions
local _, ns = ... -- Namespace (myaddon, namespace)

local tblAnalytics, tblVersion = nil, 1
local p,g = ns.dbA.profile, ns.dbA.global
local analytics = {
    new = function()
        return {
            ['playersScanned'] = 0,
            ['invitedPlayers'] = 0,
            ['acceptedInvite'] = 0,
            ['declinedInvite'] = 0,
            ['BlackListed'] = 0,
        }
    end,
    saveData = function()
        p,g = ns.dbA.profile, ns.dbA.global
        g.analytics = tblAnalytics.global
        p.analytics = tblAnalytics.profile
    end,
    loadData = function()
        p,g = ns.dbA.profile, ns.dbA.global
        if g.analyticsVersion and g.analyticsVersion > tblVersion then -- do upgrade
            error('Analytic table upgrade has not been implemeneted at this time.')
        else g.analyticsVersion = tblVersion end

        tblAnalytics = tblAnalytics and table.wipe(tblAnalytics) or {}
        tblAnalytics.global = g.analytics and g.analytics or ns.Analytics:new()
        tblAnalytics.profile = p.analytics and p.analytics or ns.Analytics:new()
        ns.Analytics:saveData()
    end,
    get = function(_, key, isGlobal)
        if not tblAnalytics.global then ns.Analytics:loadData() end
        
        if isGlobal then return tblAnalytics.global[key] or 0
        else return tblAnalytics.profile[key] or 0 end
    end,
    -- Guild Invite Analytics ns.code
    analyticsAdd = function(_,key, amt)
        if not tblAnalytics then ns.Analytics:loadData() end
        tblAnalytics.global[key] = tblAnalytics.global[key] + (amt or 1)
        tblAnalytics.profile[key] = tblAnalytics.profile[key] + (amt or 1)
        ns.Analytics:saveData()
    end,
}
ns.Analytics = analytics