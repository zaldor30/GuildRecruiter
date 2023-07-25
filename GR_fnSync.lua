local _, ns = ... -- Namespace (myaddon, namespace)

local AceTimer = LibStub("AceTimer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

local COMM_PREFIX = GRADDON.prefix
local REQUEST_TIMEOUT = 5
local DATA_WAIT_TIMEOUT = 60

ns.Sync = {}
local sync = ns.Sync

function AceTimer:CallBackSync(...) sync:MasterSync('DATA_REQUEST_TIMEOUT', ...) end
function AceTimer:CallBackRequest(...) sync:MasterSync('SYNC_REQUEST_TIMEOUT', ...) end

function sync:Init()
    self.autoSync = true
    self.commRegistered = false

    self.gmFound = false
    self.syncMaster = nil
    self.masterName = nil
    self.tblSyncClient = {}

    self.syncStart, self.startCount = nil, 0
    self.totalInvited, self.totalBlackListed = 0, 0
end
function sync:StartStatusUpdate(starting, failed)
    local syncTime = date('%H:%M %m/%d/%Y')
    local master = self.syncMaster and 'Master' or 'Client'

    if starting then
        self.syncStart = GetTime()
        ns.code:consoleOut(master..' sync started at '..syncTime)
        ns.screen:UpdateStatus(true)
    else
        if not failed then ns.db.settings.lastSync = syncTime end
        ns.code:consoleOut(master..' sync complete at '..syncTime)
        if self.syncMaster then
            ns.code:checkOut('Total sync time '..format('%.02f', GetTime() - self.syncStart)) end
            self.syncMaster, self.masterName = nil, nil
        ns.screen:UpdateStatus(false)
    end
end
function sync:SendCommMessage(msg, chatType, target)
    if not msg then return end
    chatType = chatType or 'GUILD'
    GRADDON:SendCommMessage(COMM_PREFIX, msg, chatType, (target or nil), 'ALERT')
end

-- Call Back Routines
function sync:OnCommReceived(prefix, message, distribution, sender)
    local distroOk = (distribution == 'GUILD' or distribution == 'WHISPER') and true or false
    if (not distroOk or sender == UnitName('player')) or prefix ~= GRADDON.prefix or not message then return end

    local success, tblData = false, nil
    if not message:match('SYNC_') then
        ns.code.checkOut('Decoding message from '..sender)
        local decodedWowMessage = LibDeflate:DecodeForWoWAddonChannel(message)
        local decompressedData = LibDeflate:DecompressDeflate(decodedWowMessage)
        success, tblData = GRADDON:Deserialize(decompressedData)
        if success then ns.code.checkOut(sender..' message was decoded successfully.')
        else ns.code.checkOut(sender..' message FAILED to decode.') end
    end

    if self.syncMaster then -- Master Communications
        -- Expected Messages: SYNC_NEED_CONFIRM, DATA_RECEIVED
        if self.syncMaster and success then sync:MasterSync('DATA_RECEIVED', sender, tblData)
        else sync:MasterSync(message, sender) end
    elseif not self.syncMaster then -- Client Communications
        -- Expected Messages: SYNC_REQUEST, SYNC_DATA_REQUEST, DATA_RECEIVED
        if self.masterName == sender and success then sync:ClientSync('DATA_RECEIVED', sender, tblData)
        else sync:ClientSync(message, sender) end
    end
end

-- Master Sync Routines
function sync:StartSyncMaster()
    if ns.screen.syncState then return end
    sync:StartStatusUpdate(true)

    self.gmFound, self.syncMaster, self.masterName = true, true, UnitName('player')
    self.totalInvited, self.totalBlackListed = 0, 0
    self.tblSyncClient = table.wipe(self.tblSyncClient) or {}

    if ns.db.settings.showAppMsgs then
        local c = 0
        for _ in pairs(ns.dbInv or {}) do c = c + 1 end
        self.startCount = c
    end

    sync:SendCommMessage('SYNC_REQUEST')
    AceTimer:ScheduleTimer('CallBackRequest', REQUEST_TIMEOUT)
end
function sync:MasterSync(msg, sender, ...)
    if msg == 'SYNC_NEED_CONFIRM' then -- Client confirms need to sync
        self.tblSyncClient[sender] = { timerID = nil, hasReceivedData = false }
    elseif msg == 'DATA_REQUEST_TIMEOUT' and sender then -- Ran out of time to get data from client
        if not self.tblSyncClient[sender] then return end

        self.tblSyncClient[sender] = nil
        ns.code:consoleOut('Failed to sync with '..sender)
        local completed = true
        for _, r in pairs(self.tblSyncClient or {}) do
            if not r.hasReceivedData then completed = false break end
        end
        if completed then sync:StartStatusUpdate(false, true) end
    elseif msg == 'SYNC_REQUEST_TIMEOUT' then -- Tired of waiting for clients to request sync
        local clientFound = false
        for k,r in pairs(self.tblSyncClient or {}) do
            clientFound = true
            ns.code.checkOut('Sending data request to '..k)
            sync:SendCommMessage('SYNC_DATA_REQUEST', 'WHISPER', k)
            r.timerID = AceTimer:ScheduleTimer('CallBackSync', DATA_WAIT_TIMEOUT, k)
        end
        if not clientFound then
            ns.code:consoleOut('Did not find anyone to sync with.')
            sync:StartStatusUpdate(false, true)
        elseif not self.showConsole then ns.code:consoleOut('Sending requests to client for data.') end
    elseif msg == 'DATA_RECEIVED' then -- Received data from clients and merge with own
        self.tblSyncClient[sender].hasReceivedData = true
        AceTimer:CancelTimer(self.tblSyncClient[sender].timerID)
        sync:ParseSyncData(..., sender)

        local allDone = true
        for _, r in pairs(self.tblSyncClient or {}) do
            if not r.hasReceivedData then allDone = false break end
        end
        if allDone then
            if self.showConsole then
                local c = 0
                for _ in pairs(ns.dbInv or {}) do c = c + 1 end
                ns.code.checkOut('You started with '..self.startCount..' invited players.')
                ns.code.checkOut('You now have '..c..' players that have received and invite.')
            end
            ns.code:consoleOut('Sending merged data to all clients.')
            local syncData = sync:PrepareData()
            sync:SendCommMessage(syncData)
            sync:StartStatusUpdate(false)
        end
    end
end

-- Client Sync Routines
function sync:ClientSync(msg, sender, ...)
    if msg == 'SYNC_REQUEST' then
        self.syncMaster, self.masterName = false, sender
        sync:SendCommMessage('SYNC_NEED_CONFIRM', 'WHISPER', sender)
    elseif msg == 'SYNC_DATA_REQUEST' then
        sync:StartStatusUpdate(true)
        local syncData = sync:PrepareData()
        sync:SendCommMessage(syncData, 'WHISPER', self.masterName)
    elseif msg == 'DATA_RECEIVED' then
        sync:ParseSyncData(..., sender)
        sync:StartStatusUpdate(false)
    end
end

-- Data Routines
function sync:PrepareData()
    if not ns.db then return end
    local dbGlobal = ns.dbGlobal or {}

    self.totalInvited, self.totalBlackListed = 0, 0
    local tblSync = {
        version = GRADDON.version,
        guildLink = ns.dbGlobal.guildData and (dbGlobal.guildData.guildLink or '') or '',
        guildInfo = dbGlobal.guildInfo or '',
        isGuildLeader = IsGuildLeader() or false,
        invitedPlayers = ns.dbInv or {},
        blackList = ns.dbBL or {},
    }

    local serializedData = GRADDON:Serialize(tblSync)
    local compressedData = LibDeflate:CompressDeflate(serializedData)
    return LibDeflate:EncodeForWoWAddonChannel(compressedData)
end
function sync:ParseSyncData(tblData, sender)
    local dbGlobal = ns.dbGlobal or {}
    local invitedCount, blackListCount, blRemovedCount = 0, 0, 0
    if not tblData.version or GRADDON.version ~= tblData.version then
        ns.code:consoleOut('Version mismatch with '..sender, 'FFFFFF00')
        ns.code:consoleOut('Your version: '..GRADDON.version, 'FFFF0000')
        ns.code:consoleOut('Their version: '..(tblData.version or 'Unknown'), 'FFFF0000')
        return
    end

    if tblData.isGuildLeader then
        dbGlobal.guildInfo = tblData.guildInfo
        dbGlobal.guildData.guildLink = tblData.guildLink ~= '' and tblData.guildLink or (dbGlobal.guildData.guildLink or nil)
    elseif not IsGuildLeader() then
        dbGlobal.guildData.guildLink = tblData.guildLink ~= '' and tblData.guildLink or (dbGlobal.guildData.guildLink or nil)
        if dbGlobal.guildInfo ~= '' then
            dbGlobal.guildInfo.messageList = tblData.guildInfo.messageList and #tblData.guildInfo.messageList > 0 and tblData.guildInfo.messageList or dbGlobal.guildInfo.messageList
            dbGlobal.guildInfo.antiSpam = tblData.guildInfo.antiSpam and tblData.guildInfo.antiSpam or dbGlobal.guildInfo.antiSpam
            dbGlobal.guildInfo.reinviteAfter = tblData.guildInfo.reinviteAfter and tblData.guildInfo.reinviteAfter or dbGlobal.guildInfo.reinviteAfter
            dbGlobal.guildInfo.greeting = tblData.guildInfo.greeting
            dbGlobal.guildInfo.greetingMsg = tblData.guildInfo.greetingMsg
        end
    end

    local tblInvited = ns.dbInv or {}
    for k,r in pairs(tblData.invitedPlayers or {}) do
        if not tblInvited[k] then
            invitedCount = invitedCount + 1
            tblInvited[k] = r
        end
    end
    ns.dbInv = tblInvited

    local tblBlackList = ns.dbBL or {}
    for k,r in pairs(tblData.blackList or {}) do
        if r.markedForDelete then
            blRemovedCount = blRemovedCount + 1
            tblBlackList[k].markedForDelete = true
        elseif not tblBlackList[k] then
            blackListCount = blackListCount + 1
            tblBlackList[k] = r
        end
    end
    ns.dbBL = tblBlackList

    ns.code.checkOut(sender..' added '..invitedCount..' new invited players.')
    ns.code.checkOut(sender..' added '..blackListCount..' new black listed players.')
    ns.code.checkOut('Finished sync with '..sender)
end
sync:Init()

local function OnCommReceived(prefix, message, distribution, sender)
    sync:OnCommReceived(prefix, message, distribution, sender) end
GRADDON:RegisterComm(GRADDON.prefix, OnCommReceived)