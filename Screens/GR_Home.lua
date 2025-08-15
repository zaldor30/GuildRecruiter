local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.home = {}
local home = ns.home

home.filterStarted = false

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)

    if not home.tblFrame or not home.tblFrame.frame or not home.tblFrame.previewFrame or not home.tblFrame.previewFrame.frame then return end
    ns.frames:ResetFrame(home.tblFrame.previewFrame.frame)
    ns.frames:ResetFrame(home.tblFrame.frame)
    home.tblFrame.frame = nil
end

-- Initialize the home frame
local msgFound = false
local baseSizeX, baseSizeY = 500, 300
function home:Init()
    self.tblFrame = self.tblFrame or {}

    -- Holding Tables
    self.tblFilters = {}
    self.tblMessages = {}
    self.activeFilter = ns.pSettings.activeFilter or 9999 -- Default Filter
    self.activeMessage = ns.pSettings.activeMessage or nil -- Default Message

    self.minLevel = ns.pSettings.minLevel or (ns.MAX_CHARACTER_LEVEL - 5 > 0 and ns.MAX_CHARACTER_LEVEL - 5 or 1) -- Default Min Level
    self.maxLevel = ns.pSettings.maxLevel or ns.MAX_CHARACTER_LEVEL -- Default Max Level

    self.isOk = false
end
function home:LoadTables()
    self.tblMessages, self.tblFilters = {}, {}
    local tblMessages = ns.guild.messageList
    if not tblMessages or type(tblMessages) ~= 'table' then
        tblMessages = {}
        ns.guild.messageList = tblMessages
    end

    -- Load messages and filters
    local msgCount = 0
    for k,v in pairs(tblMessages) do
        msgCount = msgCount + 1
        local desc = (not ns.isGM and v.gmSync) and ns.code:cText(ns.COLOR_GM, v.desc) or v.desc
        tinsert(self.tblMessages, { id = k, description = desc })
    end
    msgFound = msgCount > 0 or false
    self.activeMessage = (msgFound and ns.pSettings.activeMessage) and ns.pSettings.activeMessage or nil
    ns.pSettings.activeMessage = self.activeMessage


    -- Populate filters
    local filters = {}
    local tblFilters = ns.guild and ns.guild.filterList or {}
    for k,v in pairs(tblFilters) do tinsert(filters, { id = k, description = v.desc }) end
    tinsert(filters, { id = 9998, description = 'Race Filter (Default Filter)' })
    tinsert(filters, { id = 9999, description = 'Class Filter (Default Filter)' })
    self.tblFilters = filters

    -- Populate Invite Formats
    self.tblFormat = {}
    tinsert(self.tblFormat, { id = ns.InviteFormat.GUILD_INVITE_ONLY, description = L['GUILD_INVITE_ONLY'] })
    if msgFound then
        tinsert(self.tblFormat, { id = ns.InviteFormat.GUILD_INVITE_AND_MESSAGE, description = L['GUILD_INVITE_AND_MESSAGE'] })
        tinsert(self.tblFormat, { id = ns.InviteFormat.MESSAGE_ONLY, description = L['MESSAGE_ONLY'] })
        tinsert(self.tblFormat, { id = ns.InviteFormat.MESSAGE_ONLY_IF_INVITE_DECLINED, description = L['MESSAGE_ONLY_IF_INVITE_DECLINED'] })
    end
end

-- Show the home frame
function home:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end  -- Check if the home frame is shown
function home:SetShown(val)
    if not val and not self:IsShown() then return
    elseif not val then self.tblFrame.frame:SetShown(false) end

    -- Notify observers and register for close events
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    self:Init()
    self:LoadTables()

    if not self.tblFrame or not self.tblFrame.frame then
        -- Create the base frame and its components
        self:CreateHomeScreenFrame()
        self:CreateFilterAndLevel()
        self:CreateInviteTypeAndMessage()
        self:CreatePreviewWindow()
    end

    ns.code:updateStatusText()
    ns.code:ChangeBaseFrameSize()

    self:UpdatePreviewText()
    self:validate_data_scan_button()

    ns.scanner.askReset = false
end

-- Create the home screen frame
-- This function should create the main frame and its components
function home:CreateHomeScreenFrame()
    local baseFrame = ns.base.tblFrame
    local f = ns.frames:CreateFrame("Frame", "GR_HomeFrame", baseFrame.frame)
    f:SetPoint("TOPLEFT", baseFrame.icon, "BOTTOMLEFT", 5, 0)
    f:SetPoint("BOTTOMRIGHT", baseFrame.status, "TOPRIGHT", -5, 0)
    f:SetBackdropColor(0,0,0,0)
    f:SetBackdropBorderColor(0,0,0,0)
    f:EnableMouse(false)
    self.tblFrame.frame = f
