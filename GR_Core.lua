local _, ns = ... -- Namespace (myaddon, namespace)
--[[ Register and Unregister events
    Add event to table
    Add event to Register event ]]
ns.core, ns.events = {}, {}
local core, events = ns.core, ns.events
function events:Init()
    self.tblEvents = events:CreateTableEvents()
end
function events:CreateTableEvents()
    return {
        ['WHO_LIST_UPDATE'] = {active = false, installed = true},
        ['CHAT_MSG_SYSTEM'] = {active = false, installed = true},
        ['GUILD_ROSTER_UPDATE'] = {active = false, installed = true},
        ['PLAYER_LOGIN'] = {active = false, installed = true},
    }
end
function events:RegisterEvent(event, action)
    if self.tblEvents[event].active then return-- ns.code:consoleOut(event..' event is already registered in fnEventHandlers.') return
    elseif not self.tblEvents[event] and not self.tblEvents.installed then ns.code:consoleOut(event..' event is not registered in fnEventHandlers.') end

    local function eventCallBack(...)
        self.tblEvents[...].active = true
        if action then
            if 'InitializeAddon' then ns.core:InitializeAddon(...) end
        elseif event == 'WHO_LIST_UPDATE' then ns.ScreenInvite:eventWhoQueryResults()
        elseif event == 'CHAT_MSG_SYSTEM' then ns.Invite:ChatMsgHandler(...)
        elseif event == 'GUILD_ROSTER_UPDATE' then ns.Invite:GuildRosterHandler(...)
        elseif event == 'PLAYER_LOGIN' then ns.core:InitializeAddon(...) end
    end

    GRADDON:RegisterEvent(event, eventCallBack)
end
function events:UnregisterEvent(event)
    if strupper(event) == 'ALL' then
        for k, r in pairs(self.tblEvents) do
            if r.active then GRADDON:UnregisterEvent(k) end
        end
    elseif event and self.tblEvents[event] then
        self.tblEvents[event].active = false
        GRADDON:UnregisterEvent(event)
    end
end
events:Init()

local AceGUI, AceTimer = LibStub("AceGUI-3.0"), LibStub("AceTimer-3.0")
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

function AceTimer:TimerCallBack()
    if ns.core.started then return end

    ns.core.started = true
    ns.events:UnregisterEvent('PLAYER_LOGIN')
    ns.code:consoleOut('Guild not detected, Guild Recruiter is not available.')
end
function GRADDON:OnInitialize()
    local function startInitialize()
        C_Timer.After(3, function() core:InitializeAddon() end)
        AceTimer:ScheduleTimer('TimerCallBack', 60)
    end
    if not ns.core.timerStarted then
        ns.core.timerStarted = true
        GRADDON:RegisterChatCommand('rl', function() ReloadUI() end)
        ns.events:RegisterEvent('PLAYER_LOGIN', 'startInitialize')
    end
end

