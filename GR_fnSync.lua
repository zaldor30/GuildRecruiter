local _, ns = ... -- Namespace (myaddon, namespace)

local AceTimer = LibStub("AceTimer-3.0")
local comPrefix = GRADDON.prefix

local REQUEST_TIMEOUT = 5
local DATA_WAIT_TIMEOUT = 120
local PERMORMING_SYNC = ns.code:cText('FF00FF00', 'Performing Sync')

ns.Sync = {}
local sync = ns.Sync
local db, dbInv, dbBL = nil, nil, nil

-- Callback Conversion Functions
function AceTimer:CallBackSync(...) sync:MasterSync('DATA_REQUEST_TIMEOUT', ...) end
function AceTimer:CallBackRequest(...) sync:MasterSync('SYNC_REQUEST_TIMEOUT', ...) end
function GRADDON:OnCommReceived(prefix, message, distribution, sender)
    sync:OnCommReceived(prefix, message, distribution, sender) end

function sync:Init()
    self.showConsole = false
    self.commRegistered = false

    self.master = false
    self.syncMaster = nil
    self.tblSyncClient = {}

    self.syncStart, self.startCount = nil, 0
    self.totalInvited, self.totalBlackListed = 0, 0
end
-- Miscellaneous Routines
function sync:InitializeSync()
    db, dbInv, dbBL = ns.db.profile, ns.dbInv.global, ns.dbBL.global
    self.showConsole = ns.db.global.showSystem or false

    if not self.commRegistered then
        self.commRegistered = true
        GRADDON:RegisterComm(comPrefix, 'OnCommReceived')
    end
end
function sync:StartStatusUpdate(starting, failed)
    local syncTime = date('%H:%M %m/%d/%Y')
    local master = self.master and 'Master' or 'Client'

    if starting then
        self.syncStart = GetTime()
        ns.code:consoleOut(master..' sync started at '..syncTime)
        ns.code:consoleOut('Note: Syncing data can take several minutes.')
        ns.MainScreen:SyncStatus(true, self.master, PERMORMING_SYNC)
    else
        self.master, self.syncMaster = nil, nil

        if not failed then db.lastSync = syncTime end
        ns.code:consoleOut(master..' sync complete at '..syncTime)
        if self.master then
            ns.code:consoleOut('Total sync time '..(GetTime() - self.syncStart)) end
        ns.MainScreen:SyncStatus(false)
    end
end
function sync:consoleOut(msg)
    if self.showConsole then ns.code:consoleOut(msg) end
end

-- Communications Routines
function sync:SendCommMessage(msg, chatType, target)
    if not msg then return end
    GRADDON:SendCommMessage(comPrefix, msg, (chatType or 'GUILD'), target)
end
function sync:OnCommReceived(prefix, message, distribution, sender)
    local distroOk = (distribution == 'GUILD' or distribution == 'WHISPER') and true or false
    if not distroOk or sender == UnitName('player') or prefix ~= GRADDON.prefix or not message then return end

    local success, tblData = GRADDON:Deserialize(message)

    -- Master Communications
    if self.master then
        if message == 'SYNC_NEED_CONFIRM' then sync:MasterSync(message, sender)
        elseif self.master and success then sync:MasterSync('DATA_RECEIVED', sender, tblData) end
    end

    -- Client Communications
    if not self.master then
        if message == 'SYNC_REQUEST' then sync:ClientSync(message, sender)
        elseif self.syncMaster == sender and message == 'SYNC_DATA_REQUEST' then sync:ClientSync(message, sender)
        elseif self.syncMaster == sender and message == 'REQUESTING_SYNC_DATA' then sync:ClientSync(message, sender)
        elseif self.syncMaster == sender and success then sync:ClientSync('DATA_RECEIVED', sender, tblData) end
    end
end

-- Data Routines
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
function sync:ParseSyncData(tblData, sender)
    local invitedCount, blackListCount, blRemovedCount = 0, 0, 0

    if tblData.guildLink and not not IsGuildLeader() then db.guildInfo.guildLink = tblData.guildLink end

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

    sync:consoleOut(sender..' added '..invitedCount..' new invited players.')
    sync:consoleOut(sender..' added '..blackListCount..' new black listed players.')
end

-- Master/Client Sync Routines
function sync:StartSyncMaster()
    sync:StartStatusUpdate(true)

    self.master, self.syncMaster = true, false
    self.totalInvited, self.totalBlackListed = 0, 0
    self.tblSyncClient = table.wipe(self.tblSyncClient) or {}

    if self.showConsole then
        local c = 0
        for _, r in pairs(dbInv.invitedPlayers) do c = c + 1 end
        self.startCount = c
    end

    sync:SendCommMessage('SYNC_REQUEST')
    AceTimer:ScheduleTimer('CallBackRequest', REQUEST_TIMEOUT)
end
function sync:MasterSync(msg, sender, ...)
    if msg == 'SYNC_NEED_CONFIRM' then
        self.tblSyncClient[sender] = { timerID = nil, hasReceivedData = false }
    elseif msg == 'DATA_REQUEST_TIMEOUT' and sender then
        if not self.tblSyncClient[sender] then return end

        self.tblSyncClient[sender] = nil
        ns.code:consoleOut('Failed to sync with '..sender)
        local completed = true
        for _, r in pairs(self.tblSyncClient) do
            if not r.hasReceivedData then completed = false break end
        end
        if completed then sync:StartStatusUpdate(false, true) end
    elseif msg == 'SYNC_REQUEST_TIMEOUT' then
        local clientFound = false
        for k,r in pairs(self.tblSyncClient) do
            clientFound = true
            sync:consoleOut('Sending data request to '..k)
            sync:SendCommMessage('SYNC_DATA_REQUEST', 'WHISPER', k)
            r.timerID = AceTimer:ScheduleTimer('CallBackSync', 120, k)
        end
        if not clientFound then
            ns.code:consoleOut('Did not find anyone to sync with.')
            sync:StartStatusUpdate(false, true)
        elseif not self.showConsole then ns.code:consoleOut('Sending requests to client for data.') end
    elseif msg == 'DATA_RECEIVED' then
        self.tblSyncClient[sender].hasReceivedData = true
        AceTimer:CancelTimer(self.tblSyncClient[sender].timerID)
        sync:ParseSyncData(..., sender)

        local allDone = true
        for _, r in pairs(self.tblSyncClient) do
            if not r.hasReceivedData then allDone = false break end
        end
        if allDone then
            if self.showConsole then
                local c = 0
                for _ in pairs(dbInv.invitedPlayers) do c = c + 1 end
                sync:consoleOut('You started with '..self.startCount..' invited players.')
                sync:consoleOut('You now have '..c..' players that have received and invite.')
            end
            ns.code:consoleOut('Sending merged data to all clients.')
            local syncData = sync:PrepareData()
            sync:SendCommMessage(syncData, 'GUILD', UnitName('player'))
            sync:StartStatusUpdate(false)
        end
    end
end
function sync:ClientSync(msg, sender, ...)
    if msg == 'SYNC_REQUEST' then
        self.master, self.syncMaster = false, sender
        sync:SendCommMessage('SYNC_NEED_CONFIRM', 'WHISPER', sender)
    elseif msg == 'SYNC_DATA_REQUEST' then
        sync:StartStatusUpdate(true)
        local syncData = sync:PrepareData()
        sync:SendCommMessage(syncData, 'WHISPER', self.syncMaster)
    elseif msg == 'DATA_RECEIVED' then
        sync:ParseSyncData(..., sender)
        sync:StartStatusUpdate(false)
    end
end
sync:Init()