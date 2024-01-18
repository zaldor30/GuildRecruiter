local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.analytics = {}

-- Variables:
-- PlayersScanned
-- PlayersInvited
-- PlayersJoined
-- PlayersDeclined
-- PlayersBlackListed
-- WaitingOnPlayer

local analytics = ns.analytics
function analytics:Init()
    self.tblSession = {}
    self.tblSavedSessions = {}
end
function analytics:getStats(index, session, isGlobal)
    if not index then return end
    session, isGlobal = (session or false), (isGlobal or false)

    return session and (self.tblSession[index] or 0) or (isGlobal and (ns.dbAG[index] or 0) or (ns.dbAP[index] or 0))
end
function analytics:saveStats(index, amt, session)
    if not index then return end

    amt = (not amt or type(amt) == 'boolean') and 1 or amt
    session = (type(amt) ~= 'boolean') and amt or (session or false)

    if index == 'WaitingOnPlayer' then self:WaitingOnPlayer('WaitingOnPlayer', amt)
    elseif session then
        self.tblSession[index] = (self.tblSession[index] or 0) + amt
        self.tblSavedSessions[date('%m%d%Y')] = self.tblSavedSessions[date('%m%d%Y')] or {}
        self.tblSavedSessions[date('%m%d%Y')] = self.tblSession
    end
    ns.dbAP[index] = ns.code:inc(ns.dbAP[index], amt)
    ns.dbAG[index] = ns.code:inc(ns.dbAG[index], amt)
end
function analytics:WaitingOnPlayer(index, amt)
    -- No saving to session only temporary data
    local remain = ns.code:inc((self.tblSession[index] or 0), (amt or 1))
    self.tblSession[index] = remain > 0 and remain or 0
end
analytics:Init()