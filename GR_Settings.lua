local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local icon = LibStub('LibDBIcon-1.0')

local bulletAccountWide = ns.code:cText('ff00ff00', '* ')

ns.addonSettings = {
    name = L['TITLE']..' ('..GR.version..(GR.isBeta and ' Beta)' or ')'),
    type = 'group',
    args = {
        grSettings = { -- Guild Recruiter Settings
            name = 'GR Settings',
            type = 'group',
            order = 0,
            args = {
                genHeading1 = {
                    order = 0,
                    name = L['General Settings'],
                    type = 'header',
                },
                genTooltips = {
                    order = 1,
                    name = bulletAccountWide..L['GEN_TOOLTIPS'],
                    desc = L['GEN_TOOLTIP_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gSettings.showToolTips = val end,
                    get = function() return ns.gSettings.showToolTips end,
                },
                genMinimap = {
                    order = 2,
                    name = bulletAccountWide..L['GEN_MINIMAP'],
                    desc = L['GEN_MINIMAP_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.minimap = val end,
                    get = function() return ns.pSettings.minimap end,
                },
                genWhatsNew = {
                    order = 3,
                    name = bulletAccountWide..L['GEN_WHATS_NEW'],
                    desc = L['GEN_WHATS_NEW_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gSettings.showWhatsNew = val end,
                    get = function() return type(ns.gSettings.showWhatsNew) == 'boolean' and ns.db.global.showWhatsNew or true end,
                },
                genContext = {
                    order = 4,
                    name = L['GEN_CONTEXT'],
                    desc = L['GEN_CONTEXT_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.showContextMenu = val end,
                    get = function() return ns.pSettings.showContextMenu end,
                },
                genAddonMessages = {
                    order = 6,
                    name = L['GEN_ADDON_MESSAGES'],
                    desc = L['GEN_ADDON_MESSAGES_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.showAppMsgs = val end,
                    get = function() return ns.pSettings.showAppMsgs end,
                },
                genDisableAutoSync = {
                    order = 7,
                    name = 'Disable Auto Sync',
                    desc = 'Disables auto sync with guild members.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.debugAutoSync = val end,
                    get = function() return ns.pSettings.debugAutoSync end,
                },
                genHeader3 = {
                    name = L['KEYBINDING_HEADER'],
                    type = 'header',
                    order = 20
                },
                genKeybindingInvite = {
                    order = 21,
                    name = bulletAccountWide..L['KEYBINDING_INVITE'],
                    desc = L['KEYBINDING_INVITE_DESC'],
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.g.keybindInvite = nil
                        elseif val and val == ns.g.keybindScan then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.g.keybindInvite = val end
                    end,
                    get = function() return ns.g.keybindInvite end,
                },
                genSpacer = {
                    order = 22,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                genKeybindingScan = {
                    order = 23,
                    name = bulletAccountWide..L['KEYBINDING_SCAN'],
                    desc = L['KEYBINDING_SCAN_DESC'],
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.g.keybindScan = nil
                        elseif val and val == ns.g.keybindInvite then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.g.keybindScan = val end
                    end,
                    get = function() return ns.g.keybindScan end,
                },
                genNoteKeybind = {
                    order = 24,
                    name = ns.code:cText('FF00FF00', L['KEY_BINDING_NOTE']),
                    type = 'description',
                    fontSize = 'medium',
                },
                genHeadingAW = {
                    order = 100,
                    name = bulletAccountWide..L['GEN_ACCOUNT_WIDE'],
                    type = 'header',
                },
                genSpacer2 = {
                    order = 101,
                    name = ' ',
                    type = 'description',
                },
                genHeading3 = {
                    order = 102,
                    name = 'Debug Settings (Used for testing)',
                    type = 'header',
                },
                genShowDebug = {
                    order = 103,
                    name = 'Show Debug Messages',
                    desc = 'Show/Hide debug messages.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.debugMode = val end,
                    get = function() return ns.pSettings.debugMode end,
                },
            }
        }
    }
}