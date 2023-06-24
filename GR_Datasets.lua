-- Pre-defined Datasets
local _, ns = ... -- Namespace (myaddon, namespace)
ns.datasets = {}
local ds = ns.datasets

-- All Classes
function ds:Init()
    self.tblAllRaces = ds:races() -- Only for player faction
    self.tblAllClasses = ds:classes()

    self.tblBadByName = {}
    self.tblBadZones = ds:invalidZones()
end
function ds:classes()
    local tbl = {}
	for i=1,GetNumClasses() do
		local class = C_CreatureInfo.GetClassInfo(i)
		if class then
			tbl[class.classID] = { classFile = class.classFile, className = class.className }
		end
        tbl[13] = { classFile = 'EVOKER', className = 'Evoker'}
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
            [9] = "Alliance",    -- Goblin
            [10] = "Horde",      -- Blood Elf
            [11] = "Alliance",   -- Draenei
            [22] = "Alliance",   -- Worgen
            [24] = "Neutral",    -- Pandaren (can choose either faction)
            [25] = "Horde",      -- Horde Pandaren
            [26] = "Alliance",   -- Alliance Pandaren
            [27] = "Alliance",   -- Nightborne
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
        tbl[raceID] = C_CreatureInfo.GetRaceInfo(raceID).clientFileString end
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
ds:Init()