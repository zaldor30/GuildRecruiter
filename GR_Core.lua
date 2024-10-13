local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

ns.core = {}
local core = ns.core

function core:Init()
    self.hasGM = false
    self.isEnabled = false
    self.fullyStarted = false
    self.ignoreAutoSync = false
    self.obeyBlockInvites = true

    self.minimapIcon = nil

    self.fileStructure = {
        profile = {
            settings = {
                -- Starting Levels
                minLevel = ns.MAX_CHARACTER_LEVEL - 4,
                maxLevel = ns.MAX_CHARACTER_LEVEL,
                -- General Settings
                compactMode = false, -- Scanner Compact Mode
                minimap = { hide = false }, -- Mini Map Icon
                showContextMenu = true, -- Show Context Menu
                debugMode = false, -- Debug Mode
                showAppMsgs = true, -- Show Application Messages
                enableAutoSync = true, -- Disable Auto Sync
                showWhispers = true, -- Show Whispers
                antiSpam = true,
                antiSpamDays = 7,
                sendGuildGreeting = false,
                guildMessage = L['DEFAULT_GUILD_WELCOME'],
                sendWhisperGreeting = false,
                obeyBlockInvites = true, -- Obey Block Invites
                messageList = {},
                keepOpen = false,
            },
            analytics = {},
        },
        global = {
            showWhatsNew = true,
            showToolTips = true, -- Show Tool Tips
            ScanWaitTime = 6,
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
            forceObey = false,
            obeyBlockInvites = true, -- Obey Block Invites
            forceAntiSpam = false,
            antiSpam = true,
            antiSpamDays = 7,
            forceSendGuildGreeting = false,
            sendGuildGreeting = false,
            forceGuildMessage = false,
            guildMessage = L['DEFAULT_GUILD_WELCOME'],
            forceSendWhisper = false,
            sendWhisperGreeting = false,
            forceWhisperMessage = false,
            whisperMessage = '',
            forceMessageList = false,
            messageList = {},
        },
        settings = {
            -- General Settings
            obeyBlockInvites = true, -- Obey Block Invites
            showConsoleMessages = false, -- Show Console Messages
            -- Invite Settings
            antiSpam = true,
            antiSpamDays = 7,
            sendGuildGreeting = false,
            guildMessage = L['DEFAULT_GUILD_WELCOME'],
            sendWhisperGreeting = false,
            whisperMessage = '',
            -- Messages
            messageList = {},
        },
        isGuildLeader = false,
        guildLeaderToon = nil,
        blackList = {},
        blackListRemoved = {},
        antiSpamList = {},
        filterList = {},
        analytics = {},
    }
end
function core:StartGuildRecruiter()
    core:Init()
    GR:RegisterChatCommand('rl', function() ReloadUI() end) -- Set the /rl slash command to reload the UI

    ns.fPlayerName = ns.code:cPlayer(GetUnitName('player', false), UnitClassBase('player')) -- Set the player name
    ns.classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or false
    ns.cata = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC or false
    ns.isRetail = not ns.classic and not ns.cata

    local clubID = self:CheckIfInGuild()
    if not clubID or not core.isEnabled then return end

    self:StartDatabase(clubID)
    self:LoadTables()
    self:PerformRecordMaintenance()
    self:StartupGuild(clubID)

    AC:RegisterOptionsTable(addonName, ns.guildRecuriterSettings) -- Register the options table
    ns.addonOptions = ACD:AddToBlizOptions(addonName, 'Guild Recruiter') -- Add the options to the Blizzard options

    --ns.invite:GetWelcomeMessages() -- Get the welcome messages
    self:StartSlashCommands()
    self:StartMiniMapIcon()

    ns.code:fOut(L['TITLE']..' '..GR.versionOut..' '..L['ENABLED'], ns.COLOR_DEFAULT, true)
    if GR.isPreRelease then
        ns.code:fOut(L['BETA_INFORMATION']:gsub('VER', ns.code:cText('FFFF0000', strlower(GR.preReleaseType))), 'FFFFFF00', true)
    end
