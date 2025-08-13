--[[-----------------------------------------------------------------------------
Guild Recruiter – Core Bootstrap
Author: Moonfury

This module wires up the addon’s lifecycle: database boot, option panels, slash
commands, minimap icon, base UI, invite system, and long-lived tables.

It exposes a single namespace table, `ns.core`, whose methods are called in
response to PLAYER_LOGIN and internal state checks.

# External Libraries
- AceLocale-3.0           : localization lookups
- AceConfig-3.0           : options table registration
- AceConfigDialog-3.0     : embed into Blizzard Options
- AceDB-3.0               : persistent saved variables
- LibDataBroker-1.1       : minimap data object
- LibDBIcon-1.0           : minimap icon wrapper

# Other Addon Modules (referenced)
- ns.code                 : formatting, dialogs, compression helpers
- ns.events               : base event wiring
- ns.base                 : top-level frame and navigation
- ns.invite               : invitation subsystem
- ns.ds                   : data source for classes/races/zones
- ns.analytics            : telemetry helpers
- ns.whatsnew             : “what’s new” panel
- ns.scanner, ns.list     : UI and lists

# Lifecycle (happy path)
1) PLAYER_LOGIN → core:CheckIfInGuild(...)
2) If guild+permission OK → core:StartGuildRecruiter(clubID)
3) StartGuildRecruiter:
   - core:StartDatabase(clubID) → AceDB profiles + guild bucket
   - core:LoadTables()          → inflate tables & data sets
   - core:PerformRecordMaintenance()
   - core:StartupGuild(clubID)  → name/link, GM flags, sanity checks
   - Register options (AceConfig), slash, minimap, events
   - Boot UI & invite observers

# SavedVariables Schema (AceDB)
Profile (per-character):
  profile.settings:
    - minLevel, maxLevel                : numeric level range defaults
    - activeFilter, activeMessage       : selection indices
    - compactMode, isCompact            : UI compact flags
    - minimap.hide                      : minimap icon visibility
    - showContextMenu, showAppMsgs      : UX toggles
    - debugMode                         : verbose logs
    - enableAutoSync, showWhispers      : behavior flags
    - antiSpam, antiSpamDays            : anti-spam controls
    - sendGuildGreeting, guildMessage   : guild greeting toggle/text
    - sendWhisperGreeting, whisperMessage : welcome whisper toggle/text
    - obeyBlockInvites                  : respect Blizzard invite blocks
    - messageList                       : personal message templates
    - keepOpen                          : ESC close behavior
    - inviteFormat                      : enum used by invite module
  profile.analytics                     : per-character analytics bucket

Global (account-wide):
  global.timeBetweenMessages            : message pacing (string seconds)
  global.showWhatsNew, showToolTips     : UI prefs
  global.compactSize                    : compact UI sizing
  global.ScanWaitTime                   : scan cadence
  global.zoneList                       : user-maintained invalid zones
  global.keybindings.scan/invite        : saved keybinds
Guild bucket (per clubID):
  guildInfo: { clubID, guildName, guildLink }
  gmSettings: GM-enforced toggles/messages
  settings  : shared guild defaults (non-enforced)
  isGuildLeader, guildLeaderToon, gmActive
  analytics, blackList, filterList, messageList, antiSpamList, blackListRemoved
  lastSync

-----------------------------------------------------------------------------]]--

local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local AC, ACD   = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB  = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

ns.core = {}
local core = ns.core

--- Initialize core defaults and AceDB base schemas (no I/O, no UI).
-- Call once on load; real boot happens in StartGuildRecruiter().
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

--- Fully start the addon for a specific guild clubID.
-- Performs DB attach, tables load, UI/options/minimap wiring, and invite boot.
-- @param clubID number|nil Guild club id from C_Club.GetGuildClubId()
function core:StartGuildRecruiter(clubID)
    if not clubID or not core.isEnabled then return end

    core:Init() -- ensure defaults present (idempotent)
    GR.clubID = clubID
    GR:RegisterChatCommand('rl', function() ReloadUI() end) -- quick reload

    -- Environment flags & pretty player name
    ns.fPlayerName = ns.code:cPlayer(GetUnitName('player', false), UnitClassBase('player'))
    ns.classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or false
    ns.cata    = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC or false
    ns.retail  = not ns.classic and not ns.cata

    -- Attach AceDB and possibly reset if version changed.
    if self:StartDatabase(clubID) then
        self.isEnabled = false
        GR:UnregisterAllEvents()
        ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['DISABLED'], ns.COLOR_DEFAULT, true)
        return
    end

    self:LoadTables()
    self:PerformRecordMaintenance()
    self:StartupGuild(clubID)

    -- Build options UI (the options table is provided by your settings module)
    ns.newSettingsMessage()                                    -- seed blank
    AC:RegisterOptionsTable(addonName, ns.guildRecuriterSettings) -- (sic) table name
    ns.addonOptions = ACD:AddToBlizOptions(addonName, 'Guild Recruiter')

    -- Shell/UI affordances
    self:StartSlashCommands()
    self:StartMiniMapIcon()
    ns.events:StartBaseEvents()
    ns.base:SetShown(true, true)

    -- Invite subsystem
    ns.invite:Init()
    ns.invite:GetMessages()
    ns.invite:RegisterInviteObservers()

    -- Courtesy warning if FGI is also running
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

    -- Final banners
    ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['ENABLED'], ns.COLOR_DEFAULT, true)
    if GR.isPreRelease then
        ns.code:fOut(L['BETA_INFORMATION']:gsub('VER', ns.code:cText('FFFF0000', strlower(GR.preReleaseType))), 'FFFFFF00', true)
    end
    ns.whatsnew:SetShown(true, true)
    self.isEnabled = true
