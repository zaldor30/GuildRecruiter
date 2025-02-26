local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.home = {}
local home = ns.home

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    ns.frames:ResetFrame(home.tblFrame.previewFrame.frame)
    ns.frames:ResetFrame(home.tblFrame.frame)
    home.tblFrame.frame = nil
end

function home:Init()
    self.tblFrame = self.tblFrame or {}

    -- Holding Tables
    self.tblFilters = {}
    self.tblMessages = {}
    self.activeFilter = ns.pSettings.activeFilter or 9999 -- Default Filter
    self.activeMessage = ns.pSettings.activeMessage or nil -- Default Message

    self.minLevel = ns.pSettings.minLevel or ns.MAX_CHARACTER_LEVEL - 5 -- Default Min Level
    self.maxLevel = ns.pSettings.maxLevel or ns.MAX_CHARACTER_LEVEL -- Default Max Level

    self.tblFormat = {}
    table.insert(self.tblFormat, { id = 2, description = L['GUILD_INVITE_ONLY'] })
    table.insert(self.tblFormat, { id = 3, description = L['GUILD_INVITE_AND_MESSAGE'] })
    table.insert(self.tblFormat, { id = 1, description = L['MESSAGE_ONLY'] })
    table.insert(self.tblFormat, { id = 4, description = L['MESSAGE_ONLY_IF_INVITE_DECLINED'] })
end

local baseSizeX, baseSizeY = 500, 300
local function ChangeBaseFrameSize(x, y)
    x = x or baseSizeX
    y = y or baseSizeY

    ns.base.tblFrame.frame:SetSize(x, y)
end
function home:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function home:SetShown(val)
    if not val and not self:IsShown() then return
    elseif not val then self.tblFrame.frame:SetShown(false) end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    self:Init()
    self:LoadTables()
    ChangeBaseFrameSize()
    if not self.tblFrame or not self.tblFrame.frame then
        self:CreateBaseFrame()
        self:CreateFilterAndLevel()
        self:CreateInviteTypeAndMessage()
        self:MessagePreview()
    end

    self:UpdatePreviewText()
    self:validate_data_scan_button()
    self.tblFrame.frame:SetShown(val)
end
function home:CreateBaseFrame()
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
            ns.pSettings.activeFilter = id
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
    self.tblFrame.dropFilters = dropFilters

    local dropLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropLabel:SetPoint("BOTTOMLEFT", dropFilters.frame, "TOPLEFT", 20, 0)
    dropLabel:SetText(L['SELECT_A_FILTER']..":")
    dropLabel:SetTextColor(1, 1, 1)

    local oldValue = nil
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

    local function HandleTabNavigation(self, key)
        if key == "TAB" then
            if IsShiftKeyDown() then
                -- Shift+Tab pressed: Move focus to the previous Edit Box
                if self:GetName() == "GR_MaxLevel" then
                    editMinLevel:SetFocus()
                elseif self:GetName() == "GR_MinLevel" then
                    -- If more Edit Boxes exist, set focus to the last one or handle accordingly
                    editMinLevel:SetFocus() -- Example for two Edit Boxes
                end
            else
                -- Tab pressed: Move focus to the next Edit Box
                if self:GetName() == "GR_MinLevel" then
                    editMaxLevel:SetFocus()
                elseif self:GetName() == "GR_MaxLevel" then
                    -- If more Edit Boxes exist, set focus to the first one or handle accordingly
                    editMinLevel:SetFocus() -- Example for two Edit Boxes
                end
            end
        end
    end

    local validateLevel = function(value)
        if value == "" then return true end
        local num = tonumber(value)
        if num == nil then return false end
        if num < 1 or num > ns.MAX_CHARACTER_LEVEL then return false end
        return true
    end
    local function startValidate(self, level)
        if validateLevel(level) then
            self:ClearFocus()
            self:SetText(self:GetText() and tonumber(self:GetText() ) or level)
            ns.status:SetText('')
            if self:GetName() == "GR_MinLevel" then ns.pSettings.minLevel = tonumber(self:GetText())
            else ns.pSettings.maxLevel = tonumber(self:GetText()) end
            HandleTabNavigation(self, "TAB")
        else
            self:SetText(oldValue)
            ns.status:SetText(L['MAX_LEVEL_ERROR'] .. ns.MAX_CHARACTER_LEVEL)
        end

        home:validate_data_scan_button()
    end

    local skipValidation = false
    editMinLevel:SetScript("OnEnterPressed", function(self) startValidate(self, self:GetText()) end)
    editMinLevel:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:SetText(oldValue)
    end)
    editMinLevel:SetScript("OnEditFocusLost", function(self) if not skipValidation then startValidate(self, self:GetText()) end end)
    editMinLevel:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
        oldValue = self:GetText()
    end)
    editMinLevel:SetScript("OnKeyDown", function(self, key) HandleTabNavigation(self, key) end)

    editMaxLevel:SetScript("OnEnterPressed", function(self) startValidate(self, self:GetText()) end)
    editMaxLevel:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:SetText(oldValue)
    end)
    editMaxLevel:SetScript("OnEditFocusLost", function(self) if not skipValidation then startValidate(self, self:GetText()) end end)
    editMaxLevel:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
        oldValue = self:GetText()
    end)

    local buttonScan = ns.frames:CreateFrame('Button', 'GR_Start_Invite', self.tblFrame.frame, 'UIPanelButtonTemplate')
    buttonScan:SetPoint("LEFT", editMaxLevel, "RIGHT", 10, 0)
    buttonScan:SetSize(100, 20)
    buttonScan:SetText(L['SCAN'])
    buttonScan:SetScript("OnClick", function(self, button, down)
        skipValidation = false
        editMinLevel:ClearFocus()
        editMaxLevel:ClearFocus()
        if ns.pSettings.inviteFormat ~= ns.InviteFormat.GUILD_INVITE_ONLY and (not ns.pSettings.activeMessage or ns.pSettings.activeMessage == '') then
            ns.status:SetText(L['SELECT_INVITE_MESSAGE'])
            return
        end
        ns.base:buttonAction('OPEN_SCANNER')
    end)
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
        'Select a filter.',   -- Default text
        self.tblFormat,              -- Entries for the dropdown
        inviteReturn              -- Additional options (callbacks)
    )

    -- Position the dropdown within the parent frame
    dropInvite.frame:SetPoint("TOPLEFT", self.tblFrame.dropFilters.frame, "BOTTOMLEFT", 0, -15)
    dropInvite.frame:SetSelectedValue(ns.pSettings.inviteFormat)
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
        #self.tblMessages == 0 and 'Create message in settings' or 'Select a message',   -- Default text
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
function home:MessagePreview()
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

