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

local tblSync = {}

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

    ns.g.syncList = ns.g.syncList or {}
    tblSync = ns.g.syncList

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
        GR:SendCommMessage(GR.commPrefix, 'SYNC_REQUEST:'..GR.dbVersion..':'..GR.version..':'..UnitGUID('player'), 'GUILD')
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
            GR:SendCommMessage(GR.commPrefix, 'SYNC_DATA_REQUEST:'..UnitGUID('player'), 'WHISPER', k)
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

            if not sync:CheckVersion(message, sender) then return end
            local _,_,_, GUID = strsplit(':', message)

            ns.code:dOut('Sync Request Heard from '..sender)
            if not sync:CheckVersion(message, sender) then return end
            if not clientData.clients[sender] or not clientData.clients[sender].chunks then
                clientData.clients[sender] = clientData.clients[sender] or {}
                clientData.clients[sender].chunks = {}
                clientData.clients[sender].restored = {}
            end

            clientData.clients[sender].GUID = (GUID and GUID ~= '') and GUID or clientData.clients[sender].GUID
            clientData.count = clientData.count and clientData.count + 1 or 1
            timer:add(sender..'_SYNC_REQUEST_TIME_OUT', SERVER_SEND_DATA_WAIT, function() sync:EndOfSync('IS_FAIL', sender..' '..L['FAILED_TO_RECEIVE_SYNC_DATA']) end)
        else
            if sync:ProcessChunks(message, sender) then
                clientData.receivedCount = clientData.receivedCount and clientData.receivedCount + 1 or 1
                if clientData.receivedCount ~= clientData.count then return end

                if sync:ImportData() then
                    local GUID = clientData.clients[sender].GUID or nil
                    if GUID then tblSync[GUID] = time() end
                    ns.g.syncList = tblSync
                end
                for k in pairs(clientData.clients) do
                    ns.code:dOut('Sending Data to '..k)

                    local GUID = clientData.clients[sender].GUID or nil
                    sync:SendChunks(k, GUID and tblSync[GUID] or 0)
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

        if message:match('SYNC_REQUEST:') then
            if isSyncing then return
            else sync:StartSync(3, sender) end

            ns.code:cOut(L['SYNC_REQUEST_RECEIVED']..' '..sender, GRColor)
            if not sync:CheckVersion(message, sender) then sync:EndOfSync() return end

            timer:add(sender..'_SYNC_REQUEST_TIME_OUT', DATA_WAIT_TIMEOUT, function() sync:EndOfSync('IS_FAIL', sender..' '..L['FAILED_TO_RECEIVE_SYNC_DATA']) end)
            GR:SendCommMessage(GR.commPrefix, 'SYNC_REQUEST_HEARD:'..GR.dbVersion..':'..GR.version..':'..UnitGUID('player'), 'WHISPER', sender)
        elseif message:match('SYNC_DATA_REQUEST') then
            timer:cancel(sender..'_SYNC_REQUEST_TIME_OUT')
            ns.code:dOut('Received Data Request from '..sender)

            local _, GUID = strsplit(':', message)
            clientData.clients[sender] = {}
            clientData.clients[sender].GUID = GUID
            sync:SendChunks(sender, GUID and tblSync[GUID] or 0)
            timer:add('DATA_WAIT_TIMEOUT', DATA_WAIT_TIMEOUT, function() sync:EndOfSync('IS_FAIL', L['FAILED_TO_SEND_SYNC_DATA']) end)
        else
            if not clientData.clients[sender] or not clientData.clients[sender].chunks then
                clientData.clients[sender] = clientData.clients[sender] or {}
                clientData.clients[sender].chunks = {}
                clientData.clients[sender].restored = {}
            end

            if sync:ProcessChunks(message, sender) then
                ns.code:dOut('Data Received from '..sender)
                if sync:ImportData() then
                    local GUID = clientData.clients[sender].GUID or nil
                    if GUID then tblSync[GUID] = time() end
                    ns.g.syncList = tblSync
                end
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
function sync:GatherMyData(lastSync)
    local tbl = {
        sender = UnitName('player'),
        guildInfo = {},
        gmSettings = {},
        blacklist = {},
        antispamList = {},
        isGuildMaster = ns.core.hasGM
    }

    tbl.gmSettings = ns.gmSettings
    for key, r in pairs(tbl.gmSettings and tbl.gmSettings.messageList or {}) do
        if not r.gmSync then tbl.gmSettings.messageList[key] = nil end
    end
    tbl.guildInfo = ns.code:compressData(ns.guildInfo or {}, false, true)
    tbl.gmSettings = ns.code:compressData(tbl.gmSettings or {}, false, true)

    lastSync = lastSync or 0
    local tblBL = {}
    for key, rec in pairs(ns.tblBlackList or {}) do
        if rec.date > lastSync then tblBL[key] = rec end
    end
    tbl.blacklist = ns.code:compressData(tblBL or {}, false, true)

    local tblAS = {}
    for key, rec in pairs(ns.tblAntiSpamList or {}) do
        if rec.date > lastSync then tblAS[key] = rec end
    end
    tbl.antispamList = ns.code:compressData(tblAS or {}, false, true)

    local compressed = ns.code:compressData(tbl, true)
    if not compressed then
        ns.code:fOut(L['SYNC_COMPRESS_FAIL'], 'FF0000')
        return
    end

    myData = compressed
end

