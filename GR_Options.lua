-- Guild Recruiter Configuration Options
local _, ns = ... -- Namespace (myaddon, namespace)
local icon = LibStub('LibDBIcon-1.0')

local p,g = nil, nil
local code = ns.code
local fPreview = nil
local optTables = {}
local selectedMessage = nil

function ns:SetOptionsDB() p, g = ns.db.profile, ns.db.global end
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
local function createFilter()
    local filter = nil
    if tblFilter.race then filter = "-r'"..tblFilter.race.."'" end
    if tblFilter.race and tblFilter.class then filter = filter.." " end
    if tblFilter.class then filter = filter.."-c'"..tblFilter.class.."'" end
    tblFilter.filter = filter
end

local activeFilter = false
ns.options = {
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
                    name = code:cText('FFFFFF00', 'NAME')..': Player name that is being invited to the guild.\n'..code:cText('FFFFFF00', 'GUILDLINK')..': Clickable link to allow player to join the guild.\n'..code:cText('FFFFFF00', 'GUILDNAME')..': Guild name in format <ShadowBound>.',
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
                        if g.messages then
                            for k, r in pairs(g.messages) do tbl[k] = r.desc end
                        end
                        return tbl
                    end,
                    set = function(_, val) selectedMessage = val end,
                    get = function(_)
                        local msg = g.messages or nil
                        local active = selectedMessage or nil

                        if active and msg then
                            tblMessage = msg[active] or {}
                            return active
                        elseif not msg then selectedMessage = nil end
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
                    get = function(_) return tblMessage.desc or '' end,
                },
                msgInvite = {
                    name = 'Invite Message',
                    type = 'input',
                    multiline = 10,
                    order = 6,
                    width = 'full',
                    set = function(_, val) tblMessage.message = val end,
                    get = function(_) return tblMessage.message or '' end,
                },
                msgHeader3 = {
                    name = 'Message Preview',
                    type = 'header',
                    order = 7,
                },
                msgPreview = {
                    name = function()
                        fPreview = code:GuildReplace(tblMessage.message)
                        return (code:cText('FFFF80FF', 'To [')..code.fPlayerName..code:cText('FFFF80FF', ']: '..(fPreview or ''))) or ''
                    end,
                    type = 'description',
                    order = 8,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgNotGM = {
                    name = function()
                        local errMsg = (tblMessage.message and strfind(tblMessage.message, 'GUILDLINK') and not p.guildInfo.guildLink and not IsGuildLeader()) and 'WARNING: You are not a GM, so GUILDLINK is an invalid option.' or nil
                        return errMsg and code:cText('FFFF0000', errMsg) or ' '
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
                        return 'Message Length: '..code:cText(color, count)..' (255 characters per message)'
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
                        local msg = g.messages or nil
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
                        local msg = g.messages or {}
                        local active = selectedMessage
                        if not active then
                            table.insert(msg, tblMessage)
                            active = #msg
                        else msg[active] = tblMessage end
                        g.messages = msg

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
                    set = function(_, val) p.minimap = { hide = not val } end,
                    get = function(_)
                        if not p.minimap.hide then icon:Show('GR_Icon')
                        else icon:Hide('GR_Icon') end
                        return not p.minimap.hide
                    end,
                },
                optSystemMsg = {
                    name = 'Show addon messages in chat.',
                    desc = 'Shows verbose addon messages in chat, suggest disabling.',
                    type = 'toggle',
                    width = 'full',
                    order = 2,
                    set = function(_, val) g.showSystem = val end,
                    get = function(_) return g.showSystem end,
                },
                optContextMnu = {
                    name = 'Show context menu for guild invite/black list.',
                    desc = 'When you right click on a player in chat, an extra menu will appear to invite to guild or black list.',
                    type = 'toggle',
                    width = 'full',
                    order = 3,
                    set = function(_, val) g.showMenu = val end,
                    get = function(_) return g.showMenu end,
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
                    set = function(_, val) g.showWhisper = val end,
                    get = function(_) return g.showWhisper end,
                },
                optShowAccepted = {
                    name = 'Send guild greeting message when invite is accepted.',
                    desc = 'Enable/disable greeting message to newly joined players.',
                    type = 'toggle',
                    width = 'full',
                    order = 12,
                    set = function(_, val) p.showGreeting = val end,
                    get = function(_) return p.showGreeting end,
                },
                optShowAcceptedMsg = {
                    name = 'Greeting Message',
                    desc = 'This message will be sent to guild chat when a player accepts invite.',
                    type = 'input',
                    width = 'full',
                    order = 13,
                    set = function(_, val) p.greeting = val end,
                    get = function(_) return p.greeting end,
                },
                optScanInterval = {
                    name = 'Time to wait between scans (default recommended).',
                    desc = 'WoW requires a cooldown period between /who scans, this is the time that the system will wait between scans.',
                    type = 'input',
                    width = 'full',
                    order = 14,
                    set = function(_, val)
                        if tonumber(val) >=2 and tonumber(val) < 10 then g.scanTime = val
                        else return g.scanTime end
                    end,
                    get = function(_) return g.scanTime end,
                },
                optRememberInvite = {
                    name = 'Anti guild spam protection.',
                    desc = "Remembers invited players so you don't constantly spam them invites",
                    type = 'toggle',
                    width = 1.5,
                    order = 15,
                    set = function(_, val) p.remember = val end,
                    get = function(_) return p.remember end,
                },
                optReInvite = {
                    name = 'Reinvite players after:',
                    desc = 'Number of days before resetting invite status.',
                    type = 'select',
                    style = 'dropdown',
                    order = 16,
                    width = 1,
                    values = function()
                        return {
                            [1] = '1 day',
                            [3] = '3 days',
                            [5] = '5 days',
                            [7] = '7 days',
                        }
                    end,
                    set = function(_, val) p.rememberTime = val end,
                    get = function(_) return p.rememberTime or 7 end,
                },
            }
        },
    }
}