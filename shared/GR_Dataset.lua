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
    self.tblRaces = self:races()
    self.tblClasses = self:classes()
    self.tblClassesByName = nil

    self.zoneIDs = {}
    self.zoneNames = {}

    self.instanceList = {}
end
function ds:WhatsNew() -- What's new in the current version
    local height = 410 -- Adjust size of what's new window
    local title, msg = '', ''
    title = ns.code:cText('FFFFFF00', "What's new in v"..GR.versionOut.."?")
    msg = [[
            |CFF55D0FF** Please report any bugs or issues in Discord **
                    Discord: https://discord.gg/ZtS6Q2sKRH
                (or click on the icon in the top left corner)|r

    |CFFFFFF00v3.2.41 Notes|r
        - Rework of invalid zones to support other languages.
        - Also, made seasonal dungeons and raids automatically added to invalid zones.
        - Settings Rework:
            - Reorganized settings to make it easier to find things.
            - Only have invite or GM options, if you are a GM.
            - GM messages have an option to sync only the ones marked (not fully working yet).
            - Can see anti-spam list, but not change it.
            - Reworked black list and added a privacy option for reason.
            - Reworked invalid zones so you can specify a name of a zone to ignore.
    |CFFFFFF00v3.1.40 Notes|r
        - Added option to keep addon running and ignore certain ways to close it.
        - esMX (Spanish Mexico) localization added.
        - Fixed issue with whispers not being sent when player joins guild.
        - Fixed issue with compact mode not removing anti-spam/black list before adding to invite list.
    |CFFFFFF00v3.0.36 Notes|r  -- Joined forces with FGI to bring recruiting to the next level.
        - Changed the 6 months to 180 days.
        (NOTE: If you were using the 6 months, you will need to update your settings.)
        - Added force checkbox to GM settings.
        - Added auto detect of Block Guild Invites from players before sending a message.
        - Updated sync so everyone in the guild will need to upgrade.
        - Invites should match up with the order on the screen.
        - Added season 1 raid to invalid zones.
        - Added TWW dungeons to invalid zones.
        - Added Delves to invalid zones.
        - Working on issue with wrong welcome messages being sent.
        - Fixed issue with not creating a guild link.
    |CFFFFFF00v3.0.30 Notes|r
        - Fixed issue with missing no guild link localization.
        - Updated alert to missing guild link on login.
              
    |CFFFFFF00v3.0.29 Notes|r
        - Fix error when not in guild and right click a name.
        - Fix error when not in guild and a sync is attempted.
    
    |CFFFFFF00v3.0.29 Notes|r
        - Trying to fix position of right click invite menu.
        - Fix to replacing GUILDNAME, etc when sending invite message only
          from the right click menu.
        - Fixed issue with scanning using the keybindings.

    |CFFFFFF00v3.0.26 Notes|r
        I have done pretty much a full rewrite of Guild Recruiter.
        I have added a lot of new features and fixed a lot of bugs.

    - Features:
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
        - Invite list and scan data will show after leaving the screen.
    - Sync Changes:
        - Changed the detection of out of date versions.
        The sync will look at the database version and not the
        addon version.
        
        This means that the addons can be different versions and
        so long as the database is the same, they will sync.
    - Settings Changes:
        - Added the ability for GM to override GM settings so they
        can use personal invite settings.
        - Added the ability to turn off auto sync.
        - Added the ability to add zones to ignore.
    ]]

    return title, msg, height
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
function ds:invalidZones() -- Invalid zones for recruitment
    self.instanceList = self.instanceList or {} -- Instance list
    EncounterJournal_LoadUI() -- Load the Encounter Journal

    local function ListAllInstances(isRaid)
        local index, name, instanceID = 0, nil, 1

        -- Loop through all instances in the Dungeon Journal
        while instanceID do
            index = index + 1
            instanceID, name = EJ_GetInstanceByIndex(index, isRaid or false)
            if name and instanceID then
                self.instanceList[strlower(name)] = { name = name, instanceID = instanceID, reason = isRaid and 'Seasonal Raid' or 'Seasonal Dungeon' }
            end
        end
    end
    ListAllInstances()
    ListAllInstances(true)

    local function GetZoneInfo(tblIDs)
        if not tblIDs then return end
        for i=1,#tblIDs do
            local mapInfo = C_Map.GetMapInfo(tblIDs[i])
            if mapInfo then
                self.instanceList[strlower(mapInfo.name)] = { name = mapInfo.name, instanceID = tblIDs[i], reason = 'PVP Area' }
            end
        end
    end

    -- Call the function with Nagrand Arena's map ID
    GetZoneInfo(pvpMapIDs)

    ns.global.zoneList = ns.global.zoneList and ns.global.zoneList or {}
    for k, r in pairs(ns.global.zoneList and ns.global.zoneList or {}) do self.instanceList[k] = r end

    return self.instanceList, self.instanceListIDs
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
            [32] = "Horde",      -- Kul Tiran
            [34] = "Alliance",   -- Dark Iron Dwarf
            [36] = "Horde",      -- Mag'har Orc
            [37] = "Alliance",   -- Mechagnome
        }

        local raceInfo = C_CreatureInfo.GetRaceInfo(raceID)
        if raceInfo then
            if raceFactions[raceInfo.raceID] then
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
ds:Init()