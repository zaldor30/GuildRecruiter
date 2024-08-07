local _, ns = ... -- Namespace (myaddon, namespace)

ns.ds = {}
local ds = ns.ds

function ds:Init()
    self.dbVersion = '3.0.1'
    self.tblRaces = self:races()
    self.tblClasses = self:classes()
    self.tblClassesByName = nil
    self.tblZones = self:invalidZones()
end
function ds:WhatsNew() -- What's new in the current version
    local height = 410 -- Adjust size of what's new window
    local title, msg = '', ''
    title = ns.code:cText('FFFFFF00', "What's new in v"..GR.version..(GR.isTest and ' ('..GR.testLevel..')' or '').."?")
    msg = [[
            |CFF55D0FF** Please report any bugs or issues in Discord **
                    Discord: https://discord.gg/ZtS6Q2sKRH
                (or click on the icon in the top left corner)|r
                
    |CFFFFFF00v3.0 Notes|r
        Alpha Fixes v3.0.6:
        - Fixed preview showing |c2
        - Fixed issue with lblPlayersScanned error.
        - Right Click Invite Menu:
            - Added option to send invite message.
            - Now checks if player is in the guild.

        I have done pretty much a full rewrite of Guild Recruiter.
        I have added a lot of new features and fixed a lot of bugs.

            ** CHANGES WERE MADE TO THE DATABASE. **
        ** PLEASE BACKUP YOUR SAVE FILES BEFORE UPDATING. **

        Features:
        - Minimap icon:
            - Added shift+click to directly open the scanner.
            - Added anti-spam and black list counts to the tooltip.
        - Invite Player Changes:
            - Analytics now tracks /ginvite.
            - Right Click Invite Menu:
                - Invite to guild now works.
                - Hides the option to black list if on the list.
                - Ask if you try to invite someone on the black list.
                - Send your invite message to a player.
        - Scanner Changes:
            - Whispers will now show when show whispers is enabled.
            - Invite list and Who will show after leaving the screen.
    ]]

    return title, msg, height
end
function ds:invalidZones() -- Invalid zones for recruitment
    local tbl = {
        --battlegrounds
        [30] = { id = 30, name = "Alterac Valley", reason = 'Battlegrounds' },
        [489] = { id = 489, name = "Warsong Gulch", reason = 'Battlegrounds' },
        [529] = { id = 529, name = "Arathi Basin (Classic)", reason = 'Battlegrounds' },
        [566] = { id = 566, name = "Eye of the Storm", reason = 'Battlegrounds' },
        [607] = { id = 607, name = "Strand of the Ancients", reason = 'Battlegrounds' },
        [628] = { id = 628, name = "Isle of Conquest", reason = 'Battlegrounds' },
        [726] = { id = 726, name = "Twin Peaks", reason = 'Battlegrounds' },
        [727] = { id = 727, name = "Silvershard Mines", reason = 'Battlegrounds' },
        [761] = { id = 761, name = "The Battle for Gilneas", reason = 'Battlegrounds' },
        [968] = { id = 968, name = "Eye of the Storm (Rated)", reason = 'Battlegrounds' },
        [998] = { id = 998, name = "Temple of Kotmogu", reason = 'Battlegrounds' },
        [1105] = { id = 1105, name = "Deepwind Gorge", reason = 'Battlegrounds' },
        [1681] = { id = 1681, name = "Arathi Basin (Winter)", reason = 'Battlegrounds' },
        [1803] = { id = 1803, name = "Seething Shore", reason = 'Battlegrounds' },
        [2107] = { id = 2107, name = "Arathi Basin", reason = 'Battlegrounds' },
        [2177] = { id = 2177, name = "Arathi Basin Comp Stomp", reason = 'Battlegrounds' },
        --arenas
        [572] = { id = 572, name = "Ruins of Lordaeron", reason = 'Arena' },
        [617] = { id = 617, name = "Dalaran Arena", reason = 'Arena' },
        [618] = { id = 618, name = "The Ring of Valor", reason = 'Arena' },
        [980] = { id = 980, name = "Tol'Viron Arena", reason = 'Arena' },
        [1134] = { id = 1134, name = "Tiger's Peak", reason = 'Arena' },
        [1505] = { id = 1505, name = "Nagrand Arena", reason = 'Arena' },
        [1672] = { id = 1672, name = "Blade's Edge Arena", reason = 'Arena' },
        [2167] = { id = 2167, name = "The Robodrome", reason = 'Arena' },

            --@version-retail@
        --raids
        [0] = { id = 0, name = "Amirdrassil, the Dream's Hope", reason = 'Season 3 Raid' },
        [2569] = {  id = 2569, name = "Aberrus, the Shadowed Crucible", reason = 'Season 2 Raid' },
        [2522] = { id = 2522, name = "Vault of the Incarnates", reason = 'Season 1 Raid' },
        --dungeons
        [2451] = { id = 2451, name = "Uldaman: Legacy of Tyr", reason = 'DF Dungeon' },
        [2515] = { id = 2515, name = "The Azure Vault", reason = 'DF Dungeon' },
        [2516] = { id = 2516, name = "The Nokhud Offensive", reason = 'DF Dungeon' },
        [2519] = { id = 2519, name = "Neltharus", reason = 'DF Dungeon' },
        [2520] = { id = 2520, name = "Brackenhide Hollow", reason = 'DF Dungeon' },
        [2521] = { id = 2521, name = "Ruby Life Pools", reason = 'DF Dungeon' },
        [2526] = { id = 2526, name = "Algeth'ar Academy", reason = 'DF Dungeon' },
        [2527] = { id = 2527, name = "Halls of Infusion", reason = 'DF Dungeon' },
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

        --* Delves
        [1] = { id = 1, name = 'Earthcrawl Mines', reason = 'Delves' },
        [2] = { id = 1, name = 'Fungal Folly', reason = 'Delves' },
        [3] = { id = 1, name = "Kriegval’s Rest", reason = 'Delves' },
        [4] = { id = 1, name = 'The Waterworks', reason = 'Delves' },
        [5] = { id = 1, name = 'The Dread Pit', reason = 'Delves' },
        [6] = { id = 1, name = 'Nightfall Sanctum', reason = 'Delves' },
        [7] = { id = 1, name = 'The Sinkhole', reason = 'Delves' },
        [8] = { id = 1, name = 'Skittering Breach', reason = 'Delves' },
        [9] = { id = 1, name = 'Mycomancer Cavern', reason = 'Delves' },
        [10] = { id = 1, name = 'The Spiral Weave', reason = 'Delves' },
        [11] = { id = 1, name = 'Tak-Rethan Abyss', reason = 'Delves' },
        [12] = { id = 1, name = 'Underkeep', reason = 'Delves' },
        [13] = { id = 1, name = "Zekvir’s Lair", reason = 'Delves' },
    }

    ns.global.zoneList = ns.global.zoneList or {}
    for k, r in pairs(ns.global.zoneList and ns.global.zoneList or {}) do tbl[k] = r end

    return tbl
end
function ds:convertZoneKeyToName()
    local tbl = {}
    for k, v in pairs(ns.tblInvalidZones) do
        tbl[v.name] = v
    end
    return tbl
end
function ds:classes() -- Class data
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
function ds:races() -- Race data
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