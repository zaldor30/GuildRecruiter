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
    for k in pairs(ns.datasets.tblClassesByName or {}) do
        tbl[k] = { name = k, group = false, checked = false }
    end
    return tbl
end
function optTables:newRace()
    local tbl = {}
        tbl['ALL_RACES'] = { name = ns.code:cText('FF00FF00', 'All Races'), group = true, checked = true }
        for k in pairs(ns.datasets.tblAllRaces or {}) do
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

ns.addonSettings = {
    name = GR_VERSION_INFO,
    type = 'group',
    args = {
        mnuGMMsg = {
            type = 'group',
            name = 'GM: Messages',
            order = 1,
            args = {
                msgGMHeader1 = {
                    name = 'Message Formatting',
                    type = 'header',
                    order = 0,
                },
                msgGMDesc = {
                    name = ns.code:cText('FF00FF00', 'These messages will be pushed out to other officers that can invite players.\n\n')..ns.code:cText('FFFFFF00', 'NAME')..': Player name that is being invited to the guild.\n'..ns.code:cText('FFFFFF00', 'GUILDLINK')..': Clickable link to allow player to join the guild.\n'..ns.code:cText('FFFFFF00', 'GUILDNAME')..': Guild name in format <ShadowBound>.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 1,
                },
                msgGMHeader2 = {
                    name = '',
                    type = 'header',
                    order = 2,
                },
                msgGMActive = {
                    name = 'Invite Messages',
                    desc = 'The messges that will be sent to potential recruits.',
                    type = 'select',
                    style = 'dropdown',
                    order = 3,
                    width = 2,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.dbGlobal.messageList or {}) do tbl[k] = r.desc end
                        return tbl
                    end,
                    set = function(_, val) selectedGMMessage = val end,
                    get = function()
                        local msg = ns.dbGlobal.messageList or nil
                        local active = selectedGMMessage or nil

                        if active and msg then tblGMMessage = msg[active] or optTables:newMsg()
                        elseif not msg then selectedGMMessage = nil end

                        return active
                    end,
                },
                msgGMNewBtn = {
                    name = 'New',
                    desc = 'Create a new message.',
                    type = 'execute',
                    width = .5,
                    order = 4,
                    disabled = function() return not selectedGMMessage end,
                    hidden = function() return not IsGuildLeader() end,
                    func = function()
                        tblGMMessage = optTables:newMsg()
                        selectedGMMessage = nil
                    end,
                },
                msgGMInviteDesc = {
                    name = 'Invite Description',
                    desc = 'Short description of the message.',
                    type = 'input',
                    multiline = false,
                    order = 5,
                    width = 'full',
                    set = function(_, val) tblGMMessage.desc = val end,
                    get = function() return tblGMMessage.desc or '' end,
                },
                msgGMInvite = {
                    name = 'Invite Message',
                    type = 'input',
                    multiline = 10,
                    order = 6,
                    width = 'full',
                    set = function(_, val) tblGMMessage.message = val end,
                    get = function() return tblGMMessage.message or '' end,
                },
                msgGMHeader3 = {
                    name = 'Message Preview',
                    type = 'header',
                    order = 7,
                },
                msgGMPreview = {
                    name = function()
                        gmPreview = ns.code:GuildReplace(tblGMMessage.message)
                        return (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(gmPreview or ''))) or ''
                    end,
                    type = 'description',
                    order = 8,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgGMHeader4 = {
                    name = '',
                    type = 'header',
                    order = 10
                },
                msgGMPreviewCount = {
                    name = function()
                        local count = string.len(gmPreview or '')
                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return 'Message Length: '..ns.code:cText(color, count)..' (255 characters per message)'
                    end,
                    type = 'description',
                    order = 11,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgGMHeader5 = {
                    name = '',
                    type = 'header',
                    order = 12,
                },
                msgGMInviteDel = {
                    name = 'Delete',
                    desc = 'Delete the selected message.',
                    type = 'execute',
                    confirm = function() return 'Are you sure you want to delete this message?' end,
                    width = .5,
                    disabled = function() return not selectedGMMessage and true or false end,
                    hidden = function() return not IsGuildLeader() end,
                    func = function()
                        local msg = ns.dbGlobal.messageList or nil
                        local active = selectedGMMessage or nil
                        if active and msg and msg[active] then
                            msg[active] = nil
                            selectedGMMessage = nil
                            tblGMMessage = optTables:newMsg()
                        end
                    end,
                },
                msgGMInviteSave = {
                    name = 'Save',
                    desc = 'Save the selected message.',
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if not tblGMMessage then return true end
                        return not ((tblGMMessage.desc and strlen(tblGMMessage.desc) > 0) and (tblGMMessage.message and strlen(tblGMMessage.message) > 0)) end,
                    hidden = function() return not IsGuildLeader() end,
                    func = function()
                        local msg = ns.dbGlobal.messageList or {}
                        local active = selectedGMMessage

                        if not active then
                            tinsert(msg, tblGMMessage)
                            active = #msg
                        else msg[active] = tblGMMessage end
                        ns.dbGlobal.messageList = msg

                        tblGMMessage = optTables:newMsg()
                        selectedGMMessage = nil
                        UIErrorsFrame:AddMessage('Message Saved', 1.0, 0.1, 0.1, 1.0)
                    end,
                }
            }
        },
        mnuGMOptions = {
            type = 'group',
            name = 'GM: Options',
            --hidden = function() return not IsGuildLeader() end,
            order = 2,
            args = {
                optRememberInvite = {
                    name = 'Anti guild spam protection.',
                    desc = "Remembers invited players so you don't constantly spam them invites",
                    type = 'toggle',
                    disabled = not IsGuildLeader(),
                    width = 1.5,
                    order = 1,
                    set = function(_, val) ns.dbGlobal.antiSpam = val end,
                    get = function() return ns.dbGlobal.antiSpam end,
                },
                optReInvite = {
                    name = 'Reinvite players after:',
                    desc = 'Number of days before resetting invite status.',
                    type = 'select',
                    style = 'dropdown',
                    order = 2,
                    width = 1,
                    disabled = not IsGuildLeader(),
                    values = function()
                        return {
                            [1] = '1 day',
                            [3] = '3 days',
                            [5] = '5 days',
                            [7] = '7 days',
                        }
                    end,
                    set = function(_, val) ns.dbGlobal.reinviteAfter = tonumber(val) end,
                    get = function() return ns.dbGlobal.reinviteAfter end,
                },
                optOnlyGMWelcome = {
                    name = 'Use only GM welcome message.',
                    desc = "This will prevent officers from sending their own welcome message.",
                    type = 'toggle',
                    disabled = not IsGuildLeader(),
                    width = 'full',
                    order = 3,
                    set = function(_, val) ns.dbGlobal.greeting = val end,
                    get = function() return ns.dbGlobal.greeting end,
                },
                optGMWelcomeMsg = {
                    name = 'Greeting Message',
                    desc = 'This message will be sent to guild chat when a player accepts invite.',
                    type = 'input',
                    width = 'full',
                    order = 4,
                    disabled = not IsGuildLeader(),
                    set = function(_, val) ns.dbGlobal.greetingMsg = val end,
                    get = function() return ns.dbGlobal.greetingMsg end,
                }
            }
        },
        mnuBlank1 = {
            type = 'group',
            name = ' ',
            order = 10,
            args = {}
        },
        mnuMsg = {
            name = 'Messages',
            type = 'group',
            order = 11,
            args = {
                msgHeader1 = {
                    name = 'Message Formatting',
                    type = 'header',
                    order = 0,
                },
                msgDesc = {
                    name = ns.code:cText('FFFFFF00', 'NAME')..': Player name that is being invited to the guild.\n'..ns.code:cText('FFFFFF00', 'GUILDLINK')..': Clickable link to allow player to join the guild.\n'..ns.code:cText('FFFFFF00', 'GUILDNAME')..': Guild name in format <ShadowBound>.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 1,
                },
                msgHeader2 = {
                    name = '',
                    type = 'header',
                    order = 2,
                },
                msgActive = {
                    name = 'Invite Messages',
                    desc = 'The messges that will be sent to potential recruits.',
                    type = 'select',
                    style = 'dropdown',
                    order = 3,
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
                    name = 'New',
                    desc = 'Create a new message.',
                    type = 'execute',
                    width = .5,
                    order = 4,
                    disabled = function() return not selectedMessage end,
                    func = function()
                        tblMessage = optTables:newMsg()
                        selectedMessage = nil
                    end,
                },
                msgInviteDesc = {
                    name = 'Invite Description',
                    desc = 'Short description of the message.',
                    type = 'input',
                    multiline = false,
                    order = 5,
                    width = 'full',
                    set = function(_, val) tblMessage.desc = val end,
                    get = function() return tblMessage.desc or '' end,
                },
                msgInvite = {
                    name = 'Invite Message',
                    type = 'input',
                    multiline = 10,
                    order = 6,
                    width = 'full',
                    set = function(_, val) tblMessage.message = val end,
                    get = function() return tblMessage.message or '' end,
                },
                msgHeader3 = {
                    name = 'Message Preview',
                    type = 'header',
                    order = 7,
                },
                msgPreview = {
                    name = function()
                        mPreview = ns.code:GuildReplace(tblMessage.message)
                        return (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(mPreview or ''))) or ''
                    end,
                    type = 'description',
                    order = 8,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgNotGM = {
                    name = function()
                        local errMsg = (tblMessage.message and strfind(tblMessage.message, 'GUILDLINK') and not ns.db.guildInfo.guildLink and not IsGuildLeader()) and 'WARNING: You are not a GM, so GUILDLINK is an invalid option.' or nil
                        return errMsg and ns.code:cText('FFFF0000', errMsg) or ' '
                    end,
                    type = 'description',
                    order = 9,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgHeader4 = {
                    name = '',
                    type = 'header',
                    order = 10
                },
                msgPreviewCount = {
                    name = function()
                        local count = string.len(mPreview or '')
                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        return 'Message Length: '..ns.code:cText(color, count)..' (255 characters per message)'
                    end,
                    type = 'description',
                    order = 11,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgHeader5 = {
                    name = '',
                    type = 'header',
                    order = 12,
                },
                msgInviteDel = {
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
            },
        },
        mnuOptions = {
            name = 'GR Options',
            type = 'group',
            order = 12,
            args = {
                msgHeader1 = {
                    name = 'General Settings',
                    type = 'header',
                    width = 'full',
                    order = 0,
                },
                optIcon = {
                    name = 'Show icon on minimap',
                    desc = 'Toggles the visibility of the minimap icon.  You can use /gr or /gr config to access the addon.',
                    type = 'toggle',
                    width = 'full',
                    order = 1,
                    set = function(_, val) ns.db.settings.minimap = { hide = not val } end,
                    get = function()
                        if not ns.db.settings.minimap.hide then icon:Show('GR_Icon')
                        else icon:Hide('GR_Icon') end
                        return not ns.db.settings.minimap.hide
                    end,
                },
                optSystemMsg = {
                    name = 'Show addon messages in chat.',
                    desc = 'Shows verbose addon messages in chat, suggest disabling.',
                    type = 'toggle',
                    width = 'full',
                    order = 2,
                    set = function(_, val) ns.db.settings.showAppMsgs = val end,
                    get = function() return ns.db.settings.showAppMsgs end,
                },
                optContextMnu = {
                    name = 'Show context menu for guild invite/black list.',
                    desc = 'When you right click on a player in chat, an extra menu will appear to invite to guild or black list.',
                    type = 'toggle',
                    width = 'full',
                    order = 3,
                    set = function(_, val) ns.db.settings.showContext = val end,
                    get = function() return ns.db.settings.showContext end,
                },
                optWhoQuery = {
                    name = 'Show the /who query window.',
                    desc = 'This will show the /who query window when scanning.',
                    type = 'toggle',
                    width = 'full',
                    order = 4,
                    set = function(_, val) ns.db.settings.showWho = val end,
                    get = function() return ns.db.settings.showWho end,
                },
                optCompant = {
                    name = 'Scanning window defaults to compact.',
                    desc = 'Size of the recruit scanning window.',
                    type = 'toggle',
                    width = 'full',
                    order = 5,
                    set = function(_, val) ns.db.settings.compactMode = val end,
                    get = function() return ns.db.settings.compactMode end,
                },
                msgHeader2 = {
                    name = 'Invite Settings',
                    type = 'header',
                    order = 10,
                },
                optShowStats = {
                    name = 'Show invite summary after finishing scans.',
                    desc = 'This shows, # of invites, accepted, deleted and pending.',
                    type = 'toggle',
                    width = 'full',
                    order = 12,
                    set = function(_, val) ns.db.settings.showSummary = val end,
                    get = function() return ns.db.settings.showSummary end,
                },
                optShowInvite = {
                    name = 'Show your whisper when sending invite messages.',
                    desc = 'This will show or hide whisper messages to recruits, suggest going to social and turn on in-line whispers for best results.',
                    type = 'toggle',
                    width = 'full',
                    order = 13,
                    set = function(_, val) ns.db.settings.showWhispers = val end,
                    get = function() return ns.db.settings.showWhispers end,
                },
                optShowPersonalGreeting = {
                    name = 'Send guild greeting message when invite is accepted.',
                    desc = 'Enable/disable greeting message to newly joined players.',
                    type = 'toggle',
                    width = 'full',
                    order = 14,
                    disabled = function() return not IsGuildLeader() and ns.dbGlobal.greeting end,
                    set = function(_, val) ns.db.settings.sendGreeting = val end,
                    get = function() return ns.dbGlobal.greeting or ns.db.settings.sendGreeting end,
                },
                optPersonalGreetingMsg = {
                    name = 'Greeting Message',
                    desc = 'This message will be sent to guild chat when a player accepts invite.',
                    type = 'input',
                    width = 'full',
                    order = 15,
                    disabled = function() return not IsGuildLeader() and ns.dbGlobal.greeting end,
                    set = function(_, val) ns.db.settings.greetingMsg = val end,
                    get = function()
                        print(ns.dbGlobal.greetingMsg)
                        if ns.dbGlobal.greeting then return ns.dbGlobal.greetingMsg
                        else return (not ns.db.settings.greetingMsg or ns.db.settings.greetingMsg == '') and (ns.dbGlobal.greetingMsg or '') or (ns.db.settings.greetingMsg or '') end
                    end,
                },
                optShowPersonalWelcome = {
                    name = 'Send to guild chat personalized welcome message.',
                    desc = 'This will welcome each player that joins and is seperate from the greeting message.',
                    type = 'toggle',
                    width = 'full',
                    order = 16,
                    --disabled = function() return not IsGuildLeader() and ns.dbGlobal.greeting end,
                    set = function(_, val) ns.db.settings.sendWelcome = val end,
                    get = function() return ns.db.settings.sendWelcome end,
                },
                optPersonalWelcomeMsg = {
                    name = 'Individual Greeting Message',
                    desc = 'This will make the greeting individualized and shown in guild chat.\nUse NAME (in caps) to substitute the name of the player that joined.',
                    type = 'input',
                    width = 'full',
                    order = 17,
                    --disabled = function() return not IsGuildLeader() and ns.dbGlobal.greeting end,
                    set = function(_, val) ns.db.settings.welcomeMessage = val end,
                    get = function()
                        ns.db.settings.welcomeMessage = ns.db.settings.welcomeMessage or DEFAULT_GUILD_WELCOME
                        return ns.db.settings.welcomeMessage
                    end,
                },
                optScanInterval = {
                    name = 'Time to wait between scans (default recommended).',
                    desc = 'WoW requires a cooldown period between /who scans, this is the time that the system will wait between scans.',
                    type = 'input',
                    width = 'full',
                    order = 17,
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then ns.db.settings.scanWaitTime = tonumber(val)
                        else return tostring(ns.db.settings.scanWaitTime) end
                    end,
                    get = function() return tostring(ns.db.settings.scanWaitTime) end,
                },
                optWhoNote = {
                    name = ns.code:cText('FFFFFF00', 'NOTE: ')..'After much testing, the default 6 seconds seems to consistently give results, less wait time seems to not always return data.',
                    type = 'description',
                    order = 18,
                    width = 'full',
                    fontSize = 'medium'
                },
            }
        },
        mnuFilterList = {
            name = 'Custom Filters',
            type = 'group',
            order = 13,
            args = {
                filterHeader1 = {
                    name = 'Filter Editor',
                    type = 'header',
                    order = 1,
                },
                filterEdit = {
                    name = 'Select a filter to edit',
                    type = 'select',
                    style = 'dropdown',
                    order = 2,
                    width = 1.5,
                    values = function()
                        local tbl = {}
                        for k, r in pairs(ns.db.filter.filterList or {}) do tbl[k] = r.desc end
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
                    name = 'New',
                    desc = 'Create a new filter.',
                    type = 'execute',
                    width = .5,
                    order = 3,
                    disabled = function() return not selectedFilter end,
                    func = function()
                        selectedFilter, filterOld = nil, nil
                        tblRaces = optTables:newRace()
                        tblFilter = optTables:newFilter()
                        tblClasses = optTables:newClass()
                    end,
                },
                filterHeader2 = {
                    name = 'Filter Creator',
                    type = 'header',
                    order = 9,
                },
                filterDesc = {
                    name = 'Filter Description',
                    desc = 'Short description of the filter.',
                    type = 'input',
                    multiline = false,
                    order = 10,
                    width = 1.5,
                    set = function(_, val) tblFilter.desc = val end,
                    get = function() return tblFilter.desc or '' end,
                },
                filterSave = {
                    name = 'Save',
                    type = 'execute',
                    width = .5,
                    order = 12,
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
                    name = 'Delete',
                    type = 'execute',
                    width = .5,
                    order = 13,
                    disabled = function() return not selectedFilter end,
                    confirm = function() return 'Are you sure you want to delete this record?' end,
                    func = function()
                        local filterList = ns.db.filter.filterList
                        filterList[selectedFilter] = nil

                        selectedFilter, filterOld = nil, nil
                        tblRaces = optTables:newRace()
                        tblFilter = optTables:newFilter()
                        tblClasses = optTables:newClass()
                    end,
                },
                filterCustom = {
                    name = 'Custom filter',
                    desc = 'Edit and/or create your filter.',
                    type = 'input',
                    multiline = false,
                    order = 14,
                    width = 'full',
                    set = function(_, val) tblFilter.filter = val end,
                    get = function() createFilterPreview() return tblFilter.filter or '' end,
                },
                filterClass = {
                    name = 'Classes (Only select 1 group or multiple classes)',
                    desc = 'Specific class, classes with type of damage, heals or tanks, etc.',
                    type = 'multiselect',
                    style = 'dropdown',
                    order = 20,
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
                    name = 'Races',
                    desc = 'All races or specific races.',
                    type = 'multiselect',
                    style = 'dropdown',
                    order = 21,
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
            }
        },
        mnuBlackList = {
            name = 'Black List',
            type = 'group',
            order = 14,
            args = {
                blDesc = {
                    name = 'Players marked in '..ns.code:cText('FFFF0000', 'RED')..' are marked for deletion.\nPlayers marked in '..ns.code:cText('FF00FF00', 'GREEN')..' are active black listed players.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 1,
                },
                blRemoveButton = {
                    name = 'Toggle Selected Black List Entries',
                    desc = 'Black List entries marked for deletion will be perinately removed 30 days after marked.  During this time, the addon will ignore the selected Black List entries.',
                    type = 'execute',
                    width = 'full',
                    order = 2,
                    func = function()
                        for _,r in pairs(ns.dbBL.blackList) do
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
                        for k, r in pairs(ns.dbBL.blackList or {}) do
                            local name = k:gsub('-'..GetRealmName(), '')
                            name = r.markedForDelete and ns.code:cText('FFFF0000', name) or ns.code:cText('FF00FF00', name)
                            tbl[k] = (name..': '..r.reason) or ''
                        end

                        return tbl
                    end,
                    set = function(_, key, val)
                        local r = ns.dbBL.blackList[key]
                        ns.dbBL.blackList[key] = {
                            dateBlackList = r.dateBlackList,
                            markedForDelete = r.markedForDelete,
                            whoDidIt = r.whoDidIt,
                            reason = r.reason,
                            selected = val,
                            expirationDate = r.expirationDate,
                        }
                    end,
                    get = function(_, key) return ns.dbBL.blackList[key].selected or false end,
                }
            }
        },
        mnuBlank3 = {
            type = 'group',
            name = '',
            order = 97,
            args = {}
        },
        mnuAbout = {
            type = 'group',
            name = 'About GR',
            order = 98,
            args = {
                aboutDesc1 = {
                    name = 'Guild Recruiter',
                    type = 'description',
                    image = 'Interface\\AddOns\\GuildRecruiter\\imgs\\GR_Logo',
                    imageWidth = 32,
                    imageHeight = 32,
                    fontSize = 'medium',
                    order = 0,
                },
                aboutDesc2 = {
                    name = 'Thank you for using Guild Recruiter, I hope you find this addon useful!',
                    type = 'description',
                    fontSize = 'medium',
                    order = 1,
                },
                aboutDesc3 = {
                    name = '\nI am 100% self taught programmer that does this for a hobby (if you look at my code it is obvious, I am sure).  I started with Basic on a Commodore 64 and have since dabbled in Visual Basic, C+ and C#.  WoW gave me the opportunity to learn LUA and create adodns that players may find useful.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 2,
                },
                aboutDesc4 = {
                    name = '\nI truly hope this addon is useful for you and will use it for many expansions to come.  Comments and feedback are important and bellow I have added some useful links to communicate your needs with me.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 3,
                },
                aboutHeader1 = {
                    name = 'Links',
                    type = 'header',
                    order = 4,
                },
                aboutDesc5 = {
                    name = 'Bellow is a list of helpful links incase you need some support.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 5,
                },
                aboutLink1 = {
                    name = 'CurseForge',
                    type = 'input',
                    width = 'full',
                    order = 6,
                    set = function() ns.code:OpenURL('https://www.curseforge.com/wow/addons/guild-recruiter') end,
                    get = function() return 'https://www.curseforge.com/wow/addons/guild-recruiter' end,
                },
                aboutLink2 = {
                    name = 'GitHub (Support documentation)',
                    type = 'input',
                    width = 'full',
                    order = 7,
                    set = function() ns.code:OpenURL('https://github.com/zaldor30/GuildRecruiter') end,
                    get = function() return 'https://github.com/zaldor30/GuildRecruiter' end,
                },
                aboutLink3 = {
                    name = 'Discord',
                    type = 'input',
                    width = 'full',
                    order = 8,
                    set = function() ns.code:OpenURL('https://discord.gg/ZtS6Q2sKRH') end,
                    get = function() return 'https://discord.gg/ZtS6Q2sKRH' end,
                },
                aboutLink4 = {
                    name = 'Buy Me a Coffee',
                    type = 'input',
                    width = 'full',
                    order = 9,
                    set = function() ns.code:OpenURL('https://bmc.link/alwaysbeconvoking') end,
                    get = function() return 'https://bmc.link/alwaysbeconvoking' end,
                },
                aboutHeader2 = {
                    name = 'Call for help!',
                    type = 'header',
                    order = 10,
                },
                aboutDesc6 = {
                    name = 'If you would like to help localize this addon, I would appreciate the help.  Please, join my Discord and let me know if interested.',
                    type = 'description',
                    fontSize = 'medium',
                    order = 11,
                },
            }
        },
    }
}