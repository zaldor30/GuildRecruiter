local _, ns = ... -- Namespace (myaddon, namespace)
ns.core = {}

-- Application Initialization
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')
local core = ns.core

-- *Blizzard Initialization Called Function
function GR:OnInitialize()
    if core.isEnabled then return end -- Prevents double initialization

    GR:RegisterChatCommand('rl', function() ReloadUI() end) -- Set the /rl slash command to reload the UI

    local function checkIfInGuild(count)
        local clubID = C_Club.GetGuildClubId() -- Get the guild club ID (Guild ID)

        if count >= 60 then -- If the player is not in a guild after 30 attempts, then return
            core.isEnabled = false
            ns.code:cOut(L['NO GUILD']..' '..L['NOT_LOADED'])
            return
        elseif IsInGuild() and not CanGuildInvite() then -- If the player is in a guild but cannot invite, then return
            core.isEnabled = false
            ns.code:dOut(L['CANNOT_INVITE'])
            ns.code:dOut(L['NOT_LOADED'])
            return
        elseif not IsInGuild() or not clubID or not select(1, GetGuildInfo('player')) then -- If the player is not in a guild, then check again in 1 second
            C_Timer.After(1, function() checkIfInGuild(count + 1) end)
        elseif clubID then core:StartGuildRecruiter(clubID) end
    end

    checkIfInGuild(0)
end

function core:Init()
    self.hasGM = false
    self.iAmGM = false
    self.isEnabled = false
    self.fullyStarted = false
    self.ignoreAutoSync = false

    self.addonSettings = {
        profile = {
            currentVersion = nil, -- If nil show first time info, if not same version show what's new prompt
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
                disableAutoSync = false, -- Disable Auto Sync
                showWhispers = false, -- Show Whispers
            },
            analytics = {}
        },
        global = {
            showWhatsNew = true,
            guildInfo = {},
            gmSettings = {
                -- GM Settings
                antiSpam = false,
                antiSpamDays = 7,
                sendGuildGreeting = false,
                welcomeMessage = L['DEFAULT_GUILD_WELCOME'],
                sendWhisperGreeting = false,
                greetingMessage = '',
                messageList = {},
                isGuildLeader = false,
                guildLeaderToon = nil,
            },
            settings = {
                -- General Settings
                showToolTips = true, -- Show Tool Tips
                showConsoleMessages = false, -- Show Console Messages
                -- Invite Settings
                antiSpam = true,
                antiSpamDays = 7,
                sendGuildGreeting = false,
                welcomeMessage = L['DEFAULT_GUILD_WELCOME'],
                sendWhisperGreeting = false,
                greetingMessage = '',
                scanWaitTime = 6,
                -- Messages
                messageList = {},
                overrideGM = false,
            },
            keybindings = {
                scan = 'CTRL-SHIFT-S',
                invite = 'CTRL-SHIFT-I',
            },
            blackList = {},
            blackListRemoved = {},
            antiSpamList = {},
            zoneList = {},
            filterList = {},
            analytics = {},
        }
    }
end
-- * Guild Recruiter Startup Routines
function core:StartDatabase(clubID)
    if not clubID then return end

    local db = DB:New('GuildRecruiterDB') -- Initialize the database

    -- Initialize the database        
    db.global[clubID] = db.global[clubID] or self.addonSettings.global
    ns.code:dOut('Current Profile: ', db:GetCurrentProfile())

    db.profile.settings = db.profile.settings or self.addonSettings.profile.settings
    db.profile.analytics = db.profile.analytics or self.addonSettings.profile.analytics

    -- General Settings Variables 
    ns.g = db.global[clubID] -- Global Settings
    ns.p = db.profile -- Profile Settings
    ns.global = db.global -- Global Settings

    ns.gSettings, ns.pSettings = ns.g.settings, ns.p.settings -- General Settings
    -- Guild Settings Variables Declaration
    ns.guildInfo = ns.g.guildInfo or {} -- Guild Info
    ns.gmSettings = ns.g.gmSettings or self.addonSettings.global.gmSettings -- GM Settings

    -- Fix for old DB settings
    ns.gmSettings.sendGuildGreeting = ns.gmSettings.sendGuildGreeting or ns.gmSettings.sendWelcome
    ns.gmSettings.sendWhisperGreeting = ns.gmSettings.sendWhisperGreeting or ns.gmSettings.sendGreeting

    ns.gSettings.sendGuildGreeting = ns.gSettings.sendGuildGreeting or ns.gSettings.sendWelcome
    ns.gSettings.sendWhisperGreeting = ns.gSettings.sendWhisperGreeting or ns.gSettings.sendGreeting

    -- Other Variables Declaration
    ns.gFilterList = ns.g.filterList or {} -- Global Filter List
    ns.gAnalytics = ns.g.analytics or {} -- Global Analytics
    ns.pAnalytics = ns.p.analytics or {} -- Profile Analytics

    GR.debug = ns.pSettings.debugMode or false -- Set the debug mode
