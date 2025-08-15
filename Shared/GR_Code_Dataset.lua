local _, ns = ... -- Namespace (myaddon, namespace)

ns.ds = {}
local ds = ns.ds

-- List of common PvP zones
local pvpMapIDs = {
    92,    -- Warsong Gulch
    93,    -- Arathi Basin
    1459,  -- Alterac Valley
    112,   -- Eye of the Storm
    169,   -- Strand of the Ancients
    169,   -- Isle of Conquest
    206,   -- Twin Peaks
    275,   -- Battle for Gilneas
    417,   -- Silvershard Mines
    423,   -- Temple of Kotmogu
    519,   -- Deepwind Gorge
    907,   -- Seething Shore
    123,   -- Wintergrasp
    244,   -- Tol Barad
    978,   -- Ashran
    559,   -- Nagrand Arena
    562,   -- Blade's Edge Arena
    617,   -- Dalaran Sewers
    572,   -- Ruins of Lordaeron
    1134,  -- The Tiger's Peak
    1504,  -- Mugambala
    1505,  -- Hook Point
}

function ds:Init()
    self.dbVersion = GR.dbVersion -- From GR_Init
end
function ds:WhatsNew() -- What's new in the current version
    local height = 410 -- Adjust size of what's new window
    local title, msg = '', ''
    title = ns.code:cText('FFFFFF00', "What's new in v"..GR.versionOut.."?")
    msg = [[
            |CFF55D0FF** Please report any bugs or issues in Discord **
                    Discord: https://discord.gg/ZtS6Q2sKRH
                (or click on the icon in the top left corner)|r
    
        |CFFFFFF00v4.1.36 Notes|r
        - Fixed save issue when update min/max levels.
        - Added notification to refresh filter when
            changing min/max levels or filters.
        |CFFFFFF00v4.1.35 Notes|r
        - WoW Version Updated
        - Better input of player levels
        - Updated invite type checking
        - Updated how the addon gets invite
            status from Blizzard
        - Addressed issue with not sending welcome whispers

        |CFFFFFF00v4.0.00 Notes|r
            - Initial release of Guild Recruiter v4.0
    ]]
end
function ds:races_retail() -- Race data
    local tbl, raceID = {}, 1
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
            [32] = "Alliance",      -- Kul Tiran
            [34] = "Alliance",   -- Dark Iron Dwarf
            [36] = "Horde",      -- Mag'har Orc
            [37] = "Alliance",   -- Mechagnome
        }

        local myFaction = UnitFactionGroup('player')
        local raceInfo = C_CreatureInfo.GetRaceInfo(raceID)
        if raceInfo then
            if raceFactions[raceInfo.raceID] == myFaction then
                tbl[raceInfo.raceName] = {
                    ['id'] = raceInfo.raceID,
                    ['name'] = raceInfo.raceName,
                    ['faction'] = raceFactions[raceInfo.raceID],
                    ['raceFile'] = strupper(raceInfo.clientFileString),
                }
            end
        end
        raceID = raceID + 1
    end

    return tbl
end
function ds:races_classic() -- Race data
    local tbl = {}
    local tblRaces = {
        ['HUMAN'] = { id = 1, faction = 'Alliance', name = 'Human', raceFile = 'HUMAN' },
        ['ORC'] = { id = 2, faction = 'Horde', name = 'Orc', raceFile = 'ORC' },
        ['Dwarf'] = { id = 3, faction = 'Alliance', name = 'Dwarf', raceFile = 'DWARF' },
        ['NIGHTELF'] = { id = 4, faction = 'Alliance', name = 'Night Elf', raceFile = 'NIGHTELF' },
        ['UNDEAD'] = { id = 5, faction = 'Horde', name = 'Undead', raceFile = 'UNDEAD' },
        ['TAUREN'] = { id = 6, faction = 'Horde', name = 'Tauren', raceFile = 'TAUREN' },
        ['GNOME'] = { id = 7, faction = 'Alliance' , name = 'Gnome', raceFile = 'GNOME' },
        ['TROLL'] = { id = 8, faction = 'Horde', name = 'Troll', raceFile = 'TROLL' },
    }

    local myFaction = UnitFactionGroup('player')
    for k, v in pairs(tblRaces) do
        if v.faction == myFaction then tbl[k] = v end
    end

    return tbl
