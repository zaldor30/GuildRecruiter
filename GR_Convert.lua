local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local DB = LibStub('AceDB-3.0')

ns.convert = {}
local convert = ns.convert

local function resetDatabase(db)
    db.global = db.global and table.wipe(db.global) or {} -- Reset the global database
    db:ResetProfile() -- Reset current profile

    -- Optionally, delete all other profiles by iterating through them
    for profileName in pairs(db.profiles) do
        db.profiles[profileName] = nil  -- Delete profile data
    end

    db.global.dbVer = GR.dbVersion -- Set the database version
    ns.code:fOut(L['DATABASE_RESET'], ns.COLOR_ERROR)
end

function convert:Init()
    self.oldData = {}
end
function convert:ContinueConvert(whichOne)
    if whichOne == '3to4' then
        return self:Continue3to4()
    end
end

--* Convert Database from 3 to 4
function convert:ConvertFrom3to4()
    local oldData = self.oldData
    local data = ns.data

    local db = DB:New(GR.db)
    if not db or not db.global.dbVersion or type(db.global.dbVersion) == 'number' then return false end

    for k, v in pairs(db.global) do
        if type(k) == 'number' then oldData[k] = v end
    end

    resetDatabase(db)

    return true, '3to4'
end
function convert:Continue3to4()
    local oldData = self.oldData
    local gStruct = ns.core.guildFileStructure

    for k,v in pairs(oldData) do print(k,v) end

    for k, v in pairs(oldData) do
        ns.g[k] = gStruct
        ns.g[k].guildInfo = v.guildInfo
        ns.g[k].guildMessage = v.guildMessage
        ns.g[k].whisperMessage = v.whisperMessage
        ns.g[k].messageList = v.messageList

        if v.antiSpamList then ns.g[k].antiSpamList = v.antiSpamList end
        if v.blacklist then ns.g[k].blacklist = v.blacklist end
    end
end
convert:Init()