end
function home:CreateFilterAndLevel()
    local filterReturn = { -- Callback when filter is selected
        onSelect = function(id, description)
            id = tonumber(id)
            local oldID = ns.pSettings.activeFilter or nil
            ns.pSettings.activeFilter = id
            ns.scanner.askReset = home.filterStarted and (oldID ~= id and true or ns.scanner.askReset) or false
        end
    }

    local dropFilters = ns.dropdown:new(
        'GR_Filter_Dropdown', -- Name of the dropdown frame
        self.tblFrame.frame,          -- Parent frame
        210,                  -- Width of the dropdown
        'Select a filter.',   -- Default text
        self.tblFilters,              -- Entries for the dropdown
        filterReturn              -- Additional options (callbacks)
    )

    -- Position the dropdown within the parent frame
    dropFilters.frame:SetPoint("TOPLEFT", self.tblFrame.frame, "TOPLEFT", -8, -15)
    dropFilters.frame:SetSelectedValue(self.activeFilter)
    ns.scanner.resetFilters = dropFilters

    local dropLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropLabel:SetPoint("BOTTOMLEFT", dropFilters.frame, "TOPLEFT", 20, 0)
    dropLabel:SetText(L['SELECT_A_FILTER']..":")
    dropLabel:SetTextColor(1, 1, 1)

    local editMinLevel = ns.frames:CreateFrame("EditBox", "GR_MinLevel", self.tblFrame.frame, "InputBoxTemplate")
    editMinLevel:SetSize(50, 20)
    editMinLevel:SetPoint("LEFT", dropFilters.frame, "RIGHT", 0, 2)
    editMinLevel:SetNumeric(true)
    editMinLevel:SetMaxLetters(2)
    editMinLevel:SetAutoFocus(false)
    editMinLevel:SetJustifyH("CENTER")
    editMinLevel:SetText(ns.pSettings.minLevel or self.minLevel)

    local minLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    minLabel:SetPoint("BOTTOM", editMinLevel, "TOP", 0, 0)
    minLabel:SetText(L['MIN_LEVEL']..":")
    minLabel:SetTextColor(1, 1, 1)

    local editMaxLevel = ns.frames:CreateFrame("EditBox", "GR_MaxLevel", self.tblFrame.frame, "InputBoxTemplate")
    editMaxLevel:SetSize(50, 20)
    editMaxLevel:SetPoint("LEFT", editMinLevel, "RIGHT", 20, 0)
    editMaxLevel:SetNumeric(true)
    editMaxLevel:SetMaxLetters(2)
    editMaxLevel:SetAutoFocus(false)
    editMaxLevel:SetJustifyH("CENTER")
    editMaxLevel:SetText(ns.pSettings.maxLevel or self.maxLevel)

    local maxLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxLabel:SetPoint("BOTTOM", editMaxLevel, "TOP", 0, 0)
    maxLabel:SetText(L['MAX_LEVEL']..":")
    maxLabel:SetTextColor(1, 1, 1)


    local buttonScan = ns.frames:CreateFrame('Button', 'GR_Start_Invite', self.tblFrame.frame, 'UIPanelButtonTemplate')

    -- Check min and max levels
    local function fixLevel(self)
        ns.code:updateStatusText()
        if not self:GetText() then return end
        if not self or not self:GetText() or type(tonumber(self:GetText())) ~= 'number' then
            ns.code:updateStatusText(L['MAX_LEVEL_ERROR'] .. ns.MAX_CHARACTER_LEVEL, { r = 1, g = 0, b = 0, a = 1 })
            return
        end

        local origMinLevel = tonumber(editMinLevel:GetText()) or nil
        local origMaxLevel = tonumber(editMaxLevel:GetText()) or nil
        local oldMinLevel = ns.pSettings.minLevel or nil
        local oldgMaxLevel = ns.pSettings.maxLevel or nil

        local minLvl = origMinLevel and (tonumber(origMinLevel) or 1) or (ns.MAX_CHARACTER_LEVEL -5 > 0 and ns.MAX_CHARACTER_LEVEL -5 or 1)
        local maxLvl = origMaxLevel and (tonumber(origMaxLevel) or ns.MAX_CHARACTER_LEVEL) or ns.MAX_CHARACTER_LEVEL

        if minLvl < 1 then minLvl = 1
        elseif minLvl > maxLvl then minLvl = maxLvl end

        if maxLvl < 1 then maxLvl = 1
        elseif maxLvl > ns.MAX_CHARACTER_LEVEL then maxLvl = ns.MAX_CHARACTER_LEVEL end

        if maxLvl - minLvl > 5 then
            ns.code:updateStatusText(L['LEVELS_TOO_CLOSE'], { r = 1, g = 0, b = 0, a = 1 })
        end

        editMinLevel:SetText(minLvl)
        editMaxLevel:SetText(maxLvl)

        ns.pSettings.minLevel = minLvl
        ns.pSettings.maxLevel = maxLvl
        ns.scanner.askReset = home.filterStarted and ((oldMinLevel ~= ns.pSettings.minLevel or oldgMaxLevel ~= ns.pSettings.maxLevel) and true or ns.scanner.askReset) or false

        if origMinLevel ~= minLvl or origMaxLevel ~= maxLvl then
            ns.code:updateStatusText(L['LEVELS_FIXED'] .. ": " .. minLvl .. " - " .. maxLvl, { r = 1, g = 1, b = 0, a = 1 })
        end
    end

    local oldMinLevel, oldMaxLevel = nil, nil
    local function levelFocusGained(self)
        self:HighlightText()
        oldMinLevel = self:GetText() == "" and (ns.MAX_CHARACTER_LEVEL -5 > 0 and ns.MAX_CHARACTER_LEVEL -5 or 1) or tonumber(self:GetText())
        oldMaxLevel = self:GetText() == "" and ns.MAX_CHARACTER_LEVEL or tonumber(self:GetText())
    end
    editMinLevel:SetScript("OnEditFocusGained", function(self) levelFocusGained(self) end)
    editMinLevel:SetScript("OnEditFocusLost", function(self)
        if not self:GetText() or self:GetText() == "" then
            self:SetText(oldMinLevel and oldMinLevel or (ns.MAX_CHARACTER_LEVEL - 5 > 0 and ns.MAX_CHARACTER_LEVEL - 5 or 1))
        end
        fixLevel(self)
     end)
    editMinLevel:SetScript("OnEnterPressed", function(self) 
        fixLevel(self) 
        editMaxLevel:SetFocus()
    end)
    editMinLevel:SetScript("OnEscapePressed", function(self)
        self:SetText(oldMinLevel)
        fixLevel(self)
        self:ClearFocus()
    end)
    editMinLevel:SetScript("OnTabPressed", function(self) 
        editMaxLevel:SetFocus()
    end)

    editMaxLevel:SetScript("OnEditFocusGained", function(self) levelFocusGained(self) end)
    editMaxLevel:SetScript("OnEditFocusLost", function(self)
        if not self:GetText() or self:GetText() == "" then
            self:SetText(oldMaxLevel and oldMaxLevel or ns.MAX_CHARACTER_LEVEL)
        end
        fixLevel(self)
     end)
    editMaxLevel:SetScript("OnEnterPressed", function(self)
        fixLevel(self) 
        self:ClearFocus()
    end)
    editMaxLevel:SetScript("OnEscapePressed", function(self)
        self:SetText(oldMaxLevel)
        fixLevel(self)
        self:ClearFocus()
    end)
    editMaxLevel:SetScript("OnTabPressed", function(self) 
        editMinLevel:SetFocus()
    end)

    buttonScan:SetPoint("LEFT", editMaxLevel, "RIGHT", 10, 0)
    buttonScan:SetSize(100, 20)
    buttonScan:SetText(L['SCAN'])

    buttonScan:SetScript("OnClick", function(self, button, down)
        editMinLevel:ClearFocus()
        editMaxLevel:ClearFocus()
        ns.base:buttonAction('OPEN_SCANNER')
    end)
    buttonScan:SetEnabled(false)

    self.tblFrame.buttonScan = buttonScan
