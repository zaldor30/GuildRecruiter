local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_CHARACTERS = 255
local bulletAccountWide = ns.code:cText('ff00ff00', '* ')
local bulletGuildWide = ns.code:cText('ffffff00', '* ')

ns.guildRecuriterSettings = {
    name = L['TITLE']..' '..GR.versionOut,
    type = 'group',
    args = {
        generalSettings = {
            name = 'GR Settings',
            type = 'group',
            order = 1,
            args = {
                genHeading1 = {
                    order = 0,
                    name = 'GR Settings',
                    type = 'header',
                },
                genNoteGuildwide = {
                    order = 1,
                    name = bulletGuildWide..L['GEN_GUILD_WIDE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                genNoteAccountwide = {
                    order = 2,
                    name = bulletAccountWide..L['GEN_ACCOUNT_WIDE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                genNote = {
                    order = 3,
                    name = ns.code:cText('FFFFFF00', L['RELOAD_AFTER_CHANGE']),
                    type = 'description',
                    fontSize = 'medium',
                },
                genHeading2 = {
                    order = 10,
                    name = '',
                    type = 'header',
                },
                genWhatsNew = {
                    order = 11,
                    name = bulletAccountWide..L['GEN_WHATS_NEW'],
                    desc = L['GEN_WHATS_NEW_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.g.showWhatsNew = val end,
                    get = function() return ns.g.showWhatsNew or false end,
                },
                genSpacer1 = {
                    order = 12,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                genTooltips = {
                    order = 13,
                    name = bulletAccountWide..L['GEN_TOOLTIPS'],
                    desc = L['GEN_TOOLTIP_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.g.showToolTips = val end,
                    get = function() return ns.g.showToolTips or false end,
                },
                genShowAppMessages = {
                    order = 14,
                    name = L['GEN_ADDON_MESSAGES'],
                    desc = L['GEN_ADDON_MESSAGES_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.showAppMsgs = val end,
                    get = function() return ns.pSettings.showAppMsgs or false end,
                },
                genSpacer2 = {
                    order = 15,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                genIgnoreESC = {
                    order = 16,
                    name = L['KEEP_ADDON_OPEN'],
                    desc = L['KEEP_ADDON_OPEN_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.keepOpen = val end,
                    get = function() return ns.pSettings.keepOpen or false end,
                },
                genMiniMap = {
                    order = 17,
                    name = L['GEN_MINIMAP'],
                    desc = L['GEN_MINIMAP_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val)
                        ns.pSettings.minimap.hide = not val
                        if not val then ns.core.minimapIcon:Hide('GR_Icon')
                        else ns.core.minimapIcon:Show('GR_Icon') end
                    end,
                    get = function() return not ns.pSettings.minimap.hide end,
                },
                genHeading3 = {
                    order = 20,
                    name = L['INVITE_SCAN_SETTINGS'],
                    type = 'header',
                },
                genAutoSync = {
                    order = 21,
                    name = L['AUTO_SYNC'],
                    desc = L['AUTO_SYNC_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.enableAutoSync = val end,
                    get = function() return ns.pSettings.enableAutoSync or false end,
                },
                genSpacer3 = {
                    order = 22,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                genShowWhispers = {
                    order = 23,
                    name = L['SHOW_WHISPERS'],
                    desc = L['SHOW_WHISPERS_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.showWhispers = val end,
                    get = function() return ns.pSettings.showWhispers or false end,
                },
                genContextMenu = {
                    order = 24,
                    name = L['GEN_CONTEXT'],
                    desc = L['GEN_CONTEXT_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.showContextMenu = val end,
                    get = function() return ns.pSettings.showContextMenu or false end,
                },
                genScanInterval = {
                    order = 25,
                    name = bulletAccountWide..L['SCAN_WAIT_TIME'],
                    desc = L['SCAN_WAIT_TIME_DESC'],
                    type = 'input',
                    width = 1,
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then ns.g.scanWaitTime = tonumber(val)
                        else return tostring(ns.g.scanWaitTime) end
                    end,
                    get = function()
                        ns.g.scanWaitTime = ns.g.scanWaitTime and ns.g.scanWaitTime or 6
                        return tostring(ns.g.scanWaitTime)
                    end,
                },
                genHeading4 = {
                    order = 30,
                    name = L['KEYBINDING_HEADER'],
                    type = 'header',
                },
                genKeybindingInvite = {
                    order = 31,
                    name = bulletAccountWide..L['KEYBINDING_INVITE'],
                    desc = L['KEYBINDING_INVITE_DESC'],
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.g.keybindings.invite = nil
                        elseif val and val == ns.g.keybindings.invite then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.g.keybindings.invite = val end
                    end,
                    get = function() return ns.g.keybindings.invite end,
                },
                genSpacer4 = {
                    order = 32,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                genKeybindingScan = {
                    order = 33,
                    name = bulletAccountWide..L['KEYBINDING_SCAN'],
                    desc = L['KEYBINDING_SCAN_DESC'],
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.g.keybindings.scan = nil
                        elseif val and val == ns.g.keybindings.scan then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.g.keybindings.scan = val end
                    end,
                    get = function() return ns.g.keybindings.scan end,
                },
                genHeading5 = {
                    order = 90,
                    name = 'Debug Settings (Used for testing)',
                    type = 'header',
                },
                genShowDebug = {
                    order = 91,
                    name = 'Put in debug mode',
                    desc = 'This can cause issue and lead to more chat messages.  Leave disabled.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.debugMode = val end,
                    get = function() return ns.pSettings.debugMode end,
                },
            }
        },
        blankHeader1 = {
            order = 10,
            name = '',
            type = 'group',
            args = {}
        },
        gmSettings = {
            name = L['GM_SETTINGS'],
            type = 'group',
            order = 11,
            hidden = function() return not ns.core.hasGM end,
            args = {
            }
        },
        gmInviteMessageList = {
            name = L['GM_INVITE'],
            type = 'group',
            order = 12,
            hidden = function() return not ns.core.hasGM end,
            args = {
            }
        },
        playerInviteSettings = {
            name = L['INVITE_SETTINGS'],
            type = 'group',
            order = 11,
            hidden = function() return ns.core.hasGM end,
            args = {
            }
        },
        invInviteMessageList = {
            name = L['INVITE_MESSAGES'],
            type = 'group',
            order = 12,
            hidden = function() return ns.core.hasGM end,
            args = {
            }
        },
        blankHeader3 = {
            order = 20,
            name = '',
            type = 'group',
            args = {}
        },
        antiSpam = {
            name = L['ANTI_SPAM'],
            type = 'group',
            order = 21,
            args = {
            }
        },
        blackList = {
            name = L['BLACK_LIST'],
            type = 'group',
            order = 22,
            args = {
            }
        },
        zoneList = {
            name = L['INVALID_ZONE'],
            type = 'group',
            order = 23,
            args = {
            }
        },
        blankHeader4 = {
            type = 'group',
            name = '',
            order = 90,
            args = {}
        },
        about = {
            type = 'group',
            name = L['ABOUT']..' '..L['TITLE'],
            order = 91,
            args = {
                aboutDesc1 = {
                    order = 0,
                    name = L['TITLE'],
                    type = 'description',
                    image = GR.icon,
                    imageWidth = 32,
                    imageHeight = 32,
                    fontSize = 'medium',
                },
                aboutDesc2 = {
                    order = 1,
                    name = L['ABOUT_LINE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                aboutHeader1 = {
                    order = 2,
                    name = L['ABOUT_DOC_LINKS'],
                    type = 'header',
                },
                aboutLink1 = {
                    order = 3,
                    name = 'CurseForge',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://www.curseforge.com/wow/addons/guild-recruiter') end,
                    get = function() return 'https://www.curseforge.com/wow/addons/guild-recruiter' end,
                },
                aboutLink2 = {
                    order = 4,
                    name = L['GITHUB_LINK'],
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://github.com/zaldor30/GuildRecruiter') end,
                    get = function() return 'https://github.com/zaldor30/GuildRecruiter' end,
                },
                aboutLink3 = {
                    order = 5,
                    name = L['ABOUT_DISCORD_LINK'],
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://discord.gg/ZtS6Q2sKRH') end,
                    get = function() return 'https://discord.gg/ZtS6Q2sKRH' end,
                },
                aboutHeader2 = {
                    order = 6,
                    name = string.format(L['SUPPORT_LINKS'], L['TITLE']),
                    type = 'header',
                },
                aboutLink4 = {
                    order = 7,
                    name = 'Patreon Page',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://www.patreon.com/AlwaysBeConvoking') end,
                    get = function() return 'https://www.patreon.com/AlwaysBeConvoking' end,
                },
                aboutLink5 = {
                    order = 8,
                    name = 'Buy Me a Coffee',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://bmc.link/alwaysbeconvoking') end,
                    get = function() return 'https://bmc.link/alwaysbeconvoking' end,
                },
            }
        },
    },
}