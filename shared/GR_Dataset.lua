local _, ns = ... -- Namespace (myaddon, namespace)

ns.ds = {}
local ds = ns.ds

function ds:Init()
    self.dbVersion = GR.dbVersion -- From GR_Init
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
function ds:invalidZones() -- Invalid zones for recruitment
    local tbl = {
        --*battlegrounds
        ["Alterac Valley"] = { id = 30, name = "Alterac Valley", reason = 'Battlegrounds' },
        ["Warsong Gulch"] = { id = 489, name = "Warsong Gulch", reason = 'Battlegrounds' },
        ["Arathi Basin"] = { id = 529, name = "Arathi Basin (Classic)", reason = 'Battlegrounds' },
        ["Eye of the Storm"] = { id = 566, name = "Eye of the Storm", reason = 'Battlegrounds' },
        ["Strand of the Ancients"] = { id = 607, name = "Strand of the Ancients", reason = 'Battlegrounds' },
        ["Isle of Conquest"] = { id = 628, name = "Isle of Conquest", reason = 'Battlegrounds' },
        ["Twin Peaks"] = { id = 726, name = "Twin Peaks", reason = 'Battlegrounds' },
        ["Silvershard Mines"] = { id = 727, name = "Silvershard Mines", reason = 'Battlegrounds' },
        ["The Battle for Gilneas"] = { id = 761, name = "The Battle for Gilneas", reason = 'Battlegrounds' },
        ["Temple of Kotmogu"] = { id = 998, name = "Temple of Kotmogu", reason = 'Battlegrounds' },
        ["Deepwind Gorge"] = { id = 1105, name = "Deepwind Gorge", reason = 'Battlegrounds' },
        ["Seething Shore"] = { id = 1803, name = "Seething Shore", reason = 'Battlegrounds' },
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
        --*raids
        ["Nerub’ar Palace"] = { id = 0, name = "Nerub’ar Palace", reason = 'TWW Season 1 Raid' },

        --*dungeons
        ["Ara-Kara, City of Echoes"] = { id = 0, name = "Ara-Kara, City of Echoes", reason = 'TWW Dungeon' },
        ["Priory of the Sacred Flame"] = { id = 0, name = "Priory of the Sacred Flame", reason = 'TWW Dungeon' },
        ["The Stonevault"] = { id = 0, name = "The Stonevault", reason = 'TWW Dungeon' },
        ["Cinderbrew Meadery"] = { id = 0, name = "Cinderbrew Meadery", reason = 'TWW Dungeon' },
        ["City of Threads"] = { id = 0, name = "City of Threads", reason = 'TWW Dungeon' },
        ["Darkflame Cleft"] = { id = 0, name = "Darkflame Cleft", reason = 'TWW Dungeon' },
        ["The Dawnbreaker"] = { id = 0, name = "The Dawnbreaker", reason = 'TWW Dungeon' },

        --* Delves
        ["Delves"] = { id = 0, name = "Delves", reason = 'Delves' },
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