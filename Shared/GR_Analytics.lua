local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.analytics = {}
local analytics = ns.analytics

--[[
    Invited to Guild
    Declined invite to Guild
    Accepted invite to Guild

    Total Scanned Players
    Valid Unguilded Players Found
    Players blacklisted

    Session:
    Total Scanned Players
    Valid Unguilded Players Found
    Players blacklisted
    Players invited to Guild
    Players declined invite to Guild
    Players accepted invite to Guild
    Waiting on Response
]]

local savedStruct = {
    -- Saved Vars
    ['BLACKLISTED'] = { label = 'Players blacklisted', value = 0 },
    ['TOTAL_SCANNED'] = { label = 'Total Scanned Players', value = 0 },
    ['INVITED_GUILD'] = { label = 'Invited to Guild', value = 0 },
    ['DECLINED_INVITE'] = { label = 'Declined invite to Guild', value = 0 },
    ['ACCEPTED_INVITE'] = { label = 'Accepted invite to Guild', value = 0 },
    ['SCANNED_NO_GUILD'] = { label = 'Players with no guild found', value = 0 },
}
local sessionStruct = {
    ['TIMESTAMP'] = { label = 'Session Started', value = date('%m/%d/%Y') },
    ['SESSION_TOTAL_SCANNED'] = { label = 'Scanned', value = 0 },
    ['SESSION_BLACKLISTED'] = { label = 'Blacklisted', value = 0 },
    ['SESSION_INVITED_GUILD'] = { label = 'Invited', value = 0 },
    ['SESSION_DECLINED_INVITE'] = { label = 'Declined Invite', value = 0 },
    ['SESSION_ACCEPTED_INVITE'] = { label = 'Accepted Invite', value = 0 },
    ['SESSION_WAITING_RESPONSE'] = { label = 'Waiting on', value = 0 },
    ['SESSION_INVITE_TIMED_OUT'] = { label = 'Invite Timed Out', value = 0 },
    ['SESSION_SCANNED_NO_GUILD'] = { label = 'Potential Found', value = 0 },
}

function analytics:Init()
    self.gData = ns.code:deepCopy(savedStruct)
    self.pData = ns.code:deepCopy(savedStruct)
end
--* Build Data
function analytics:SaveData()
    ns.gAnalytics = table.wipe(ns.gAnalytics or {})
    for k, v in pairs(self.gData) do ns.gAnalytics[k] = v.value end
    ns.pAnalytics = ns.pAnalytics and table.wipe(ns.pAnalytics) or {}
    for k, v in pairs(self.pData) do ns.pAnalytics[k] = v.value end
end -- Session data updated separately in UpdateSessionData
function analytics:RetrieveSavedData()
    for k, v in pairs(ns.gAnalytics) do
        if self.gData[k] then self.gData[k].value = v end
    end
    for k, v in pairs(ns.pAnalytics or {}) do
        if self.pData[k] then self.pData[k].value = v end
    end

    local currentDate = date('%m/%d/%Y')
    ns.pAnalytics.session = ns.pAnalytics.session or {}
    if not ns.pAnalytics.session.TIMESTAMP or currentDate ~= ns.pAnalytics.session.TIMESTAMP then
        print('New Session')
        ns.pAnalytics.session = table.wipe(ns.pAnalytics.session)
        sessionStruct.TIMESTAMP.value = currentDate
        self.sData = ns.code:deepCopy(sessionStruct)
        for k, v in pairs(self.sData) do ns.pAnalytics.session[k] = v.value end
    end

    self.sData = self.sData or ns.code:deepCopy(sessionStruct)
    for k, v in pairs(ns.pAnalytics.session or {}) do
        if v and self.sData[k] then self.sData[k].value = v end
    end
end

--* Functions
function analytics:UpdateData(key, value)
    if not self.gData[key] then return end

    self.gData[key].value = self.gData[key].value + (value or 1)
    self.pData[key].value = self.pData[key].value + (value or 1)

    self:SaveData()
end
function analytics:UpdateSessionData(key, value)
    if not self.sData[key] then return end
    local valueOut = self.sData[key].value + (value or 1)
    valueOut = valueOut < 0 and 0 or valueOut
    self.sData[key].value = valueOut

    ns.pAnalytics.session = ns.pAnalytics.session or {}
    for k, v in pairs(self.sData) do ns.pAnalytics.session[k] = v.value end

    if ns.scanner:IsShown() then ns.scanner:UpdateSessionData() end
end
function analytics:GetData(key)
    return (self.gData[key] and self.gData[key].value or nil), (self.pData[key] and self.pData[key].value or nil), (self.sData[key] and self.sData[key].value or nil)
end
analytics:Init()