local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local AceTimer = LibStub("AceTimer-3.0")

ns.sync = {}
local sync = ns.sync

local COMM_PREFIX = 'GRSync'
local REQUEST_WAIT_TIMEOUT = 5
local SYNC_FAIL_TIMER, DATA_WAIT_TIMEOUT = 120, 60

function sync:Init()
    self.blackList = 0
    self.antiSpamList = 0

    self.syncType = nil -- 1 = Auto, 2 = Manual, 3 = Request
    self.isSyncServer = false -- Is this the server?
    self.whoSyncingWith = nil -- Who are we syncing with? (server player name)

    self.tblMyData = nil -- My Data Table
    self.tblClients = nil -- List of Clients Table (server only)
    self.tblIncomingData = {} -- Incoming Data Table

    self.tblTimer = {} -- Timer table
    self.syncStart = nil -- Sync start time
    self.wrongVersionShown = false -- Wrong version message shown?

    self.tblSynctype = {
        [1] = 'Auto',
        [2] = 'Manual',
        [3] = 'Request',
    }
end
--* Sync Start/Stop Routines
 -- Includes gathering my data
function sync:StartSyncRoutine(syncType, sender)
    self.syncType = syncType or nil
    if not syncType then return
    elseif self.syncType and self.syncStart then
        ns.code:fOut('Sync already in progress', 'FFFF0000')
        return
        end -- Sync already in progress

    ns.win.base.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    self.syncStart = GetServerTime()
    self:AddTimer('syncTimeOut', SYNC_FAIL_TIMER, function()
        ns.code:fOut('Sync timed out', 'FFFF0000')
        ns.sync:ShutdownSync('IS_FAIL')
    end) -- Sync Timeout Timer (2 minutes)

    local syncMessage = syncType == 3 and 'Sync with '..sender or self.tblSynctype[self.syncType]
    ns.code:cOut('Starting '..syncMessage, GRColor)

    local function masterSync() --* Start Master Sync Routine
        ns.code:cOut('Requesting Sync from Clients', GRColor)
        self:SendCommMessage('SYNC_REQUEST', 'GUILD')
        self:AddTimer('MASTER_WAIT_FOR_CLIENT_RESPONSE', REQUEST_WAIT_TIMEOUT, function()
            local count = 0
            for _ in pairs(self.tblClients and self.tblClients or {}) do count = count + 1 end
            if count == 0 then
                ns.code:fOut('No clients to sync with.', 'FFFF0000')
                ns.sync:ShutdownSync('IS_FAIL')
                return
            else
                self:CancelTimer('syncWait')
                ns.code:cOut('Found '..count..' guild member to sync with.', GRColor)
                self:SendCommMessage('SEND_YOUR_SYNC_DATA', 'GUILD')
                self:AddTimer('WAIT_FOR_DATA', DATA_WAIT_TIMEOUT, function()
                    ns.code:fOut('Sync request with clients timed out.', 'FFFF0000')
                    ns.sync:ShutdownSync('IS_FAIL')
                end)
            end
        end)
    end
    local function clientSync() --* Start Client Sync Routine
        self:GetMyData()
        self:AddTimer('WAIT_FOR_DATA', DATA_WAIT_TIMEOUT, function()
            ns.code:fOut('Sync request with '..sender..' timed out.', 'FFFF0000')
            ns.sync:ShutdownSync('IS_FAIL')
        end)
    end

    if syncType == 3 then clientSync()
    else masterSync() end
end
function sync:ShutdownSync(isFail)
    if not isFail then
        ns.code:fOut('Black List: '..self.blackList..' added.', GRColor)
        ns.code:fOut('Anti Spam List: '..self.antiSpamList..' added.', GRColor)
    end

    self:CancelTimer('ALL')

    ns.win.base.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    local syncMessage = self.syncType == 3 and 'Client Sync' or self.tblSynctype[self.syncType]
    ns.code:fOut(syncMessage..' Sync Complete', GRColor)

    self:Init() -- Reset init variables
