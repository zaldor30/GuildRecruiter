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
    db.devGuildRecruiterDB = nil -- Remove the old database
    ns.code:fOut(L['DATABASE_RESET'], ns.COLOR_ERROR)
end

function convert:Init()
    self.oldData = {}
end
function convert:ContinueConvert(whichOne)
    if whichOne == '3to4' then return
    end
end

--* Convert Database from 3 to 4
function convert:ConvertFrom3to4()
    local oldData = self.oldData

    local db = DB:New(GR.db)
    if db then db.global.dbVer = nil end
    if (db and db.global.dbVersion and type(db.global.dbVersion) == 'number') and db.global.dbVersion >= 4 then return false end

    ns.blacklist, ns.tblAntiSpamList = {}, {}
    for k, v in pairs(db.global) do
        if type(k) == 'number' then
            oldData[k] = v

            if v.antiSpamList then
                local success, tbl = ns.code:decompressData(v.antiSpamList)
                oldData[k].antiSpamList = ''
                if success and tbl then
                    for k1, v1 in pairs(tbl) do
                        local key = strlower(k1:match('-') and k1 or k1..'-'..GetRealmName())
                        ns.tblAntiSpamList[key] = {
                            time = v1.date,
                            name = v1.name,
                        }
                    end
                end
            end

            if v.blackList then
                local success, tbl = ns.code:decompressData(v.blackList)
                oldData[k].blackList = ''
                if success and tbl then
                    for k1, v1 in pairs(tbl) do
                        local key = strlower(k1:match('-') and k1 or k1..'-'..GetRealmName())
                        ns.blacklist[key] = v1
                    end
                end
            end
        end
    end

    resetDatabase(db)

    local gStruct = ns.core.guildFileStructure
    for k, v in pairs(oldData) do
        ns.guild = gStruct
        ns.guild.guildInfo = v.guildInfo or {}
        ns.guild.guildMessage = v.guildMessage or L['DEFAULT_GUILD_WELCOME']
        ns.guild.whisperMessage = v.whisperMessage or ''
        ns.guild.messageList = v.messageList or {}
        db.global[k] = ns.guild
        ns.guild = db.global[k]
        ns.code:saveTables()
    end
    db.global.dbVersion = 4

    return true, '3to4'
end
convert:Init()
