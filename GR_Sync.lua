local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local AceTimer = LibStub("AceTimer-3.0")

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("AceSerializer-3.0")

ns.sync = {}
local sync = ns.sync

local COMM_PREFIX = GR.commPrefix
local REQUEST_WAIT_TIMEOUT = 5
local SYNC_FAIL_TIMER, DATA_WAIT_TIMEOUT = 120, 60

function sync:Init()
    self.useVerboseDebug = false

    self.cBlackList = 0 -- Blacklist Count
    self.cAntiSpamList = 0 -- Anti-Spam Count

    self.syncType = nil -- 1 = Auto, 2 = Manual, 3 = Request
    self.isSyncServer = false -- Is this the server?
    self.whoSyncingWith = nil -- Who are we syncing with? (server player name)

    self.myData = nil -- My Data Table
    self.tblChuncks = {} -- Chuncks Table key = player name, chuncks = table for each player, tChuncks = total chuncks
    self.tblClients = {} -- List of Clients Table (server only)
    self.tblIncomingData = {} -- Incoming Data Table

    self.tblTimer = {} -- Timer table
    self.isSyncing = nil -- Sync start time
    self.syncStartTime = false -- Sync start time

    self.syncPrefix = nil -- Sync Prefix for console output

    self.tblSynctype = {
        [1] = 'Auto',
        [2] = 'Manual',
        [3] = 'Client',
    }
end

--[[ Timer List
    SYNC_TIMED_OUT: Overall Sync Timeout
    SYNC_REQUEST_TIME_OUT: Sync Client Request Timeout
    DATA_WAIT_TIMEOUT: Data Wait Timeout
    <Player Name>_SYNC_REQUEST_TIME_OUT: Client Sync Request Timeout
    ALL: Cancel All Timers
]]

--* Sync Start/Stop Routines
function sync:StartSyncRoutine(syncType, sender)
    self.syncType = syncType or nil
    if not ns.core.isEnabled then return
    elseif self.syncType and self.syncStart then
        ns.code:fOut(L['SYNC_ALREADY_IN_PROGRESS']..' ('..self.whoSyncingWith..')', 'FFFF0000')
        return
    end

    ns.win.base.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    self.isSyncing = true
    self.isSyncServer = true
    self.syncStartTime = GetServerTime()

    --* Start Overall Timeout Timer in case of failure
    self:AddTimer('SYNC_TIMED_OUT', SYNC_FAIL_TIMER, function()
        ns.code:fOut('Sync timed out', 'FFFF0000')
        ns.sync:ShutdownSync('IS_FAIL')
    end) -- Sync Timeout Timer (2 minutes)

    self.syncPrefix = syncType == 3 and 'Sync with '..sender or self.tblSynctype[self.syncType]..' Sync'
    ns.code:fOut('Starting '..self.syncPrefix, GRColor)

    --* Master Sync Start
    local function masterSync()
        ns.code:dOut('Requesting sync from clients.')
        self:SendCommMessage('SYNC_REQUEST', 'GUILD') -- Check for clients
        self:AddTimer('SYNC_REQUEST_TIME_OUT', REQUEST_WAIT_TIMEOUT, function()
            if #self.tblClients > 0 then
                self:CancelTimer('SYNC_REQUEST_TIME_OUT')
                self:StartMasterSync()
            else
                ns.code:fOut(L['NO_CLIENTS_FOUND'], GRColor)
                self:ShutdownSync('IS_FAIL')
            end
        end)
    end

    if syncType == 3 then self:StartClientSync()
    else masterSync() end
