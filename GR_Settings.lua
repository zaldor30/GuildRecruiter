local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local icon = LibStub('LibDBIcon-1.0')

local hasGM, iAmGM = ns.core.hasGM, ns.core.iAmGM
local bulletAccountWide = ns.code:cText('ff00ff00', '* ')

-- Determine the length of a message
local maxChars = 255
local function MessageLength(msg)
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
local function newMsg()
    return {
        desc = '',
        message = '',
    }
end
local function newZone()
    return {
        id = '',
        name = '',
        reason = '',
    }
end

local tblZoneByName = nil
local function zoneOut()
    local tbl = {}
    local tblTemp = ns.ds:convertZoneKeyToName()
    local tblZonesOut = ns.code:sortTableByField(tblTemp, 'name', true, true)
    for _, r in pairs(tblZonesOut or {}) do
        local personal = ns.global.zoneList[r.id] and '|cFF00FF00*|r' or ''
        if r.id and r.reason and r.name then
            tbl[r.id] = personal..ns.code:cText('FFFFFF00', r.name)..' ('..r.reason..')'
        end
    end

    tblZoneByName = tbl
    return tbl
end

local tblZone = newZone()
local tblMessage = newMsg()
local tblGMMessage = newMsg()

local gmActiveMessage, invActiveMessage, activeZone = nil, nil, nil

BL_DAYS_TO_WAIT = 14