end
function home:CreateInviteTypeAndMessage()
    local inviteReturn = { -- Callback when filter is selected
        onSelect = function(id, description)
            id = tonumber(id)
            ns.pSettings.inviteFormat = id
            self:validate_data_scan_button()
        end
    }

    local dropInvite = ns.dropdown:new(
        'GR_Filter_Dropdown', -- Name of the dropdown frame
        self.tblFrame.frame,          -- Parent frame
        210,                  -- Width of the dropdown
        L['SELECT_INVITE_TYPE'],   -- Default text
        self.tblFormat,              -- Entries for the dropdown
        inviteReturn              -- Additional options (callbacks)
    )

    -- Position the dropdown within the parent frame
    dropInvite.frame:SetPoint("TOPLEFT", ns.scanner.resetFilters.frame, "BOTTOMLEFT", 0, -15)
    local inviteFormat = ns.pSettings.inviteFormat or ns.InviteFormat.GUILD_INVITE_ONLY
    ns.pSettings.inviteFormat = inviteFormat

    dropInvite.frame:SetSelectedValue(inviteFormat)
    self.tblFrame.dropInvite = dropInvite

    local dropLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropLabel:SetPoint("BOTTOMLEFT", dropInvite.frame, "TOPLEFT", 20, 0)
    dropLabel:SetText(L['SELECT_INVITE_TYPE']..":")
    dropLabel:SetTextColor(1, 1, 1)

    local messageReturn = { -- Callback when filter is selected
        onSelect = function(id, description)
            self.activeMessage = id
            ns.pSettings.activeMessage = id

            self:UpdatePreviewText()
            self:validate_data_scan_button()
        end
    }

    local dropMessages = ns.dropdown:new(
        'GR_Filter_Dropdown', -- Name of the dropdown frame
        self.tblFrame.frame,          -- Parent frame
        220,                  -- Width of the dropdown
        #self.tblMessages == 0 and L['CREATE_MESSAGE_IN_SETTINGS'] or L['SELECT_INVITE_MESSAGE'],   -- Default text
        self.tblMessages,              -- Entries for the dropdown
        messageReturn              -- Additional options (callbacks)
    )

    -- Position the dropdown within the parent frame
    dropMessages.frame:SetPoint("BOTTOMLEFT", dropInvite.frame, "BOTTOMRIGHT", -25, 0)
    dropMessages.frame:SetSelectedValue(self.activeMessage)

    local dropMsgLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropMsgLabel:SetPoint("BOTTOMLEFT", dropMessages.frame, "TOPLEFT", 20, 0)
    dropMsgLabel:SetText(L['SELECT_INVITE_MESSAGE']..":")
    dropMsgLabel:SetTextColor(1, 1, 1)
    self.tblFrame.dropMessages = dropMessages
    self.tblFrame.dropMessages.text = dropMsgLabel
