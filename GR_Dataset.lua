local _, ns = ... -- Namespace (myaddon, namespace)

ns.ds = {}
local ds = ns.ds

function ds:Init()
    self.dbVersion = '3.0.0'
    self.grVersion = '2.2.53'

    self.tblRaces = self:races()
    self.tblClasses = self:classes()
    self.tblClassesByName = nil
    self.tblBadZonesByName = self:invalidZones()
end
function ds:WhatsNew()
    local update = false -- True and will save seen message
    local height = 410 -- Adjust size of what's new window
    local title, msg = '', ''
    title = ns.code:cText('FFFFFF00', "What's new in v"..GR.version.."?")
    msg = [[
         |CFF55D0FF** Please report any bugs or issues in Discord **
                Discord: https://discord.gg/ZtS6Q2sKRH
             (or click on the icon in the top left corner)|r

    |CFFFFFF00v2.2.53 Notes|r
        * Removed server restrictions
        * Fixed issue with options not opening up
        * Added a delay to sending messages after player joins guild

    |CFFFFFF00v2.2.52 Notes|r
        * Forgot to enable old dungeons and raids when inviting players.
    |CFFFFFF00v2.2.51 Notes|r
        * Fix issue give nil error when filter is finished and will now restart.
    |CFFFFFF00v2.2.50 Notes|r
        * Fix issue give nil error when trying to skip/black list a player.
        * Fix issue with min/max level not working properly.
    |CFFFFFF00v2.2.49 Notes|r
        Sorry all, have been taking a break from WoW and my computer for a bit.  I am back
        and if you have an issue, please let me know in Discord or on CurseForge (quciker
        response in Discord).  I will be working on the addon again and getting the filter
        working soon, been kicking my butt.

        * Bump in World of Warcraft versioning for 10.2.7
        * Fixed an issue where Start Search would not work.
        If you were having an issue clicking on players, let me know if still an issue.

    |CFFFFFF00v2.2.48 Notes|r
        * Bump in World of Warcraft version.
    |CFFFFFF00v2.2.47 Notes|r
        * Fixed an specifying levels and then having to /rl before it would work.
        * Fixed issue with sending a welcome/greeting message when inviting from chat.
        * Fixed type in settings (HIDE minimap icon, should be SHOW minimap icon).
    |CFFFFFF00v2.2.45 Notes|r
        * Fixed an issue with not being able to create/edit non-GM messages.

    |CFFFFFF00v2.2.44 Notes|r
        * Fixed an issue on single server realms, checking names would cause LUA error.
        
    |CFFFFFF00v2.2.43 Notes|r
        * |CFF00FF00NOTE: Cusom filters are not working at this time.
            I am working on a fix.|r
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
        * Updated ACE3 libraries.
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
        ["Vault of the Incarnates"] = { id = 2522, name = "Vault of the Incarnates", reason = 'Season 1 Raid' },
        --dungeons
        [2451] = { name = "Uldaman: Legacy of Tyr", reason = 'DF Dungeon' },
        [2515] = { name = "The Azure Vault", reason = 'DF Dungeon' },
        [2516] = { name = "The Nokhud Offensive", reason = 'DF Dungeon' },
        [2519] = { name = "Neltharus", reason = 'DF Dungeon' },
        [2520] = { name = "Brackenhide Hollow", reason = 'DF Dungeon' },
        [2521] = { name = "Ruby Life Pools", reason = 'DF Dungeon' },
        [2526] = { name = "Algeth'ar Academy", reason = 'DF Dungeon' },
        [2527] = { name = "Halls of Infusion", reason = 'DF Dungeon' },
            --M+ rotating
        --["Freehold"] = { id = 1754, name = "Freehold", reason = 'Season 2 Dungeon' },
        --["The Underrot"] = { id = 1841, name = "The Underrot", reason = 'Season 2 Dungeon' },
        --["Neltharion's Lair"] = { id = 1458, name = "Neltharion's Lair", reason = 'Season 2 Dungeon' },
        --["The Vortex Pinnacle"] = { id = 657, name = "The Vortex Pinnacle", reason = 'Season 2 Dungeon' },
        --["Darkheart Thicket"] = { id = 1466, name = "Darkheart Thicket", reason = 'Season 3 Dungeon' },
        --['Black Rook Hold'] = { id = 1501, name = 'Black Rook Hold', reason = 'Season 3 Dungeon' },
        --['Waycrest Manor'] = { id = 1862, name = 'Waycrest Manor', reason = 'Season 3 Dungeon' },
        --["Atal'Dazar"] = { id = 1763, name = "Atal'Dazar", reason = 'Season 3 Dungeon' },
        --['The Everbloom'] = { id = 1279, name = 'The Everbloom', reason = 'Season 3 Dungeon' },
        --['Throne of Tides'] = { id = 643, name = 'Throne of Tides', reason = 'Season 3 Dungeon' },
        --["Dawn of the Infinite: Galakrond's Fall"] = { id = 0, name = "Dawn of the Infinite: Galakrond's Fall", reason = 'Season 3 Dungeon' },
        --["Dawn of the Infinite Murozond's Rise"] = { id = 0, name = "Dawn of the Infinite Murozond's Rise", reason = 'Season 3 Dungeon' },
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
            classFile = strupper(classFile),
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
                    ['name'] = raceInfo.raceName,
                    ['raceFile'] = strupper(raceInfo.clientFileString),
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