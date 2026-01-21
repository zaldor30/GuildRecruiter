--[[
Guild Recruiter Core

Purpose:
- Start the addon only when the player is in a guild and can invite.
- Set up saved data (AceDB), UI hooks, and integration points.
- Provide simple slash commands and a minimap entry for access.

Libraries used:
- AceLocale-3.0, AceConfig-3.0, AceConfigDialog-3.0, AceDB-3.0
- LibDataBroker-1.1, LibDBIcon-1.0

Lifecycle Overview:
1) PLAYER_LOGIN → `core:StartGuildRecruiter()`
2) `core:GuildVerification()` ensures guild/permissions → registers events
3) `core:RegisterDatabase()` binds AceDB (profile/global/guild)
4) `core:InitializeTables()` loads lists and datasets
5) `core:InitializeGuildInfo()` sets guild name/link + GM state
6) UI + minimap + slash commands become available
]]

local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.BlackList, ns.AntiSpamListList = {}, {}

local AC, ACD   = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB  = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

ns.core = {}
local core = ns.core
local ClubID = nil

--* Courtesy warning if FGI is also running
local function checkForFGI(retry)
    retry = retry + 1
    local isFGILoaded = C_AddOns.IsAddOnLoaded('FastGuildInvite')
    if isFGILoaded then
        ns.code:fOut(L['FGI_LOADED'], ns.COLOR_ERROR)
        return
    elseif retry > 5 then
        return
    else
        C_Timer.After(1, function() checkForFGI(retry + 1) end)
    end
end
checkForFGI(0)

--*Event handler for PLAYER_LOGIN to check guild status and start GR.

--#region Event Handlers
local function eventsPLAYER_LOGIN()
    GR:UnregisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)
    core:StartGuildRecruiter()
end
GR:RegisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)
--#endregion Event Handlers

--- Notify AceConfig that our options table changed (e.g., labels/values).
function core:NotifySettingsUpdate()
    AceConfigRegistry:NotifyChange(addonName)
end

--*Initialize core defaults and AceDB base schemas (no I/O, no UI).
local GuildCheckTimeOut = 15     -- Seconds to wait for guild clubID fetch
-- Call once on load; real boot happens in StartGuildRecruiter().
--- Prepare default structures used by AceDB and runtime flags.
function core:Init()
    self.isEnabled = false          -- True after full successful start
    self.fullyStarted = false       -- Reserved if stricter gating is needed
    self.ignoreAutoSync = false     -- Manual override for auto sync
    self.obeyBlockInvites = true    -- Default, can be overridden by settings

    self.minimapIcon = nil          -- LibDBIcon handle (set in StartMiniMapIcon)

    -- AceDB profile/global scaffolding (defaults). Do not mutate in-place;
    -- treat as constant default templates passed to AceDB:New().
    self.fileStructure = {
        profile = {
            settings = {
                -- Starting Levels
                minLevel = ns.MAX_CHARACTER_LEVEL - 5,
                maxLevel = ns.MAX_CHARACTER_LEVEL,
                -- General Settings
                activeFilter = 9999,
                activeMessage = nil,
                compactMode = false,          -- Scanner Compact Mode (legacy)
                minimap = { hide = false },   -- Mini Map Icon
                showContextMenu = true,       -- Show Context Menu
                debugMode = false,            -- Debug Mode
                showAppMsgs = true,           -- Show Application Messages
                enableAutoSync = true,        -- Enable Auto Sync
                showWhispers = true,          -- Show Whispers in UI
                antiSpam = true,
                antiSpamDays = 7,
                sendGuildGreeting = true,
                guildMessage = L['DEFAULT_GUILD_WELCOME'],
                sendWhisperGreeting = false,
                obeyBlockInvites = true,      -- Respect invite-block windows
                messageList = {},             -- Personal templates
                keepOpen = false,             -- ESC closes UI when false
                inviteFormat = 2,
                isCompact = false,            -- Current compact on/off
                whisperMessage = '',
            },
            analytics = {},
        },
        global = {
            timeBetweenMessages = "0.2",      -- String seconds, used by ns.MQ
            showWhatsNew = true,
            showToolTips = true,
            compactSize = 1,
            ScanWaitTime = 5,
            zoneList = {},
            keybindings = {
                scan = 'CTRL-SHIFT-S',
                invite = 'CTRL-SHIFT-I',
            },
        }
    }

    -- Defaults that live under the per-guild (clubID) bucket.
    self.guildFileStructure = {
        guildInfo = {
            clubID = nil,
            guildName = '',
            guildLink = '',
        },
        gmSettings = {
            -- GM-enforced knobs
            forceMessageList = false,
            forceSendWhisper = false,
            forceInviteMessage = false,
            forceWhisperMessage = false,
            forceSendGuildGreeting = false,
            obeyBlockInvites = true,
            antiSpam = true,
            antiSpamDays = 7,
            sendGuildGreeting = true,
            guildMessage = L['DEFAULT_GUILD_WELCOME'],
            sendWhisperGreeting = false,
            whisperMessage = '',
        },
        settings = {
            -- Shared guild defaults (not enforced when GM forces exist)
            showConsoleMessages = false,
            antiSpam = true,
            antiSpamDays = 7,
            sendGuildGreeting = true,
            guildMessage = L['DEFAULT_GUILD_WELCOME'],
            sendWhisperGreeting = false,
            whisperMessage = '',
            messageList = {},
        },
        isGuildLeader = false,
        guildLeaderToon = nil,
        gmActive = false,
        analytics = {},
        blackList = {},
        filterList = {},
        messageList = {},
        antiSpamList = {},
        blackListRemoved = {},
        lastSync = {}, -- { who = "Name-Realm", date = time() }
    }
