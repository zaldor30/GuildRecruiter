local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.sync = {}
local sync, func, client, server = ns.sync, {}, {}, {}

local aceTimer = LibStub("AceTimer-3.0")

local serverColor = 'FF4040A3'
local clientColor = 'FF00FF00'

--#region ⚡ Sync Variables ⚡
local myData, clientData, syncTimer = {}, {}, {}
local SYNC_FAIL_TIMER, REQUEST_WAIT_TIMEOUT, DATA_WAIT_TIMEOUT = 120, 2, 60
local settingsChanged, messageListChanged, cBlacklist, cAntiSpamList = false, false, 0, 0

local sender = nil -- Master of the sync
local AUTO, CLIENT, SERVER = 'AUTO', 'CLIENT', 'SERVER' -- Sync Types
--#endregion
--#region ⚡ Sync Timer Metatable ⚡
syncTimer = setmetatable({}, { __index = syncTimer, })
function syncTimer:add(k, t, myFunc)
    if not k or not t or syncTimer[k] then return end

    myFunc = myFunc or (function() sync:FinishSync(k) end)
    syncTimer[k] = aceTimer:ScheduleTimer(myFunc, t)
end
function syncTimer:cancel(k)
    if not k then return end

    aceTimer:CancelTimer(k)
    if syncTimer[k] then syncTimer[k] = nil end
end
function syncTimer:cancelAll()
    aceTimer:CancelAllTimers()
    for k, v in pairs(syncTimer) do
        if type(v) == 'table' then syncTimer[k] = nil end
    end
end
--#endregion

--#region ✨ Begin Sync Routine ✨
function sync:Init()
    if not ns.core.isEnabled then return end

    self.myData = self.myData or nil
    self.syncType = self.syncType or nil
    self.isSyncing = self.isSyncing or false
    if self.isSyncing or self.syncType then
        ns.code:fOut(L['SYNC_ALREADY_IN_PROGRESS']..' ('..sender..')', 'FFFF0000')
        return false
    end

    myData, clientData = nil, { clients = {}, guildLeader = nil, count = 0, clientCount = 0 }
    settingsChanged, messageListChanged, cBlacklist, cAntiSpamList = false, false, 0, 0

    ns.base.tblFrame.syncButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    return true
end
function sync:BeginSync(typeOfSync, syncMaster)
    if not self:Init() then return end

    self.syncType = typeOfSync
    self.isSyncing = true

    sender = typeOfSync == CLIENT and syncMaster or GetUnitName('player')
    if typeOfSync == CLIENT then client:BeginSync()
    elseif typeOfSync == SERVER then server:BeginSync() end
end
function sync:FinishSync(errMsg, color)
    ns.base.tblFrame.syncButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    syncTimer:cancelAll()

    self.isSyncing, self.syncType = false, nil

    if errMsg then ns.code:fOut(L[errMsg], (color or 'FFFF0000')) end
    if settingsChanged then ns.code:cOut(L['SETTINGS_CHANGED'], ns.COLOR_DEFAULT, true) end
    if messageListChanged then ns.code:cOut(L['MESSAGE_LIST_CHANGED'], ns.COLOR_DEFAULT, true) end
    if cBlacklist > 0 then ns.code:cOut(string.format(L['BLACKLIST_CHANGED'], cBlacklist), ns.COLOR_DEFAULT, true) end
    if cAntiSpamList > 0 then ns.code:cOut(string.format(L['ANTISPAM_CHANGED'], cAntiSpamList), ns.COLOR_DEFAULT, true) end
    local syncType = self.syncType == AUTO and L['AUTO_SYNC'] or (self.syncType == SERVER and L['MANUAL_SYNC']) or L['CLIENT_SYNC']
    ns.code:cOut(syncType..' '..L['SYNC_FINISHED'])
end
--endregion

