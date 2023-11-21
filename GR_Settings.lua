local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local icon = LibStub('LibDBIcon-1.0')

local accountWide = ns.code:cText('ff00ff00', '* ')

-- Determine the length of a message
local function MessageLength(msg)
    if not msg or msg == '' then return false, 0, msg end

    local gd = ns.dbGlobal.guildInfo
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

local tblMessage = newMsg()
local tblGMMessage = newMsg()

local gmActiveMessage, invActiveMessage = nil, nil

BL_DAYS_TO_WAIT = 14

ns.addonSettings = {
    name = L['TITLE']..' ('..GR.version..')',
    type = 'group',
    args = {
        grSettings = {
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
                    name = accountWide..L['GEN_TOOLTIPS'],
                    desc = L['GEN_TOOLTIP_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gSettings.showToolTips = val end,
                    get = function() return ns.gSettings.showToolTips end,
                },
                genIcon = {
                    order = 2,
                    name = L['GEN_ICON'],
                    desc = L['GEN_ICON_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val)
                        ns.settings.minimap = { hide = not val }
                        if not ns.settings.minimap.hide then icon:Show('GR_Icon')
                        else icon:Hide('GR_Icon') end
                    end,
                    get = function() return not ns.settings.minimap.hide end,
                },
                genContext = {
                    order = 3,
                    name = L['GEN_CONTEXT'],
                    desc = L['GEN_CONTEXT_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.settings.showContextMenu = val end,
                    get = function() return ns.settings.showContextMenu end,
                },
                genHeading2 = {
                    order = 4,
                    name = L['Addon Messages'],
                    type = 'header',
                },
                genWhatsNew = {
                    order = 5,
                    name = accountWide..L['GEN_WHATS_NEW'],
                    desc = L['GEN_WHATS_NEW_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.db.global.showWhatsNew = val end,
                    get = function() return ns.db.global.showWhatsNew end,
                },
                genAddonMessages = {
                    order = 6,
                    name = L['GEN_ADDON_MESSAGES'],
                    desc = L['GEN_ADDON_MESSAGES_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.settings.showAppMsgs = val end,
                    get = function() return ns.settings.showAppMsgs end,
                },
                genHeader3 = {
                    name = L['Keybindings'],
                    type = 'header',
                    order = 7
                },
                genKeybindingInvite = {
                    order = 8,
                    name = accountWide..L['Keybinding: Invite'],
                    desc = L['KEYBINDING_DESC'],
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.db.global.keybindInvite = nil
                        elseif val and val == ns.db.global.keybindScan then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.db.global.keybindInvite = val end
                    end,
                    get = function() return ns.db.global.keybindInvite end,
                },
                genSpacer = {
                    order = 9,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                genKeybindingScan = {
                    order = 10,
                    name = accountWide..L['Keybinding: Scan'],
                    desc = L['KEBINDING_SCAN_DESC'],
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.db.global.keybindScan = nil
                        elseif val and val == ns.db.global.keybindInvite then
                            ns.code:fOut(L['KEY_BOUND_TO_INVITE'])
                            return
                        else ns.db.global.keybindScan = val end
                    end,
                    get = function() return ns.db.global.keybindScan end,
                },
                genNoteKeybind = {
                    order = 11,
                    name = ns.code:cText('FF00FF00', L['KEY_BINDING_NOTE']),
                    type = 'description',
                    fontSize = 'medium',
                },
                genHeading3 = {
                    order = 90,
                    name = 'Debug Settings (Used for testing)',
                    type = 'header',
                },
                genShowDebug = {
                    order = 91,
                    name = 'Show Debug Messages',
                    desc = 'Show/Hide debug messages.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.settings.debugMode = val end,
                    get = function() return ns.settings.debugMode end,
                },
                genDisableAutoSync = {
                    order = 92,
                    name = 'Disable Auto Sync',
                    desc = 'Disables auto sync with guild members.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.settings.debugAutoSync = val end,
                    get = function() return ns.settings.debugAutoSync end,
                },
                genHeadingAW = {
                    order = 100,
                    name = accountWide..L['GEN_ACCOUNT_WIDE'],
                    type = 'header',
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
            name = 'GM Settings',
            type = 'group',
            order = 2,
            args = {
                gmHeading1 = {
                    order = 0,
                    name = L['GM Settings'],
                    type = 'header',
                },
                gmSettingsDesc = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', L['GM_SETTINGS_DESC']),
                    type = 'description',
                    fontSize = 'medium',
                },
                gmHeading2 = {
                    order = 2,
                    name = L['Anti-Spam Settings'],
                    type = 'header',
                },
                gmAntiSpam = {
                    order = 3,
                    name = L['GM_ANTI_SPAM'],
                    desc = L['GM_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1,
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.antiSpam = val end,
                    get = function() return ns.gmSettings.antiSpam end,
                },
                gmAntiSpamDays = {
                    order = 4,
                    name = L['GM_ANTI_SPAM_DAYS'],
                    desc = L['GM_ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1.5,
                    disabled = function() return not ns.isGuildLeader end,
                    values = function()
                        return {
                            [7] = '7 days',
                            [14] = '14 days',
                            [30] = '30 days (1 month)',
                            [190] = '190 days (3 months)',
                            [380] = '380 days (6 months)',
                        }
                    end,
                    set = function(_, val) ns.gmSettings.antiSpamDays = val end,
                    get = function() return ns.gmSettings.antiSpamDays or 7 end,
                },
                gmHeading3 = {
                    order = 5,
                    name = L['Welcome Message'],
                    type = 'header',
                },
                gmSendWelcome = {
                    order = 6,
                    name = L['GM_SEND_WELCOME'],
                    desc = L['GM_SEND_WELCOME_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.sendWelcome = val end,
                    get = function() return ns.gmSettings.sendWelcome end,
                },
                gmWelcomeMessage = {
                    order = 7,
                    name = L['GM_WELCOME_MESSAGE'],
                    desc = L['GM_WELCOME_MESSAGE_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.welcomeMessage = val end,
                    get = function() return ns.gmSettings.welcomeMessage end,
                },
                gmHeading4 = {
                    order = 8,
                    name = L['Greeting Message'],
                    type = 'header',
                },
                gmSendGreeting = {
                    order = 9,
                    name = L['GM_SEND_GREETING'],
                    desc = L['GM_SEND_GREETING_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.sendGreeting = val end,
                    get = function() return ns.gmSettings.sendGreeting end,
                },
                gmGreetingMessage = {
                    order = 10,
                    name = L['GM_GREETING_MESSAGE'],
                    desc = L['GM_GREETING_MESSAGE_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) ns.gmSettings.greetingMessage = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return ns.gmSettings.greetingMessage end,
                },
                gmPreviewCount = {
                    order = 11,
                    name = function()
                        local playerNameFound, count = MessageLength(ns.gmSettings.greetingMessage)

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return L['Message Length']..': '..ns.code:cText(color, count)..' '..L['(255 characters per message)']..(playerNameFound and '\n'..L['assumes 12 characters when using PLAYERNAME).'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
            }
        },
        gmMessageList = {
            order = 3,
            name = L['GM Messages'],
            type = 'group',
            args = {
                gmMessageListHeading1 = {
                    order = 0,
                    name = L['GM Messages'],
                    type = 'header',
                },
                gmMessageListDesc = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', L['GM_SETTINGS_DESC']),
                    type = 'description',
                    fontSize = 'medium',
                },
                gmMessageListHeading2 = {
                    order = 2,
                    name = 'Guild Master Messages',
                    type = 'header',
                },
                gmMessageListInstructions = {
                    order = 3,
                    name = function()
                        local msg = ns.code:cText('FF00FF00', L['GM_MESSAGE_DESC_1'])..'\n\n'
                        msg = msg..ns.code:cText('FFFFFF00', L['GUILDLINK'])..L['GM_MESSAGE_DESC_2']..'\n'
                        msg = msg..ns.code:cText('FFFFFF00', L['GUILDNAME'])..L['GM_MESSAGE_DESC_3']..ns.dbGlobal.guildInfo.guildName..').\n'
                        msg = msg..ns.code:cText('FFFFFF00', L['PLAYERNAME'])..L['GM_MESSAGE_DESC_4']

                        return msg
                    end,
                    type = 'description',
                    fontSize = 'medium',
                },
                gmMessageListHeading3 = {
                    order = 4,
                    name = '',
                    type = 'header',
                },
                msgGMActive = {
                    order = 5,
                    name = L['GM_MESSAGE_ACTIVE'],
                    desc = L['GM_MESSAGE_ACTIVE_DESC'],
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
                    order = 6,
                    name = L['New'],
                    desc = L['NEW_DESC'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return not gmActiveMessage end,
                    hidden = function() return not ns.isGuildLeader end,
                    func = function()
                        tblGMMessage = newMsg()
                        gmActiveMessage = nil
                    end,
                },
                msgGMInviteDesc = {
                    order = 7,
                    name = L['Invite Description'],
                    desc = L['Short description of the message.'],
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) tblGMMessage.desc = val end,
                    get = function() return tblGMMessage.desc or '' end,
                },
                msgGMInviteMessage = {
                    order = 8,
                    name = 'Invite Message',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) tblGMMessage.message = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return tblGMMessage.message or '' end,
                },
                msgGMHeader4 = {
                    order = 9,
                    name = 'Message Preview',
                    type = 'header',
                    hidden = function() return tblGMMessage.message == '' end,
                },
                msgGMPreview = {
                    order = 9,
                    name = function()
                        local preview = ns.code:variableReplacement(tblGMMessage.message, UnitName('player'))
                        if tblGMMessage.message == '' then return '' end

                        local msg = (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
                        msg = msg:gsub(L['No Guild Link'], ns.code:cText('FFFF0000', L['No Guild Link']))
                        msg = msg:gsub(L['No Guild Name'], ns.code:cText('FFFF0000', L['No Guild Name']))
                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                    hidden = function() return tblGMMessage.message == '' end,
                },
                msgGMPreviewCount = {
                    order = 11,
                    name = function()
                        local playerNameFound, count = MessageLength((tblGMMessage.message or ''))

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        local msg = L['Message Length']..': '
                        msg = msg..ns.code:cText(color, count)..' '..L['(255 characters per message)']
                        msg = msg..(playerNameFound and '\n'..L['assumes 12 characters when using PLAYERNAME).'] or '')

                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                msgGMHeader5 = {
                    order = 12,
                    name = '',
                    type = 'header',
                },
                msgGMInviteDel = {
                    order = 13,
                    name = L['Delete'],
                    desc = L['DELETE_DESC'],
                    type = 'execute',
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    width = .5,
                    disabled = function() return not gmActiveMessage and true or false end,
                    hidden = function() return not ns.isGuildLeader end,
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
                    order = 14,
                    name = L['Save'],
                    desc = L['SAVE_DESC'],
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblGMMessage then return true end
                        return not ((tblGMMessage.desc and strlen(tblGMMessage.desc) > 0) and (tblGMMessage.message and strlen(tblGMMessage.message) > 0)) end,
                    hidden = function() return not ns.isGuildLeader end,
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
            }
        },
        blankHeader2 = {
            order = 4,
            name = ' ',
            type = 'group',
            args = {}
        },
        inviteSettings = {
            order = 5,
            name = L['Invite Settings'],
            type = 'group',
            args = {
                invHeader1 = {
                    name = L['Invite Settings'],
                    type = 'header',
                    order = 0,
                },
                invShowInvite = {
                    order = 1,
                    name = L['SHOW_WHISPERS'],
                    desc = L['SHOW_WHISPERS_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.settings.showWhispers = val end,
                    get = function() return ns.settings.showWhispers end,
                },
                invShowInviteMsg = {
                    order = 2,
                    name = ns.code:cText('FF00FF00', L['RELOAD_NOTE']),
                    type = 'description',
                    fontSize = 'medium',
                },
                invScanInterval = {
                    order = 3,
                    name = accountWide..L['SCAN_WAIT_TIME'],
                    desc = L['SCAN_WAIT_TIME_DESC'],
                    type = 'input',
                    width = 'full',
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then ns.gSettings.scanWaitTime = tonumber(val)
                        else return tostring(ns.gSettings.scanWaitTime) end
                    end,
                    get = function() return tostring(ns.gSettings.scanWaitTime) end,
                },
                InvWhoNote = {
                    order = 4,
                    name = ns.code:cText('FFFFFF00', L['SCAN_WAIT_TIME_NOTE']),
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                invHeader2 = {
                    name = L['Anti-Spam Settings'],
                    type = 'header',
                    order = 5,
                },
                invAntiSpamEnable = {
                    order = 6,
                    name = accountWide..L['ENABLE_ANTI_SPAM'],
                    desc = L['ANTI_SPAM_DESC'],
                    type = 'toggle',
                    disabled = function() return ns.gmSettings.antiSpam end,
                    width = 1.5,
                    set = function(_, val) ns.gSettings.antiSpam = val end,
                    get = function()
                        if ns.gmSettings.antiSpam then return ns.gmSettings.antiSpam
                        else return ns.gSettings.antiSpam end
                    end,
                },
                invAntiSpamInterval = {
                    order = 7,
                    name = accountWide..L['GM_ANTI_SPAM_DAYS'],
                    desc = L['GM_ANTI_SPAM_DAYS_DESC'],
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
                        if ns.gmSettings.antiSpam then return ns.gmSettings.antiSpamDays
                        else return ns.gSettings.antiSpamDays or 7 end
                    end,
                },
                invHeader3 = {
                    name = L['Welcome Message'],
                    type = 'header',
                    order = 8,
                },
                invSendWelcome = {
                    order = 9,
                    name = accountWide..L['SEND_WELCOME'],
                    desc = L['SEND_WELCOME_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendWelcome end,
                    set = function(_, val) ns.gSettings.sendWelcome = val end,
                    get = function()
                        if ns.gmSettings.sendWelcome then return ns.gmSettings.sendWelcome
                        else return ns.gSettings.sendWelcome end
                    end,
                },
                invWelcomeMessage = {
                    order = 10,
                    name = accountWide..L['GM_WELCOME_MESSAGE'],
                    desc = L['WELCOME_MESSAGE_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendWelcome end,
                    set = function(_, val) ns.gSettings.welcomeMessage = val end,
                    get = function()
                        if ns.gmSettings.sendWelcome then return ns.gmSettings.welcomeMessage
                        else return ns.gSettings.welcomeMessage end
                    end,
                },
                invHeading4 = {
                    order = 11,
                    name = L['Greeting Message'],
                    type = 'header',
                },
                invSendGreeting = {
                    order = 12,
                    name = accountWide..L['SEND_GREETING'],
                    desc = L['SEND_GREETING_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendGreeting end,
                    set = function(_, val) ns.gSettings.sendGreeting = val end,
                    get = function()
                        if ns.gmSettings.sendGreeting then return ns.gmSettings.sendGreeting
                        else return ns.gSettings.sendGreeting end
                    end,
                },
                invGreetingMessage = {
                    order = 13,
                    name = accountWide..L['GM_GREETING_MESSAGE'],
                    desc = L['GREETING_MESSAGE_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return ns.gmSettings.sendGreeting end,
                    set = function(_, val) ns.gSettings.greetingMessage = ns.code:capitalKeyWord(val:trim()) end,
                    get = function()
                        if ns.gmSettings.sendGreeting then return ns.gmSettings.greetingMessage
                        else return ns.gSettings.greetingMessage end
                    end,
                },
                invPreviewCount = {
                    order = 14,
                    name = function()
                        local playerNameFound, count = MessageLength(ns.gSettings.greetingMessage)

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return L['Message Length']..': '..ns.code:cText(color, count)..' '..L['(255 characters per message)']..(playerNameFound and '\n'..L['assumes 12 characters when using PLAYERNAME).'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                    hidden = function() return ns.gmSettings.sendGreeting end,
                },
                invHeadingAW = {
                    order = 100,
                    name = accountWide..L['GEN_ACCOUNT_WIDE'],
                    type = 'header',
                },
                invHeadingNote = {
                    order = 101,
                    name = ns.code:cText('FFFFFF00', L['GM_DISABLE_NOTE']),
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
            }
        },
        inviteMessages = {
            order = 6,
            name = L['Invite Messages'],
            type = 'group',
            args = {
                invMessageListHeading2 = {
                    order = 0,
                    name = L['Invite Messages'],
                    type = 'header',
                },
                invMessageListInstructions = {
                    order = 1,
                    name = function()
                        local msg = ns.code:cText('FFFFFF00', L['GUILDLINK'])..L['GM_MESSAGE_DESC_2']..'\n'
                        msg = msg..ns.code:cText('FFFFFF00', L['GUILDNAME'])..L['GM_MESSAGE_DESC_3']..ns.dbGlobal.guildInfo.guildName..').\n'
                        msg = msg..ns.code:cText('FFFFFF00', L['PLAYERNAME'])..L['GM_MESSAGE_DESC_4']

                        return msg
                    end,
                    type = 'description',
                    fontSize = 'medium',
                },
                invActiveMessageMessageListHeading3 = {
                    order = 2,
                    name = '',
                    type = 'header',
                },
                invActive = {
                    order = 5,
                    name = L['GM_MESSAGE_ACTIVE'],
                    desc = L['GM_MESSAGE_ACTIVE_DESC'],
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
                    name = L['New'],
                    desc = L['NEW_DESC'],
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
                    name = L['Invite Description'],
                    desc = L['Short description of the message.'],
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) tblMessage.desc = val end,
                    get = function() return tblMessage.desc or '' end,
                },
                invInviteMessage = {
                    order = 8,
                    name = 'Invite Message',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
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
                        msg = msg:gsub(L['No Guild Link'], ns.code:cText('FFFF0000', L['No Guild Link']))
                        msg = msg:gsub(L['No Guild Name'], ns.code:cText('FFFF0000', L['No Guild Name']))
                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                    hidden = function() return tblMessage.message == '' end,
                },
                invPreviewCount = {
                    order = 11,
                    name = function()
                        local playerNameFound, count = MessageLength((tblMessage.message or ''))

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        local msg = L['Message Length']..': '
                        msg = msg..ns.code:cText(color, count)..' '..L['(255 characters per message)']
                        msg = msg..(playerNameFound and '\n'..L['assumes 12 characters when using PLAYERNAME).'] or '')

                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                invHeader5 = {
                    order = 12,
                    name = '',
                    type = 'header',
                },
                invInviteDel = {
                    order = 13,
                    name = L['Delete'],
                    desc = L['DELETE_DESC'],
                    type = 'execute',
                    confirm = function() return 'Are you sure you want to delete this message?' end,
                    width = .5,
                    disabled = function() return not invActiveMessage and true or false end,
                    hidden = function() return not ns.isGuildLeader end,
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
                    order = 14,
                    name = L['Save'],
                    desc = L['SAVE_DESC'],
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblMessage then return true end
                        return not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0)) end,
                    hidden = function() return not ns.isGuildLeader end,
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
            }
        },
        blankHeader3 = {
            order = 7,
            name = ' ',
            type = 'group',
            args = {}
        },
        blackList = {
            name = L['Black List'],
            type = 'group',
            order = 10,
            args = {
                blHeader1 = {
                    order = 0,
                    name = L['Black List'],
                    type = 'header',
                },
                blDesc = {
                    order = 1,
                    name = function()
                        local msg = string.format(L['Players marked in %s are marked for deletion.'], ns.code:cText('FFFF0000', 'RED'))..'\n'
                        msg = msg..string.format(L['Players marked in %s are active black listed players.'], ns.code:cText('FFFFFF00', 'YELLOW'))..'\n'
                        msg = msg..string.format(L['Players marked in %s are able to be removed from the list now.'], ns.code:cText('FF00FF00', 'GREEN'))

                        return msg
                    end,
                    type = 'description',
                    fontSize = 'medium',
                },
                blHeader2 = {
                    order = 2,
                    name = '',
                    type = 'header',
                },
                blRemoveButton = {
                    name = L['Remove Selected Black List Entries'],
                    desc = L['BLACK_LIST_REMOVE_DESC'],
                    type = 'execute',
                    width = 'full',
                    order = 3,
                    func = function()
                        for k, r in pairs(ns.tblBlackList and ns.tblBlackList or {}) do
                            if r.selected and not r.sent then ns.tblBlackList[k] = nil
                            elseif r.selected and not r.markedForDelete then
                                r.markedForDelete = true
                                r.expirationDate = C_DateAndTime.GetServerTimeLocal() + (BL_DAYS_TO_WAIT * SECONDS_IN_A_DAY)
                            elseif r.selected and r.markedForDelete then
                                r.markedForDelete = false
                                r.expirationDate = nil
                            end

                            if r.selected then r.selected = false end
                        end

                        ns.code:saveTables('BLACK_LIST')
                    end,
                },
                blHeader3 = {
                    order = 4,
                    name = '',
                    type = 'header',
                },
                blMultiSelect = {
                    order = 5,
                    type = 'multiselect',
                    name = 'Black Listed Players',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.tblBlackList or {}) do
                            local name = k
                            name = r.markedForDelete and ns.code:cText('FFFF0000', name) or (not r.sent and ns.code:cText('FF00FF00', name) or ns.code:cText('FFFFFF00', name))
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
            name = L['Invalid Zone List'],
            type = 'group',
            order = 11,
            args = {
                zonesHeader1 = {
                    order = 0,
                    name = L['Invalid Zone List'],
                    type = 'header',
                },
                zonesList = {
                    order = 1,
                    name = L['ZONE_LIST_NAME'],
                    type = 'multiselect',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        local tblZones = ns.code:sortTableByField(ns.tblBadZonesByName, 'name', true)
                        for _, r in pairs(tblZones or {}) do tbl[r.key] = ns.code:cText('FFFFFF00', r.name)..' ('..r.reason..')' end
                        return tbl
                    end,
                },
                zonesDesc = {
                    order = 2,
                    name = L['ZONE_LIST_NOTE'],
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
            name = L['About GR'],
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
                    name = L['ABOUT_LINE_1'],
                    type = 'description',
                    fontSize = 'medium',
                },
                aboutHeader1 = {
                    order = 2,
                    name = L['Documentation Links'],
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
                    name = 'GitHub (Support documentation)',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://github.com/zaldor30/GuildRecruiter') end,
                    get = function() return 'https://github.com/zaldor30/GuildRecruiter' end,
                },
                aboutLink3 = {
                    order = 5,
                    name = 'Discord',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://discord.gg/ZtS6Q2sKRH') end,
                    get = function() return 'https://discord.gg/ZtS6Q2sKRH' end,
                },
                aboutHeader2 = {
                    order = 6,
                    name = string.format(L['Support %s Links'], L['TITLE']),
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