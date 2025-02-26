local addonName, ns = ... -- Namespace (myAddon, namespace)

ns.ICON_PATH = 'Interface\\AddOns\\'..addonName..'\\Images\\'

GR.commPrefix = 'GRSync'
GR.dbVersion = 4

GR.debug = false
GR.isTesting = false -- Used for testing purposes (invite)
GR.testingPlayerName = 'Monkstrife'
GR.enableFilter = false
GR.isPreRelease = false
GR.preReleaseType = 'Beta'
GR.versionOut = '(v'..GR.version..(GR.isPreRelease and ' '..GR.preReleaseType or '')..')'

C_ChatInfo.RegisterAddonMessagePrefix(GR.commPrefix)

-- Default Colors
ns.COLOR_GM = 'FFAF640C'
ns.COLOR_DEBUG = 'FFD845D8'
ns.COLOR_ERROR = 'FFFF0000'
ns.COLOR_SYSTEM = 'FFFFFF40'
ns.COLOR_DEFAULT = 'FF3EB9D8' -- Guild Recruiter Color

-- Icons
ns.GR_ICON = ns.ICON_PATH..'GR_Icon'
ns.BUTTON_LOCKED = ns.ICON_PATH..'GR_Locked'
ns.BUTTON_UNLOCKED = ns.ICON_PATH..'GR_Unlocked'
ns.BUTTON_ABOUT = ns.ICON_PATH..'GR_About'
ns.BUTTON_BACK = ns.ICON_PATH..'GR_Back'
ns.BUTTON_BLACKLIST = ns.ICON_PATH..'GR_Blacklist'
ns.BUTTON_FILTER = ns.ICON_PATH..'GR_Filter'
ns.BUTTON_FILTER_COLOR = ns.ICON_PATH..'GR_FilterColor'
ns.BUTTON_COMPACT = ns.ICON_PATH..'GR_Compact'
ns.BUTTON_EXPAND = ns.ICON_PATH..'GR_Expand'
ns.BUTTON_EXIT = ns.ICON_PATH..'GR_Exit'
ns.BUTTON_EXIT_EMPTY = ns.ICON_PATH..'GR_ExitEmpty'
ns.BUTTON_NEW = ns.ICON_PATH..'GR_New'
ns.BUTTON_RESET = ns.ICON_PATH..'GR_Reset'
ns.BUTTON_STATS = ns.ICON_PATH..'GR_Stats'
ns.BUTTON_SYNC_ON = ns.ICON_PATH..'GR_SyncOn'
ns.BUTTON_SYNC = ns.ICON_PATH..'GR_Sync'
ns.BUTTON_SETTINGS = ns.ICON_PATH..'GR_Settings'

-- Global Variables
ns.PLAYER_PROFILE = UnitName('player')..'-'..GetRealmName()
ns.SECONDS_IN_A_DAY = 86400
ns.MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()

-- Highlight Images
ns.BLUE_HIGHLIGHT = 'bags-glow-heirloom'
ns.BLUE_LONG_HIGHLIGHT = 'communitiesfinder_card_highlight'

-- Font Globals
ns.ARIAL_FONT = 'Fonts\\ARIAN.ttf'
ns.SKURRI_FONT = 'Fonts\\SKURRI.ttf'
ns.DEFAULT_FONT = 'Fonts\\FRIZQT__.ttf'
ns.MORPHEUS_FONT = 'Fonts\\MORPHEUS.ttf'
ns.DEFAULT_FONT_SIZE = 12

-- Enumerations
ns.InviteFormat = {
    MESSAGE_ONLY = 1,
    GUILD_INVITE_ONLY = 2,
    GUILD_INVITE_AND_MESSAGE = 3,
    MESSAGE_ONLY_IF_INVITE_DECLINED = 4
}

--* Link Constants
ns.GITHUB = 'https://github.com/zaldor30/GuildRecruiter'
ns.DISCORD = 'https://discord.gg/ZtS6Q2sKRH'
ns.CURSE_FORGE = 'https://www.curseforge.com/wow/addons/guild-recruiter'

ns.PATREON = 'https://www.patreon.com/AlwaysBeConvoking'
ns.BUY_ME_COFFEE = 'https://bmc.link/alwaysbeconvoking'
