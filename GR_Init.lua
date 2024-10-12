local addonName, ns = ... -- Namespace (myaddon, namespace)
ns = {}

GR = LibStub('AceAddon-3.0'):NewAddon(addonName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
GR.title = C_AddOns.GetAddOnMetadata(addonName, 'Title')
GR.author  = C_AddOns.GetAddOnMetadata(addonName, 'Author')
GR.version = C_AddOns.GetAddOnMetadata(addonName, 'Version')
GR.ICON_PATH = 'Interface\\AddOns\\'..addonName..'\\Images\\'