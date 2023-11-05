-- Pre-defined Datasets
local _, ns = ... -- Namespace (myaddon, namespace)

ns.ds, ns.tblBlackList, ns.tblInvited = {}, {}, {}
local ds = ns.ds

function ds:Init()
    self.tblRaces = ds:races() -- Only for player faction
    self.tblClasses = ds:classes()
    self.tblClassesByName = nil

    self.tblBadZones = ds:invalidZones()
    self.tblBadZonesByName = ds:invalidZonesByName()

    self.tblWhispers = {}
    self.tblConnected = ds:GetConnectedRealms()
end
ns.ds.dbVersion = '2.1.38'
ns.ds.GR_VERSION = '2.1.38' -- Show 'What's New' only if versions match
function ds:WhatsNew()
    local update = false -- True and will save seen message
    local height = 410 -- Adjust size of what's new window
    local title, msg = '', ''
    title = ns.code:cText('FFFFFF00', "What's new in v"..GRADDON.version.."?")
    msg = [[
         |CFF55D0FF** Please report any bugs or issues in Discord **
                Discord: https://discord.gg/ZtS6Q2sKRH
             (or click on the icon in the top left corner)|r

    |CFFFFFF00v2.1.39 Notes|r
        * Added compression to database for invited players and
            black list.
            |CFF55D0FFNote: This is to facilitate larger lists with less penealty
            to performance while logging in.|r
        * Changed anti-spam to base 7 days and up to 6 months.
            |CFF55D0FFNote: Go into settings to make sure it is correct.|r
        * Added anti-spam for when not forced by Guild Master.
        * Added keybindings for inviting and scanning
            (Found in settings, Invite Settings).
            |CFF55D0FFNote: This does not overwrite any existing
            keybindings in WoW.|r
        * Players in instances will not be invited or messaged (fixed).
        * Fixed issue with welcome message not using GM settings.
        * Fixed issues with analytics not tracking black list and invited players.
        * Black listed players can be removed right away as long as a sync has not occurred.

I have posted the updated beta for it.

    |CFFFFFF00v2.1.33 Notes|r
        * Brought back adding black list players to the icon bar.
        * Added the ability to send greeting/welcome message
            when inviting via the menu (right click on
            player name in chat).
        * Added message length to greeting message and
            restricted to 255 characters (1 message).
        * Restricting welcome message to 255 characters.

    |CFFFFFF00v2.1.33 Notes|r
        * Fixed invite issue with connected realms.
        * Fixed anti-spam issue with connected realms.
        * UI improvements and clean up.
        * Default message is guild wide on your account.
            Meaning, if you change it on one character, it will
            change on all.
        * Added option to disable the 'What's New' message.
        * Added skip if you don't want to invite a player right
            now, it will add them to the skip list.
        * Scans now remember where you left off if you close
            the addon and reopen (note: not if you log off
            or reload UI.)
        * Compact mode now remembers when you click on the icon.
        * Opened GM settings from any character on GM's account.
        * Added guild welcome message to the GM settings window.
        * Added auto sync on login (will begin 60 seconds
            after login).
        * Fixed issues with auto sync not transferring all data.

        -> Sync with older versions will time out.
        -> Everyone needs to be on the current version.
    ]]

    return title, msg, height, update