end

--*Do start Guild Recruiter Routines
--- Entry point that performs initial checks and kicks off initialization.
function core:StartGuildRecruiter()
    core.isEnabled = false

    GR:UnregisterAllEvents()
    GR:RegisterChatCommand('rl', function() ReloadUI() end) -- quick reload

    ClubID = self:GuildVerification() or nil
end

--* Verify guild status and Guild Status Events

--#region Support Guild Functions
--- Ensure the player is in a guild and can invite; register guild events.
function core:GuildVerification()
    -- Recursive function to wait for clubID fetch
    local function clubIDCheck(count)
        local clubID = C_Club.GetGuildClubId() or nil

        if clubID then
            core.isEnabled = true
            ClubID = clubID
            core:InitializeGuildRecruiter()
            return clubID
        else
            if count < GuildCheckTimeOut then
                C_Timer.After(1, function() clubIDCheck(count + 1) end)
            else
                core.isEnabled = false
                return nil end
        end
    end
    local clubID = clubIDCheck(0)

    if not clubID then
        ns.code:fOut(L['NOT_IN_GUILD'])
        ns.code:fOut(L["NOT_IN_GUILD_LINE1"])
        return
    elseif not CanGuildInvite() then ns.code:cOut(L['CANNOT_INVITE']) end

    GR:RegisterEvent('PLAYER_GUILD_UPDATE', function()
        self:GuildStatusChanged()
    end) -- Handle guild join/leave guild events

    if clubID then
        GR:RegisterEvent('GUILD_ROSTER_UPDATE', function()
            self:GuidInfoChanges()
        end) -- Check for guild info changes and check rank
        return clubID
    else return nil end
end
--* Initialize guild info (name/link) and guild leader status
--- Populate guild info and leader state; warn if Anti-Spam is disabled.
function core:InitializeGuildInfo()
    local guildName = GetGuildInfo('player')

    ns.guildInfo.clubID = ClubID
    ns.guildInfo.guildName = guildName or ''

    self:GuidLeaderStatus()

    if (ns.isGM and not ns.gmSettings.antiSpam) or (not ns.isGM and not ns.pSettings.antiSpam) then
        ns.code:fOut(L['NO_ANTI_SPAM'], ns.COLOR_ERROR)
    end

    if ns.isGM then
        ns.guild.isGuildLeader = true
        ns.guild.guildLeaderToon = GetUnitName('player', true)
    elseif not ns.isGM then
        ns.gmActive = ns.guild.gmActive or false
        ns.obeyBlockInvites = ns.gmSettings.obeyBlockInvites and ns.gmSettings.obeyBlockInvites or ns.gSettings.obeyBlockInvites
        if GetUnitName('player', true) == ns.guild.guildLeaderToon then
            ns.guild.isGuildLeader = false
            ns.guild.guildLeaderToon = nil
        end
    end

    -- Validate existing guildLink (may be stale across sessions/renames)
    ns.guildInfo.guildLink = (ns.guildInfo.guildLink and ns.guildInfo.guildLink ~= '') and ns.guildInfo.guildLink or nil
    if ns.guildInfo.guildLink and not strmatch(ns.guildInfo.guildLink, guildName) then
        ns.guildInfo.guildLink = nil
    end

    local function createGuildLink(retry)
        local club = ClubID and ClubFinderGetCurrentClubListingInfo(ClubID) or nil
        if club then
            local guildLink = "|cffffd200|HclubFinder:"..club.clubFinderGUID.."|h["..club.name.."]|h|r"
            ns.guildInfo.guildLink = guildLink or nil
            return
        elseif retry >= 10 then
            ns.guildInfo.guildLink = nil
            ns.code:fOut(ns.code:cText(ns.COLOR_ERROR, L['GUILD_LINK_NOT_FOUND']))
            if ns.core.isGM then ns.code:fOut(L['GUILD_LINK_NOT_FOUND_GM'])
            else ns.code:fOut(L['PLAYER_GUILD_LINK_NOT_FOUND']) end
            return
        else
            C_Timer.After(1, function() createGuildLink(retry) end)
        end
    end
    if not ns.classic then
        if not ns.guildInfo.guildLink or not strmatch(ns.guildInfo.guildLink, guildName) then
            createGuildLink(0)
        end
    end
