local _, ns = ... -- Namespace (myaddon, namespace)
ns.tblEvents = {} -- Registered Events

local WAIT_BEFORE_INIT = 5

local AceGUI = LibStub("AceGUI-3.0")
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

ns.core = {}
local core = ns.core
function core:Init()
    self.started = false
    self.shutdown = false
    self.timerStarted = false

    self.slashCommand = 'recruiter'

    self.addonSettings = {
        profile = {
            settings = {
                -- Starting Levels
                minLevel = MAX_CHARACTER_LEVEL - 4,
                maxLevel = MAX_CHARACTER_LEVEL,
                -- App Settings
                minimap = { hide = false, },
                showContext = true,
                showAppMsgs = false,
                showTooltips = true,
                -- Invite Settings
                compactMode = false,
                scanWaitTime = 6,
                showWho = false,
                showSummary = true,
                showWhispers = false,
                sendGreeting = false,
                greetingMsg = '',
                sendWelcome = true,
                welcomeMessage = DEFAULT_GUILD_WELCOME,
                inviteFormat = 2,
            },
            filter = {
                filterList = {},
                activeFilter = 1,
            },
            messages = {
                activeMessage = nil,
                messageList = {},
            },
        },
        global = {
            dbVer = '2.0.0',
            guildInfo = {
                antiSpam = true,
                reinviteAfter = 5,
                greeting = false,
                greetingMsg = '',
                messageList = {},
            },
        }
    }

    self.f = AceGUI:Create('InlineGroup')
end
function core:OnPlayerLoggedIn()
    GRADDON:UnregisterEvent('PLAYER_LOGIN')

    GRADDON.db = DB:New('GR_SettingsDB', nil, PLAYER_PROFILE)
    GRADDON.dbBl = DB:New('GR_BlackListDB', nil, PLAYER_PROFILE)
    GRADDON.dbInv = DB:New('GR_InvitedPlayersDB', nil, PLAYER_PROFILE)
    GRADDON.dbAnal = DB:New('GR_AnalyticsDB', nil, PLAYER_PROFILE)

    ns.db, ns.dbGlobal = GRADDON.db.profile, GRADDON.db.global
    ns.dbBL = GRADDON.dbBl.global
    ns.dbInv = GRADDON.dbInv.global
    ns.dbAnal = GRADDON.dbAnal

    local isSettings = ns.db.settings and true or false
    local dbMatch = ((isSettings and ns.db.settings.dbVer) and ns.db.settings.dbVer == self.addonSettings.profile.settings.dbVer) or false

    if not isSettings or not dbMatch then
        if ns.db.settings then ns.db.settings = nil end
        if ns.db.filter then ns.db.filter = nil end
        if ns.db.messages then ns.db.messages = nil end
        isSettings = false
    end

    if not core:RegisterGuild() then return end
    if not GRADDON.clubID and not ns.dbGlobal.guildData then return
    elseif ns.dbGlobal.guildData then GRADDON.clubID = ns.dbGlobal.guildData.clubID end

    if not GRADDON.clubID or not IsInGuild() then
        ns.code:consoleOut('You are not currently in a guild.')
        ns.code:consoleOut('Guild Recruiter will be disabled.')
        return
    end
    if not GRADDON.db.global[GRADDON.clubID] then return end

    if not isSettings or not dbMatch then core:dbChanges() end
    if self.shutdown then return end

    ns.dbGlobal = GRADDON.db.global[GRADDON.clubID]
    ns.dbBL =  GRADDON.dbBl.global[GRADDON.clubID]
    ns.dbInv = GRADDON.dbInv.global[GRADDON.clubID]
    ns.dbAnal = GRADDON.dbAnal.profile.analytics
    ns.dbGAnal = GRADDON.dbAnal.global[GRADDON.clubID].analytics

    AC:RegisterOptionsTable('GR_Options', ns.addonSettings)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    if not SlashCmdList['GR'] then
        self.slashCommand = 'gr'
        GRADDON:RegisterChatCommand('gr', function(...) core:SlashCommand(...) end)
    else self.slashCommand = 'recruiter' end
    GRADDON:RegisterChatCommand('recruiter', function(input) core:SlashCommand(input) end)

    core:CreateMiniMapIcon()
    core:StartMaintenance()
    for k, r in pairs(ns.dbBL or {}) do
        if r.selected then r.selected = false end
    end -- Reset selection state for options

    if not ns.db.settings.ver or ns.db.settings.ver ~= '2.0.0' then
        ns.db.settings.ver = '2.0.0'
        ns.infoScreen()
    end

    ns.code:consoleOut(GR_VERSION_INFO..' is active.', nil, true)
    ns.code:consoleOut('Database version: '..ns.db.settings.dbVer, nil, true)
    ns.code:consoleOut('You can use "/'..(self.slashCommand == 'gr' and 'gr or /recruiter' or '/'..self.slashCommand)..' help" to get a list of commands.', nil, true)
end

function GRADDON:OnInitialize(...) -- Continue Initialize After Player Enters world
    GRADDON:RegisterChatCommand('rl', function() ReloadUI() end)

    GRADDON:RegisterEvent('PLAYER_LOGIN', function()
        local function checkForMap()
            C_Timer.After(1, function()
                if C_Map.GetBestMapForUnit("player") then
                    C_Timer.After(WAIT_BEFORE_INIT, function() core:OnPlayerLoggedIn() end)
                else checkForMap() end
            end)
        end
        checkForMap()
    end)
