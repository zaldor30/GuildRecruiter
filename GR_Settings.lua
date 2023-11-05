-- Guild Recruiter Configuration Options
local _, ns = ... -- Namespace (myaddon, namespace)
local icon = LibStub('LibDBIcon-1.0')

local mPreview, gmPreview, selectedMessage, selectedGMMessage, selectedFilter, filterOld = nil, nil, nil, nil, nil, nil

local optTables = {}
function optTables:newMsg()
    return {
        desc = '',
        message = '',
    }
end
function optTables:newFilter()
    return {
        race = {},
        class = {},
        filter = nil,
        desc = nil,
    }
end
function optTables:newClass()
    local tbl = {}
    tbl['ALL_CLASSES'] = { name = ns.code:cText('FF00FF00', 'All Classes'), group = true, checked = true }
    tbl['ALL_TANKS'] = { name = ns.code:cText('FF00FF00', 'Tanks Only'), group = true, checked = false }
    tbl['ALL_HEALS'] = { name = ns.code:cText('FF00FF00', 'Healing Only'), group = true, checked = false }
    tbl['ALL_MELEE'] = { name = ns.code:cText('FF00FF00', 'Melee Only'), group = true, checked = false }
    tbl['ALL_RANGED'] = { name = ns.code:cText('FF00FF00', 'Ranged Only'), group = true, checked = false }
    for k in pairs(ns.ds.tblClassesByName or {}) do
        tbl[k] = { name = k, group = false, checked = false }
    end
    return tbl
end
function optTables:newRace()
    local tbl = {}
        tbl['ALL_RACES'] = { name = ns.code:cText('FF00FF00', 'All Races'), group = true, checked = true }
        for k in pairs(ns.ds.tblRaces or {}) do
            tbl[k] = { name = k, group = false, checked = false }
        end
    return tbl
end

local tblMessage = optTables:newMsg()
local tblGMMessage = optTables:newMsg()

local tblRaces = optTables:newRace()
local tblFilter = optTables:newFilter()
local tblClasses = optTables:newClass()

local function createFilterPreview()
    local out = nil
    for k, r in pairs(tblClasses) do
        local group = (r.checked and (r.name:match('All') or r.name:match('Only'))) and k or nil
        if r.checked and group then out = '-c"'..k..'" ' break
        elseif r.checked then out = '-c"SELECTED CLASSES" ' break end
    end
    for k, r in pairs(tblRaces) do
        local group = (r.checked and (r.name:match('All') or r.name:match('Only'))) and k or nil
        if r.checked and group then out = (out or '')..'-r"'..k..'"' break
        elseif r.checked then out = (out or '')..'-r"SELECTED RACES"' break end
    end

    tblFilter.filter = out
end
local function MessageLength(msg)
    local gd = ns.dbGlobal.guildData
    local playerNameFound = false
    local count, tMsg = 0, (msg or '')

    msg = ns.code:capitalKeyWord(msg, 'GUILDLINK')
    msg = ns.code:capitalKeyWord(msg, 'GUILDNAME')
    msg = ns.code:capitalKeyWord(msg, 'PLAYERNAME')

    if ns.code:capitalKeyWord(tMsg, 'GUILDLINK') then
        tMsg = tMsg:gsub('GUILDLINK', '')
        count = strlen(gd.guildName) + 9
    end
    if ns.code:capitalKeyWord(tMsg, 'GUILDNAME') then
        tMsg = tMsg:gsub('GUILDNAME', '')
        count = count + strlen(gd.guildName) + 2
    end
    if ns.code:capitalKeyWord(tMsg, 'PLAYERNAME') then
        playerNameFound = tMsg:match('PLAYERNAME') and true or false
        tMsg = tMsg:gsub('PLAYERNAME', '')
    end

    return playerNameFound, count + (strlen(tMsg) or 0), count, msg
end