end
function ds:races_cata() -- Race data
    local tbl = {}
    local tblRaces = {
        ['HUMAN'] = { id = 1, faction = 'Alliance', name = 'Human', raceFile = 'HUMAN' },
        ['ORC'] = { id = 2, faction = 'Horde', name = 'Orc', raceFile = 'ORC' },
        ['Dwarf'] = { id = 3, faction = 'Alliance', name = 'Dwarf', raceFile = 'DWARF' },
        ['NIGHTELF'] = { id = 4, faction = 'Alliance', name = 'Night Elf', raceFile = 'NIGHTELF' },
        ['UNDEAD'] = { id = 5, faction = 'Horde', name = 'Undead', raceFile = 'UNDEAD' },
        ['TAUREN'] = { id = 6, faction = 'Horde', name = 'Tauren', raceFile = 'TAUREN' },
        ['GNOME'] = { id = 7, faction = 'Alliance' , name = 'Gnome', raceFile = 'GNOME' },
        ['TROLL'] = { id = 8, faction = 'Horde', name = 'Troll', raceFile = 'TROLL' },
        ['GOBLIN'] = { id = 9, faction = 'Horde', name = 'Goblin', raceFile = 'GOBLIN' },
        ['BLOODELF'] = { id = 10, faction = 'Horde', name = 'Blood Elf', raceFile = 'BLOODELF' },
        ['DRAENEI'] = { id = 11, faction = 'Alliance', name = 'Draenei', raceFile = 'DRAENEI' },
        ['WORGEN'] = { id = 22, faction = 'Alliance', name = 'Worgen', raceFile = 'WORGEN' },
    }

    local myFaction = UnitFactionGroup('player')
    for k, v in pairs(tblRaces) do
        if v.faction == myFaction then tbl[k] = v end
    end

    return tbl
end
function ds:classes_retail() -- Class list
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
function ds:classes_classic() -- Class list
    local tbl = {}
    local classes = {
        ['WARRIOR'] = { id = 1, faction = 'Both', name = 'Warrior', color = 'C79C6E', classFile = 'WARRIOR', icon = 132355 },
        ['PALADIN'] = { id = 2, faction = 'Alliance', name = 'Paladin', color = 'F58CBA', classFile = 'PALADIN', icon = 135873 },
        ['HUNTER'] = { id = 3, faction = 'Both', name = 'Hunter', color = 'ABD473', classFile = 'HUNTER', icon = 132162 },
        ['ROGUE'] = { id = 4, faction = 'Both', name = 'Rogue', color = 'FFF569', classFile = 'ROGUE', icon = 132320 },
        ['PRIEST'] = { id = 5, faction = 'Both', name = 'Priest', color = 'FFFFFF', classFile = 'PRIEST', icon = 135940 },
        ['SHAMAN'] = { id = 7, faction = 'Horde', name = 'Shaman', color = '0070DE', classFile = 'SHAMAN', icon = 136243 },
        ['MAGE'] = { id = 8, faction = 'Both', name = 'Mage', color = '69CCF0', classFile = 'MAGE', icon = 136129 },
        ['WARLOCK'] = { id = 9, faction = 'Both', name = 'Warlock', color = '9482C9', classFile = 'WARLOCK', icon = 136145 },
        ['DRUID'] = { id = 11, faction = 'Both', name = 'Druid', color = 'FF7D0A', classFile = 'DRUID', icon = 132114 },
    }

    local myFaction = UnitFactionGroup('player')
    for k, v in pairs(classes) do
        if v.faction == 'Both' or v.faction == myFaction then tbl[k] = v end
    end

    return tbl
