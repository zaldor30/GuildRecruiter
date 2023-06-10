-- Guild Recruiter Core and Initialize
local _, ns = ... -- Namespace (myaddon, namespace)
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

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
    local ds = ns.datasets

    -- Set Databases
    GRADDON.db = DB:New('GR_SettingsDB', ds.tblOptDefaults, PLAYER_PROFILE)
    GRADDON.dbBl = DB:New('GR_BlackListDB', nil, PLAYER_PROFILE)
    GRADDON.dbInv = DB:New('GR_InvitedPlayersDB', nil, PLAYER_PROFILE)
    GRADDON.dbAnal = DB:New('GR_AnalyticsDB', nil, PLAYER_PROFILE)
    ns.db = GRADDON.db
    ns.dbBL = GRADDON.dbBl
    ns.dbInv = GRADDON.dbInv
    ns.dbAnal = GRADDON.dbAnal

    ns:SetOptionsDB() -- Udpates the db in options
    AC:RegisterOptionsTable('GR_Options', ns.options)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    -- Slash Command Declaration
    self:RegisterChatCommand('rl', function() ReloadUI() end)
    self:RegisterChatCommand('gr', 'SlashCommand')
    self:RegisterChatCommand('guildrecruiter', 'SlashCommand')

    -- Other Housekeeping Routines
    -- Start Maintenance with chat msg
    CreateMiniMapIcon()
    ds:saveOptions() -- Saves default to data file
end