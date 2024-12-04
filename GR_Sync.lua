local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.sync = {}
local sync = ns.sync

local aceTimer = LibStub("AceTimer-3.0")

local serverColor = 'FF0000FF'
local clientColor = 'FF00FF00'

local REQUEST_WAIT_TIMEOUT, SERVER_SEND_DATA_WAIT = 2, 60
local SYNC_FAIL_TIMER, DATA_WAIT_TIMEOUT = 120, 60

local myData, clientData = {}, {}
local cBlacklist, cAntiSpamList = 0, 0
local server, serverComms, clientComms = {}, {}, {}
local isSyncing, syncType, syncPrefix = false, nil, nil

local sender = nil -- Master of the sync
local AUTO, CLIENT, SERVER = 'AUTO', 'CLIENT', 'SERVER'
local tblSync, syncTimer = {}, {}

local function eventCHAT_MSG_ADDON(_, message, distribution, whoSent)
    if not ns.core.isEnabled then return end

    if distribution:match('GUILD'):match('WHISPER') then return
    elseif whoSent:match(UnitName('player')) then return
    elseif sync.syncType == CLIENT and whoSent:match(sender) then
        if message:match('REQUEST_SYNC') then sync:BeginSync(CLIENT, whoSent)
        elseif message:match('REQUEST_CONFIRMED') then sync:PrepClient(whoSent)
        end
    end
end
ns.observer:Register('eventCHAT_MSG_ADDON', eventCHAT_MSG_ADDON)

function sync:Init()
    if not ns.core.isEnabled then return end

    self.syncType = self.syncType or nil
    self.isSyncing = self.isSyncing or false
    if self.isSyncing or self.syncType then
        ns.code:fOut(L['SYNC_ALREADY_IN_PROGRESS']..' ('..sender..')', 'FFFF0000')
        return false
    end

    cBlacklist, cAntiSpamList = 0, 0
    myData, clientData = nil, { clients = {}, guildLeader = nil, count = 0, clientCount = 0 }
    server, serverComms, clientComms = {}, {}, {}
    self.tblFrame.syncButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    -- Metatable Creation
    syncTimer = setmetatable({}, { __index = syncTimer, })
    function syncTimer:add(k, t, func)
        if syncTimer[k] then return end

        func = func or function() self:FinishSync(k) end
        syncTimer[k] = aceTimer:ScheduleTimer(func, t)
    end
    function syncTimer:cancel(k)
        aceTimer:CancelTimer(k)
        self[k] = nil
    end
    function syncTimer:cancelAll()
        aceTimer:CancelAllTimers()
        for k, v in pairs(syncTimer) do
            if type(v) == 'table' then syncTimer[k] = nil end
        end
    end

    return true
end

--* Begin Sync Routine
function sync:BeginSync(typeOfSync, syncMaster)
    if not self:Init() then return end

    self.syncType = typeOfSync
    self.isSyncing = true

    local function beginServerSync()
        ns.code:cOut(L['SYNC_SERVER_STARTED'], serverColor)

        sender = GetUnitName('player')
        syncTimer:add('REQUEST_WAIT_TIMEOUT', REQUEST_WAIT_TIMEOUT, function()
            if clientData.receivedCount == 0 then self:FinishSync('NO_CLIENTS_FOUND_TO_SYNC_WITH')
            else
                ns.code:cOut(format.string(L['SYNC_CLIENTS_FOUND'], clientData.receivedCount), serverColor)
                self:GatherMyData()
                syncTimer:cancel('SERVER_SEND_DATA_WAIT')
                syncTimer:add('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT)
                if not ns.core.isGuildLeader then self:ServerSyncSteps('SETTINGS')
                else self:ServerSyncSteps('BLACKLIST') end
            end
        end)
        self:SendComm('REQUEST_SYNC')
    end
    local function beginClientSync()
        ns.code:cOut(L['SYNC_BEGIN_CLIENT_SYNC'], clientColor)

        sender = syncMaster
        self:GatherMyData()

        syncTimer:add('REQUEST_WAIT_TIMEOUT', REQUEST_WAIT_TIMEOUT)
        self:SendComm('REQUEST_CONFIRMED', 'WHISPER', sender)
    end

    if typeOfSync == CLIENT then beginClientSync()
    elseif typeOfSync == SERVER then beginServerSync() end
end
function sync:FinishSync(errMsg)
    self.tblFrame.syncButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    self.syncTimer:cancelAll()

    self.isSyncing, self.syncType = false, nil

    if errMsg then ns.code:fOut(L[errMsg], 'FFFF0000') end
end
--* End of Begin Sync Routine

--* Client and Master Sync Routines
function sync:GatherMyData()
    myData = {
        isGuildLeader = ns.core.isGuildLeader,
        gmSettings = ns.gmSettings,

        messageList = {},
        blacklist = {},
        antiSpamList = {},
    }
    for _, v in pairs(ns.guild.messageList) do table.insert(myData.messageList, v) end
    for k, v in pairs(ns.tblBlackList) do myData.blacklist[k] = v end
    for k, v in pairs(ns.tblAntiSpamList) do myData.antiSpamList[k] = v end
end
function sync:SendComm(message, channel, sendTo)
    channel = channel or 'GUILD'
    GR:SendCommMessage('GR', message, channel, sendTo)
end
--* End of Client and Master Sync Routines

--* Client Sync Routines
function sync:RequestSync() -- Reply that can sync with me
    
end
--* End of Client Sync Routines

--* Server Sync Routines
function sync:ServerSyncSteps(whichStep)
    syncTimer.cancel('DATA_WAIT_TIMEOUT')
    syncTimer.add('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT)

    if whichStep == 'SETTINGS' then
        ns.code:dOut('Sending Request for GM Settings to Clients.', serverColor)
        for k in pairs(clientData.clients) do self:SendComm('GM_SETTINGS', 'WHISPER', k) end
    elseif whichStep == 'BLACKLIST' then
        ns.code:dOut('Requesting Blacklist from clients.', serverColor)
        for k in pairs(clientData.clients) do self:SendComm('REQUEST_BLACKLIST', 'WHISPER', k) end
    elseif whichStep == 'ANTISPAM' then
        ns.code:dOut('Requesting Anti-Spam List from clients.', serverColor)
        for k in pairs(clientData.clients) do self:SendComm('REQUEST_ANTISPAM', 'WHISPER', k) end
    end
end
function sync:PrepClient(whoSent)
    local blankRecord = {
        gmSettings = {},
        messageList = {},
        blacklist = {},
        antiSpamList = {},
        blTotal = 0, blPacket = 0,
        asTotal = 0, asPacket = 0,
        msgTotal = 0, msgPacket = 0,
    }

    clientData.clients[whoSent] = blankRecord
    clientData.clientCount = clientData.clientCount + 1
end
--* End of Server Sync Routines