end
function ds:classes_cata() -- Class list
    local tbl = {}
    local classes = {
        ['WARRIOR'] = { id = 1, faction = 'Both', name = 'Warrior', color = 'C79C6E', classFile = 'WARRIOR', icon = 132355 },
        ['PALADIN'] = { id = 2, faction = 'Alliance', name = 'Paladin', color = 'F58CBA', classFile = 'PALADIN', icon = 135873 },
        ['HUNTER'] = { id = 3, faction = 'Both', name = 'Hunter', color = 'ABD473', classFile = 'HUNTER', icon = 132162 },
        ['ROGUE'] = { id = 4, faction = 'Both', name = 'Rogue', color = 'FFF569', classFile = 'ROGUE', icon = 132320 },
        ['PRIEST'] = { id = 5, faction = 'Both', name = 'Priest', color = 'FFFFFF', classFile = 'PRIEST', icon = 135940 },
        ['DEATHKNIGHT'] = { id = 6, faction = 'Both', name = 'Death Knight', color = 'C41F3B', classFile = 'DEATHKNIGHT', icon = 135770 },
        ['SHAMAN'] = { id = 7, faction = 'Horde', name = 'Shaman', color = '0070DE', classFile = 'SHAMAN', icon = 136243 },
        ['MAGE'] = { id = 8, faction = 'Both', name = 'Mage', color = '69CCF0', classFile = 'MAGE', icon = 136129 },
        ['WARLOCK'] = { id = 9, faction = 'Both', name = 'Warlock', color = '9482C9', classFile = 'WARLOCK', icon = 136145 },
        ['DRUID'] = { id = 11, faction = 'Both', name = 'Druid', color = 'FF7D0A', classFile = 'DRUID', icon = 132114 },
    }

    local myFaction = UnitFactionGroup('player')
    for k, v in pairs(classes) do
        if v.faction == 'Both' or v.faction == myFaction then tbl[k] = v end
    end

    return tbl
end
function ds:GetZones()
    local tbl = {}
    for mapID = 1, 20000 do  -- Expanded range to cover all potential maps
        local mapInfo = C_Map.GetMapInfo(mapID)
        if mapInfo and mapInfo.name then
            tbl[strlower(mapInfo.name)] = mapInfo
        end
    end

    return tbl
end
function ds:GetZoneInfo(tblIDs)
    local instanceList = {}
    if not tblIDs then return end
    for i=1,#tblIDs do
        local mapInfo = C_Map.GetMapInfo(tblIDs[i])
        if mapInfo then
            instanceList[strlower(mapInfo.name)] = { name = mapInfo.name, instanceID = tblIDs[i], reason = 'PVP Area' }
        end
    end

    return instanceList
end
function ds:invalidZones_Retail() -- Invalid zones for recruitment
    EncounterJournal_LoadUI() -- Load the Encounter Journal

    local instanceList = {}
    instanceList = self:GetZoneInfo(pvpMapIDs) or {}
    local function ListAllInstances(isRaid)
        local index, name, instanceID = 0, nil, 1

        -- Loop through all instances in the Dungeon Journal
        while instanceID do
            index = index + 1
            instanceID, name = EJ_GetInstanceByIndex(index, isRaid or false)
            if name and instanceID then
                instanceList[strlower(name)] = {
                    name = name, instanceID = instanceID, reason = isRaid and 'Seasonal Raid' or 'Seasonal Dungeon' }
            end
        end
    end

    ListAllInstances() -- List all seasonal dungeons
    ListAllInstances(true) -- List all seasonal raids

    return instanceList
