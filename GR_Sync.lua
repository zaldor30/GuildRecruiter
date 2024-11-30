local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.sync = {}
local sync = ns.sync

local REQUEST_WAIT_TIMEOUT, SERVER_SEND_DATA_WAIT = 2, 60
local SYNC_FAIL_TIMER, DATA_WAIT_TIMEOUT = 120, 60

local myData, clientData = nil, { clients = {}, count = 0, receivedCount = 0 }
local cBlacklist, cAntiSpamList = 0, 0
local server, serverComms, clientComms = {}, {}, {}
local isSyncing, syncMaster, syncType, syncPrefix = false, nil, nil, nil

local tblSync, syncTimer = {}, {}
function Init()
    -- Metatable Creation
    syncTimer = setmetatable({}, { __index = syncTimer, })
end

--* Begin Sync Routine
--* End of Begin Sync Routine