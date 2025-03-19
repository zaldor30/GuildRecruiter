local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

ns.core = {}
local core = ns.core

function core:Init()
    self.isEnabled = false
    self.fullyStarted = false
    self.ignoreAutoSync = false
    self.obeyBlockInvites = true

    self.minimapIcon = nil

    self.fileStructure = {
        profile = {
            settings = {
                -- Starting Levels
                minLevel = ns.MAX_CHARACTER_LEVEL - 5,
                maxLevel = ns.MAX_CHARACTER_LEVEL,
                -- General Settings
                activeFilter = 9999,
                activeMessage = nil,
                compactMode = false, -- Scanner Compact Mode
                minimap = { hide = false }, -- Mini Map Icon
                showContextMenu = true, -- Show Context Menu
                debugMode = false, -- Debug Mode
                showAppMsgs = true, -- Show Application Messages
                enableAutoSync = true, -- Disable Auto Sync
                showWhispers = true, -- Show Whispers
                antiSpam = true,
                antiSpamDays = 7,
                sendGuildGreeting = true,
                guildMessage = L['DEFAULT_GUILD_WELCOME'],
                sendWhisperGreeting = false,
                obeyBlockInvites = true, -- Obey Block Invites
                messageList = {},
                keepOpen = false,
                inviteFormat = 2,
                isCompact = false,
                whisperMessage = '',
                -- Add filter settings initialization
                classFilters = {},
                raceFilters = {},
            },
            analytics = {},
        },
        global = {
            timeBetweenMessages = "0.2",
            showWhatsNew = true,
            showToolTips = true, -- Show Tool Tips
            compactSize = 1,
            ScanWaitTime = 5,
            zoneList = {},
            keybindings = {
                scan = 'CTRL-SHIFT-S',
                invite = 'CTRL-SHIFT-I',
            },
        }
    }
    self.guildFileStructure = {
        guildInfo = {
            clubID = nil,
            guildName = '',
            guildLink = '',
        },
        gmSettings = {
            -- GM Settings
            forceMessageList = false,
            forceSendWhisper = false,
            forceInviteMessage = false,
            forceWhisperMessage = false, -- Force Invite Message
            forceSendGuildGreeting = false,
            obeyBlockInvites = true, -- Obey Block Invites
            antiSpam = true,
            antiSpamDays = 7,
            sendGuildGreeting = true,
            guildMessage = L['DEFAULT_GUILD_WELCOME'],
            sendWhisperGreeting = false,
            whisperMessage = '',
        },
        settings = {
            -- General Settings
            showConsoleMessages = false, -- Show Console Messages
            -- Invite Settings
            antiSpam = true,
            antiSpamDays = 7,
            sendGuildGreeting = true,
            guildMessage = L['DEFAULT_GUILD_WELCOME'],
            sendWhisperGreeting = false,
            whisperMessage = '',
            -- Messages
            messageList = {},
        },
        isGuildLeader = false,
        guildLeaderToon = nil,
        gmActive = false,
        analytics = {},
        blackList = {},
        filterList = {},
        antiSpamList = {},
        blackListRemoved = {},
        lastSync = {}, -- Who, Date
    }
end
function core:StartGuildRecruiter(clubID)
    if not clubID or not core.isEnabled then return end

    core:Init()
    GR.clubID = clubID
    GR:RegisterChatCommand('rl', function() ReloadUI() end) -- Set the /rl slash command to reload the UI

    ns.fPlayerName = ns.code:cPlayer(GetUnitName('player', false), UnitClassBase('player')) -- Set the player name
    ns.classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or false
    ns.cata = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC or false
    ns.retail = not ns.classic and not ns.cata

    if self:StartDatabase(clubID) then
        self.isEnabled = false
        GR:UnregisterAllEvents()
        ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['DISABLED'], ns.COLOR_DEFAULT, true)
        return
    end
    
    -- Initialize filter settings if they don't exist
    if not ns.pSettings.classFilters then
        ns.pSettings.classFilters = {}
        -- Default to all classes enabled
        for classFile, _ in pairs(ns.ds:GetClassList()) do
            ns.pSettings.classFilters[classFile] = true
        end
    end
    
    if not ns.pSettings.raceFilters then
        ns.pSettings.raceFilters = {}
        -- Default to all races enabled
        for raceName, _ in pairs(ns.ds:GetRaceList()) do
            ns.pSettings.raceFilters[raceName] = true
        end
    end

    self:LoadTables()
    self:PerformRecordMaintenance()
    self:StartupGuild(clubID)

    ns.newSettingsMessage() -- Set blank message record for settings
    AC:RegisterOptionsTable(addonName, ns.guildRecuriterSettings) -- Register the options table
    ns.addonOptions = ACD:AddToBlizOptions(addonName, 'Guild Recruiter') -- Add the options to the Blizzard options

    --ns.invite:GetWelcomeMessages() -- Get the welcome messages
    self:StartSlashCommands()
    self:StartMiniMapIcon()
    ns.events:StartBaseEvents() -- Start the base events

    ns.base:SetShown(true, true)

    ns.invite:Init()
    ns.invite:GetMessages()
    ns.invite:RegisterInviteObservers()

    local function checkForFGI(retry)
        retry = retry + 1
        local isFGILoaded = C_AddOns.IsAddOnLoaded('FastGuildInvite')
        if isFGILoaded then ns.code:fOut(L['FGI_LOADED'], ns.COLOR_ERROR) return
        elseif retry > 5 then return
        elseif retry <= 5 then C_Timer.After(1, function() checkForFGI(retry + 1) end) end
    end
    checkForFGI(0)

    ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['ENABLED'], ns.COLOR_DEFAULT, true)
    if GR.isPreRelease then
        ns.code:fOut(L['BETA_INFORMATION']:gsub('VER', ns.code:cText('FFFF0000', strlower(GR.preReleaseType))), 'FFFFFF00', true)
    end
    ns.whatsnew:SetShown(true, true)
    self.isEnabled = true
