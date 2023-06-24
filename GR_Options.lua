-- Guild Recruiter Configuration Options
local _, ns = ... -- Namespace (myaddon, namespace)
local icon = LibStub('LibDBIcon-1.0')

local fPreview, selectedMessage = nil, nil

local optTables = {}
function optTables:newMsg()
    return {
        desc = '',
        message = '',
    }
end
function optTables:newFilter()
    return {
        lvlMin = 1,
        lvlMax = MAX_CHARACTER_LEVEL,
        race = nil,
        class = nil,
        filter = nil,
        desc = nil,
    }
end

local tblFilter = optTables:newFilter()
local tblMessage = optTables:newMsg()

ns.addonSettings = {
    name = GR_VERSION_INFO,
    type = 'group',
    args = {
        mnuMsg = {
            name = 'Messages',
            type = 'group',
            order = 0,
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
                        for k, r in pairs(ns.db.messages and ns.db.messages.messageList or {}) do tbl[k] = r.desc end
                        return tbl
                    end,
                    set = function(_, val) selectedMessage = val end,
                    get = function()
                        local msg = ns.db.messages and ns.db.messages.messageList or nil
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
                        fPreview = ns.code:GuildReplace(tblMessage.message)
                        return (ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(fPreview or ''))) or ''
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
                        local count = string.len(fPreview or '')
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
                            table.insert(msg, tblMessage)
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
            order = 1,
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
                optShowInvite = {
                    name = 'Show your whisper when sending invite messages.',
                    desc = 'This will show or hide whisper messages to recruits, suggest going to social and turn on in-line whispers for best results.',
                    type = 'toggle',
                    width = 'full',
                    order = 11,
                    set = function(_, val) ns.db.settings.showWhispers = val end,
                    get = function() return ns.db.settings.showWhispers end,
                },
                optShowAccepted = {
                    name = 'Send guild greeting message when invite is accepted.',
                    desc = 'Enable/disable greeting message to newly joined players.',
                    type = 'toggle',
                    width = 'full',
                    order = 12,
                    set = function(_, val) ns.db.settings.sendGreeting = val end,
                    get = function() return ns.db.settings.sendGreeting end,
                },
                optShowAcceptedMsg = {
                    name = 'Greeting Message',
                    desc = 'This message will be sent to guild chat when a player accepts invite.',
                    type = 'input',
                    width = 'full',
                    order = 13,
                    set = function(_, val) ns.db.settings.greetingMsg = val end,
                    get = function() return ns.db.settings.greetingMsg end,
                },
                optScanInterval = {
                    name = 'Time to wait between scans (default recommended).',
                    desc = 'WoW requires a cooldown period between /who scans, this is the time that the system will wait between scans.',
                    type = 'input',
                    width = 'full',
                    order = 14,
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then ns.db.settings.scanWaitTime = tonumber(val)
                        else return tostring(ns.db.settings.scanWaitTime) end
                    end,
                    get = function() return tostring(ns.db.settings.scanWaitTime) end,
                },
                msgHeader3 = {
                    name = 'Guild Master Settings',
                    type = 'header',
                    order = 20,
                },
                optDisclaimer = {
                    name = '|CFFFF0000Note: These settings are controlled by the Guild Master.|r',
                    fontSize = 'medium',
                    type = 'description',
                    order = 21,
                    hidden = IsGuildLeader(),
                },
                optRememberInvite = {
                    name = 'Anti guild spam protection.',
                    desc = "Remembers invited players so you don't constantly spam them invites",
                    type = 'toggle',
                    disabled = not IsGuildLeader(),
                    width = 1.5,
                    order = 22,
                    set = function(_, val) ns.db.settings.antiSpam = val end,
                    get = function() return ns.db.settings.antiSpam end,
                },
                optReInvite = {
                    name = 'Reinvite players after:',
                    desc = 'Number of days before resetting invite status.',
                    type = 'select',
                    style = 'dropdown',
                    order = 23,
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
                    set = function(_, val) ns.db.settings.reinviteAfter = tonumber(val) end,
                    get = function() return ns.db.settings.reinviteAfter end,
                },
            }
        },
        mnuBlackList = {
            name = 'Black List',
            type = 'group',
            order = 3,
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
    }
}