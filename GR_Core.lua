local _, ns = ... -- Namespace (myaddon, namespace)
ns.core = {}

-- Application Initialization
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')
local core = ns.core

local SYNC_WAIT_TIME = 60 -- Seconds to wait before syncing

-- Application Startup Default Function
function GR:OnInitialize()
    if core.isEnabled then return end

    local function checkGuildInfo(count)
        local clubID = C_Club.GetGuildClubId()

        count = count or 0
        if count > 30 then ns.code:cOut(L['GUILD_NOT_FOUND']) return
        elseif not IsInGuild() or not clubID then C_Timer.After(1, function() checkGuildInfo(count + 1) end)
        else
            core:StartGuildRecruiter(clubID)
            if not core.isEnabled then return end
            core:PerformRecordMaintenance()

            ns.tblRacesByName = ns.code:sortTableByField(ns.ds.tblRaces, 'name')
            ns.tblClassesByName = ns.code:sortTableByField(ns.ds.tblClasses, 'name')
            ns.code.fPlayerName = ns.code:cPlayer('player')

            ns.invite:StartUp()
            core:SlashCommands()
            core:CreateMiniMapIcon()
            core:FinishStartup()

            ns.events:RegisterEvent('PLAYER_LOGOUT', function() ns.code:saveTables() end)

            SYNC_WAIT_TIME = ns.settings.debugMode and 1 or SYNC_WAIT_TIME
            if core.ignoreAutoSync or not core.isEnabled or ns.settings.debugAutoSync then return end -- CHECK IF SYNCING
            C_Timer.After(SYNC_WAIT_TIME, function() ns.sync:StartSync(true, UnitName('player'), true) end)
        end
    end

    GR:RegisterChatCommand('rl', function() ReloadUI() end)
    checkGuildInfo()
end

function core:Init()
    self.isEnabled = false
    self.fullyStarted = false
    self.ignoreAutoSync = false

    self.isGuildLeader = false

    self.addonSettings = {
        profile = {
            settings = {
                -- Starting Levels
                minLevel = MAX_CHARACTER_LEVEL - 4,
                maxLevel = MAX_CHARACTER_LEVEL,
                -- General Settings
                compactMode = false, -- Scanner Compact Mode
                minimap = { hide = false, }, -- Mini Map Icon
                showContextMenu = true, -- Show Context Menu
                debugMode = false, -- Debug Mode
                debugAutoSync = false, -- Debug Auto Sync (false = on)
                showAppMsgs = true, -- Show Application Messages
            },
            analytics = {}
        },
        global = {
            guildInfo = {},
            gmSettings = {
                -- GM Settings
                antiSpam = false,
                antiSpamDays = 7,
                sendWelcome = false,
                welcomeMessage = L['DEFAULT_GUILD_WELCOME'],
                sendGreeting = false,
                greetingMessage = '',
                messageList = {},
                isGuildLeader = false,
            },
            settings = {
                -- General Settings
                showToolTips = true, -- Show Tool Tips
                showConsoleMessages = false, -- Show Console Messages
                -- Invite Settings
                showWhispers = false, -- Show Whispers
                antiSpam = true,
                antiSpamDays = 7,
                sendWelcome = true,
                welcomeMessage = L['DEFAULT_GUILD_WELCOME'],
                sendGreeting = false,
                greetingMessage = '',
                scanWaitTime = 6,
                -- Messages
                messageList = {},
            },
            keybindings = {
                scan = 'CTRL-SHIFT-S',
                invite = 'CTRL-SHIFT-I',
            },
            filterList = {},
            analytics = {},
        }
    }
