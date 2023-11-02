local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

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
            ns.code:cOut(L['NO_GUILD'])
            return
        elseif not IsInGuild() or not clubID then
            C_Timer.After(1, function() CheckIfInGuild(count + 1) end)
        else
            core:startGuildRecruiter()

            ns.events:RegisterEvent('CHAT_MSG_SYSTEM', CHAT_MSG_SYSTEM)

            C_Timer.After(10, function()
                if core.stopSync or ns.dbGlobal.debugAutoSync then return end

                ns.sync.isAutoSync = true
                ns.sync:StartSyncServer()
            end)
        end
    end

    CheckIfInGuild()
end

-- Core Routines
function core:Init()
    self.isEnabled = false
    self.isGuildLeader = false
    self.hasGuildLeader = false

    self.stopSync = false

    self.addonSettings = {
        profile = {
            settings = {
                debugMode = false,
                dbVersion = nil,
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
                firstRunComplete = false,

                -- Anti Spam Settings
                antiSpam = true,
                reinviteAfter = 7,
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
    --self.addonSettings.profile.settings.dbVersion = ns.ds.dbVersion

    local db = DB:New('GR_SettingsDB', nil, PLAYER_PROFILE)
    local dbBL = DB:New('GR_BlackListDB', nil, PLAYER_PROFILE)
    local dbInv = DB:New('GR_InvitedPlayersDB', nil, PLAYER_PROFILE)
    local dbAnal = DB:New('GR_AnalyticsDB', nil, PLAYER_PROFILE)

    ns.db, ns.dbGlobal = db.profile, db.global
    ns.dbBL, ns.dbInv = dbBL.global, dbInv.global
    ns.dbAP, ns.dbAG = dbAnal.profile, dbAnal.global

    ns.db.settings = ns.db.settings or self.addonSettings.profile.settings
    ns.dbGlobal.settings = ns.dbGlobal.settings or self.addonSettings.global.settings

    ns.settings = ns.db.settings
    ns.db.filter = ns.db.filter or self.addonSettings.profile.filter
    ns.db.messages = ns.db.messages or self.addonSettings.profile.messages

    GRADDON.debug = ns.dbGlobal.debugMode or false -- Leave this here

    -- Guild Related Routines and Checks
    local function registerGuild()
        local clubID = C_Club.GetGuildClubId() or nil
        if not clubID or not IsInGuild() then
            self.isEnabled = false
            ns.code:cOut(L['NO_GUILD'])
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
            ns.code:consoleOut(L['BAD_GUILD_DATA'])
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

        ns.dbBL[GRADDON.clubID] = ns.dbBL[GRADDON.clubID] or {}
        ns.dbInv[GRADDON.clubID] = ns.dbInv[GRADDON.clubID] or {}

        ns.dbAP.analytics = ns.dbAP.analytics or {}
        ns.dbAG[GRADDON.clubID] = ns.dbAG[GRADDON.clubID] or {}
        ns.dbAG[GRADDON.clubID].analytics = ns.dbAG[GRADDON.clubID].analytics or {}

        ns.dbAP, ns.dbAG = dbAnal.profile.analytics, dbAnal.global[GRADDON.clubID].analytics
        ns.dbGlobal, ns.dbBL, ns.dbInv = ns.dbGlobal[GRADDON.clubID], ns.dbBL[GRADDON.clubID], ns.dbInv[GRADDON.clubID]

        self.isGuildLeader = ns.dbGlobal.guildInfo.hasGuildLeader or IsGuildLeader()
        ns.isGuildLeader = self.isGuildLeader
        if self.isGuildLeader then
            ns.hasGuildLeader = true
            ns.dbGlobal.guildInfo.hasGuildLeader = true
            ns.dbGlobal.guildInfo.guildLeader = UnitName('player')
        elseif not self.isGuildLeader and UnitName('player') == ns.dbGlobal.guildInfo.guildLeader then
            ns.hasGuildLeader = false
            ns.dbGlobal.guildInfo.hasGuildLeader = false
        end



        AC:RegisterOptionsTable('GR_Options', ns.addonSettings)
        ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

        -- Initialize Variables and Functions

        self.tblWhispers = ns.ds:WhisperMessages()

        ns.code:fOut(GR_VERSION_INFO..' '..L['ENABLED']..'.', 'FFFFFFFF', true)
        if not ns.settings.firstRunComplete then
            -- Need to force for first run
            ns.settings.firstRunComplete = true
            ns.code:fOut(L['FIRST_RUN'], 'FFFFFFFF', true)
        end
    end

    if GRADDON.debug then
        ns.code:dOut('Guild Recruiter is in debug mode.', 'FFFF0000', true)
        ns.code:dOut('If this is not a beta contact the author in Discord.', 'FFFFFFFF', true)
        ns.code:dOut('Click on the top left icon for a link.', 'FFFFFFFF', true)
    end

    -- Setup Slash Commands
    GRADDON:RegisterChatCommand('gr', function(input) core:SlashCommand(input) end)
    GRADDON:RegisterChatCommand(L['recruiter'], function(input) core:SlashCommand(input) end)

    -- Initialize Modules
    ns.invite:InitializeInvite()
    ns.ds.tblClassesByName = ns.ds:classesByName()
    ns.ds.tblBadZonesByName = ns.ds:invalidZonesByName()

    core:CreateMiniMapIcon()

    -- Compress Database
    local newDB, noDataInv, noDataBL = false, true, true
    if not ns.settings.dbVersion or ns.settings.dbVersion ~= ns.ds.dbVersion then
        newDB = true
        ns.settings.dbVer = nil
        ns.settings.dbVersion = ns.ds.dbVersion
        ns.code:fOut('Updating database to version '..ns.ds.dbVersion)

        ns.dbInv = ns.dbInv or {}
        local stringOut = ns.dbInv and ns.code:compressData(ns.dbInv) or ''
        for k in pairs(ns.dbInv and ns.dbInv or {}) do noDataInv = false ns.dbInv[k] = nil end
        ns.dbInv['InvitedPlayers'] = stringOut or ''

        ns.dbBL = ns.dbBL or {}
        stringOut = ns.dbBL and ns.code:compressData(ns.dbBL) or ''
        for k in pairs(ns.dbBL and ns.dbBL or {}) do noDataBL = false ns.dbBL[k] = nil end
        ns.dbBL['BlackList'] = stringOut or ''
    end

    -- Get Data for Invited Players and Black List
    local state, tbl = ns.code:decompressData(ns.dbInv.InvitedPlayers)
    if state and tbl then ns.tblInvited = tbl
    elseif newDB and noDataInv then ns.tblInvited = {}
    else ns.code:fOut('Error decompressing Invited Players.', 'FFFF0000') end

    state, tbl = ns.code:decompressData(ns.dbBL.BlackList)
    if state and tbl then ns.tblBlackList = tbl
    elseif newDB and noDataBL then ns.tblBlackList = {}
    else ns.code:fOut('Error decompressing Black List.', 'FFFF0000') end

    ns.blackList:FixBlackList() -- Fix Black List Table

    -- Start Main Screen
    ns.screen:AddonLoaded()

    -- Maintenance Routine
    local function startMaintenance()
        local removeCount = 0
        local cutOffTime = C_DateAndTime.GetServerTimeLocal() - ((db.rememberTime or 7) * SECONDS_IN_A_DAY)

        for k,r in pairs((ns.tblInvited and ns.tblInvited) or {}) do
            local invitedOn = (type(r) == 'table' and r.invitedOn) and (type(r.invitedOn) == 'string' and tonumber(r.invitedOn) or r.invitedOn) or nil
            if invitedOn and invitedOn <= cutOffTime then
                ns.tblInvited[k] = nil
                removeCount = removeCount + 1
            elseif not invitedOn then ns.tblInvited[k] = nil end
        end
        ns.dbInv.InvitedPlayers = ns.code:compressData(ns.tblInvited)

        if removeCount > 0 then
            ns.code:fOut(string.format(L['ANTI_SPAM_REMOVAL'], removeCount), 'FFFFFFFF', true) end

        removeCount = 0
        cutOffTime = C_DateAndTime.GetServerTimeLocal()
        for k,r in pairs(ns.tblBlackList and ns.tblBlackList or {}) do
            if r.expirationDate and cutOffTime >= r.expirationDate then
                removeCount = removeCount + 1
                ns.tblBlackList[k] = nil
            end
        end
        ns.dbBL.BlackList= ns.code:compressData(ns.tblBlackList)

        if removeCount > 0 then
            ns.code:cOut(removeCount..L['BL_REMOVAL'], 'FFFFFFFF', true) end
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
    if not msg or msg == '' then ns.screen.home:EnterHomeScreen()
    elseif strlower(msg) == L['help'] then
        ns.code:fOut(string.format(L['SLASH_HELP1'], GR_VERSION_INFO))
        ns.code:fOut(L['SLASH_HELP2'])
        ns.code:fOut(L['SLASH_HELP3'])
        ns.code:fOut(L['SLASH_HELP4'])
        ns.code:fOut(L['SLASH_HELP5'])
    elseif strlower(msg) == L['config'] then InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
    elseif strlower(msg):match(L['blacklist']) then
        msg = strlower(msg):gsub(L['blacklist'], ''):trim()
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
            local title = code:cText('FFFFFF00', L['TITLE'])
            local body = code:cText('FFFFFFFF', L['LEFT_MOUSE_BUTTON']..'\n')
            body = body..code:cText('FFFFFFFF', L['RIGHT_MOUSE_BUTTON'])

            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
        OnLeave = function()
            GameTooltip:Hide() -- Hide the tooltip when the mouse leaves the icon
        end,
    })

    icon:Register('GR_Icon', iconData, ns.db.settings.minimap)
end
core:Init()

local function HandlesGlobalMouseEvent(self, button, event)
	if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton')then
        if not ns.db.settings.showContext then return false end
		return true
	end
	return false
end

local tblFrame, rows, rowHeight = {}, 3, 40
local function DropDownOnShow(self)
    if not core.isEnabled then return
    elseif not ns.db.settings.showContext then return
    elseif not ns.db or not ns.db.settings or not ns.db.settings.showContext then return end

    local dropdown = self.dropdown
    if not dropdown or not dropdown.which then return end

    if dropdown.which == 'PLAYER' or dropdown.which == 'FRIEND' then -- UnitPopup
        local dropdownFullName = dropdown.name and dropdown.name:gsub('-'..GetRealmName(), '') or nil
        if not dropdownFullName then return end

        local f = tblFrame.frame or CreateFrame("Frame", "GR_DropDownFrame", UIParent, "BackdropTemplate")
        f:SetFrameStrata('TOOLTIP')
        f:SetSize(165, rowHeight * rows - 15)
        f:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
        f:SetBackdropColor(0,0,0,1)
        f:SetBackdropBorderColor(1,1,1,1)
        f:IsClampedToScreen(true)
        f:EnableMouse(true)
        f:SetShown(true)
        tblFrame.frame = f

        f:ClearAllPoints()
        if self:GetLeft() >= self:GetWidth() then f:SetPoint('RIGHT', self, 'LEFT',0,0)
        else f:SetPoint('LEFT', self, 'RIGHT',0,0) end

        -- Gather Information
        f.name = dropdownFullName
        if not f or not f.name or not ns.code:verifyRealm(f.name) then
            if f and not ns.code:verifyRealm(f.name) then
                ns.code:fOut('Player is not connected to your realm.', 'FFFF0000')
            end
            return
        end

        local name = f.name:gsub('-'..GetRealmName(), '')
        local fullName = dropdown.chatTarget
        local class = select(2, UnitClass(fullName)) or nil

        -- Invite with Messages
        local fInviteMsg = tblFrame.inviteMsg or CreateFrame('Button', nil, tblFrame.frame)
        fInviteMsg:SetSize(tblFrame.frame:GetWidth(), rowHeight)
        fInviteMsg:SetPoint('TOP', f, 'TOP', 0, 0)
        fInviteMsg.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
        fInviteMsg:SetShown(true)
        tblFrame.inviteMsg = fInviteMsg

        local fInviteMsgHighlight = tblFrame.InviteMSGhighlight or fInviteMsg:CreateTexture(nil, 'OVERLAY')
        fInviteMsgHighlight:SetSize(tblFrame.frame:GetWidth() -8, rowHeight -5)
        fInviteMsgHighlight:SetPoint('CENTER', fInviteMsg, 'CENTER', 0, -1)
        fInviteMsgHighlight:SetAtlas(BLUE_LONG_HIGHLIGHT)
        fInviteMsgHighlight:SetShown(false)
        tblFrame.InviteMSGhighlight = fInviteMsgHighlight

        local fInviteMsgText = tblFrame.inviteMSGText or fInviteMsg:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        fInviteMsgText:SetFont(DEFAULT_FONT, DEFAULT_FONT_SIZE, 'OUTLINE')
        fInviteMsgText:SetPoint('CENTER', fInviteMsg, 'CENTER', 0, 0)
        fInviteMsgText:SetText('Invite '..(ns.code:cPlayer(name, nil, 'FF00FF00'))..'\nWith Greeting/Welcome')
        tblFrame.inviteMSGText = fInviteMsgText

        fInviteMsg:SetScript('OnEnter', function() tblFrame.InviteMSGhighlight:SetShown(true) end)
        fInviteMsg:SetScript('OnLeave', function() tblFrame.InviteMSGhighlight:SetShown(false) end)
        fInviteMsg:SetScript('OnClick', function()
            if fullName then ns.invite:InvitePlayer(fullName, class, 'MANUAL', false, (class and false or true)) end
            CloseDropDownMenus()
        end)

        -- Add to Black List
        local fBlackList = tblFrame.blackList or CreateFrame('Button', nil, tblFrame.frame)
        fBlackList:SetSize(tblFrame.frame:GetWidth(), rowHeight)
        fBlackList:SetPoint('TOP', fInviteMsg, 'BOTTOM', 0, 8)
        fBlackList.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
        tblFrame.blackList = fBlackList

        local fBlackListHighlight = tblFrame.blackListHighlight or fBlackList:CreateTexture(nil, 'OVERLAY')
        fBlackListHighlight:SetSize(fBlackList:GetWidth() -8, fBlackList:GetHeight() -5)
        fBlackListHighlight:SetPoint('CENTER', fBlackList, 'CENTER', 0, -1)
        fBlackListHighlight:SetAtlas(BLUE_LONG_HIGHLIGHT)
        fBlackListHighlight:SetShown(false)
        tblFrame.blackListHighlight = fBlackListHighlight

        local fBlackListText = tblFrame.fBlackListText or fBlackList:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        fBlackListText:SetFont(DEFAULT_FONT, DEFAULT_FONT_SIZE, 'OUTLINE')
        fBlackListText:SetPoint('CENTER', fBlackList, 'CENTER', 0, 0)
        fBlackListText:SetText('Add '..(ns.code:cPlayer(name, nil, 'FF00FF00'))..'\nTo Black List')
        tblFrame.fBlackListText = fBlackListText

        fBlackList:SetScript('OnEnter', function() tblFrame.blackListHighlight:SetShown(true) end)
        fBlackList:SetScript('OnLeave', function() tblFrame.blackListHighlight:SetShown(false) end)
        fBlackList:SetScript('OnClick', function()
            if fullName then ns.blackList:AddToBlackList(fullName) end
            CloseDropDownMenus()
        end)

        -- Invite without Greeting
        local fInvite = tblFrame.invite or CreateFrame('Button', nil, tblFrame.frame)
        fInvite:SetSize(tblFrame.frame:GetWidth(), rowHeight)
        fInvite:SetPoint('TOP', fBlackList, 'BOTTOM', 0, 8)
        fInvite.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
        tblFrame.invite = fInvite

        local fInviteHighlight = tblFrame.inviteHighlight or fInvite:CreateTexture(nil, 'OVERLAY')
        fInviteHighlight:SetSize(fInvite:GetWidth() -8, fInvite:GetHeight() -5)
        fInviteHighlight:SetPoint('CENTER', fInvite, 'CENTER', 0, -1)
        fInviteHighlight:SetAtlas(BLUE_LONG_HIGHLIGHT)
        fInviteHighlight:SetShown(false)
        tblFrame.inviteHighlight = fInviteHighlight

        local fInviteText = tblFrame.fInviteText or fInvite:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        fInviteText:SetFont(DEFAULT_FONT, DEFAULT_FONT_SIZE, 'OUTLINE')
        fInviteText:SetPoint('CENTER', fInvite, 'CENTER', 0, 0)
        fInviteText:SetText('Invite '..(ns.code:cPlayer(name, nil, 'FF00FF00'))..'\nNo Greeting/Welcome')
        tblFrame.fInviteText = fInviteText

        fInvite:SetScript('OnEnter', function() tblFrame.inviteHighlight:SetShown(true) end)
        fInvite:SetScript('OnLeave', function() tblFrame.inviteHighlight:SetShown(false) end)
        fInvite:SetScript('OnClick', function()
            if fullName then ns.invite:InvitePlayer(fullName, class, 'MANUAL', false, (class and false or true), true) end
            CloseDropDownMenus()
        end)

    else return end
end
local function DropDownOnHide() if tblFrame.frame then tblFrame.frame:SetShown(false) end end
DropDownList1:HookScript('OnShow', DropDownOnShow)
DropDownList1:HookScript('OnHide', DropDownOnHide)