local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_CHARACTERS = 255
local bulletAccountWide = ns.code:cText('ff00ff00', '* ')
local bulletGuildWide = ns.code:cText('ffffff00', '* ')

local disableSaveButton = false
local tblAntiSpamSorted, tblBlackListSorted, tblFilter = nil, nil, {}
local activeZone, checkedZones, tblPlayerZone = nil, false, nil
local tblZoneList, tblZone = nil, {}

local activeMessage, isGMMessage, tblMessage = nil, false, {}
local function newMsg()
    return {
        desc = '',
        message = '',
        gmSync = ns.isGM,
    }
end

local getMessageLength = function(msg)
    if not msg or msg == '' then return false, 0, msg end

    local gd = ns.guildInfo
    local playerNameFound = false

    msg = ns.code:capitalKeyWord(msg:trim())
    playerNameFound = msg:match('PLAYERNAME') and true or false
    msg = msg:gsub('PLAYERNAME', '')

    local count = playerNameFound and 12 or 0
    count = count + ((msg:match('GUILDLINK') or (msg:match('GUILDNAME'))) and ((strlen(gd.guildName)) + 2) or 0)
    msg = msg:gsub('GUILDLINK', ''):gsub('GUILDNAME', '')

    return playerNameFound, ((count + (strlen(msg))) or 0)
end
function ns.newSettingsMessage() tblMessage = newMsg() end
local function GetInstructions()
    local msg = (ns.classic and L['MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC'] or L['MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1'])..'\n'..L['MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2']
    msg = not ns.classic and msg:gsub('GUILDLINK', ns.code:cText('FFFFFF00', L['GUILDLINK'])) or msg
    msg = msg:gsub('GUILDNAME', ns.code:cText('FFFFFF00', L['GUILDNAME']))
    msg = msg:gsub('PLAYERNAME', ns.code:cText('FFFFFF00', L['PLAYERNAME']))

    return msg
end
local tblASDays = {
    [7] = '7 days',
    [14] = '14 days',
    [30] = '30 days (1 month)',
    [90] = '90 days (3 months)',
    [180] = '180 days (6 months)',
}