end

--!Remove dOut after testing in StartGuildSetup

function core:StartGuildSetup(clubID) -- Get Guild Info and prep database
    if not clubID then return end

    local function checkIfGuildLeader()
        if IsGuildLeader() then
            ns.guildInfo.isGuildLeader = true
            ns.guildInfo.guildLeaderToon = GetUnitName('player', true)
            ns.code:dOut('You are the Guild Leader')
        elseif not IsGuildLeader() then
            if ns.guildInfo.guildLeaderToon == GetUnitName('player', true) then
                ns.guildInfo.isGuildLeader = false
                ns.guildInfo.guildLeaderToon = nil
                ns.code:dOut(GetUnitName('player', true)..' is no longer the Guild Leader')
            elseif not ns.guildInfo.guildLeaderToon then
                ns.guildInfo.isGuildLeader = false
                ns.code:dOut('You are not the Guild Leader')
            else ns.code:dOut('Current Guild Leader: '..(ns.guildInfo.guildLeaderToon or 'No One')) end
        end
    end

    ns.guildInfo.clubID = clubID
    ns.guildInfo.guildName = GetGuildInfo('player')

    local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
    if not ns.guildInfo.guildLink and club then
        ns.guildInfo.guildLink = GetClubFinderLink(club.clubFinderGUID, club.name) or nil
    elseif not ns.guildInfo.guildLink then
        ns.code:cOut(L['NO_GUILD_LINK'])
    end

    checkIfGuildLeader()
end
function core:PerformRecordMaintenance() -- Perform Record Maintenance
    -- ToDo: Remove old deleted black list records
    -- Decode Black List
    local blSuccess, tblBL = ns.code:decompressData(ns.g.blackList or {})
    if blSuccess then ns.blackList = tblBL or {}
    else
        ns.blackList = {}
        ns.code:dOut('There was an issue decoding the Black List (Record Maint)') end

    -- Decode Anti-Spam List
    local asSuccess, tblAS = ns.code:decompressData(ns.g.antiSpamList or {})
    if asSuccess then ns.antiSpamList = tblAS or {}
    else
        ns.antiSpamList = {}
        ns.code:dOut('There was an issue decoding the Anti-Spam List (Record Maint)') end

    -- Start Record Maintenance
    local antiSpamRemoved, blackListRemoved = 0, 0
    local antiSpamDays = (ns.gmSettings.antiSpam and ns.gmSettings.antiSpamDays) and ns.gmSettings.antiSpamDays or (ns.gSettings.antiSpamDays or 7)
    local antiSpamExpire = C_DateAndTime.GetServerTimeLocal() - (antiSpamDays * SECONDS_IN_A_DAY)

    -- Anti-Spam List Maintenance
    for k, r in pairs(ns.antiSpamList) do
        if r.timeStamp < antiSpamExpire then
            ns.antiSpamList[k] = nil
            antiSpamRemoved = antiSpamRemoved + 1
        end
    end

    -- Black List Maintenance
    local blExpire = C_DateAndTime.GetServerTimeLocal()
    for k, r in pairs(ns.blackList) do
        if r.timeStamp < blExpire then
            ns.blackList[k] = nil
            blackListRemoved = blackListRemoved + 1
        end
    end

    -- Report to console
    ns.code:fOut('Anti-Spam Records Removed: '..antiSpamRemoved, GRColor)
    ns.code:fOut('Black List Records Removed: '..blackListRemoved, GRColor)
end
function core:StartSlashCommands() -- Start Slash Commands
    local function slashCommand(msg)
        msg = strlower(msg:trim())

        if not msg or msg == '' then ns.win.home:StartUp()
        elseif msg == L['HELP'] then ns.code:fOut(L['SLASH_COMMANDS'], GRColor, true)
        elseif strlower(msg) == L['CONFIG'] then Settings.OpenToCategory('Guild Recruiter')
        elseif strlower(msg):match(tostring(L['BLACKLIST'])) then
            msg = strlower(msg):gsub(tostring(L['BLACKLIST']), ''):trim()
            local name = strupper(strsub(msg,1,1))..strlower(strsub(msg,2))
            ns:add(name)
        end
    end

    GR:RegisterChatCommand('gr', slashCommand)
    GR:RegisterChatCommand(L["RECRUITER"], slashCommand)
