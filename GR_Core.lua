local optDefaults = {
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

local AC, ACD, icon = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0'), LibStub('LibDBIcon-1.0')
local addonOptions = nil

function CreateMiniMapIcon()
    local cText = function(color, text) return '|c'..color..text..'|r' end
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = 'Interface\\AddOns\\GuildRecruiter\\imgs\\gr_minimap',
        OnClick = function(_, button)
            if button == 'LeftButton' then GR_NAMESPACES:createMainSearch()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local msg = cText('FFFFFF00','Guild Recruiter')
            msg = msg..cText('FFFFFFFF', '\nLMB - Start Recruit Search\n')
            msg = msg..cText('FFFFFFFF', 'RMB - Open Configuration')

            GameTooltip:SetText(msg)
        end,
    })

    icon:Register('GR_Icon', iconData, GRADDON.db.profile.minimap)
end
function GRADDON:OnInitialize()
    -- Set DB
    GRADDON.db = LibStub('AceDB-3.0'):New('GuildRecruiterDB', optDefaults, true)

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
function GRADDON:SlashCommand(msg)
    msg = msg and msg:trim() or msg
    if msg == 'config' then InterfaceOptionsFrame_OpenToCategory(addonOptions) end
end