end
function core:StartDatabase(clubID)
    local wasReset = false
    local db = DB:New(GR.db, self.fileStructure) -- Initialize the database

    local function resetDatabase()
        db.global = db.global and table.wipe(db.global) or {} -- Reset the global database
        db:ResetProfile() -- Reset current profile

        -- Optionally, delete all other profiles by iterating through them
        for profileName in pairs(db.profiles) do
            db.profiles[profileName] = nil  -- Delete profile data
        end

        wasReset = true
        db.global.dbVer = GR.dbVersion -- Set the database version
        ns.code:fOut(L['DATABASE_RESET'], ns.COLOR_ERROR)
    end

    if not db.global.dbVer or (db.global.dbVer < 4 and db.global.dbVer ~= GR.dbVersion) then resetDatabase() end -- Reset the database if the version is different

    if not db.global[clubID] then
        db.global[clubID] = self.guildFileStructure -- Set the guild defaults
    end

    ns.p, ns.g, ns.guild = db.profile, db.global, db.global[clubID] -- Set the profile and global database
    ns.pAnalytics, ns.gAnalytics = ns.p.analytics, ns.guild.analytics -- Set the analytics database
    ns.pSettings, ns.gSettings = ns.p.settings, ns.guild.settings -- Set the settings database
    ns.guildInfo, ns.gmSettings = ns.guild.guildInfo, ns.guild.gmSettings -- Set the guild info and GM settings database
    ns.gFilterList = ns.guild.filterList -- Set the filter list database

    GR.debug = GR.isTesting or ns.pSettings.debugMode -- Set the debug modes
    return wasReset
end
function core:LoadTables()
    ns.tblBlackList, ns.antiSpamList = {}, {}

    local blSuccess, tblBL = ns.code:decompressData(ns.guild.blackList)
    ns.tblBlackList = blSuccess and tblBL or {}

    local asSuccess, tblAS = ns.code:decompressData(ns.guild.antiSpamList)
    ns.tblAntiSpamList = asSuccess and tblAS or {}

    --* Load Class/Race and Invalid Zones Table
    if ns.retail then
        ns.races = ns.ds:races_retail()
        ns.classes = ns.ds:classes_retail()
        ns.invalidZones = ns.ds:invalidZones_Retail()
    elseif ns.classic then
        ns.races = ns.ds:races_classic()
        ns.classes = ns.ds:classes_classic()
        ns.invalidZones = ns.ds:invalidZones_Classic()
    elseif ns.cata then
        ns.races = ns.ds:races_cata()
        ns.classes = ns.ds:classes_cata()
        ns.invalidZones = ns.ds:invalidZones_Cata()
    end

    ns.analytics:RetrieveSavedData()
end
function core:PerformRecordMaintenance()
    --* Move Player Message List to GM Message List
    if ns.isGM and #ns.pSettings.messageList > 0 then
        for _, v in pairs(ns.pSettings.messageList) do
            table.insert(ns.gmSettings.messageList, v)
        end
        ns.pSettings.messageList = {}
    end

    -- Remove Old Records
    local function removeOldRecords(tbl, days)
        local currentTime = time()
        for name, data in pairs(tbl) do
            if data and data.time then
                local timeDiff = currentTime - data.time
                if timeDiff >= days * 86400 then
                    tbl[name] = nil
                end
            end
        end
    end

    removeOldRecords(ns.tblAntiSpamList, ns.gmSettings.antiSpamDays)
