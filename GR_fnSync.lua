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
function sync:consoleOut(msg)
    if ns.db.settings.showAppMsgs then ns.code:consoleOut(msg) end
end
function sync:StartStatusUpdate(starting, failed)
    local syncTime = date('%H:%M %m/%d/%Y')
    local master = self.syncMaster and 'Master' or 'Client'

    if starting then
        self.syncStart = GetTime()
        ns.code:consoleOut(master..' sync started at '..syncTime)
        ns.MainScreen:SyncStatus(true, self.syncMaster, ns.code:cText('FF00FF00', 'Performing Sync'))
    else
        if not failed then ns.db.settings.lastSync = syncTime end
        ns.code:consoleOut(master..' sync complete at '..syncTime)
        if self.syncMaster then
            ns.code:consoleOut('Total sync time '..(GetTime() - self.syncStart)) end
            self.syncMaster, self.masterName = nil, nil
            ns.MainScreen:GetMessageList()
        ns.MainScreen:SyncStatus(false)
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
        sync:consoleOut('Decoding message from '..sender)
        local decodedWowMessage = LibDeflate:DecodeForWoWAddonChannel(message)
        local decompressedData = LibDeflate:DecompressDeflate(decodedWowMessage)
        success, tblData = GRADDON:Deserialize(decompressedData)
        if success then sync:consoleOut(sender..' message was decoded successfully.')
        else sync:consoleOut(sender..' message FAILED to decode.') end
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
    sync:StartStatusUpdate(true)

    self.gmFound, self.syncMaster, self.masterName = true, true, UnitName('player')
    self.totalInvited, self.totalBlackListed = 0, 0
    self.tblSyncClient = table.wipe(self.tblSyncClient) or {}

    if ns.db.settings.showAppMsgs then
        local c = 0
        for _ in pairs(ns.dbInv.invitedPlayers or {}) do c = c + 1 end
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
            sync:consoleOut('Sending data request to '..k)
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
                for _ in pairs(ns.dbInv.invitedPlayers or {}) do c = c + 1 end
                sync:consoleOut('You started with '..self.startCount..' invited players.')
                sync:consoleOut('You now have '..c..' players that have received and invite.')
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

    self.totalInvited, self.totalBlackListed = 0, 0
    local tblSync = {
        isGuildLeader = IsGuildLeader() or false,
        greetingMessage = ns.db.settings.greetingMsg or nil,
        messageList = ns.dbGlobal.messageList or {},
        rememberPlayers = ns.db.settings.antiSpam or false,
        rememberTime = ns.db.settings.reinviteAfter or 5,
        guildLink = (ns.db.guildInfo and ns.db.guildInfo.guildLink) and ns.db.guildInfo.guildLink or nil,
        invitedPlayers = ns.dbInv.invitedPlayers or {},
        blackList = ns.dbBL.blackList or {},
    }

    local serializedData = GRADDON:Serialize(tblSync)
    local compressedData = LibDeflate:CompressDeflate(serializedData)
    return LibDeflate:EncodeForWoWAddonChannel(compressedData)
end
function sync:ParseSyncData(tblData, sender)
    local invitedCount, blackListCount, blRemovedCount = 0, 0, 0

    if not self.gmFound and not IsGuildLeader() then
        self.gmFound = tblData.isGuildLeader or self.gmFound
        if (tblData.guildLink and ns.db.guildInfo.guildLink) and not IsGuildLeader() then
            ns.db.guildInfo.guildLink = tblData.guildLink end
        ns.dbGlobal.messageList = tblData.messageList or {}
        ns.db.settings.greetingMsg = ((not ns.db.settings.greetingMsg or ns.db.settings.greetingMsg:trim() == '') and tblData.greetingMessage) and tblData.greetingMessage or (ns.db.settings.greetingMsg or nil)
        ns.db.settings.antiSpam = tblData.rememberPlayers or false
        ns.db.settings.reinviteAfter = tblData.rememberTime or 5
    end

    local tblInvited = ns.dbInv.invitedPlayers or {}
    for k,r in pairs(tblData.invitedPlayers or {}) do
        if not tblInvited[k] then
            invitedCount = invitedCount + 1
            tblInvited[k] = r
        end
    end
    ns.dbInv.invitedPlayers = tblInvited

    local tblBlackList = ns.dbBL.blackList or {}
    for k,r in pairs(tblData.blackList or {}) do
        if r.markForDelete then
            blRemovedCount = blRemovedCount + 1
            tblBlackList[k].markedForDelete = true
        elseif not tblBlackList[k] then
            blackListCount = blackListCount + 1
            tblBlackList[k] = r
        end
    end
    ns.dbBL.blackList = tblBlackList

    sync:consoleOut(sender..' added '..invitedCount..' new invited players.')
    sync:consoleOut(sender..' added '..blackListCount..' new black listed players.')
    sync:consoleOut('Finished sync with '..sender)
end
sync:Init()

local function OnCommReceived(prefix, message, distribution, sender)
    sync:OnCommReceived(prefix, message, distribution, sender) end
GRADDON:RegisterComm(GRADDON.prefix, OnCommReceived)