ns.addonSettings = {
    name = GR_VERSION_INFO,
    type = 'group',
    args = {
        mnuGeneral = {
            name = 'GR Settings',
            type = 'group',
            order = 1,
            args = {
                msgHeader1 = {
                    name = 'General Settings',
                    type = 'header',
                    width = 'full',
                    order = 0,
                },
                optTooltipsMnu = {
                    name = 'Show tooltips',
                    desc = 'Will hide non-essental tooltips when overing over icons.',
                    type = 'toggle',
                    width = 'full',
                    order = 1,
                    set = function(_, val) ns.settings.showTooltips = val end,
                    get = function() return ns.settings.showTooltips end,
                },
                optIcon = {
                    name = 'Show icon on minimap',
                    desc = 'Toggles the visibility of the minimap icon.  You can use /gr or /gr config to access the addon.',
                    type = 'toggle',
                    width = 'full',
                    order = 2,
                    set = function(_, val) ns.settings.minimap = { hide = not val } end,
                    get = function()
                        if not ns.settings.minimap.hide then icon:Show('GR_Icon')
                        else icon:Hide('GR_Icon') end
                        return not ns.settings.minimap.hide
                    end,
                },
                optContextMnu = {
                    name = 'Show context menu for guild invite/black list.',
                    desc = 'When you right click on a player in chat, an extra menu will appear to invite to guild or black list.',
                    type = 'toggle',
                    width = 'full',
                    order = 3,
                    set = function(_, val) ns.settings.showContext = val end,
                    get = function() return ns.settings.showContext end,
                },
                msgHeader2 = {
                    name = 'Addon Messages',
                    type = 'header',
                    width = 'full',
                    order = 10,
                },
                optUpdateMsg = {
                    name = 'Show addon changes window.',
                    desc = 'A window pops up with the changes in the current version, once per version.',
                    type = 'toggle',
                    width = 'full',
                    order = 11,
                    set = function(_, val) ns.settings.showUpdates = val end,
                    get = function() return ns.settings.showUpdates end,
                },
                optSystemMsg = {
                    name = 'Show addon messages in chat.',
                    desc = 'Shows verbose addon messages in chat, suggest disabling.',
                    type = 'toggle',
                    width = 'full',
                    order = 12,
                    set = function(_, val) ns.settings.showAppMsgs = val end,
                    get = function() return ns.settings.showAppMsgs end,
                },
                msgHeader99 = {
                    name = 'Debug Settings',
                    type = 'header',
                    width = 'full',
                    order = 90,
                },
                optDebugMsg = {
                    name = 'Shows debug messages in chat.',
                    desc = 'This is used for development, turn off.',
                    type = 'toggle',
                    width = 'full',
                    order = 98,
                    set = function(_, val)
                        GRADDON.debug = val
                        ns.settings.debugMode = val
                    end,
                    get = function() return ns.settings.debugMode end,
                },
                optDebugSync = {
                    name = 'Disable Auto Sync.',
                    desc = 'This is used for development, leave off.',
                    type = 'toggle',
                    width = 'full',
                    order = 99,
                    set = function(_, val) ns.dbGlobal.debugAutoSync = val end,
                    get = function() return ns.dbGlobal.debugAutoSync or false end,
                },
            },
        },
        mnuBlank1 = {
            type = 'group',
            name = ' ',
            order = 5,
            args = {}
        },
        mnuGMOptions = {
            type = 'group',
            name = 'GM: Settings',
            order = 6,
            args = {
                optGMLabel = {
                    order = 0,
                    type = 'description',
                    name = 'Guild Masters have access to the following settings on any guild character.',
                },
                optGMHeader1 = {
                    order = 1,
                    name = 'Guild Master Settings',
                    type = 'header',
                },
                optGMAntiSpamEnable = {
                    order = 2,
                    name = 'Anti guild spam protection.',
                    desc = "Remembers invited players so you don't constantly spam them invites",
                    type = 'toggle',
                    disabled = function() return not ns.isGuildLeader end,
                    width = 1.5,
                    set = function(_, val) ns.dbGlobal.guildInfo.antiSpam = val end,
                    get = function() return ns.dbGlobal.guildInfo.antiSpam end,
                },
                optGMAntiSpamInterval = {
                    order = 3,
                    name = 'Reinvite players after:',
                    desc = 'Number of days before resetting invite status.',
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
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
                    set = function(_, val) ns.dbGlobal.guildInfo.reinviteAfter = tonumber(val) end,
                    get = function()
                        if ns.dbGlobal.guildInfo.reinviteAfter and ns.dbGlobal.guildInfo.reinviteAfter < 7 then
                            ns.dbGlobal.guildInfo.reinviteAfter = 7
                        end
                        return ns.dbGlobal.guildInfo.reinviteAfter end,
                },
                optOnlyGMGreeting = {
                    order = 4,
                    name = 'Force/Unenforce whispered greeting message to new guild member.',
                    desc = 'This message will be in a '..ns.code:cText('FFFFFF00', 'whisper')..' form to the player upon joining.\n \nEnabled, everyone using the addon will send this message.',
                    type = 'toggle',
                    disabled = function() return not ns.isGuildLeader end,
                    width = 'full',
                    set = function(_, val) ns.dbGlobal.guildInfo.greeting = val end,
                    get = function() return ns.dbGlobal.guildInfo.greeting end,
                },
                optGMGreetingMsg = {
                    order = 5,
                    name = 'Greeting Message',
                    desc = 'This is the message that will be '..ns.code:cText('FFFFFF00', 'whispered')..' to the player after joining.',
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val)
                        local playerNameFound, _, remove, msg = MessageLength(val:trim())
                        msg = msg or ''

                        ns.dbGlobal.guildInfo.greetingMsg = playerNameFound and msg:sub(1, (243 - (remove or 0))) or msg:sub(1, (255 - (remove or 0)))
                    end,
                    get = function() return ns.dbGlobal.guildInfo.greetingMsg end,
                },
                GMHeader2 = {
                    name = '',
                    type = 'header',
                    order = 6
                },
                GMPreviewCount = {
                    order = 7,
                    name = function()
                        local gi = ns.dbGlobal.guildInfo
                        local playerNameFound, count = MessageLength((gi.greetingMsg or ''))

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return 'Message Length: '..ns.code:cText(color, count)..' (255 characters per message)'..(playerNameFound and '\nNote: Does not count the player name.' or '')..ns.code:cText('FFFFFF00', '\nMessages will be truncated to 255 characters\n(assumes 12 characters for PLAYERNAME).')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                GMHeader3 = {
                    order = 8,
                    name = '',
                    type = 'header',
                },
                optOnlyGMWelcome = {
                    order = 9,
                    name = 'Force/Unenforce welcome message.',
                    desc = 'Enable/Disable sending of a personalized welcome message to '..ns.code:cText('FFFFFF00', 'guild chat')..' after a player joins.\n \nEnabled, everyone using the addon will send this message.',
                    type = 'toggle',
                    disabled = function() return not ns.isGuildLeader end,
                    width = 'full',
                    set = function(_, val)
                        local playerNameFound, _, remove, msg = MessageLength(val:trim())
                        msg = msg or ''
                        ns.dbGlobal.guildInfo.welcome = playerNameFound and msg:sub(1, (243 - (remove or 0))) or msg:sub(1, (255 - (remove or 0)))
                    end,
                    get = function() return ns.dbGlobal.guildInfo.welcome end,
                },
                optGMWelcomeMsg = {
                    order = 10,
                    name = 'Actual greeting Message',
                    desc = 'This is the actual message shown in '..ns.code:cText('FFFFFF00', 'guild chat')..'.',
                    type = 'input',
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) ns.dbGlobal.guildInfo.welcomeMsg = val end,
                    get = function()
                        ns.dbGlobal.guildInfo.welcomeMsg = ns.dbGlobal.guildInfo.welcomeMsg or DEFAULT_GUILD_WELCOME
                        return ns.dbGlobal.guildInfo.welcomeMsg
                    end,
                },
            }
        },
        mnuGMMsg = {
            type = 'group',
            name = 'GM: Messages',
            order = 7,
            args = {
                optGMLabel = {
                    order = 0,
                    type = 'description',
                    name = 'Guild Masters have access to the following settings on any guild character.',
                },
                optGMHeader1 = {
                    order = 1,
                    name = 'Guild Master Messages',
                    type = 'header',
                },
                msgGMDesc = {
                    order = 2,
                    name = ns.code:cText('FF00FF00', 'These messages will be pushed out to other officers that can invite players.\n\n')..ns.code:cText('FFFFFF00', 'GUILDLINK')..': Clickable link to allow player to join the guild.\n'..ns.code:cText('FFFFFF00', 'GUILDNAME')..': Guild name in format <Shadowbound>.\n'..ns.code:cText('FFFFFF00', 'PLAYERNAME')..': Player name that is being invited to the guild.',
                    type = 'description',
                    fontSize = 'medium',
                },
                msgGMHeader2 = {
                    order = 3,
                    name = '',
                    type = 'header',
                },
                msgGMActive = {
                    order = 4,
                    name = 'Invite Messages',
                    desc = 'The messges that will be sent to potential recruits.',
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.dbGlobal.guildInfo.messageList or {}) do tbl[k] = ns.code:cText(GM_DESC_COLOR, r.desc) end
                        return tbl
                    end,
                    set = function(_, val) selectedGMMessage = val end,
                    get = function()
                        local msg = ns.dbGlobal.guildInfo.messageList or nil
                        local active = selectedGMMessage or nil

                        if active and msg then tblGMMessage = msg[active] or optTables:newMsg()
                        elseif not msg then selectedGMMessage = nil end

                        return active
                    end,
                },
                msgGMNewBtn = {
                    order = 5,
                    name = 'New',
                    desc = 'Create a new message.',
                    type = 'execute',
                    width = .5,
                    disabled = function() return not selectedGMMessage end,
                    hidden = function() return not ns.isGuildLeader end,
                    func = function()
                        tblGMMessage = optTables:newMsg()
                        selectedGMMessage = nil
                    end,
                },
                msgGMInviteDesc = {
                    order = 6,
                    name = 'Invite Description',
                    desc = 'Short description of the message.',
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) tblGMMessage.desc = val end,
                    get = function() return tblGMMessage.desc or '' end,
                },
                msgGMInvite = {
                    order = 7,
                    name = 'Invite Message',
                    type = 'input',
                    multiline = 7,
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader end,
                    set = function(_, val) tblGMMessage.message = val end,
                    get = function() return tblGMMessage.message or '' end,
                },
                msgGMHeader3 = {
                    order = 8,
                    name = 'Message Preview',
                    type = 'header',
                },
                msgGMPreview = {
                    order = 9,
                    name = function()
                        local preview = ns.code:variableReplacement(tblGMMessage.message, UnitName('player'))
                        if preview == '' then return '' end
                        return (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                msgGMHeader4 = {
                    order = 10,
                    name = '',
                    type = 'header',
                },
                msgGMPreviewCount = {
                    order = 11,
                    name = function()
                        local gi = ns.dbGlobal.guildInfo
                        local playerNameFound, count = MessageLength((gi.greetingMsg or ''))

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return 'Message Length: '..ns.code:cText(color, count)..' (255 characters per message)'..(playerNameFound and '\n Note: Does not count the player name.' or '')
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
                    name = 'Delete',
                    desc = 'Delete the selected message.',
                    type = 'execute',
                    confirm = function() return 'Are you sure you want to delete this message?' end,
                    width = .5,
                    disabled = function() return not selectedGMMessage and true or false end,
                    hidden = function() return not ns.isGuildLeader end,
                    func = function()
                        local msg = ns.dbGlobal.guildInfo.messageList or nil
                        local active = selectedGMMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            selectedGMMessage = nil
                            tblGMMessage = optTables:newMsg()
                        end
                    end,
                },
                msgGMInviteSave = {
                    order = 14,
                    name = 'Save',
                    desc = 'Save the selected message.',
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblGMMessage then return true end
                        return not ((tblGMMessage.desc and strlen(tblGMMessage.desc) > 0) and (tblGMMessage.message and strlen(tblGMMessage.message) > 0)) end,
                    hidden = function() return not ns.isGuildLeader end,
                    func = function()
                        local msg = ns.dbGlobal.guildInfo.messageList or {}
                        local active = selectedGMMessage

                        if not active then
                            tinsert(msg, tblGMMessage)
                            active = #msg
                        else msg[active] = tblGMMessage end
                        ns.dbGlobal.guildInfo.messageList = msg

                        tblGMMessage = optTables:newMsg()
                        selectedGMMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 1.0, 0.1, 0.1, 1.0)
                    end,
                },
            }
        },
        mnuBlank2 = {
            type = 'group',
            name = ' ',
            order = 10,
            args = {}
        },
        mnuInviteOptions = {
            order = 11,
            name = 'Invite Settings',
            type = 'group',
            args = {
                msgHeader2 = {
                    name = 'Invite Settings',
                    type = 'header',
                    order = 0,
                },
                optContextMnu = {
                    order = 1,
                    name = 'Show context menu for guild invite/black list.',
                    desc = 'When you right click on a player in chat, an extra menu will appear to invite to guild or black list.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.settings.showContext = val end,
                    get = function() return ns.settings.showContext end,
                },
                optShowInvite = {
                    order = 3,
                    name = 'Show your whisper when sending invite messages.',
                    desc = 'This will show or hide whisper messages to recruits, suggest going to social and turn on in-line whispers for best results.',
                    type = 'toggle',
                    width = 'full',
                    set = function(_, val) ns.settings.showWhispers = val end,
                    get = function() return ns.settings.showWhispers end,
                },
                optShowInviteMsg = {
                    order = 4,
                    name = ns.code:cText('FF00FF00', 'NOTE: You must reload your UI to take effect (/rl).'),
                    type = 'description',
                    fontSize = 'medium',
                },
                optGMAntiSpamEnable = {
                    order = 5,
                    name = 'Anti guild spam protection.',
                    desc = "Remembers invited players so you don't constantly spam them invites",
                    type = 'toggle',
                    disabled = function() return ns.dbGlobal.guildInfo.antiSpam end,
                    width = 1.5,
                    set = function(_, val) ns.settings.antiSpam = val end,
                    get = function()
                        if ns.dbGlobal.guildInfo.antiSpam then
                            return ns.dbGlobal.guildInfo.antiSpam
                        else return ns.settings.antiSpam end
                    end,
                },
                optGMAntiSpamInterval = {
                    order = 6,
                    name = 'Reinvite players after:',
                    desc = 'Number of days before resetting invite status.',
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    disabled = function() return ns.dbGlobal.guildInfo.antiSpam end,
                    values = function()
                        return {
                            [7] = '7 days',
                            [14] = '14 days',
                            [30] = '30 days (1 month)',
                            [190] = '190 days (3 months)',
                            [380] = '380 days (6 months)',
                        }
                    end,
                    set = function(_, val) ns.settings.reinviteAfter = tonumber(val) end,
                    get = function()
                        if ns.dbGlobal.guildInfo.antiSpam then return ns.dbGlobal.guildInfo.reinviteAfter
                        else return ns.settings.reinviteAfter end
                    end,
                },
                optShowPersonalGreeting = {
                    order = 7,
                    name = 'Enable/Disable whispered greeting message to new guild member.',
                    desc = 'This message will be in a '..ns.code:cText('FFFFFF00', 'whisper')..' form to the player upon joining.',
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return ns.dbGlobal.guildInfo.greeting end,
                    set = function(_, val) ns.settings.sendGreeting = val end,
                    get = function() return ns.dbGlobal.guildInfo.greeting or ns.settings.sendGreeting end,
                },
                optShowPersonalGM = {
                    order = 8,
                    name = ns.code:cText('FF00FF00', 'NOTE: The GM has forced this option on.'),
                    hidden = function() return not ns.dbGlobal.guildInfo.greeting end,
                    type = 'description',
                    fontSize = 'medium',
                },
                optPersonalGreetingMsg = {
                    order = 9,
                    name = 'Actual greeting message',
                    desc = 'This is the message that will be '..ns.code:cText('FFFFFF00', 'whispered')..' to the player after joining.',
                    type = 'input',
                    multiline = 3,
                    width = 'full',
                    disabled = function() return ns.dbGlobal.guildInfo.greeting end,
                    set = function(_, val)
                        local playerNameFound, _, remove, msg = MessageLength(val:trim())
                        msg = msg or ''

                        ns.settings.greetingMsg  = playerNameFound and msg:sub(1, (243 - (remove or 0))) or msg:sub(1, (255 - (remove or 0)))
                    end,
                    get = function()
                        if ns.dbGlobal.guildInfo.greetingMsg then return ns.dbGlobal.guildInfo.greetingMsg
                        else return ns.settings.greetingMsg end
                    end,
                },
                Header2 = {
                    name = '',
                    type = 'header',
                    order = 10
                },
                PreviewCount = {
                    order = 11,
                    name = function()
                        local gi = ns.dbGlobal.guildInfo
                        local playerNameFound, count = MessageLength((ns.settings.greetingMsg or gi.greetingMsg or ''))

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return 'Message Length: '..ns.code:cText(color, count)..' (255 characters per message)'..(playerNameFound and '\nNote: Does not count the player name.' or '')..ns.code:cText('FFFFFF00', '\nMessages will be truncated to 255 characters\n(assumes 12 characters for PLAYERNAME).')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                Header3 = {
                    order = 12,
                    name = '',
                    type = 'header',
                },
                optShowPersonalWelcome = {
                    order = 13,
                    name = 'Enable/Disable personal welcome message.',
                    desc = 'Enable/Disable sending of a personalized welcome message to '..ns.code:cText('FFFFFF00', 'guild chat')..' after a player joins.',
                    type = 'toggle',
                    width = 'full',
                    disabled = function() return not ns.isGuildLeader and ns.dbGlobal.greeting end,
                    set = function(_, val) ns.settings.sendWelcome = val end,
                    get = function() return ns.settings.sendWelcome end,
                },
                optPersonalWelcomeMsg = {
                    order = 14,
                    name = 'Actual message sent to player after joining.',
                    desc = 'This message will be sent to '..ns.code:cText('FFFFFF00', 'guild chat')..' to the player after joining.',
                    type = 'input',
                    width = 'full',
                    disabled = function() return not ns.core.isGuildLeader and ns.dbGlobal.greeting end,
                    set = function(_, val)
                        local playerNameFound, _, remove, msg = MessageLength(val:trim())
                        msg = msg or ''
                        ns.settings.welcomeMessage = playerNameFound and msg:sub(1, (243 - (remove or 0))) or msg:sub(1, (255 - (remove or 0)))
                    end,
                    get = function()
                        ns.settings.welcomeMessage = ns.settings.welcomeMessage or DEFAULT_GUILD_WELCOME
                        return ns.settings.welcomeMessage
                    end,
                },
                optMsgNote = {
                    order = 15,
                    name = ns.code:cText('FFFFFF00', 'NOTE: ')..'Disabled options are controlled by the Guild Master.',
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                optScanInterval = {
                    order = 16,
                    name = 'Time to wait between scans (default recommended).',
                    desc = 'WoW requires a cooldown period between /who scans, this is the time that the system will wait between scans.',
                    type = 'input',
                    width = 'full',
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then ns.settings.scanWaitTime = tonumber(val)
                        else return tostring(ns.settings.scanWaitTime) end
                    end,
                    get = function() return tostring(ns.settings.scanWaitTime) end,
                },
                optWhoNote = {
                    order = 17,
                    name = ns.code:cText('FFFFFF00', 'NOTE: ')..'6 seconds seems to give best results, shorter time yields less results.',
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                Header4 = {
                    name = 'Keybindings',
                    type = 'header',
                    order = 18
                },
                optKeybindingInvite = {
                    order = 19,
                    name = 'Keybinding: Invite',
                    desc = 'Change the keybinding to invite a player to the guild.',
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.global.keybindInvite = nil
                        elseif val and val == ns.global.keybindScan then
                            ns.code:fOut('That key is bound to scan, please choose another key.')
                            return
                        else ns.global.keybindInvite = val end
                    end,
                    get = function() return ns.global.keybindInvite end,
                },
                optSpacer = {
                    order = 20,
                    name = '',
                    type = 'description',
                    width = .5,
                },
                optKeybindingScan = {
                    order = 21,
                    name = 'Keybinding: Scan',
                    desc = 'Change the keybinding to scan for players to invite.',
                    type = 'keybinding',
                    width = 1,
                    set = function(_, val)
                        if strlen(val) == 0 or val == '' then ns.global.keybindScan = nil
                        elseif val and val == ns.global.keybindInvite then
                            ns.code:fOut('That key is bound to invite, please choose another key.')
                            return
                        else ns.global.keybindScan = val end
                    end,
                    get = function() return ns.global.keybindScan end,
                },
                optNoteKeybind = {
                    order = 22,
                    name = ns.code:cText('FF00FF00', 'NOTE: Keybinds do not overwrite your WoW binds and are only used in the scanner.'),
                    type = 'description',
                    fontSize = 'medium',
                },
            },
        },
        mnuPersonalMsg = {
            order = 21,
            name = 'Invite Messages',
            type = 'group',
            args = {
                msgHeader1 = {
                    order = 0,
                    name = 'Message Formatting',
                    type = 'header',
                },
                msgDesc = {
                    order = 1,
                    name = ns.code:cText('FFFFFF00', 'GUILDLINK')..': Clickable link to allow player to join the guild.\n'..ns.code:cText('FFFFFF00', 'GUILDNAME')..': Guild name in format <Shadowbound>.\n'..ns.code:cText('FFFFFF00', 'PLAYERNAME')..': Player name that is being invited to the guild.',
                    type = 'description',
                    fontSize = 'medium',
                },
                msgHeader2 = {
                    order = 2,
                    name = '',
                    type = 'header',
                },
                msgActive = {
                    order = 3,
                    name = 'Invite Messages',
                    desc = 'The messges that will be sent to potential recruits.',
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.db.messages.messageList or {}) do tbl[k] = r.desc end
                        return tbl
                    end,
                    set = function(_, val) selectedMessage = val end,
                    get = function()
                        local msg = ns.db.messages.messageList or nil
                        local active = selectedMessage or nil

                        if active and msg then
                            tblMessage = msg[active] or optTables:newMsg()
                        elseif not msg then selectedMessage = nil end

                        return active
                    end,
                },
                msgNewBtn = {
                    order = 4,
                    name = 'New',
                    desc = 'Create a new message.',
                    type = 'execute',
                    width = .5,
                    disabled = function() return not selectedMessage end,
                    func = function()
                        tblMessage = optTables:newMsg()
                        selectedMessage = nil
                    end,
                },
                msgInviteDesc = {
                    order = 5,
                    name = 'Invite Description',
                    desc = 'Short description of the message.',
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    set = function(_, val) tblMessage.desc = val end,
                    get = function() return tblMessage.desc or '' end,
                },
                msgInvite = {
                    order = 6,
                    name = 'Invite Message',
                    type = 'input',
                    multiline =  7,
                    width = 'full',
                    set = function(_, val) tblMessage.message = val end,
                    get = function() return tblMessage.message or '' end,
                },
                msgHeader3 = {
                    order = 7,
                    name = 'Message Preview',
                    type = 'header',
                },
                msgPreview = {
                    order = 8,
                    name = function()
                        mPreview = ns.code:variableReplacement(tblMessage.message, UnitName('player'))
                        if mPreview == '' then return '' end
                        return (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(mPreview or ''))) or ''
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                msgNotGM = {
                    order = 9,
                    name = function()
                        local errMsg = (tblMessage.message and strfind(tblMessage.message, 'guildData') and not ns.dbGlobal.guildData and not ns.core.isGuildLeader) and 'WARNING: You are not a GM, so guildData is an invalid option.' or nil
                        return errMsg and ns.code:cText('FFFF0000', errMsg) or ' '
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium'
                },
                msgHeader4 = {
                    order = 10,
                    name = '',
                    type = 'header',
                },
                msgPreviewCount = {
                    order = 11,
                    name = function()
                        local gi = ns.dbGlobal.guildData
                        local playerNameFound = false
                        local count, tMsg = 0, tblMessage.message or nil

                        if ns.code:capitalKeyWord(tMsg, 'GUILDLINK') then
                            tMsg = tMsg:gsub('GUILDLINK', '')
                            count = strlen(gi.guildName) + 9
                        end
                        if ns.code:capitalKeyWord(tMsg, 'GUILDNAME') then
                            tMsg = tMsg:gsub('GUILDNAME', '')
                            count = count + strlen(gi.guildName) + 2
                        end
                        if ns.code:capitalKeyWord(tMsg, 'PLAYERNAME') then
                            playerNameFound = tMsg:match('PLAYERNAME') and true or false
                            tMsg = tMsg:gsub('PLAYERNAME', '')
                        end
                        count = count + strlen(tMsg)

                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return 'Message Length: '..ns.code:cText(color, count)..' (255 characters per message)'..(playerNameFound and '\n Note: Does not count the player name.' or '')
                    end,
                    type = 'description',
                    width = 'full',
                    fontSize = 'medium',
                },
                msgHeader5 = {
                    order = 12,
                    name = '',
                    type = 'header',
                },
                msgInviteDel = {
                    order = 13,
                    name = 'Delete',
                    desc = 'Delete the selected message.',
                    type = 'execute',
                    confirm = function() return 'Are you sure you want to delete this message?' end,
                    width = .5,
                    disabled = function() return not selectedMessage and true or false end,
                    func = function()
                        local msg = ns.db.messages.messageList or nil
                        local active = selectedMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            selectedMessage = nil
                            tblMessage = optTables:newMsg()
                        end
                    end,
                },
                msgInviteSave = {
                    order = 14,
                    name = 'Save',
                    desc = 'Save the selected message.',
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblMessage then return true end
                        return not ((tblMessage.desc and strlen(tblMessage.desc) > 0) and (tblMessage.message and strlen(tblMessage.message) > 0)) end,
                    func = function()
                        local msg = ns.db.messages and ns.db.messages.messageList or {}
                        local active = selectedMessage
                        if not active then
                            tinsert(msg, tblMessage)
                            active = #msg
                        else msg[active] = tblMessage end
                        ns.db.messages.messageList = msg

                        tblMessage = optTables:newMsg()
                        selectedMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 1.0, 0.1, 0.1, 1.0)
                    end,
                }
            }
        },
        mnuBlank3 = {
            order = 30,
            type = 'group',
            name = ' ',
            args = {}
        },
        mnuFilterList = {
            name = 'Custom Filters',
            type = 'group',
            order = 31,
            args = {
                filterHeader1 = {
                    order = 0,
                    name = 'Filter Editor',
                    type = 'header',
                },
                filterEdit = {
                    order = 1,
                    name = 'Select a filter to edit',
                    type = 'select',
                    style = 'dropdown',
                    width = 1.5,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.db.filter.filterList and ns.db.filter.filterList or {}) do tbl[k] = r.desc end
                        return tbl
                    end,
                    set = function(_, val) selectedFilter = val end,
                    get = function()
                        if filterOld == selectedFilter then return selectedFilter end
                        local filter = ns.db.filter.filterList and ns.db.filter.filterList[selectedFilter] or nil
                        if selectedFilter and filter then
                            tblRaces = optTables:newRace()
                            tblFilter = optTables:newFilter()
                            tblClasses = optTables:newClass()

                            tblFilter.desc = filter.desc
                            tblFilter.filter = filter.filter

                            tblClasses['ALL_CLASSES'].checked = false
                            for k in pairs(filter.class or {}) do
                                if tblClasses[k] then tblClasses[k].checked = true end
                            end

                            tblRaces['ALL_RACES'].checked = false
                            for k in pairs(filter.race or {}) do
                                if tblRaces[k] then tblRaces[k].checked = true end
                            end
                        elseif not filter then selectedFilter, filterOld = nil, nil end

                        filterOld = selectedFilter
                        return selectedFilter
                    end,
                },
                filterNewBtn = {
                    order = 2,
                    name = 'New',
                    desc = 'Create a new filter.',
                    type = 'execute',
                    width = .5,
                    disabled = function() return not selectedFilter end,
                    func = function()
                        selectedFilter, filterOld = nil, nil
                        tblRaces = optTables:newRace()
                        tblFilter = optTables:newFilter()
                        tblClasses = optTables:newClass()
                    end,
                },
                filterHeader2 = {
                    order = 3,
                    name = 'Filter Creator',
                    type = 'header',
                },
                filterDesc = {
                    order = 4,
                    name = 'Filter Description',
                    desc = 'Short description of the filter.',
                    type = 'input',
                    multiline = false,
                    width = 1.5,
                    set = function(_, val) tblFilter.desc = val end,
                    get = function() return tblFilter.desc or '' end,
                },
                filterSave = {
                    order = 5,
                    name = 'Save',
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        return not ((strlen(tblFilter.desc or '') > 0 and strlen(tblFilter.filter or '') > 0) or false)
                    end,
                    func = function()
                        local checkFound = false
                        local tblClassList, tblRaceList = {}, {}
                        for k, r in pairs(tblClasses) do
                            if r.checked then
                                checkFound = true
                                tblClassList[k] = r.name
                            end
                        end
                        if not checkFound then
                            UIErrorsFrame('You much select a class or a group.')
                            return
                        end

                        checkFound = false
                        for k, r in pairs(tblRaces) do
                            if r.checked then
                                checkFound = true
                                tblRaceList[k] = r.name
                            end
                        end
                        if not checkFound then
                            UIErrorsFrame('You much select a race or a group.')
                            return
                        end

                        local filterList = ns.db.filter.filterList
                        tblFilter.class = tblClassList
                        tblFilter.race = tblRaceList
                        if selectedFilter and filterList[selectedFilter] then filterList[selectedFilter] = tblFilter
                        else tinsert(filterList, tblFilter) end

                        selectedFilter, filterOld = nil, nil
                        tblRaces = optTables:newRace()
                        tblFilter = optTables:newFilter()
                        tblClasses = optTables:newClass()
                    end,
                },
                filterDelete = {
                    order = 6,
                    name = 'Delete',
                    type = 'execute',
                    width = .5,
                    disabled = function() return not selectedFilter end,
                    confirm = function() return 'Are you sure you want to delete this record?' end,
                    func = function()
                        if not selectedFilter then return end

                        local filterList = ns.db.filter.filterList
                        filterList[selectedFilter] = nil

                        selectedFilter, filterOld = nil, nil
                        tblRaces = optTables:newRace()
                        tblFilter = optTables:newFilter()
                        tblClasses = optTables:newClass()
                    end,
                },
                filterCustom = {
                    order = 7,
                    name = 'Custom filter',
                    desc = 'Edit and/or create your filter.',
                    type = 'input',
                    multiline = false,
                    width = 'full',
                    set = function(_, val) tblFilter.filter = val end,
                    get = function() createFilterPreview() return tblFilter.filter or '' end,
                },
                filterClass = {
                    order = 8,
                    name = 'Classes (Only select "All Classes" or multiple classes)',
                    desc = 'Specific class, classes with type of damage, heals or tanks, etc.',
                    type = 'multiselect',
                    style = 'dropdown',
                    width = 'FULL',
                    validate = (function(_, field, value)
                        if not value then return true end
                        local group = tblClasses[field].group or false
                        if not group then
                            for k,r in pairs(tblClasses) do
                                if r.group and r.checked then group = k break end
                            end
                        end
                        if group then
                            for k,r in pairs(tblClasses) do
                                if group and r.checked and field ~= k then
                                    return 'You can only select one group or multiple classes.'
                                end
                            end
                        end
                        return true
                    end),
                    values = function()
                        local tbl = {}
                        for k,r in pairs(tblClasses) do tbl[k] = r.name end
                        return tbl
                    end,
                    set = function(_, key, val)
                        tblClasses[key].checked = val
                        createFilterPreview()
                    end,
                    get = function(_, key) return tblClasses[key].checked end,
                },
                filterRaces = {
                    order = 9,
                    name = 'Races',
                    desc = 'Choose "All Races" or specific races.',
                    type = 'multiselect',
                    style = 'dropdown',
                    width = 'FULL',
                    validate = (function(_, field, value)
                        if not value then return true end
                        local group = tblRaces[field].group or false
                        if not group then
                            for k,r in pairs(tblRaces) do
                                if r.group and r.checked then group = k break end
                            end
                        end
                        if group then
                            for k,r in pairs(tblRaces) do
                                if group and r.checked and field ~= k then
                                    return 'You can only select one group or multiple races.'
                                end
                            end
                        end
                        return true
                    end),
                    values = function()
                        local tbl = {}
                        for k,r in pairs(tblRaces) do tbl[k] = r.name end
                        return tbl
                    end,
                    set = function(_, key, val)
                        tblRaces[key].checked = val
                        createFilterPreview()
                    end,
                    get = function(_, key) return tblRaces[key].checked end,
                },
                filterHeader3 = {
                    name = 'Custom Filter Commands',
                    type = 'header',
                    order = 80,
                },
                filterDesc1 = {
                    name = '\nThe following commands can be used in filters:',
                    type = 'description',
                    fontSize = 'medium',
                    order = 92,
                },
                filterDesc2 = {
                    name = 'Name ('..ns.code:cText('FFFFFF00', 'n-"<char name>"')..'): Used to search for a specific character.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 93,
                },
                filterDesc3 = {
                    name = 'Zone ('..ns.code:cText('FFFFFF00', 'z-"<zone name>"')..'): Used to search a specific zone.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 94,
                },
                filterDesc4 = {
                    name = 'Race ('..ns.code:cText('FFFFFF00', 'r-"<race name>"')..'): Used to search a specific race.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 94,
                },
                filterDesc5 = {
                    name = 'Class ('..ns.code:cText('FFFFFF00', 'c-"<class name>"')..'): Used to search a specific class.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 95,
                },
                filterDesc6 = {
                    name = '\nNotes:\nFollow the exact format in the parenthesis.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 97,
                },
                filterDesc7 = {
                    name = 'Replace the <command> with correct value.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 98,
                },
                filterDesc8 = {
                    name = 'Example: '..ns.code:cText('FFFFFF00', 'c-"<class name>"')..' would be '..ns.code:cText('FFFFFF00', 'c-"mage"'),
                    type = 'description',
                    fontSize = 'medium',
                    order = 99,
                },
                filterDesc9 = {
                    name = 'Each filter can be seperated by a space.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 100,
                },
                filterDesc10 = {
                    name = 'Use the selections first, then add custom commands to the filter.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 101,
                },
                filterDesc11 = {
                    name = ns.code:cText('FF00FF00', 'DO NOT: Specify levels, that is controlled by the main screen.'),
                    type = 'description',
                    fontSize = 'medium',
                    order = 102,
                },
            },
        },
        mnuBlackList = {
            name = 'Black List',
            type = 'group',
            order = 32,
            args = {
                filterHeader1 = {
                    order = 0,
                    name = 'Black List Editor',
                    type = 'header',
                },
                blDesc = {
                    order = 1,
                    name = 'Players marked in '..ns.code:cText('FFFF0000', 'RED')..' are marked for deletion.\nPlayers marked in '..ns.code:cText('FF00FF00', 'GREEN')..' are active black listed players.',
                    type = 'description',
                    fontSize = 'medium',
                },
                blRemoveButton = {
                    name = 'Toggle Selected Black List Entries',
                    desc = 'Black List entries marked for deletion will be permanently removed 30 days after marked.  During this time, the addon will ignore the selected Black List entries.',
                    type = 'execute',
                    width = 'full',
                    order = 2,
                    func = function()
                        for _,r in pairs(ns.tblBlackList) do
                            if r.selected and not r.markedForDelete then
                                r.markedForDelete = true
                                r.expirationDate = C_DateAndTime.GetServerTimeLocal() + (30 * SECONDS_IN_A_DAY)
                            elseif r.selected and r.markedForDelete then
                                r.markedForDelete = false
                                r.expirationDate = nil
                            end

                            r.selected = false
                        end
                    end,
                },
                blMultiSelect = {
                    type = 'multiselect',
                    name = 'Black Listed Players',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.tblBlackList or {}) do
                            local name = k
                            name = r.markedForDelete and ns.code:cText('FFFF0000', name) or ns.code:cText('FF00FF00', name)
                            tbl[k] = (name..': '..(r.reason or 'Unknown'))
                        end

                        return tbl
                    end,
                    set = function(_, key, val) ns.tblBlackList[key].selected = val end,
                    get = function(_, key) return ns.tblBlackList[key].selected or false end,
                }
            }
        },
        mnuInvalidZones = {
            name = 'Invalid Zone List',
            type = 'group',
            order = 33,
            args = {
                hdrZones = {
                    order = 0,
                    name = 'Invalid Zone List',
                    type = 'header',
                },
                descList = {
                    order = 1,
                    name = 'The following zones are will be ignored by the scanner:',
                    type = 'multiselect',
                    width = 'full',
                    values = function()
                        local tbl = {}
                        local tblZones = ns.code:sortTableByField(ns.ds.tblBadZonesByName, 'name', true)
                        for _, r in pairs(tblZones or {}) do tbl[r.key] = ns.code:cText('FFFFFF00', r.name)..' ('..r.reason..')' end
                        return tbl
                    end,
                },
                descZones2 = {
                    order = 2,
                    name = 'If you find a zone that is not listed, please let me know.',
                    type = 'description',
                    fontSize = 'medium',
                },
            }
        },
        mnuBlank4 = {
            type = 'group',
            name = ' ',
            order = 90,
            args = {}
        },
        mnuAbout = {
            type = 'group',
            name = 'About GR',
            order = 91,
            args = {
                aboutDesc1 = {
                    order = 0,
                    name = 'Guild Recruiter',
                    type = 'description',
                    image = ICON_PATH..'GR_Logo',
                    imageWidth = 32,
                    imageHeight = 32,
                    fontSize = 'medium',
                },
                aboutDesc2 = {
                    order = 1,
                    name = '\nThank you for using Guild Recruiter, I hope you find this addon useful!',
                    type = 'description',
                    fontSize = 'medium',
                },
                aboutDesc3 = {
                    order = 2,
                    name = '\nI am 100% self taught programmer that does this for a hobby (if you look at my code it is obvious, I am sure).  I started with Basic on a Commodore 64 and have since dabbled in Visual Basic, C+ and C#.  WoW gave me the opportunity to learn LUA and create adodns that players may find useful.',
                    type = 'description',
                    fontSize = 'medium',
                },
                aboutDesc4 = {
                    order = 3,
                    name = '\nI truly hope this addon is useful for you and will use it for many expansions to come.  Comments and feedback are important and bellow I have added some useful links to communicate your needs with me.',
                    type = 'description',
                    fontSize = 'medium',
                },
                aboutHeader1 = {
                    order = 4,
                    name = 'Links',
                    type = 'header',
                },
                aboutDesc5 = {
                    order = 5,
                    name = 'Bellow is a list of helpful links incase you need some support.',
                    type = 'description',
                    fontSize = 'medium',
                },
                aboutLink1 = {
                    order = 6,
                    name = 'CurseForge',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://www.curseforge.com/wow/addons/guild-recruiter') end,
                    get = function() return 'https://www.curseforge.com/wow/addons/guild-recruiter' end,
                },
                aboutLink2 = {
                    order = 7,
                    name = 'GitHub (Support documentation)',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://github.com/zaldor30/GuildRecruiter') end,
                    get = function() return 'https://github.com/zaldor30/GuildRecruiter' end,
                },
                aboutLink3 = {
                    order = 8,
                    name = 'Discord',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://discord.gg/ZtS6Q2sKRH') end,
                    get = function() return 'https://discord.gg/ZtS6Q2sKRH' end,
                },
                aboutLink4 = {
                    order = 9,
                    name = 'Buy Me a Coffee',
                    type = 'input',
                    width = 'full',
                    set = function() ns.code:OpenURL('https://bmc.link/alwaysbeconvoking') end,
                    get = function() return 'https://bmc.link/alwaysbeconvoking' end,
                },
                aboutHeader2 = {
                    order = 10,
                    name = 'Call for help!',
                    type = 'header',
                },
                aboutDesc6 = {
                    order = 11,
                    name = 'If you would like to help localize this addon, I would appreciate the help.  Please, join my Discord and let me know if interested.',
                    type = 'description',
                    fontSize = 'medium',
                },
            }
        },
    },
}