-- Guild Recruiter Core
local _, ns = ... -- Namespace (myaddon, namespace)
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
    local cText = ns.code.cText
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = 'Interface\\AddOns\\GuildRecruiter\\imgs\\gr_minimap',
        OnClick = function(_, button)
            if button == 'LeftButton' then ns:ShowMainScreen()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local msg = cText('FFFFFF00','Guild Recruiter')
            msg = msg..cText('FFFFFFFF', '\nLMB - Start Recruit Search\n')
            msg = msg..cText('FFFFFFFF', 'RMB - Open Configuration')

            GameTooltip:SetText(msg)
        end,
    })

    icon:Register('GR_Icon', iconData, ns.db.profile.minimap)
end

function GRADDON:OnInitialize()
    -- Set Databases
    GRADDON.db = DB:New('GR_SettingsDB', optDefaults, PLAYER_PROFILE)
    GRADDON.bl = DB:New('GR_BlackListDB', nil, true)
    GRADDON.inv = DB:New('GR_InvitedPlayersDB', nil, true)
    ns.db.profile, ns.db.global = GRADDON.db.profile, GRADDON.db.global

    ns:SetOptionsDB()
    AC:RegisterOptionsTable('GR_Options', GR_MAIN_OPTIONS)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    -- Slash Command Declaration
    self:RegisterChatCommand('rl', function() ReloadUI() end)
    self:RegisterChatCommand('gr', 'SlashCommand')
    self:RegisterChatCommand('guildrecruiter', 'SlashCommand')

    CreateMiniMapIcon()

    ns:SetProfileDefaults()
end

-- Slash Command Routines
function GRADDON:SlashCommand(msg)
    msg = msg and msg:trim() or msg
    if not msg or msg == '' then ns:ShowMainScreen()
    elseif msg == 'config' then InterfaceOptionsFrame_OpenToCategory(ADDON_OPTIONS) end
end