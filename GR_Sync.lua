local _, ns = ... -- Namespace (myaddon, namespace)

local AceTimer = LibStub("AceTimer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

local COMM_PREFIX = GRADDON.prefix
local REQUEST_TIMEOUT = 5
local DATA_WAIT_TIMEOUT, SYNC_FAIL_TIMER = 120, 240

ns.sync = {}
local sync = ns.sync

function AceTimer:CallBackSync(...) sync:OnCommReceived(nil, 'DATA_REQUEST_TIMEOUT', ...) end
function AceTimer:CallBackRequest(...) sync:OnCommReceived(nil, 'SYNC_REQUEST_TIMEOUT', ...) end
function AceTimer:CallBackClientTimeOut(sender)
    ns.code:fOut('Sync request timed out with '..(sender or 'unknown sender'))
    sync:StopSync()
end
function AceTimer:CallBackSyncTimeOut()
    ns.code:fOut('Sync timed out')
    sync:StopSync()
end

function sync:Init()
    self.tblData = {}

    self.isAutoSync = false
    self.syncStarted = false
    self.timeOutTimer = nil
    self.syncStartTime = 0

    -- Master Variables
    self.isMaster = false
    self.masterName = nil

    -- Client Variables
    self.clientTimer = nil

    self.startInvited = 0
    self.startBlackListed = 0
end
function sync:console(msg, debug, force)
    if debug then ns.code:dOut(msg)
    else
        if force then ns.code:fOut(msg) else ns.code:cOut(msg) end
    end
    ns.code:statusOut(msg)
end
-- Start/Stop Sync Routines
function sync:StopSync()
    if ns.screen.tblFrame.syncIcon then
        ns.screen.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(1, 1, 1, 1) end
    if not self.syncStarted then return end

    self.syncStarted, self.isMaster, self.masterName = false, false, nil

    if self.timeOutTimer then
        AceTimer:CancelTimer(self.timeOutTimer)
        self.timeOutTimer = nil
    end

    local syncType = self.isMaster and 'Master' or 'Client'
    if self.isAutoSync then
        self:console('Auto sync completed.', false, 'FORCE')
    else
        self:console('Sync took '..ns.code:round(GetTime() - self.syncStartTime, 2)..' seconds to complete', 'DEBUG')
        self:console(syncType..' sync completed.', false, 'FORCE')
    end

    ns.code:saveTables()

    self.isAutoSync = false

    C_Timer.After(5, function() ns.code:statusOut(' ') end)
end -- Decide the function to stop the sync
function sync:StartSyncServer()
    if self.syncStarted then return end

    self.isMaster, self.masterName = true, UnitName("player")
    self.syncStarted, self.syncStartTime = true, GetTime()

    self.timeOutTimer = AceTimer:ScheduleTimer('CallBackSyncTimeOut', SYNC_FAIL_TIMER)

    if ns.screen.tblFrame.syncIcon then
        ns.screen.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1) end

    if self.isAutoSync then
        self:console('Auto sync started.', false, 'FORCE')
    else self:console('Master sync started.', false, 'FORCE') end

    self.tblData = table.wipe(self.tblData) or {}
    self.totalInvited, self.totalBlackListed = 0, 0

    for _ in pairs(ns.tblInvited and ns.tblInvited or {}) do self.startInvited = self.startInvited + 1 end
    for _ in pairs(ns.tblBlackList and ns.tblBlackList or {}) do self.startBlackListed = self.startBlackListed + 1 end

    self:SendCommMessage('SYNC_REQUEST')
    AceTimer:ScheduleTimer('CallBackRequest', REQUEST_TIMEOUT)
end
function sync:StartSyncClient(masterName)
    if self.syncStarted then return end

    if ns.screen.tblFrame.syncIcon then
        ns.screen.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1) end

    ns.core.stopSync = true
    self.isMaster, self.masterName = false, masterName
    self.syncStarted, self.syncStartTime = true, GetTime()
    self.timeOutTimer = AceTimer:ScheduleTimer('CallBackSyncTimeOut', SYNC_FAIL_TIMER)

    self:console('Client sync started.', false, 'FORCE')
end

-- Comm Routines
function sync:SendCommMessage(msg, chatType, target)
    if not msg then return end
    chatType = chatType or 'GUILD'
    GRADDON:SendCommMessage(COMM_PREFIX, msg, chatType, (target or nil), 'ALERT')
