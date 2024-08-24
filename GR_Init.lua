local _, ns = ... -- Namespace (myaddon, namespace)
ns = {}

ICON_PATH = 'Interface\\AddOns\\GuildRecruiter\\Images\\'

GR = LibStub('AceAddon-3.0'):NewAddon('GuildRecruiter', 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0', 'AceComm-3.0')
GR.debug = false
GR.isTest = false
GR.testLevel = nil
GR.author  = C_AddOns.GetAddOnMetadata('GuildRecruiter', 'Author')
GR.version = C_AddOns.GetAddOnMetadata('GuildRecruiter', 'Version')
GR.dbVersion = '3.0'

-- Icons
GR.icon = ICON_PATH..'GR_Icon.tga'
BUTTON_LOCKED = ICON_PATH..'GR_Locked'
BUTTON_UNLOCKED = ICON_PATH..'GR_Unlocked'

-- Global Variables
PLAYER_PROFILE = UnitName('player')..'-'..GetRealmName()
SECONDS_IN_A_DAY = 86400
MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()

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

-- Frame Stratas
BACKGROUND_STRATA = 'BACKGROUND'
LOW_STRATA = 'LOW'
MEDIUM_STRATA = 'MEDIUM'
HIGH_STRATA = 'HIGH'
DIALOG_STRATA = 'DIALOG'
TOOLTIP_STRATA = 'TOOLTIP'
DEFAULT_STRATA = BACKGROUND_STRATA

-- Default Colors
GRColor = 'FF3EB9D8' -- Guild Recruiter Color
GM_DESC_COLOR = 'FFAF640C'

-- Highlgiht Images
BLUE_HIGHLIGHT = 'bags-glow-heirloom'
BLUE_LONG_HIGHLIGHT = 'communitiesfinder_card_highlight'

-- Font Globals
ARIAL_FONT = 'Fonts\\ARIAN.ttf'
SKURRI_FONT = 'Fonts\\SKURRI.ttf'
DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
MORPHEUS_FONT = 'Fonts\\MORPHEUS.ttf'
DEFAULT_FONT_SIZE = 12