-- Guild Recruiter Core
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local addonOptions = nil

-- Options Table Defaults
OPTIONS_DEFAULT = {
    profile = {
        minimap = { hide = false, },
    },
    global = {
        showIcon = true,
        showMsg = true,
        showMenu = true,
        scanPlayers = false,
        scanTime = '10',
        remember = true,
        rememberTime = 'WEEK',
        msgInviteDesc = '',
        msgInvite = '',
    }
}

function CreateMiniMapIcon()
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = 'Interface\\AddOns\\GuildRecruiter\\imgs\\gr_minimap',
        OnClick = function(_, button)
            if button == 'LeftButton' then GR_NAMESPACES:createMainSearch()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local cText = GR_CODE.cText
            local msg = cText('FFFFFF00','Guild Recruiter')
            msg = msg..cText('FFFFFFFF', '\nLMB - Start Recruit Search\n')
            msg = msg..cText('FFFFFFFF', 'RMB - Open Configuration')

            GameTooltip:SetText(msg)
        end,
    })

    GR_LIBSTUB:Register('GR_Icon', iconData, GRDB.profile.minimap)
end

function GR_ADDON:OnInitialize()
    -- Set DB
    GRDB = LibStub('AceDB-3.0'):New('GuildRecruiterDB', OPTIONS_DEFAULT, true)

    -- Register Options table
    AC:RegisterOptionsTable('GuildRecruiter_Options', GR_MAIN_OPTIONS)
    addonOptions = ACD:AddToBlizOptions('GuildRecruiter_Options', 'Guild Recruiter')

    -- Slash Command Declaration
    self:RegisterChatCommand('rl', function() ReloadUI() end)
    self:RegisterChatCommand('gr', 'SlashCommand')
    self:RegisterChatCommand('guildrecruiter', 'SlashCommand')

    CreateMiniMapIcon()
end

-- Slash Command Routines
function GR_ADDON:SlashCommand(msg)
    msg = msg and msg:trim() or msg
    if msg == 'config' then InterfaceOptionsFrame_OpenToCategory(addonOptions) end
end