function sync:SendChunks(sender, prevSync) -- Chunk and Send
    sync:GatherMyData(prevSync)
    if not myData then return end

    local chunks = {}
    local function GetChunks(encodedData, chunkSize)
        for i = 1, #encodedData, chunkSize do
            table.insert(chunks, encodedData:sub(i, i + chunkSize - 1))
        end
    end
    GetChunks(myData, 245)

    local chunkCount, totalChunks = 0, #chunks
    local function SendChunkWithDelay(recipient)
        local chunkOut = tremove(chunks, 1)
        chunkCount = chunkCount + 1
        chunkOut = chunkCount..':'..totalChunks..':'..chunkOut
        ns.code:dOut(string.format("Sending chunk %d of %d, size: %d", chunkCount, totalChunks, #chunkOut))
        C_ChatInfo.SendAddonMessage(GR.commPrefix, chunkOut, "WHISPER", recipient)

        -- Delay the sending of the next chunk
        if #chunks == 0 then return end
        C_Timer.After((chunkCount/20 == 0 and 2 or .3), function()
            SendChunkWithDelay(recipient)
        end)
    end
    SendChunkWithDelay(sender)
end
function sync:CheckVersion(message, sender)
    local dbVer = tonumber(GR.dbVersion)
    local grVer = type(GR.version) == 'string' and tonumber(GR.version:match('^%d+%.%d+%.(.*)')) or nil

    local _, dbVersion, grVersion, GUID = strsplit(':', message)
    local acVer = grVersion
    dbVersion = (dbVersion and dbVersion ~= '') and tonumber(dbVersion) or nil
    grVersion = (grVersion and grVersion ~= '') and tonumber(grVersion:match('^%d+%.%d+%.(.*)')) or nil

    if not dbVersion or not grVersion then
        ns.code:fOut(sender..' '..L['OUTDATED_VERSION'], 'FFBCD142')
        return false
    elseif dbVersion ~= dbVer then
        ns.code:fOut(sender..' '..L['OUTDATED_VERSION'], 'FFBCD142')
        if dbVersion < dbVer or (not GUID and grVersion < grVer) then
            ns.code:fOut(sender..' ('..acVer..') '..L['OLDER_VERSION']..' '..GR.versionOut, 'FFBCD142')
        elseif grVersion > grVer then
            ns.code:fOut(sender..' ('..acVer..') '..L['NEWER_VERSION']..' '..GR.versionOut, 'FFBCD142')
        end

        return false
    elseif grVersion > grVer then
        ns.code:fOut(sender..' ('..acVer..') '..' '..L['NEWER_VERSION']..' '..GR.versionOut, 'FFBCD142')
    end

    return GUID
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

    ns.code:dOut('Received Chunk '..clientData.clients[sender].chunkCount..' of '..total..' from '..sender..' Chunk Size: '..#data)
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

    for k, v in pairs(clientData.clients or {}) do
        local loadGM = false
        if not gmFound then
            local r = v.restored
            if v.restored then
                local giSuccess, tblGI = ns.code:decompressData(r.guildInfo, false, true)
                if not giSuccess then
                    ns.code:dOut('Failed to decompress Guild Info data from '..k, 'FF0000')
                    return
                end
                local gmSuccess, tblGM = ns.code:decompressData(r.gmSettings, false, true)
                if not gmSuccess then
                    ns.code:dOut('Failed to decompress GM Settings data from '..k, 'FF0000')
                    return
                end

                ns.guildInfo.lastSync = ns.guildInfo.lastSync or 0
                r.lastSync = r.guildInfo.lastSync or 0

                if not ns.core.hasGM then
                    if r.isGuildMaster then
                        gmFound = r.isGuildMaster
                        ns.guildInfo.lastSync = time()
                        ns.guildInfo.wasGM = tblGI.isGuildMaster
                        loadGM = true
                    elseif tblGI.wasGM and not ns.guildInfo.wasGM then
                        ns.guildInfo = tblGI.guildInfo
                        ns.guildInfo.wasGM = tblGI.wasGM
                        ns.guildInfo.lastSync = tblGI.lastSync
                        loadGM = true
                    elseif tblGI.lastSync > 0 and tblGI.lastSync > ns.guildInfo.lastSync then
                        ns.guildInfo = tblGI.guildInfo
                        ns.guildInfo.wasGM = tblGI.wasGM
                        ns.guildInfo.lastSync = tblGI.lastSync
                        loadGM = true
                    end
                end

                if loadGM then
                    for k1, v1 in pairs(tblGM or {}) do ns.gmSettings[k1] = v1 end end
            end

            cBlacklist, cAntiSpamList = 0, 0
            local blSuccess, tblBL = ns.code:decompressData(r.blacklist, false, true)
            if not blSuccess then
                ns.code:dOut('Failed to decompress Blacklist data from '..k, 'FF0000')
                return
            end
            for key, rec in pairs(tblBL) do
                if not ns.tblBlackList[key] then
                    ns.tblBlackList[key] = rec
                    if rec.private then ns.tblBlackList[key].reason = 'private' end
                    cBlacklist = cBlacklist + 1
                end
            end
            local asSuccess, tblAS = ns.code:decompressData(r.antispamList, false, true)
            if not asSuccess then
                ns.code:dOut('Failed to decompress Anti-Spam data from '..k, 'FF0000')
                return
            end
            for key, rec in pairs(tblAS) do
                if not ns.tblAntiSpamList[key] then
                    ns.tblAntiSpamList[key] = rec
                    cAntiSpamList = cAntiSpamList + 1
                end
            end
        end
    end

    ns.code:saveTables()
    return true
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