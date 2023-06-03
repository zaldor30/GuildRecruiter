-- Guild Recruiter Configuration Options
local code, cText = GR_CODE, GR_CODE.cText
local class = select(2, UnitClass('player'))
local cClass = select(4, GetClassColor(class))
local formattedPreview = ''

local function resetTable()
    local tbl = {
        desc = '',
        message = '',
    }
    return tbl
end
local tblMessage = resetTable()

GR_MAIN_OPTIONS = {
    name = 'Guild Recruiter',
    handler = GR_ADDON,
    type = 'group',
    args = {
        optGeneral = {
            name = 'General',
            order = 1,
            handler = GR_ADDON,
            type = 'group',
            args = {
                genHeader1 = {
                    name = 'General Settings',
                    type = 'header',
                    order = 0,
                },
                showIcon = {
                    name = 'Show Minimap Icon',
                    desc = 'Show/Hide the icon from the minimap.',
                    type = 'toggle',
                    order = 0,
                    width = 'full',
                    set = function(_, val) GRDB.profile.minimap = { hide = not val } end,
                    get = function(_)
                        if not GRDB.profile.minimap.hide then GR_LIBSTUB:Show('GR_Icon')
                        else GR_LIBSTUB:Hide('GR_Icon') end
                        return not GRDB.profile.minimap.hide
                    end,
                },
                showMenu = {
                    name = 'Show menu when clicking on names in chat.',
                    desc = 'Shows a menu for invite, black list, etc in a dropdown menu.',
                    type = 'toggle',
                    order = 1,
                    width = 'full',
                    set = function(_, val) GRDB.global.showMenu = val end,
                    get = function(_) return GRDB.global.showMenu end,
                },
                genHeader2 = {
                    name = 'Invite Settings',
                    type = 'header',
                    order = 2,
                },
                showMsg = {
                    name = 'Do not show messages sent to potential recruits.',
                    desc = 'Only works if you have in-line checked under Social/New Whispers.',
                    type = 'toggle',
                    order = 3,
                    width = 'full',
                    set = function(_, val) GRDB.global.showMsg = val end,
                    get = function(_) return GRDB.global.showMsg end,
                },
                scanPlayers = {
                    name = 'Perform Auto Scan',
                    desc = 'Will scan for players without intervention.',
                    type = 'toggle',
                    order = 4,
                    width = 1.2,
                    set = function(_, val) GRDB.global.scanPlayers = val end,
                    get = function(_) return GRDB.global.scanPlayers end,
                },
                scanTime = {
                    name = 'Time to wait between scans',
                    desc = 'Must be more than 5 seconds.',
                    type = 'input',
                    validate = function(_, val)
                        val = val and tonumber(val) or nil
                        local valid = (val and type(val) == 'number' and val >= 5) and true or false
                        return valid
                    end,
                    order = 5,
                    width = .8,
                    set = function(_, val) GRDB.global.scanTime = val end,
                    get = function(_) return GRDB.global.scanTime end,
                },
                rememberPlayers = {
                    name = 'Remember invited players',
                    desc = 'Remember players that were invited so you do not duplicate invites.',
                    type = 'toggle',
                    order = 6,
                    width = 1.2,
                    set = function(_, val) GRDB.global.remember = val end,
                    get = function(_) return GRDB.global.remember end,
                },
                rememberTime = {
                    name = 'Time to wait',
                    desc = 'How long to wait before attempting a reinvite.',
                    type = 'select',
                    style = 'dropdown',
                    values = {
                        ['WEEK'] = '7 days.',
                        ['MONTH'] = '30 days.',
                        ['QUARTER'] = '90 days.',
                        ['YEAR'] = '365 days.',
                    },
                    order = 67,
                    width = .8,
                    set = function(_, val) GRDB.global.rememberTime = val end,
                    get = function(_) return GRDB.global.rememberTime end,
                },
            },
        },
        optMessages = {
            name = 'Messages',
            order = 2,
            handler = GR_ADDON,
            type = 'group',
            args = {
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
                activeMessage = {
                    name = 'Invite Messages',
                    desc = 'The messges that will be sent to potential recruits.',
                    type = 'select',
                    style = 'dropdown',
                    order = 3,
                    width = 2,
                    values = function()
                        if GRDB.global.messages then
                            local tbl = {}
                            for k, r in pairs(GRDB.global.messages) do tbl[k] = r.desc end
                            return tbl
                        else return {} end
                    end,
                    set = function(_, val) GRDB.global.activeMessage = val end,
                    get = function(_)
                        if GRDB.global.activeMessage and GRDB.global.messages then
                            tblMessage = GRDB.global.messages[GRDB.global.activeMessage]
                            return GRDB.global.activeMessage
                        elseif not GRDB.global.messages then GRDB.global.activeMessage = nil end
                    end,
                },
                msgInviteNew = {
                    name = 'New',
                    desc = 'Create a new message.',
                    type = 'execute',
                    width = .5,
                    order = 4,
                    disabled = function()
                        if GRDB.global.activeMessage then return false
                        else return true end
                    end,
                    func = function()
                        GRDB.global.activeMessage = nil
                        tblMessage = resetTable()
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
                        formattedPreview = code.GuildReplace(tblMessage.message)
                        local msg = cText('FFFF80FF', 'To [')..cText(cClass, UnitName('player'))..cText('FFFF80FF', ']: '..formattedPreview)
                        return msg
                    end,
                    type = 'description',
                    order = 8,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgHeader4 = {
                    name = '',
                    type = 'header',
                    order = 9
                },
                msgPreviewCount = {
                    name = function()
                        local count = string.len(formattedPreview)
                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        local msg = 'Message Length: '..cText(color, count)..' (255 characters per message)'

                        return msg
                    end,
                    type = 'description',
                    order = 10,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgHeader5 = {
                    name = '',
                    type = 'header',
                    order = 11,
                },
                msgInviteDel = {
                    name = 'Delete',
                    desc = 'Delete the selected message.',
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        return (not GRDB or not GRDB.global.activeMessage) and true or false
                    end,
                    func = function()
                        if GRDB.global.activeMessage and GRDB.global.messages[GRDB.global.activeMessage] then
                            GRDB.global.messages[GRDB.global.activeMessage] = nil
                            GRDB.global.activeMessage = nil
                            tblMessage = resetTable()
                        end
                    end,
                },
                msgInviteSave = {
                    name = 'Save',
                    desc = 'Save the selected message.',
                    type = 'execute',
                    width = .5,
                    disabled = function()
                        if tblMessage.desc ~= '' and tblMessage.message ~= '' then return false
                        else return true end
                    end,
                    func = function()
                        GRDB.global.messages = GRDB.global.messages or {}
                        if not GRDB.global.activeMessage then
                            table.insert(GRDB.global.messages, tblMessage)
                            GRDB.global.activeMessage = #GRDB.global.messages
                        else GRDB.global.messages[GRDB.global.activeMessage] = tblMessage end

                        INFO_BOX('Record Saved', 'Message has been saved.', 'Press the Close button', 250)
                    end,
                },
            }
        },
        optFilters = {
            name = 'Filters',
            order = 3,
            handler = GR_ADDON,
            type = 'group',
            args = {}
        },
        optBlackList = {
            name = 'Black List',
            order = 4,
            handler = GR_ADDON,
            type = 'group',
            args = {}
        },
        optSync = {
            name = 'Syncronize',
            order = 5,
            handler = GR_ADDON,
            type = 'group',
            args = {}
        },
    }
}