end
-- Database Routines
function core:StartGuildRecruiter(clubID)
    self.isEnabled = (CanGuildInvite() and clubID and IsInGuild()) and true or false
    if not self.isEnabled then
        ns.code:dOut(L['TITLE']..' '..GR.version..' '..L['DISABLED']..'.', 'FF3EB9D8', 'NO_PREFIX')
        ns.code:dOut('You are not in a guild or cannot invite players.', 'FF3EB9D8', 'NO_PREFIX')
        return
    end
    -- Start Databases
    local db = DB:New('GuildRecruiterDB', nil, PLAYER_PROFILE)

    db.global = db.global or { showWhatsNew = true }
    db.profile.settings = db.profile.settings or self.addonSettings.profile.settings
    db.profile.analytics = db.profile.analytics or self.addonSettings.profile.analytics

    db.global[clubID] = db.global[clubID] or self.addonSettings.global
    db.global[clubID].blackList = db.global[clubID].blackList or ''
    db.global[clubID].antiSpamList = db.global[clubID].antiSpamList or ''


    ns.db, ns.dbProfile, ns.dbGlobal = db, db.profile, db.global[clubID]
    ns.dbAP, ns.dbAG = ns.dbProfile.analytics, ns.dbGlobal.analytics
    ns.settings, ns.gSettings, ns.gmSettings = db.profile.settings, db.global[clubID].settings, db.global[clubID].gmSettings

    ns.dbAP = ns.dbAP or {}
    ns.dbAG = ns.dbAG or {}

    GR.debug = ns.settings.debugMode

    -- Setup Guild Info
    local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
    ns.sync.clubID = clubID

    ns.code:fOut(L['TITLE']..' ('..GR.version..') '..L['ENABLED']..'.', 'FF3EB9D8', 'NO_PREFIX')
    ns.settings.firstRunComplete = ns.settings.firstRunComplete or false
    if not ns.settings.firstRunComplete then
        ns.code:fOut(L['FIRST_RUN'], 'FF3EB9D8', 'NO_PREFIX')
        ns.settings.firstRunComplete = true
    end

    ns.dbGlobal.guildInfo.clubID = ns.dbGlobal.guildInfo.clubID or clubID
    ns.dbGlobal.guildInfo.guildName = GetGuildInfo('player')
    if not (ns.dbGlobal.guildInfo.guildLink or ns.dbGlobal.guildInfo.guildLink == '') then
        ns.dbGlobal.guildInfo.guildLink = club and GetClubFinderLink(club.clubFinderGUID, club.name) or nil
    end
    ns.dbGlobal.guildInfo.isGuildLeader = IsGuildLeader() and true or (ns.dbGlobal.guildInfo.isGuildLeader or false)

    if IsGuildLeader() and not ns.dbGlobal.guildInfo.guildLink then
        ns.code:fOut(L['GUILD_LINK_INSTRUCTIONS'], 'FFAF640C')
    end

    ns.dbGlobal.guildInfo.isGuildLeader = false
    if ns.dbGlobal.guildInfo.guildLeaderName then
        local tbl = db:GetProfiles()
        for _, r in pairs(tbl) do
            if r:match(ns.dbGlobal.guildInfo.guildLeaderName) then
                ns.dbGlobal.guildInfo.isGuildLeader = true
                break
            end
        end
    end

    if IsGuildLeader() then
        ns.dbGlobal.guildInfo.isGuildLeader = true
        ns.dbGlobal.guildInfo.gmMemberID = C_Club.GetMemberInfoForSelf(clubID).memberId
        ns.dbGlobal.guildInfo.guildLeaderName = UnitName('player')
    end

    ns.isGuildLeader = ns.dbGlobal.guildInfo.isGuildLeader -- Set Guild Leader Flag

    ns.tblConnectedRealms = ns.ds:GetConnectedRealms() -- Servers connected to player's realm
end
function core:PerformRecordMaintenance()
    local gmSettings, gSettings = ns.gmSettings, ns.gSettings
    local invitedRemoved, blackListRemoved = 0, 0
    local antiSpamDays = (gmSettings.antiSpam and gmSettings.antiSpamDays) and gmSettings.antiSpamDays or (gSettings.antiSpamDays or 7)
    local antiSpamExpire = C_DateAndTime.GetServerTimeLocal() - (antiSpamDays * SECONDS_IN_A_DAY)

    -- Setup Tables for Black List and Invited Players
    ns.tblBlackList, ns.tblInvited = {}, {}
    local blSuccess, tblBL = ns.code:decompressData(ns.dbGlobal.blackList)
    if blSuccess and tblBL then ns.tblBlackList = tblBL
    elseif ns.dbBL then ns.code:fOut('There was an issue loading the Black List.', 'FFAF640C') end

    local invSuccess, tblInv = ns.code:decompressData(ns.dbGlobal.antiSpamList and ns.dbGlobal.antiSpamList or '')
    if invSuccess and tblInv then ns.tblInvited = tblInv
    elseif ns.dbInv then ns.code:fOut('There was an issue loading the Invited Players.', 'FFAF640C') end

    local sessionSuccess, tblSession = ns.code:decompressData(ns.dbGlobal.sessionData)
    if sessionSuccess and tblSession then ns.ds.tblSavedSessions = tblSession
    else ns.ds.tblSavedSessions = date('%m%d%Y') end


    -- Remove Invited Players
    for k, r in pairs(ns.tblInvited) do
        if r.invitedOn < antiSpamExpire then
            ns.tblInvited[k] = nil
            invitedRemoved = invitedRemoved + 1
        end
    end

    -- Remove Black List
    local blExpire = C_DateAndTime.GetServerTimeLocal()
    for k, r in pairs(ns.tblBlackList) do
        if r.markedForDelete and r.dateBlackList <= blExpire then
            ns.tblBlackList[k] = nil
            blackListRemoved = blackListRemoved + 1
        end
    end

    if invitedRemoved > 0 then ns.code:saveTables('INVITED')
        ns.code:fOut(string.format(L['ANTI_SPAM_REMOVAL'], invitedRemoved), 'FFFFFFFF', true)
    end
    if blackListRemoved > 0 then ns.code:saveTables('BLACK_LIST')
        ns.code:cOut(blackListRemoved..L['BL_REMOVAL'], 'FFFFFFFF', true)
    end