--* Home Support Functions
function home:LoadTables()
    self.tblMessages, self.tblFilters = {}, {}
    local tblMessages = ns.guild.messageList or {}
    for k,v in pairs(tblMessages) do
        local desc = (not ns.isGM and v.gmSync) and ns.code:cText(ns.COLOR_GM, v.desc) or v.desc
        table.insert(self.tblMessages, { id = k, description = desc })
    end
    self.activeMessage = ns.pSettings.activeMessage or nil

    local filters = {}
    local tblFilters = ns.guild and ns.guild.filterList or {}
    for k,v in pairs(tblFilters) do table.insert(filters, { id = k, description = v.desc }) end
    table.insert(filters, { id = 9998, description = 'Race Filter (Default Filter)' })
    table.insert(filters, { id = 9999, description = 'Class Filter (Default Filter)' })
    self.tblFilters = filters
end
function home:validate_data_scan_button()
    local msg = ''
    local buttonScan = self.tblFrame.buttonScan
    local minLevel = tonumber(ns.pSettings.minLevel)
    local maxLevel = tonumber(ns.pSettings.maxLevel)

    buttonScan:Enable()
    if minLevel > maxLevel then msg = "Min Level cannot be greater than Max Level."
    elseif minLevel < 1 or minLevel > ns.MAX_CHARACTER_LEVEL then msg = "Min Level must be between 1 and " .. ns.MAX_CHARACTER_LEVEL
    elseif maxLevel < 1 or maxLevel > ns.MAX_CHARACTER_LEVEL then msg = "Max Level must be between 1 and " .. ns.MAX_CHARACTER_LEVEL end

    local dropMessages, preview = self.tblFrame.dropMessages, self.tblFrame.previewFrame
    if dropMessages and preview then
        if ns.pSettings.inviteFormat == ns.InviteFormat.GUILD_INVITE_ONLY then
            preview.frame:SetShown(false)
            dropMessages.frame:SetShown(false)
            dropMessages.text:SetShown(false)
            ChangeBaseFrameSize(baseSizeX, 185)
        else
            preview.frame:SetShown(true)
            dropMessages.frame:SetShown(true)
            dropMessages.text:SetShown(true)
            ChangeBaseFrameSize(baseSizeX, baseSizeY)
        end
    end

    local allOk = msg == '' or false
    if maxLevel - minLevel > 5 then
        msg = "Level range of more than 5 levels is not recommended."
    end
    if ns.pSettings.inviteFormat ~= ns.InviteFormat.GUILD_INVITE_ONLY then
        if not self.activeMessage then msg = "Please select a message." end
    end

    if msg ~= '' and not allOk then
        buttonScan:Disable()
        msg = ns.code:cText('FFFF0000', msg)
    end
    ns.status:SetText(msg)


    return (msg == '' or allOk or false), msg
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