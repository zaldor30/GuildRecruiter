-- Guild Recruiter Configuration Options
local _, ns = ... -- Namespace (myaddon, namespace)
local icon = LibStub('LibDBIcon-1.0')

local p,g = nil, nil
local cText = ns.code:cText()
local fPreview = nil
local optTables = {}

function ns:SetOptionsDB() p, g = ns.db.profile, ns.db.global
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
local function createFilter()
    local filter = nil
    if tblFilter.race then filter = "-r'"..tblFilter.race.."'" end
    if tblFilter.race and tblFilter.class then filter = filter.." " end
    if tblFilter.class then filter = filter.."-c'"..tblFilter.class.."'" end
    tblFilter.filter = filter
end

local tblFilter = optTables:resetFilter()
local tblMessage = optTables:resetMsg()

local activeFilter = false
ns.options = {
    name = 'GuildRecruiter',
    type = 'group',
    args = {
        mnuMsg = {
            msgHeader1 = {
                name = 'Message Formatting',
                type = 'header',
                order = 0,
            },
            msgDesc = {
                name = cText('FFFFFF00', 'NAME')..': Player name that is being invited to the guild.\n'..cText('FFFFFF00', 'GUILDLINK')..': Clickable link to allow player to join the guild.\n'..cText('FFFFFF00', 'GUILDNAME')..': Guild name in format <ShadowBound>.',
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
                values = function() return g.messages or {} end,
                set = function(_, val) g.activeMessage = val end,
                get = function(_)
                    local msg = g.messages or nil
                    local active = g.activeMessage or nil

                    if active and msg then
                        tblMessage = msg[active] or {}
                        return active
                    elseif not msg then p.activeMessage = nil end
                end,
            },
            msgNewBtn = {
                name = 'New',
                desc = 'Create a new message.',
                type = 'execute',
                width = .5,
                order = 4,
                disabled = function() return not p.activeMessage end,
                func = function()
                    p.activeMessage = nil
                    tblMessage = optTables:resetMsg()
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
                    fPreview = ns.invite:GuildReplace(tblMessage.message)
                    return cText('FFFF80FF', 'To [')..ns.code.fPlayerName..cText('FFFF80FF', ']: '..fPreview)
                end,
                type = 'description',
                order = 8,
                width = 'full',
                fontSize = 'medium'
            },
            msgNotGM = {
                name = function()
                    local errMsg = (tblMessage.message and strfind(tblMessage.message, 'GUILDLINK') and not IsGuildLeader()) and 'WARNING: You are not a GM, so GUILDLINK is an invalid option.' or nil
                    return errMsg and cText('FFFF0000', errMsg) or ' '
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
                    local count = string.len(fPreview)
                    local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                    return 'Message Length: '..cText(color, count)..' (255 characters per message)'
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
                disabled = function() return not p.activeMessage and true or false end,
                func = function()
                    local msg = g.messages or nil
                    local active = p.activeMessage or nil
                    if active and msg and msg[active] then
                        msg[active] = nil
                        active = nil
                        tblMessage = optTables:resetMsg()
                    end
                end,
            },
            msgInviteSave = {
                name = 'Save',
                desc = 'Save the selected message.',
                type = 'execute',
                width = .5,
                disabled = function() return (tblMessage.desc ~= '' and tblMessage.message ~= '') and false or true end,
                func = function()
                    msg = global.messages or {}
                    active = p.activeMessage
                    if not active then
                        table.insert(msg, tblMessage)
                        active = #msg
                    else msg[active] = tblMessage end
                    ns.widgets:createErrorWindow('Message Saved')
                end,
            },
        }
    }
}