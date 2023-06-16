local _, ns = ... -- Namespace (myaddon, namespace)

local AceTimer = LibStub("AceTimer-3.0")
local comPrefix = GRADDON.prefix

ns.Sync = {}
local sync = ns.Sync
local db, dbInv, dbBL = nil, nil, nil
function AceTimer:CallBackWait() sync:syncDataWait() end
function AceTimer:CallBackStartClientSync() sync:startClientSync() end

function sync:Init()
    self.showConsole = false

    self.master = false
    self.syncMaster = nil
    self.tblSyncClient = {}

    self.totalInvited, self.totalBlackListed = 0, 0
end
function sync:addonStartUp()
    db, dbInv, dbBL = ns.db.profile, ns.dbInv.global, ns.dbBL.global
    self.showConsole = ns.db.global.showSystem or false
end
function sync:syncData(tblData, sender)
    db, dbInv, dbBL = ns.db.profile, ns.dbInv.global, ns.dbBL.global
    if not self.master then sync:syncStart() end
    local hasGuildLink, invitedCount, blackListCount, blRemovedCount = false, 0, 0, 0
    if tblData.guildLink then
        hasGuildLink = true
        if not db.guildInfo.guildLink then db.guildInfo.guildLink = tblData.guildLink
        elseif not IsGuildLeader() and db.guildInfo.guildLink ~= tblData.guildLink then
            db.guildInfo.guildLink = tblData.guildLink
        end
    end
    local tblInvited = dbInv.invitedPlayers or {}
    for k,r in pairs(tblData.invitedPlayers) do
        if not tblInvited[k] then
            invitedCount = invitedCount + 1
            tblInvited[k] = r
        end
    end
    dbInv.invitedPlayers = tblInvited

    local tblBlackList = dbBL.blackList or {}
    for k,r in pairs(tblData.blackList) do
        if r.markForDelete then
            blRemovedCount = blRemovedCount + 1
            tblBlackList[k].markedForDelete = true
        elseif not tblBlackList[k] then
            blackListCount = blackListCount + 1
            tblBlackList[k] = r
        end
    end
    dbBL.blackList = tblBlackList

    if self.showConsole then
        ns.code:consoleOut(sender..(hasGuildLink and ' has ' or ' does not have ')..'the guild link.')
        ns.code:consoleOut(sender..' added '..invitedCount..' new invited players.')
        ns.code:consoleOut(sender..' added '..blackListCount..' new black listed players.')
        if blRemovedCount > 0 then
            ns.code:consoleOut(sender..' removed '..blRemovedCount..' from black listed players.')
        end
        if not self.master then sync:SyncComplete() end
    end
end

-- Master Syncer Status
function sync:BeginSync()
    db, dbInv, dbBL = ns.db.profile, ns.dbInv.global, ns.dbBL.global

    db.lastSync = ns.code:cText('FF00FF00', 'Performing Sync')
    ns.MainScreen:DisableScanButton(true)
    ns.MainScreen:UpdateSyncTime()

    self.master, self.syncMaster = true, false
    self.totalInvited, self.totalBlackListed = 0, 0
    self.tblSyncClient = table.wipe(self.tblSyncClient) or {}
    sync:syncStart()
    sync:SendCommMessage('SYNC_REQUEST')
    AceTimer:ScheduleTimer('CallBackStartClientSync', 3)
end
function sync:startClientSync()
    local hasSync = false
    for k, r in pairs(self.tblSyncClient) do
        if not r.hasSentRequest then
            if self.showConsole then
                ns.code:consoleOut('Sending data request to '..k) end

            hasSync = true
            r.hasSentRequest = true
            sync:SendCommMessage('SYNC_DATA_REQUEST', 'WHISPER', k)
            r.timerID = AceTimer:ScheduleTimer('CallBackWait', 120)
        end
    end
    if not hasSync then
        ns.code:consoleOut('Could not find anyone to sync.')
        sync:SyncComplete()
    end