end
function sync:ShutdownSync(isFail)
    if not isFail then
        if self.cBlackList > 0 then ns.code:cOut(L['TOTAL_BLACKLISTED']..': '..self.cBlackList, GRColor)
        else ns.code:cOut(L['NO_BLACKLISTED_ADDED'], GRColor) end

        if self.cAntiSpamList > 0 then ns.code:cOut(L['ANTI_SPAM']..': '..self.cAntiSpamList, GRColor)
        else ns.code:cOut(L['NO_ANTISPAM_ADDED'], GRColor) end
    end
    self:CancelTimer('ALL')
    ns.win.base.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    ns.code:fOut((self.syncPrefix..' Sync Complete'):gsub('Sync Sync', 'Sync'), GRColor)
    self:Init() -- Reset Sync Variables
end
--? End of Start/Stop Sync

--* Sync Start Control Functions
function sync:StartMasterSync()
    ns.code:cOut('Found '..#self.tblClients..' guild member to sync with.', GRColor)

    for i=1, #self.tblClients do
        local sender = self.tblClients[i]
        ns.code:dOut('Requesting data from '..sender)
        self:SendCommMessage('SYNC_YOUR_DATA', 'WHISPER', sender)
        self:AddTimer(sender..'_SYNC_REQUEST_TIME_OUT', REQUEST_WAIT_TIMEOUT, function()
            ns.code:fOut('Failed to receive data from '..sender, 'FFFF0000')
            self:ShutdownSync('IS_FAIL')
        end)
    end

    --* Start Data Wait Timer
    self:AddTimer('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT, function()
        ns.code:fOut(L['FAILED_TO_RECEIVE_SYNC_DATA'], 'FFFF0000')
        self:ShutdownSync('IS_FAIL')
    end)
end
function sync:StartClientSync()
    self:GatherLocalData() -- Gather Local Data and package it.
    self:SendCommMessage('CLIENT_SYNC_DATA', 'WHISPER', self.whoSyncingWith)
    ns.code:dOut('Sending data to '..self.whoSyncingWith)

    self:AddTimer('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT, function()
        ns.code:fOut(L['FAILED_TO_RECEIVE_SYNC_DATA']..' '..self.whoSyncingWith, 'FFFF0000')
        self:ShutdownSync('IS_FAIL')
    end)
end
--? End of Sync Start Control Functions

--* Timer Functions
function sync:AddTimer(tName, tLength, func)
    if not tName or not tLength then
        ns.code:dOut('Add Timer issue: name: '..tName..' length: '..tLength)
        return
    elseif self.tblTimer[tName] then return end

    self.tblTimer[tName] = AceTimer:ScheduleTimer(func, tLength)
    if self.useVerboseDebug then ns.code:dOut('Timer Added: '..tName..' ('..tLength..')') end
end
function sync:CancelTimer(key)
    if not key then return
    elseif key ~= 'ALL' and not self.tblTimer[key] then
        if self.useVerboseDebug then ns.code:dOut('Timer not found: '..key) end
        return end

    if key == 'ALL' then
        if self.useVerboseDebug then ns.code:dOut('Cancelling All Timers') end
        AceTimer:CancelAllTimers()
    else
        if self.useVerboseDebug then ns.code:dOut('Cancelling Timer: '..key) end
        AceTimer:CancelTimer(self.tblTimer[key])
        self.tblTimer[key] = nil
    end
end
--? End of Timer Functions

--* Data Functions
function sync:GatherLocalData()
    local tbl = {}

    tbl.guildInfo = ns.guildInfo
    tbl.gmSettings = ns.gmSettings
    tbl.isGuildMaster = ns.core.hasGM

    tbl.blackList = ns.tblBlackList
    tbl.antiSpamList = ns.tblAntiSpamList

    local encodedData = self:PackageData(tbl)
    if not encodedData then
        self:ShutdownSync('IS_FAIL')
        return
    else self.myData = encodedData end
end
function sync:PackageData(tbl)
    if not tbl then return end

    local serailized = LibSerialize:Serialize(tbl) -- Serialize the table
    local compressed = LibDeflate:CompressDeflate(serailized) -- Compress the serialized table
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed) -- Encode the compressed table

    local result = self:UnpackageData(encoded) or nil
    if not result then
        ns.code:fOut('Failed to package data.', 'FFFF0000')
        return
    end

    return encoded