end
-- Support Routines
function core:CreateMiniMapIcon()
    local code = ns.code
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GuildRecruiter", { -- Minimap Icon Settings
        type = 'data source',
        icon = GR.icon,
        OnClick = function(_, button)
            if button == 'LeftButton' then ns.screens.home:StartUp()
            elseif button == 'RightButton' then Settings.OpenToCategory('Guild Recruiter')(ns.addonOptions) end
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

    icon:Register('GR_Icon', iconData, ns.settings.minimap)
end
function core:SlashCommands()
    local function slashCommand(msg)
        msg = strlower(msg:trim())

        if not msg or msg == '' then ns.screens.home:StartUp()
        elseif msg == L['help'] then
            ns.code:fOut(string.format(tostring(L['SLASH_HELP1']), tostring(GR.version)))
            ns.code:fOut(L['SLASH_HELP2'])
            ns.code:fOut(L['SLASH_HELP3'])
            ns.code:fOut(L['SLASH_HELP4'])
            ns.code:fOut(L['SLASH_HELP5'])
        elseif strlower(msg) == L['config'] then Settings.OpenToCategory('Guild Recruiter')(ns.addonOptions)
        elseif strlower(msg):match(tostring(L['blacklist'])) then
            msg = strlower(msg):gsub(tostring(L['blacklist']), ''):trim()
            local name = strupper(strsub(msg,1,1))..strlower(strsub(msg,2))
            ns:add(name)
        end
    end

    GR:RegisterChatCommand('gr', slashCommand)
    GR:RegisterChatCommand(L['recruiter'], slashCommand)
end
function core:FinishStartup()
    -- Chat Message Response Routine
    local function CHAT_MSG_SYSTEM(...) ns.observer:Notify('CHAT_MSG_SYSTEM', ...) end
    ns.events:RegisterEvent('CHAT_MSG_SYSTEM', CHAT_MSG_SYSTEM)

    AC:RegisterOptionsTable('GR_Options', ns.addonSettings)
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter')

    ns.screens.base:StartUp()
    local showWhatsNew = type(ns.db.global.showWhatsNew) == 'boolean' and ns.db.global.showWhatsNew or true
    if showWhatsNew and ns.db.global.version ~= ns.ds.grVersion then
        ns.screens.whatsnew:StartUp()
    else
        self.fullyStarted = true
        ns.screens.base.tblFrame.frame:SetShown(false)
    end
end
core:Init()

-- Context Menu Routine
local function HandlesGlobalMouseEvent(self, button, event)
	if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton')then
        if not ns.settings.showContextMenu then return false end
		return true
	end
	return false
end

local tblFrame, rows, rowHeight = {}, 3, 40
local function DropDownOnShow(self)
    if not core.isEnabled or not CanGuildInvite() then return
    elseif not ns.settings.showContextMenu then return
    elseif not ns.db or not ns.settings or not ns.settings.showContextMenu then return end

    local dropdown = self.dropdown
    if not dropdown or not dropdown.which then return end

    local name = dropdown.name
    local server = dropdown.server or GetRealmName()
    local fullName = name and name..'-'..server or nil
    if not name then return
    elseif not ns.code:verifyRealm(server, 'REALM_ONLY') then
        ns.code:fOut('Player is not connected to your realm.', 'FFFF0000')
        return
    end

    -- Create the Box
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
        if fullName then ns.invite:InvitePlayer(fullName, true, false, false, true) end
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
        if fullName then ns.invite:InvitePlayer(fullName, true, false, true, true) end
        CloseDropDownMenus()
    end)
end
local function DropDownOnHide() if tblFrame.frame then tblFrame.frame:SetShown(false) end end
DropDownList1:HookScript('OnShow', DropDownOnShow)
DropDownList1:HookScript('OnHide', DropDownOnHide)