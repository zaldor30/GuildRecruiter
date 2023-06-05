-- Guid Recruiter Constants
MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()
GR_SCAN_WAIT_TIME = 5
DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
PLAYER_PROFILE = UnitName('player')..' - '..GetRealmName()
NS = {}

function GetAllPlayerClasses()
	local tbl = {}
	for i=1,GetNumClasses() do
		local class = C_CreatureInfo.GetClassInfo(i)
		if class then
			tbl[class.classID] = { classFile = class.classFile, className = class.className }
		end
	end

	return tbl
end
APC = GetAllPlayerClasses() -- All Available Classes

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
local function resetRaceTable()
    local tbl, raceID, faction = {}, 1, UnitFactionGroup('player')
    while C_CreatureInfo.GetRaceInfo(raceID) do
		if raceFactions[raceID] == faction or raceFactions[raceID] == 'Neutral' then
        	tbl[raceID] = C_CreatureInfo.GetRaceInfo(raceID).clientFileString end
        raceID = raceID + 1
    end

    return tbl
end
APR = resetRaceTable() -- All Available Races

GR_INSTANCE_ZONES = {
    --battlegrounds
		2597,
		6665,
		3358,
		4710,
		4384,
		3820,
		8485,
		6126,
		3277,
		5449,
		5031,
		7107,
		9136,
		6051,
		10176,
	--arenas
		8008,
		4406,
		6732,
		3968,
		4378,
		7816,
		6296,
		3698,
		3702,
		8624,
		14436,

		--@version-retail@
	--raids
		14663,
		14030,
		14663,
	--dungeons
		14032,
		13991,
		14082,
		14011,
		14063,
		13954,
		13982,
		13968,
		--M+ rotating
		9391,
		7546,
		8093,
}

function NS.SetProfileDefaults(db)
	local p,g = db.profile, db.global

	g.showMenu = g.showMenu or true
	g.showMsg = g.showMsg or false
	g.autoScanPlayers = g.autoScanPlayers or false
	g.autoScanTime = g.autoScanTime or 5
	g.rememberPlayers = g.rememberPlayers or true
	g.rememberTime = g.rememberTime or 7
end