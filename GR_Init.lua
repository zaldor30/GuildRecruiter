local addonName, ns = ... -- Namespace (myaddon, namespace)
ns = {}

-- Set version flags early
ns.classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or false
ns.cata = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC or false
ns.retail = not ns.classic and not ns.cata

GR = LibStub('AceAddon-3.0'):NewAddon(addonName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', "AceHook-3.0")
GR.title = C_AddOns.GetAddOnMetadata(addonName, 'Title')
GR.author  = C_AddOns.GetAddOnMetadata(addonName, 'Author')
GR.version = C_AddOns.GetAddOnMetadata(addonName, 'Version')
GR.db = addonName == 'GuildRecruiter' and 'GuildRecruiterDB' or 'devGuildRecruiterDB'
GR.ICON_PATH = 'Interface\\AddOns\\'..addonName..'\\Images\\'