end
function core:dbChanges()
    local clubID = C_Club.GetGuildClubId() or GRADDON.clubID or nil
    if ns.db.settings and not ns.db.reloaded then
        ns.infoScreen()
        C_Timer.After(.1, function()
            ns.code:consoleOut(ns.code:cText('FFFF0000', 'Guild Recruiter data has been reset!!'))
            ns.code:consoleOut('Your black list, invite log and analytics should be saved.')
            ns.code:consoleOut(ns.code:cText('FF00FF00', 'Please type /rl to reload your UI!'))
            ns.code:consoleOut('Please reconfigure your settings.')
        end)
        ns.core.shutdown = true
        return
    end

    ns.db.reloaded = nil
    ns.db.settings = self.addonSettings.profile.settings
    ns.db.filter = self.addonSettings.profile.filter
    ns.db.messages = self.addonSettings.profile.messages

    clubID = GRADDON.clubID
    local tblInvited = ns.dbInv[clubID] and (ns.dbInv[clubID].invited or ns.dbInv[clubID]) or {}
    ns.dbInv[clubID] = tblInvited

    local tblBlackList = ns.dbBL[clubID] and (ns.dbBL[clubID].blackList or ns.dbBL[clubID]) or {}
    ns.dbBL[clubID] = tblBlackList

    local tblAnalytics = ns.dbAnal.profile.analytics and (ns.dbAnal.profile.analytics.analytics or ns.dbAnal.profile.analytics or ns.dbAnal.profile) or {}
    ns.dbAnal.profile.analytics = tblAnalytics or {}
    ns.dbAnal.profile.analytics.startDate = (ns.dbAnal.profile.analytics and ns.dbAnal.profile.analytics.startDate) and ns.dbAnal.profile.analytics.startDate or C_DateAndTime.GetServerTimeLocal()

    ns.dbAnal.global[clubID] = ns.dbAnal.global[clubID] or {}
    local tblGlobalAnalytics = (ns.dbAnal.global[clubID] and ns.dbAnal.global[clubID].analytics) and (ns.dbAnal.global[clubID].analytics.analytics or ns.dbAnal.global[clubID].analytics or ns.dbAnal.global[clubID]) or {}
    ns.dbAnal.global[clubID].analytics = tblGlobalAnalytics or {}
    ns.dbAnal.global[clubID].analytics.startDate = (ns.dbAnal.global[clubID] and ns.dbAnal.global[clubID].analytics.startDate) and ns.dbAnal.global[clubID].analytics.startDate or C_DateAndTime.GetServerTimeLocal()
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
        ns:add(name)
    end
end
function core:CreateMiniMapIcon()
    local code = ns.code
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = GRADDON.icon,
        OnClick = function(_, button)
            if button == 'LeftButton' then ns.screen:StartGuildRecruiter()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local title = code:cText('FFFFFF00','Guild Recruiter')
            local body = code:cText('FFFFFFFF', 'LMB - Start Recruit Search\n')
            body = body..code:cText('FFFFFFFF', 'RMB - Open Configuration')

            ns.widgets:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
        OnLeave = function()
            GameTooltip:Hide() -- Hide the tooltip when the mouse leaves the icon
        end,
    })

    icon:Register('GR_Icon', iconData, ns.db.settings.minimap)
end
function core:RegisterGuild()
    local clubID = C_Club.GetGuildClubId() or nil
    if not clubID or not IsInGuild() then
        self.isEnabled = false
        ns.code:consoleOut('Could not find an active guild, Guild Recruiter is not available.')
        return false
    end

    GRADDON.clubID = clubID
    local g = ns.dbGlobal[clubID] or nil
    if not g or not ns.dbGlobal[clubID] or not ns.dbGlobal[clubID].guildInfo or (not ns.dbGlobal[clubID].dbVer or ns.dbGlobal[clubID].dbVer ~= self.addonSettings.global.dbVer) then
        ns.dbGlobal[clubID] = {}
        ns.dbGlobal[clubID] = self.addonSettings.global -- Contains guildInfo
        g = ns.dbGlobal[clubID]
        g.guildData = {}
    end
    if not g then
        ns.code:consoleOut('There was an issue accessing the guild data.')
        return
    end

    local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
    if club then
        local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
        g.guildData = {clubID = clubID, guildName = gName, guildLink = gLink }
    elseif C_Club.GetClubInfo(clubID) then g.guildData = {clubID = clubID, guildName = C_Club.GetClubInfo(clubID).name, guildLink = (g.guildData.guildLink or nil) } end

    return clubID or false
end
function core:StartMaintenance()
    local db, dbInv, dbBL = ns.db.settings, ns.dbInv, ns.dbBL

    local removeCount = 0
    local cutOffTime = C_DateAndTime.GetServerTimeLocal() - ((db.rememberTime or 7) * SECONDS_IN_A_DAY)

    for k,r in pairs((dbInv and dbInv) or {}) do
        local invitedOn = (type(r) == 'table' and r.invitedOn) and (type(r.invitedOn) == 'string' and tonumber(r.invitedOn) or r.invitedOn) or nil
        if invitedOn and invitedOn <= cutOffTime then
            dbInv[k] = nil
            removeCount = removeCount + 1
        elseif not invitedOn then dbInv[k] = nil end
    end

    if removeCount > 0 then
        ns.code:consoleOut(removeCount..' were removed from the invitied players list.') end

    removeCount = 0
    cutOffTime = C_DateAndTime.GetServerTimeLocal()
    for k,r in pairs(dbBL or {}) do
        if r.expirationDate and cutOffTime >= r.expirationDate then
            removeCount = removeCount + 1
            dbBL[k] = nil
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
            ns:add(f.name)
        end
        CloseDropDownMenus()
    end)
    f:AddChild(lblBlackList)

    FinishFrame()
end
local function DropDownOnHide() if f then f.frame:Hide() end end
DropDownList1:HookScript('OnShow', DropDownOnShow)
DropDownList1:HookScript('OnHide', DropDownOnHide)