end
function sync:OnCommReceived(prefix, message, distribution, sender)
    if message ~= 'DATA_REQUEST_TIMEOUT' and message ~= 'SYNC_REQUEST_TIMEOUT' then
        local distroOk = (distribution == 'GUILD' or distribution == 'WHISPER') and true or false
        if not distroOk or not sender or sender == UnitName('player') then return
        elseif not message or prefix ~= GRADDON.prefix then return end
    end

    local function sendMasterData()
        local invAdded, blAdded, blRemoved = 0, 0, 0
        for k, r in pairs(self.tblData) do
            if r.hasReceivedData then
                local inv, bl, blRem = self:MergeSyncData(k, r.rawData)
                invAdded = invAdded + inv
                blAdded = blAdded + bl
                blRemoved = blRemoved + blRem
            end
        end
        sync:ConsoleStatsDisplay(invAdded, blAdded, blRemoved)

        local sendData = self:PrepareDataToSend()
        for k in pairs(self.tblData) do
            self:SendCommMessage(sendData, 'WHISPER', k)
        end

        sync:StopSync()
    end

    -- Master Sync Error Handling
    if message:match('DATA_REQUEST_TIMEOUT') then
        if not self.tblData[sender] then return end

        self.tblData[sender] = nil
        ns.code:fOut('Failed to sync with '..(sender or 'unknown sender'))

        local completed, remain = true, 0
        for _, r in pairs(self.tblData) do
            if not r.hasReceivedData then
                completed = false
                remain = remain + 1
            elseif r.hasReceivedData then completed = false end
        end
        if completed then sync:StopSync()
        elseif remain == 0 then sendMasterData() end
    elseif message:match('SYNC_REQUEST_TIMEOUT') then
        local clientFound = false
        for k, r in pairs(self.tblData) do
            clientFound = true
            sync:console('Sending data request to '..k, 'DEBUG')
            sync:SendCommMessage('DATA_REQUEST', 'WHISPER', k)
            r.timerID = AceTimer:ScheduleTimer('CallBackSync', DATA_WAIT_TIMEOUT, k)
        end

        if not clientFound then
            sync:console('No clients found to sync with', false, self.isAutoSync)
            sync:StopSync()
            return
        else self:console('Sent sync requests, waiting for response...') end
    elseif message:match('INCOMMING_DATA') then
        self:console('Getting data from '..(sender or 'unknown sender'))
        return
    end

    if self.isMaster and sender ~= self.masterName then
        if message == 'SYNC_REQUEST_HEARD' then
            self.tblData[sender] = {}
            self.tblData[sender].hasReceivedData = false
            ns.code:dOut('Received sync acknowledgement from '..(sender or 'unknown sender'))
        elseif message and self.tblData[sender] then
            self:console('Received Client Data from '..(sender or 'remote client.'), 'DEBUG')

            self.tblData[sender].hasReceivedData = true
            AceTimer:CancelTimer(self.tblData[sender].timerID)
            self.tblData[sender].timerID = nil
            self.tblData[sender].rawData = message

            local waitLonger = false
            for _, r in pairs(self.tblData) do
                if not r.hasReceivedData then waitLonger = true break end
            end
            if not waitLonger then sendMasterData() end
        end
    else
        if message == 'SYNC_REQUEST' then
            sync:StartSyncClient(sender)

            ns.code:fOut('Received sync request from '..(sender or 'unknown sender'))
            sync:SendCommMessage('SYNC_REQUEST_HEARD', 'WHISPER', sender)

            self.clientTimer = AceTimer:ScheduleTimer('CallBackClientTimeOut', 10, sender)
        elseif message == 'DATA_REQUEST' and sender == self.masterName then
            self:console('Sending data to '..(sender or 'sync master.'))

            AceTimer:CancelTimer(self.clientTimer)

            self:console('Sending data to '..(sender or 'sync master.'), 'DEBUG')
            sync:SendCommMessage('INCOMMING_DATA', 'WHISPER', sender)
            sync:SendCommMessage(self:PrepareDataToSend(), 'WHISPER', sender)
        elseif sender == self.masterName and message then
            self:console('Received Master Data from '..(sender or 'remote master.'))
            local invAdded, blAdded, blRemoved = sync:MergeSyncData(sender, message)
            if invAdded == -1 then sync:StopSync() return end
            sync:ConsoleStatsDisplay(invAdded, blAdded, blRemoved)
            sync:StopSync()
        end
    end
end

