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

    self.tblAllMessages = {}
end
function ds:WhatsNew()
    local msg = ns.code:cText('FFFFFF00', "What's new in v2.0.0?").."\n \nI have completely rewrote the whole addon.  Why did I do this?  Because I hated the previous interface and while I reused most of the code, I went through it as I rebuilt the interface.  Still needs more tweaking, but is much better than before.\n \nI have added some about screens which have links to support options, I would appreciate feedback and any issues you may encounter.\n \n"..ns.code:cText('FFFFFF00', "Changes in 2.0:").."\nYou can now move the screen and it will retain its new position.\nMajorly overhauled the database.\nOne account can be in multiple guilds with this addon.\nDid a lot of work in the settings.\nLots of code fixes and clean up.\n \nYou will need to reload your interface, use \\rl or click the button bellow."

    return msg
end
MATCH_VERSION = '2.0.4'
function ds:LatestUpdates()
    local msg = ns.code:cText('FFFFFF00', "What's new in v2.0.3?").."\n \n"
    msg = msg..'This will actually incorporate the changes from 2.0.2 as well.\n \n'
    msg = msg..ns.code:cText('FFFFFF00', "Changes in 2.0.3:").."\n"
    msg = msg..'* Fixed issue where accepted invites were double couting.\n \n'
    msg = msg..ns.code:cText('FFFFFF00', "Changes in 2.0.2:").."\n"
    msg = msg..'* Fixed a bug where the addon would not load if you were not in a guild.\n'
    msg = msg..'* Cleaned up verbose messaging when logging in with a character that is not in a guild.\n'
    msg = msg..'* Fixed issue for info screen showing everytime an update occurs.\n'
    msg = msg..'* Changed sync to verify database version an not app version.\n'
    msg = msg..'* Created a reminder to have other officers update their addon.\n'
    msg = msg..'* You can turn off seeing new changes in settings.'

    return msg
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
function ds:AllMessages()
    local dbMessages = ns.db.messages.messageList or nil
    local dbGMessages = ns.dbGlobal.guildInfo.messageList or {}

    -- GM messages then personal
    local tbl = {}
    for _,r in pairs(dbGMessages) do
        r.gmMessage = true
        tinsert(tbl, r)
    end
    for _,r in pairs(dbMessages or {}) do tinsert(tbl, r) end
    self.tblAllMessages = tbl
end
ds:Init()