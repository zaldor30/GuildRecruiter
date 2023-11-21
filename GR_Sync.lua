local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

local AceTimer = LibStub("AceTimer-3.0")

ns.sync = {}
local sync = ns.sync

local COMM_PREFIX = 'GuildRecruiter'
local REQUEST_TIMEOUT = 5
local DATA_WAIT_TIMEOUT, SYNC_FAIL_TIMER = 120, 240

local function newClient(name, hasReceivedData)
    return {
        name = name,
        isActive = true,
        dataSent = false,
        hasReceivedData = hasReceivedData or false,
        addedAntiSpam = 0,
        addedBlackList = 0,
        removedBlackList = 0,
    }
end

-- Timer Callbacks
function AceTimer:timerEvent(message, sender) sync:FailRoutines(message, sender) end

function sync:Init()
    self.clubID = nil -- Passed from ns.core

    self.isSyncing = false
    self.isAutoSync = false

    -- Master Sync Variables
    self.masterSync = nil
    self.isMasterSync = false

    -- Sync Timer Variables
    self.syncStartTime = GetTime()

    -- Client Variables
    self.tblClient = {}
    self.clientFound = false

    -- Timer Variables
    self.tblTimer = {}
end
-- Start/Stop Sync
function sync:StartSync(isMaster, sender, autoSync)
    local tblScreen = ns.screens.base.tblFrame
    if self.isSyncing or not ns.core.fullyStarted then return end

    self.masterSync = isMaster and UnitName('player')..'-'..GetRealmName() or (sender or nil)
    self.isMasterSync = isMaster or false
    if not self.isMasterSync then return end

    self.isSyncing = true
    self.tblTimer = self.tblTimer and table.wipe(self.tblTimer) or {}
    self.syncStartTime = GetTime()

    ns.screens.base.isSyncing = true
    if tblScreen.syncIcon then
        tblScreen.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1)
    end

    local function masterSyncStartUp()
        if autoSync then ns.sync:cOut(L['Auto-sync']..' '..L['started']..'...', true)
        else ns.sync:cOut(L['Master sync']..' '..L['started']..'...', true) end

        function AceTimer:masterSyncStart()
            if ns.sync.clientFound then
                ns.sync:cOut(L['Sending data requests to client']..' '..ns.sync.masterSync)
                for k in pairs(ns.sync.tblClient) do
                    if not ns.sync.tblClient[k].hasReceivedData then
                        ns.sync:SendCommMessage('DATA_REQUEST', 'WHISPER', k)
                        ns.sync.tblTimer[k] = AceTimer:ScheduleTimer('timerEvent', DATA_WAIT_TIMEOUT, 'DATA_REQUEST_TIMEOUT', k)
                    end
                end

                sync:CancelTimer('SYNC_REQUEST_TIMEOUT')
            else
                ns.sync:cOut(L['No clients found to sync with.'])
                ns.sync:StopSync()
            end
        end

        ns.sync.tblClient = table.wipe(ns.sync.tblClient or {})
        ns.sync.clientFound = false

        ns.sync:SendCommMessage('SYNC_REQUESTED', 'GUILD')
        ns.sync.tblTimer['FULL_SYNC_FAILED'] = AceTimer:ScheduleTimer('timerEvent', SYNC_FAIL_TIMER, 'FULL_SYNC_FAILED')
        ns.sync.tblTimer['SYNC_REQUEST_TIMEOUT'] = AceTimer:ScheduleTimer('masterSyncStart', REQUEST_TIMEOUT)
    end
    local function clientSyncStartUp()
        sync:SendCommMessage('SYNC_REQUEST_HEARD', 'WHISPER', sender)
        self.tblTimer['CLIENT_SYNC_FAIL'] = AceTimer:Scheduletimer('timerEvent', SYNC_FAIL_TIMER, 'CLIENT_SYNC_FAIL')
    end

    self.isAutoSync = autoSync or false
    if isMaster or autoSync then masterSyncStartUp()
    elseif not isMaster then clientSyncStartUp() end
