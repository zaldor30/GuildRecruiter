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
        local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil -- Get the guild club info

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
        elseif clubID and club then core:StartGuildRecruiter(clubID) end
    end

    checkIfInGuild(0)
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
-- * Guild Recruiter Startup Routines
function core:StartDatabase(clubID)
    if not clubID then return end

    local db = DB:New('GuildRecruiterDB') -- Initialize the database

    -- Initialize the database        
    db.global[clubID] = db.global[clubID] or self.addonSettings.global
    ns.code:dOut('Current Profile: ', db:GetCurrentProfile())
    print(db.profile.settings)

    db.profile.settings = db.profile.settings or self.addonSettings.profile.settings
    db.profile.analytics = db.profile.analytics or self.addonSettings.profile.analytics
    
    -- General Settings Variables Declaration
    ns.g = db.global[clubID] -- Global Settings
    ns.p = db.profile -- Profile Settings

    --ns.gSettings = ns.g.settings or {} -- Global Settings
    --ns.pSettings = ns.p.settings or {} -- Profile Settings

    -- Guild Settings Variables Declaration
    --[[ns.guildInfo = ns.g.guildInfo or {} -- Guild Info
    ns.gmSettings = ns.g.gmSettings or self.addonSettings.global.gmSettings -- GM Settings

    -- Guild List Variables Declaration
    ns.blackList = ns.g.blackList or {} -- Black List
    ns.antiSpamList = ns.g.antiSpamList or {} -- Anti-Spam List

    -- Other Variables Declaration
    ns.gFilterList = ns.g.filterList or {} -- Global Filter List
    ns.gAnalytics = ns.g.analytics or {} -- Global Analytics
    ns.pAnalytics = ns.p.analytics or {} -- Profile Analytics

    GR.debug = ns.pSettings.debugMode or false -- Set the debug mode
    GR.debug = true --!Change after settings is made --]]
end
function core:StartGuildSetup(clubID)
    if not clubID then return end

    local function checkIfGuildLeader()
        local gm = C_Club.GetClubPrivileges(clubID)
        if gm and gm.canSetAttribute then
            core.isGuildLeader = true
            ns.gmSettings.isGuildLeader = true
            print('You are the guild leader.')
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

    if not ns.guildInfo.guildLink and ns.gmSettings.isGuildLeader then
        ns.code:cOut(L['GUILD_LINK_INSTRUCTIONS'])
    end
end
function core:StartGuildRecruiter(clubID) -- Start Guild Recruiter
    self.isEnabled = true
    ns.code:dOut('Starting Guild Recruiter')

    self:StartDatabase(clubID) -- Start the database
    --self:StartGuildSetup(clubID) -- Start the guild setup
    if not self.isEnabled then return end -- If the guild is not enabled, then return

    ns.code:cOut(L['TITLE']..' ('..GR.version..') '..L['IS_ENABLED'], 'FF3EB9D8', false)

    --!Sync Timer Routine
end
core:Init()