end
function sync:syncDataWait()
    for k, r in pairs(self.tblSyncClient) do
        if not r.hasReceivedData then
            r.hasReceivedData = true
            ns.code:consoleOut('Timeout on sync with '..k)
        end
    end

    AceTimer:CancelAllTimers()
    sync:masterSendData()
end
function sync:masterDataReceived(tblData, sender)
    if not self.tblSyncClient or not self.tblSyncClient[sender] then return end

    self.tblSyncClient[sender].hasReceivedData = true
    AceTimer:CancelTimer(self.tblSyncClient[sender].timerID)
    self.tblSyncClient[sender].timerID = nil
    sync:syncData(tblData, sender)

    local allDone = true
    for _, r in pairs(self.tblSyncClient) do
        if not r.hasReceivedData then allDone = false break end
    end

    if allDone then
        for _, r in pairs(self.tblSyncClient) do
            if r.timerID then AceTimer:CancelTimer(r.timerID) end
        end
        sync:masterSendData()
    end
end
function sync:masterSendData()
    local syncData = sync:PrepareData()
    if syncData then
        sync:SendCommMessage(syncData)
        self.master = false
    else ns.code:consoleOut('There was a problem with the sync.') end
    sync:SyncComplete()
end
function sync:CommReceived(prefix, message, distribution, sender)
    local distroOk = (distribution == 'GUILD' or distribution == 'WHISPER') and true or false
    if not distroOk or sender == UnitName('player') or prefix ~= GRADDON.prefix or not message then return end

    if message == 'SYNC_NEED_CONFIRM' then
        if not self.tblSyncClient then self.tblSyncClient = {} end
        self.tblSyncClient[sender] = { timerID = nil, hasSentRequest = false, hasReceivedData = false }
    elseif message == 'SYNC_REQUEST' then
        self.master, self.syncMaster = false, sender
        sync:SendCommMessage('SYNC_NEED_CONFIRM', 'WHISPER', sender)
    elseif not self.master and self.syncMaster == sender and message == 'SYNC_DATA_REQUEST' then
        local syncData = sync:PrepareData()
        sync:SendCommMessage(syncData, 'WHISPER', self.syncMaster)
    else
        local success, tblData = GRADDON:Deserialize(message)
        if success then
            if self.master then sync:masterDataReceived(tblData, sender)
            else sync:syncData(tblData, sender) end
        end
    end
end

-- Comm Routines
function sync:syncStart()
    local syncStart = date('%H:%M %m/%d/%Y')
    ns.code:consoleOut('Sync complete at '..syncStart)
end
function sync:SyncComplete()
    local syncEnd = date('%H:%M %m/%d/%Y')
    ns.code:consoleOut('Sync complete at '..syncEnd)
    self.master, self.syncMaster = nil, nil
    db.lastSync = syncEnd
    ns.MainScreen:UpdateSyncTime()
    ns.MainScreen:DisableScanButton(false)
end
function sync:PrepareData()
    if not ns.db then return end
    db, dbInv, dbBL = ns.db.profile, ns.dbInv.global, ns.dbBL.global

    self.totalInvited, self.totalBlackListed = 0, 0
    local tblSync = {
        guildLink = db.guildInfo.guildLink and db.guildInfo.guildLink or nil,
        invitedPlayers = dbInv.invitedPlayers or {},
        blackList = dbBL.blackList or {},
    }
    return GRADDON:Serialize(tblSync)
end
function sync:SendCommMessage(msg, chatType, target)
    if not msg then return end
    GRADDON:SendCommMessage(comPrefix, msg, (chatType or 'GUILD'), target, 'ALERT')
end
sync:Init()

function GRADDON:OnCommReceived(prefix, message, distribution, sender)
    ns.Sync:CommReceived(prefix, message, distribution, sender)
end
GRADDON:RegisterComm(comPrefix, 'OnCommReceived')