ns.addonSettings = {
    name = L['TITLE']..' ('..GR.version..(GR.isTest and ' '..GR.testLevel..')' or ')'),
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
                    set = function(_, val)
                        ns.pSettings.minimap.hide = not val
                        if val then icon:Show('GR_Icon')
                        else icon:Hide('GR_Icon') end
                    end,
                    get = function() return not ns.pSettings.minimap.hide or false end,
                },
                genWhatsNew = {
                    order = 3,
                    name = bulletAccountWide..L['GEN_WHATS_NEW'],
                    desc = L['GEN_WHATS_NEW_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.global.showWhatsNew = val end,
                    get = function() return ns.global.showWhatsNew end,
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
                    set = function(_, val) ns.gSettings.sendWhsiper = val end,
                    get = function() return ns.gSettings.sendWhsiper end,
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
            order = 5,
            name = ' ',
            type = 'group',
            hidden = function() return not ns.guildInfo.isGuildLeader and not ns.guildInfo.GuildLeaderToon end,
            args = {}
        },
        gmSettings = {
            name = L['GM_SETTINGS'],
            type = 'group',
            order = 6,
            hidden = function() return not ns.core.hasGM end,
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
                    disabled = function() return not ns.core.iAmGM end,
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
                    disabled = function() return not ns.core.iAmGM end,
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
                    disabled = function() return not ns.core.iAmGM end,
                    set = function(_, val) ns.gmSettings.sendGuildGreeting = val end,
                    get = function() return ns.gmSettings.sendGuildGreeting end,
                },
                invWelcomeMessage = {
                    order = 11,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return not ns.core.iAmGM end,
                    set = function(_, val) ns.gmSettings.guildMessage = val end,
                    get = function() return ns.gmSettings.guildMessage end,
                },
                invSendGreeting = {
                    order = 12,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return not ns.core.iAmGM end,
                    set = function(_, val) ns.gmSettings.sendWhsiper = val end,
                    get = function() return ns.gmSettings.sendWhsiper end,
                },
                invGreetingMessage = {
                    order = 13,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return not ns.core.iAmGM end,
                    set = function(_, val) ns.gmSettings.whisperMessage = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return ns.gmSettings.whisperMessage end,
                },
                gmPreviewCount = {
                    order = 14,
                    name = function()
                        local playerNameFound, count = MessageLength(ns.gmSettings.whisperMessage)

                        local msg = L['MAX_CHARS']
                        local color = count < maxChars and 'FF00FF00' or 'FFFF0000'
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', maxChars)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                genSpacer3 = {
                    order = 15,
                    name = ' ',
                    type = 'description',
                },
                GMMessageListInstructions = {
                    order = 16,
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
        gmMessageList = {
            order = 7,
            name = L['GM_INVITE'],
            type = 'group',
            hidden = function() return not ns.core.hasGM end,
            args = {
                gmMessageListHeading1 = {
                order = 0,
                name = L['GM_INVITE'],
                type = 'header',
                },
                gmMessageListDesc = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', L['GM_SETTINGS_DESC']),
                    type = 'description',
                    fontSize = 'medium',
                },
                msgGMActive = {
                    order = 2,
                    name = L['INVITE_ACTIVE_MESSAGE'],
                    desc = L['NEW_MESSAGE_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.gmSettings.messageList or {}) do tbl[k] = ns.code:cText(GM_DESC_COLOR, r.desc) end
                        return tbl
                    end,
                    set = function(_, val) gmActiveMessage = val end,
                    get = function()
                        local msg = ns.gmSettings.messageList or nil
                        local active = gmActiveMessage or nil

                        if active and msg then tblGMMessage = msg[active] or newMsg()
                        elseif not msg then gmActiveMessage = nil end

                        return active
                    end,
                },
                msgGMNewButton = {
                    order = 3,
                    name = L['NEW_MESSAGE'],
                    desc = L['NEW_MESSAGE_DESC'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return not gmActiveMessage end,
                    hidden = function() return not ns.core.iAmGM end,
                    func = function()
                        tblGMMessage = newMsg()
                        gmActiveMessage = nil
                    end,
                },
                msgGMInviteDesc = {
                    order = 4,
                    name = L['INVITE_DESC'],
                    desc = L['INVITE_DESC_TOOLTIP'],
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    disabled = function() return not ns.core.iAmGM end,
                    set = function(_, val) tblGMMessage.desc = val end,
                    get = function() return tblGMMessage.desc or '' end,
                },
                msgGMInviteMessage = {
                    order = 5,
                    name = 'Invite Message',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    disabled = function() return not ns.core.iAmGM end,
                    set = function(_, val) tblGMMessage.message = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return tblGMMessage.message or '' end,
                },
                msgGMHeader4 = {
                    order = 10,
                    name = 'Message Preview',
                    type = 'header',
                    hidden = function() return tblGMMessage.message == '' end,
                },
                msgGMPreview = {
                    order = 11,
                    name = function()
                        local preview = ns.code:variableReplacement(tblGMMessage.message, UnitName('player'))
                        if tblGMMessage.message == '' then return '' end

                        local msg = (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
                        msg = msg:gsub(L['GUILD_LINK_NOT_FOUND'], ns.code:cText('FFFF0000', L['GUILD_LINK_NOT_FOUND']))
                        msg = msg:gsub(L['NO_GUILD_NAME'], ns.code:cText('FFFF0000', L['NO_GUILD_NAME']))
                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                    hidden = function() return tblGMMessage.message == '' end,
                },
                gmPreviewCount = {
                    order = 20,
                    name = function()
                        local playerNameFound, count = MessageLength(ns.gmSettings.whisperMessage)

                        local msg = L['MAX_CHARS']
                        local color = count < maxChars and 'FF00FF00' or 'FFFF0000'
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', maxChars)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                msgGMHeader5 = {
                    order = 21,
                    name = '',
                    type = 'header',
                },
                msgGMInviteDel = {
                    order = 22,
                    name = L['DELETE'],
                    type = 'execute',
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    width = .5,
                    disabled = function() return not gmActiveMessage and true or false end,
                    hidden = function() return not ns.core.iAmGM end,
                    func = function()
                        local msg = ns.gmSettings.messageList or nil
                        local active = gmActiveMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            gmActiveMessage = nil
                            tblGMMessage = newMsg()
                        end
                    end,
                },
                msgGMInviteSave = {
                    order = 23,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblGMMessage then return true end
                        return not ((tblGMMessage.desc and strlen(tblGMMessage.desc) > 0) and (tblGMMessage.message and strlen(tblGMMessage.message) > 0)) end,
                    hidden = function() return not ns.core.iAmGM end,
                    func = function()
                        local msg = ns.gmSettings.messageList or {}
                        local active = gmActiveMessage

                        if not active then
                            tinsert(msg, tblGMMessage)
                            active = #msg
                        else msg[active] = tblGMMessage end
                        ns.gmSettings.messageList = msg

                        tblGMMessage = newMsg()
                        gmActiveMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 1.0, 0.1, 0.1, 1.0)
                    end,
                },
            },
        },
        blankHeader2 = {
            order = 10,
            name = ' ',
            type = 'group',
            hidden = function() return (hasGM and not iAmGM) and ns.gmSettings.sendWhsiper and ns.gmSettings.sendGuildGreeting and ns.gmSettings.antiSpam end,
            args = {}
        },
        inviteSettings = {
            order = 11,
            name = L['INVITE_SETTINGS'],
            type = 'group',
            hidden = function() return (hasGM and not iAmGM) and ns.gmSettings.sendWhsiper and ns.gmSettings.sendGuildGreeting and ns.gmSettings.antiSpam end,
            args = {
                invHeader1 = {
                    name = L['INVITE_SETTINGS'],
                    type = 'header',
                    order = 0,
                },
                invNote = {
                    order = 2,
                    name = ns.code:cText('FF00FF00', L['ENABLED_NOTE']),
                    type = 'description',
                    fontSize = 'medium',
                    hidden = function() return iAmGM end,
                },
                invOverrideGMSettings = {
                    order = 1,
                    name = L['OVERRIDE_GM_SETTINGS'],
                    desc = L['OVERRIDE_GM_SETTINGS_DESC'],
                    type = 'toggle',
                    width = 'full',
                    hidden = function() return not iAmGM end,
                    set = function(_, val) ns.gSettings.overrideGM = val end,
                    get = function() return ns.gSettings.overrideGM end,
                },
                invAntiSpamEnable = {
                    order = 6,
                    name = bulletAccountWide..L['ENABLE_ANTI_SPAM'],
                    desc = L['ENABLE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1.5,
                    disabled = function() return hasGM and ns.gmSettings.antiSpam end,
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
                    disabled = function() return hasGM and ns.gmSettings.antiSpam end,
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
                    disabled = function() return hasGM and ns.gmSettings.sendGuildGreeting end,
                    set = function(_, val) ns.gSettings.sendGuildGreeting = val end,
                    get = function() return ns.gSettings.sendGuildGreeting end,
                },
                invWelcomeMessage = {
                    order = 11,
                    name = bulletAccountWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return hasGM and ns.gmSettings.sendGuildGreeting end,
                    set = function(_, val) ns.gSettings.guildMessage = val end,
                    get = function() return ns.gSettings.guildMessage end,
                },
                invSendGreeting = {
                    order = 12,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return hasGM and ns.gmSettings.sendWhsiper end,
                    set = function(_, val) ns.gSettings.sendWhsiper = val end,
                    get = function() return ns.gSettings.sendWhsiper end,
                },
                invGreetingMessage = {
                    order = 13,
                    name = bulletAccountWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return hasGM and ns.gmSettings.sendWhsiper end,
                    set = function(_, val) ns.gSettings.whisperMessage = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return ns.gSettings.whisperMessage end,
                },
                invPreviewCount = {
                    order = 14,
                    name = function()
                        local playerNameFound, count = MessageLength(ns.gSettings.whisperMessage)

                        local msg = L['MAX_CHARS']
                        local color = count < maxChars and 'FF00FF00' or 'FFFF0000'
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', maxChars)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                genSpacer = {
                    order = 15,
                    name = ' ',
                    type = 'description',
                },
                invMessageListInstructions = {
                    order = 16,
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
        inviteMessages = {
            order = 12,
            name = L['INVITE_MESSAGES'],
            type = 'group',
            hidden = function() return (hasGM and not iAmGM) and ns.gmSettings.sendWhsiper end,
            args = {
                invMessageListHeading = {
                    order = 0,
                    name = L['INVITE_MESSAGES'],
                    type = 'header',
                },
                invActive = {
                    order = 5,
                    name = L['INVITE_ACTIVE_MESSAGE'],
                    desc = L['INVITE_ACTIVE_MESSAGE_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.gSettings.messageList or {}) do tbl[k] = ns.code:cText(GM_DESC_COLOR, r.desc) end
                        return tbl
                    end,
                    set = function(_, val) invActiveMessage = val end,
                    get = function()
                        local msg = ns.gSettings.messageList or nil
                        local active = invActiveMessage or nil

                        if active and msg then tblMessage = msg[active] or newMsg()
                        elseif not msg then invActiveMessage = nil end

                        return active
                    end,
                },
                invNewButton = {
                    order = 6,
                    name = L['NEW_MESSAGE'],
                    desc = L['NEW_MESSAGE_DESC'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return not invActiveMessage end,
                    func = function()
                        tblMessage = newMsg()
                        invActiveMessage = nil
                    end,
                },
                invInviteDesc = {
                    order = 7,
                    name = L['INVITE_DESC'],
                    desc = L['INVITE_DESC_TOOLTIP'],
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    set = function(_, val) tblMessage.desc = val end,
                    get = function() return tblMessage.desc or '' end,
                },
                invInviteMessage = {
                    order = 8,
                    name = L['INVITE_MESSAGES']..':',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    set = function(_, val) tblMessage.message = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return tblMessage.message or '' end,
                },
                invHeader4 = {
                    order = 9,
                    name = 'Message Preview',
                    type = 'header',
                    hidden = function() return tblMessage.message == '' end,
                },
                invPreview = {
                    order = 9,
                    name = function()
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
                    hidden = function() return tblMessage.message == '' end,
                },
                invPreviewCount = {
                    order = 14,
                    name = function()
                        local playerNameFound, count = MessageLength(ns.gSettings.whisperMessage)

                        local msg = L['MAX_CHARS']
                        local color = count < maxChars and 'FF00FF00' or 'FFFF0000'
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', maxChars)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                invHeader5 = {
                    order = 15,
                    name = '',
                    type = 'header',
                },
                invInviteDel = {
                    order = 16,
                    name = L['DELETE'],
                    type = 'execute',
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    width = .5,
                    disabled = function() return not invActiveMessage and true or false end,
                    func = function()
                        local msg = ns.gSettings.messageList or nil
                        local active = invActiveMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            invActiveMessage = nil
                            tblMessage = newMsg()
                        end
                    end,
                },
                invInviteSave = {
                    order = 17,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblMessage then return true end
                        return not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0)) end,
                    func = function()
                        local msg = ns.gSettings.messageList or {}
                        local active = invActiveMessage

                        if not active then
                            tinsert(msg, tblMessage)
                            active = #msg
                        else msg[active] = tblMessage end
                        ns.gSettings.messageList = msg

                        tblMessage = newMsg()
                        invActiveMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 1.0, 0.1, 0.1, 1.0)
                    end,
                },
                genSpacer = {
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
            order = 15,
            name = ' ',
            type = 'group',
            args = {}
        },
        blackList = {
            name = L['BLACK_LIST'],
            type = 'group',
            order = 16,
            args = {
                blHeader1 = {
                    order = 0,
                    name = L['BLACK_LIST'],
                    type = 'header',
                },
                blRemoveButton = {
                    name = L['BLACK_LIST_REMOVE'],
                    type = 'execute',
                    width = 'full',
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    order = 1,
                    func = function()
                        ns.g.blackListRemoved = ns.g.blackListRemoved and ns.g.blackListRemoved or {}
                        for k, r in pairs(ns.tblBlackList and ns.tblBlackList or {}) do
                            if r.selected then
                                ns.g.blackListRemoved[k] = C_DateAndTime.GetServerTimeLocal()
                                ns.tblBlackList[k] = nil
                            end
                        end

                        ns.code:saveTables('BLACK_LIST')
                    end,
                },
                blHeader3 = {
                    order = 2,
                    name = '',
                    type = 'header',
                },
                blMultiSelect = {
                    order = 3,
                    type = 'multiselect',
                    name = 'Black Listed Players',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.tblBlackList or {}) do
                            local name = k
                            tbl[k] = (name..': '..(r.reason or 'Unknown'))
                        end

                        return tbl
                    end,
                    set = function(_, key, val) ns.tblBlackList[key].selected = val end,
                    get = function(_, key) return ns.tblBlackList[key].selected or false end,
                }
            }
        },
        invalidZones = {
            name = L['INVALID_ZONE'],
            type = 'group',
            order = 17,
            args = {
                zonesHeader1 = {
                    order = 0,
                    name = L['INVALID_ZONE'],
                    type = 'header',
                },
                zoneID = {
                    order = 1,
                    name = L['ZONE_ID'],
                    desc = L['ZONE_ID_DESC'],
                    type = 'input',
                    width = .7,
                    set = function(_, val)
                        if not tonumber(val) then return end
                        tblZone.id = tonumber(val)
                    end,
                    get = function() return tostring(tblZone.id) end,
                },
                zoneName = {
                    order = 2,
                    name = L['ZONE_NAME'],
                    type = 'input',
                    width = .9,
                    set = function(_, val) tblZone.name = val end,
                    get = function() return tostring(tblZone.name) end,
                },
                zoneDesc = {
                    order = 2,
                    name = L['ZONE_TYPE'],
                    type = 'input',
                    width = .8,
                    set = function(_, val) tblZone.reason = val end,
                    get = function() return tostring(tblZone.reason) end,
                },
                invNewButton = {
                    order = 4,
                    name = L['NEW'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return not activeZone end,
                    func = function()
                        tblZone = newZone()
                        activeZone = nil
                    end,
                },
                invSaveButton = {
                    order = 4,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        local saveFail = tblZone.id == '' or tblZone.name == '' or tblZone.reason == ''
                        if not activeZone then
                            for _, r in pairs(ns.tblInvalidZones) do
                                if strlower(r.name) == strlower(tblZone.name) then
                                    saveFail = true
                                    break
                                end
                            end
                        end

                        return saveFail
                    end,
                    func = function()
                        ns.global.zoneList[tonumber(tblZone.id)] = tblZone
                        ns.tblInvalidZones = ns.ds:invalidZones()
                        tblZone = newZone()
                        activeZone = nil
                        zoneOut()
                    end,
                },
                invMessageListInstructions = {
                    order = 5,
                    name = ' ',
                    type = 'description',
                    fontSize = 'medium',
                    width = .5,
                },
                invDeleteButton = {
                    order = 6,
                    name = L['DELETE'],
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    type = 'execute',
                    width = .5,
                    disabled = function() return not activeZone end,
                    func = function()
                        if not activeZone then return end

                        ns.global.zoneList[activeZone] = nil
                        ns.tblInvalidZones = ns.ds:invalidZones()
                        activeZone = nil
                        tblZone = newZone()
                        zoneOut()
                    end,
                },
                ZoneNote = {
                    order = 14,
                    name = L['ZONE_NOTE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                zonesList = {
                    order = 15,
                    name = L['ZONE_LIST_NAME'],
                    type = 'multiselect',
                    width = 'full',
                    values = function()
                        if not tblZoneByName then zoneOut() end
                        return tblZoneByName
                    end,
                    set = function(_, key)
                        if not tblZoneByName or not tblZoneByName[key] then return end
                        activeZone = key
                        tblZone = {
                            id = key,
                            name = ns.tblInvalidZones[key].name,
                            reason = ns.tblInvalidZones[key].reason
                        }
                        zoneOut()
                    end,
                },
                ZoneInstructions = {
                    order = 90,
                    name = L['ZONE_ID_DESC'],
                    type = 'description',
                    fontSize = 'medium',
                },
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
    }
}