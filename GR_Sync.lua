local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local aceTimer = LibStub("AceTimer-3.0")

ns.sync = {}
local sync, gSync = {}, ns.sync

local REQUEST_WAIT_TIMEOUT, SERVER_SEND_DATA_WAIT = 2, 60
local SYNC_FAIL_TIMER, DATA_WAIT_TIMEOUT = 120, 60

local myData, clientData = nil, { clients = {}, count = 0, receivedCount = 0 }
local cBlacklist, cAntiSpamList = 0, 0
local server, serverComms, clientComms = {}, {}, {}
local isSyncing, syncMaster, syncType, syncPrefix = false, nil, nil, nil

--* Timer Metatable Functions
local timer = {}
timer = setmetatable({}, {
    __index = timer,
})
function timer:add(k, t, func)
    if timer[k] then return end

    timer[k] = aceTimer:ScheduleTimer(func, t)
end
function timer:cancel(k)
    aceTimer:CancelTimer(k)
    self[k] = nil
end
function timer:cancelAll()
    aceTimer:CancelAllTimers()
    for k, v in pairs(timer) do
        if type(v) == 'table' then timer[k] = nil end
    end
end
--? End of Timer Metatable Functions


function sync:Init()
end
--* Start and End of Sync Routines
function sync:StartSync(typeOfSync, sender)
    if not ns.core.isEnabled then return
    elseif isSyncing then
        if typeOfSync == 2 then
            ns.code:fOut(L['SYNC_ALREADY_IN_PROGRESS']..' ('..(syncMaster or sender)..')', 'FFFF0000') end
        return
    end

    ns.win.base.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    isSyncing, syncType, syncMaster = true, typeOfSync, (sender or UnitName('player'))
    syncPrefix = syncType == 1 and 'Auto Sync' or syncType == 2 and 'Manual Sync' or 'Sync with '..syncMaster
    ns.code:cOut('Starting '..syncPrefix..'.', GRColor)

    timer:add('SYNC_TIMED_OUT', SYNC_FAIL_TIMER, function() self:EndOfSync('IS_FAIL', L['SYNC_TIMED_OUT']) end)

    if syncType ~= 3 then server:StartServerSync(typeOfSync, syncMaster) end
end
function sync:EndOfSync(isFail, failMessage)
    if isFail and failMessage then ns.code:fOut(failMessage, 'FFFF0000')
    else
        if cBlacklist > 0 then ns.code:cOut(L['TOTAL_BLACKLISTED']..': '..cBlacklist, GRColor) end
        if cAntiSpamList > 0 then ns.code:cOut(L['ANTI_SPAM']..': '..cAntiSpamList, GRColor) end
    end

    timer:cancelAll()

    ns.code:fOut(syncPrefix..' is complete.', GRColor)
    isSyncing, syncMaster, syncType, syncPrefix = false, nil, nil, nil
    ns.win.base.tblFrame.syncIcon:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    clientData = table.wipe(clientData)
    clientData = { clients = {}, count = 0, receivedCount = 0 }
end
--? End of Start and End of Sync Routines