end
function sync:StopSync(as, bl, rem)
    self.isSyncing = false
    self.clientFound = false

    for k in pairs(self.tblTimer) do sync:CancelTimer(k) end
    self.tblTimer = table.wipe(self.tblTimer or {})

    as, bl, rem = (as or 0), (bl or 0), (rem or 0)
    if self.masterSync then
        for _, r in pairs(self.tblClient) do
            as = r.addedAntiSpam or 0
            bl = r.addedBlackList or 0
            rem = r.removedBlackList or 0
        end
    end

    ns.screens.base.isSyncing = false
    local tblScreen = ns.screens.base.tblFrame
    if tblScreen.syncIcon then
        tblScreen.syncIcon:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
    end

    if as > 0 then self:cOut(string.format(L['Added %s anti-spam records'], as), 'FF00FF00') end
    if bl > 0 then self:cOut(string.format(L['Added %s black list records'], bl), 'FF00FF00') end
    if rem > 0 then self:cOut(string.format(L['MARKED_FOR_DELETE'], rem), 'FF00FF00') end

    if self.isAutoSync then self:cOut(L['Auto-sync']..' '..L['complete'], true)
    elseif self.isMasterSync then self:cOut(L['Master sync']..' '..L['complete'], true)
    else sync:cOut(L['Sync']..' '..L['complete'], true) end

    self.isAutoSync = false
    self.masterSync = nil
    self.isMasterSync = false
end

-- Comm Routines
function sync:SendCommMessage(msg, chatType, target)
    if not msg then return end
    chatType = chatType or 'GUILD'
    GR:SendCommMessage(COMM_PREFIX, msg, chatType, (target or nil), 'ALERT')
end
function sync:CommReceived(message, sender)
    if not sender or sender == '' or sender == UnitName('player') then return
    elseif not message then return end

    local function prepIncommingData()
        local msg = L['Sync data received from']..' '..sender
        local success, tbl = ns.code:decompressData(message, 'DECODE_FOR_WOW')
        if success and tbl then
            if self.isMasterSync then self:CancelTimer(sender)
            else self:CancelTimer('CLIENT_SYNC_FAIL') end

            self:cOut(msg, 'FF00FF00')
            self:ProcessIncommingData(sender, tbl)
        else
            self:cOut(msg..' '..L['is invalid'], 'FFFF0000', true)
            self:StopSync()
            return
        end
    end

    if self.isMasterSync then
        if message:match('SYNC_REQUEST_HEARD') then
            if not self.isSyncing then return end

            ns.code:dOut('Sync request heard from '..sender, 'FFFFFF00')
            self.clientFound = true
            self.tblClient[sender] = newClient(sender)
        else prepIncommingData() end
    elseif not self.isMasterSync then
        if message:match('SYNC_REQUESTED') then
            if self.isSyncing then return end

            self:cOut('Client sync started...', true)
            self:cOut('Sync requested by '..sender, 'FF00FF00', true)
            self:StartSync(false, sender)
            sync:SendCommMessage('SYNC_REQUEST_HEARD', 'WHISPER', sender)
        elseif sender == self.masterSync and message:match('DATA_REQUEST') then
            self:cOut('Data requested by '..sender, 'FF00FF00')
            self:PrepareAndSendData()
        else prepIncommingData() end
    end
end

-- Data Routines
function sync:CheckIfAllDataReceived()
    local allData = true
    for _, r in pairs(self.tblClient) do
        if not r.hasReceivedData then allData = false end
    end
    if not allData then self:PrepareAndSendData() end

    return allData
end
function sync:PrepareAndSendData()
    for _, r in pairs(ns.tblBlackList) do r.sent = true end
    local tblData = {
        version = GR.version,
        guildInfo = ns.dbGlobal.guildInfo,
        gmSettings = ns.gmSettings,
        antiSpamList = ns.tblInvited,
        blackList = ns.tblBlackList,
    }

    local dataOutput = ns.code:compressData(tblData, 'ENCODE_FOR_WOW')

    if self.isMasterSync then
        for k, r in pairs(self.tblClient) do
            if r.isActive and not r.dataSent then
                self:SendCommMessage(dataOutput, 'WHISPER', k)
                self.tblClient[k].dataSent = true
            end
        end

        self:StopSync()
    else self:SendCommMessage(dataOutput, 'WHISPER', self.masterSync) end