end
function ds:invalidZones_Classic() -- Invalid zones for recruitment
    local instanceList = {}
    instanceList = self:GetZoneInfo(pvpMapIDs) or {}

    --** Classic Raids
    instanceList['molten core'] = {
        name = 'Molten Core',
        instanceID = 409,
        reason = 'Raid',
        levelRange = '60',
        location = 'Blackrock Mountain, Burning Steppes',
    }

    instanceList['onyxias lair'] = {
        name = 'Onyxia\'s Lair',
        instanceID = 249,
        reason = 'Raid',
        levelRange = '60',
        location = 'Dustwallow Marsh, Kalimdor',
    }

    instanceList['blackwing lair'] = {
        name = 'Blackwing Lair',
        instanceID = 469,
        reason = 'Raid',
        levelRange = '60',
        location = 'Blackrock Mountain, Burning Steppes',
    }

    instanceList['zul gurub'] = {
        name = 'Zul\'Gurub',
        instanceID = 309,
        reason = 'Raid',
        levelRange = '60',
        location = 'Stranglethorn Vale, Eastern Kingdoms',
    }

    instanceList['ruins of ahnqiraj'] = {
        name = 'Ruins of Ahn\'Qiraj',
        instanceID = 509,
        reason = 'Raid',
        levelRange = '60',
        location = 'Silithus, Kalimdor',
    }

    instanceList['temple of ahnqiraj'] = {
        name = 'Temple of Ahn\'Qiraj',
        instanceID = 531,
        reason = 'Raid',
        levelRange = '60',
        location = 'Silithus, Kalimdor',
    }

    instanceList['naxxramas'] = {
        name = 'Naxxramas',
        instanceID = 533,
        reason = 'Raid',
        levelRange = '60',
        location = 'Eastern Plaguelands, Eastern Kingdoms',
    }

    --** Classic Dungeons
    instanceList['ragefire chasm'] = {
        name = 'Ragefire Chasm',
        instanceID = 389, -- Example ID; instance IDs in Classic are different from retail
        reason = 'Dungeon',
        levelRange = '13-18',
        location = 'Orgrimmar, Kalimdor',
    }
    instanceList['the deadmines'] = {
        name = 'The Deadmines',
        instanceID = 756,
        reason = 'Dungeon',
        levelRange = '17-26',
        location = 'Westfall, Eastern Kingdoms',
    }
    instanceList['wailing caverns'] = {
        name = 'Wailing Caverns',
        instanceID = 718,
        reason = 'Dungeon',
        levelRange = '17-24',
        location = 'Northern Barrens, Kalimdor',
    }
    instanceList['the stockade'] = {
        name = 'The Stockade',
        instanceID = 717,
        reason = 'Dungeon',
        levelRange = '22-30',
        location = 'Stormwind City, Eastern Kingdoms',
    }
    instanceList['shadowfang keep'] = {
        name = 'Shadowfang Keep',
        instanceID = 33,
        reason = 'Dungeon',
        levelRange = '22-30',
        location = 'Silverpine Forest, Eastern Kingdoms',
    }
    instanceList['blackfathom deeps'] = {
        name = 'Blackfathom Deeps',
        instanceID = 719,
        reason = 'Dungeon',
        levelRange = '20-30',
        location = 'Ashenvale, Kalimdor',
    }
    instanceList['gnomeregan'] = {
        name = 'Gnomeregan',
        instanceID = 721,
        reason = 'Dungeon',
        levelRange = '29-38',
        location = 'Dun Morogh, Eastern Kingdoms',
    }
    instanceList['razorfen kraul'] = {
        name = 'Razorfen Kraul',
        instanceID = 491,
        reason = 'Dungeon',
        levelRange = '30-40',
        location = 'Southern Barrens, Kalimdor',
    }
    instanceList['scarlet monastery'] = {
        name = 'Scarlet Monastery',
        instanceID = 796,
        reason = 'Dungeon (4 Wings)',
        levelRange = '26-45',
        location = 'Tirisfal Glades, Eastern Kingdoms',
    }
    instanceList['razorfen downs'] = {
        name = 'Razorfen Downs',
        instanceID = 722,
        reason = 'Dungeon',
        levelRange = '37-46',
        location = 'Southern Barrens, Kalimdor',
    }
    instanceList['uldaman'] = {
        name = 'Uldaman',
        instanceID = 1337,
        reason = 'Dungeon',
        levelRange = '42-52',
        location = 'Badlands, Eastern Kingdoms',
    }
    instanceList['zulfarrak'] = {
        name = 'Zul\'Farrak',
        instanceID = 1176,
        reason = 'Dungeon',
        levelRange = '44-54',
        location = 'Tanaris, Kalimdor',
    }
    instanceList['maraudon'] = {
        name = 'Maraudon',
        instanceID = 2100,
        reason = 'Dungeon (3 Wings)',
        levelRange = '46-55',
        location = 'Desolace, Kalimdor',
    }
    instanceList['temple of atalhakkar'] = {
        name = 'Temple of Atal\'Hakkar (The Sunken Temple)',
        instanceID = 1477,
        reason = 'Dungeon',
        levelRange = '50-60',
        location = 'Swamp of Sorrows, Eastern Kingdoms',
    }
    instanceList['blackrock depths'] = {
        name = 'Blackrock Depths',
        instanceID = 1584,
        reason = 'Dungeon',
        levelRange = '52-60',
        location = 'Blackrock Mountain, Eastern Kingdoms',
    }
    instanceList['lower blackrock spire'] = {
        name = 'Lower Blackrock Spire (LBRS)',
        instanceID = 1585,
        reason = 'Dungeon',
        levelRange = '55-60',
        location = 'Blackrock Mountain, Eastern Kingdoms',
    }
    instanceList['dire maul'] = {
        name = 'Dire Maul',
        instanceID = 2557,
        reason = 'Dungeon (3 Wings)',
        levelRange = '54-60',
        location = 'Feralas, Kalimdor',
    }
    instanceList['stratholme'] = {
        name = 'Stratholme',
        instanceID = 2017,
        reason = 'Dungeon (2 Wings)',
        levelRange = '58-60',
        location = 'Eastern Plaguelands, Eastern Kingdoms',
    }
    instanceList['scholomance'] = {
        name = 'Scholomance',
        instanceID = 2057,
        reason = 'Dungeon',
        levelRange = '58-60',
        location = 'Western Plaguelands, Eastern Kingdoms',
    }

    return instanceList