end
function core:StartSlashCommands() -- Start Slash Commands
    local function slashCommand(msg)
        msg = strlower(msg:trim())

        if not msg or msg == '' and not ns.base:IsShown() then return ns.base:SetShown(true)
        elseif msg == strlower(L['HELP']) then ns.code:fOut(L['SLASH_COMMANDS'], ns.COLOR_DEFAULT, true)
        elseif strlower(msg) == strlower(L['CONFIG']) then Settings.OpenToCategory('Guild Recruiter')
        elseif strlower(msg):match(strlower(L['BLACKLIST'])) then
            msg = strlower(msg):gsub(strlower(L['BLACKLIST']), ''):trim()
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
        icon = ns.GR_ICON,
        OnClick = function(_, button)
            if button == 'LeftButton' and IsShiftKeyDown() then
                if not ns.base:IsShown() then ns.base:SetShown(true) end
                if not ns.scanner:IsShown() then ns.base:buttonAction('OPEN_SCANNER') end
            elseif button == 'LeftButton' then ns.base:SetShown(not ns.base:IsShown())
            elseif button == 'RightButton' then Settings.OpenToCategory('Guild Recruiter') end
        end,
        OnTooltipShow = function()
            local title = code:cText('FFFFFF00', L['TITLE']..' (v'..GR.version..'):')
            local body = code:cText('FFFFFFFF', L['MINIMAP_TOOLTIP'])

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

--* core Support Functions
function core:StartupGuild(clubID)
    local guildName = GetGuildInfo('player')

    ns.guildInfo.clubID = clubID
    ns.guildInfo.guildName = guildName

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
        else C_Timer.After(1, function() createGuildLink(retry) end) end
    end

    ns.isGM = ns.guild.isGuildLeader or IsGuildLeader() or false
    if not ns.isGM then
        ns.gmActive = ns.guild.gmActive or false
        ns.obeyBlockInvites = ns.gmSettings.obeyBlockInvites and ns.gmSettings.obeyBlockInvites or ns.gSettings.obeyBlockInvites
        if not ns.gmSettings.antiSpam and not ns.pSettings.antiSpam then ns.code:fOut(L['NO_ANTI_SPAM'], ns.COLOR_ERROR) end
    elseif not ns.gmSettings.antiSpam then ns.code:fOut(L['NO_ANTI_SPAM'], ns.COLOR_ERROR) end

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

    ns.guildInfo.guildLink = (ns.guildInfo.guildLink and ns.guildInfo.guildLink ~= '') and ns.guildInfo.guildLink or nil
    if ns.guildInfo.guildLink and not strmatch(ns.guildInfo.guildLink, guildName) then ns.guildInfo.guildLink = nil end

    if not ns.classic then
        if not ns.guildInfo.guildLink or not strmatch(ns.guildInfo.guildLink, guildName) then createGuildLink(0) end
    end
end
function core:CheckIfInGuild(count, callback)
    count = count or 0

    local clubID = C_Club.GetGuildClubId() or nil -- Get the guild club ID (Guild ID)

    if clubID and CanGuildInvite() then
        self.isEnabled = true
        if callback then callback(clubID) end
        return clubID
    elseif count >= 30 then -- If the player is not in a guild after 60 attempts, then return
        self.isEnabled = false

        ns.code:cOut(L['TITLE']..' '..GR.versionOut..' '..L['DISABLED'])
        if IsInGuild() and not CanGuildInvite() then ns.code:cOut(L['CANNOT_INVITE'])
        else
            ns.code:cOut(L['NOT_IN_GUILD'])
            ns.code:cOut(L['NOT_IN_GUILD_LINE1'])
        end
        if callback then callback(nil) end
        return
    elseif not CanGuildInvite() or not IsInGuild() or not clubID or not GetGuildInfo('player') then -- If the player is not in a guild, then check again in 1 second
        C_Timer.After(1, function() self:CheckIfInGuild(count + 1, callback) end)
    end
end
--? End of core Support Functions

--* Start of Guild Recruiter
local function eventsPLAYER_LOGIN()
    GR:UnregisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)

    core:CheckIfInGuild(0, function(clubID)
        if clubID then core:StartGuildRecruiter(clubID) end
    end)
end
GR:RegisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)
--? End of Guild Recruiter

--* Manual update of settings data
function core:NotifySettingsUpdate()
    AceConfigRegistry:NotifyChange(addonName)
end
core:Init()
