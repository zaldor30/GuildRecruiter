local _, ns = ... -- Namespace (myaddon, namespace)
ns.tblEvents = {} -- Registered Events

local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

ns.core = {}
local core = ns.core

local function CHAT_MSG_SYSTEM(...) ns.observer:Notify('CHAT_MSG_SYSTEM', ...) end

-- Application Initialization Routine
function GRADDON:OnInitialize(...)
    if core.isEnabled then return end

    GRADDON:RegisterChatCommand('rl', function() ReloadUI() end)

    local function CheckIfInGuild(count)
        local clubID = C_Club.GetGuildClubId()

        count = count or 0
        if count > 30 then
            ns.code:cOut('Could not find an active guild, Guild Recruiter is not available.')
            return
        elseif not IsInGuild() or not clubID then
            C_Timer.After(1, function() CheckIfInGuild(count + 1) end)
        else
            core:startGuildRecruiter()

            ns.events:RegisterEvent('CHAT_MSG_SYSTEM', CHAT_MSG_SYSTEM)

            local function startAutoSync()
                if core.stopSync then return end
                ns.sync:StartSyncServer()
            end
            C_Timer.After(30, startAutoSync)
        end
    end

    CheckIfInGuild()
end

-- Core Routines
function core:Init()
    self.isEnabled = false
    self.isGuildLeader = false

    self.stopSync = false

    self.addonSettings = {
        profile = {
            settings = {
                dbVer = '2.0.0',
                debugMode = false,
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
            version = GRADDON.version,
            showUpdates = true,
            guildInfo = {
                hasGuildLeader = false,
                guildLeader = nil,
                antiSpam = true,
                reinviteAfter = 5,
                greeting = false,
                greetingMsg = '',
                messageList = {},
            },
        }
    }
end
-- Guild Recruiter Addon Initialization
function core:startGuildRecruiter()
    local db = DB:New('GR_SettingsDB', nil, PLAYER_PROFILE)
    local dbBL = DB:New('GR_BlackListDB', nil, PLAYER_PROFILE)
    local dbInv = DB:New('GR_InvitedPlayersDB', nil, PLAYER_PROFILE)
    local dbAnal = DB:New('GR_AnalyticsDB', nil, PLAYER_PROFILE)

    ns.settings = db.profile.settings
    ns.db, ns.dbGlobal = db.profile, db.global
    ns.dbBL, ns.dbInv = dbBL.global, dbInv.global
    ns.dbAP, ns.dbAG = dbAnal.profile, dbAnal.global

    GRADDON.debug = ns.dbGlobal.debugMode or false -- Leave this here

    -- Guild Related Routines and Checks
    local function registerGuild()
        local clubID = C_Club.GetGuildClubId() or nil
        if not clubID or not IsInGuild() then
            self.isEnabled = false
            ns.code:cOut('Could not find an active guild, Guild Recruiter is not available.')
            return true
        end

        local gLink = nil
        GRADDON.clubID = clubID
        local g = ns.dbGlobal[clubID] or nil
        if g and g.guildData then
            gLink = (g and g.guildData and g.guildData.guildLink ~= '')and g.guildLink or ((g and g.guildData.guildLink) and g.guildData.guildLink or nil)
        end

        if not g or not g.guildInfo then
            ns.dbGlobal[clubID] = {}
            ns.dbGlobal[clubID] = self.addonSettings.global -- Contains guildInfo
            g = ns.dbGlobal[clubID]
            g.guildData = {}
        end
        if not g then
            ns.code:consoleOut('There was an issue accessing the guild data.')
            return true
        end

        local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
        if club then
            local gName = club.name
            gLink = GetClubFinderLink(club.clubFinderGUID, club.name)
            g.guildData = {clubID = clubID, guildName = gName, guildLink = gLink }
        elseif C_Club.GetClubInfo(clubID) then g.guildData = {clubID = clubID, guildName = C_Club.GetClubInfo(clubID).name, guildLink = (g.guildData.guildLink or gLink or nil) } end

        return false
    end
    self.isEnabled = not registerGuild()
    if not CanGuildInvite() or not GRADDON.clubID or not IsInGuild() or not self.isEnabled then
        if not GRADDON.clubID or not IsInGuild() then self.isEnabled = false
        elseif not CanGuildInvite() then self.isEnabled = false end
    end

    -- Startup Console Messages
    if not GRADDON.clubID then self.isEnabled = false end
    if not self.isEnabled then -- Guild Recruiter is not enabled shows only in debug mode
        self.stopSync = true
        ns.code:dOut('You are not in a guild or do not have permission to invite players to the guild.', nil)
        return
    elseif GRADDON.clubID then -- Guild Recruiter is enabled
        ns.dbGlobal[GRADDON.clubID] = ns.dbGlobal[GRADDON.clubID] or {}
        ns.dbGlobal[GRADDON.clubID].guildInfo = ns.dbGlobal[GRADDON.clubID].guildInfo or {}

        ns.dbInv[GRADDON.clubID] = ns.dbInv[GRADDON.clubID] or {}

        ns.dbBL[GRADDON.clubID] = ns.dbBL[GRADDON.clubID] or {}

        ns.dbAP.analytics = ns.dbAP.analytics or {}
        ns.dbAG[GRADDON.clubID] = ns.dbAG[GRADDON.clubID] or {}
        ns.dbAG[GRADDON.clubID].analytics = ns.dbAG[GRADDON.clubID].analytics or {}


        ns.dbAG.analytics = ns.dbAG.analytics or {}
        ns.dbAP, ns.dbAG = dbAnal.profile.analytics, dbAnal.global[GRADDON.clubID].analytics
        ns.dbGlobal, ns.dbBL, ns.dbInv = ns.dbGlobal[GRADDON.clubID], ns.dbBL[GRADDON.clubID], ns.dbInv[GRADDON.clubID]

        -- Initialize Variables and Functions

        self.isGuildLeader = ns.dbGlobal.guildInfo.hasGuildLeader or IsGuildLeader()
        ns.isGuildLeader = self.isGuildLeader
        if self.isGuildLeader then
            ns.dbGlobal.guildInfo.hasGuildLeader = true
            ns.dbGlobal.guildInfo.guildLeader = UnitName('player')
        elseif not self.isGuildLeader and UnitName('player') == ns.dbGlobal.guildInfo.guildLeader then
            ns.dbGlobal.guildInfo.hasGuildLeader = false
        end

        self.tblWhispers = ns.ds:WhisperMessages()

        if not ns.settings.firstRunComplete then
            ns.settings.firstRunComplete = true
            -- Need to force for first run
            ns.code:fOut(GR_VERSION_INFO..' is enabled.', 'FFFFFFFF', true)
            ns.code:fOut('You can use "/gr help or /recruiter help" to get a list of commands.', 'FFFFFFFF', true)
        else ns.code:cOut(GR_VERSION_INFO..' is enabled.', 'FFFFFFFF', true) end
    end

    if GRADDON.debug then
        ns.code:dOut('Guild Recruiter is in debug mode.', 'FFFF0000', true)
        ns.code:dOut('If this is not a beta contact the author in Discord.', 'FFFFFFFF', true)
        ns.code:dOut('Click on the top left icon for a link.', 'FFFFFFFF', true)
    end

    AC:RegisterOptionsTable('GR_Options', ns.addonSettings)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    -- Setup Slash Commands
    GRADDON:RegisterChatCommand('gr', function(input) core:SlashCommand(input) end)
    GRADDON:RegisterChatCommand('recruiter', function(input) core:SlashCommand(input) end)

    -- Initialize Modules
    ns.screen:AddonLoaded()
    ns.invite:InitializeInvite()
    ns.ds.tblClassesByName = ns.ds:classesByName()
    ns.ds.tblBadZonesByName = ns.ds:invalidZonesByName()

    core:CreateMiniMapIcon()

    -- Maintenance Routine
    local function startMaintenance()
        local removeCount = 0
        local cutOffTime = C_DateAndTime.GetServerTimeLocal() - ((db.rememberTime or 7) * SECONDS_IN_A_DAY)

        for k,r in pairs((ns.dbInv and ns.dbInv) or {}) do
            local invitedOn = (type(r) == 'table' and r.invitedOn) and (type(r.invitedOn) == 'string' and tonumber(r.invitedOn) or r.invitedOn) or nil
            if invitedOn and invitedOn <= cutOffTime then
                ns.dbInv[k] = nil
                removeCount = removeCount + 1
            elseif not invitedOn then ns.dbInv[k] = nil end
        end

        if removeCount > 0 then
            ns.code:cOut(removeCount..' were removed from the invitied players list.', 'FFFFFFFF', true) end

        removeCount = 0
        cutOffTime = C_DateAndTime.GetServerTimeLocal()
        for k,r in pairs(ns.dbBL and ns.dbBL or {}) do
            if r.expirationDate and cutOffTime >= r.expirationDate then
                removeCount = removeCount + 1
                ns.dbBL[k] = nil
            end
        end

        if removeCount > 0 then
            ns.code:cOut(removeCount..' were removed from the black list after the 30 day wait period.', 'FFFFFFFF', true) end
    end
    startMaintenance()

    -- Show What's New
    ns.dbGlobal.showUpdates = ns.dbGlobal.showUpdates == nil and true or ns.dbGlobal.showUpdates
    if ns.dbGlobal.showUpdates and (GRADDON.debug or not ns.dbGlobal.version:match(ns.ds.GR_VERSION)) then
        ns.whatsnew:ShowWhatsNew()
    end
end
function core:SlashCommand(msg)
    msg = msg:trim()
    if not msg or msg == '' then ns.screen:StartGuildRecruiter()
    elseif strlower(msg) == 'help' then
        ns.code:fOut(GR_VERSION_INFO..' - Help')
        ns.code:fOut('You can use /gr or /recruiter to access the commands bellow.')
        ns.code:fOut('config - Takes you to Guild Recruiter settings screen.')
        ns.code:fOut('blacklist <player name> - This will add player to the black list (do not use the <>)')
        ns.code:fOut('You can type /rl to reload your UI (same as /reload).')
    elseif strlower(msg) == 'config' then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
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
            if button == 'LeftButton' then ns.screen.home:EnterHomeScreen()
            elseif button == 'RightButton' then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end
        end,
        OnTooltipShow = function(GameTooltip)
            local title = code:cText('FFFFFF00','Guild Recruiter')
            local body = code:cText('FFFFFFFF', 'LMB - Start Recruit Search\n')
            body = body..code:cText('FFFFFFFF', 'RMB - Open Configuration')

            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
        OnLeave = function()
            GameTooltip:Hide() -- Hide the tooltip when the mouse leaves the icon
        end,
    })

    icon:Register('GR_Icon', iconData, ns.db.settings.minimap)
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
    if core.shutdown then return
    elseif not ns.db or not ns.db.settings or not ns.db.settings.showContext then return end

    local dropdown = self.dropdown
    local function FinishFrame()
        if dropdown.which == 'PLAYER' or dropdown.which == 'FRIEND' then -- UnitPopup
            local dropdownFullName = dropdown.name and dropdown.name:gsub('-'..GetRealmName(), '') or nil
            if not dropdownFullName then return end

            f.name = dropdownFullName
            if not f or not f.name or not ns.code:verifyRealm(f.name) then return end
            local name = f.name:gsub('-'..GetRealmName(), '')
            local fullName = f.name

            local fEntry = CreateFrame('Button', nil, f)
            fEntry:SetSize(150, 40)
            fEntry:SetPoint('TOPLEFT', f, 'TOPLEFT', 0 , 10)
            fEntry.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
            fEntry:SetScript('OnMouseDown', function()
                if f.name then ns.blackList:AddToBlackList(f.name) end
                CloseDropDownMenus()
            end)

            local fIcon = CreateFrame('Button', nil, fEntry, 'BackdropTemplate')
            fIcon:SetSize(20, 20)
            fIcon:SetPoint('LEFT', fEntry, 'LEFT',0 , -10)

            fIcon:SetNormalTexture(ICON_PATH..'GR_NewRecord')
            fIcon:SetHighlightTexture(ICON_PATH..'GR_NewRecord')

            local blTextString = fEntry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            blTextString:SetPoint("LEFT", fIcon, "RIGHT", 5, 0)
            blTextString:SetText('Add '..(ns.code:cPlayer(name, nil, 'FF00FF00') or 'no name')..'\nto the black list.')
            blTextString:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            blTextString:SetJustifyH('CENTER')
            blTextString:SetTextColor(1,1,1,1)

            fEntry:SetScript('OnEnter', function() blTextString:SetTextColor(1,1,0,1) end)
            fEntry:SetScript('OnLeave', function() blTextString:SetTextColor(1,1,1,1) end)

            local lineTexture = fEntry:CreateTexture(nil, "ARTWORK")
            lineTexture:SetColorTexture(.5, .5, .5)
            lineTexture:SetHeight(1)
            lineTexture:SetPoint("BOTTOMLEFT", fEntry, "BOTTOMLEFT", 5, -5)
            lineTexture:SetPoint("BOTTOMRIGHT", fEntry, "BOTTOMRIGHT", 5, -5)

            local fInvite = CreateFrame('Button', nil, f)
            fInvite:SetSize(150, 40)
            fInvite:SetPoint('TOPLEFT', fEntry, 'BOTTOMLEFT', 0 , 10)
            fInvite.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
            fInvite:SetScript('OnMouseDown', function()
                if fullName then ns.invite:InvitePlayer(fullName, select(2, UnitClass(fullName)), true, nil, 'SKIP_CLASS_CHECK') end
                CloseDropDownMenus()
            end)

            fIcon = CreateFrame('Button', nil, fInvite, 'BackdropTemplate')
            fIcon:SetSize(20, 20)
            fIcon:SetPoint('LEFT', fInvite, 'LEFT',0 , -10)

            fIcon:SetNormalTexture(ICON_PATH..'GR_NewRecord')
            fIcon:SetHighlightTexture(ICON_PATH..'GR_NewRecord')

            local invTextString = fInvite:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            invTextString:SetPoint("LEFT", fIcon, "RIGHT", 5, 0)
            invTextString:SetText('Invite '..(ns.code:cPlayer(name, nil, 'FF00FF00') or 'no name')..'\nto the guild.')
            invTextString:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            invTextString:SetJustifyH('CENTER')
            invTextString:SetTextColor(1,1,1,1)

            fInvite:SetScript('OnEnter', function() invTextString:SetTextColor(1,1,0,1) end)
            fInvite:SetScript('OnLeave', function() invTextString:SetTextColor(1,1,1,1) end)
        else return end

        if self:GetLeft() >= self:GetWidth() then f:SetPoint('RIGHT', self, 'LEFT',0,0)
        else f:SetPoint('LEFT', self, 'RIGHT',0,0) end
    end

    if f then f = nil end
    f = CreateFrame("Frame", "GR_DropDownFrame", UIParent, "BackdropTemplate")
    f:SetFrameStrata('TOOLTIP')
    f:SetSize(165, 70)
    f:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    f:SetBackdropColor(0,0,0,1)
    f:SetBackdropBorderColor(1,1,1,1)
    f:IsClampedToScreen(true)
    f.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent

    FinishFrame()
end
local function DropDownOnHide() if f then f:Hide() end end
DropDownList1:HookScript('OnShow', DropDownOnShow)
DropDownList1:HookScript('OnHide', DropDownOnHide)