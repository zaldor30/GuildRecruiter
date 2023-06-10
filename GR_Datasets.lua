-- Pre-defined Datasets
ns.datasets = {}
local ds = ns.datasets

-- All Classes
function ds:Init()
    tblAllRaces = ds:races() -- Only for player faction
    tblAllClasses = ds:classes()
    tblBadZones = ds:invalidZones()
    tblOptDefaults = ds:optionDefaults()
end
function ds:classes()
    local tbl = {}
	for i=1,GetNumClasses() do
		local class = C_CreatureInfo.GetClassInfo(i)
		if class then
			tbl[class.classID] = { classFile = class.classFile, className = class.className }
		end
	end

	return tbl
end
function ds:races()
    local tbl, raceID, faction = {}, 1, UnitFactionGroup('player')
    while C_CreatureInfo.GetRaceInfo(raceID) do
		if raceFactions[raceID] == faction or raceFactions[raceID] == 'Neutral' then
       tbl[raceID] = C_CreatureInfo.GetRaceInfo(raceID).clientFileString end
        raceID = raceID + 1
    end

    return tbl
end
function ds:invalidZones()
    return {
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
end
function ds:optionDefaults()
    return {
        profile = {
            minimap = { hide = false, },
        },
        global = {
            showIcon = true,
            showMsg = false,
            showMenu = true,
            scanTime = '2',
            remember = true,
            rememberTime = '7',
            msgInviteDesc = '',
            msgInvite = '',
        }
    }
end
function ds:saveOptions()
    local p,g = ns.db.profile, ns.db.global

	g.showMenu = g.showMenu or true
	g.showMsg = g.showMsg or false
	g.autoScanTime = g.autoScanTime or SCAN_WAIT_TIME
	g.rememberPlayers = g.rememberPlayers or true
	g.rememberTime = g.rememberTime or 7

	local clubID = C_Club.GetGuildClubId() or nil
	local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
	if club then
		local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
		p.guildInfo = {clubID = clubID, guildName = gName, guildLink = gLink }
	elseif clubID and C_Club.GetClubInfo(clubID) then
		p.guildInfo = {clubID = clubID, guildName = C_Club.GetClubInfo(clubID).name, guildLink = nil }
	end
end
ds:Init()