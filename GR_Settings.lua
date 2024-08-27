local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local icon = LibStub('LibDBIcon-1.0')

local MAX_CHARACTERS = 255
local bulletAccountWide = ns.code:cText('ff00ff00', '* ')

--* Message Routines
local activeMessage = nil

local function newMsg()
    return {
        desc = '',
        message = '',
        gmSync = ns.core.hasGM,
    }
end
local tblMessage = newMsg()
local getMessageLength = function(msg)
    if not msg or msg == '' then return false, 0, msg end

    local gd = ns.guildInfo
    local playerNameFound = false
    local count, tMsg = 0, (msg or '')

    msg = ns.code:capitalKeyWord(msg)

    if msg:match(L['GUILDLINK']) then count = strlen(gd.guildName) + 9 end
    if msg:match(L['GUILDNAME']) then count = count + strlen(gd.guildName) + 2 end
    if msg:match(L['PLAYERNAME']) then
        playerNameFound = true
        count = count + 12
    end

    tMsg = msg:gsub('GUILDLINK', ''):gsub('GUILDNAME', ''):gsub('PLAYERNAME', '')
    return (playerNameFound or false), count + (strlen(tMsg) or 0), count, msg
end

ns.addonSettings = {
    name = L['TITLE']..' '..GR.versionOut,
    type = 'group',
    args = {
        grSettings = { -- Guild Recruiter Settings
            name = 'GR Settings',
            type = 'group',
            order = 0,
            args = {
                genHeading1 = {
                    order = 0,
                    name = L['SYSTEM_SETTINGS'],
                    type = 'header',
                },
                genNoteAccountwide = {
                    order = 1,
                    name = bulletAccountWide..L['GEN_ACCOUNT_WIDE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                genMiniMap = {
                    order = 2,
                    name = bulletAccountWide..L['GEN_MINIMAP'],
                    desc = L['GEN_MINIMAP_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val)
                        ns.pSettings.minimap.hide = not val
                        if not val then ns.core.minimapIcon:Hide('GR_Icon')
                        else ns.core.minimapIcon:Show('GR_Icon') end
                    end,
                    get = function() return not ns.pSettings.minimap.hide end,
                },
                genWhatsNew = {
                    order = 3,
                    name = bulletAccountWide..L['GEN_WHATS_NEW'],
                    desc = L['GEN_WHATS_NEW_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.global.showWhatsNew = val end,
                    get = function() return ns.global.showWhatsNew or false end,
                },
                genTooltips = {
                    order = 4,
                    name = bulletAccountWide..L['GEN_TOOLTIPS'],
                    desc = L['GEN_TOOLTIP_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gSettings.showToolTips = val end,
                    get = function() return ns.gSettings.showToolTips or false end,
                },
                genShowAppMessages = {
                    order = 5,
                    name = L['GEN_ADDON_MESSAGES'],
                    desc = L['GEN_ADDON_MESSAGES_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.showAppMsgs = val end,
                    get = function() return ns.pSettings.showAppMsgs or false end,
                },
                genIgnoreESC = {
                    order = 6,
                    name = bulletAccountWide..L['KEEP_ADDON_OPEN'],
                    desc = L['KEEP_ADDON_OPEN_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gSettings.keepOpen = val end,
                    get = function() return ns.gSettings.keepOpen or false end,
                },
                genHeading2 = {
                    order = 10,
                    name = L['INVITE_SCAN_SETTINGS'],
                    type = 'header',
                },
                genAutoSync = {
                    order = 11,
                    name = L['AUTO_SYNC'],
                    desc = L['AUTO_SYNC_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.enableAutoSync = val end,
                    get = function() return ns.pSettings.enableAutoSync or false end,
                },
                genShowWhispers = {
                    order = 12,
                    name = L['SHOW_WHISPERS'],
                    desc = L['SHOW_WHISPERS_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.showWhispers = val end,
                    get = function() return ns.pSettings.showWhispers or false end,
                },
                genContextMenu = {
                    order = 13,
                    name = L['GEN_CONTEXT'],
                    desc = L['GEN_CONTEXT_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.pSettings.showContextMenu = val end,
                    get = function() return ns.pSettings.showContextMenu or false end,
                },
                genScanInterval = {
                    order = 14,
                    name = bulletAccountWide..L['SCAN_WAIT_TIME'],
                    desc = L['SCAN_WAIT_TIME_DESC'],
                    type = 'input',
                    width = 1,
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then ns.gSettings.scanWaitTime = tonumber(val)
                        else return tostring(ns.gSettings.scanWaitTime) end
                    end,
                    get = function() return tostring(ns.gSettings.scanWaitTime) end,
                },
                genHeading3 = {
                    order = 20,
                    name = L['KEYBINDING_HEADER'],
                    type = 'header',
                },
                genKeybindingInvite = {
                    order = 21,
                    name = bulletAccountWide..L['KEYBINDING_INVITE'],
                    desc = L['KEYBINDING_INVITE_DESC'],
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.global.keybindInvite = nil
                        elseif val and val == ns.global.keybindScan then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.global.keybindInvite = val end
                    end,
                    get = function() return ns.global.keybindInvite end,
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
                        if strlen(val) == 0 or val == '' then ns.global.keybindScan = nil
                        elseif val and val == ns.global.keybindInvite then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.global.keybindScan = val end
                    end,
                    get = function() return ns.global.keybindScan end,
                },
                genNoteKeybind = {
                    order = 24,
                    name = ns.code:cText('FF00FF00', L['KEY_BINDING_NOTE']),
                    type = 'description',
                    fontSize = 'medium',
                },
                genSpacer1 = {
                    order = 90,
                    name = ' ',
                    type = 'description',
                    width = 'full',
                },
                genHeading4 = {
                    order = 91,
                    name = 'Debug Settings (Used for testing)',
                    type = 'header',
                },
                genShowDebug = {
                    order = 92,
                    name = 'Put in debug mode',
                    desc = 'This can cause issue, leave disabled.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.pSettings.debugMode = val end,
                    get = function() return ns.pSettings.debugMode end,
                },
            },
        },
        blankHeader1 = {
            order = 10,
            name = ' ',
            type = 'group',
            args = {}
        },
        gmSettings = {
            name = L['GM_SETTINGS'],
            type = 'group',
            order = 11,
            hidden = function() return not ns.core.hasGM end,
            args = {
                invHeader1 = {
                    name = L['GM_SETTINGS'],
                    type = 'header',
                    order = 0,
                },
                gmSettingsDesc1 = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', L['GM_FORCE_DESC1']),
                    type = 'description',
                    fontSize = 'medium',
                },
                gmSettingsDesc2 = {
                    order = 2,
                    name = ns.code:cText('FFFFFF00', L['GM_FORCE_DESC2']),
                    type = 'description',
                    fontSize = 'medium',
                },
                gmSettingsDesc3 = {
                    order = 3,
                    name = ' ',
                    type = 'description',
                    fontSize = 'medium',
                    width = 'full',
                },
                gmColumn1 = {
                    order = 4,
                    name = 'Force',
                    type = 'description',
                    fontSize = 'medium',
                    width = 1,
                },
                gmColumn2 = {
                    order = 4,
                    name = 'Setting',
                    type = 'description',
                    fontSize = 'medium',
                    width = 1,
                },
                gmForceObeyBlock = {
                    order = 5,
                    name = bulletAccountWide..L['FORCE_ENABLE_BLOCK_INVITE_CHECK'],
                    desc = L['FORCE_ENABLE_BLOCK_INVITE_CHECK_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.forceObey = val end,
                    get = function() return ns.gmSettings.forceObey or false end,
                },
                gmObeyBlock = {
                    order = 6,
                    name = bulletAccountWide..L['ENABLE_BLOCK_INVITE_CHECK'],
                    desc = L['ENABLE_BLOCK_INVITE_CHECK_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.obeyBlockInvites = val end,
                    get = function() return ns.gmSettings.obeyBlockInvites or false end,
                },
                gmForceAntiSpam = {
                    order = 7,
                    name = bulletAccountWide..L['FORCE_ANTI_SPAM'],
                    desc = L['FORCE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.forceAntiSpam = val end,
                    get = function() return ns.gmSettings.forceAntiSpam or false end,
                },
                gmAntiSpamEnable = {
                    order = 8,
                    name = bulletAccountWide..L['ENABLE_ANTI_SPAM'],
                    desc = L['ENABLE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.antiSpam = val end,
                    get = function() return ns.gmSettings.antiSpam or false end,
                },
                gmColumn1Spacer = {
                    order = 9,
                    name = ' ',
                    type = 'description',
                    fontSize = 'medium',
                    width = 1,
                },
                gmAntiSpamInterval = {
                    order = 10,
                    name = bulletAccountWide..L['ANTI_SPAM_DAYS'],
                    desc = L['ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
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
                invHeader2 = {
                    name = L['WELCOME_MESSAGES'],
                    type = 'header',
                    order = 20,
                },
                gmForceGuildGreeting = {
                    order = 21,
                    name = L['FORCE_GUILD_GREETING'],
                    desc = L['FORCE_GUILD_GREETING_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.forceSendGuildGreeting = val end,
                    get = function() return ns.gmSettings.forceSendGuildGreeting or false end,
                },
                gmGuildGreeting = {
                    order = 22,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.sendGuildGreeting = val end,
                    get = function() return ns.gmSettings.sendGuildGreeting or false end,
                },
                gmGuildWelcomeMessage = {
                    order = 23,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.code:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gmSettings.guildMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetWelcomeMessages()
                    end,
                    get = function() return ns.gmSettings.guildMessage end,
                },
                gmForceWelcomeWhisper = {
                    order = 24,
                    name = L['FORCE_WHISPER_MESSAGE'],
                    desc = L['FORCE_WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.forceSendWhisper = val end,
                    get = function() return ns.gmSettings.forceSendWhisper or false end,
                },
                gmWelcomeWhisper = {
                    order = 25,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.sendWhisperGreeting = val end,
                    get = function() return ns.gmSettings.sendWhisperGreeting or false end,
                },
                gmWelcomeWhisperMessage = {
                    order = 26,
                    name = bulletAccountWide..L['FORCE_WHISPER_MESSAGE'],
                    desc = L['FORCE_WHISPER_MESSAGE_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.code:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gmSettings.whisperMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetWelcomeMessages()
                    end,
                    get = function() return ns.gmSettings.whisperMessage end,
                },
                genSpacer3 = {
                    order = 90,
                    name = ' ',
                    type = 'description',
                },
                GMMessageListInstructions = {
                    order = 91,
                    name = function()
                        local msg = L['MESSAGE_REPLACEMENT_INSTRUCTIONS']
                        msg = msg:gsub('GUILDLINK', ns.code:cText('FFFFFF00', L['GUILDLINK']))
                        msg = msg:gsub('GUILDNAME', ns.code:cText('FFFFFF00', L['GUILDNAME']))
                        msg = msg:gsub('PLAYERNAME', ns.code:cText('FFFFFF00', L['PLAYERNAME']))

                        return msg
                    end,
                    type = 'description',
                    fontSize = 'medium',
                },
            },
        },
        playerInviteSettings = {
            name = L['INVITE_SETTINGS'],
            type = 'group',
            order = 11,
            hidden = function() return ns.core.hasGM end,
            args = {
                invHeader1 = {
                    name = L['INVITE_SETTINGS'],
                    type = 'header',
                    order = 0,
                },
                invSettingsDesc1 = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', L['ENABLED_NOTE']),
                    type = 'description',
                    fontSize = 'medium',
                },
                invAntiSpamEnable = {
                    order = 5,
                    name = bulletAccountWide..L['ENABLE_ANTI_SPAM'],
                    desc = L['ENABLE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gSettings.antiSpam = val end,
                    get = function() return ns.gSettings.antiSpam or false end,
                },
                invAntiSpamInterval = {
                    order = 6,
                    name = bulletAccountWide..L['ANTI_SPAM_DAYS'],
                    desc = L['ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
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
                    get = function() return ns.gSettings.antiSpamDays or 7 end,
                },
                invHeader2 = {
                    name = L['WELCOME_MESSAGES'],
                    type = 'header',
                    order = 20,
                },
                invGuildGreeting = {
                    order = 21,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gSettings.sendGuildGreeting = val end,
                    get = function() return ns.gSettings.sendGuildGreeting or false end,
                },
                invGuildWelcomeMessage = {
                    order = 22,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.code:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gSettings.guildMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetWelcomeMessages()
                    end,
                    get = function() return ns.gmSettings.guildMessage end,
                },
                gmWelcomeWhisper = {
                    order = 23,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gSettings.sendWhisperGreeting = val end,
                    get = function() return ns.gSettings.sendWhisperGreeting or false end,
                },
                gmWelcomeWhisperMessage = {
                    order = 24,
                    name = bulletAccountWide..L['FORCE_WHISPER_MESSAGE'],
                    desc = L['FORCE_WHISPER_MESSAGE_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.code:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gSettings.whisperMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetWelcomeMessages()
                    end,
                    get = function() return ns.gSettings.whisperMessage end,
                },
                genSpacer3 = {
                    order = 90,
                    name = ' ',
                    type = 'description',
                },
                GMMessageListInstructions = {
                    order = 91,
                    name = function()
                        local msg = L['MESSAGE_REPLACEMENT_INSTRUCTIONS']
                        msg = msg:gsub('GUILDLINK', ns.code:cText('FFFFFF00', L['GUILDLINK']))
                        msg = msg:gsub('GUILDNAME', ns.code:cText('FFFFFF00', L['GUILDNAME']))
                        msg = msg:gsub('PLAYERNAME', ns.code:cText('FFFFFF00', L['PLAYERNAME']))

                        return msg
                    end,
                    type = 'description',
                    fontSize = 'medium',
                },
            }
        },
        gmInviteMessageList = {
            name = L['GM_INVITE'],
            type = 'group',
            order = 12,
            hidden = function() return not ns.core.hasGM end,
            args = {
                gmMessageListHeading = {
                    order = 0,
                    name = L['GM_INVITE'],
                    type = 'header',
                },
                gmMessageListDesc = {
                    order = 1,
                    name = L['GM_SETTINGS_DESC'],
                    type = 'description',
                    fontSize = 'medium',
                },
                gmForceMessageList = {
                    order = 2,
                    name = L['FORCE_MESSAGE_LIST'],
                    desc = L['FORCE_MESSAGE_LIST_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gmSettings.forceMessageList = val end,
                    get = function() return ns.gmSettings.forceMessageList end,
                },
                gmDropdownList = {
                    order = 3,
                    name = L['INVITE_ACTIVE_MESSAGE'],
                    desc = L['INVITE_ACTIVE_MESSAGE_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.gmSettings.messageList or {}) do
                            local desc = (r.gmSync or r.gmSync == nil) and ns.code:cText(GM_DESC_COLOR, r.desc) or r.desc
                            tbl[k] = desc
                        end
                        return tbl
                    end,
                    set = function(_, val) activeMessage = val end,
                    get = function()
                        local msg = ns.gmSettings.messageList or nil
                        local active = activeMessage or nil

                        if active and msg then
                            tblMessage = msg[active] or newMsg()
                            tblMessage.gmSync = (tblMessage.gmSync == nil) and true or tblMessage.gmSync
                        elseif not msg then activeMessage = nil end

                        return active
                    end,
                },
                gmNewButton = {
                    order = 4,
                    name = L['NEW'],
                    desc = L['NEW_MESSAGE_DESC'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return not activeMessage end,
                    hidden = function() return not ns.core.hasGM or not activeMessage end,
                    func = function()
                        tblMessage = newMsg()
                        activeMessage = nil
                    end,
                },
                gmInviteDesc = {
                    order = 5,
                    name = L['INVITE_DESC'],
                    desc = L['INVITE_DESC_TOOLTIP'],
                    type = 'input',
                    multiline = false,
                    width = 1,
                    set = function(_, val)
                        if not tblMessage then tblMessage = newMsg() end

                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.code:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end

                        tblMessage.desc = val end,
                    get = function() return tblMessage and tblMessage.desc or '' end,
                },
                gmSyncMessage = {
                    order = 6,
                    name = L['SYNC_MESSAGES'],
                    desc = L['SYNC_MESSAGES_DESC'],
                    type = 'toggle',
                    width = 1,
                    disabled = function() return not tblMessage end,
                    set = function(_, val) tblMessage.gmSync = val end,
                    get = function() return tblMessage.gmSync == nil and true or tblMessage.gmSync end,
                },
            }
        },
    },
}