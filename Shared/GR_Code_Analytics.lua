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
    ['TIMESTAMP'] = { label = L['ANALYTICS_STATS_START'], value = date('%m/%d/%Y') },
    ['BLACKLISTED'] = { label = L['ANALYTICS_BLACKLISTED'], value = 0 },
    ['TOTAL_SCANNED'] = { label = L['ANALYTICS_SCANNED'], value = 0 },
    ['INVITED_GUILD'] = { label = L['ANALYTICS_ACCEPTED'], value = 0 },
    ['DECLINED_INVITE'] = { label = L['ANALYTICS_DECLINED'], value = 0 },
    ['ACCEPTED_INVITE'] = { label = L['ANALYTICS_INVITED'], value = 0 },
    ['SCANNED_NO_GUILD'] = { label = L['ANALYTICS_NO_GUILD'], value = 0 },
    ['LAST_SCAN'] = { label = L['LAST_SCAN'], value = '' },
}
local sessionStruct = {
    ['TIMESTAMP'] = { label = L['ANALYTICS_SESSION_STARTED'], value = date('%m/%d/%Y') },
    ['SESSION_TOTAL_SCANNED'] = { label = L['ANALYTICS_SESSION_SCANNED'], value = 0 },
    ['SESSION_BLACKLISTED'] = { label = L['ANALYTICS_SESSION_BLACKLISTED'], value = 0 },
    ['SESSION_INVITED_GUILD'] = { label = L['ANALYTICS_SESSION_INVITED'], value = 0 },
    ['SESSION_DECLINED_INVITE'] = { label = L['ANALYTICS_SESSION_DECLINED'], value = 0 },
    ['SESSION_ACCEPTED_INVITE'] = { label = L['ANALYTICS_SESSION_ACCEPTED'], value = 0 },
    ['SESSION_WAITING_RESPONSE'] = { label = L['ANALYTICS_SESSION_WAITING'], value = 0 },
    ['SESSION_INVITE_TIMED_OUT'] = { label = L['ANALYTICS_SESSION_TIMED_OUT'], value = 0 },
    ['SESSION_SCANNED_NO_GUILD'] = { label = L['ANALYTICS_SESSION_NO_GUILD'], value = 0 },
}

function analytics:Init()
    self.gData = ns.code:deepCopy(savedStruct)
    self.pData = ns.code:deepCopy(savedStruct)
    self.sData = ns.code:deepCopy(sessionStruct)
end
--* Build Data
function analytics:SaveData()
    ns.gAnalytics = table.wipe(ns.gAnalytics or {})
    for k, v in pairs(self.gData) do ns.gAnalytics[k] = v.value end
    ns.pAnalytics = ns.pAnalytics and table.wipe(ns.pAnalytics) or {}
    for k, v in pairs(self.pData) do ns.pAnalytics[k] = v.value end
end -- Session data updated separately in UpdateSessionData
function analytics:RetrieveSavedData()
    local currentDate, lastScanFound, timestampFound = date('%m/%d/%Y'), false, false
    for k, v in pairs(ns.gAnalytics) do
        if v and k == 'TIMESTAMP' then timestampFound = true
        elseif v and k == 'LAST_SCAN' then lastScanFound = true end

        if v and k == 'TIMESTAMP' then timestampFound = true self.gData[k].value = v
        elseif v and k == 'LAST_SCAN' then lastScanFound = true self.gData[k].value = v
        elseif self.gData[k] and v then self.gData[k].value = v end
    end
    if not lastScanFound then self.gData.LAST_SCAN.value = 'Unknown' end
    if not timestampFound then self.gData.TIMESTAMP.value = currentDate end

    lastScanFound, timestampFound = false, false
    for k, v in pairs(ns.pAnalytics or {}) do
        if v and k == 'TIMESTAMP' then timestampFound = true self.pData[k].value = v
        elseif v and k == 'LAST_SCAN' then lastScanFound = true self.pData[k].value = v
        elseif self.pData[k] and v then self.pData[k].value = v end
    end
    if not lastScanFound then self.pData.LAST_SCAN.value = 'Unknown' end
    if not timestampFound then self.pData.TIMESTAMP.value = currentDate end

    ns.pAnalytics.session = ns.pAnalytics.session or {}
    if not ns.pAnalytics.session.TIMESTAMP or currentDate ~= ns.pAnalytics.session.TIMESTAMP then
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

    if not value or type(value) == 'number' then
        self.gData[key].value = self.gData[key].value + (value or 1)
        self.pData[key].value = self.pData[key].value + (value or 1)
    else
        self.gData[key].value = value
        self.pData[key].value = value
    end

    self:SaveData()
end
function analytics:UpdateSessionData(key, value)
    if not self.sData[key] then return end

    if not value or type(value) == 'number' then
        local valueOut = self.sData[key].value + (value or 1)
        valueOut = valueOut < 0 and 0 or valueOut
        self.sData[key].value = valueOut

        ns.pAnalytics.session = ns.pAnalytics.session or {}
        for k, v in pairs(self.sData) do ns.pAnalytics.session[k] = v.value end
    else self.sData[key].value = value end

    if ns.scanner:IsShown() then ns.scanner:UpdateSessionData() end
end
function analytics:GetData(key)
    return (self.gData[key] and self.gData[key].value or nil), (self.pData[key] and self.pData[key].value or nil), (self.sData[key] and self.sData[key].value or nil)
end
analytics:Init()
