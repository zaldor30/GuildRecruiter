-- Guild Recruiter Core and Initialize
local _, ns = ... -- Namespace (myaddon, namespace)
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

ns.MaintenanceActive = false

local dOptions = {
    profile = {
        minimap = { hide = false, },
        showWho = false,
        remember = true,
        rememberTime = '7',
    },
    global = {
        showIcon = true,
        showMsg = false,
        showMenu = true,
        showSystem = false,
        showWhisper = true,
        scanTime = '2',
        msgInviteDesc = '',
        msgInvite = '',
    }
}

function CreateMiniMapIcon()
    local code = ns.code
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = 'Interface\\AddOns\\GuildRecruiter\\imgs\\gr_minimap',
        OnClick = function(_, button)
            if button == 'LeftButton' then ns.MainScreen:ShowMainScreen()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local msg = code:cText('FFFFFF00','Guild Recruiter')
            msg = msg..code:cText('FFFFFFFF', '\nLMB - Start Recruit Search\n')
            msg = msg..code:cText('FFFFFFFF', 'RMB - Open Configuration')

            GameTooltip:SetText(msg)
        end,
    })

    icon:Register('GR_Icon', iconData, ns.db.profile.minimap)
end
function GRADDON:OnInitialize()
    -- Set Databases
    GRADDON.db = DB:New('GR_SettingsDB', dOptions, PLAYER_PROFILE)
    GRADDON.dbBl = DB:New('GR_BlackListDB', nil, PLAYER_PROFILE)
    GRADDON.dbInv = DB:New('GR_InvitedPlayersDB', nil, PLAYER_PROFILE)
    GRADDON.dbAnal = DB:New('GR_AnalyticsDB', nil, PLAYER_PROFILE)

    ns.db = GRADDON.db
    ns.dbBL = GRADDON.dbBl
    ns.dbInv = GRADDON.dbInv
    ns.dbAnal = GRADDON.dbAnal

    ns:SetOptionsDB()
    if not C_Club.GetGuildClubId() and not ns.db.profile.guildInfo.guildName then return end
    ns.datasets:saveOptions() -- Udpates the db in options
    AC:RegisterOptionsTable('GR_Options', ns.options)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    -- Slash Command Declaration
    self:RegisterChatCommand('rl', function() ReloadUI() end)
    self:RegisterChatCommand('gr', 'SlashCommand')
    self:RegisterChatCommand('guildrecruiter', 'SlashCommand')

    ns.Sync:addonStartUp()
    CreateMiniMapIcon()
    -- Other Housekeeping Routines
    -- Start Maintenance with chat msg
end

-- Slash Command Routines
function GRADDON:SlashCommand(msg)
    msg = msg and msg:trim() or msg
    if not msg or msg == '' then ns.MainScreen:ShowMainScreen()
    elseif msg == 'config' then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end
end

-- Context Menu Creation for Guild Invite/Black List
local function HandlesGlobalMouseEvent(self, button, event)
	if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton')then
        if not ns.db.global.showMenu then return false end
		return true
	end
	return false
end
local AceGUI = LibStub("AceGUI-3.0")
local f = AceGUI:Create('InlineGroup')
f:SetWidth(135)
f:SetLayout('flow')

local invite = AceGUI:Create('InteractiveLabel')
invite:SetText('Guild Invite')
invite:SetWidth(135)
invite:SetFont('Fonts\\FRIZQT__.ttf', 12, 'OUTLINE')
invite:SetHighlight(255,255,255,125)
invite.frame.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
invite:SetCallback('OnClick', function()
	if f.name then
        ns.code:consoleOut('Sending invite to '..f.name)
        ns.Invite:invitePlayer(f.name, nil, 'SEND_INVITE', 'FORCE', select(2, UnitClass(f.name))) end
	CloseDropDownMenus()
end)
invite:SetPoint('TOPLEFT', f.frame, 'TOPLEFT', 0, 0)
f:AddChild(invite)

local blacklist = AceGUI:Create('InteractiveLabel')
blacklist:SetText('Black List')
blacklist:SetWidth(135)
blacklist:SetFont('Fonts\\FRIZQT__.ttf', 12, 'OUTLINE')
blacklist:SetHighlight(255,255,255,125)
blacklist.frame.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
blacklist:SetCallback('OnClick', function()
	if f.name then ns.BlackList:add(f.name) end
	CloseDropDownMenus()
end)
blacklist:SetPoint('TOPLEFT', invite.frame, 'BOTTOMLEFT', 0, 0)
f:AddChild(blacklist)

local function DropDownOnShow(self)
    if not ns.db.global.showMenu then return end
	local dropdown = self.dropdown
	if not dropdown then return end

	f.frame:SetParent(self)
	f.frame:SetFrameStrata(self:GetFrameStrata())
	f.frame:SetFrameLevel(self:GetFrameLevel() + 2)
	f:ClearAllPoints()

	if dropdown.Button == LFGListFrameDropDownButton then
	elseif dropdown.which then -- UnitPopup
		local dropdownFullName = nil
		if dropdown.name then
			if dropdown.server and not dropdown.name:find('-') then
				dropdownFullName = dropdown.name .. '-' .. dropdown.server
			else dropdownFullName = dropdown.name end
		end
		f.name = dropdownFullName
	else return end

	if self:GetLeft() >= self:GetWidth() then f:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT',0,0)
	else f:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT',0,0) end
	f.frame:Show()
end
local function DropDownOnHide()
	f.frame:Hide()
end

DropDownList1:HookScript('OnShow', DropDownOnShow)
DropDownList1:HookScript('OnHide', DropDownOnHide)