--#region ⭐  Client Sync Routines ⭐ 
function client:BeginSync()
    ns.code:cOut(sender..' '..L['SYNC_CLIENT_STARTED'])

    func:GatherMyData()

    func:SendComm('REQUEST_CONFIRMED', 'WHISPER', sender)
    syncTimer:add('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT)
    syncTimer:add('SYNC_FAIL_TIMER', SYNC_FAIL_TIMER, function() sync:FinishSync('SYNC_TIMED_OUT') end)
end
function client:SendGMSettings()
    local tblSettings = {
        guildInfo = sync.myData.guildInfo,
        gmSettings = sync.myData.gmSettings,
        messageList = sync.messageList,

        lastUpdate = sync.myData.lastUpdate,
        isGuildLeader = sync.myData.isGuildLeader,
    }
    local syncSettings = ns.code:compressData(tblSettings, true)
    if not syncSettings then
        ns.code:fOut(L['SYNC_SETTINGS_FAILED'])
        return
    end
    func:SendComm('CLIENT_GM_SETTINGS'..syncSettings, 'WHISPER', sender)
    ns.code:dOut('Sync Settings Sent to '..sender)
end
function client:SaveGMSettings()
    print('SAVING GM SETTINGS')
end
--#endregion
--#region ⭐  Server Sync Routines ⭐ 
function server:BeginSync()
    ns.code:cOut(self.syncType == AUTO and L['AUTO_SYNC_STARTED'] or L['MANUAL_SYNC_STARTED'])

    func:SendComm('REQUEST_SYNC')
    syncTimer:add('REQUEST_WAIT_TIMEOUT', REQUEST_WAIT_TIMEOUT, function()
        if clientData.clientCount == 0 then sync:FinishSync('NO_CLIENTS_FOUND_TO_SYNC_WITH', ns.COLOR_DEFAULT)
        else
            ns.code:cOut(string.format(L['SYNC_CLIENTS_FOUND'], clientData.clientCount))

            syncTimer:cancel('DATA_WAIT_TIMEOUT')
            server:ServerSyncSteps('GATHER_DATA')
        end
    end)
    syncTimer:add('SYNC_FAIL_TIMER', SYNC_FAIL_TIMER, function() sync:FinishSync('SYNC_TIMED_OUT') end)
end
function server:AddClientToSync(whoSent)
    clientData.clients[whoSent] = {
        gmSettings = {},
        messageList = {},
        blacklist = {},
        antiSpamList = {},
        blTotal = 0, blPacket = 0,
        asTotal = 0, asPacket = 0,
        msgTotal = 0, msgPacket = 0,
    }
    clientData.clientCount = clientData.clientCount + 1
end
function server:ServerSyncSteps(step)
    if step == 'GATHER_DATA' then
        func:GatherMyData()
        self:ServerSyncSteps(not ns.core.isGuildLeader and 'REQUEST_SETTINGS' or 'SEND_SETTINGS')
    elseif step == 'REQUEST_SETTINGS' then
        for k in pairs(clientData.clients) do
            func:SendComm('REQUEST_SETTINGS', 'WHISPER', k)
        end
    elseif step == 'SEND_SETTINGS' then
        local tblSettings = {
            guildInfo = sync.myData.guildInfo,
            gmSettings = sync.myData.gmSettings,
            messageList = sync.messageList,

            lastUpdate = sync.myData.lastUpdate,
            isGuildLeader = sync.myData.isGuildLeader,
        }
        local syncSettings = ns.code:compressData(tblSettings, true)
        if not syncSettings then
            ns.code:fOut(L['SYNC_SETTINGS_FAILED'])
            server:ServerSyncSteps('REQUEST_BLACKLIST')
            return
        end
        for k in pairs(clientData.clients) do
            --! CHANGE TO PROPER SEND
            func:SendComm('GM_SETTINGS'..syncSettings, 'WHISPER', k)
        end
        syncTimer:add('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT)
    elseif step == 'REQUEST_BLACKLIST' then
    elseif step == 'ANTISPAM' then
    end
end
function server:SaveGMSettings()
    print('SAVING GM SETTINGS')
end
--endregion

--#region ✴️ Shared Function Routines ✴️
function func:GatherMyData()
    myData = {
        guildInfo = ns.guildInfo,
        gmSettings = ns.gmSettings,

        messageList = {},
        blacklist = {},
        antiSpamList = {},

        lastUpdate = ns.gmSettings.lastUpdate or nil,
        isGuildLeader = ns.core.isGuildLeader,
    }

    for _, v in pairs(ns.guild.messageList) do
        if v.gmSync then table.insert(myData.messageList, v) end
    end
    if self.syncType == CLIENT then
        local lastSync = ns.guild.lastSync and (ns.guild.lastSync[sender] or nil) or nil
        for _, v in pairs(ns.guild.messageList) do table.insert(myData.messageList, v) end
        for k, v in pairs(ns.tblBlackList) do
            if not lastSync or lastSync < v.time then myData.blacklist[k] = v end
        end
        for k, v in pairs(ns.tblAntiSpamList) do
            if not lastSync or lastSync < v.time then myData.antiSpamList[k] = v end
        end
    else
        for k, v in pairs(ns.tblBlackList) do myData.blacklist[k] = v end
        for k, v in pairs(ns.tblAntiSpamList) do myData.antiSpamList[k] = v end
    end

    sync.myData = myData
end
function func:SendComm(message, channel, sendTo)
    channel = channel or 'GUILD'
    C_ChatInfo.SendAddonMessage(GR.commPrefix, message, channel, sendTo)
end
local function eventCHAT_MSG_ADDON(_,_, message, distribution, whoSent)
    if not ns.core.isEnabled then return end

    if not distribution:match('GUILD') and not distribution:match('WHISPER') then return
    elseif whoSent:match(UnitName('player')) then return
    elseif message:match('REQUEST_SYNC') then sync:BeginSync(CLIENT, whoSent)
    elseif message:match('REQUEST_CONFIRMED') then server:AddClientToSync(whoSent)
    elseif message:match('REQUEST_SETTINGS') then client:SendGMSettings()
    elseif message:match('GM_SETTINGS') then client:SaveGMSettings()
    elseif message:match('CLIENT_GM_SETTINGS') then server:SaveGMSettings()
    end
end
ns.observer:Register('eventCHAT_MSG_ADDON', eventCHAT_MSG_ADDON)
--endregion
--#region ✴️ Chunking Routines ✴️
function func:SendChunks(sendTo, prefix, data)
    if not data then return end

    sendTo = sendTo or sender
    local lastSync = ns.guild.lastSync and (ns.guild.lastSync[sendTo] or nil) or nil
    local dataSend = type(data) == 'string' and func:GatherData(data, lastSync) or data
    if not dataSend then return end
    local encodedData = ns.code:compressData(dataSend, true)
    if not encodedData then return end

    prefix = string.sub(prefix, 'C-', 1, 2) and prefix or 'C-'..prefix

    local chunkSize = #prefix + 10
    local chunks = {}
    for i=1, #encodedData, chunkSize do
        table.insert(chunks, encodedData:sub(i, i + chunkSize - 1))
    end

     local tblChunk, chunkCount, totalChunks = 0, #chunks
     local function CreateChunks()
        local chunkOut = tremove(chunks, 1)
        if not chunkOut then return end

        chunkCount = chunkCount + 1
        chunkOut = strupper(prefix)..'\\'..chunkCount..'\\'..totalChunks..'\\'..chunkOut
        tinsert(tblChunk, { sendTo = sendTo, chunkOut = chunkOut })
        CreateChunks()
     end
     CreateChunks()

     local function SendChunks()
        local chunkRecord = tremove(tblChunk, 1)
        if not chunkRecord then return end

        local chunkOut = chunkRecord.chunkOut
        local recipient = chunkRecord.sendTo
        ns.code:dOut(string.format("Sending chunk %d of %d, size: %d to %s", chunkCount, totalChunks, #chunkOut, recipient))
        func:SendComm(chunkOut, 'WHISPER', recipient)
        C_Timer.After(0.1, SendChunks)
     end
     SendChunks()
end
function func:GatherData(data, lastSync)
    local dataSend = {}
    local dataList = data == 'BLACKLIST' and ns.tblBlackList or ns.tblAntiSpamList

    return dataSend
end
--#endregion