end
--* Check and notify guild leader status changes
--- Compare stored vs current GM state and announce transitions.
function core:GuidLeaderStatus()
    if not ns.guild then return end

    local storedLeaderState = ns.guild.isGuildLeader
    local currentLeaderState = IsGuildLeader()
    ns.isGM = currentLeaderState

    if storedLeaderState ~= currentLeaderState then
        ns.guild.isGuildLeader = currentLeaderState
        if currentLeaderState then ns.code:cOut(L['GAINED_GUILD_LEADER'])
        else ns.code:cOut(L['LOST_GUILD_LEADER']) end
    end
    ns.guild.isGuildLeader = ns.isGM
end
--* Handle guild join/leave guild events
--- Handle join/leave or guild change and update enabled state/messages.
function core:GuildStatusChanged()
    if ClubID and C_Club.GetGuildClubId() == ClubID then core:GuidLeaderStatus()
    elseif ClubID and C_Club.GetGuildClubId() ~= ClubID then
        ns.code:fOut(L['NOT_IN_GUILD'])
        core.isEnabled = false
    elseif not ClubID and C_Club.GetGuildClubId() then
        ns.code:fOut(L['NEW_GUILD_DETECTED'])
        core.isEnabled = false
    end
end
--* Check for guild info changes (name/link) and rank changes
--- Detect guild info/rank changes and disable when invites are blocked.
function core:GuidInfoChanges()
    local tClubID = C_Club.GetGuildClubId() or nil
    if not tClubID or tClubID ~= ClubID then return end

    if not CanGuildInvite() then ns.code:cOut(L['CANNOT_INVITE_DETECTED']) core.isEnabled = false return end
end
--#endregion Support Guild Functions

--* Initialize Guild Recruiter for the current guild

--#region Initialize Guild Recruiter Routines
--- Full initialization: DB, UI, minimap, slash, invite subsystem.
function core:InitializeGuildRecruiter()
    if not core.isEnabled then return false end

    self:Init()
    ns.fPlayerName = ns.code:cPlayer(GetUnitName('player', false), UnitClassBase('player'))

    ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['ENABLED'], ns.COLOR_DEFAULT, true)
    if GR.isPreRelease then
        ns.code:fOut(L['BETA_INFORMATION']:gsub('VER', ns.code:cText('FFFF0000', strlower(GR.preReleaseType))), 'FFFFFF00', true)
    end

    self:RegisterDatabase() -- Initialize and bind AceDB

    self:InitializeTables() -- Decompress and load black/anti-spam lists
    self:PerformRecordMaintenance() -- Clean up old records

    self:InitializeGuildInfo()

    -- Build options UI (the options table is provided by your settings module)
    ns.newSettingsMessage()                                    -- seed blank
    AC:RegisterOptionsTable(addonName, ns.guildRecruiterSettings) -- (sic) table name
    ns.addonOptions = ACD:AddToBlizOptions(addonName, 'Guild Recruiter')

    -- Shell/UI affordance
    self:StartMiniMapIcon()
    self:StartSlashCommands()

    ns.base:SetShown(true, true)
    ns.events:StartBaseEvents()

    -- Invite subsystem
    ns.invite:Init()
    ns.invite:GetMessages()
    ns.invite:RegisterInviteObservers()

    return true
