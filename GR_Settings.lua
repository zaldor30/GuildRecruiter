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
                    name = L['AUTO_SYNC'],
                    desc = L['AUTO_SYNC_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.debugAutoSync = val end,
                    get = function() return ns.pSettings.debugAutoSync end,
                },
                invShowInvite = {
                    order = 8,
                    name = L['SHOW_WHISPERS'],
                    desc = L['SHOW_WHISPERS_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.showWhispers = val end,
                    get = function() return ns.pSettings.showWhispers end,
                },
                invScanInterval = {
                    order = 9,
                    name = bulletAccountWide..L['SCAN_WAIT_TIME'],
                    desc = L['SCAN_WAIT_TIME_DESC'],
                    type = 'input',
                    width = 'full',
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then ns.gSettings.scanWaitTime = tonumber(val)
                        else return tostring(ns.gSettings.scanWaitTime) end
                    end,
                    get = function() return tostring(ns.gSettings.scanWaitTime) end,
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
        },
        blankHeader1 = {
            order = 1,
            name = ' ',
            type = 'group',
            args = {}
        },
        gmSettings = {
            name = L['GM_SETTINGS'],
            type = 'group',
            order = 2,
            args = {
                invHeader1 = {
                    name = L['GM_SETTINGS'],
                    type = 'header',
                    order = 0,
                },
                gmSettingsDesc = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', L['GM_SETTINGS_DESC']),
                    type = 'description',
                    fontSize = 'medium',
                },
                genSpacer = {
                    order = 2,
                    name = ' ',
                    type = 'description',
                },
                invAntiSpamEnable = {
                    order = 3,
                    name = bulletAccountWide..L['ENABLE_ANTI_SPAM'],
                    desc = L['ENABLE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1.5,
                    disabled = function() return not ns.gmSettings.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.antiSpam = val end,
                    get = function() return ns.gmSettings.antiSpam end,
                },
                invAntiSpamInterval = {
                    order = 4,
                    name = bulletAccountWide..L['ANTI_SPAM_DAYS'],
                    desc = L['ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    disabled = function() return not ns.gmSettings.isGuildLeader end,
                    values = function()
                        return {
                            [7] = '7 days',
                            [14] = '14 days',
                            [30] = '30 days (1 month)',
                            [190] = '190 days (3 months)',
                            [380] = '380 days (6 months)',
                        }
                    end,
                    set = function(_, val) ns.gmSettings.antiSpamDays = tonumber(val) end,
                    get = function() return ns.gmSettings.antiSpamDays or 7 end,
                },
                invSendWelcome = {
                    order = 10,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return not ns.gmSettings.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.sendWelcome = val end,
                    get = function() return ns.gmSettings.sendWelcome end,
                },
                invWelcomeMessage = {
                    order = 11,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return not ns.gmSettings.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.welcomeMessage = val end,
                    get = function() return ns.gmSettings.welcomeMessage end,
                },
                invSendGreeting = {
                    order = 12,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return not ns.gmSettings.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.sendWhisperGreeting = val end,
                    get = function() return ns.gmSettings.sendWhisperGreeting end,
                },
                invGreetingMessage = {
                    order = 13,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return not ns.gmSettings.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.greetingMessage = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return ns.gmSettings.greetingMessage end,
                },
            }
        },
        gmMessageList = {
            order = 3,
            name = L['GM_INVITE'],
            type = 'group',
            hidden = function() return not ns.gmSettings.isGuildLeader end,
            args = {
            }
        },
        blankHeader2 = {
            order = 4,
            name = ' ',
            type = 'group',
            hidden = function() return ns.gmSettings.sendGuildGreeting and ns.gmSettings.sendWhisperGreeting and ns.gmSettings.antiSpam end,
            args = {}
        },
        inviteSettings = {
            order = 5,
            name = L['INVITE_SETTINGS'],
            type = 'group',
            hidden = function() return ns.gmSettings.sendGuildGreeting and ns.gmSettings.sendWhisperGreeting and ns.gmSettings.antiSpam end,
            args = {
                invHeader1 = {
                    name = L['INVITE_SETTINGS'],
                    type = 'header',
                    order = 0,
                },
                invAntiSpamEnable = {
                    order = 6,
                    name = bulletAccountWide..L['ENABLE_ANTI_SPAM'],
                    desc = L['ENABLE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1.5,
                    disabled = function() return ns.gmSettings.antiSpam end,
                    set = function(_, val) ns.gSettings.antiSpam = val end,
                    get = function()
                        if ns.gSettings.antiSpam then return ns.gSettings.antiSpam
                        else return ns.gSettings.antiSpam end
                    end,
                },
                invAntiSpamInterval = {
                    order = 7,
                    name = bulletAccountWide..L['ANTI_SPAM_DAYS'],
                    desc = L['ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    disabled = function() return ns.gmSettings.antiSpam end,
                    values = function()
                        return {
                            [7] = '7 days',
                            [14] = '14 days',
                            [30] = '30 days (1 month)',
                            [190] = '190 days (3 months)',
                            [380] = '380 days (6 months)',
                        }
                    end,
                    set = function(_, val) ns.gSettings.antiSpamDays = tonumber(val) end,
                    get = function()
                        if ns.gSettings.antiSpam then return ns.gSettings.antiSpamDays
                        else return ns.gSettings.antiSpamDays or 7 end
                    end,
                },
                invSendWelcome = {
                    order = 10,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendGuildGreeting end,
                    set = function(_, val) ns.gSettings.sendWelcome = val end,
                    get = function()
                        if ns.gmSettings.sendGuildGreeting then return ns.gmSettings.sendGuildGreeting
                        else return ns.gSettings.sendGuildGreeting end
                    end,
                },
                invWelcomeMessage = {
                    order = 11,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendGuildGreeting end,
                    set = function(_, val) ns.gSettings.welcomeMessage = val end,
                    get = function()
                        if ns.gmSettings.welcomeMessage then return ns.gmSettings.welcomeMessage
                        else return ns.gSettings.welcomeMessage end
                    end,
                },
                invSendGreeting = {
                    order = 12,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendWhisperGreeting end,
                    set = function(_, val) ns.gSettings.sendGreeting = val end,
                    get = function()
                        if ns.gmSettings.sendGreeting then return ns.gmSettings.sendGreeting
                        else return ns.gSettings.sendGreeting end
                    end,
                },
                invGreetingMessage = {
                    order = 13,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendGreeting end,
                    set = function(_, val) ns.gSettings.greetingMessage = ns.code:capitalKeyWord(val:trim()) end,
                    get = function()
                        if ns.gmSettings.sendGreeting and ns.gmSettings.greetingMessage then return ns.gmSettings.greetingMessage
                        else return ns.gSettings.greetingMessage end
                    end,
                },
            }
        },
    }
}