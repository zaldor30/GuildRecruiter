local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local AceTimer = LibStub("AceTimer-3.0")

ns.sync = {}
local sync = ns.sync

local COMM_PREFIX = 'GuildRecruiter'
local REQUEST_TIMEOUT = 5
local DATA_WAIT_TIMEOUT, SYNC_FAIL_TIMER = 120, 240

--* Table Setup
local function comTables()
    local tblFunction = {}
    function tblFunction:new()
        return {
            -- Guild Data
            isGM = false,
            guildLink = nil,

        }
    end

    return tblFunction
end