-- Data Parsing Routines
function sync:IncorrectVersionOutput(version, sender)
    sender = (sender and sender ~= '') and sender or 'unknown sender'
    if not version or not sender then
        ns.code:fOut('IncorrectVersionOutput: Missing version or sender ('..version..'/'..sender..')')
        return
    end
    if not version or GRADDON.version ~= version then
        ns.code:fOut('Addon version mismatch with '..(sender or 'unknown sender'), 'FFFFFF00')
        ns.code:fOut('Your version: '..GRADDON.version, 'FFFF0000')
        ns.code:fOut('Their version: '..(version or 'Unknown'), 'FFFF0000')
    end
end
function sync:ConsoleStatsDisplay(invAdded, blAdded, blRemoved)
    if invAdded > 0 then
        ns.code:fOut(invAdded..' players added to invited list') end
    if blAdded > 0 then
        ns.code:fOut(blAdded..' players added to black list') end
    if blRemoved > 0 then
        ns.code:fOut(blRemoved..' players removed from black list') end
end
function sync:MergeSyncData(sender, message)
    if not ns.dbGlobal.guildInfo or not message or not sender then return end

    local function mergeTheData(tbl)
        local invAdded, blAdded, blRemoved = 0, 0, 0
        if GRADDON.version ~= tbl.dbVersion then
            self:IncorrectVersionOutput(tbl.dbVersion, sender)
            return 0, 0, 0
        end

        if not ns.isGuildLeader and not ns.hasGuildLeader then
            local tblGuildInfo = tbl.guildInfo or nil
            local tblGuildData = tbl.guildData or nil

            tblGuildInfo.guildLeader = nil
            tblGuildInfo.hasGuildLeader = false

            if tblGuildInfo then ns.dbGlobal.guildInfo = tblGuildInfo end
            if tblGuildData then ns.dbGlobal.guildData = tblGuildData end

            if not ns.settings.welcomeMessage and ns.dbGlobal.guildInfo.welcomeMessage then
                ns.settings.welcomeMessage = ns.dbGlobal.guildInfo.welcomeMessage end
            if not ns.settings.greetingMsg and ns.dbGlobal.guildInfo.greetingMsg then
                ns.settings.greetingMsg = ns.dbGlobal.guildInfo.greetingMsg end
        end

        ns.tblInvited = ns.tblInvited or {}
        for k, r in pairs(tbl.invitedPlayers and tbl.invitedPlayers or {}) do
            if not ns.tblInvited[k] then
                ns.tblInvited[k] = r
                invAdded = invAdded + 1
            end
        end

        ns.tblBlackList = ns.tblBlackList or {}
        for k, r in pairs(tbl.blackListedPlayers and tbl.blackListedPlayers or {}) do
            if not ns.tblBlackList[k] and type(k) == 'string' and k ~= 'blacklist' then
                ns.tblBlackList[k] = r
                blAdded = blAdded + 1
            elseif r.markedForDeletion then
                ns.tblBlackList[k].markedForDeletion = true
                ns.tblBlackList[k].expirationTime = r.expirationTime
                blRemoved = blRemoved + 1
            end
        end

        return invAdded, blAdded, blRemoved
    end

    local function decodeFailed()
        self:console('Failed to decode data from '..(sender or 'unknown sender'), false, 'FORCE')
        return -1, -1, -1
    end

    local invAdded, blAdded, blRemoved = 0, 0, 0
    local success, tbl = ns.code:decompressData(message, 'DECODE_FOR_WOW')
    if success and tbl and type(tbl) == 'table' then
        -- _, tbl.blackListedPlayers = ns.code:decompressData(tbl.blackListedPlayers)
        invAdded, blAdded, blRemoved = mergeTheData(tbl)
        return invAdded, blAdded, blRemoved
    else decodeFailed() end
end
function sync:PrepareDataToSend() -- Used when sending client data (Client)
    local tbl = {}
    tbl.dbVersion = GRADDON.version

    tbl.guildInfo = ns.dbGlobal.guildInfo
    tbl.guildData = ns.dbGlobal.guildData

    tbl.invitedPlayers = ns.tblInvited
    tbl.blackListedPlayers = ns.tblBlackList --ns.code:compressData(ns.tblBlackList)

    return ns.code:compressData(tbl, 'ENCODE_FOR_WOW')
end
sync:Init()

local function OnCommReceived(prefix, message, distribution, sender)
    sync:OnCommReceived(prefix, message, distribution, sender) end
GRADDON:RegisterComm(GRADDON.prefix, OnCommReceived)