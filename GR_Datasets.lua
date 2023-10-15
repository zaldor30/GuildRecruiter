-- Pre-defined Datasets
local _, ns = ... -- Namespace (myaddon, namespace)

ns.ds = {}
local ds = ns.ds

ns.ds.GR_VERSION = '2.1.33' -- Show 'What's New' only if versions match
function ds:Init()
    self.tblBadZones = ds:invalidZones()
    self.tblBadZonesByName = nil
    self.tblRaces = ds:races() -- Only for player faction
    self.tblClasses = ds:classes()
    self.tblClassesByName = nil

    self.tblWhispers = {}
    self.tblConnected = ds:GetConnectedRealms()
end
function ds:WhatsNew()
    local update = false -- True and will save seen message
    local height = 410 -- Adjust size of what's new window
    local title, msg = '', ''
    title = ns.code:cText('FFFFFF00', "What's new in v"..GRADDON.version.."?")
    msg = [[
        * Fixed invite issue with connected realms (Need feedback).
        * Fixed anti-spam issue with connected realms.
        * UI improvements and clean up.
        * Default message is guild wide on your account.
            Meaning, if you change it on one character, it will change on all.
        * Added option to disable the 'What's New' message.
        * Added skip if you don't want to invite a player right now,
            it will add them to the skip list.
        * Scans now remember where you left off if you close
            the addon and reopen (note: not if you log off or reload UI.)
        * Compact mode now remembers when you click on the icon.
        * Opened GM settings from any character on GM's account.
        * Added guild welcome message to the GM settings window.
        * Added auto sync on login (will begin 60 seconds after login).
        * Fixed issues with auto sync not transferring all data.

        -> Sync with older versions will time out.
        -> Everyone needs to be on the current version.

        ** Please report any bugs or issues on CurseForge or Discord **
    ]]

    return title, msg, height, update
