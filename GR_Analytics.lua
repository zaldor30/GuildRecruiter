-- Guild Recruiter Global Functions
local _, ns = ... -- Namespace (myaddon, namespace)

local tblAnalytics, tblVersion = {}, 1
local dbAnalytics = nil
local p,g = nil, nil

local analytics = {
    new = function()
        return {
            ['playersScanned'] = 0,
            ['invitedPlayers'] = 0,
            ['acceptedInvite'] = 0,
            ['declinedInvite'] = 0,
            ['blackListed'] = 0,
        }
    end,
    saveData = function()
        g.analytics = tblAnalytics.global
        p.analytics = tblAnalytics.profile
    end,
    loadData = function()
        if g.analyticsVersion and g.analyticsVersion > tblVersion then -- do upgrade
            error('Analytic table upgrade has not been implemeneted at this time.')
        else g.analyticsVersion = tblVersion end

        tblAnalytics.global = g.analytics.global and g.analytics.global or ns.Analytics:new()
        tblAnalytics.profile = p.analytics.profile and g.analytics.profile or ns.Analytics:new()
    end,
    get = function(key, profile)
        if profile then return tblAnalytics.global[key]
        else return tblAnalytics.profile[key] end
    end,
    -- Guild Invite Analytics ns.code
    playersScanned = function(amt)
        tblAnalytics.global['playersScanned'] = tblAnalytics.global['playersScanned'] + amt
        tblAnalytics.profile['playersScanned'] = tblAnalytics.profile['playersScanned'] + amt
        dbAnalytics:saveData()
    end,
    Invited = function()
        tblAnalytics.global.invitedPlayers = tblAnalytics.global.invitedPlayers + 1
        tblAnalytics.profile.invitedPlayers = tblAnalytics.profile.invitedPlayers + 1
        dbAnalytics:saveData()
    end,
    acceptedInvite = function()
        tblAnalytics.global.acceptedInvite = tblAnalytics.global.acceptedInvite + 1
        tblAnalytics.profile.acceptedInvite = tblAnalytics.profile.acceptedInvite + 1
        dbAnalytics:saveData()
    end,
    declinedInvite = function()
        tblAnalytics.global.declinedInvite = tblAnalytics.global.declinedInvite + 1
        tblAnalytics.profile.declinedInvite = tblAnalytics.profile.declinedInvite + 1
        dbAnalytics:saveData()
    end,
    -- Black List Analytics ns.code
    blackListed = function(remove)
        tblAnalytics.global = {['blackListed'] = tblAnalytics.global.blackListed + (remove and -1 or 1)}
        tblAnalytics.profile = {['blackListed'] = tblAnalytics.profile.blackListed + (remove and -1 or 1)}
        dbAnalytics:saveData()
    end,
}
ns.Analytics = analytics
tblAnalytics.global = ns.Analytics.new()
tblAnalytics.profile = ns.Analytics.new()