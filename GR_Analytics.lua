-- Guild Recruiter Global Functions
local tblAnalytics, tblVersion = {}, 1
local dbAnalytics, Analytics = nil, nil
local p,g = nil, nil

function NS.Analytics()
    if not GRADDON.db then return end
    p,g = GRADDON.db.profile, GRADDON.db.global

    local tbl = {}
    function tbl:new()
        return {
            playersScanned = 0,
            invitedPlayers = 0,
            acceptedInvite = 0,
            declinedInvite = 0,
            blackListed = 0,
        }
    end
    function tbl:saveData()
        g.analytics = tblAnalytics.global
        p.analytics = tblAnalytics.profile
    end
    function tbl:loadData()
        if g.analyticsVersion and g.analyticsVersion > tblVersion then -- do upgrade
            error('Analytic table upgrade has not been implemeneted at this time.')
        else g.analyticsVersion = tblVersion end

        tblAnalytics.global = g.analytics and g.analytics or dbAnalytics:new()
        tblAnalytics.profile = p.analytics and g.analytics or dbAnalytics:new()
    end
    function tbl:get(profile, key)
        if profile == 'global' then return tblAnalytics.global[key]
        elseif profile == 'profile' then return tblAnalytics.profile[key] end
    end
    -- Guild Invite Analytics NS.code
    function tbl:playersScanned(amt)
        tblAnalytics.global = {['playersScanned'] = tblAnalytics.global.playersScanned + amt}
        tblAnalytics.profile = {['playersScanned'] = tblAnalytics.profile.playersScanned + amt}
        dbAnalytics:saveData()
    end
    function tbl:Invited()
        tblAnalytics.global = {['invitedPlayers'] = tblAnalytics.global.invitedPlayers + 1}
        tblAnalytics.profile = {['invitedPlayers'] = tblAnalytics.profile.invitedPlayers + 1}
        dbAnalytics:saveData()
    end
    function tbl:acceptedInvite()
        tblAnalytics.global = {['acceptedInvite'] = tblAnalytics.global.acceptedInvite + 1}
        tblAnalytics.profile = {['acceptedInvite'] = tblAnalytics.profile.acceptedInvite + 1}
        dbAnalytics:saveData()
    end
    function tbl:declinedInvite()
        tblAnalytics.global = {['declinedInvite'] = tblAnalytics.global.declinedInvite + 1}
        tblAnalytics.profile = {['declinedInvite'] = tblAnalytics.profile.declinedInvite + 1}
        dbAnalytics:saveData()
    end
    -- Black List Analytics NS.code
    function tbl:blackListed(remove)
        tblAnalytics.global = {['blackListed'] = tblAnalytics.global.blackListed + (remove and -1 or 1)}
        tblAnalytics.profile = {['blackListed'] = tblAnalytics.profile.blackListed + (remove and -1 or 1)}
        dbAnalytics:saveData()
    end

    return tbl
end