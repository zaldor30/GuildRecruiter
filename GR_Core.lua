local _, ns = ... -- Namespace (myaddon, namespace)

-- Application Initialization
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

ns.core = {}
local core = ns.core

-- *Blizzard Initialization Called Function
function GR:OnInitialize()
    if core.isEnabled then return end -- Prevents double initialization

    GR:RegisterChatCommand('rl', function() ReloadUI() end) -- Set the /rl slash command to reload the UI

    local function checkIfInGuild(count) -- Check if the player is in a guild
        if not count then return end

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
        elseif clubID then
            core.isEnabled = true
            core:StartGuildRecruiter(clubID) end
    end

    checkIfInGuild(0)
end

function core:Init()
    self.hasGM = false
    self.isEnabled = false
    self.fullyStarted = false
    self.ignoreAutoSync = false
    self.obeyBlockInvites = true

    self.minimapIcon = nil

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
                showAppMsgs = true, -- Show Application Messages
                enableAutoSync = true, -- Disable Auto Sync
                showWhispers = true, -- Show Whispers
            },
            analytics = {}
        },
        global = {
            showWhatsNew = true,
            guildInfo = {},
            gmSettings = {
                -- GM Settings
                forceObey = true,
                obeyBlockInvites = true, -- Obey Block Invites
                forceAntiSpam = true,
                antiSpam = false,
                antiSpamDays = 7,
                forceSendGuildGreeting = false,
                sendGuildGreeting = false,
                forceGuildMessage = true,
                guildMessage = L['DEFAULT_GUILD_WELCOME'],
                forceSendWhisper = false,
                sendWhsiper = false,
                forceWhisperMessage = true,
                whisperMessage = '',
                forceMessageList = false,
                messageList = {},
                guildLeaderToon = nil,
            },
            settings = {
                -- General Settings
                obeyBlockInvites = true, -- Obey Block Invites
                showToolTips = true, -- Show Tool Tips
                showConsoleMessages = false, -- Show Console Messages
                -- Invite Settings
                antiSpam = true,
                antiSpamDays = 7,
                sendGuildGreeting = false,
                guildMessage = L['DEFAULT_GUILD_WELCOME'],
                sendWhsiper = false,
                whisperMessage = '',
                scanWaitTime = 6,
                -- Messages
                messageList = {},
                keepOpen = false,
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

    self:PerformDatabaseMaintenance() -- Perform Database Maintenance

    -- Other Variables Declaration
    ns.gFilterList = ns.g.filterList or {} -- Global Filter List
    ns.gAnalytics = ns.g.analytics or {} -- Global Analytics
    ns.pAnalytics = ns.p.analytics or {} -- Profile Analytics
    ns.analytics:Start()

    ns.invite:GetWelcomeMessages() -- Get the welcome messages
    GR.debug = ns.pSettings.debugMode or false -- Set the debug mode

    local profiles, _ = db:GetProfiles()
    if not IsGuildLeader() then
        for _, profile in pairs(profiles) do
            if profile:find(UnitName('player')) then
                if IsGuildLeader() then
                    ns.guildInfo.isGuildLeader = true
                    ns.guildInfo.guildLeaderToon = GetUnitName('player', true)
                elseif not IsGuildLeader() and ns.guildInfo.guildLeaderToon == UnitName('player') then
                    ns.guildInfo.isGuildLeader = false
                    ns.guildInfo.guildLeaderToon = nil
                    ns.gSettings.overrideGM = false
                    ns.code:dOut(GetUnitName('player', true)..' is no longer the Guild Leader')
                elseif ns.guildInfo.guildLeaderToon ~= GetUnitName('player', true) then
                    ns.guildInfo.isGuildLeader = ns.guildInfo.isGuildLeader
                end
                break
            end
        end
    else
        ns.guildInfo.isGuildLeader = true
        ns.guildInfo.guildLeaderToon = GetUnitName('player', true)
    end

    self.hasGM = ns.guildInfo.isGuildLeader
    if self.hasGM and ns.gmSettings.forceObey then self.obeyBlockInvites = ns.gmSettings.obeyBlockInvites or false
    elseif ns.pSettings.obeyBlockInvites then self.obeyBlockInvites = ns.pSettings.obeyBlockInvites or false end
end
function core:PerformDatabaseMaintenance()
    if ns.gSettings.antiSpam == nil then ns.gSettings.antiSpam = true end
    if ns.gmSettings.antiSpam == nil then ns.gmSettings.antiSpam = true end

    if not ns.global.dbVersion or ns.global.dbVersion ~= GR.dbVersion then
        local oldVer = tonumber(ns.global.dbVersion) or 1
        -- Before 3.1
        ns.global.dbVersion = GR.dbVersion
        if oldVer < 3.1 then
            if ns.gmSettings.obeyBlockInvites == nil then ns.gmSettings.obeyBlockInvites = true end
            if ns.gSettings.obeyBlockInvites == nil then ns.gSettings.obeyBlockInvites = true end

            -- Fix for old DB settings
            ns.gmSettings.sendGuildGreeting = ns.gmSettings.sendGuildGreeting or ns.gmSettings.sendWelcome
            ns.gmSettings.sendWhsiper = ns.gmSettings.sendWhsiper or ns.gmSettings.sendGreeting
            ns.gmSettings.sendGreeting, ns.gmSettings.sendWelcome = nil, nil

            ns.gSettings.sendGuildGreeting = ns.gSettings.sendGuildGreeting or ns.gSettings.sendWelcome
            ns.gSettings.sendWhsiper = ns.gSettings.sendWhsiper or ns.gSettings.sendGreeting

            -- Change Message Records
            if ns.gSettings.welcomeMessage and ns.gSettings.welcomeMessage ~= '' then
                ns.gSettings.guildMessage = ns.gSettings.welcomeMessage and ns.gSettings.welcomeMessage or ns.gSettings.guildMessage
                ns.gSettings.welcomeMessage = nil
            end
            if ns.gmSettings.welcomeMessage and ns.gmSettings.welcomeMessage ~= '' then
                ns.gmSettings.guildMessage = ns.gmSettings.welcomeMessage and ns.gmSettings.welcomeMessage or ns.gmSettings.guildMessage
                ns.gmSettings.welcomeMessage = nil
            end
            if ns.gSettings.greetingMessage and ns.gSettings.greetingMessage ~= '' then
                ns.gSettings.whisperMessage = ns.gSettings.greetingMessage or nil
                ns.gSettings.greetingMessage = nil
            end
            if ns.gmSettings.greetingMessage and ns.gmSettings.greetingMessage ~= '' then
                ns.gmSettings.whisperMessage = ns.gmSettings.greetingMessage or nil
                ns.gmSettings.greetingMessage = nil
            end
            if ns.gSettings.sendWhisperGreeting or ns.gmSettings.sendWhisperGreeting then
                ns.gSettings.sendWhsiper = ns.gSettings.sendWhisperGreeting or ns.gSettings.sendWhsiper
                ns.gmSettings.sendWhsiper = ns.gmSettings.sendWhisperGreeting or ns.gmSettings.sendWhsiper
                ns.gSettings.sendWhisperGreeting = nil
                ns.gmSettings.sendWhisperGreeting = nil
            end

            -- Combine Message Lists
            local tblDescHold = {}
            local tblMsgs, tblGM, tblPlayer = {}, ns.gmSettings.messageList or {}, ns.gSettings.messageList or {}
            for _, v in pairs(tblGM) do
                if not tblDescHold[v.desc] then
                    tinsert(tblMsgs, {
                        desc = v.desc,
                        message = v.message,
                        type = 'GM',
                    })
                    tblDescHold[v.desc] = true
                end
            end
            for _, v in pairs(tblPlayer) do
                if not tblDescHold[v.desc] then
                    tinsert(tblMsgs, {
                        desc = v.desc,
                        message = v.message,
                        type = 'PLAYER',
                    })
                    tblDescHold[v.desc] = true
                end
            end
            ns.gSettings.messageList = tblMsgs or {}
            ns.gmSettings.messageList, ns.pSettings.messageList = nil, nil
        end

        if oldVer >= 3.1 then
            for k, v in pairs(ns.gSettings.messageList) do
                if v.type == 'GM' then
                    ns.gSettings.messageList[k] = nil
                    ns.gmSettings.messageList[k] = v
                    ns.gmSettings.messageList[k].gmSync = true
                end
            end
        end
    end
end
function core:StartGuildSetup(clubID) -- Get Guild Info and prep database
    if not clubID then return end

    ns.guildInfo.clubID = clubID
    ns.guildInfo.guildName = GetGuildInfo('player')

    local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
    if not ns.guildInfo.guildLink and club then
        --"|cffffd200|HclubFinder:ClubFinder-1-246204-77-95938602|h[Guild: Shock Value]|h|r"
        local guildLink = "|cffffd200|HclubFinder:"..club.clubFinderGUID.."|h[Guild: "..club.name.."]|h|r"
        ns.guildInfo.guildLink = guildLink or nil
    end
end
function core:PerformRecordMaintenance() -- Perform Record Maintenance
    core:CreateBLandAntiSpamTables() -- Create the black list and anti-spam tables

    -- ToDo: Remove old deleted black list records
    -- Decode Black List
    local blSuccess, tblBL = ns.code:decompressData(ns.g.blackList or {})
    if blSuccess then ns.tblBlackList = tblBL or {}
    else
        ns.tblBlackList = {}
        ns.code:dOut('There was an issue decoding the Black List (Record Maint)') end

    -- Decode Anti-Spam List
    local asSuccess, tblAS = ns.code:decompressData(ns.g.antiSpamList or {})
    if asSuccess then ns.tblAntiSpamList = tblAS or {}
    else
        ns.tblAntiSpamList = {}
        ns.code:dOut('There was an issue decoding the Anti-Spam List (Record Maint)') end

    -- Anti-Spam List Maintenance
    local antiSpamRemoved, blackListRemoved = 0, 0
    local antiSpamDays = (ns.gmSettings.antiSpam and ns.gmSettings.antiSpamDays) and ns.gmSettings.antiSpamDays or nil
    antiSpamDays = (not ns.gmSettings.antiSpam and (ns.gSettings.antiSpam and ns.gSettings.antiSpamDays)) and ns.gSettings.antiSpamDays or 7

    local antiSpamExpire = C_DateAndTime.GetServerTimeLocal() - (antiSpamDays * SECONDS_IN_A_DAY)
    for k, r in pairs(ns.tblAntiSpamList or {}) do
        if not r.date then
            ns.tblAntiSpamList[k] = nil
            antiSpamRemoved = antiSpamRemoved + 1
        elseif r.date < antiSpamExpire then
            ns.tblAntiSpamList[k] = nil
            antiSpamRemoved = antiSpamRemoved + 1
        end
    end

    -- Report to console
    if antiSpamRemoved > 0 then
        ns.code:fOut('Anti-Spam Records Removed: '..antiSpamRemoved, GRColor) end
    if blackListRemoved > 0 then
        ns.code:fOut('Black List Records Removed: '..blackListRemoved, GRColor) end
end
function core:StartSlashCommands() -- Start Slash Commands
    local function slashCommand(msg)
        msg = strlower(msg:trim())

        if not msg or msg == '' and not ns.win.home:IsShown() then return ns.win.home:SetShown(true)
        elseif msg == L['HELP'] then ns.code:fOut(L['SLASH_COMMANDS'], GRColor, true)
        elseif strlower(msg) == L['CONFIG'] then Settings.OpenToCategory('Guild Recruiter')
        elseif strlower(msg):match(tostring(L['BLACKLIST_ICON'])) then
            msg = strlower(msg):gsub(tostring(L['BLACKLIST_ICON']), ''):trim()
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
            if button == 'LeftButton' and IsShiftKeyDown() and not ns.win.home:IsShown() then ns.win.scanner:SetShown(true)
            elseif button == 'LeftButton' and not ns.win.home:IsShown() then ns.win.home:SetShown(true)
            elseif button == 'RightButton' then Settings.OpenToCategory('Guild Recruiter') end
        end,
        OnTooltipShow = function(GameTooltip)
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
function core:StartBaseEvents()
    -- Chat Message Response Routine
    local function CHAT_MSG_SYSTEM(...) ns.observer:Notify('CHAT_MSG_SYSTEM', ...) end
    ns.events:RegisterEvent('CHAT_MSG_SYSTEM', CHAT_MSG_SYSTEM)

    -- Saves the ns.tblBlackList and ns.antiSpamList tables on logout
    ns.events:RegisterEvent('PLAYER_LOGOUT', function() ns.code:saveTables() end)
end
function core:CreateBLandAntiSpamTables()
    ns.tblBlackList, ns.antiSpamList = {}, {}

    local blSuccess, tblBL = ns.code:decompressData(ns.g.blackList or {})
    ns.tblBlackList = blSuccess and tblBL or {}

    local asSuccess, tblAS = ns.code:decompressData(ns.g.antiSpamList or {})
    ns.tblAntiSpamList = asSuccess and tblAS or {}
end
function core:StartGuildRecruiter(clubID) -- Start Guild Recruiter
    if not self.isEnabled then return end

    ns.code:dOut('Starting Guild Recruiter')

    ns.code.fPlayerName = ns.code:cPlayer(GetUnitName('player', false), select(2, UnitClass("player"))) -- Set the player name

    self:StartDatabase(clubID) -- Start the database
    self:StartGuildSetup(clubID) -- Start the guild setup

    -- Setup Tables
    ns.tblRaces, ns.tblClasses = ns.ds:races(), ns.ds:classes()

    AC:RegisterOptionsTable('GuildRecruiter', ns.addonSettings) -- Register the options table
    ns.addonOptions = ACD:AddToBlizOptions('GuildRecruiter', 'Guild Recruiter') -- Add the options to the Blizzard options
    self.iAmGM = (ns.guildInfo.isGuildLeader or ns.guildInfo.guildLeaderToon == GetUnitName('player', true)) or false
    ns.gSettings.overrideGM = self.iAmGM and ns.gSettings.overrideGM or false

    core:PerformRecordMaintenance() -- Perform record maintenance
    core:StartSlashCommands() -- Start the slash commands
    core:StartMiniMapIcon() -- Start the mini map icon

    core:StartBaseEvents() -- Start the base events
    ns.win.base:StartUp() -- Show the base window
    ns.win.base:SetShown(false) -- Hide the base window
    self.fullyStarted = true


    --* Setup Tables
    ns.tblInvalidZones = ns.ds:invalidZones()
    ns.tblRacesSortedByName = ns.code:sortTableByField(ns.tblRaces, 'name')
    ns.tblClassesSortedByName = ns.code:sortTableByField(ns.tblClasses, 'name')

    ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['IS_ENABLED'], GRColor, true)
    if not ns.guildInfo.guildLink then
        ns.code:fOut(L['NO_GUILD_LINK'], GRColor)
        ns.code:fOut(ns.code:cText('FFFF0000', L['NO_GUILD_LINK'], GRColor))
    end

    if GR.isPreRelease then
        ns.code:fOut(L['BETA_INFORMATION']:gsub('VER', ns.code:cText('FFFF0000', strlower(GR.preReleaseType))), 'FFFFFF00', true)
     end

     --print('hasGM:'..ns.core.hasGM)
    --print('Guild Greeting:',ns.gmSettings.sendGuildGreeting, 'Guild Message:', ns.gmSettings.guildMessage)

    if type(ns.global.showWhatsNew) ~= 'boolean' then
        ns.global.showWhatsNew = true
        ns.win.whatsnew.startUpWhatsNew = true
        ns.code:fOut(L['FIRST_TIME_INFO'], GRColor, true) -- Show the first time info
        C_Timer.After(3, function() ns.win.whatsnew:SetShown(true) end) -- Show the what's new window
    elseif ns.global.showWhatsNew and ns.global.currentVersion ~= GR.version then
        ns.win.whatsnew.startUpWhatsNew = true
        C_Timer.After(3, function() ns.win.whatsnew:SetShown(true) end) -- Show the what's new window
    elseif ns.global.currentVersion ~= GR.version then ns.code:fOut(L['NEW_VERSION_INFO'], GRColor, true) end

    local function OnCommReceived(prefix, message, distribution, sender)
        if not ns.core.isEnabled then return
        elseif sender == UnitName('player') then return
        elseif prefix ~= GR.commPrefix then return
        elseif distribution ~= 'GUILD' and distribution ~= 'WHISPER' then return end

        ns.sync:CommReceived(message, sender)
    end
    GR:RegisterComm(GR.commPrefix, OnCommReceived)

    --* Start Auto Sync
    if type(ns.pSettings.enableAutoSync) ~= 'boolean' then ns.pSettings.enableAutoSync = true end
    if ns.pSettings.enableAutoSync then
        C_Timer.After(15, function() ns.sync:StartSyncRoutine(1) end)
    end
end

--* Manual update of settings data
function core:NotifySettingsUpdate()
    AceConfigRegistry:NotifyChange("GuildRecruiter")
end
core:Init()

--* Hook /ginvite command
-- Create a custom dropdown frame for the additional options
local customDropdown = CreateFrame("Frame", "CustomChatDropdown", UIParent, "UIDropDownMenuTemplate")
-- Function to initialize the custom dropdown menu
local function InitializeDropdownMenu(self, level)
    if not core.isEnabled then return
    elseif not self.chatPlayerName or not ns.pSettings.showContextMenu then return end
    local cPlayerName = ns.code:cText(GRColor, self.chatPlayerName)
    if level == 1 then
        local name = self.chatPlayerName:find('-') and self.chatPlayerName or self.chatPlayerName..'-'..GetRealmName() -- Add realm name if not present
        local info = UIDropDownMenu_CreateInfo()
        info.text = cPlayerName..'\n'..ns.code:cText('FFFFFF00', L['INVITE_NO_MESSAGES_MENU'])
        info.notCheckable = true
        info.fontObject = GameFontNormalOutline
        info.func = function()
            ns.invite:SendManualInvite(self.chatPlayerName, select(2, UnitClass(self.chatPlayerName)), false, false, true)
        end
        UIDropDownMenu_AddButton(info, level)

        -- Separator for spacing
        info = UIDropDownMenu_CreateInfo()
        info.disabled = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.text = cPlayerName..'\n'..ns.code:cText('FFFFFF00', L['INVITE_MESSAGES_MENU'])
        info.notCheckable = true
        info.fontObject = GameFontNormalOutline
        info.func = function()
            ns.invite:SendManualInvite(self.chatPlayerName, select(2, UnitClass(self.chatPlayerName)), true, true, true)
        end
        UIDropDownMenu_AddButton(info, level)

        local activeMessage = ns.pSettings.activeMessage or nil
        local msg = activeMessage and ns.gSettings.messageList[activeMessage] or nil
        if msg then
            -- Separator for spacing
            info = UIDropDownMenu_CreateInfo()
            info.disabled = true
            info.notCheckable = true
            info.fontObject = GameFontNormalOutline
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = cPlayerName..'\n'..ns.code:cText('FFFFFF00', L['INVITE_MESSAGE_ONLY'])
            info.notCheckable = true
            info.fontObject = GameFontNormalOutline
            info.func = function()
                ns.invite:SendMessage(self.chatPlayerName, self.chatPlayerName:gsub('-', ''), msg.message)
            end
            UIDropDownMenu_AddButton(info, level)
        end

        if not ns.blackList:IsOnBlackList(name) then
            -- Separator for spacing
            info = UIDropDownMenu_CreateInfo()
            info.disabled = true
            info.notCheckable = true
            info.fontObject = GameFontNormalOutline
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = cPlayerName..'\n'..L['BLACKLIST']
            info.notCheckable = true
            info.fontObject = GameFontNormalOutline
            info.func = function()
                ns.blackList:BlackListReasonPrompt(self.chatPlayerName)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
-- Function to position the custom dropdown menu
local function PositionCustomDropdown()
    local systemDropdown = DropDownList1
    if not systemDropdown then
        return 40, 0
    end

    local systemDropdownWidth = systemDropdown:GetWidth()
    local customDropdownWidth = customDropdown:GetWidth()
    local systemDropdownX, systemDropdownY = systemDropdown:GetCenter()
    local screenWidth = GetScreenWidth()

    -- Ensure systemDropdownX and systemDropdownY have valid values
    if not systemDropdownX or not systemDropdownY then
        return 200, 0
    end

    local xOffset = 0
    local yOffset = 0

    -- Calculate the new position, ensuring it stays within the screen bounds
    if (systemDropdownX + systemDropdownWidth / 2 + customDropdownWidth > screenWidth) then
        xOffset = -customDropdownWidth - 10
    else
        xOffset = systemDropdownWidth - 20
    end

    return xOffset, 0 -- Keep yOffset as 0 since we want the menus aligned vertically
end

-- Original SetItemRef function
local originalSetItemRef = SetItemRef

-- Override SetItemRef to capture right-clicks on player names
SetItemRef = function(link, text, button, chatFrame)
    if button == "RightButton" then
        local type, name = strsplit(":", link)
        if type == "player" then
            -- Store the clicked player name in the dropdown frame
            customDropdown.chatPlayerName = name
            -- Show the system context menu
            originalSetItemRef(link, text, button, chatFrame)
            -- Calculate the position for the custom dropdown menu
            local xOffset, yOffset = PositionCustomDropdown()
                -- Initialize and show the custom dropdown menu
            UIDropDownMenu_Initialize(customDropdown, InitializeDropdownMenu, "MENU")
            ToggleDropDownMenu(1, nil, customDropdown, "cursor", 180, 100)
            return
        end
    end
    originalSetItemRef(link, text, button, chatFrame)
end