--* Sync Server Routines
local function serverSync()
    local tblFunc = {}
    function tblFunc:StartServerSync(typeOfSync, sender) -- SYNC_REQUEST
        ns.code:dOut(L['FINDING_CLIENTS_SYNC'])
        GR:SendCommMessage(GR.commPrefix, 'SYNC_REQUEST;'..GR.dbVersion..';'..GR.version, 'GUILD')
        timer:add('SYNC_REQUEST_TIME_OUT', REQUEST_WAIT_TIMEOUT, function()
            timer:cancel('SYNC_REQUEST_TIME_OUT')
            if (clientData.count or 0) > 0 then
                ns.code:cOut(L['CLIENTS_FOUND']..' '..tostring(clientData.count), GRColor)
                server:SendDataRequests()
            else
                ns.code:fOut(L['NO_CLIENTS_FOUND'], GRColor)
                sync:EndOfSync()
            end
        end)
    end
    function tblFunc:SendDataRequests() -- SYNC_DATA_REQUEST
        timer:cancel('SYNC_REQUEST_TIME_OUT')
        for k in pairs(clientData.clients) do
            ns.code:dOut('Sending Data Request to '..k)
            GR:SendCommMessage(GR.commPrefix, 'SYNC_DATA_REQUEST', 'WHISPER', k)
        end
        timer:add('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT, function() sync:EndOfSync('IS_FAIL', L['FAILED_TO_SEND_SYNC_DATA']) end)
    end

    return tblFunc
end
local function serverCommsSync()
    local tblFunc = {}
    function tblFunc:OnCommReceived(message, sender)
        if message:match('SYNC_REQUEST_HEARD') then
            if clientData.clients[sender] then
                ns.code:dOut('Duplicate Sync Request Heard from '..sender)
                return
            end

            ns.code:dOut('Sync Request Heard from '..sender)
            if not sync:CheckVersion(message, sender) then return end
            if not clientData.clients[sender] then
                clientData.clients[sender] = {}
                clientData.clients[sender].chunks = {}
                clientData.clients[sender].restored = {}
            end
            clientData.count = clientData.count and clientData.count + 1 or 1
            timer:add(sender..'_SYNC_REQUEST_TIME_OUT', SERVER_SEND_DATA_WAIT, function() sync:EndOfSync('IS_FAIL', sender..' '..L['FAILED_TO_RECEIVE_SYNC_DATA']) end)
        else
            if sync:ProcessChunks(message, sender) then
                clientData.receivedCount = clientData.receivedCount and clientData.receivedCount + 1 or 1
                if clientData.receivedCount ~= clientData.count then return end

                sync:ImportData()
                sync:GatherMyData()
                for k in pairs(clientData.clients) do
                    ns.code:dOut('Sending Data to '..k)
                    sync:SendChunks(k)
                end

                sync:EndOfSync()
            end
        end
    end

    return tblFunc
end
server = serverSync()
serverComms = serverCommsSync()
--? End of Sync Server Routines

--* Sync Client Routines
local function clientCommsFunctions()
    local tblFunc = {}
    function tblFunc:OnCommReceived(message, sender)
        if not message then return end

        if message:match('SYNC_REQUEST;') then
            if isSyncing then return
            else sync:StartSync(3, sender) end

            ns.code:cOut(L['SYNC_REQUEST_RECEIVED']..' '..sender, GRColor)
            if not sync:CheckVersion(message, sender) then sync:EndOfSync() return end

            sync:GatherMyData()
            timer:add(sender..'_SYNC_REQUEST_TIME_OUT', DATA_WAIT_TIMEOUT, function() sync:EndOfSync('IS_FAIL', sender..' '..L['FAILED_TO_RECEIVE_SYNC_DATA']) end)
            GR:SendCommMessage(GR.commPrefix, 'SYNC_REQUEST_HEARD;'..GR.dbVersion..';'..GR.version, 'WHISPER', sender)
        elseif message:match('SYNC_DATA_REQUEST') then
            timer:cancel(sender..'_SYNC_REQUEST_TIME_OUT')
            ns.code:dOut('Received Data Request from '..sender)
            sync:SendChunks(sender)
            timer:add('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT, function() sync:EndOfSync('IS_FAIL', L['FAILED_TO_SEND_SYNC_DATA']) end)
        else
            if not clientData.clients[sender] then
                clientData.clients[sender] = {}
                clientData.clients[sender].chunks = {}
                clientData.clients[sender].restored = {}
            end

            if sync:ProcessChunks(message, sender) then
                ns.code:dOut('Data Received from '..sender)
                sync:ImportData()
                sync:EndOfSync()
            end
        end
    end

    return tblFunc
end
clientComms = clientCommsFunctions()
--? End of Sync Client Routines

--[[ Timer List
    SYNC_TIMED_OUT: Overall Sync Timeout
    SYNC_REQUEST_TIME_OUT: Sync Client Request Timeout
    DATA_WAIT_TIMEOUT: Data Wait Timeout
    <Player Name>_SYNC_REQUEST_TIME_OUT: Client Sync Request Timeout
    ALL: Cancel All Timers
]]
--* Data Functions
function sync:GatherMyData()
    local tbl = {
        guildInfo = {},
        gmSettings = {},
        blacklist = {},
        antispamList = {},
        isGuildMaster = ns.core.hasGM
    }

    for k, v in pairs(ns.guildInfo) do tbl.guildInfo[k] = v end
    for k, v in pairs(ns.gmSettings) do tbl.gmSettings[k] = v end
    for key, r in pairs(tbl.gmSettings.messageList or {}) do
        if not r.gmSync then tbl.gmSettings.messageList[key] = nil end
    end
    tbl.blacklist = ns.code:compressData(ns.tblBlackList or {}, false, true)
    tbl.antispamList = ns.code:compressData(ns.tblAntiSpamList or {}, false, true)

    local compressed = ns.code:compressData(tbl, true)
    if not compressed then
        ns.code:fOut(L['SYNC_COMPRESS_FAIL'], 'FF0000')
        return
    end

    myData = compressed
end

function sync:SendChunks(sender) -- Chunk and Send
    if not myData or type(myData) ~= 'string' then return end

    local chunkCount = 0
    local function SendChunkWithDelay(index, chunkSize, encodedData, recipient)
        local totalChunks = math.ceil(#encodedData / chunkSize)

        if index <= #encodedData then
            -- Add metadata (chunkIndex/totalChunks)
            chunkCount = chunkCount + 1
            local chunk = encodedData:sub(index, index + chunkSize - 1)
            local message = string.format("%d:%d:%s", chunkCount, totalChunks, chunk)

            -- Log chunk info and send it
            ns.code:dOut(string.format("Sending chunk %d of %d, size: %d", chunkCount, totalChunks, #chunk))
            C_ChatInfo.SendAddonMessage(GR.commPrefix, message, "WHISPER", recipient)
            
            -- Delay the sending of the next chunk
            C_Timer.After(0.2, function()
                SendChunkWithDelay(index + chunkSize, chunkSize, encodedData, recipient)
            end)
        end
    end
    SendChunkWithDelay(1, 250, myData, sender)
end
function sync:CheckVersion(message, sender)
    local dbVer = tonumber(GR.dbVersion)
    local grVer = type(GR.version) == 'string' and tonumber(GR.version:match('^%d+%.%d+%.(.*)')) or nil

    local _, dbVersion, grVersion = strsplit(';', message)
    local acVer = grVersion
    dbVersion = (dbVersion and dbVersion ~= '') and tonumber(dbVersion) or nil
    grVersion = (grVersion and grVersion ~= '') and tonumber(grVersion:match('^%d+%.%d+%.(.*)')) or nil

    if not dbVersion or not grVersion then
        ns.code:fOut(sender..' '..L['OUTDATED_VERSION'], 'FFBCD142')
        return false
    elseif dbVersion ~= dbVer then
        ns.code:fOut(sender..' '..L['OUTDATED_VERSION'], 'FFBCD142')
        if dbVersion < dbVer then
            ns.code:fOut(sender..' ('..acVer..') '..L['OLDER_VERSION']..' '..GR.versionOut, 'FFBCD142')
        elseif grVersion > grVer then
            ns.code:fOut(sender..' ('..acVer..') '..L['NEWER_VERSION']..' '..GR.versionOut, 'FFBCD142')
        end

        return false
    elseif grVersion > grVer then
        ns.code:fOut(sender..' ('..acVer..') '..' '..L['NEWER_VERSION']..' '..GR.versionOut, 'FFBCD142')
    end

    return true
end
function sync:ProcessChunks(message, sender)
    local index, total, data = message:match("^(%d+):(%d+):(.+)$")
    index, total = tonumber(index), tonumber(total)
    if not index or not total or not data then
        ns.code:dOut('Invalid Sync Data from '..sender)
        return
    end

    if clientData.clients[sender].chunks[index] then
        ns.code:dOut('Duplicate Sync Data from '..sender)
        return
    end

    clientData.clients[sender].chunkCount = clientData.clients[sender].chunkCount and clientData.clients[sender].chunkCount + 1 or 1
    clientData.clients[sender].chunks[index] = data

    ns.code:dOut('Received Chunk '..clientData.clients[sender].chunkCount..' of '..total..' from '..sender)
    if clientData.clients[sender].chunkCount == total then -- Server mode, make sure got all clients
        ns.code:dOut('All Chunks Received from '..sender)

        local assembled = table.concat(clientData.clients[sender].chunks)
        --[[for k,v in ipairs(clientData.clients[sender].chunks) do
            assembled = assembled and assembled..v or v
        end--]]
        local success, tbl = ns.code:decompressData(assembled, true)
        if not success then
            ns.code:fOut(sender..'\'s data was not reassembled.', 'FF0000')
            return
        end

        clientData.clients[sender].restored = tbl
        return true
    end
end
function sync:ImportData()
    local gmFound = false

    for _, v in pairs(clientData.clients or {}) do
        if not gmFound then
            local r = v.restored
            if v.restored then
                ns.guildInfo.lastSync = ns.guildInfo.lastSync or 0
                r.lastSync = r.guildInfo.lastSync or 0

                if r.isGuildMaster then
                    gmFound = r.isGuildMaster
                    ns.guildInfo.lastSync = time()
                    ns.guildInfo.wasGM = r.isGuildMaster
                    ns.gmSettings = r.gmSettings
                elseif r.wasGM and not ns.guildInfo.wasGM then
                    ns.guildInfo = r.guildInfo
                    ns.guildInfo.wasGM = r.wasGM
                    ns.guildInfo.lastSync = r.lastSync
                    ns.gmSettings = r.gmSettings
                elseif r.lastSync > 0 and r.lastSync > ns.guildInfo.lastSync then
                    ns.guildInfo = r.guildInfo
                    ns.guildInfo.wasGM = r.wasGM
                    ns.guildInfo.lastSync = r.lastSync
                    ns.gmSettings = r.gmSettings
                end
            end

            cBlacklist, cAntiSpamList = 0, 0
            local blSuccess, tblBL = ns.code:decompressData(r.blacklist, false, true)
            for key, rec in pairs(tblBL) do
                if not ns.tblBlackList[key] then
                    ns.tblBlackList[key] = rec
                    if rec.private then ns.tblBlackList[key].reason = 'private' end
                    cBlacklist = cBlacklist + 1
                end
            end
            local asSuccess, tblAS = ns.code:decompressData(r.blacklist, false, true)
            for key, rec in pairs(tblAS) do
                if not ns.tblAntiSpamList[key] then
                    ns.tblAntiSpamList[key] = rec
                    cAntiSpamList = cAntiSpamList + 1
                end
            end
        end
    end

    ns.code:saveTables()
end
sync:Init()
--? End of Data Functions

--* Public Functions
function gSync:StartSyncRoutine(typeOfSync, sender) sync:StartSync(typeOfSync, sender) end
--? End of Public Functions

--* Communication Routines
local function OnCommReceived(prefix, message, distribution, sender)
    if not ns.core.isEnabled then return
    elseif sender == UnitName('player') then return
    elseif prefix ~= GR.commPrefix then return
    elseif distribution ~= 'GUILD' and distribution ~= 'WHISPER' then return end

    if syncType == 1 or syncType == 2 then serverComms:OnCommReceived(message, sender)
    else clientComms:OnCommReceived(message, sender) end
end
GR:RegisterComm(GR.commPrefix, OnCommReceived)
--? End of Communication Routines