-- Guild Recruiter Configuration Options
GR_MAIN_OPTIONS = {
    name = 'Guild Recruiter',
    handler = GR_ADDON,
    type = 'group',
    args = {
        optGeneral = {
            name = 'General',
            handler = GR_ADDON,
            type = 'group',
            args = {
                showIcon = {
                    name = 'Show Minimap Icon',
                    desc = 'Show/Hide the icon from the minimap.',
                    type = 'toggle',
                    order = 0,
                    width = 'full',
                    set = function(info, val) GR_DB.profile.showIcon = val end,
                    get = function(info) return GR_DB.profile.showIcon end,
                },
                showMsg = {
                    name = 'Do not show messages sent to potential recruits.',
                    desc = 'Only works if you have in-line checked under Social/New Whispers.',
                    type = 'toggle',
                    order = 1,
                    width = 'full',
                    set = function(info, val) GR_DB.profile.showMsg = val end,
                    get = function(info) return GR_DB.profile.showMsg end,
                },
                showMenu = {
                    name = 'Show menu when clicking on names in chat.',
                    desc = 'Shows a menu for invite, black list, etc in a dropdown menu.',
                    type = 'toggle',
                    order = 2,
                    width = 'full',
                    set = function(info, val) GR_DB.profile.showMenu = val end,
                    get = function(info) return GR_DB.profile.showMenu end,
                },
                rememberPlayers = {
                    name = 'Remember invited players',
                    desc = 'Remember players that were invited so you do not duplicate invites.',
                    type = 'toggle',
                    order = 3,
                    width = 1.2,
                    set = function(info, val) GR_DB.profile.remember = val end,
                    get = function(info) return GR_DB.profile.remember end,
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
                    order = 4,
                    width = .8,
                    set = function(info, val) GR_DB.profile.rememberTime = val end,
                    get = function(info) return GR_DB.profile.rememberTime end,
                },
            },
        },
        optTable2 = {
            name = 'Guild',
            handler = GR_ADDON,
            type = 'group',
            args = {
                showIcon = {
                    name = 'Show Minimap Icon',
                    desc = 'Show/Hide the icon from the minimap.',
                    type = 'toggle',
                    order = 0,
                    width = 'full',
                    set = function(info, val) GR_DB.profile.showIcon = val end,
                    get = function(info) return GR_DB.profile.showIcon end,
                },
            }
        },
    }
}