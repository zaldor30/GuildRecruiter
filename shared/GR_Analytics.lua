local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

ns.analytics = {}
local analytics = ns.analytics

function analytics:Init()
    self.tblGlobal = {}
    self.tblPlayer = {}
    self.tblSession = {}
end
function analytics:Start()
    local location = ns.pAnalytics
    local template = {
        ["PlayersBlackListed"] = location["PlayersBlackListed"] or 0,
        ["PlayersInvited"] = location["PlayersInvited"] or 0,
        ["PlayersDeclined"] = location["PlayersDeclined"] or 0,
        ["startDate"] = location["startDate"] or time(),
        ["PlayersScanned"] = location["PlayersScanned"] or 0,
        ["PlayersJoined"] = location["PlayersJoined"] or 0,
    }

    self.tblPlayer = template
    location = ns.gAnalytics
    self.tblGlobal = template
    self.tblSession = {
        ["PlayersBlackListed"] = 0,
        ["PlayersInvited"] = 0,
        ["PlayersDeclined"] =0,
        ["startDate"] = time(),
        ["PlayersScanned"] = 0,
        ["PlayersJoined"] = 0,
        ["WaitingOnInvite"] = 0,
}
end
function analytics:getSessionStats(field, isSavedStat) return self:getStats(field, (isSavedStat or false), true) end
function analytics:getStats(field)
    if not field then return
    elseif field == 'WaitingOnInvite' then return self.tblSession[field]
    elseif not self.tblSession[field] then
        ns.code:fOut('Analytics: Field not found: '..field)
        return
    end

    local global, player, session = self.tblGlobal[field], self.tblPlayer[field], self.tblSession[field]
    return global, player, session
end
function analytics:incStats(field, amt)
    if not field then return
    elseif field == 'WaitingOnInvite' then self:WaitingOnInvite(field, amt) return end

    amt = (not amt or type(amt) == 'boolean') and 1 or amt
    self.tblGlobal[field] = (self.tblGlobal[field] or 0) + amt
    self.tblPlayer[field] = (self.tblPlayer[field] or 0) + amt
    self.tblSession[field] = (self.tblSession[field] or 0) + amt

    return self.tblGlobal[field], self.tblPlayer[field], self.tblSession[field]
end
function analytics:UpdateSaveData()
    ns.pAnalytics = self.tblPlayer
    ns.gAnalytics = self.tblGlobal
end
function analytics:WaitingOnPlayer(field, amt)
    amt = (not amt or type(amt) == 'boolean') and 1 or amt
    local remain = (self.tblSession[field] or 0) + amt

    self.tblSession[field] = remain > 0 and remain or 0
end
analytics:Init()

-- ToDo: <FUTURE> Add session logging and syncing.