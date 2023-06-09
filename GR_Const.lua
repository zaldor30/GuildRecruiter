-- Guid Recruiter Constants
GuildRecruiter = {}
_G['GuildRecruiter'] = GuildRecruiter
local _, ns = ... -- Namespace (myaddon, namespace)

ns.db, ns.dbInv, ns.dbBl, ns.dbA, ns.code = {}, {}, {}, {}, {} -- Namespace and ns.code Namespace
MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()
SCAN_WAIT_TIME = 4
DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
PLAYER_PROFILE = UnitName('player')..' - '..GetRealmName()

function SetGuildInfo()
	local p = ns.db.profile
	local clubID = C_Club.GetGuildClubId() or nil
	local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
	if club then
		local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
		p.guildInfo = {clubID = clubID, guildName = gName, guildLink = gLink }
	elseif clubID and C_Club.GetClubInfo(clubID) then
		p.guildInfo = {clubID = clubID, guildName = C_Club.GetClubInfo(clubID).name, guildLink = nil }
	end
end
function ns:SetProfileDefaults()
	local g = ns.db.global

	g.showMenu = g.showMenu or true
	g.showMsg = g.showMsg or false
	g.autoScanPlayers = g.autoScanPlayers or false
	g.autoScanTime = g.autoScanTime or SCAN_WAIT_TIME
	g.rememberPlayers = g.rememberPlayers or true
	g.rememberTime = g.rememberTime or 7

	SetGuildInfo(db)
end

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

GR_INSTANCE_ZONE_ID = {
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
GR_INSTANCE_ZONE_NAME = {}
for k,r in pairs(GR_INSTANCE_ZONE_ID) do
	GR_INSTANCE_ZONE_NAME[r] = k end