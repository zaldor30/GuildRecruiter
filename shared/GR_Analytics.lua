local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

ns.analytics = {}
local analytics = ns.analytics

function analytics:Init()
end
function analytics:Start()
    -- Create Table if Needed
    ns.pAnalytics = {
        ["PlayersBlackListed"] = ns.pAnalytics["PlayersBlackListed"] or 0,
        ["PlayersInvited"] = ns.pAnalytics["PlayersInvited"] or 0,
        ["PlayersDeclined"] = ns.pAnalytics["PlayersDeclined"] or 0,
        ["startDate"] = ns.pAnalytics["startDate"] or time(),
        ["PlayersScanned"] = ns.pAnalytics["PlayersScanned"] or 0,
        ["PlayersJoined"] = ns.pAnalytics["PlayersJoined"] or 0,
    }
    ns.gAnalytics = {
        ["PlayersBlackListed"] = ns.gAnalytics["PlayersBlackListed"] or 0,
        ["PlayersInvited"] = ns.gAnalytics["PlayersInvited"] or 0,
        ["PlayersDeclined"] = ns.gAnalytics["PlayersDeclined"] or 0,
        ["startDate"] = ns.gAnalytics["startDate"] or time(),
        ["PlayersScanned"] = ns.gAnalytics["PlayersScanned"] or 0,
        ["PlayersJoined"] = ns.gAnalytics["PlayersJoined"] or 0,
    }

    -- Create Guild Recruiter Accessable Tables
    local success, tblGSession = ns.code:decompressData(ns.gAnalytics.session or {})
    ns.pStats = ns.pAnalytics
    ns.gStats = ns.gAnalytics
    ns.SessionStat = {
        ["PlayersBlackListed"] = 0,
        ["PlayersInvited"] = 0,
        ["PlayersDeclined"] = 0,
        ["startDate"] = time(),
        ["PlayersScanned"] = 0,
        ["PlayersJoined"] = 0,
        ['WaitingOnInvite'] = 0,
    }
    ns.guildSession = success and tblGSession or {}
    ns.guildSession[date('%m%d%Y')] = ns.guildSession[date('%m%d%Y')] or {
        ["PlayersBlackListed"] = 0,
        ["PlayersInvited"] = 0,
        ["PlayersDeclined"] = 0,
        ["startDate"] = time(),
        ["PlayersScanned"] = 0,
        ["PlayersJoined"] = 0,
        ['WaitingOnInvite'] = 0,
    }
end
function analytics:getSessionStats(field, isSavedStat) return self:getStats(field, (isSavedStat or false), true) end
function analytics:getStats(field, isGlobal, session)
    if not field then return end

    local tbl = {}
    if not isGlobal and session then tbl = ns.SessionStat or {} -- Current Session Stats
    elseif isGlobal and session then tbl = ns.guildSession[date('%m%d%Y')] or {} -- Session stats that are saved
    elseif not isGlobal and not session then tbl = ns.pStats or {} -- Profile Stats
    elseif isGlobal and not session then  tbl = ns.gStats or {} end -- Global Stats

    return (tbl and tbl[field]) and tbl[field] or 0
end
function analytics:saveStats(field, amt)
    if not field then return
    elseif field == 'WaitingOnInvite' then self:WaitingOnInvite(field, amt) return end

    local curDate = date('%m%d%Y')
    ns.guildSession[curDate] = ns.guildSession[curDate] or self.blankRecord

    amt = (not amt or type(amt) == 'boolean') and 1 or amt
    ns.pAnalytics[field] = ns.pAnalytics[field] and ns.code:inc(ns.pAnalytics[field], amt) or amt
    ns.gAnalytics[field] = ns.gAnalytics[field] and ns.code:inc(ns.gAnalytics[field], amt) or amt
    ns.guildSession[date('%m%d%Y')][field] = ns.code:inc(ns.guildSession[date('%m%d%Y')][field], amt) or amt
    ns.SessionStat[field] = ns.code:inc(ns.SessionStat[field], amt)
end
function analytics:WaitingOnPlayer(field, amt)
    amt = (not amt or type(amt) == 'boolean') and 1 or amt
    local remain = (self.tblSession[field] or 0) + amt

    self.tblSession[field] = remain > 0 and remain or 0
end
analytics:Init()

-- ToDo: <FUTURE> Add session logging and syncing.