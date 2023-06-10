-- Namespace Setup
local _, ns = ... -- Namespace (myaddon, namespace)
ns = {}

-- Application Initialization
-- Uses: AceConsole-3.0, AceEvent-3.0, AceComm-3.0, AceHook-3.0, AceSerializer-3.0
GRADDON = LibStub('AceAddon-3.0'):NewAddon('GuildRecruiter', 'AceConsole-3.0', 'AceEvent-3.0', 'AceComm-3.0', 'AceHook-3.0', 'AceSerializer-3.0')
GRADDON.playerFaction = UnitFactionGroup('player') == 'Horde' and 2 or 1
GRADDON.version = GetAddOnMetadata('GuildRecruiter', 'Version')
GRADDON.realmID = GetRealmID()
GRADDON.whoQuery = {}
GRADDON.classInfo = {
	WARRIOR = {fClass = 'Warrior', color = 'ffc79c6e'},
	PALADIN = {fClass = 'Warrior', color = 'fff58cba'},
	HUNTER = {fClass = 'Warrior', color = 'ffabd473'},
	ROGUE = {fClass = 'Warrior', color = 'fffff569'},
	PRIEST = {fClass = 'Warrior', color = 'ffffffff'},
	DEATHKNIGHT = {fClass = 'Warrior', color = 'ffc41f3b'},
	SHAMAN = {fClass = 'Warrior', color = 'ff0070de'},
	MAGE = {fClass = 'Warrior', color = 'ff3fc7eb'},
	WARLOCK = {fClass = 'Warrior', color = 'ff8788ee'},
	MONK = {fClass = 'Warrior', color = 'ff00ff96'},
	DRUID = {fClass = 'Warrior', color = 'ffff7d0a'},
	DEMONHUNTER = {fClass = 'Warrior', color = 'ffa330c9'},
	EVOKER = {fClass = 'Warrior', color = 'ff308a77'},
}
GRADDON.addonPrefix = 'GuildRecruiter'

GuildRecruiter = {}
_G['GuildRecruiter'] = GuildRecruiter

-- Constant Variables
SCAN_WAIT_TIME = 4
PLAYER_PROFILE = UnitName('player')..' - '..GetRealmName()
MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()

DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
ARIAL_FONT = 'Fonts\\ARIAN.ttf'
MORPHEUS_FONT = 'Fonts\\MORPHEUS.ttf'
SKURRI_FONT = 'Fonts\\SKURRI.ttf'
MORRIS_FONT = 'Fonts\\MORRIS__.ttf'
FRIENDS_FONT = 'Fonts\\FRIENDS.ttf'