end
--* Register and bind the AceDB database
--- Create AceDB, reset old versions, and bind handy references.
function core:RegisterDatabase()
    local db = DB:New(GR.db, self.fileStructure) -- AceDB: profile/global roots
    if db.global.dbVer and db.global.dbVer < 4 then
        -- Reset database if version is older than version 4
        db.global = db.global and table.wipe(db.global) or {}
        db:ResetProfile()
        for profileName in pairs(db.profiles) do
            db.profiles[profileName] = nil
        end
        db.global.dbVer = GR.dbVersion
        ns.code:fOut(L['DATABASE_RESET'], ns.COLOR_ERROR)
    end
    if ClubID and not db.global[ClubID] then
        db.global[ClubID] = self.guildFileStructure
    end
    -- Bind handy references (read/write) for the rest of the addon
    ns.p,        ns.g,        ns.guild      = db.profile, db.global, db.global[ClubID]
    ns.pAnalytics, ns.gAnalytics            = ns.p.analytics, ns.guild.analytics
    ns.pSettings,  ns.gSettings             = ns.p.settings,  ns.guild.settings
    ns.guildInfo,  ns.gmSettings            = ns.guild.guildInfo, ns.guild.gmSettings
    ns.gFilterList                          = ns.guild.filterList

    -- Initialize guild leader status
    if ns.guild.isGuildLeader == nil then
        ns.guild.isGuildLeader = IsGuildLeader()
    end

    -- Debug flags
    GR.debug = (GR.debug or GR.isTesting) or ns.pSettings.debugMode
end
--- Inflate runtime tables from compressed storage and load datasets.
function core:InitializeTables()
    -- Decompress blackList
    if ns.guild.blackList and type(ns.guild.blackList) == "table" and next(ns.guild.blackList) ~= nil then
        ns.BlackList = ns.code:decompressData(ns.guild.blackList)
    else
        ns.guild.blackList = {}
        ns.BlackList = {}
    end

    -- Decompress antiSpamList
    if ns.guild.antiSpamList and type(ns.guild.antiSpamList) == "table" and next(ns.guild.antiSpamList) ~= nil then
        ns.AntiSpamListList = ns.code:decompressData(ns.guild.antiSpamList)
    else
        ns.guild.antiSpamList = {}
        ns.AntiSpamListList = {}
    end

    -- Create Datasets (classes/races/invalid zones)
    if ns.retail then
        ns.races   = ns.ds:races_retail()
        ns.classes = ns.ds:classes_retail()
        ns.invalidZones = ns.ds:invalidZones_Retail()
    elseif ns.classic then
        ns.MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()
        ns.races   = ns.ds:races_classic()
        ns.classes = ns.ds:classes_classic()
        ns.invalidZones = ns.ds:invalidZones_Classic()
    elseif ns.cata then
        ns.MAX_CHARACTER_LEVEL = GetMaxPlayerLevel()
        ns.races   = ns.ds:races_cata()
        ns.classes = ns.ds:classes_cata()
        ns.invalidZones = ns.ds:invalidZones_Cata()
    end
    ns.classesByID = ns.code:sortTableByField(ns.classes, 'id')

    ns.analytics:RetrieveSavedData()
end
--- Perform periodic cleanup and GM migration of personal templates.
function core:PerformRecordMaintenance()
    -- If user became GM, move any personal message templates to GM list.
    if ns.isGM and #ns.pSettings.messageList > 0 then
        for _, v in pairs(ns.pSettings.messageList) do
            table.insert(ns.gmSettings.messageList, v)
        end
        ns.pSettings.messageList = {}
    end

    -- Drop stale anti-spam entries older than configured days.
    local function removeOldRecords(tbl, days)
        local currentTime = time()
        for name, data in pairs(tbl or {}) do
            if data and data.time then
                local age = currentTime - data.time
                if age >= days * 86400 then
                    tbl[name] = nil
                end
            end
        end
    end
    removeOldRecords(ns.AntiSpamList, ns.gmSettings.antiSpamDays)
