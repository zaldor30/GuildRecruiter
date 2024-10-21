local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.analytics = {}
local analytics = ns.analytics

function analytics:BuildAnalytics()
    local dNow = date("*t", GetServerTime())
    if dNow then return end
    ns.pAnalytics.start = ns.pAnalytics.start or time()
    ns.gAnalytics.start = ns.gAnalytics.start or time()
    ns.pAnalytics.sStart = ns.pAnalytics.sStart or dNow.yday

    if ns.pAnalytics.sStart ~= dNow.yday then
        ns.pAnalytics.sStart = time()
        ns.pAnalytics.sScanned = 0
        ns.pAnalytics.sDeclined = 0
        ns.pAnalytics.sInvited = 0
        ns.pAnalytics.sAccepted = 0
        ns.pAnalytics.sBlacklisted = 0
        ns.pAnalytics.sTimeout = 0
        ns.pAnalytics.sQueued = 0
    end

    local scanned = {
        field = 'Players Scanned',
        pAmt = ns.pAnalytics.scanned and (ns.pAnalytics.scanned.amt or 0) or 0,
        gAmt = ns.gAnalytics.scanned and (ns.gAnalytics.scanned.amt or 0) or 0,
        sAmt = ns.pAnalytics.sScanned and (ns.pAnalytics.sScanned.amt or 0) or 0,
    }
    ns.analytics.scanned = scanned

    local declined = {
        field = 'Players Declined',
        pAmt = ns.pAnalytics.declined and (ns.pAnalytics.declined.amt or 0) or 0,
        gAmt = ns.gAnalytics.declined and (ns.gAnalytics.declined.amt or 0) or 0,
        sAmt = ns.pAnalytics.sDeclined and (ns.pAnalytics.sDeclined.amt or 0) or 0,
    }
    ns.analytics.declined = declined

    local invited = {
        field = 'Players Invited',
        pAmt = ns.pAnalytics.invited and (ns.pAnalytics.invited.amt or 0) or 0,
        gAmt = ns.gAnalytics.invited and (ns.gAnalytics.invited.amt or 0) or 0,
        sAmt = ns.pAnalytics.sInvited and (ns.pAnalytics.sInvited.amt or 0) or 0,
    }
    ns.analytics.invited = invited

    local accepted = {
        field = 'Players Accepted',
        pAmt = ns.pAnalytics.accepted and (ns.pAnalytics.accepted.amt or 0) or 0,
        gAmt = ns.gAnalytics.accepted and (ns.gAnalytics.accepted.amt or 0) or 0,
        sAmt = ns.pAnalytics.sAccepted and (ns.pAnalytics.sAccepted.amt or 0) or 0,
    }
    ns.analytics.accepted = accepted

    local blacklisted = {
        field = 'Blacklisted',
        pAmt = ns.pAnalytics.blacklisted and (ns.pAnalytics.blacklisted.amt or 0) or 0,
        gAmt = ns.gAnalytics.blacklisted and (ns.gAnalytics.blacklisted.amt or 0) or 0,
        sAmt = ns.pAnalytics.sBlacklisted and (ns.pAnalytics.sBlacklisted.amt or 0) or 0,
    }
    ns.analytics.blacklisted = blacklisted

    local timeout = {
        field = 'Invites Timed Out',
        sAmt = ns.pAnalytics.sTimeout and (ns.pAnalytics.sTimeout.amt or 0) or 0,
    }
    ns.analytics.timeout = timeout

    local queued = {
        field = 'Players Queued',
        sAmt = ns.pAnalytics.sQueued and (ns.pAnalytics.sQueued.amt or 0) or 0,
    }
    ns.analytics.queued = queued
end
function analytics:SaveAnalytics()
end
local function updateAmount(field, amt)
    if ns.analytics[field] then
        ns.analytics[field].pAmt = ns.analytics[field].pAmt and ns.analytics[field].pAmt + amt
        ns.analytics[field].gAmt = ns.analytics[field].gAmt and ns.analytics[field].gAmt + amt
        ns.analytics[field].sAmt = ns.analytics[field].sAmt + amt
    end
end
function analytics:Reception(field, amt)
    amt = amt or 1

    if field == 'scanned' then updateAmount(field, amt) return
    elseif field == 'declined' then updateAmount(field, amt)
    elseif field == 'invited' then updateAmount(field, amt)
    elseif field == 'accepted' then updateAmount(field, amt)
    elseif field == 'queued' then updateAmount(field, amt) return
    elseif field == 'timeout' then updateAmount(field, amt)
    elseif field == 'offline' then updateAmount('invited', -(amt))
    elseif field == 'notplaying' then updateAmount('invited', -(amt))
    elseif field == 'notfound' then updateAmount('invited', -(amt))
    elseif field == 'alreadyinguild' then updateAmount('invited', -(amt)) end

    updateAmount('queued', -(amt))
end