end
--* Sync Support Routines
-- Timer Routines
function sync:AddTimer(timerName, length, func)
    if not timerName or not length then
        ns.code:dOut('Add Timer issue: name: '..timerName..' length: '..length)
        return end
    if self.tblTimer[timerName] then return end

    self.tblTimer[timerName] = AceTimer:ScheduleTimer(func, length)
end
function sync:CancelTimer(key)
    if not key then return
    elseif key ~= 'ALL' and not self.tblTimer[key] then return end

    if key == 'ALL' then AceTimer:CancelAllTimers()
    else
        AceTimer:CancelTimer(self.tblTimer[key])
        self.tblTimer[key] = nil
    end
end

--* Comm Routines
function sync:CommReceived(message, sender)
    self.tblClients = self.tblClients or {}

    if not message or not sender or sender == UnitName('player') then return end

    local success, tblData = ns.code:decompressData(message, 'DECODE_DATA')
    if success and tblData and self.tblClients[sender] then -- or (self.syncType == 3 and sender == self.whoSyncingWith) then
        ns.code:dOut('Received sync data from '..sender)
        self.tblClients[sender] = tblData
        if self.syncType == 3 then
            self:ProcessClientSyncData()
            self:ShutdownSync()
            return
        end
        self.tblClients[sender].receivedData = true

        local dataReady = true
        if self.syncType <= 2 then
            for key, v in pairs(self.tblClients) do
                if not v.receivedData then print(key..' not ready.') dataReady = false return end
            end
        end

        if dataReady then
            self:ProcessClientSyncData()
            ns.code:dOut('Sending server data to clients.')
            self:SendCommMessage(self.tblMyData, 'GUILD')
            self:ShutdownSync()
        end
    elseif not self.syncType and message == 'SYNC_REQUEST' then -- Start clicnet sync
        ns.code:dOut('Sync request received from '..sender)

        self.whoSyncingWith = sender
        self:StartSyncRoutine(3, sender)
        self.tblClients[sender] = {}

        self:SendCommMessage('SYNC_REQUEST_HEARD', 'WHISPER', sender)
        self:AddTimer('WAIT_FOR_DATA', DATA_WAIT_TIMEOUT, function()
            self:ProcessClientSyncData() -- Process data if all clients have not responded
        end)
    elseif self.syncType <= 2 and message == 'SYNC_REQUEST_HEARD' then -- Client response
        ns.code:dOut('Sync request heard from '..sender)

        -- Got my data in start sync routine
        self.tblClients[sender] = {}
    elseif self.syncType == 3 and self.whoSyncingWith == sender and message == 'SEND_YOUR_SYNC_DATA' then
        ns.code:dOut('Received sync data request from '..sender)
        self:SendCommMessage(self.tblMyData, 'WHISPER', sender)
        self:AddTimer('WAIT_FOR_DATA', DATA_WAIT_TIMEOUT, function()
            ns.code:fOut('Sync request with '..sender..' timed out.', 'FFFF0000')
            ns.sync:ShutdownSync('IS_FAIL')
        end)
    end
end
function sync:SendCommMessage(msg, chatType, target)
    if not msg then return end
    chatType = chatType or 'GUILD'
    GR:SendCommMessage(COMM_PREFIX, msg, chatType, (target or nil), 'ALERT')
end

