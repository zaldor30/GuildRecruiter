local addonName, ns = ... -- Namespace (myaddon, namespace)

ICON_PATH = 'Interface\\AddOns\\'..addonName..'\\Images\\'

GR.commPrefix = 'GRSync'
GR.dbVersion = 4.0

GR.debug = false
GR.isTesting = true
GR.isPreRelease = true
GR.preReleaseType = 'Alpha'
GR.versionOut = '(v'..GR.version..(GR.isPreRelease and ' '..GR.preReleaseType or '')..')'

C_ChatInfo.RegisterAddonMessagePrefix(GR.commPrefix)

-- Default Colors
ns.COLOR_GM = 'FFAF640C'
ns.COLOR_DEBUG = 'FFD845D8'
ns.COLOR_ERROR = 'FFFF0000'
ns.COLOR_DEFAULT = 'FF3EB9D8' -- Guild Recruiter Color

-- Icons
ns.GR_ICON = ICON_PATH..'GR_Icon'
ns.BUTTON_LOCKED = ICON_PATH..'GR_Locked'
ns.BUTTON_UNLOCKED = ICON_PATH..'GR_Unlocked'
ns.BUTTON_ABOUT = ICON_PATH..'GR_About'
ns.BUTTON_BACK = ICON_PATH..'GR_Back'
ns.BUTTON_BLACKLIST = ICON_PATH..'GR_Blacklist'
ns.BUTTON_COMPACT = ICON_PATH..'GR_Compact'
ns.BUTTONS_EXPAND = ICON_PATH..'GR_Expand'
ns.BUTTON_EXIT = ICON_PATH..'GR_Exit'
ns.BUTTON_NEW = ICON_PATH..'GR_New'
ns.BUTTON_RESET = ICON_PATH..'GR_Reset'
ns.BUTTON_STATS = ICON_PATH..'GR_Stats'
ns.BUTTON_SYNC_ON = ICON_PATH..'GR_SyncOn'
ns.BUTTON_SYNC_OFF = ICON_PATH..'GR_SyncOff'

-- Global Variables
ns.PLAYER_PROFILE = UnitName('player')..'-'..GetRealmName()
ns.SECONDS_IN_A_DAY = 86400
ns.MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()

-- Highlgiht Images
ns.BLUE_HIGHLIGHT = 'bags-glow-heirloom'
ns.BLUE_LONG_HIGHLIGHT = 'communitiesfinder_card_highlight'

-- Font Globals
ns.ARIAL_FONT = 'Fonts\\ARIAN.ttf'
ns.SKURRI_FONT = 'Fonts\\SKURRI.ttf'
ns.DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
ns.MORPHEUS_FONT = 'Fonts\\MORPHEUS.ttf'
ns.DEFAULT_FONT_SIZE = 12