local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local AceTimer = LibStub("AceTimer-3.0")

ns.sync = {}
local sync, gSync = {}, ns.sync

local COMM_PREFIX = GR.commPrefix
local REQUEST_WAIT_TIMEOUT = 5
local SYNC_FAIL_TIMER, DATA_WAIT_TIMEOUT = 120, 60

local tMyData, tChunks = {}, {}


function sync:Init()
end
function sync:StartSyncRoutine(syncType, sender)
    sync:GatherMyData()
end

function sync:GatherMyData()
    local tbl = {}

    local guildInfo = {}
    for k, v in pairs(ns.guildInfo) do guildInfo[k] = v end
    local gmSettings = {}
    for k, v in pairs(ns.gmSettings) do gmSettings[k] = v end
    local blacklist = {}
    for k, v in pairs(ns.blacklist or {}) do blacklist[k] = v end
    local antispamList = {}
    for k, v in pairs(ns.antispamList or {}) do antispamList[k] = v end

    tbl.isGuildMaster = ns.core.hasGM
    tbl.guildInfo = guildInfo
    tbl.gmSettings = gmSettings
    tbl.blacklist = blacklist
    tbl.antispamList = antispamList

    local compressed = ns.code:compressData(tbl, true)
    local success, decompressed = ns.code:decompressData(compressed, true)
    print(success, decompressed)
    print('Compressed:', tostring(#compressed), 'Decompressed:', tostring(#decompressed))
end
sync:Init()

function gSync:StartSyncRoutine(syncType, sender) sync:StartSyncRoutine(syncType, sender) end