end
function core:StartMiniMapIcon() -- Start Mini Map Icon
    local code = ns.code
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GR_Icon", { -- Minimap Icon Settings
        type = 'data source',
        icon = GR.icon,
        OnClick = function(_, button)
            if button == 'LeftButton' then return ns.win.base:SetShown(true)
            elseif button == 'RightButton' then Settings.OpenToCategory('Guild Recruiter') end
        end,
        OnTooltipShow = function(GameTooltip)
            local title = code:cText('FFFFFF00', L['TITLE']..' v'..GR.version..':')
            local body = code:cText('FFFFFFFF', L['MINIMAP_TOOLTIP'])

            local antiSpam = #ns.antiSpamList > 0 and ' |cFFFF0000'..#ns.antiSpamList..'|r' or 0
            local blackList = #ns.blackList > 0 and ' |cFFFF0000'..#ns.blackList..'|r' or 0

            body = body:gsub('%%AntiSpam', antiSpam)
            body = body:gsub('%%BlackList', blackList)

            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
        OnLeave = function()
            GameTooltip:Hide() -- Hide the tooltip when the mouse leaves the icon
        end,
    })

    icon:Register('GR_Icon', iconData, ns.pSettings.minimap)
end
function core:StartBaseEvents()
    -- Chat Message Response Routine
    local function CHAT_MSG_SYSTEM(...) ns.observer:Notify('CHAT_MSG_SYSTEM', ...) end
    ns.events:RegisterEvent('CHAT_MSG_SYSTEM', CHAT_MSG_SYSTEM)

    -- Saves the ns.blackList and ns.antiSpamList tables on logout
    ns.events:RegisterEvent('PLAYER_LOGOUT', function() ns.code:saveTables() end)
end
function core:StartGuildRecruiter(clubID) -- Start Guild Recruiter
    self.isEnabled = true
    ns.code:dOut('Starting Guild Recruiter')

    ns.code.fPlayerName = ns.code:cPlayer(GetUnitName('player', false), select(2, UnitClass("player"))) -- Set the player name

    self:StartDatabase(clubID) -- Start the database
    self:StartGuildSetup(clubID) -- Start the guild setup
    if not self.isEnabled then return end -- If the guild is not enabled, then return

    -- Setup Tables
    ns.tblRaces, ns.tblClasses, ns.tblInvalidZones = ns.ds:races(), ns.ds:classes(), ns.ds:invalidZones()
    ns.tblRacesSortedByName = ns.code:sortTableByField(ns.tblRaces, 'name')
    ns.tblClassesSortedByName = ns.code:sortTableByField(ns.tblClasses, 'name')

    AC:RegisterOptionsTable('GR_Options', ns.addonSettings) -- Register the options table
    ns.addonOptions = ACD:AddToBlizOptions('GR_Options', 'Guild Recruiter') -- Add the options to the Blizzard options
    self.hasGM = (ns.guildInfo.isGuildLeader and ns.guildInfo.guildLeaderToon) or false
    self.iAmGM = (ns.guildInfo.isGuildLeader or ns.guildInfo.guildLeaderToon == GetUnitName('player', true)) or false
    ns.gSettings.overrideGM = self.iAmGM and ns.gSettings.overrideGM or false

    core:PerformRecordMaintenance() -- Perform record maintenance
    core:StartSlashCommands() -- Start the slash commands
    core:StartMiniMapIcon() -- Start the mini map icon

    -- ToDo: Invite Startup

    core:StartBaseEvents() -- Start the base events
    self.fullyStarted = true
    ns.win.base:StartUp() -- Build the base window
    ns.win.base:SetShown(false) -- Hide the base window

    -- Display info based on version change
    if not ns.g.currentVersion then ns.code:fOut(L['FIRST_TIME_INFO'], GRColor, true)
    elseif ns.g.currentVersion ~= GR.version then ns.code:fOut(L['NEW_VERSION_INFO'], GRColor, true) end
    ns.g.currentVersion = GR.version -- Set the current version

    ns.code:fOut(L['TITLE']..' ('..GR.version..(GR.isBeta and ' Beta) ')..L['IS_ENABLED'], GRColor, true)
    if GR.isBeta then ns.code:fOut(L['BETA_INFORMATION'], 'FF0000', true) end

    -- ToDo: Sync Timer Routine
end
core:Init()

-- * Right Click Invite Routines