end
function ds:classes()
    return {
        ['WARRIOR'] = {
            id = 1, name = 'Warrior', classFile = 'WARRIOR',
            color = GRADDON.classInfo['WARRIOR'].color, icon = GRADDON.classInfo['WARRIOR'].icon,
            tank = true, healer = false, melee = true, ranged = false
        },
        ['PALADIN'] = {
            id = 2, name = 'Paladin', classFile = 'PALADIN',
            color = GRADDON.classInfo['PALADIN'].color, icon = GRADDON.classInfo['PALADIN'].icon,
            tank = true, healer = true, melee = true, ranged = false
        },
        ['HUNTER'] = {
            id = 3, name = 'Hunter', classFile = 'HUNTER',
            color = GRADDON.classInfo['HUNTER'].color, icon = GRADDON.classInfo['HUNTER'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['ROGUE'] = {
            id = 4, name = 'Rogue', classFile = 'ROGUE',
            color = GRADDON.classInfo['ROGUE'].color, icon = GRADDON.classInfo['ROGUE'].icon,
            tank = false, healer = false, melee = true, ranged = false
        },
        ['PRIEST'] = {
            id = 5, name = 'Priest', classFile = 'PRIEST',
            color = GRADDON.classInfo['PRIEST'].color, icon = GRADDON.classInfo['PRIEST'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['DEATHKNIGHT'] = {
            id = 6, name = 'Death Knight', classFile = 'DEATHKNIGHT',
            color = GRADDON.classInfo['DEATHKNIGHT'].color, icon = GRADDON.classInfo['DEATHKNIGHT'].icon,
            tank = true, healer = false, melee = true, ranged = false
        },
        ['SHAMAN'] = {
            id = 7, name = 'Shaman', classFile = 'SHAMAN',
            color = GRADDON.classInfo['SHAMAN'].color, icon = GRADDON.classInfo['SHAMAN'].icon,
            tank = false, healer = true, melee = true, ranged = true
        },
        ['MAGE'] = {
            id = 8, name = 'Mage', classFile = 'MAGE',
            color = GRADDON.classInfo['MAGE'].color, icon = GRADDON.classInfo['MAGE'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['WARLOCK'] = {
            id = 9, name = 'Warlock', classFile = 'WARLOCK',
            color = GRADDON.classInfo['WARLOCK'].color, icon = GRADDON.classInfo['WARLOCK'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['MONK'] = {
            id = 10, name = 'Monk', classFile = 'MONK',
            color = GRADDON.classInfo['MONK'].color, icon = GRADDON.classInfo['MONK'].icon,
            tank = true, healer = true, melee = true, ranged = false
        },
        ['DRUID'] = {
            id = 11, name = 'Druid', classFile = 'DRUID',
            color = GRADDON.classInfo['DRUID'].color, icon = GRADDON.classInfo['DRUID'].icon,
            tank = true, healer = true, melee = true, ranged = true
        },
        ['DEMONHUNTER'] = {
            id = 12, name = 'Demon Hunter', classFile = 'DEMONHUNTER',
            color = GRADDON.classInfo['DEMONHUNTER'].color, icon = GRADDON.classInfo['DEMONHUNTER'].icon,
            tank = true, healer = false, melee = true, ranged = false },
        ['EVOKER'] = {
            id = 13, name = 'Evoker', classFile = 'EVOKER',
            color = GRADDON.classInfo['EVOKER'].color, icon = GRADDON.classInfo['EVOKER'].icon,
            tank = false, healer = true, melee = false, ranged = true
        },
    }
end
function ds:classesByName()
    local tbl, tblClasses = {}, {}
	tblClasses = ns.code:sortTableByField(self.tblClasses, 'classFile')
    for k, r in pairs(tblClasses) do
        tbl[r.key] = {
            classID = r.id,
            class = r.key,
            classFile = r.classFile,
        }
    end

	return tbl
end
function ds:races()
    local tbl, raceID, faction = {}, 1, UnitFactionGroup('player')
    while C_CreatureInfo.GetRaceInfo(raceID) do
        local raceFactions = {
            [1] = "Alliance",    -- Human
            [2] = "Horde",       -- Orc
            [3] = "Alliance",    -- Dwarf
            [4] = "Alliance",    -- Night Elf
            [5] = "Horde",       -- Undead
            [6] = "Horde",       -- Tauren
            [7] = "Alliance",    -- Gnome
            [8] = "Horde",       -- Troll
            [9] = "Hode",        -- Goblin
            [10] = "Horde",      -- Blood Elf
            [11] = "Alliance",   -- Draenei
            [22] = "Alliance",   -- Worgen
            [25] = "Horde",      -- Horde Pandaren
            [26] = "Alliance",   -- Alliance Pandaren
            [27] = "Horde",      -- Nightborne
            [28] = "Horde",      -- Highmountain Tauren
            [29] = "Alliance",   -- Void Elf
            [30] = "Alliance",   -- Lightforged Draenei
            [31] = "Horde",      -- Zandalari Troll
            [32] = "Horde",      -- Kul Tiran
            [34] = "Alliance",   -- Dark Iron Dwarf
            [36] = "Horde",      -- Mag'har Orc
            [37] = "Alliance",   -- Mechagnome
        }

        if raceFactions[raceID] == faction or raceFactions[raceID] == 'Neutral' then
            local raceInfo = C_CreatureInfo.GetRaceInfo(raceID)
            if raceInfo then
                tbl[raceInfo.raceName] = {
                    ['id'] = raceInfo.raceID,
                    ['fileName'] = raceInfo.clientFileString,
                }
            end
        end
        raceID = raceID + 1
    end

    return tbl
end
function ds:invalidZones()
    local tbl = {
        --battlegrounds
        [30] = "Alterac Valley",
        [489] = "Warsong Gulch",
        [529] = "Arathi Basin (Classic)",
        [566] = "Eye of the Storm",
        [607] = "Strand of the Ancients",
        [628] = "Isle of Conquest",
        [726] = "Twin Peaks",
        [727] = "Silvershard Mines",
        [761] = "The Battle for Gilneas",
        [968] = "Eye of the Storm (Rated)",
        [998] = "Temple of Kotmogu",
        [1105] = "Deepwind Gorge",
        [1681] = "Arathi Basin (Winter)",
        [1803] = "Seething Shore",
        [2107] = "Arathi Basin",
        [2177] = "Arathi Basin Comp Stomp",
        --arenas
        [572] = "Ruins of Lordaeron",
        [617] = "Dalaran Arena",
        [618] = "The Ring of Valor",
        [980] = "Tol'Viron Arena",
        [1134] = "Tiger's Peak",
        [1505] = "Nagrand Arena",
        [1672] = "Blade's Edge Arena",
        [2167] = "The Robodrome",

            --@version-retail@
        --raids
        [2522] = "Vault of the Incarnates",
        [2569] = "Aberrus, the Shadowed Crucible",
        --dungeons
        [2451] = "Uldaman: Legacy of Tyr",
        [2515] = "The Azure Vault",
        [2516] = "The Nokhud Offensive",
        [2519] = "Neltharus",
        [2520] = "Brackenhide Hollow",
        [2521] = "Ruby Life Pools",
        [2526] = "Algeth'ar Academy",
        [2527] = "Halls of Infusion",
            --M+ rotating
        [1754] = "Freehold",
        [1841] = "The Underrot",
        [1458] = "Neltharion's Lair",
        [657] = "The Vortex Pinnacle",
    }

    return tbl
end
function ds:invalidZonesByName()
    self.tblBadZonesByName = {}
    for k, r in pairs(self.tblBadZones) do
        self.tblBadZonesByName[r] = k
    end
end
function ds:WhisperMessages(performCheck)
    ns.db.messages = ns.db.messages or {}
    ns.dbGlobal.guildInfo = ns.dbGlobal.guildInfo or {}

    ns.db.messages.messageList = ns.db.messages.messageList or {}
    ns.dbGlobal.guildInfo.messageList = ns.dbGlobal.guildInfo.messageList or {}

    local dbMessages = ns.db.messages.messageList or {}
    local dbGMessages = ns.dbGlobal.guildInfo.messageList or {}

    -- GM messages then personal
    local tbl = {}
    for _,r in pairs(dbGMessages) do
        r.gmMessage = true
        tbl[#tbl+1] = { desc = r.desc, gmMessage = r.gmMessage, message = r.message }
    end
    for _,r in pairs(dbMessages or {}) do
        tbl[#tbl+1] = { desc = r.desc, gmMessage = r.gmMessage, message = r.message }
    end

    if performCheck then
        local hasGuildLink = (ns.dbGlobal.guildData and ns.dbGlobal.guildData.guildLink) or false
        for k, r in pairs(tbl) do
            if not hasGuildLink and strupper(r.message):match('GUILDLINK') then tbl[k] = nil end
        end
    end

    return tbl
end
function ds:GetConnectedRealms()
    local tbl = {}
    for _, r in pairs(GetAutoCompleteRealms() or {}) do tbl[r] = true end

    return tbl
end
ds:Init()