end
function sync:UnpackageData(encodedData)
    local data = LibDeflate:DecodeForWoWAddonChannel(encodedData)
    if not data then
        ns.code:fOut('Failed to decode data.', 'FFFF0000')
        return
    end

    local decompressed = LibDeflate:DecompressDeflate(data)
    if not data then
        ns.code:fOut('Failed to decompress data.', 'FFFF0000')
        return
    end

    local success, finalData = LibSerialize:Deserialize(decompressed)
    if not success then
        ns.code:fOut('Failed to deserialize data.', 'FFFF0000')
        return
    end

    return finalData
end
function sync:ProcessClientData(fullData, sender)
    local tbl = self:UnpackageData(fullData)

    if not tbl then
        ns.code:fOut('Failed to process client data.', 'FFFF0000')
        self:ShutdownSync('IS_FAIL')
        return
    end

    ns.code:dOut('Processing client data from '..sender..'.')
    local guildLeadFound = false
    if not ns.core.hasGM and not guildLeadFound then
        guildLeadFound = tbl.isGuildMaster
        ns.guildInfo = tbl.guildInfo
        ns.gmSettings = tbl.gmSettings
    end

    --* Blacklist and Anti-Spam List
    if tbl.blackList then
        for k, v in pairs(tbl.blackList) do
            if not ns.tblBlackList[k] then
                ns.tblBlackList[k] = v
                self.cBlackList = self.cBlackList + 1
            end
        end
    end

    --* Anti-Spam List
    if tbl.antiSpamList then
        for k, v in pairs(tbl.antiSpamList) do
            if not ns.tblAntiSpamList[k] then
                ns.tblAntiSpamList[k] = v
                self.cAntiSpamList = self.cAntiSpamList + 1
            end
        end
    end

    if self.isSyncServer then
        ns.code:cOut('Sending out updated client data.', GRColor)
        self:GatherLocalData()
        self:ChunkDataAndSend(self.myData, sender)
    end
    self:ShutdownSync()
