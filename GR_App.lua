local _, ns = ... -- Namespace (myaddon, namespace)
ICON_PATH = 'Interface\\AddOns\\GuildRecruiter\\Images\\'
ns = {}

-- Application Initialization
-- Uses: AceConsole-3.0, AceEvent-3.0, AceComm-3.0, AceHook-3.0, AceSerializer-3.0

GRADDON = LibStub('AceAddon-3.0'):NewAddon('GuildRecruiter', 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0', 'AceComm-3.0', 'AceSerializer-3.0')
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

GRADDON.debug = false
GRADDON.system = nil
GRADDON.title = L['TITLE']
GRADDON.version = GetAddOnMetadata('GuildRecruiter', 'Version')
GRADDON.author = GetAddOnMetadata('GuildRecruiter', 'Author')
GRADDON.icon = ICON_PATH..'GR_Icon.tga'
GRADDON.realmID = GetRealmID()
GRADDON.prefix = 'GuildRecruiter'
GRADDON.clubID = nil
GRADDON.classInfo = {
	['WARRIOR'] = {fClass = 'Warrior', color = 'ffc79c6e', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Warrior'},
	['PALADIN'] = {fClass = 'Paladin', color = 'fff58cba', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Paladin'},
	['HUNTER'] = {fClass = 'Hunter', color = 'ffabd473', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Hunter'},
	['ROGUE'] = {fClass = 'Rogue', color = 'fffff569', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Rogue'},
	['PRIEST'] = {fClass = 'Priest', color = 'ffffffff', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Priest'},
	['DEATHKNIGHT'] = {fClass = 'Death Knight', color = 'ffc41f3b', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-DeathKnight'},
	['SHAMAN'] = {fClass = 'Shaman', color = 'ff0070de', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Shaman'},
	['MAGE'] = {fClass = 'Mage', color = 'ff3fc7eb', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Mage'},
	['WARLOCK'] = {fClass = 'Warlock', color = 'ff8788ee', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Warlock'},
	['MONK'] = {fClass = 'Monk', color = 'ff00ff96', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Monk'},
	['DRUID'] = {fClass = 'Druid', color = 'ffff7d0a', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Druid'},
	['DEMONHUNTER'] = {fClass = 'Demon Hunter', color = 'ffa330c9', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-DemonHunter'},
	['EVOKER'] = {fClass = 'Evoker', color = 'ff308a77', icon = 'UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Evoker'},
}


GM_DESC_COLOR = 'FFAF640C'

-- Backdrop Templates
DEFAULT_BORDER = 'Interface\\Tooltips\\UI-Tooltip-Border'
BLANK_BACKGROUND = 'Interface\\Buttons\\WHITE8x8'
DIALOGUE_BACKGROUND = 'Interface\\DialogFrame\\UI-DialogBox-Background'
function BackdropTemplate(bgImage, edgeImage, tile, tileSize, edgeSize, insets)
	tile = tile == 'NO_TILE' and false or true

	return {
		bgFile = bgImage or DIALOGUE_BACKGROUND,
		edgeFile = edgeImage or DEFAULT_BORDER,
		tile = true,
		tileSize = tileSize or 16,
		edgeSize = edgeSize or 16,
		insets = insets or { left = 3, right = 3, top = 3, bottom = 3 }
	}
end

-- Different Stratas
BUTTON_STRATA = 'LOW'
DEFAULT_STRATA = 'BACKGROUND'

-- Constant Variables
DEFAULT_GUILD_WELCOME = 'Welcome PLAYERNAME to GUILDNAME!'
GR_VERSION_INFO = GRADDON.title..' v'..GRADDON.version
SCAN_WAIT_TIME = 3
PLAYER_PROFILE = UnitName('player')..' - '..GetRealmName()
MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()
SECONDS_IN_A_DAY = 86400

DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
ARIAL_FONT = 'Fonts\\ARIAN.ttf'
MORPHEUS_FONT = 'Fonts\\MORPHEUS.ttf'
SKURRI_FONT = 'Fonts\\SKURRI.ttf'
DEFAULT_FONT_SIZE = 12

-- Icons
BUTTON_LOCKED = ICON_PATH..'GR_Locked'
BUTTON_UNLOCKED = ICON_PATH..'GR_Unlocked'

-- Highlgiht Icons
BLUE_HIGHLIGHT = 'bags-glow-heirloom'
BLUE_LONG_HIGHLIGHT = 'communitiesfinder_card_highlight'