-- Guild Recruiter Core
local AC, ACD, DB = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0'), LibStub('AceDB-3.0')
local icon = LibStub('LibDBIcon-1.0')

local optDefaults = {
    profile = {
        minimap = { hide = false, },
    },
    global = {
        showIcon = true,
        showMsg = false,
        showMenu = true,
        scanTime = '2',
        remember = true,
        rememberTime = '7',
        msgInviteDesc = '',
        msgInvite = '',
    }
}

function CreateMiniMapIcon()
    local cText = NS.code.cText
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = 'Interface\\AddOns\\GuildRecruiter\\imgs\\gr_minimap',
        OnClick = function(_, button)
            if button == 'LeftButton' then NS.MainScreen()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(NS.addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local msg = cText('FFFFFF00','Guild Recruiter')
            msg = msg..cText('FFFFFFFF', '\nLMB - Start Recruit Search\n')
            msg = msg..cText('FFFFFFFF', 'RMB - Open Configuration')

            GameTooltip:SetText(msg)
        end,
    })

    icon:Register('GR_Icon', iconData, NS.db.profile.minimap)
end

function GRADDON:OnInitialize()
    -- Set Databases
    GRADDON.db = DB:New('GR_SettingsDB', optDefaults, PLAYER_PROFILE)
    GRADDON.bl = DB:New('GR_BlackListDB', nil, true)
    GRADDON.inv = DB:New('GR_InvitedPlayersDB', nil, true)
    NS.db.profile, NS.db.global = GRADDON.db.profile, GRADDON.db.global

    NS:SetOptionsDB()
    AC:RegisterOptionsTable('GR_Options', GR_MAIN_OPTIONS)
    NS.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    -- Slash Command Declaration
    self:RegisterChatCommand('rl', function() ReloadUI() end)
    self:RegisterChatCommand('gr', 'SlashCommand')
    self:RegisterChatCommand('guildrecruiter', 'SlashCommand')

    CreateMiniMapIcon()

    NS:SetProfileDefaults()
end

-- Slash Command Routines
function GRADDON:SlashCommand(msg)
    msg = msg and msg:trim() or msg
    if msg == 'config' then InterfaceOptionsFrame_OpenToCategory(ADDON_OPTIONS) end
end