end
function core:StartDatabase(clubID)
    local db = DB:New(GR.db, self.fileStructure) -- Initialize the database

    if not db.global[clubID] then
        db.global[clubID] = self.guildFileStructure -- Set the guild defaults
    end

    ns.p, ns.g, ns.guild = db.profile, db.global, db.global[clubID] -- Set the profile and global database
    ns.pSettings, ns.gSettings = ns.p.settings, ns.guild.settings -- Set the settings database
    ns.guildInfo, ns.gmSettings = ns.guild.guildInfo, ns.guild.gmSettings -- Set the guild info and GM settings database

    ns.pAnalytics, ns.gAnalytics = ns.p.analytics, ns.guild.analytics -- Set the analytics database
    ns.gFilterList = ns.guild.filterList -- Set the filter list database

    GR.debug = GR.isTesting or ns.pSettings.debugMode -- Set the debug modes
end
function core:LoadTables()
    ns.tblBlackList, ns.antiSpamList = {}, {}

    local blSuccess, tblBL = ns.code:decompressData(ns.g.blackList or {})
    ns.tblBlackList = blSuccess and tblBL or {}

    local asSuccess, tblAS = ns.code:decompressData(ns.g.antiSpamList or {})
    ns.tblAntiSpamList = asSuccess and tblAS or {}

    --* Load Class/Race and Invalid Zones Table
    if ns.isRetail then
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
end
function core:PerformRecordMaintenance()
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
    removeOldRecords(ns.tblBlackList, ns.gmSettings.antiSpamDays)
end
function core:StartSlashCommands() -- Start Slash Commands
    local function slashCommand(msg)
        msg = strlower(msg:trim())

        if not msg or msg == '' and not ns.win.home:IsShown() then return ns.win.home:SetShown(true)
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
            if button == 'LeftButton' and IsShiftKeyDown() and not ns.win.home:IsShown() then ns.win.scanner:SetShown(true)
            elseif button == 'LeftButton' and not ns.win.home:IsShown() then ns.win.home:SetShown(true)
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

    if ns.isRetail then
        local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
        if (not ns.guildInfo.guildLink or ns.guildInfo.guildLink == '') and club then
            local guildLink = "|cffffd200|HclubFinder:"..club.clubFinderGUID.."|h[Guild: "..club.name.."]|h|r"
            ns.guildInfo.guildLink = guildLink or nil
        end
    else
        if guildName and (not ns.guildInfo.guildLink or ns.guildInfo.guildLink == '') then
            local guildLink = "|cffffff00|Hmyguildlink:" .. guildName .. "|h[" .. guildName .. "]|h|r"
            ns.guildInfo.guildLink = guildLink or nil
        end
    end

    if not ns.guildInfo.guildLink or ns.guildInfo.guildLink == '' then
        ns.code:fOut(ns.code:cText(ns.COLOR_ERROR, L['GUILD_LINK_NOT_FOUND']))
        ns.code:fOut(L['GUILD_LINK_NOT_FOUND_LINE1'])
        ns.code:fOut(L['GUILD_LINK_NOT_FOUND_LINE2'])
    end

    if not IsGuildLeader() then
        if GetUnitName('player', true) == ns.g.guildLeaderToon then
            ns.guild.isGuildLeader = false
            ns.guild.guildLeaderToon = nil
            ns.code:fOut(ns.fPlayerName..' '..L['NO_LONGER_GUILD_LEADER'])
        end
    else
        ns.g.isGuildLeader = true
        ns.guild.guildLeaderToon = GetUnitName('player', true)
    end

    ns.isGM = ns.guild.isGuildLeader
    if not ns.isGM then
        ns.obeyBlockInvites = ns.gmSettings.obeyBlockInvites and ns.gmSettings.obeyBlockInvites or ns.gSettings.obeyBlockInvites
        if not not ns.gmSettings.antiSpam and not ns.pSettings.antiSpam then
            ns.code:fOut(L['NO_ANTI_SPAM'], ns.COLOR_ERROR)
        end
    else
        if not not ns.gmSettings.antiSpam then
            ns.code:fOut(L['NO_ANTI_SPAM'], ns.COLOR_ERROR)
        end
    end