end
function sync:ChunkDataAndSend(encodedData, sender)
    if not encodedData then
        ns.code:dOut('Failed to chunk data.', 'FFFF0000')
        return
    end

    local chunkSize = 250
    local totalChunks = math.ceil(#encodedData / chunkSize)
    if GR.useVerboseDebug then
        ns.code:dOut('Total Chunks: '..totalChunks..' With a size of '..chunkSize) end

    for i = 1, totalChunks do
        local sendTo = sender == 'ALL' and 'GUILD' or 'WHISPER'
        local chunk = string.sub(encodedData, (i - 1) * chunkSize + 1, i * chunkSize)
        local message = string.format("%d:%d:%s", i, totalChunks, chunk)
        self:SendCommMessage(message, sendTo, (sender == 'ALL' and nil or sender))
        -- Use a delay here if needed to prevent spam
    end
end
--? End of Data Functions

--* Communication Functions
--[[
    SYNC_REQUEST: Request for Sync
    SYNC_REQUEST_HEARD: Sync Request Heard
    SYNC_YOUR_DATA: Send your data
    CLIENT_SYNC_DATA: Send your data
    SEND_YOUR_DATA: Send your data
]]
function sync:SendCommMessage(msg, channel, target)
    if not msg then return end

    if channel == 'GUILD' or not channel then
        C_ChatInfo.SendAddonMessage(COMM_PREFIX, msg, 'GUILD')
    elseif channel == 'WHISPER' then
        C_ChatInfo.SendAddonMessage(COMM_PREFIX, msg, 'WHISPER', target)
    end
end
function sync:CommReceived(msg, sender)
    if not msg then return end

    if msg:find('SYNC_REQUEST_HEARD') then -- Server Response
        local _, vDB, version = strsplit(';', msg)
        ns.code:dOut('Received SYNC_REQUEST_HEARD from '..sender)

        if vDB then
            local verClient, verMine = tonumber(vDB), tonumber(GR.dbVersion)
            if verClient < verMine then
                ns.code:fOut(sender..' '..L['OLDER_VERSION']..' ('..version..').', 'FFBDBE5A')
                self:SendCommMessage('WRONG_VERSION;'..L['OLDER_VERSION'], 'WHISPER', sender)
                return
            elseif verClient > verMine then
                ns.code:fOut(sender..' '..L['NEWER_VERSION']..' ('..version..').', 'FFBDBE5A')
                self:SendCommMessage('WRONG_VERSION;'..L['NEWER_VERSION'], 'WHISPER', sender)
                return
            end
        else
            ns.code:fOut(sender..' '..L['OUTDATED_VERSION']..'.', 'FFBDBE5A')
            self:SendCommMessage('WRONG_VERSION;'..L['OUTDATED_VERSION'], 'WHISPER', sender)
            return
        end

        table.insert(self.tblClients, sender)
    elseif msg:find('SYNC_REQUEST') then -- Client Response
        ns.code:cOut('Started sync '..sender..' as a client.', GRColor)
        local sendMessage = 'SYNC_REQUEST_HEARD;'..GR.dbVersion..';'..GR.version

        self.syncPrefix = 'Sync with '..sender
        self:GatherLocalData() -- Gather Local Data and package it.
        self:SendCommMessage(sendMessage, 'WHISPER', sender)
        self:AddTimer('WAIT_FOR_SERVER_REPLY', REQUEST_WAIT_TIMEOUT, function()
            ns.code:fOut('Failed to receive reply from '..sender, 'FFFF0000')
            self:ShutdownSync('IS_FAIL')
        end)
    elseif msg:find('SYNC_YOUR_DATA') then -- Server Response
        ns.code:dOut('Received SYNC_YOUR_DATA from '..sender)
        self:CancelTimer('WAIT_FOR_SERVER_REPLY')

        self:ChunkDataAndSend(self.myData, sender)
    elseif msg:find('WRONG_VERSION') then -- Wrong Version Response
        local _, message, myVer, newVer = strsplit(';', msg)
        ns.code:fOut(message, 'FFBDBE5A')
        ns.code:fOut('Version Running: '..myVer..self.whoSyncingWith..' Version: '..newVer, 'FFBDBE5A')
        self:ShutdownSync('IS_FAIL')
    else -- Data Response
        if not msg then
            ns.code:dOut('Received empty message from '..sender)
            return
        end
        ns.code:dOut('Received chunk from '..sender)

        local index, totalChunks, chunk = string.match(msg, "^(%d+):(%d+):(.+)$")

        self.tblChuncks[sender] = self.tblChuncks[sender] or {}
        self.tblChuncks[sender].tChuncks = tonumber(totalChunks) or 0
        self.tblChuncks[sender].chunkCount = self.tblChuncks[sender].chunkCount and self.tblChuncks[sender].chunkCount + 1 or 1
        self.tblChuncks[sender].tblChuncks = self.tblChuncks[sender].tblChuncks or {}
        self.tblChuncks[sender].tblChuncks[tonumber(index)] = chunk

        if self.tblChuncks[sender].chunkCount >= self.tblChuncks[sender].tChuncks then
            tremove(self.tblClients, 1)
            self:CancelTimer(sender..'_SYNC_REQUEST_TIME_OUT')
            ns.code:dOut('Received all chunks from '..sender)

            local fullData = table.concat(self.tblChuncks[sender].tblChuncks)
            if not fullData or fullData == '' then
                ns.code:fOut('Failed to receive data from '..sender, 'FFFF0000')
                self:ShutdownSync('IS_FAIL')
                return
            end

            if #self.tblClients == 0 then self:ProcessClientData(fullData, sender) end
        end
    end
end
--* Communication Event Setup

--? End of Communication Functions
sync:Init() -- Initialize Sync Table