end

--- Create/attach AceDB and bind convenience references under `ns`.
-- Also performs compatible DB reset when version requires.
-- @param clubID number
-- @return boolean wasReset True if a compatibility reset occurred
function core:StartDatabase(clubID)
    local wasReset = false
    local db = DB:New(GR.db, self.fileStructure) -- AceDB: profile/global roots

    local function resetDatabase()
        -- Wipe global namespace then reset current profile. Remove any stray
        -- extra profiles to avoid stale data after structural changes.
        db.global = db.global and table.wipe(db.global) or {}
        db:ResetProfile()
        for profileName in pairs(db.profiles) do
            db.profiles[profileName] = nil
        end
        wasReset = true
        db.global.dbVer = GR.dbVersion
        ns.code:fOut(L['DATABASE_RESET'], ns.COLOR_ERROR)
    end

    -- Example migration policy: reset if missing or behind and not equal to head.
    if not db.global.dbVer or (db.global.dbVer < 4 and db.global.dbVer ~= GR.dbVersion) then
        resetDatabase()
    end

    -- Ensure guild bucket exists
    if not db.global[clubID] then
        db.global[clubID] = self.guildFileStructure
    end

    -- Bind handy references (read/write) for the rest of the addon
    ns.p,        ns.g,        ns.guild      = db.profile, db.global, db.global[clubID]
    ns.pAnalytics, ns.gAnalytics            = ns.p.analytics, ns.guild.analytics
    ns.pSettings,  ns.gSettings             = ns.p.settings,  ns.guild.settings
    ns.guildInfo,  ns.gmSettings            = ns.guild.guildInfo, ns.guild.gmSettings
    ns.gFilterList                          = ns.guild.filterList

    -- Debug flags
    GR.debug = GR.isTesting or ns.pSettings.debugMode
    return wasReset
end

--- Inflate in-memory tables and load game-version dependent datasets.
function core:LoadTables()
    ns.tblBlackList, ns.antiSpamList = {}, {}

    -- Decompress persisted tables (no-op if empty or invalid)
    local blSuccess, tblBL = ns.code:decompressData(ns.guild.blackList)
    ns.tblBlackList = blSuccess and tblBL or {}

    local asSuccess, tblAS = ns.code:decompressData(ns.guild.antiSpamList)
    ns.tblAntiSpamList = asSuccess and tblAS or {}

    -- Data sets (classes/races/invalid zones) differ per branch
    if ns.retail then
        ns.races   = ns.ds:races_retail()
        ns.classes = ns.ds:classes_retail()
        ns.invalidZones = ns.ds:invalidZones_Retail()
    elseif ns.classic then
        ns.races   = ns.ds:races_classic()
        ns.classes = ns.ds:classes_classic()
        ns.invalidZones = ns.ds:invalidZones_Classic()
    elseif ns.cata then
        ns.races   = ns.ds:races_cata()
        ns.classes = ns.ds:classes_cata()
        ns.invalidZones = ns.ds:invalidZones_Cata()
    end

    ns.analytics:RetrieveSavedData()
end

--- Cleanup/migrate time-bounded records (e.g., anti-spam).
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
        for name, data in pairs(tbl) do
            if data and data.time then
                local age = currentTime - data.time
                if age >= days * 86400 then
                    tbl[name] = nil
                end
            end
        end
    end
    removeOldRecords(ns.tblAntiSpamList, ns.gmSettings.antiSpamDays)
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

        if not msg or msg == '' and not ns.base:IsShown() then
            return ns.base:SetShown(true)
        elseif msg == strlower(L['HELP']) then
            ns.code:fOut(L['SLASH_COMMANDS'], ns.COLOR_DEFAULT, true)
        elseif strlower(msg) == strlower(L['CONFIG']) then
            Settings.OpenToCategory('Guild Recruiter')
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
                Settings.OpenToCategory('Guild Recruiter')
            end
        end,
        OnTooltipShow = function()
            local title = code:cText('FFFFFF00', L['TITLE']..' (v'..GR.version..'):')
            local body  = code:cText('FFFFFFFF', L['MINIMAP_TOOLTIP'])

            local count = 0
            for _ in pairs(ns.tblAntiSpamList) do count = count + 1 end
            local antiSpam = ' |cFFFF0000'..count..'|r'

            count = 0
            for _ in pairs(ns.tblBlackList) do count = count + 1 end
            local blackList = ' |cFFFF0000'..count..'|r'

            body = body:gsub('%%AntiSpam', antiSpam):gsub('%%BlackList', blackList)
            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
        OnLeave = function() GameTooltip:Hide() end,
    })

    icon:Register('GR_Icon', iconData, ns.pSettings.minimap)
    self.minimapIcon = icon