ns.guildRecuriterSettings = {
    name = L['TITLE']..' '..GR.versionOut,
    type = 'group',
    args = {
        generalSettings = {
            name = L['GR_SETTINGS'],
            type = 'group',
            order = 1,
            args = {
                genHeading1 = {
                    order = 0,
                    name = L['GR_SETTINGS'],
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
                    width = 1.5,
                    set = function(_, val) ns.pSettings.showContextMenu = val end,
                    get = function() return ns.pSettings.showContextMenu or false end,
                },
                genCompactSize = {
                    order = 26,
                    name = bulletAccountWide..L['COMPACT_SIZE']..':',
                    desc = 'When in compact mode, select the size of the window.',
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    values = function()
                        return {
                            [1] = 'Normal',
                            [2] = 'Compact',
                        }
                    end,
                    set = function(_, val) ns.g.compactSize = tonumber(val) end,
                    get = function() return ns.g.compactSize or 1 end,
                },
                genScanInterval = {
                    order = 27,
                    name = bulletAccountWide..L['SCAN_WAIT_TIME'],
                    desc = L['SCAN_WAIT_TIME_DESC'],
                    type = 'input',
                    width = 1,
                    set = function(_, val)
                        if tonumber(val) >= 2 and tonumber(val) <= 10 then ns.g.scanWaitTime = val
                        else ns.frames:AcceptDialog('Enter value of 1 to 10.', function() return end) end
                    end,
                    get = function() return tostring(ns.g.scanWaitTime or 5) end,
                },
                genSendWaitTime = {
                    order = 28,
                    name = bulletAccountWide..L['SEND_MESSAGE_WAIT_TIME'],
                    desc = L['SEND_MESSAGE_WAIT_TIME_DESC'],
                    type = 'range',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    width = 1,
                    set = function(_, val) ns.g.timeBetweenMessages = tostring(val) end,
                    get = function() return tonumber(ns.g.timeBetweenMessages) or .2 end,
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
                genSpacer5 = {
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
            name = L['GM_INVITE_SETTINGS'],
            type = 'group',
            order = 11,
            hidden = function() return not ns.isGM end,
            args = {
                invHeader1 = {
                    name = L['GM_INVITE_SETTINGS'],
                    type = 'header',
                    order = 0,
                },
                invSettingsDesc1 = {
                    order = 1,
                    name = bulletGuildWide..L['GEN_GUILD_WIDE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                invSettingsDesc2 = {
                    order = 2,
                    name = bulletAccountWide..L['GEN_ACCOUNT_WIDE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                invHeading1 = {
                    order = 3,
                    name = '',
                    type = 'header',
                },
                invBlockGuildInvites = {
                    order = 4,
                    name = bulletGuildWide..L['ENABLE_BLOCK_INVITE_CHECK'],
                    desc = L['ENABLE_BLOCK_INVITE_CHECK_TOOLTIP'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gmSettings.obeyBlockInvites = val end,
                    get = function() return ns.gmSettings.obeyBlockInvites end,
                },
                invAntiSpamEnable = {
                    order = 5,
                    name = bulletGuildWide..L["ENABLE"]..' '..L['ANTI_SPAM'],
                    desc = L['ENABLE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) ns.gmSettings.antiSpam = val end,
                    get = function() return ns.gmSettings.antiSpam end,
                },
                invSpacer1 = {
                    order = 6,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                invAntiSpamInterval = {
                    order = 7,
                    name = bulletGuildWide..L['ANTI_SPAM_DAYS'],
                    desc = L['ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    values = function() return tblASDays end,
                    set = function(_, val) ns.gmSettings.antiSpamDays = tonumber(val) end,
                    get = function() return ns.gmSettings.antiSpamDays or 7 end,
                },
                invHeader2 = {
                    name = L['GUILD_WELCOME_MSG'],
                    type = 'header',
                    order = 20,
                },
                invForceGuildGreeting = {
                    order = 21,
                    name = bulletGuildWide..L['FORCE_OPTION']..' '..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gmSettings.forceSendGuildGreeting = val end,
                    get = function() return ns.gmSettings.forceSendGuildGreeting end,
                },
                invGuildGreeting = {
                    order = 22,
                    name = bulletGuildWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val)
                        ns.gmSettings.sendGuildGreeting = val
                        ns.invite:GetMessages()
                    end,
                    get = function() return ns.gmSettings.sendGuildGreeting end,
                },
                invGuildWelcomeMessage = {
                    order = 23,
                    name = bulletGuildWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.frames:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gmSettings.guildMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetMessages()
                    end,
                    get = function() return ns.gmSettings.guildMessage end,
                },
                invHeader3 = {
                    name = L['WHISPER_WELCOME_MSG'],
                    type = 'header',
                    order = 24,
                },
                gmForceWelcomeWhisper = {
                    order = 25,
                    name = bulletGuildWide..L['FORCE_OPTION']..' '..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gmSettings.forceSendWhisper = val end,
                    get = function() return ns.gmSettings.forceSendWhisper end,
                },
                gmWelcomeWhisper = {
                    order = 26,
                    name = bulletGuildWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.gmSettings.sendWhisperGreeting = val end,
                    get = function() return ns.gmSettings.sendWhisperGreeting end,
                },
                gmWelcomeWhisperMessage = {
                    order = 27,
                    name = bulletGuildWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.frames:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.gmSettings.whisperMessage = ns.code:capitalKeyWord(val:trim())
                    end,
                    get = function() return ns.gmSettings.whisperMessage end,
                },
                invHeader4 = {
                    name = 'Message Instructions',
                    type = 'header',
                    order = 90,
                },
                GMMessageListInstructions = {
                    order = 91,
                    name = function() return GetInstructions() end,
                    type = 'description',
                    fontSize = 'medium',
                },
            }
        },
        gmInviteMessageList = {
            name = L['GM_INVITE_MESSAGES'],
            type = 'group',
            order = 12,
            hidden = function() return not ns.isGM end,
            args = {
                gmMessageListHeading = {
                    order = 0,
                    name = L['GM_INVITE_MESSAGES'],
                    type = 'header',
                },
                gmDropdownList = {
                    order = 1,
                    name = L['GM_INVITE_MESSAGES'],
                    desc = L['INVITE_ACTIVE_MESSAGE_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    values = function()
                        local tbl, recordFound = {}, false
                        tblMessage = tblMessage or newMsg()
                        for k, r in pairs(ns.guild.messageList or {}) do
                            tbl[k] = r.desc
                            recordFound = true
                        end
                        if recordFound then tbl['default'] = 'Select a message or create a new one.'
                        else tbl['default'] = 'Create new message by entering a description.' end

                        return tbl
                    end,
                    set = function(_, val)
                        activeMessage = val
                        tblMessage = ns.guild.messageList[val] or newMsg()
                    end,
                    get = function()
                        local msg = ns.guild.messageList or nil
                        local active = activeMessage or nil

                        return active or 'default'
                    end,
                },
                gmNewButton = {
                    order = 2,
                    name = L['NEW'],
                    desc = L['NEW_MESSAGE_DESC'],
                    type = 'execute',
                    width = .5,
                    hidden = function() return not activeMessage end,
                    func = function()
                        isGMMessage = false
                        activeMessage = nil
                        tblMessage = newMsg()
                    end,
                },
                gmInviteDesc = {
                    order = 3,
                    name = L['INVITE_DESC'],
                    desc = L['INVITE_DESC_TOOLTIP'],
                    type = 'input',
                    multiline = false,
                    width = 1.5,
                    set = function(_, val)
                        if not tblMessage then tblMessage = newMsg() end

                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.frames:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end

                        tblMessage.desc = val end,
                    get = function() return tblMessage and tblMessage.desc or '' end,
                },
                gmSync = {
                    order = 4,
                    name = L['SYNC_MESSAGES'],
                    desc = L['SYNC_MESSAGES_DESC'],
                    type = 'toggle',
                    width = 1,
                    set = function(_, val) tblMessage.gmSync = val end,
                    get = function() return tblMessage.gmSync end,
                },
                gmInviteMessage = {
                    order = 6,
                    name = L['INVITE_MESSAGES']..':',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    set = function(_, val)
                        if not tblMessage then tblMessage = newMsg() end
                        tblMessage.message = ns.code:capitalKeyWord(val:trim()) end,
                    get = function() return tblMessage and tblMessage.message or '' end,
                },
                gmPreview = {
                    order = 7,
                    name = function()
                        if not tblMessage then return '' end

                        local preview = ns.code:variableReplacement(tblMessage.message, UnitName('player'))
                        if tblMessage.message == '' then return '' end

                        local msg = (ns.code:cText('FFFF80FF', 'To [')..ns.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
                        msg = msg:gsub(L['GUILD_LINK_NOT_FOUND'], ns.code:cText('FFFF0000', L['GUILD_LINK_NOT_FOUND']))
                        msg = msg:gsub(L['NO_GUILD_NAME'], ns.code:cText('FFFF0000', L['NO_GUILD_NAME']))

                        return msg
                    end,
                    hidden = function() return not tblMessage or not tblMessage.message end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                gmPreviewCount = {
                    order = 8,
                    name = function()
                        if not tblMessage then return '' end

                        local playerNameFound, count = getMessageLength(tblMessage.message)

                        local msg = L['MAX_CHARS']
                        local color = count < MAX_CHARACTERS and 'FF00FF00' or 'FFFF0000'
                        disableSaveButton = count >= MAX_CHARACTERS or false
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', MAX_CHARACTERS)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                gmHeader5 = {
                    order = 20,
                    name = '',
                    type = 'header',
                    hidden = function()
                        if not tblMessage then return true end
                        return isGMMessage or (not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0))) end,
                },
                gmInviteSave = {
                    order = 21,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return disableSaveButton end,
                    hidden = function()
                        if not tblMessage then return true end
                        return isGMMessage or (not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0))) end,
                    func = function()
                        local tbl = ns.guild.messageList or {}
                        local active = activeMessage
                        tbl.message = tbl.message and ns.code:capitalKeyWord(tbl.message or '') or ''

                        if not active then
                            tinsert(tbl, tblMessage)
                            active = #tbl
                        else tbl[active] = tblMessage end
                        ns.guild.messageList = tbl

                        tblMessage = newMsg()
                        activeMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 0, 1, 0, 1)
                    end,
                },
                gmSpacer = {
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
                    hidden = function() return isGMMessage or not activeMessage end,
                    func = function()
                        local msg = ns.guild.messageList or nil
                        local active = activeMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            tblMessage = newMsg()
                        end

                        activeMessage = nil
                        if ns.pSettings.activeMessage then ns.pSettings.activeMessage = nil end
                    end,
                },
                gmHeader4 = {
                    name = 'Message Instructions',
                    type = 'header',
                    order = 90,
                },
                gmMessageListInstructions = {
                    order = 91,
                    name = function() return GetInstructions() end,
                    type = 'description',
                    fontSize = 'medium',
                },
            }
        },
        playerInviteSettings = {
            name = L['INVITE_SETTINGS'],
            type = 'group',
            order = 11,
            hidden = function() return ns.isGM end,
            args = {
                invHeader1 = {
                    name = L['INVITE_SETTINGS'],
                    type = 'header',
                    order = 0,
                },
                invSettingsDesc1 = {
                    order = 1,
                    name = bulletGuildWide..L['GEN_GUILD_WIDE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                invSettingsDesc2 = {
                    order = 2,
                    name = bulletAccountWide..L['GEN_ACCOUNT_WIDE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                invSettingsDesc3 = {
                    order = 3,
                    name = ns.code:cText('FFFFFF00', L['ENABLED_NOTE']),
                    type = 'description',
                    fontSize = 'medium',
                },
                invHeading1 = {
                    order = 4,
                    name = '',
                    type = 'header',
                },
                invBlockGuildInvites = {
                    order = 5,
                    name = bulletGuildWide..L['ENABLE_BLOCK_INVITE_CHECK'],
                    desc = L['ENABLE_BLOCK_INVITE_CHECK_TOOLTIP'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmActive and ns.gmSettings.obeyBlockInvites or false end,
                    set = function(_, val) ns.gSettings.obeyBlockInvites = val end,
                    get = function() return (ns.gmActive and ns.gmSettings.obeyBlockInvites) and ns.gmSettings.obeyBlockInvites or ns.gSettings.obeyBlockInvites end,
                },
                invAntiSpamEnable = {
                    order = 6,
                    name = bulletGuildWide..L["ENABLE"]..' '..L['ANTI_SPAM'],
                    desc = L['ENABLE_ANTI_SPAM_DESC'],
                    type = 'toggle',
                    width = 1,
                    disabled = function() return ns.gmActive and ns.gmSettings.antiSpam or false end,
                    set = function(_, val) ns.gSettings.antiSpam = val end,
                    get = function() return (ns.gmActive and ns.gmSettings and ns.gmSettings.antiSpam) and ns.gmSettings.antiSpam or ns.gSettings.antiSpam end,
                },
                invSpacer1 = {
                    order = 7,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                invAntiSpamInterval = {
                    order = 8,
                    name = bulletGuildWide..L['ANTI_SPAM_DAYS'],
                    desc = L['ANTI_SPAM_DAYS_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    disabled = function() return ns.gmActive and ns.gmSettings.antiSpam or false end,
                    values = function() return tblASDays end,
                    set = function(_, val) ns.gSettings.antiSpamDays = tonumber(val) end,
                    get = function() return (ns.gmActive and ns.gmSettings.antiSpam) and (ns.gmSettings.antiSpamDays or 7) or (ns.gSettings.antiSpamDays or 7) end,
                },
                invHeader2 = {
                    name = L['GUILD_WELCOME_MSG'],
                    type = 'header',
                    order = 20,
                },
                invGuildGreeting = {
                    order = 21,
                    name = bulletGuildWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmSettings.forceSendGuildGreeting end,
                    set = function(_, val)
                        ns.pSettings.sendGuildGreeting = val
                        ns.invite:GetMessages()
                    end,
                    get = function() return ns.gmSettings.forceSendGuildGreeting and ns.gmSettings.sendGuildGreeting or ns.pSettings.sendGuildGreeting end,
                },
                invGuildWelcomeMessage = {
                    order = 23,
                    name = bulletGuildWide..L['GUILD_WELCOME_MSG'],
                    desc = L['GUILD_WELCOME_MSG_DESC'],
                    type = 'input',
                    width = 'full',
                    disabled = function() return ns.gmSettings.forceGuildMessage end,
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.frames:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.pSettings.guildMessage = ns.code:capitalKeyWord(val:trim())
                        ns.invite:GetMessages()
                    end,
                    get = function() return ns.gmSettings.forceGuildMessage and ns.gmSettings.guildMessage or ns.pSettings.guildMessage end,
                },
                invHeader3 = {
                    name = L['WHISPER_WELCOME_MSG'],
                    type = 'header',
                    order = 24,
                },
                invWelcomeWhisper = {
                    order = 25,
                    name = bulletGuildWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.gmSettings.forceSendWhisper end,
                    set = function(_, val) ns.pSettings.sendWhisperGreeting = val end,
                    get = function() return ns.gmSettings.forceSendWhisper or ns.pSettings.sendWhisperGreeting end,
                },
                invWelcomeWhisperMessage = {
                    order = 26,
                    name = bulletGuildWide..L['WHISPER_WELCOME_MSG'],
                    desc = L['WHISPER_WELCOME_MSG_DESC'],
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return ns.gmSettings.forceWhisperMessage end,
                    set = function(_, val)
                        local _, len = getMessageLength(val)
                        if len >= MAX_CHARACTERS then
                            ns.frames:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end
                        ns.pSettings.whisperMessage = ns.code:capitalKeyWord(val:trim())
                    end,
                    get = function() return ns.gmSettings.forceWhisperMessage and ns.gmSettings.whisperMessage or ns.pSettings.whisperMessage end,
                },
                invHeader4 = {
                    name = 'Message Instructions',
                    type = 'header',
                    order = 90,
                },
                MessageListInstructions = {
                    order = 91,
                    name = function() return GetInstructions() end,
                    type = 'description',
                    fontSize = 'medium',
                },
            }
        },
        invInviteMessageList = {
            name = L['INVITE_MESSAGES'],
            type = 'group',
            order = 12,
            hidden = function() return ns.isGM end,
            args = {
                invMessageListHeading = {
                    order = 0,
                    name = L['INVITE_MESSAGES'],
                    type = 'header',
                },
                invMessageListDesc = {
                    order = 1,
                    name = L['PLAYER_SETTINGS_DESC']:gsub('Orange', ns.code:cText(ns.COLOR_GM, 'Orange')),
                    type = 'description',
                    fontSize = 'medium',
                },
                invMessageListHeading2 = {
                    order = 2,
                    name = '',
                    type = 'header',
                },
                invDropdownList = {
                    order = 3,
                    name = L['INVITE_ACTIVE_MESSAGE'],
                    desc = L['INVITE_ACTIVE_MESSAGE_DESC'],
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    disabled = function() return ns.gmSettings.forceMessageList end,
                    values = function()
                        local tbl, recordFound = {}, false
                        tblMessage = tblMessage or newMsg()
                        for k, r in pairs(ns.guild and ns.guild.messageList or {}) do
                            local desc = (r.gmSync or r.gmSync == nil) and ns.code:cText(ns.COLOR_GM, r.desc) or r.desc
                            recordFound = true
                            tbl[k] = desc
                        end
                        if recordFound then tbl['default'] = 'Select a message or create a new one.'
                        else tbl['default'] = 'Create new message by entering a description.' end

                        return tbl
                    end,
                    set = function(_, val)
                        activeMessage = val
                        tblMessage = ns.guild.messageList[val] or newMsg()
                    end,
                    get = function()
                        local msg = ns.guild.messageList or nil
                        local active = activeMessage or nil

                        if active and msg then
                            isGMMessage = msg[active].gmSync or false
                            tblMessage = msg[active] or newMsg()
                            tblMessage.gmSync = false
                        elseif not msg then activeMessage = nil end

                        return active or 'default'
                    end,
                },
                invNewButton = {
                    order = 4,
                    name = L['NEW'],
                    desc = L['NEW_MESSAGE_DESC'],
                    type = 'execute',
                    width = .5,
                    hidden = function() return not activeMessage end,
                    func = function()
                        isGMMessage = false
                        activeMessage = nil
                        tblMessage = newMsg()
                    end,
                },
                invInviteDesc = {
                    order = 5,
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
                            ns.frames:AcceptDialog(L['MAX_CHARS']:gsub('<sub>', MAX_CHARACTERS), function() return end)
                            return
                        end

                        tblMessage.desc = val end,
                    get = function() return tblMessage and tblMessage.desc or '' end,
                },
                invInviteMessage = {
                    order = 6,
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
                    order = 7,
                    name = function()
                        if not tblMessage then return '' end

                        local preview = ns.code:variableReplacement(tblMessage.message, UnitName('player'))
                        if tblMessage.message == '' then return '' end

                        local msg = (ns.code:cText('FFFF80FF', 'To [')..ns.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
                        msg = msg:gsub(L['GUILD_LINK_NOT_FOUND'], ns.code:cText('FFFF0000', L['GUILD_LINK_NOT_FOUND']))
                        msg = msg:gsub(L['NO_GUILD_NAME'], ns.code:cText('FFFF0000', L['NO_GUILD_NAME']))

                        return msg
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                    hidden = function() return not tblMessage or not tblMessage.message end,
                },
                invPreviewCount = {
                    order = 8,
                    name = function()
                        if not tblMessage then return '' end

                        local playerNameFound, count = getMessageLength(tblMessage.message)

                        local msg = L['MAX_CHARS']
                        local color = count < MAX_CHARACTERS and 'FF00FF00' or 'FFFF0000'
                        disableSaveButton = count >= MAX_CHARACTERS or false
                        return L['MESSAGE_LENGTH']..': '..ns.code:cText(color, count)..' '..msg:gsub('<sub>', MAX_CHARACTERS)..(playerNameFound and '\n'..L['LENGTH_INFO'] or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                invHeader5 = {
                    order = 20,
                    name = '',
                    type = 'header',
                    hidden = function()
                        if not tblMessage then return true end
                        return isGMMessage or (not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0))) end,
                },
                invInviteSave = {
                    order = 21,
                    name = L['SAVE'],
                    type = 'execute',
                    width = .5,
                    disabled = function() return disableSaveButton end,
                    hidden = function()
                        if not tblMessage then return true end
                        return isGMMessage or (not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0))) end,
                    func = function()
                        local tbl = ns.guild.messageList or {}
                        local active = activeMessage
                        tbl.message = tbl.message and ns.code:capitalKeyWord(tbl.message or '') or ''

                        if not active then
                            tinsert(tbl, tblMessage)
                            active = #tbl
                        else tbl[active] = tblMessage end
                        ns.guild.messageList = tbl

                        tblMessage = newMsg()
                        activeMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 0, 1, 0, 1)
                    end,
                },
                invSpacer = {
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
                    hidden = function() return isGMMessage or not activeMessage end,
                    func = function()
                        local msg = ns.guild.messageList or nil
                        local active = activeMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            tblMessage = newMsg()
                        end

                        activeMessage = nil
                        if ns.pSettings.activeMessage then ns.pSettings.activeMessage = nil end
                    end,
                },
                invHeader4 = {
                    name = 'Message Instructions',
                    type = 'header',
                    order = 90,
                },
                invMessageListInstructions = {
                    order = 91,
                    name = function() return GetInstructions() end,
                    type = 'description',
                    fontSize = 'medium',
                },
            }
        },
        blankHeader4 = {
            order = 20,
            name = '',
            type = 'group',
            args = {}
        },
        antiSpam = {
            name = L['ANTI_SPAM'],
            type = 'group',
            order = 30,
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
                asHeader2 = {
                    order = 2,
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
                        tblAntiSpamSorted = tblAntiSpamSorted or ns.code:sortTableByField(ns.tblAntiSpamList or {}, 'name')
                        for k, r in pairs(tblAntiSpamSorted or {}) do
                            tbl[k] = (r.name..': '..date("%m/%d/%Y %H:%M", r.date))
                        end

                        return tbl
                    end,
                    set = function(_, key, val) if not tblAntiSpamSorted then return end ns.tblAntiSpamList[tblAntiSpamSorted[key].key].selected = val end,
                    get = function(_, key) if not tblAntiSpamSorted then return end return ns.tblAntiSpamList[tblAntiSpamSorted[key].key].selected or false end,
                }
            }
        },
        blackList = {
            name = L['BLACKLIST'],
            type = 'group',
            order = 31,
            args = {
                blHeader1 = {
                    order = 0,
                    name = L['BLACKLIST'],
                    type = 'header',
                },
                blRemoveButton = {
                    name = L['BLACKLIST_REMOVE'],
                    type = 'execute',
                    width = 1.25,
                    confirm = function() return L['DELETE_CONFIRMATION'] end,
                    order = 1,
                    func = function()
                        ns.g.blackListRemoved = ns.g.blackListRemoved and ns.g.blackListRemoved or {}
                        for _, r in pairs(tblBlackListSorted or {}) do
                            if r.selected then
                                tinsert(ns.g.blackListRemoved, ns.tblBlackList[r.key])
                                ns.tblBlackList[r.key] = nil
                            end
                        end
                    end,
                },
                blPrivateReasonButton = {
                    name = L['BL_PRIVATE_REASON'],
                    desc = L['BL_PRIVATE_REASON_DESC'],
                    type = 'execute',
                    width = 1.25,
                    order = 2,
                    func = function()
                        for _, r in pairs(tblBlackListSorted or {}) do
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
                    set = function(_, key, val) if not tblBlackListSorted then return end tblBlackListSorted[key].selected = val end,
                    get = function(_, key) if not tblBlackListSorted then return end return tblBlackListSorted[key].selected or false end,
                }
            }
        },
        zoneList = {
            name = L['INVALID_ZONE'],
            type = 'group',
            order = 32,
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
                            ns.frames:AcceptDialog(L['ZONE_NOT_FOUND']..' '..val, function() return end)
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
                        ns.g.zoneList = ns.g.zoneList or {}
                        local key = strlower(tblZone.name)
                        ns.g.zoneList[key] = tblZone
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
                        for k, r in pairs(tblPlayerZone or {}) do
                            if r.selected then
                                ns.g.zoneList[k] = nil
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
                        for k, r in pairs(ns.g.zoneList or {}) do
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
                        if not tblPlayerZone then return false end

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
                        for k, r in pairs(ns.invalidZones or {}) do
                            tbl[k] = r.name..ns.code:cText('FFFFFF00', ' Reason: '..r.reason) end

                        return tbl
                    end,
                    set = function(_, key, val) return end,
                    get = function(_, key) return false end,
                }
            }
        },
        blankHeader6 = {
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
                    name = L['DONATION_MESSAGE'],
                    type = 'description',
                    fontSize = 'medium',
                },
                aboutHeader1 = {
                    order = 2,
                    name = L['SUPPORT_LINKS'],
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
                    name = L['DISCORD_LINK'],
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