end
function home:CreatePreviewWindow()
    local previewFrame = ns.frames:CreateFrame("Frame", "GR_MessagePreview", self.tblFrame.frame)
    previewFrame:SetPoint("TOPLEFT", self.tblFrame.dropInvite.frame, "BOTTOMLEFT", 15, -5)
    previewFrame:SetPoint("BOTTOMRIGHT", ns.status.frame, "TOPRIGHT", -10, 5)
    previewFrame:SetBackdropColor(0,0,0,.7)
    previewFrame:SetBackdropBorderColor(1,1,1,1)

    local previewLabel = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewLabel:SetPoint("TOPLEFT", previewFrame, "TOPLEFT", 10, -10)
    previewLabel:SetText(L['PREVIEW_TITLE']..":")
    previewLabel:SetTextColor(1, 1, 1)
    self.tblFrame.previewFrame = {}
    self.tblFrame.previewFrame.frame = previewFrame

    local previewText = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewText:SetPoint("TOPLEFT", previewLabel, "BOTTOMLEFT", 0, -5)
    previewText:SetPoint("BOTTOMRIGHT", previewFrame, "BOTTOMRIGHT", -10, 10)
    previewText:SetJustifyH("LEFT")
    previewText:SetJustifyV("TOP")
    self.tblFrame.previewFrame.previewText = previewText
end

-- Check Routines
function home:validate_data_scan_button()
    local btnScan = self.tblFrame.buttonScan

    if ns.pSettings.inviteFormat ~= ns.InviteFormat.GUILD_INVITE_ONLY and (not ns.pSettings.activeMessage or ns.pSettings.activeMessage == '') then
        ns.code:updateStatusText(L['SELECT_INVITE_MESSAGE'], { r = 1, g = 0, b = 0, a = 1 })
        self.isOk = false
    else
        self.isOk = true
        ns.code:updateStatusText()
    end

    btnScan:SetEnabled(self.isOk)
end
function home:UpdatePreviewText()
    local previewFrame = self.tblFrame.previewFrame.previewText
    local tblMessage = ns.guild.messageList and ns.guild.messageList[self.activeMessage] or nil
    if not tblMessage then return end

    local preview = ns.code:variableReplacement(tblMessage.message, UnitName('player'))
    if tblMessage.message == '' then return '' end

    local msg = (ns.code:cText('FFFF80FF', 'To [')..ns.fPlayerName..ns.code:cText('FFFF80FF', ']: '..(preview or ''))) or ''
    msg = msg:gsub(L['GUILD_LINK_NOT_FOUND'], ns.code:cText('FFFF0000', L['GUILD_LINK_NOT_FOUND']))
    msg = msg:gsub(L['NO_GUILD_NAME'], ns.code:cText('FFFF0000', L['NO_GUILD_NAME']))

    previewFrame:SetText(msg)
end