end
function ds:invalidZones_Cata() -- Invalid zones for recruitment
    local instanceList = {}

    --** Cataclysm Raids
    -- Wrath of the Lich King Raids
    instanceList['naxxramas'] = {
        name = 'Naxxramas',
        instanceID = 533,
        reason = 'Raid',
        levelRange = '80',
        location = 'Dragonblight, Northrend',
    }

    instanceList['obsidian sanctum'] = {
        name = 'The Obsidian Sanctum',
        instanceID = 615,
        reason = 'Raid',
        levelRange = '80',
        location = 'Dragonblight, Northrend',
    }

    instanceList['eye of eternity'] = {
        name = 'The Eye of Eternity',
        instanceID = 616,
        reason = 'Raid',
        levelRange = '80',
        location = 'Borean Tundra, Northrend',
    }

    instanceList['ulduar'] = {
        name = 'Ulduar',
        instanceID = 603,
        reason = 'Raid',
        levelRange = '80',
        location = 'The Storm Peaks, Northrend',
    }

    instanceList['trial of the crusader'] = {
        name = 'Trial of the Crusader',
        instanceID = 649,
        reason = 'Raid',
        levelRange = '80',
        location = 'Icecrown, Northrend',
    }

    instanceList['onyxias lair'] = {
        name = 'Onyxia\'s Lair',
        instanceID = 249,
        reason = 'Raid',
        levelRange = '80',
        location = 'Dustwallow Marsh, Kalimdor',
    }

    instanceList['icecrown citadel'] = {
        name = 'Icecrown Citadel',
        instanceID = 631,
        reason = 'Raid',
        levelRange = '80',
        location = 'Icecrown, Northrend',
    }

    instanceList['ruby sanctum'] = {
        name = 'The Ruby Sanctum',
        instanceID = 724,
        reason = 'Raid',
        levelRange = '80',
        location = 'Dragonblight, Northrend',
    }

    -- Cataclysm Raids
    instanceList['baradin hold'] = {
        name = 'Baradin Hold',
        instanceID = 757,
        reason = 'Raid',
        levelRange = '85',
        location = 'Tol Barad, Eastern Kingdoms',
    }

    instanceList['blackwing descent'] = {
        name = 'Blackwing Descent',
        instanceID = 754,
        reason = 'Raid',
        levelRange = '85',
        location = 'Blackrock Mountain, Eastern Kingdoms',
    }

    instanceList['bastion of twilight'] = {
        name = 'The Bastion of Twilight',
        instanceID = 758,
        reason = 'Raid',
        levelRange = '85',
        location = 'Twilight Highlands, Eastern Kingdoms',
    }

    instanceList['throne of the four winds'] = {
        name = 'Throne of the Four Winds',
        instanceID = 773,
        reason = 'Raid',
        levelRange = '85',
        location = 'Uldum, Kalimdor',
    }

    instanceList['firelands'] = {
        name = 'Firelands',
        instanceID = 720,
        reason = 'Raid',
        levelRange = '85',
        location = 'Mount Hyjal, Kalimdor',
    }

    instanceList['dragon soul'] = {
        name = 'Dragon Soul',
        instanceID = 824,
        reason = 'Raid',
        levelRange = '85',
        location = 'Caverns of Time, Tanaris',
    }

    --** Wrath of the Lich King Dungeons
    instanceList['utgarde keep'] = {
        name = 'Utgarde Keep',
        instanceID = 574,
        reason = 'Dungeon',
        levelRange = '68-75',
        location = 'Howling Fjord, Northrend',
    }

    instanceList['the nexus'] = {
        name = 'The Nexus',
        instanceID = 576,
        reason = 'Dungeon',
        levelRange = '70-75',
        location = 'Borean Tundra, Northrend',
    }

    instanceList['azjol-nerub'] = {
        name = 'Azjol-Nerub',
        instanceID = 601,
        reason = 'Dungeon',
        levelRange = '72-77',
        location = 'Dragonblight, Northrend',
    }

    instanceList['ahnkahet the old kingdom'] = {
        name = 'Ahn\'kahet: The Old Kingdom',
        instanceID = 619,
        reason = 'Dungeon',
        levelRange = '73-78',
        location = 'Dragonblight, Northrend',
    }

    instanceList['draktharon keep'] = {
        name = "Drak'Tharon Keep",
        instanceID = 600,
        reason = 'Dungeon',
        levelRange = '74-79',
        location = 'Grizzly Hills, Northrend',
    }

    instanceList['violet hold'] = {
        name = 'The Violet Hold',
        instanceID = 608,
        reason = 'Dungeon',
        levelRange = '75-80',
        location = 'Dalaran, Northrend',
    }

    instanceList['gundrak'] = {
        name = 'Gundrak',
        instanceID = 604,
        reason = 'Dungeon',
        levelRange = '76-80',
        location = 'Zul\'Drak, Northrend',
    }

    instanceList['halls of stone'] = {
        name = 'Halls of Stone',
        instanceID = 599,
        reason = 'Dungeon',
        levelRange = '77-80',
        location = 'The Storm Peaks, Northrend',
    }

    instanceList['halls of lightning'] = {
        name = 'Halls of Lightning',
        instanceID = 602,
        reason = 'Dungeon',
        levelRange = '78-80',
        location = 'The Storm Peaks, Northrend',
    }

    instanceList['the oculus'] = {
        name = 'The Oculus',
        instanceID = 578,
        reason = 'Dungeon',
        levelRange = '78-80',
        location = 'Borean Tundra, Northrend',
    }

    instanceList['utgarde pinnacle'] = {
        name = 'Utgarde Pinnacle',
        instanceID = 575,
        reason = 'Dungeon',
        levelRange = '78-80',
        location = 'Howling Fjord, Northrend',
    }

    instanceList['trial of the champion'] = {
        name = 'Trial of the Champion',
        instanceID = 650,
        reason = 'Dungeon',
        levelRange = '80',
        location = 'Icecrown, Northrend',
    }

    instanceList['forge of souls'] = {
        name = 'The Forge of Souls',
        instanceID = 632,
        reason = 'Dungeon',
        levelRange = '80',
        location = 'Icecrown Citadel, Northrend',
    }

    instanceList['pit of saron'] = {
        name = 'Pit of Saron',
        instanceID = 658,
        reason = 'Dungeon',
        levelRange = '80',
        location = 'Icecrown Citadel, Northrend',
    }

    instanceList['halls of reflection'] = {
        name = 'Halls of Reflection',
        instanceID = 668,
        reason = 'Dungeon',
        levelRange = '80',
        location = 'Icecrown Citadel, Northrend',
    }

    -- Cataclysm Dungeons
    instanceList['blackrock caverns'] = {
        name = 'Blackrock Caverns',
        instanceID = 753,
        reason = 'Dungeon',
        levelRange = '80-83',
        location = 'Blackrock Mountain, Eastern Kingdoms',
    }

    instanceList['throne of the tides'] = {
        name = 'Throne of the Tides',
        instanceID = 767,
        reason = 'Dungeon',
        levelRange = '80-83',
        location = 'Abyssal Maw, Vashj\'ir',
    }

    instanceList['the stonecore'] = {
        name = 'The Stonecore',
        instanceID = 768,
        reason = 'Dungeon',
        levelRange = '81-85',
        location = 'Deepholm, The Maelstrom',
    }

    instanceList['vortex pinnacle'] = {
        name = 'The Vortex Pinnacle',
        instanceID = 769,
        reason = 'Dungeon',
        levelRange = '81-85',
        location = 'Uldum, Kalimdor',
    }

    instanceList['grim batol'] = {
        name = 'Grim Batol',
        instanceID = 757,
        reason = 'Dungeon',
        levelRange = '84-85',
        location = 'Twilight Highlands, Eastern Kingdoms',
    }

    instanceList['lost city of tolvir'] = {
        name = 'Lost City of the Tol\'vir',
        instanceID = 747,
        reason = 'Dungeon',
        levelRange = '84-85',
        location = 'Uldum, Kalimdor',
    }

    instanceList['halls of origination'] = {
        name = 'Halls of Origination',
        instanceID = 759,
        reason = 'Dungeon',
        levelRange = '85',
        location = 'Uldum, Kalimdor',
    }

    instanceList['zul gurub'] = {
        name = 'Zul\'Gurub',
        instanceID = 793,
        reason = 'Dungeon',
        levelRange = '85',
        location = 'Northern Stranglethorn, Eastern Kingdoms',
    }

    instanceList['zul aman'] = {
        name = 'Zul\'Aman',
        instanceID = 781,
        reason = 'Dungeon',
        levelRange = '85',
        location = 'Ghostlands, Eastern Kingdoms',
    }

    instanceList['end time'] = {
        name = 'End Time',
        instanceID = 820,
        reason = 'Dungeon',
        levelRange = '85',
        location = 'Tanaris, Caverns of Time',
    }

    instanceList['well of eternity'] = {
        name = 'Well of Eternity',
        instanceID = 816,
        reason = 'Dungeon',
        levelRange = '85',
        location = 'Tanaris, Caverns of Time',
    }

    instanceList['hour of twilight'] = {
        name = 'Hour of Twilight',
        instanceID = 819,
        reason = 'Dungeon',
        levelRange = '85',
        location = 'Dragonblight, Northrend',
    }

    return instanceList
end
ds:Init()