end
function ds:classes()
    local function GetLocalizedClassNames()
        local localizedClassNames = {}

        for classIndex = 1, GetNumClasses() do
            local className, classFileName, classID = GetClassInfo(classIndex)
            localizedClassNames[classID] = className
        end

        return localizedClassNames
    end

    local localizedClasses = GetLocalizedClassNames()

    return {
        ['WARRIOR'] = {
            id = 1, name = localizedClasses[1], classFile = 'WARRIOR',
            color = GRADDON.classInfo['WARRIOR'].color, icon = GRADDON.classInfo['WARRIOR'].icon,
            tank = true, healer = false, melee = true, ranged = false
        },
        ['PALADIN'] = {
            id = 2, name = localizedClasses[2], classFile = 'PALADIN',
            color = GRADDON.classInfo['PALADIN'].color, icon = GRADDON.classInfo['PALADIN'].icon,
            tank = true, healer = true, melee = true, ranged = false
        },
        ['HUNTER'] = {
            id = 3, name = localizedClasses[3], classFile = 'HUNTER',
            color = GRADDON.classInfo['HUNTER'].color, icon = GRADDON.classInfo['HUNTER'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['ROGUE'] = {
            id = 4, name = localizedClasses[4], classFile = 'ROGUE',
            color = GRADDON.classInfo['ROGUE'].color, icon = GRADDON.classInfo['ROGUE'].icon,
            tank = false, healer = false, melee = true, ranged = false
        },
        ['PRIEST'] = {
            id = 5, name = localizedClasses[5], classFile = 'PRIEST',
            color = GRADDON.classInfo['PRIEST'].color, icon = GRADDON.classInfo['PRIEST'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['DEATHKNIGHT'] = {
            id = 6, name = localizedClasses[6], classFile = 'DEATHKNIGHT',
            color = GRADDON.classInfo['DEATHKNIGHT'].color, icon = GRADDON.classInfo['DEATHKNIGHT'].icon,
            tank = true, healer = false, melee = true, ranged = false
        },
        ['SHAMAN'] = {
            id = 7, name = localizedClasses[7], classFile = 'SHAMAN',
            color = GRADDON.classInfo['SHAMAN'].color, icon = GRADDON.classInfo['SHAMAN'].icon,
            tank = false, healer = true, melee = true, ranged = true
        },
        ['MAGE'] = {
            id = 8, name = localizedClasses[8], classFile = 'MAGE',
            color = GRADDON.classInfo['MAGE'].color, icon = GRADDON.classInfo['MAGE'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['WARLOCK'] = {
            id = 9, name = localizedClasses[9], classFile = 'WARLOCK',
            color = GRADDON.classInfo['WARLOCK'].color, icon = GRADDON.classInfo['WARLOCK'].icon,
            tank = false, healer = false, melee = false, ranged = true
        },
        ['MONK'] = {
            id = 10, name = localizedClasses[10], classFile = 'MONK',
            color = GRADDON.classInfo['MONK'].color, icon = GRADDON.classInfo['MONK'].icon,
            tank = true, healer = true, melee = true, ranged = false
        },
        ['DRUID'] = {
            id = 11, name = localizedClasses[11], classFile = 'DRUID',
            color = GRADDON.classInfo['DRUID'].color, icon = GRADDON.classInfo['DRUID'].icon,
            tank = true, healer = true, melee = true, ranged = true
        },
        ['DEMONHUNTER'] = {
            id = 12, name = localizedClasses[12], classFile = 'DEMONHUNTER',
            color = GRADDON.classInfo['DEMONHUNTER'].color, icon = GRADDON.classInfo['DEMONHUNTER'].icon,
            tank = true, healer = false, melee = true, ranged = false },
        ['EVOKER'] = {
            id = 13, name = localizedClasses[13], classFile = 'EVOKER',
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
            className = r.name,
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
        [30] = { name = "Alterac Valley", reason = 'Battlegrounds' },
        [489] = { name = "Warsong Gulch", reason = 'Battlegrounds' },
        [529] = { name = "Arathi Basin (Classic)", reason = 'Battlegrounds' },
        [566] = { name = "Eye of the Storm", reason = 'Battlegrounds' },
        [607] = { name = "Strand of the Ancients", reason = 'Battlegrounds' },
        [628] = { name = "Isle of Conquest", reason = 'Battlegrounds' },
        [726] = { name = "Twin Peaks", reason = 'Battlegrounds' },
        [727] = { name = "Silvershard Mines", reason = 'Battlegrounds' },
        [761] = { name = "The Battle for Gilneas", reason = 'Battlegrounds' },
        [968] = { name = "Eye of the Storm (Rated)", reason = 'Battlegrounds' },
        [998] = { name = "Temple of Kotmogu", reason = 'Battlegrounds' },
        [1105] = { name = "Deepwind Gorge", reason = 'Battlegrounds' },
        [1681] = { name = "Arathi Basin (Winter)", reason = 'Battlegrounds' },
        [1803] = { name = "Seething Shore", reason = 'Battlegrounds' },
        [2107] = { name = "Arathi Basin", reason = 'Battlegrounds' },
        [2177] = { name = "Arathi Basin Comp Stomp", reason = 'Battlegrounds' },
        --arenas
        [572] = { name = "Ruins of Lordaeron", reason = 'Arena' },
        [617] = { name = "Dalaran Arena", reason = 'Arena' },
        [618] = { name = "The Ring of Valor", reason = 'Arena' },
        [980] = { name = "Tol'Viron Arena", reason = 'Arena' },
        [1134] = { name = "Tiger's Peak", reason = 'Arena' },
        [1505] = { name = "Nagrand Arena", reason = 'Arena' },
        [1672] = { name = "Blade's Edge Arena", reason = 'Arena' },
        [2167] = { name = "The Robodrome", reason = 'Arena' },

            --@version-retail@
        --raids
        [11111] = { name = "Amirdrassil, the Dream's Hope", reason = 'Season 3 Raid' },
        [2569] = { name = "Aberrus, the Shadowed Crucible", reason = 'Season 2 Raid' },
        --[2522] = { name = "Vault of the Incarnates", reason = 'Season 1 Raid' },
        --dungeons
        --[2451] = { name = "Uldaman: Legacy of Tyr", reason = 'DF Dungeon' },
        --[2515] = { name = "The Azure Vault", reason = 'DF Dungeon' },
        --[2516] = { name = "The Nokhud Offensive", reason = 'DF Dungeon' },
        --[2519] = { name = "Neltharus", reason = 'DF Dungeon' },
        --[2520] = { name = "Brackenhide Hollow", reason = 'DF Dungeon' },
        --[2521] = { name = "Ruby Life Pools", reason = 'DF Dungeon' },
        --[2526] = { name = "Algeth'ar Academy", reason = 'DF Dungeon' },
        --[2527] = { name = "Halls of Infusion", reason = 'DF Dungeon' },
            --M+ rotating
        [1754] = { name = "Freehold", reason = 'Season 2 Dungeon' },
        [1841] = { name = "The Underrot", reason = 'Season 2 Dungeon' },
        [1458] = { name = "Neltharion's Lair", reason = 'Season 2 Dungeon' },
        [657] = { name = "The Vortex Pinnacle", reason = 'Season 2 Dungeon' },
        [1466] = { name = "Darkheart Thicket", reason = 'Season 3 Dungeon' },
        [1501] = { name = 'Black Rook Hold', reason = 'Season 3 Dungeon' },
        [1862] = { name = 'Waycrest Manor', reason = 'Season 3 Dungeon' },
        [1763] = { name = "Atal'Dazar", reason = 'Season 3 Dungeon' },
        [1279] = { name = 'The Everbloom', reason = 'Season 3 Dungeon' },
        [643] = { name = 'Throne of Tides', reason = 'Season 3 Dungeon' },
        [22222] = { name = "Dawn of the Infinite: Galakrond's Fall", reason = 'Season 3 Dungeon' },
        [33333] = { name = "Dawn of the Infinite Murozond's Rise", reason = 'Season 3 Dungeon' },
    }

    return tbl
end
function ds:invalidZonesByName()
    local tbl = ds:invalidZones()
    local tblOut = {}
    for k, r in pairs(tbl) do
        local name = r.name:gsub("%b()", ""):trim()
        if not tblOut[strlower(name)] then
            tblOut[strlower(name)] = { id = k, name = name, reason = r.reason } end
    end

    return tblOut
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