end

--- Populate guild identity, GM state, and (Retail) derive clickable guild link.
-- Also resolves enforcement flags for non-GM users.
-- @param clubID number Guild club id
function core:StartupGuild(clubID)
    local guildName = GetGuildInfo('player')

    ns.guildInfo.clubID = clubID
    ns.guildInfo.guildName = guildName

    -- Attempt to build a clickable guild link (Retail only). Retry up to 10s.
    local function createGuildLink(retry)
        retry = retry + 1
        local club = clubID and ClubFinderGetCurrentClubListingInfo(clubID) or nil
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

    -- GM/leadership state & enforcement wiring
    ns.isGM = ns.guild.isGuildLeader or IsGuildLeader() or false
    if not ns.isGM then
        ns.gmActive = ns.guild.gmActive or false
        ns.obeyBlockInvites = ns.gmSettings.obeyBlockInvites and ns.gmSettings.obeyBlockInvites or ns.gSettings.obeyBlockInvites
        if not ns.gmSettings.antiSpam and not ns.pSettings.antiSpam then
            ns.code:fOut(L['NO_ANTI_SPAM'], ns.COLOR_ERROR)
        end
    elseif not ns.gmSettings.antiSpam then
        ns.code:fOut(L['NO_ANTI_SPAM'], ns.COLOR_ERROR)
    end

    -- Track/clear leader toon name
    if not ns.isGM then
        if GetUnitName('player', true) == ns.guild.guildLeaderToon then
            ns.guild.isGuildLeader = false
            ns.guild.guildLeaderToon = nil
            ns.code:fOut(ns.fPlayerName..' '..L['NO_LONGER_GUILD_LEADER'])
        end
    else
        ns.guild.isGuildLeader = true
        ns.guild.guildLeaderToon = GetUnitName('player', true)
    end

    -- Validate existing guildLink (may be stale across sessions/renames)
    ns.guildInfo.guildLink = (ns.guildInfo.guildLink and ns.guildInfo.guildLink ~= '') and ns.guildInfo.guildLink or nil
    if ns.guildInfo.guildLink and not strmatch(ns.guildInfo.guildLink, guildName) then
        ns.guildInfo.guildLink = nil
    end

    if not ns.classic then
        if not ns.guildInfo.guildLink or not strmatch(ns.guildInfo.guildLink, guildName) then
            createGuildLink(0)
        end
    end
end

--- Poll until we detect guild + invite permission, then call callback(clubID).
-- Retries every 1s up to ~30s. Prints user-facing reasons on failure.
-- @param count number (internal) retry counter
-- @param callback function|nil called with clubID (number) or nil on timeout
-- @return number|nil clubID when available
function core:CheckIfInGuild(count, callback)
    count = count or 0
    local clubID = C_Club.GetGuildClubId() or nil

    if clubID and CanGuildInvite() then
        self.isEnabled = true
        if callback then callback(clubID) end
        return clubID
    elseif count >= 30 then
        -- Timed out: show hints based on current state
        self.isEnabled = false
        ns.code:cOut(L['TITLE']..' '..GR.versionOut..' '..L['DISABLED'])
        if IsInGuild() and not CanGuildInvite() then
            ns.code:cOut(L['CANNOT_INVITE'])
        else
            ns.code:cOut(L['NOT_IN_GUILD'])
            ns.code:cOut(L['NOT_IN_GUILD_LINE1'])
        end
        if callback then callback(nil) end
        return
    elseif not CanGuildInvite() or not IsInGuild() or not clubID or not GetGuildInfo('player') then
        C_Timer.After(1, function() self:CheckIfInGuild(count + 1, callback) end)
    end
end

-- Event bootstrap: wait for login before probing guild state.
local function eventsPLAYER_LOGIN()
    GR:UnregisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)
    core:CheckIfInGuild(0, function(clubID)
        if clubID then core:StartGuildRecruiter(clubID) end
    end)
end
GR:RegisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)

--- Notify AceConfig that our options table changed (e.g., labels/values).
function core:NotifySettingsUpdate()
    AceConfigRegistry:NotifyChange(addonName)
end

-- Seed defaults immediately so other files can read `core.fileStructure`, etc.
core:Init()
