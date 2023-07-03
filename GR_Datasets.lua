-- Pre-defined Datasets
local _, ns = ... -- Namespace (myaddon, namespace)
ns.datasets = {}
local ds = ns.datasets

-- All Classes
function ds:Init()
    self.tblAllRaces = ds:races() -- Only for player faction
    self.tblAllClasses = ds:classes()
    self.tblClassesByName = ds:classesByName()

    self.tblBadByName = {}
    self.tblBadZones = ds:invalidZones()

    self.tblGMMessages = {}
end
function ds:classes()
    return {
        ['WARRIOR'] = { id = 1, name = 'Warrior', classFile = 'WARRIOR', tank = true, healer = false, melee = true, ranged = false },
        ['PALADIN'] = { id = 2, name = 'Paladin', classFile = 'PALADIN', tank = true, healer = true, melee = true, ranged = false },
        ['HUNTER'] = { id = 3, name = 'Hunter', classFile = 'HUNTER', tank = false, healer = false, melee = false, ranged = true },
        ['ROGUE'] = { id = 4, name = 'Rogue', classFile = 'ROGUE', tank = false, healer = false, melee = true, ranged = false },
        ['PRIEST'] = { id = 5, name = 'Priest', classFile = 'PRIEST', tank = false, healer = false, melee = false, ranged = true },
        ['DEATHKNIGHT'] = { id = 6, name = 'Death Knight', classFile = 'DEATHKNIGHT', tank = true, healer = false, melee = true, ranged = false },
        ['SHAMAN'] = { id = 7, name = 'Shaman', classFile = 'SHAMAN', tank = false, healer = true, melee = true, ranged = true },
        ['MAGE'] = { id = 8, name = 'Mage', classFile = 'MAGE', tank = false, healer = false, melee = false, ranged = true },
        ['WARLOCK'] = { id = 9, name = 'Warlock', classFile = 'WARLOCK', tank = false, healer = false, melee = false, ranged = true },
        ['MONK'] = { id = 10, name = 'Monk', classFile = 'MONK', tank = true, healer = true, melee = true, ranged = false },
        ['DRUID'] = { id = 11, name = 'Druid', classFile = 'DRUID', tank = true, healer = true, melee = true, ranged = true },
        ['DEMONHUNTER'] = { id = 12, name = 'Demon Hunter', classFile = 'DEMONHUNTER', tank = true, healer = false, melee = true, ranged = false },
        ['EVOKER'] = { id = 13, name = 'Evoker', classFile = 'EVOKER', tank = false, healer = true, melee = false, ranged = true },
    }
end
function ds:classesByName()
    local tbl = {}
	for i=1,GetNumClasses() do
		local class = C_CreatureInfo.GetClassInfo(i)
		if class then
			tbl[class.className] = { classID = class.classID, classFile = class.classFile }
		end
        tbl['Evoker'] = { classID = 13, className = 'Evoker'}
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

    for k, r in pairs(tbl) do self.tblBadByName[r] = k end

    return tbl
end
function ds:GMessages()
    local dbMessages = ns.db.messages.messageList or nil
    local dbGMessages = ns.dbGlobal.messageList or {}

    -- GM messages then personal
    local tbl = {}
    for _,r in pairs(dbGMessages) do
        r.gmMessage = true
        tinsert(tbl, r)
    end
    for _,r in pairs(dbMessages or {}) do tinsert(tbl, r) end
    self.tblGMMessages = tbl
end
ds:Init()