--* Sync Data Processing Routines
function sync:ProcessClientSyncData()
    local realGMUpdated = false

    local function findRevision(ver)
        local firstDecimal = ver:find('.')
        local secondDecimal = ver:find('.', firstDecimal + 1)

        local clientRev = tonumber(ver:sub(secondDecimal + 1))
        firstDecimal = GR.version:find('.')
        secondDecimal = GR.version:find('.', firstDecimal + 1)
        local myRev = tonumber(GR.version:sub(secondDecimal + 1))

        return myRev, clientRev
    end
    for k, r in pairs(self.tblClients) do
        local skipRecord = false
        local rev, clientRev = findRevision(r.grVersion)
        if rev > clientRev then ns.code:fOut(k:gsub('-', '')..' using an older version ('..r.grVersion..').', 'FFFFAE00')
        elseif rev < clientRev then ns.code:fOut(k:gsub('-', '')..' using a newer version ('..r.grVersion..').', 'FFFFAE00') end

        local dbRev, dbClientRev = findRevision(r.dbVersion)
        if r.dbVersion ~= dbClientRev then
            if dbRev > dbClientRev then ns.code:fOut(k:gsub('-', '')..' using an older version ('..r.dbVersion..').', 'FFFFAE00')
            else ns.code:fOut(k:gsub('-', '')..' using a newer version ('..r.dbVersion..').', 'FFFFAE00') end
            self.tblClients[k] = nil
            skipRecord = true
        end

        if not skipRecord then
            --* Sync GM Data
            if (not realGMUpdated and not ns.guildInfo.isGuildLeader) or r.isGuildLeader then
                ns.guildInfo.guildLink = r.guildInfo.guildLink or r.guildInfo.guildLink or ''
                realGMUpdated = r.isGuildLeader or false
                if realGMUpdated then ns.guildInfo.guildLeaderToon = r.guildLeaderToon end
                ns.gmSettings.sendGuildGreeting = r.guildInfo.sendGuildGreeting or false
                ns.gmSettings.guildMessage = r.guildInfo.guildMessage or nil
                ns.gmSettings.sendWhisperGreeting = r.guildInfo.sendWhisperGreeting or false
                ns.gmSettings.whisperMessage = r.guildInfo.whisperMessage or nil

                -- Update GM messages
                for key, v in pairs(ns.gSettings.messageList or {}) do -- Remove all GM messages
                    if v.type == 'GM' then
                        ns.gSettings.messageList[key] = nil
                    end
                end
                for _, v in pairs(r.messageList) do -- Add all GM messages
                    if v.type == 'GM' then
                        tinsert(ns.gSettings.messageList, v)
                    end
                end
            end

            --* Sync Black List
            for key, v in pairs(r.blackList) do
                if not ns.tblBlackList[key] then
                    ns.tblBlackList[key] = v
                    self.blackList = self.blackList + 1
                end
            end
            --* Sync Anti Spam List
            for key, v in pairs(r.antiSpamList) do
                if not ns.tblAntiSpamList[key] then
                    ns.tblAntiSpamList[key] = v
                    self.antiSpamList = self.antiSpamList + 1
                end
            end
        end
    end

    self:GetMyData(realGMUpdated)
end
function sync:GetMyData(realGMUpdated) --* Gather Data for Sync
    local tblGMMessages = {}

    for k, r in pairs(ns.gSettings.messageList) do
        if r.type == 'GM' then tblGMMessages[k] = r end
    end

    local tbl = {
        ['grVersion'] = GR.version,
        ['dbVersion'] = GR.dbVersion,
        ['guildInfo'] = {
            ['guildLink'] = ns.guildInfo.guildLink or nil,
            ['isGuildLeader'] = (realGMUpdated or ns.guildInfo.isGuildLeader) or false,
            ['guildLeaderToon'] = ns.guildInfo.guildLeaderToon or nil,
            ['sendGuildGreeting'] = ns.gmSettings.sendGuildGreeting or false,
            ['guildMessage'] = ns.gmSettings.guildMessage or nil,
            ['sendWhisperGreeting'] = ns.gmSettings.sendWhisperGreeting or false,
            ['whisperMessage'] = ns.gmSettings.whisperMessage or nil,
        },
        ['blackList'] = ns.tblBlackList,
        ['messageList'] = tblGMMessages,
        ['antiSpamList'] = ns.tblAntiSpamList,
        ['sentData'] = true,
        ['receivedData'] = false,
    }

    self.tblMyData = ns.code:compressData(tbl, 'ENCODE_DATA')
    if not self.tblMyData then
        ns.code:fOut('Error compressing my data for sync', 'FFFF0000')
        self:ShutdownSync('IS_FAIL')
        return
    end
end
sync:Init()

local function OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX then return
    elseif distribution ~= 'GUILD' and distribution ~= 'WHISPER' then return end

    sync:CommReceived(message, sender)
end
GR:RegisterComm(COMM_PREFIX, OnCommReceived)