local _, ns = ... -- Namespace (myaddon, namespace)

ns.core = {}
local core = {}
local AceGUI = LibStub("AceGUI-3.0")
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

function GRADDON:OnInitialize()
    GRADDON:RegisterChatCommand('rl', function() ReloadUI() end)
    C_Timer.After(5, function() core:Initialize() end)
end

function core:Init()
    self.isEnabled = false

    self.addonSettings = {
        profile = {
            -- App Settings
            minimap = { hide = false, },
            showContext = true,
            showAppMsgs = false,
            -- Invite Settings
            compactMode = false,
            scanWaitTime = 3,
            showWho = false,
            showWhispers = false,
            sendGreeting = false,
            greetingMsg = '',
            -- GM Settings
            antiSpam = true,
            reinviteAfter = 5,
        }
    }

    self.f = AceGUI:Create('InlineGroup')
end
function core:Initialize()
    GRADDON.db = DB:New('GR_SettingsDB', self.addonSettings, PLAYER_PROFILE)
    GRADDON.dbBl = DB:New('GR_BlackListDB', nil, PLAYER_PROFILE)
    GRADDON.dbInv = DB:New('GR_InvitedPlayersDB', nil, PLAYER_PROFILE)
    GRADDON.dbAnal = DB:New('GR_AnalyticsDB', nil, PLAYER_PROFILE)

    ns.db = GRADDON.db.profile
    if not core:RegisterGuild() then return end

    ns.dbBL = GRADDON.dbBl.global
    ns.dbInv = GRADDON.dbInv.global
    ns.dbAnal = GRADDON.dbAnal

    if not ns.db.filter then ns.db.filter = {} end
    if not ns.db.messages then ns.db.messages = {} end
    if not ns.db.settings then ns.db.settings = self.addonSettings.profile end
    ns.dbInv[GRADDON.clubID] = ns.dbInv[GRADDON.clubID] or {}
    ns.dbInv = ns.dbInv[GRADDON.clubID]

    AC:RegisterOptionsTable('GR_Options', ns.addonSettings)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')
    GRADDON:RegisterChatCommand('gr', function(input) core:SlashCommand(input) end)
    GRADDON:RegisterChatCommand('recruiter', function(input) core:SlashCommand(input) end)

    core:CreateMiniMapIcon()
    core:StartMaintenance()

    ns.Invite:InitializeInvite()

    function GRADDON:OnCommReceived(prefix, message, distribution, sender)
        ns.Sync:OnCommReceived(prefix, message, distribution, sender) end
    GRADDON:RegisterComm(GRADDON.prefix, 'OnCommReceived')
end
function core:SlashCommand(input)
    local msg = input:trim()

    if not msg or msg == '' then -- open Main screen
    elseif strlower(msg) == 'help' then
        ns.code:consoleOut(GR_VERSION_INFO..' - Help')
        ns.code:consoleOut('You can use /gr or /recruiter to access the commands bellow.')
        ns.code:consoleOut('config - Takes you to Guild Recruiter settings screen.')
        ns.code:consoleOut('blacklist <player name> - This will add player to the black list (do not use the <>)')
        ns.code:consoleOut('You can type /rl to reload your UI (same as /reload).')
    elseif strlower(msg) == 'config' then
    elseif strlower(msg) == 'blacklist' then
    end
end
function core:CreateMiniMapIcon()
    local code = ns.code
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = 'Interface\\AddOns\\GuildRecruiter\\imgs\\gr_minimap',
        OnClick = function(_, button)
            if button == 'LeftButton' then ns.MainScreen:ShowMainScreen()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local title = code:cText('FFFFFF00','Guild Recruiter')
            local body = code:cText('FFFFFFFF', 'LMB - Start Recruit Search\n')
            body = body..code:cText('FFFFFFFF', 'RMB - Open Configuration')

            ns.code:createTooltip(title, body)
        end,
    })

    icon:Register('GR_Icon', iconData, ns.db.settings.minimap)
