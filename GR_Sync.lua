local _, ns = ... -- Namespace (myaddon, namespace)

local AceTimer = LibStub("AceTimer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

local COMM_PREFIX = GRADDON.prefix
local REQUEST_TIMEOUT = 5
local DATA_WAIT_TIMEOUT = 60

ns.sync = {}
local sync = ns.sync

function AceTimer:CallBackSync(...) sync:OnCommReceived(nil, 'DATA_REQUEST_TIMEOUT', ...) end
function AceTimer:CallBackRequest(...) sync:OnCommReceived(nil, 'SYNC_REQUEST_TIMEOUT', ...) end
function AceTimer:CallBackClientTimeOut(sender)
    ns.code:fOut('Sync request timed out with '..sender)
    sync:StopSync()
end

function sync:Init()
    self.tblData = {}

    self.syncStarted = false
    self.syncStartTime = 0

    -- Master Variables
    self.isMaster = false
    self.masterName = nil

    -- Client Variables
    self.clientTimer = nil

    self.startInvited = 0
    self.startBlackListed = 0
end
function sync:console(msg, debug)
    if debug then ns.code:dOut(msg) else ns.code:cOut(msg) end
    ns.code:statusOut(msg)
end
-- Start/Stop Sync Routines
function sync:StopSync()
    if self.isMaster then sync:StopMasterSync()
    else sync:StopClientSync() end
end -- Decide the function to stop the sync
function sync:StartSyncServer()
    if self.syncStarted then return end

    local tblScreen = ns.screen.tblFrame
    self.isMaster, self.masterName = true, UnitName("player")

    self.syncStarted = true
    self.syncStartTime = GetTime()

    tblScreen.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    self:console('Master sync started at '..date('%H:%M %m/%d/%Y'))

    self.tblData = table.wipe(self.tblData) or {}
    self.totalInvited, self.totalBlackListed = 0, 0

    for _ in pairs(ns.dbInv and ns.dbInv or {}) do self.startInvited = self.startInvited + 1 end
    for _ in pairs(ns.dbBL and ns.dbBL or {}) do self.startBlackListed = self.startBlackListed + 1 end

    self:SendCommMessage('SYNC_REQUEST')
    AceTimer:ScheduleTimer('CallBackRequest', REQUEST_TIMEOUT)
end
function sync:StopMasterSync()
    local tblScreen = ns.screen.tblFrame
    tblScreen.syncIcon:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    if not self.syncStarted then return end

    self:console('Sync took '..ns.code:round(GetTime() - self.syncStartTime, 2)..' seconds to complete', 'DEBUG')
    self:console('Master sync completed at '..date('%H:%M %m/%d/%Y'))

    self.syncStarted, self.isMaster, self.masterName = false, false, nil
    C_Timer.After(5, function() ns.code:statusOut(' ') end)
end
function sync:StartSyncClient(masterName)
    if self.syncStarted then return end

    local tblScreen = ns.screen.tblFrame
    self.isMaster, self.masterName = false, masterName

    self.syncStarted = true
    self.syncStartTime = GetTime()

    tblScreen.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    local msgStart = 'Client sync started at '..date('%H:%M %m/%d/%Y')
    ns.code:cOut(msgStart)
    ns.code:statusOut(msgStart)
end
function sync:StopClientSync()
    local tblScreen = ns.screen.tblFrame
    tblScreen.syncIcon:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
    if not self.syncStarted then return end

    self:console('Sync took '..ns.code:round(GetTime() - self.syncStartTime, 2)..' seconds to complete', 'DEBUG')
    self:console('Client sync completed at '..date('%H:%M %m/%d/%Y'))

    self.syncStarted, self.isMaster, self.masterName = false, false, nil
    C_Timer.After(5, function() ns.code:statusOut(' ') end)
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

    -- Master Sync Error Handling
    if message:match('DATA_REQUEST_TIMEOUT') then
        if not self.tblData[sender] then return end

        self.tblData[sender] = nil
        ns.code:fOut('Failed to sync with '..sender)

        local completed, remain = true, 0
        for _, r in pairs(self.tblData) do
            if not r.hasReceivedData then
                completed = false
                remain = remain + 1
            elseif r.hasReceivedData then completed = false end
        end
        if completed then sync:StopSync()
        elseif remain == 0 then self:ParseClientData() end
    elseif message:match('SYNC_REQUEST_TIMEOUT') then
        local clientFound = false
        for k, r in pairs(self.tblData) do
            clientFound = true
            sync:console('Sending data request to '..k, 'DEBUG')
            sync:SendCommMessage('DATA_REQUEST', 'WHISPER', k)
            r.timerID = AceTimer:ScheduleTimer('CallBackSync', DATA_WAIT_TIMEOUT, k)
        end

        if not clientFound then
            sync:console('No clients found to sync with')
            sync:StopSync()
        else self:console('Sent sync requests, waiting for response...') end
    end

    if self.isMaster and sender ~= self.masterName then
        if message == 'SYNC_REQUEST_HEARD' then
            self.tblData[sender] = {}
            self.tblData[sender].hasReceivedData = false
            ns.code:dOut('Received sync acknowledgement from '..sender)
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
            if not waitLonger then self:ParseClientData() end
        end
    else
        if message == 'SYNC_REQUEST' then
            sync:StartSyncClient(sender)

            ns.code:dOut('Received sync request from '..sender)
            sync:SendCommMessage('SYNC_REQUEST_HEARD', 'WHISPER', sender)

            self.clientTimer = AceTimer:ScheduleTimer('CallBackClientTimeOut', 10, sender)
        elseif message == 'DATA_REQUEST' and sender == self.masterName then
            self:console('Received data request from '..(sender or 'sync master.'), 'DEBUG')

            AceTimer:CancelTimer(self.clientTimer)
            sync:SendCommMessage(self:PrepareDataToSend(), 'WHISPER', sender)
            self:console('Data was sent to '..(sender or 'sync master.'), 'DEBUG')
        elseif sender == self.masterName and message then
            sync:console('Received Master Data from '..sender)

            local decodedWowMessage = LibDeflate:DecodeForWoWAddonChannel(message)
            local decompressedData = LibDeflate:DecompressDeflate(decodedWowMessage)
            local success, tbl = GRADDON:Deserialize(decompressedData)
            if success then
                local invAdded, blAdded, blRemoved = sync:MergeSyncData(tbl)

                ns.code:fOut(invAdded..' players added to invited list')
                ns.code:fOut(blAdded..' players added to black list')
                if blRemoved > 0 then
                    ns.code:fOut(blRemoved..' players removed from black list') end
            else self:console('Failed to decode data from '..sender, 'DEBUG') end

            sync:StopSync()
        end
    end
end

-- Data Parsing Routines
function sync:IncorrectVersionOutput(version, sender)
    if not version or GRADDON.version ~= version then
        ns.code:fOut('Addon version mismatch with '..sender, 'FFFFFF00')
        ns.code:fOut('Your version: '..GRADDON.version, 'FFFF0000')
        ns.code:fOut('Their version: '..(version or 'Unknown'), 'FFFF0000')
    end
end
function sync:ParseClientData() -- Used when receiving client data (Master)
    self:console('Parsing client data...')
    local invAdded, blAdded, blRemoved = 0, 0, 0
    for k, r in pairs(self.tblData) do
        if r.rawData then
            local decodedWowMessage = LibDeflate:DecodeForWoWAddonChannel(r.rawData)
            local decompressedData = LibDeflate:DecompressDeflate(decodedWowMessage)
            local success, tbl = GRADDON:Deserialize(decompressedData)
            if success then
                self.tblData[k].decoded = true
                ns.code:dOut('Decoded data from '..k)

                local inv, bl, removed = self:MergeSyncData(tbl)

                blAdded = blAdded + (bl or 0)
                invAdded = invAdded + (inv or 0)
                blRemoved = blRemoved + (removed or 0)
            else self.tblData[k].decoded = false end
        end
    end

    ns.code:fOut(invAdded..' players added to invited list')
    ns.code:fOut(blAdded..' players added to black list')
    if blRemoved > 0 then
        ns.code:fOut(blRemoved..' players removed from black list') end

    local codedData = sync:PrepareDataToSend()
    for k, r in pairs(self.tblData) do
        if r.decoded then
            self:SendCommMessage(codedData, 'WHISPER', k)
        end
    end
    sync:StopSync()
end
function sync:MergeSyncData(tbl)
    if not ns.dbGlobal.guildInfo then return end

    if GRADDON.version ~= tbl.dbVersion then
        self:IncorrectVersionOutput(tbl.dbVersion, tbl.sender)
        return
    end

    if tbl.isGuildLeader and not ns.isGuildLeader then
        local tblGuildInfo = tbl.guildInfo or nil
        local tblGuildData = tbl.guildData or nil

        tblGuildInfo.guildLeader = nil
        tblGuildInfo.hasGuildLeader = false

        if tblGuildInfo then ns.dbGlobal.guildInfo = tblGuildInfo end
        if tblGuildData then ns.dbGlobal.guildData = tblGuildData end
    end

    local invAdded = 0
    ns.dbInv = ns.dbInv or {}
    for k, r in pairs(tbl.invitedPlayers and tbl.invitedPlayers or {}) do
        if not ns.dbInv[k] then
            ns.dbInv[k] = r
            invAdded = invAdded + 1
        end
    end

    local blAdded, blRemoved = 0, 0
    ns.dbBL = ns.dbBL or {}
    for k, r in pairs(tbl.blackListedPlayers and tbl.blackListedPlayers or {}) do
        if not ns.dbBL[k] then
            ns.dbBL[k] = r
            blAdded = blAdded + 1
        elseif r.markedForDeletion then
            ns.dbBL[k].markedForDeletion = true
            ns.dbBL[k].expirationTime = r.expirationTime
            blRemoved = blRemoved + 1
        end
    end

    return invAdded, blAdded, blRemoved
end
function sync:PrepareDataToSend() -- Used when sending client data (Client)
    local tbl = {}
    tbl.dbVersion = GRADDON.version

    tbl.guildInfo = ns.dbGlobal.guildInfo
    tbl.guildData = ns.dbGlobal.guildData

    tbl.invitedPlayers = ns.dbInv
    tbl.blackListedPlayers = ns.dbBL

    local serializedData = GRADDON:Serialize(tbl)
    local compressedData = LibDeflate:CompressDeflate(serializedData)

    return LibDeflate:EncodeForWoWAddonChannel(compressedData)
end
sync:Init()

local function OnCommReceived(prefix, message, distribution, sender)
    sync:OnCommReceived(prefix, message, distribution, sender) end
GRADDON:RegisterComm(GRADDON.prefix, OnCommReceived)