function core:Init()
    self.started = false
    self.timerStarted = false

    self.slashCommand = 'recruiter'

    self.addonSettings = {
        profile = {
            -- Starting Levels
            minLevel = MAX_CHARACTER_LEVEL - 4,
            maxLevel = MAX_CHARACTER_LEVEL,
            -- App Settings
            minimap = { hide = false, },
            showContext = true,
            showAppMsgs = false,
            -- Invite Settings
            compactMode = false,
            scanWaitTime = 6,
            showWho = false,
            showSummary = true,
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
function core:InitializeAddon(...) -- Continue Initialize After Player Enters world
    if ... ~= 'PLAYER_LOGIN' then return end
    ns.events:UnregisterEvent('PLAYER_LOGIN')
    if ns.core.started then return else ns.core.started = true end

    GRADDON.db = DB:New('GR_SettingsDB', self.addonSettings, PLAYER_PROFILE)
    GRADDON.dbBl = DB:New('GR_BlackListDB', nil, PLAYER_PROFILE)
    GRADDON.dbInv = DB:New('GR_InvitedPlayersDB', nil, PLAYER_PROFILE)
    GRADDON.dbAnal = DB:New('GR_AnalyticsDB', nil, PLAYER_PROFILE)

    ns.db = GRADDON.db.profile
    ns.dbBL = GRADDON.dbBl.global
    ns.dbInv = GRADDON.dbInv.global
    ns.dbAnal = GRADDON.dbAnal

    if not ns.db.filter then ns.db.filter = {} end
    if not ns.db.filter.filterList then ns.db.filter.filterList = {} end
    if not ns.db.messages then ns.db.messages = {} end
    if not ns.db.settings then ns.db.settings = self.addonSettings.profile end
    if not ns.db.guildInfo then ns.db.guildInfo = {} end

    if not core:RegisterGuild() then return end
    if not GRADDON.clubID and not ns.db.guildInfo then return
    elseif ns.db.guildInfo then GRADDON.clubID = ns.db.guildInfo.clubID end

    ns.dbInv[GRADDON.clubID] = ns.dbInv[GRADDON.clubID] or {}
    ns.dbInv = ns.dbInv[GRADDON.clubID]

    AC:RegisterOptionsTable('GR_Options', ns.addonSettings)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    if not GRADDON.clubID or not IsInGuild() then
        ns.code:consoleOut('You are not currently in a guild.')
        ns.code:consoleOut('Guild Recruiter will be disabled.')
        return
    end

    if not SlashCmdList['GR'] then
        self.slashCommand = 'gr'
        GRADDON:RegisterChatCommand('gr', function(...) core:SlashCommand(...) end)
    else self.slashCommand = 'recruiter' end
    GRADDON:RegisterChatCommand('recruiter', function(input) core:SlashCommand(input) end)

    core:CreateMiniMapIcon()
    core:StartMaintenance()

    ns.Invite:InitializeInvite()
    ns.code:consoleOut(GR_VERSION_INFO..' is active.', nil, true)
    ns.code:consoleOut('You can use "/'..(self.slashCommand == 'gr' and 'gr or /recruiter' or '/'..self.slashCommand)..' help" to get a list of commands.', nil, true)

    function GRADDON:OnCommReceived(prefix, message, distribution, sender)
        ns.Sync:OnCommReceived(prefix, message, distribution, sender) end
    GRADDON:RegisterComm(GRADDON.prefix, 'OnCommReceived')
end
function core:SlashCommand(msg)
    msg = msg:trim()
    if not msg or msg == '' then ns.MainScreen:ShowMainScreen()
    elseif strlower(msg) == 'help' then
        ns.code:consoleOut(GR_VERSION_INFO..' - Help')
        ns.code:consoleOut('You can use /gr or /recruiter to access the commands bellow.')
        ns.code:consoleOut('config - Takes you to Guild Recruiter settings screen.')
        ns.code:consoleOut('blacklist <player name> - This will add player to the black list (do not use the <>)')
        ns.code:consoleOut('You can type /rl to reload your UI (same as /reload).')
    elseif strlower(msg) == 'config' then
    elseif strlower(msg):match('blacklist') then
        msg = strlower(msg):gsub('blacklist', ''):trim()
        local name = strupper(strsub(msg,1,1))..strlower(strsub(msg,2))
        ns.BlackList:add(name)
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
    local clubID = C_Club.GetGuildClubId() or (ns.db.guildInfo.clubID or nil)
    if not clubID or not IsInGuild() then
        self.isEnabled = false
        ns.code:consoleOut('Could not find an active guild, Guild Recruiter is not available.')
        return false
    end

    GRADDON.clubID = clubID
    local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
    if club then
        local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
        ns.db.guildInfo = {clubID = clubID, guildName = gName, guildLink = gLink }
    elseif C_Club.GetClubInfo(clubID) then ns.db.guildInfo = {clubID = clubID, guildName = C_Club.GetClubInfo(clubID).name, guildLink = nil } end

    return clubID or false
end
function core:StartMaintenance()
    local db, dbInv, dbBL = ns.db.settings, ns.dbInv, ns.dbBL

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
end
core:Init()

local f = nil
local function HandlesGlobalMouseEvent(self, button, event)
	if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton')then
        if not ns.db.settings.showContext then return false end
		return true
	end
	return false
end
local function DropDownOnShow(self)
    if not ns.db or not ns.db.settings.showContext then return end

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

    if f then f = nil end
    f = AceGUI:Create('InlineGroup')
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