end
function core:CheckIfInGuild()
    local function checkIfInGuild(count) -- Check if the player is in a guild
        if not count then return end

        local clubID = C_Club.GetGuildClubId() -- Get the guild club ID (Guild ID)

        if clubID then
            core.isEnabled = true
            return clubID
        elseif count >= 60 then -- If the player is not in a guild after 30 attempts, then return
            core.isEnabled = false
            ns.code:cOut(L['TITLE']..' '..GR.versionOut..' '..L['DISABLED'])
            ns.code:cOut(L['NOT_IN_GUILD'])
            ns.code:cOut(L['NOT_IN_GUILD_LINE1'])
            return
        elseif IsInGuild() and not CanGuildInvite() then -- If the player is in a guild but cannot invite, then return
            core.isEnabled = false
            ns.code:cOut(L['TITLE']..' '..GR.versionOut..' '..L['DISABLED'])
            ns.code:cOut(L['CANNOT_INVITE'])
            return
        elseif not IsInGuild() or not clubID or not select(1, GetGuildInfo('player')) then -- If the player is not in a guild, then check again in 1 second
            C_Timer.After(1, function() checkIfInGuild(count + 1) end)
        end
    end

    return checkIfInGuild(0)
end
--? End of core Support Functions

--* Start of Guild Recruiter
local function eventsPLAYER_LOGIN()
    GR:UnregisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)
    core:StartGuildRecruiter()
end
GR:RegisterEvent('PLAYER_LOGIN', eventsPLAYER_LOGIN)
--? End of Guild Recruiter

--* Manual update of settings data
function core:NotifySettingsUpdate()
    AceConfigRegistry:NotifyChange(addonName)
end
core:Init()

--* Hook /ginvite command
-- Create a custom dropdown frame for the additional options
local customDropdown = CreateFrame("Frame", "CustomChatDropdown", UIParent, "UIDropDownMenuTemplate")
-- Function to initialize the custom dropdown menu
local function InitializeDropdownMenu(self, level)
    if not core.isEnabled then return
    elseif not self.chatPlayerName or not ns.pSettings.showContextMenu then return end
    local cPlayerName = ns.code:cText(ns.COLOR_DEFAULT, self.chatPlayerName)
    if level == 1 then
        local name = self.chatPlayerName:find('-') and self.chatPlayerName or self.chatPlayerName..'-'..GetRealmName() -- Add realm name if not present
        local info = UIDropDownMenu_CreateInfo()
        info.text = cPlayerName..'\n'..ns.code:cText('FFFFFF00', L['INVITE_NO_MESSAGES_MENU'])
        info.notCheckable = true
        info.fontObject = GameFontNormalOutline
        info.func = function()
            ns.invite:SendManualInvite(self.chatPlayerName, true)
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
            ns.invite:SendManualInvite(self.chatPlayerName, true, false, true)
        end
        UIDropDownMenu_AddButton(info, level)

        local activeMessage = ns.pSettings.activeMessage or 1
        local location = ns.core.hasGM and ns.gmSettings or ns.gSettings
        local messageList = (location.messageList and location.messageList[activeMessage]) and location.messageList[activeMessage].message or nil
        local msg = (messageList and messageList[activeMessage]) and messageList[activeMessage].messages or nil

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
--local originalSetItemRef = SetItemRef

-- Override SetItemRef to capture right-clicks on player names
hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
    if button == "RightButton" then
        local type, name = strsplit(":", link)
        if type == "player" then
            if InCombatLockdown() then return end  -- Prevent opening menu during combat

            -- Store the clicked player name in the dropdown frame
            customDropdown.chatPlayerName = name
            customDropdown.fromInviteMenu = true  -- Mark that this click is from the invite menu

            -- Show the system context menu
            local xOffset, yOffset = PositionCustomDropdown()
            UIDropDownMenu_Initialize(customDropdown, InitializeDropdownMenu, "MENU")
            ToggleDropDownMenu(1, nil, customDropdown, "cursor", xOffset, yOffset)
        else
            customDropdown.fromInviteMenu = false  -- Mark that this is not from the invite menu
        end
    else
        customDropdown.fromInviteMenu = false  -- Mark that this is not from the invite menu
    end
end)