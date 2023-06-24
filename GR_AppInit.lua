local _, ns = ... -- Namespace (myaddon, namespace)
local iconPath = 'Interface\\Icons\\'
ns = {}

-- Application Initialization
-- Uses: AceConsole-3.0, AceEvent-3.0, AceComm-3.0, AceHook-3.0, AceSerializer-3.0
GRADDON = LibStub('AceAddon-3.0'):NewAddon('GuildRecruiter', 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0', 'AceComm-3.0', 'AceSerializer-3.0')
GRADDON.version = GetAddOnMetadata('GuildRecruiter', 'Version')
GRADDON.realmID = GetRealmID()
GRADDON.prefix = 'GuildRecruiter'
GRADDON.clubID = nil
GRADDON.classInfo = {
	WARRIOR = {fClass = 'Warrior', color = 'ffc79c6e', icon = iconPath..'ClassIcon_Warrior'},
	PALADIN = {fClass = 'Paladin', color = 'fff58cba', icon = iconPath..'ClassIcon_Paladin'},
	HUNTER = {fClass = 'Hunter', color = 'ffabd473', icon = iconPath..'ClassIcon_Hunter'},
	ROGUE = {fClass = 'Rouge', color = 'fffff569', icon = iconPath..'ClassIcon_Rogue'},
	PRIEST = {fClass = 'Priest', color = 'ffffffff', icon = iconPath..'ClassIcon_Priest'},
	DEATHKNIGHT = {fClass = 'Death Knight', color = 'ffc41f3b', icon = iconPath..'ClassIcon_DeathKnight'},
	SHAMAN = {fClass = 'Shaman', color = 'ff0070de', icon = iconPath..'ClassIcon_Saman'},
	MAGE = {fClass = 'Mage', color = 'ff3fc7eb', icon = iconPath..'ClassIcon_Mage'},
	WARLOCK = {fClass = 'Warlock', color = 'ff8788ee', icon = iconPath..'ClassIcon_Warlock'},
	MONK = {fClass = 'Monk', color = 'ff00ff96', icon = iconPath..'ClassIcon_Monk'},
	DRUID = {fClass = 'Druid', color = 'ffff7d0a', icon = iconPath..'ClassIcon_Druid'},
	DEMONHUNTER = {fClass = 'Demon Hunter', color = 'ffa330c9', icon = iconPath..'ClassIcon_DemonHunter'},
	EVOKER = {fClass = 'Evoker', color = 'ff308a77', icon = iconPath..'ClassIcon_Evoker'},
}

GuildRecruiter = {}
_G['GuildRecruiter'] = GuildRecruiter

-- Constant Variables
GR_VERSION_INFO = 'Guild Recruiter v'..GRADDON.version..' (Release Candidate)'
SCAN_WAIT_TIME = 3
PLAYER_PROFILE = UnitName('player')..' - '..GetRealmName()
MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()
SECONDS_IN_A_DAY = 86400

DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
ARIAL_FONT = 'Fonts\\ARIAN.ttf'
MORPHEUS_FONT = 'Fonts\\MORPHEUS.ttf'
SKURRI_FONT = 'Fonts\\SKURRI.ttf'
MORRIS_FONT = 'Fonts\\MORRIS__.ttf'
FRIENDS_FONT = 'Fonts\\FRIENDS.ttf'
DEFAULT_FONT_SIZE = 12