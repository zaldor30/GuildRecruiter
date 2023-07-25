local _, ns = ... -- Namespace (myaddon, namespace)
ICON_PATH = 'Interface\\AddOns\\GuildRecruiter\\Images\\'
ns = {}

-- Application Initialization
-- Uses: AceConsole-3.0, AceEvent-3.0, AceComm-3.0, AceHook-3.0, AceSerializer-3.0
GRADDON = LibStub('AceAddon-3.0'):NewAddon('GuildRecruiter', 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0', 'AceComm-3.0', 'AceSerializer-3.0')
GRADDON.title = GetAddOnMetadata('GuildRecruiter', 'Title')
GRADDON.version = GetAddOnMetadata('GuildRecruiter', 'Version')
GRADDON.author = GetAddOnMetadata('GuildRecruiter', 'Author')
GRADDON.icon = ICON_PATH..'GR_Icon'
GRADDON.realmID = GetRealmID()
GRADDON.prefix = 'GuildRecruiter'
GRADDON.clubID = nil
GRADDON.classInfo = {
	WARRIOR = {fClass = 'Warrior', color = 'ffc79c6e', icon = ICON_PATH..'ClassIcon_Warrior'},
	PALADIN = {fClass = 'Paladin', color = 'fff58cba', icon = ICON_PATH..'ClassIcon_Paladin'},
	HUNTER = {fClass = 'Hunter', color = 'ffabd473', icon = ICON_PATH..'ClassIcon_Hunter'},
	ROGUE = {fClass = 'Rogue', color = 'fffff569', icon = ICON_PATH..'ClassIcon_Rogue'},
	PRIEST = {fClass = 'Priest', color = 'ffffffff', icon = ICON_PATH..'ClassIcon_Priest'},
	DEATHKNIGHT = {fClass = 'Death Knight', color = 'ffc41f3b', icon = ICON_PATH..'ClassIcon_DeathKnight'},
	SHAMAN = {fClass = 'Shaman', color = 'ff0070de', icon = ICON_PATH..'ClassIcon_Saman'},
	MAGE = {fClass = 'Mage', color = 'ff3fc7eb', icon = ICON_PATH..'ClassIcon_Mage'},
	WARLOCK = {fClass = 'Warlock', color = 'ff8788ee', icon = ICON_PATH..'ClassIcon_Warlock'},
	MONK = {fClass = 'Monk', color = 'ff00ff96', icon = ICON_PATH..'ClassIcon_Monk'},
	DRUID = {fClass = 'Druid', color = 'ffff7d0a', icon = ICON_PATH..'ClassIcon_Druid'},
	DEMONHUNTER = {fClass = 'Demon Hunter', color = 'ffa330c9', icon = ICON_PATH..'ClassIcon_DemonHunter'},
	EVOKER = {fClass = 'Evoker', color = 'ff308a77', icon = ICON_PATH..'ClassIcon_Evoker'},
}

-- Different Stratas
DEFAULT_STRATA = 'BACKGROUND'
BUTTON_STRATA = 'LOW'

-- Constant Variables
DEFAULT_GUILD_WELCOME = 'Welcome PLAYERNAME to GUILDNAME!'
GR_VERSION_INFO = 'Guild Recruiter v'..GRADDON.version
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