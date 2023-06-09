-- Guild Recruiter Configuration Options
local _, ns = ... -- Namespace (myaddon, namespace)
local icon = LibStub('LibDBIcon-1.0')

local profile, global = nil, nil
local cText = ns.code.cText
local class = select(2, UnitClass('player'))
local cClass = select(4, GetClassColor(class))
local formattedPreview = ''

local function tables()
    local tbl = {}
    function tbl:resetMsg()
        return {
            desc = '',
            message = '',
        }
    end
    function tbl:resetFilter()
        return {
            lvlMin = 1,
            lvlMax = MAX_CHARACTER_LEVEL,
            race = nil,
            class = nil,
            filter = nil,
            desc = nil,
        }
    end
    function tbl:CreateFilter()
        local filter = nil
        if tblFilter.race then filter = "-r'"..tblFilter.race.."'" end
        if tblFilter.race and tblFilter.class then filter = filter.." " end
        if tblFilter.class then filter = filter.."-c'"..tblFilter.class.."'" end
        tblFilter.filter = filter
    end

    return tbl
end
local optTables = tables()
tblFilter = optTables:resetFilter()
tblMessage = optTables:resetMsg()

local activeFilter = false
GR_MAIN_OPTIONS = {
    name = 'GuildRecruiter',
    type = 'group',
    args = {
        optMessages = {
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
                        local tbl = {}
                        if global.messages then
                            for k, r in pairs(global.messages) do tbl[k] = r.desc end
                        end
                        return tbl
                    end,
                    set = function(_, val) profile.activeMessage = val end,
                    get = function(_)
                        if profile.activeMessage and global.messages then
                            tblMessage = global.messages[profile.activeMessage]
                            return profile.activeMessage
                        elseif not global.messages then profile.activeMessage = nil end
                    end,
                },
                msgInviteNew = {
                    name = 'New',
                    desc = 'Create a new message.',
                    type = 'execute',
                    width = .5,
                    order = 4,
                    disabled = function() return not profile.activeMessage end,
                    func = function()
                        profile.activeMessage = nil
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
                        formattedPreview = ns.code.GuildReplace(tblMessage.message)
                        local msg = cText('FFFF80FF', 'To [')..cText(cClass, UnitName('player'))..cText('FFFF80FF', ']: '..formattedPreview)
                        return msg
                    end,
                    type = 'description',
                    order = 8,
                    width = 'full',
                    fontSize = 'medium'
                },
                msgNotGM = {
                    name = function()
                        local errMsg = (tblMessage.message and strfind(tblMessage.message, 'GUILDLINK') and not IsGuildLeader()) and 'WARNING: You are not a GM, so GUILDLINK is an invalid option.' or nil
                        return cText('FFFF0000', errMsg or ' ')
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
                        local count = string.len(formattedPreview)
                        local color = count < 255 and 'FF00FF00' or 'FFFF0000'
                        local msg = 'Message Length: '..cText(color, count)..' (255 characters per message)'

                        return msg
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
                    disabled = function()
                        return not profile.activeMessage and true or false
                    end,
                    func = function()
                        if profile.activeMessage and global.messages[profile.activeMessage] then
                            global.messages[profile.activeMessage] = nil
                            profile.activeMessage = nil
                            tblMessage = optTables:resetMsg()
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
                        global.messages = global.messages or {}
                        if not profile.activeMessage then
                            table.insert(global.messages, tblMessage)
                            profile.activeMessage = #global.messages
                        else global.messages[profile.activeMessage] = tblMessage end
                        ns.code.createErrorWindow('Message Saved')
                    end,
                },
            }
        },
        optGeneral = {
            name = 'General Settings',
            type = 'group',
            order = 1,
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
                    width = 'full',
                    order = 0,
                    set = function(_, val) profile.minimap = { hide = not val } end,
                    get = function(_)
                        if not profile.minimap.hide then icon:Show('GR_Icon')
                        else icon:Hide('GR_Icon') end
                        return not profile.minimap.hide
                    end,
                },
                showMenu = {
                    name = 'Show menu when clicking on names in chat.',
                    desc = 'Shows a menu for invite, black list, etc in a dropdown menu.',
                    type = 'toggle',
                    order = 1,
                    width = 'full',
                    set = function(_, val) global.showMenu = val end,
                    get = function(_) return global.showMenu end,
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
                    set = function(_, val) global.showMsg = val end,
                    get = function(_) return global.showMsg end,
                },
                scanTime = {
                    name = 'Time to wait between scans',
                    desc = 'Must be more than 2 seconds.',
                    type = 'input',
                    validate = function(_, val)
                        val = val and tonumber(val) or nil
                        local valid = (val and type(val) == 'number' and val >= 2) and true or false
                        return valid
                    end,
                    order = 5,
                    width = .8,
                    set = function(_, val) global.scanTime = val end,
                    get = function(_) return global.scanTime end,
                },
                rememberPlayers = {
                    name = 'Remember invited players',
                    desc = 'Remember players that were invited so you do not duplicate invites.',
                    type = 'toggle',
                    order = 6,
                    width = 1.2,
                    set = function(_, val) global.remember = val end,
                    get = function(_) return global.remember end,
                },
                rememberTime = {
                    name = 'Time to wait',
                    desc = 'How long to wait before attempting a reinvite.',
                    type = 'select',
                    style = 'dropdown',
                    values = {
                        [7] = '7 days.',
                        [30] = '30 days.',
                        [90] = '90 days.',
                    },
                    order = 67,
                    width = .8,
                    set = function(_, val) global.rememberTime = val end,
                    get = function(_) return global.rememberTime end,
                },
            },
        },
        optFilters = {
            name = 'Filters',
            type = 'group',
            order = 3,
            args = {
                activeFilterDrop = {
                    name = 'Filter Description',
                    desc = 'Select the filter to edit.',
                    type = 'select',
                    style = 'dropdown',
                    width = 2,
                    order = 1,
                    values = function()
                        if not global.filter then return {} end
                        local tbl = {}
                        for k,r in pairs(global.filter) do tbl[k] = r.desc or '' end
                        return tbl
                    end,
                    set = function(_,val)
                        activeFilter = val
                        tblFilter = global.filter[val]
                    end,
                    get = function() return activeFilter end,
                },
                fNewButton = {
                    name = 'New',
                    desc = 'Create a new filter.',
                    type = 'execute',
                    width = .5,
                    order = 2,
                    disabled = function() return not activeFilter end,
                    func = function()
                        activeFilter = false
                        tblFilter = optTables:resetFilter()
                    end,
                },
                fHeader1 = {
                    name = 'Create Filter',
                    type = 'header',
                    order = 3,
                },
                fDesc = {
                    name = "You can create a filter using the dropdowns bellow or manually enter a filter using the who commands.\nFollow the format: Race: r-'race' Class: c-'class'.\n\nThe class levels on the main screen will override any manual ones.",
                    type = 'description',
                    fontSize = 'medium',
                    order = 4,
                },
                fHeader2 = {
                    name = '',
                    type = 'header',
                    order = 5,
                },
                fDescFilter = {
                    name = 'Filter Description',
                    desc = 'Short description of the filter.',
                    type = 'input',
                    multiline = false,
                    order = 6,
                    width = 'full',
                    set = function(_, val) tblFilter.desc = val end,
                    get = function(_) return tblFilter.desc or '' end,
                },
                fRaces = {
                    name = 'Race',
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    order = 7,
                    values = function()
                        local tbl = {}
                        for _,r in pairs(APR) do tbl[r] = r end
                        tbl[0] = ''
                        return tbl
                    end,
                    set = function(_,val)
                        tblFilter.race = (val == 0 and nil or val)
                        CreateFilter()
                    end,
                    get = function(_) return tblFilter.race end,
                },
                fClasses = {
                    name = 'Classes',
                    type = 'select',
                    style = 'dropdown',
                    width = 1,
                    order = 8,
                    values = function()
                        local tbl = {}
                        for _,r in pairs(APC) do tbl[r.className] = r.className end
                        tbl[0] = ''
                        return tbl
                    end,
                    set = function(_,val)
                        tblFilter.class = (val == 0 and nil or val)
                        CreateFilter()
                    end,
                    get = function(_) return tblFilter.class end,
                },
                fCustomFilter = {
                    name = 'Custom Filter/Preview',
                    type = 'input',
                    order = 9,
                    width = 'full',
                    set = function(_, val) tblFilter.filter = val end,
                    get = function(_) return tblFilter.filter or '' end,
                },
                fDelButton = {
                    name = 'Delete',
                    desc = 'Delete the selected filter.',
                    type = 'execute',
                    width = .5,
                    disabled = function() return not profile.activeFilter end,
                    func = function()
                        if profile.activeFilter and global.filter[profile.activeFilter] then
                            global.filter[profile.activeFilter] = nil
                            profile.activeFilter = nil
                            activeFilter = false
                            tblFilter = optTables:resetFilter()
                        end
                    end,
                },
                fSaveButton = {
                    name = 'Save',
                    desc = 'Save the current filter.',
                    type = 'execute',
                    width = .5,
                    disabled = function() return not tblFilter.filter end,
                    func = function()
                        activeFilter = false
                        global.filter = global.filter or {}
                        if not activeFilter then table.insert(global.filter, tblFilter)
                        else global.filter[activeFilter] = tblFilter end
                        ns.code.createErrorWindow('Filter Saved')
                        tblFilter = optTables:resetFilter()
                    end,
                },
            }
        },
        optBlackList = {
            name = 'Black List',
            type = 'group',
            order = 4,
            args = {}
        },
        optSync = {
            name = 'Syncronize',
            type = 'group',
            order = 5,
            args = {}
        },
    }
}
function ns:SetOptionsDB() profile, global = ns.db.profile, ns.db.global end

local function OverrideEscapeMenu()
    if GameMenuFrame:IsShown() then
        --HideUIPanel(GameMenuFrame)
        return true
    else  end
end
--hooksecurefunc("ToggleGameMenu", OverrideEscapeMenu)