local _, ns = ... -- Namespace (myaddon, namespace)

ns.ds = {}
local ds = ns.ds

function ds:Init()
    self.dbVersion = '3.0.0'
    self.grVersion = '2.2.43'

    self.tblRaces = self:races()
    self.tblClasses = self:classes()
    self.tblClassesByName = nil
    self.tblBadZonesByName = self:invalidZones()
end
function ds:WhatsNew()
    self.dbVersion = '3.0.0'
    self.grVersion = '2.1.39'

    local update = false -- True and will save seen message
    local height = 410 -- Adjust size of what's new window
    local title, msg = '', ''
    title = ns.code:cText('FFFFFF00', "What's new in v"..GR.version.."?")
    msg = [[
         |CFF55D0FF** Please report any bugs or issues in Discord **
                Discord: https://discord.gg/ZtS6Q2sKRH
             (or click on the icon in the top left corner)|r

    |CFFFFFF00v2.2.43 Notes|r
        * Database maintenance.
            * Removed old unused variables.
            * Cleaned up where data is stored.
            * Moved more settings to guild wide versus character.
        * Fixed when GM has changed the current GM will be come
            invalidated in the addon.
        * Added instructions on how to get a guild link.
        * Lots of clean up and fixes to settings.
            * Made many settings guild wide so you do not have
                to change them on each character.
        * Some UI tweaks and improvements.
        * Rework to sync to make it more reliable.
        * Added saving of session data for later updates.
        * Added total counts for invited players and black list
            to analytics.
        * Scans will now resume from where you left off if you
            leave the scan screen and return.
        * Added reasons to unguilded players in /who results.
            * Only works when not in compact mode.
        * Moved custom filters and reworked to main icon bar.

    |CFFFFFF00v2.1.42 Notes|r
        * Increment for patch 10.2
        * Added total invited players and black listed players in
            analytics.
        * Fixed error with default race filter.

    |CFFFFFF00v2.1.40 Notes|r
        * Fixes for invited players and black list anti-spam.

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
        * Fixed issues with analytics not tracking black list and
            invited players.
        * Black listed players can be removed right away as long as
            a sync has not occurred.

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
-- Instance Zones that are Invalid
function ds:invalidZones()
    local tbl = {
        --battlegrounds
        ['Alterac Valley'] = { id = 30, name = "Alterac Valley", reason = 'Battlegrounds' },
        ["Warsong Gulch"] = { id = 489, name = "Warsong Gulch", reason = 'Battlegrounds' },
        ["Arathi Basin (Classic)"] = { id = 529, name = "Arathi Basin (Classic)", reason = 'Battlegrounds' },
        ["Eye of the Storm"] = { id = 566, name = "Eye of the Storm", reason = 'Battlegrounds' },
        ["Strand of the Ancients"] = { id = 607, name = "Strand of the Ancients", reason = 'Battlegrounds' },
        ["Isle of Conquest"] = { id = 628, name = "Isle of Conquest", reason = 'Battlegrounds' },
        ["Twin Peaks"] = { id = 726, name = "Twin Peaks", reason = 'Battlegrounds' },
        ["Silvershard Mines"] = { id = 727, name = "Silvershard Mines", reason = 'Battlegrounds' },
        ["The Battle for Gilneas"] = { id = 761, name = "The Battle for Gilneas", reason = 'Battlegrounds' },
        ["Eye of the Storm (Rated)"] = { id = 968, name = "Eye of the Storm (Rated)", reason = 'Battlegrounds' },
        ["Temple of Kotmogu"] = { id = 998, name = "Temple of Kotmogu", reason = 'Battlegrounds' },
        ["Deepwind Gorge"] = { id = 1105, name = "Deepwind Gorge", reason = 'Battlegrounds' },
        ["Arathi Basin (Winter)"] = { id = 1681, name = "Arathi Basin (Winter)", reason = 'Battlegrounds' },
        ["Seething Shore"] = { id = 1803, name = "Seething Shore", reason = 'Battlegrounds' },
        ["Arathi Basin"] = { id = 2107, name = "Arathi Basin", reason = 'Battlegrounds' },
        ["Arathi Basin Comp Stomp"] = { id = 2177, name = "Arathi Basin Comp Stomp", reason = 'Battlegrounds' },
        --arenas
        ["Ruins of Lordaeron"] = { id = 572, name = "Ruins of Lordaeron", reason = 'Arena' },
        ["Dalaran Arena"] = { id = 617, name = "Dalaran Arena", reason = 'Arena' },
        ["The Ring of Valor"] = { id = 618, name = "The Ring of Valor", reason = 'Arena' },
        ["Tol'Viron Arena"] = { id = 980, name = "Tol'Viron Arena", reason = 'Arena' },
        ["Tiger's Peak"] = { id = 1134, name = "Tiger's Peak", reason = 'Arena' },
        ["Nagrand Arena"] = { id = 1505, name = "Nagrand Arena", reason = 'Arena' },
        ["Blade's Edge Arena"] = { id = 1672, name = "Blade's Edge Arena", reason = 'Arena' },
        ["The Robodrome"] = { id = 2167, name = "The Robodrome", reason = 'Arena' },

            --@version-retail@
        --raids
        ["Amirdrassil, the Dream's Hope"] = { id = 0, name = "Amirdrassil, the Dream's Hope", reason = 'Season 3 Raid' },
        ["Aberrus, the Shadowed Crucible"] = {  id = 2569, name = "Aberrus, the Shadowed Crucible", reason = 'Season 2 Raid' },
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
        ["Freehold"] = { id = 1754, name = "Freehold", reason = 'Season 2 Dungeon' },
        ["The Underrot"] = { id = 1841, name = "The Underrot", reason = 'Season 2 Dungeon' },
        ["Neltharion's Lair"] = { id = 1458, name = "Neltharion's Lair", reason = 'Season 2 Dungeon' },
        ["The Vortex Pinnacle"] = { id = 657, name = "The Vortex Pinnacle", reason = 'Season 2 Dungeon' },
        ["Darkheart Thicket"] = { id = 1466, name = "Darkheart Thicket", reason = 'Season 3 Dungeon' },
        ['Black Rook Hold'] = { id = 1501, name = 'Black Rook Hold', reason = 'Season 3 Dungeon' },
        ['Waycrest Manor'] = { id = 1862, name = 'Waycrest Manor', reason = 'Season 3 Dungeon' },
        ["Atal'Dazar"] = { id = 1763, name = "Atal'Dazar", reason = 'Season 3 Dungeon' },
        ['The Everbloom'] = { id = 1279, name = 'The Everbloom', reason = 'Season 3 Dungeon' },
        ['Throne of Tides'] = { id = 643, name = 'Throne of Tides', reason = 'Season 3 Dungeon' },
        ["Dawn of the Infinite: Galakrond's Fall"] = { id = 0, name = "Dawn of the Infinite: Galakrond's Fall", reason = 'Season 3 Dungeon' },
        ["Dawn of the Infinite Murozond's Rise"] = { id = 0, name = "Dawn of the Infinite Murozond's Rise", reason = 'Season 3 Dungeon' },
    }

    return tbl
end
-- Class Table Routines
function ds:classes()
    local tbl = {}

    local icons = {
        ["DEMONHUNTER"] = 236415,
        ["DRUID"] = 625999,
        ["HUNTER"] = 626000,
        ["MAGE"] = 626001,
        ["MONK"] = 626002,
        ["PALADIN"] = 626003,
        ["PRIEST"] = 626004,
        ["ROGUE"] = 626005,
        ["SHAMAN"] = 626006,
        ["WARLOCK"] = 626007,
        ["WARRIOR"] = 626008,
        ["DEATHKNIGHT"] = 135771,
        ["EVOKER"] = 4567909,
    }

    for i=1, GetNumClasses() do
        local class, classFile, classID = GetClassInfo(i)
        tbl[classFile] = {
            id = classID,
            name = class,
            icon = icons[classFile],
            color = select(4, GetClassColor(classFile)),
            classFile = classFile,
        }
    end

    return tbl
end
function ds:classesByName()
    local tbl, sorted = {}, ns.code:sortTableByField(self.tblClasses, 'name')
    for _, r in pairs(sorted) do tbl[r.name] = r end

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
                    ['name'] = raceInfo.raceName,
                    ['fileName'] = raceInfo.clientFileString,
                }
            end
        end
        raceID = raceID + 1
    end

    return tbl
end
function ds:GetConnectedRealms()
    local tbl, isConnected = {}, false
    for _, r in pairs(GetAutoCompleteRealms() or {}) do
        isConnected = true
        tbl[r] = true
    end

    return isConnected and tbl or nil
end
ds:Init()

ns.tblRaces, ns.tblClasses, ns.tblBadZonesByName = ds.tblRaces, ds.tblClasses, ds.tblBadZonesByName