end
function core:RegisterGuild()
    local clubID = C_Club.GetGuildClubId() or nil
    if not clubID or not C_Club.GetClubInfo(clubID) then
        self.isEnabled = false
        ns.code:consoleOut('Could not find an active guild, Guild Recruiter is not available.')
        return false
    else self.isEnabled = true end
    GRADDON.clubID = clubID

    local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
    if club then
        local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
        ns.db.guildInfo = {clubID = clubID, guildName = gName, guildLink = gLink }
    else ns.db.guildInfo = {clubID = clubID, guildName = C_Club.GetClubInfo(clubID).name, guildLink = nil } end

    ns.code:consoleOut(GR_VERSION_INFO..' is active.')
    return true
end
function core:StartMaintenance()
    local db, dbInv, dbBL = ns.db.settings, ns.dbInv, ns.dbBL

    ns.code:consoleOut('Starting database maintenance...')

    local removeCount = 0
    local cutOffTime = C_DateAndTime.GetServerTimeLocal() - ((db.rememberTime or 7) * SECONDS_IN_A_DAY)

    for k,r in pairs((dbInv and dbInv.invitedPlayers) or {}) do
        local invitedOn = (type(r) == 'table' and r.invitedOn) and (type(r.invitedOn) == 'string' and tonumber(r.invitedOn) or r.invitedOn) or nil
        if invitedOn and invitedOn <= cutOffTime then
            dbInv.invitedPlayers[k] = nil
            removeCount = removeCount + 1
        elseif not invitedOn then dbInv.invitedPlayers[k] = nil end
    end

    if removeCount > 0 then
        ns.code:consoleOut(removeCount..' were removed from the invitied players list.') end

    removeCount = 0
    cutOffTime = C_DateAndTime.GetServerTimeLocal()
    for k,r in pairs(dbBL.blackList or {}) do
        if r.expirationDate and cutOffTime >= r.expirationDate then
            removeCount = removeCount + 1
            dbBL.blackList[k] = nil
        end
    end

    if removeCount > 0 then
        ns.code:consoleOut(removeCount..' were removed from the black list after the 30 day wait period.') end

    ns.code:consoleOut('Database maintenance complete.')
end
core:Init()

--[[ Context Menu Routine ]]
local f = nil
local function HandlesGlobalMouseEvent(self, button, event)
	if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton')then
        if not ns.db.settings.showMenu then return false end
		return true
	end
	return false
end
local function DropDownOnShow(self)
    if not core.isEnabled or not ns.db or not ns.db.settings.showContext or not self.dropdown then return end

    local dropdown = self.dropdown
    local function FinishFrame()
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

        if self:GetLeft() >= self:GetWidth() then f.frame:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT',0,0)
        else f.frame:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT',0,0) end
    end

    if f then
        FinishFrame()
        f.frame:Show()
        return
    else f = AceGUI:Create('InlineGroup') end
    f:SetWidth(135)
    f:SetLayout('flow')


    local lblInvite = AceGUI:Create('InteractiveLabel')
    lblInvite:SetText('Guild Invite')
    lblInvite:SetFont('Fonts\\FRIZQT__.ttf', 12, 'OUTLINE')
    lblInvite:SetWidth(135)
    lblInvite:SetHighlight(255, 216.75, 0, 255)
    lblInvite.frame.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
    lblInvite:SetCallback('OnClick', function()
        if f.name then
            ns.code:consoleOut('Sending invite to '..f.name)
            ns.Invite:invitePlayer(f.name, nil, 'SEND_INVITE', 'FORCE', select(2, UnitClass(f.name)))
        end
        CloseDropDownMenus()
    end)
    f:AddChild(lblInvite)

    local lblBlackList = AceGUI:Create('InteractiveLabel')
    lblBlackList:SetText('Black List')
    lblBlackList:SetWidth(135)
    lblBlackList:SetFont('Fonts\\FRIZQT__.ttf', 12, 'OUTLINE')
    lblBlackList:SetHighlight(255,255,255)
    lblBlackList.frame.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
    lblBlackList:SetCallback('OnClick', function()
        if f.name then
            ns.code:consoleOut('Adding '..f.name..' to blacklist list.')
            ns.BlackList:add(f.name)
        end
        CloseDropDownMenus()
    end)
    f:AddChild(lblBlackList)

    FinishFrame()
end
local function DropDownOnHide() if f then f.frame:Hide() end end
DropDownList1:HookScript('OnShow', DropDownOnShow)
DropDownList1:HookScript('OnHide', DropDownOnHide)