end
function sync:ProcessIncommingData(sender, tblData)
    if not sender or sender == '' or not tblData then return end

    if sync:IncorrectVersionOutput(tblData.version, sender) then
        if sync:CheckIfAllDataReceived() then sync:PrepareAndSendData() end
        return
    end

    local gmName = tblData.guildInfo.guildLeaderName
    if not ns.isGuildLeader and tblData.guildInfo.guildLeaderName:match(gmName) then
        ns.dbGlobal.guildInfo = tblData.guildInfo
        ns.dbGlobal.guildInfo.isGuildLeader = false
        ns.gmSettings = tblData.gmSettings
    end

    local antiSpamCount = 0
    for k, r in pairs(tblData.antiSpamList) do
        if not ns.tblInvited[k] then
            ns.tblInvited[k] = r
            ns.tblInvited[k].addedBy = sender
            antiSpamCount = antiSpamCount + 1
        end
    end

    local blackListCount, removedCount = 0, 0
    for k, r in pairs(tblData.blackList) do
        if not ns.tblBlackList[k] then
            ns.tblBlackList[k] = r
            blackListCount = blackListCount + 1
        end

        if ns.tblBlackList[k] and not ns.tblBlackList[k].markedForDelete and r.markedForDelete then
            ns.tblBlackList[k].markedForDelete = r.markedForDelete
            ns.tblBlackList[k].expirationDate = r.expirationDate
            removedCount = removedCount + 1
        end
    end

    if self.tblClient[sender] then
        self.tblClient[sender].hasReceivedData = true
        self.tblClient[sender].addedAntiSpam = antiSpamCount
        self.tblClient[sender].addedBlackList = blackListCount
        self.tblClient[sender].removedBlackList = removedCount

        sync:CancelTimer(sender)
    else sync:CancelTimer('DATA_REQUEST_TIMEOUT') end

    if self.isMasterSync and self:CheckIfAllDataReceived() then sync:PrepareAndSendData()
    else sync:StopSync(antiSpamCount, blackListCount, removedCount) end
end

-- Support Routines
function sync:cOut(msg, color, force)
    if not msg then return end
    color = type(color) == 'string' and color or 'FF3EB9D8'
    force = type(color) == 'boolean' and color or (force or false)

    if force then ns.code:fOut(msg, color)
    else ns.code:cOut(msg, color) end
end
function sync:CancelTimer(key)
    if not self.tblTimer[key] then return end

    AceTimer:CancelTimer(self.tblTimer[key])
    self.tblTimer[key] = nil
end
function sync:IncorrectVersionOutput(version, sender)
    sender = (sender and sender ~= '') and sender or 'unknown sender'
    if not version or not sender then
        ns.code:dOut('IncorrectVersionOutput: Missing version or sender ('..version..'/'..sender..')', true)
        return true
    end
    if not version or GR.version ~= version then
        self:cOut('Addon version mismatch with '..(sender or 'unknown sender'), 'FFFFFF00', true)
        self:cOut('Your version: '..GR.version, 'FF00FF00', true)
        self:cOut('Their version: '..(version or 'Unknown'), 'FFFF0000', true)
        return true
    end

    return false
end
function sync:FailRoutines(message, sender)
    sync:CancelTimer((sender or message))
    if message:match('FULL_SYNC_FAILED') then
        self:cOut('Sync failed', 'FFFF0000', true)
        self:StopSync()
    elseif message:match('DATA_REQUEST_TIMEOUT') then
        self:cOut('Data request timed out for '..sender, 'FFFF0000', true)
        if self.isMasterSync then
            self.tblClient[sender].isActive = false
            self.tblClient[sender].hasReceivedData = true
            if self:CheckIfAllDataReceived() then sync:PrepareAndSendData() end
        else self:StopSync() end
    end
end
sync:Init()

local function OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX then return
    elseif distribution ~= 'GUILD' and distribution ~= 'WHISPER' then return end

    sync:CommReceived(message, sender)
end
GR:RegisterComm(COMM_PREFIX, OnCommReceived)