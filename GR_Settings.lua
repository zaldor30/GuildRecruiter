local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local icon = LibStub('LibDBIcon-1.0')

local MAX_CHARACTERS = 255
local bulletAccountWide = ns.code:cText('ff00ff00', '* ')

--* Message Routines
local activeZone, checkedZones, tblPlayerZone = nil, false, nil
local activeMessage, isGMMessage = nil, false
local tblAntiSpamSorted, tblBlackListSorted = {}, {}

local function newMsg()
    return {
        desc = '',
        message = '',
        gmSync = ns.core.hasGM,
    }
end
local tblMessage, tblZoneList, tblZone = nil, nil, {}
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
                gmForceGuildGreetingMessage = {
                    order = 23,
                    name = L['FORCE_GUILD_MESSAGE'],
                    desc = L['FORCE_GUILD_MESSAGE_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gmSettings.forceGuildMessage = val end,
                    get = function() return ns.gmSettings.forceGuildMessage or false end,
                },
                gmGuildWelcomeMessage = {
                    order = 24,
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
                    order = 25,
                    name = L['FORCE_WHISPER_MESSAGE'],
                    desc = L['FORCE_WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.forceSendWhisper = val end,
                    get = function() return ns.gmSettings.forceSendWhisper or false end,
                },
                gmWelcomeWhisper = {
                    order = 26,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.sendWhisperGreeting = val end,
                    get = function() return ns.gmSettings.sendWhisperGreeting or false end,
                },
                gmForceGuildWhisperMessage = {
                    order = 27,
                    name = L['FORCE_WHISPER_MESSAGE'],
                    desc = L['FORCE_WHISPER_MESSAGE_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gmSettings.forceWhisperMessage = val end,
                    get = function() return ns.gmSettings.forceWhisperMessage or false end,
                },
                gmWelcomeWhisperMessage = {
                    order = 28,
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
                    disabled = function() return ns.gmSettings.forceAntiSpam end,
                    set = function(_, val) ns.gSettings.antiSpam = val end,
                    get = function() return ns.gmSettings.forceAntiSpam and ns.gmSettings.AntiSpam or ns.gSettings.antiSpam end,
                },
                invAntiSpamInterval = {
                    order = 6,
                    name = bulletAccountWide..L['ANTI_SPAM_DAYS'],
                    desc = L['ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    disabled = function() return ns.gmSettings.forceAntiSpam end,
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
                    get = function() return ns.gmSettings.forceAntiSpam and ns.gmSettings.antiSpamDays or (ns.gSettings.antiSpamDays or 7) end,
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
                    disabled = function() return ns.gmSettings.forceSendGuildGreeting end,
                    set = function(_, val) ns.gSettings.sendGuildGreeting = val end,
                    get = function() return ns.gmSettings.forceSendGuildGreeting and ns.gmSettings.sendGuildGreeting or ns.gSettings.sendGuildGreeting end,
                },
                invGuildWelcomeMessage = {
                    order = 22,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return ns.gmSettings.forceGuildMessage end,
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.code:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gSettings.guildMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetWelcomeMessages()
                    end,
                    get = function() return ns.gmSettings.forceGuildMessage and ns.gmSettings.guildMessage or ns.gSettings.guildMessage end,
                },
                gmWelcomeWhisper = {
                    order = 23,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmSettings.forceSendWhisper end,
                    set = function(_, val) ns.gSettings.sendWhisperGreeting = val end,
                    get = function() return ns.gmSettings.forceSendWhisper or ns.gSettings.sendWhisperGreeting end,
                },
                gmWelcomeWhisperMessage = {
                    order = 24,
                    name = bulletAccountWide..L['FORCE_WHISPER_MESSAGE'],
                    desc = L['FORCE_WHISPER_MESSAGE_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return ns.gmSettings.forceWhisperMessage end,
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.code:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gSettings.whisperMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetWelcomeMessages()
                    end,
                    get = function() return ns.gmSettings.forceWhisperMessage and ns.gmSettings.whisperMessage or ns.gSettings.whisperMessage end,
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
                        tblMessage = tblMessage or newMsg()
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
                    get = function() return tblMessage and tblMessage.gmSync or false end,
                },
                gmInviteMessage = {
                    order = 7,
                    name = L['INVITE_MESSAGES']..':',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    disabled = function() return not tblMessage end,
                    set = function(_, val)
                        if not tblMessage then tblMessage = newMsg() end
                        tblMessage.message = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return tblMessage and tblMessage.message or '' end,
                },
                gmPreview = {
                    order = 8,
                    name = function()
                        if not tblMessage then return '' end

                        local preview = ns.code:variableReplacement(tblMessage.message, UnitName('player'))
                        if tblMessage.message == '' then return '' end

                        local msg = (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
                        msg = msg:gsub(L['GUILD_LINK_NOT_FOUND'], ns.code:cText('FFFF0000', L['GUILD_LINK_NOT_FOUND']))
                        msg = msg:gsub(L['NO_GUILD_NAME'], ns.code:cText('FFFF0000', L['NO_GUILD_NAME']))

                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                gmPreviewCount = {
                    order = 9,
                    name = function()
                        if not tblMessage then return '' end
                
                        local playerNameFound, count = getMessageLength(tblMessage.message)

                        local msg = L['MAX_CHARS']
                        local color = count < MAX_CHARACTERS and 'FF00FF00' or 'FFFF0000'
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', MAX_CHARACTERS)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                msgGMHeader5 = {
                    order = 20,
                    name = '',
                    type = 'header',
                },
                msgGMInviteSave = {
                    order = 21,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblMessage then return true end
                        return not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0)) end,
                    func = function()
                        local tbl = ns.gmSettings.messageList or {}
                        local active = activeMessage

                        if not active then
                            tinsert(tbl, tblMessage)
                            active = #tbl
                        else tbl[active] = tblMessage end
                        ns.gmSettings.messageList = tbl

                        tblMessage = newMsg()
                        activeMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 0, 1, 0, 1)
                    end,
                },
                genSpacer = {
                    order = 22,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                gmInviteDel = {
                    order = 23,
                    name = L['DELETE'],
                    type = 'execute',
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    width = .5,
                    disabled = function() return not activeMessage and true or false end,
                    func = function()
                        local msg = ns.gmSettings.messageList or nil
                        local active = activeMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            tblMessage = newMsg()
                        end

                        activeMessage = nil
                        if ns.pSettings.activeMessage then ns.pSettings.activeMessage = nil end
                    end,
                },
                genSpacer3 = {
                    order = 90,
                    name = ' ',
                    type = 'description',
                },
                gmMessageListInstructions = {
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
        invInviteMessageList = {
            name = L['INVITE_MESSAGES'],
            type = 'group',
            order = 12,
            hidden = function() return ns.core.hasGM end,
            args = {
                invMessageListHeading = {
                    order = 0,
                    name = L['INVITE_MESSAGES'],
                    type = 'header',
                },
                invMessageListDesc = {
                    order = 1,
                    name = L['PLAYER_SETTINGS_DESC'],
                    type = 'description',
                    fontSize = 'medium',
                },
                invDropdownList = {
                    order = 2,
                    name = L['INVITE_ACTIVE_MESSAGE'],
                    desc = L['INVITE_ACTIVE_MESSAGE_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    values = function()
                        local tbl = {}
                        tblMessage = tblMessage or newMsg()
                        for k, r in pairs(ns.gmSettings.messageList or {}) do
                            local desc = (r.gmSync or r.gmSync == nil) and ns.code:cText(GM_DESC_COLOR, r.desc) or r.desc
                            tbl[k] = desc
                        end
                        for k, r in pairs(ns.gSettings.messageList or {}) do tbl[k] = r.desc end
                        return tbl
                    end,
                    set = function(_, val) activeMessage = val end,
                    get = function()
                        local msg = ns.gSettings.messageList or nil
                        local active = activeMessage or nil

                        if active and msg then
                            isGMMessage = msg[active].gmSync or false
                            tblMessage = msg[active] or newMsg()
                            tblMessage.gmSync = false
                        elseif not msg then activeMessage = nil end

                        return active
                    end,
                },
                invNewButton = {
                    order = 3,
                    name = L['NEW'],
                    desc = L['NEW_MESSAGE_DESC'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return not activeMessage end,
                    hidden = function() return not activeMessage end,
                    func = function()
                        isGMMessage = false
                        activeMessage = nil
                        tblMessage = newMsg()
                    end,
                },
                invInviteDesc = {
                    order = 4,
                    name = L['INVITE_DESC'],
                    desc = L['INVITE_DESC_TOOLTIP'],
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    disabled = function() return isGMMessage end,
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
                invInviteMessage = {
                    order = 5,
                    name = L['INVITE_MESSAGES']..':',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    disabled = function() return isGMMessage or not tblMessage end,
                    set = function(_, val)
                        if not tblMessage then tblMessage = newMsg() end
                        tblMessage.message = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return tblMessage and tblMessage.message or '' end,
                },
                invPreview = {
                    order = 6,
                    name = function()
                        if not tblMessage then return '' end

                        local preview = ns.code:variableReplacement(tblMessage.message, UnitName('player'))
                        if tblMessage.message == '' then return '' end

                        local msg = (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
                        msg = msg:gsub(L['GUILD_LINK_NOT_FOUND'], ns.code:cText('FFFF0000', L['GUILD_LINK_NOT_FOUND']))
                        msg = msg:gsub(L['NO_GUILD_NAME'], ns.code:cText('FFFF0000', L['NO_GUILD_NAME']))

                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                invPreviewCount = {
                    order = 7,
                    name = function()
                        if not tblMessage then return '' end
                
                        local playerNameFound, count = getMessageLength(tblMessage.message)

                        local msg = L['MAX_CHARS']
                        local color = count < MAX_CHARACTERS and 'FF00FF00' or 'FFFF0000'
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', MAX_CHARACTERS)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                msgGMHeader5 = {
                    order = 20,
                    name = '',
                    type = 'header',
                },
                invGMInviteSave = {
                    order = 21,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblMessage then return true end
                        return isGMMessage or (not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0))) end,
                    func = function()
                        local tbl = ns.gSettings.messageList or {}
                        local active = activeMessage

                        if not active then
                            tinsert(tbl, tblMessage)
                            active = #tbl
                        else tbl[active] = tblMessage end
                        ns.gSettings.messageList = tbl

                        tblMessage = newMsg()
                        activeMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 0, 1, 0, 1)
                    end,
                },
                genSpacer = {
                    order = 22,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                invInviteDel = {
                    order = 23,
                    name = L['DELETE'],
                    type = 'execute',
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    width = .5,
                    disabled = function() return isGMMessage or not activeMessage end,
                    func = function()
                        local msg = ns.gSettings.messageList or nil
                        local active = activeMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            tblMessage = newMsg()
                        end

                        activeMessage = nil
                        if ns.pSettings.activeMessage then ns.pSettings.activeMessage = nil end
                    end,
                },
                genSpacer3 = {
                    order = 90,
                    name = ' ',
                    type = 'description',
                },
                invMessageListInstructions = {
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
        blankHeader3 = {
            order = 20,
            name = ' ',
            type = 'group',
            args = {}
        },
        antiSpam = {
            name = L['ANTI_SPAM'],
            type = 'group',
            order = 21,
            args = {
                asHeader1 = {
                    order = 0,
                    name = L['ANTI_SPAM'],
                    type = 'header',
                },
                asDesc1 = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', 'This is read only for now, will be updated in the future.'),
                    type = 'description',
                    fontSize = 'medium',
                },
                asHeader3 = {
                    order = 3,
                    name = '',
                    type = 'header',
                },
                asMultiSelect = {
                    order = 4,
                    type = 'multiselect',
                    name = 'Anti-Spam Player List',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        tblAntiSpamSorted = ns.code:sortTableByField(ns.tblAntiSpamList, 'name')
                        for k, r in pairs(tblAntiSpamSorted or {}) do
                            tbl[k] = (r.name..': '..date("%m/%d/%Y %H:%M", r.date))
                        end

                        return tbl
                    end,
                    set = function(_, key, val) ns.tblAntiSpamList[tblAntiSpamSorted[key].key].selected = val end,
                    get = function(_, key) return ns.tblAntiSpamList[tblAntiSpamSorted[key].key].selected or false end,
                }
            }
        },
        blackList = {
            name = L['BLACK_LIST'],
            type = 'group',
            order = 22,
            args = {
                blHeader1 = {
                    order = 0,
                    name = L['BLACK_LIST'],
                    type = 'header',
                },
                blRemoveButton = {
                    name = L['BLACK_LIST_REMOVE'],
                    type = 'execute',
                    width = 1,
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    order = 1,
                    func = function()
                        ns.g.blackListRemoved = ns.g.blackListRemoved and ns.g.blackListRemoved or {}
                        for _, r in pairs(tblBlackListSorted) do
                            if r.selected then
                                tinsert(ns.g.blackListRemoved, ns.tblBlackList[r.key])
                                ns.tblBlackList[r.key] = nil
                            end
                        end

                        ns.code:saveTables('BLACK_LIST')
                    end,
                },
                blPrivateReasonButton = {
                    name = L['BL_PRIVATE_REASON'],
                    desc = L['BL_PRIVATE_REASON_DESC'],
                    type = 'execute',
                    width = 1,
                    order = 2,
                    func = function()
                        for _, r in pairs(tblBlackListSorted) do
                            if r.blBy == UnitName('player') then
                                if r.selected and not r.private then
                                    ns.tblBlackList[r.key].private = true
                                elseif r.selected and r.private then
                                    ns.tblBlackList[r.key].private = false
                                end
                            elseif r.selected then ns.code:fOut(L['BL_PRIVATE_REASON_ERROR']..' '..r.key) end
                            r.selected = false
                        end

                        -- Put back in to black list table
                        for _, r in pairs(ns.tblBlackList) do ns.tblBlackList[r.key] = r end
                        ns.code:saveTables('BLACK_LIST')
                    end,
                },
                blHeader3 = {
                    order = 3,
                    name = '',
                    type = 'header',
                },
                blMultiSelect = {
                    order = 4,
                    type = 'multiselect',
                    name = 'Black Listed Players',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        tblBlackListSorted = ns.code:sortTableByField(ns.tblBlackList, 'name')
                        for k, r in pairs(tblBlackListSorted or {}) do
                            local reason = r.reason
                            if r.private then reason = '<Private>' end
                            tbl[k] = (r.name..': '..(reason or 'Unknown'))
                        end

                        return tbl
                    end,
                    set = function(_, key, val) tblBlackListSorted[key].selected = val end,
                    get = function(_, key) return tblBlackListSorted[key].selected or false end,
                }
            }
        },
        zoneList = {
            name = L['INVALID_ZONE'],
            type = 'group',
            order = 23,
            args = {
                zHeader1 = {
                    order = 0,
                    name = L['INVALID_ZONE'],
                    type = 'header',
                },
                zSettingsDesc1 = {
                    order = 1,
                    name = ns.code:cText('FF00FF00', L['ZONE_INSTRUCTIONS']),
                    type = 'description',
                    fontSize = 'medium',
                },
                zHeader2 = {
                    order = 2,
                    name = '',
                    type = 'header',
                },
                zoneName = {
                    order = 3,
                    name = L['ZONE_NAME'],
                    type = 'input',
                    width = 1,
                    set = function(_, val)
                        tblZone.name = val
                        tblZoneList = tblZoneList or ns.ds:GetZones()
                        if not tblZoneList[strlower(val)] then
                            ns.code:AcceptDialog(L['ZONE_NOT_FOUND']..' '..val, function() return end)
                            activeZone = nil
                        else activeZone = tblZoneList[strlower(val)] end
                    end,
                    get = function() return tblZone.name and tostring(tblZone.name) or '' end,
                },
                zoneDesc = {
                    order = 4,
                    name = L['ZONE_INVALID_REASON'],
                    type = 'input',
                    width = 1,
                    set = function(_, val) tblZone.reason = val end,
                    get = function() return tblZone.reason and tostring(tblZone.reason) or '' end,
                },
                zSpacer1 = {
                    order = 5,
                    name = ' ',
                    type = 'description',
                    fontSize = 'medium',
                    width = .5,
                },
                zNewButton = {
                    order = 6,
                    name = L['NEW'],
                    type = 'execute',
                    width = .5,
                    hidden = function() return not activeZone or checkedZones end,
                    func = function()
                        tblZone = {}
                        activeZone = nil
                    end,
                },
                zSaveButton = {
                    order = 7,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    hidden = function() return not activeZone or checkedZones end,
                    disabled = function()
                        if activeZone and tblZone.name and tblZone.reason then
                            return checkedZones else return true end
                    end,
                    func = function()
                        ns.global.zoneList = ns.global.zoneList or {}
                        local key = strlower(tblZone.name)
                        ns.global.zoneList[key] = tblZone
                        UIErrorsFrame:AddMessage('Zone Saved', 0, 1, 0, 1)
                    end,
                },
                zDeleteButton = {
                    order = 9,
                    name = L['DELETE'],
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    type = 'execute',
                    width = .5,
                    hidden = function() return not checkedZones end,
                    func = function()
                        for k, r in pairs(tblPlayerZone) do
                            if r.selected then
                                ns.global.zoneList[k] = nil
                                tblPlayerZone[k] = nil
                            end
                        end
                        checkedZones = false
                        UIErrorsFrame:AddMessage('Zones Deleted', 0, 1, 0, 1)
                    end,
                },
                zPlayerZones = {
                    order = 10,
                    type = 'multiselect',
                    name = 'Player\'s Invalid Zone List:',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        tblPlayerZone = tblPlayerZone or {}
                        for k, r in pairs(ns.global.zoneList or {}) do
                            tblPlayerZone[k] = {
                                r,
                                selected = tblPlayerZone[k] and tblPlayerZone[k].selected or false,
                            }
                            tbl[k] = r.name..ns.code:cText('FFFFFF00', ' Reason: '..r.reason) end

                        return tbl
                    end,
                    set = function(_, key, val)
                        if tblPlayerZone then
                            tblPlayerZone[key].selected = val
                            checkedZones = false
                            for _, r in pairs(tblPlayerZone) do
                                if r.selected then checkedZones = true break end
                            end
                        end
                    end,
                    get = function(_, key)
                        if not tblPlayerZone then print('tblPlayerZone missing') return false end
                        print(tblPlayerZone[key].selected)
                        return tblPlayerZone[key].selected
                    end,
                },
                zLockedZones = {
                    order = 11,
                    type = 'multiselect',
                    name = 'Locked Invalid Zone List (View Only):',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.tblInvalidZones or {}) do
                            tbl[k] = r.name..ns.code:cText('FFFFFF00', ' Reason: '..r.reason) end

                        return tbl
                    end,
                    set = function(_, key, val) return end,
                    get = function(_, key) return false end,
                }
            }
        },
        blankHeader4 = {
            type = 'group',
            name = ' ',
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