end
--- Register /gr and /recruiter style slash commands.
-- Supported:
--  - /gr (no args)      : toggles base UI
--  - /gr help           : prints help
--  - /gr config         : opens options
--  - /gr blacklist NAME : add NAME to blacklist (delegates to ns:add)
function core:StartSlashCommands()
    local function slashCommand(msg)
        msg = strlower(msg:trim())

        if not core.isEnabled then
            ns.code:fOut(L['NOT_ENABLED'], ns.COLOR_ERROR)
            return
        elseif not msg or msg == '' and not ns.base:IsShown() then
            return ns.base:SetShown(true)
        elseif msg == strlower(L['HELP']) then
            ns.code:fOut(L['SLASH_COMMANDS'], ns.COLOR_DEFAULT, true)
        elseif strlower(msg) == strlower(L['CONFIG']) then
            core:OpenConfig()
        elseif strlower(msg):match(strlower(L['BLACKLIST'])) then
            msg = strlower(msg):gsub(strlower(L['BLACKLIST']), ''):trim()
            local name = strupper(strsub(msg,1,1))..strlower(strsub(msg,2))
            ns:add(name)
        end
    end

    GR:RegisterChatCommand('gr', slashCommand)
    GR:RegisterChatCommand(L["RECRUITER"], slashCommand)
end
--- Create and register the minimap icon (LibDataBroker + LibDBIcon).
-- Left-click toggles UI; Shift+Left opens scanner; Right-click opens options.
function core:StartMiniMapIcon()
    local code = ns.code
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GR_Icon", {
        type = 'data source',
        icon = ns.GR_ICON,
        OnClick = function(_, button)
            if button == 'LeftButton' and IsShiftKeyDown() then
                if not ns.base:IsShown() then ns.base:SetShown(true) end
                if not ns.scanner:IsShown() then ns.base:buttonAction('OPEN_SCANNER') end
            elseif button == 'LeftButton' then
                ns.base:SetShown(not ns.base:IsShown())
            elseif button == 'RightButton' then
                core:OpenConfig()
            end
        end,
        OnTooltipShow = function()
            local title = code:cText('FFFFFF00', L['TITLE']..' (v'..GR.version..'):')
            local body  = code:cText('FFFFFFFF', L['MINIMAP_TOOLTIP'])

            local count = 0
            for _ in pairs(ns.AntiSpamList or {}) do count = count + 1 end
            local antiSpam = ' |cFFFF0000'..count..'|r'

            count = 0
            for _ in pairs(ns.tblBlackLists or {}) do count = count + 1 end
            local blackList = ' |cFFFF0000'..count..'|r'

            body = body:gsub('%%AntiSpam', antiSpam):gsub('%%BlackList', blackList)
            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
        OnLeave = function() GameTooltip:Hide() end,
    })

    icon:Register('GR_Icon', iconData, ns.pSettings.minimap)
    self.minimapIcon = icon
end

--- Open the addon configuration panel across game versions.
function core:OpenConfig()
    -- Retail (Dragonflight+): Settings API expects a category ID/object, not a name.
    if Settings and Settings.OpenToCategory then
        local opts = ns.addonOptions
        local id = opts and (opts.ID or opts.categoryID)
        if id then
            Settings.OpenToCategory(id)
            return
        end
        -- Fallback: open AceConfigDialog window if category ID unavailable
        ACD:Open(addonName)
        return
    end

    -- Classic-era clients: use the legacy Interface Options frame
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions or addonName)
        return
    end

    -- Last resort: open AceConfigDialog directly
    ACD:Open(addonName)
end
--#endregion Initialize Guild Recruiter Routines

--[[
    Namespace variables:
    ns.core                 : Core routines and variables
    ns.code                 : Code routines (console output, keyword replacement)
    ns.fPlayerName          : Formatted player name with class color
    ns.isGM                 : Is the player guild master

    File variables:
    ns.p                   : Profile settings (per-character)
    ns.g                   : Global settings (all characters)
    ns.guild               : Current guild data (per-guild/clubID)
    ns.pSettings           : Shortcut to ns.p.settings
    ns.gSettings           : Shortcut to ns.guild.settings
    ns.guildInfo           : Shortcut to ns.guild.guildInfo
    ns.gmSettings          : Shortcut to ns.guild.gmSettings

    Other variables:
    core.isEnabled         : True if GR is fully started and enabled
    ns.BlackList           : Decompressed blacklist table
    ns.AntiSpamListList    : Decompressed anti-spam list table
]]