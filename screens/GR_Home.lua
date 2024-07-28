local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local aceGUI = LibStub("AceGUI-3.0")

ns.win.home = {}
local home = ns.win.home

-- Observer Call Backs
local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)
    if not home.tblFrame.frame or not ns.screens.home.tblFrame.inline then return end

    home.tblFrame.frame:SetShown(false)
    home.tblFrame.inline.frame:Hide()
end

function home:Init()
    self.activeMessage = nil

    self.tblFrame = {}
    self.tblFilters = {}
    self.tblWhipsers = {}

    self.minLevel = MAX_CHARACTER_LEVEL - 5 -- Default Min Level
    self.maxLevel = MAX_CHARACTER_LEVEL -- Default Max Level

    self.tblFormat = {
        [1] = L['MESSAGE_ONLY'],
        [2] = L['GUILD_INVITE_ONLY'],
        [3] = L['GUILD_INVITE_AND_MESSAGE'],
        [4] = L['MESSAGE_ONLY_IF_INVITE_DECLINED'],
    }
end
function home:SetShown(val)
    local tblHome = ns.win.base.tblFrame

    if not val and tblHome.frame then tblHome.frame:SetShown(false) return
    elseif not tblHome.frame then return end

    ns.win.base.tblFrame.frame:SetSize(500, 300)
    ns.pSettings.inviteFormat = ns.pSettings.inviteFormat or 2
    self.minLevel = ns.pSettings.minLevel or MAX_CHARACTER_LEVEL - 5
    self.maxLevel = ns.pSettings.maxLevel or MAX_CHARACTER_LEVEL

    -- Setup for Close Routines
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    -- Get Invite Messages
    self.tblWhipsers = self:GetWhisperMessages()
    self.tblFilters = {
        [1] = L['CLASS_FILTER'],
        [2] = L['RACE_FILTER'],
    }
    for k, r in pairs(ns.gSettings.filterList and ns.gSettings.filterList or {}) do self.tblFilters[k+100] = r.desc end

    -- Clear home Ace3 children
    if self.tblFrame and self.tblFrame.inline then
        self.tblFrame.inline:ReleaseChildren()
    end

    if not self.tblFrame or not self.tblFrame.frame then self:CreateHomeFrame() end
end

-- *Create Invite Area
function home:CreateInviteArea()
    local inline = self.tblFrame.inline
    local tblFrame, tblBase = self.tblFrame, ns.win.base.tblFrame

    -- DropDown for Message Format Ace3
    local formatDrop = aceGUI:Create('Dropdown')
    formatDrop:SetLabel(L['INVITE_FORMAT'])
    formatDrop:SetRelativeWidth(.5)
    formatDrop:SetList(self.tblFormat)
    formatDrop:SetValue(ns.pSettings.inviteFormat or 2)
    formatDrop:SetCallback('OnValueChanged', function(_, _, val)
        ns.pSettings.inviteFormat = tonumber(val)
      self:CreatePreview()
        self:SetButtonStates()
    end)
    inline:AddChild(formatDrop)

    -- Padding for level boxes
    ns.code:createPadding(inline, .03)

    -- Minimum level for filter Ace3
    local minLevelBox = aceGUI:Create('EditBox')
    minLevelBox:SetLabel(L['MIN_LVL'])
    minLevelBox:SetText(ns.pSettings.minLevel)
    minLevelBox:SetMaxLetters(2)
    minLevelBox:SetRelativeWidth(.13)
    minLevelBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local errMsg = nil
        self.minLevel = type(self.minLevel) == 'string' and tonumber(self.minLevel) or self.minLevel
        self.maxLevel = type(self.maxLevel) == 'string' and tonumber(self.maxLevel) or self.maxLevel

        if type(tonumber(val:trim())) ~= 'number' or (tonumber(val:trim()) <= 0 or tonumber(val:trim()) > MAX_CHARACTER_LEVEL) then
            errMsg = L['INVALID_LEVEL']..' '..tostring(MAX_CHARACTER_LEVEL)
        else
            local min = tonumber(val:trim()) or nil
            local maxLevel = self.maxLevel and tonumber(self.maxLevel) or MAX_CHARACTER_LEVEL

            if min > maxLevel then errMsg = L['MIN_LVL_HIGHER_ERROR'] end
        end

        if errMsg then
            print('Error:', errMsg)
            widget:SetText(tostring(self.minLevel) or '1')
            ns.statusText:SetText(errMsg)
            return
        else
            ns.statusText:SetText('')
            self.minLevel = val:trim() or nil
            ns.pSettings.minLevel = self.minLevel
        end
    end)
    inline:AddChild(minLevelBox)
    tblFrame.minLevel = minLevelBox

    -- Padding for max level box
    ns.code:createPadding(inline, .02)

    -- Maximum level for filter Ace3
    local maxLevelBox = aceGUI:Create('EditBox')
    maxLevelBox:SetLabel(L['MAX_LVL'])
    maxLevelBox:SetText(ns.pSettings.maxLevel)
    maxLevelBox:SetMaxLetters(2)
    maxLevelBox:SetRelativeWidth(.13)
    maxLevelBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local errMsg = nil
        local level = val and tonumber(val:trim()) or nil
        if not level then return end

        self.minLevel = type(self.minLevel) == 'string' and tonumber(self.minLevel) or self.minLevel
        self.maxLevel = type(self.maxLevel) == 'string' and tonumber(self.maxLevel) or self.maxLevel

        if level < 0 or level > MAX_CHARACTER_LEVEL then errMsg = L['INVALID_LEVEL']..' '..tostring(MAX_CHARACTER_LEVEL)
        elseif level < (self.minLevel or 1) then errMsg = L['MAX_LVL_LOWER_ERROR'] end

        if errMsg then
            widget:SetText(tostring(self.maxLevel) or tostring(MAX_CHARACTER_LEVEL))
            ns.statusText:SetText(errMsg)
            return
        else
            ns.statusText:SetText('')
            self.maxLevel = val:trim() or nil
            ns.pSettings.maxLevel = self.maxLevel
        end
    end)
    inline:AddChild(maxLevelBox)
    tblFrame.maxLevel = maxLevelBox

    -- Padding for Scan  Button
    ns.code:createPadding(inline, .03)

    -- Scan Button Ace3
    local scanButton = aceGUI:Create('Button')
    scanButton:SetText(L['SCAN'])
    scanButton:SetRelativeWidth(.15)
    scanButton:SetCallback('OnClick', function()
        tblBase.statusText:SetText('')
        local msgID = ns.settings.activeMessage
        local msg = (msgID and self.tblWhipsers[msgID]) and self.tblWhipsers[msgID].message or nil
        if ns.settings.inviteFormat ~= 2 and (not msgID or not msg) then
            ns.statusText:SetText(ns.code:cText('FFFF0000', L['Select a message from the list or create one in settings.']))
            return
        else ns.statusText:SetText('') end

        ns.screens.scanner:StartUp(msg)
    end)
    inline:AddChild(scanButton)
    tblFrame.scanButton = scanButton
end
function home:CreateMessageSelection()
    local inline = self.tblFrame.inline
    local tblFrame = self.tblFrame

    local tbl = {}
    for k, r in pairs(self.tblWhipsers) do
        tbl[k] = r.desc
    end

    -- Message List DropDown Ace3
    local msgListDropDown = aceGUI:Create('Dropdown')
    msgListDropDown:SetLabel(L['MESSAGE_LIST']..':')
    msgListDropDown:SetRelativeWidth(.5)
    msgListDropDown:SetList(tbl)
    msgListDropDown:SetValue(ns.pSettings.activeMessage)
    msgListDropDown:SetCallback('OnValueChanged', function(_, _, val) self:MessageChanged(val) end)
    inline:AddChild(msgListDropDown)
    tblFrame.msgList = msgListDropDown
end
function home:CreateMessagePreview()
    local inline = self.tblFrame.inline
    local tblFrame = self.tblFrame

    local previewInline = aceGUI:Create('InlineGroup')
    previewInline:SetLayout('Fill')
    previewInline:SetRelativeWidth(1)
    previewInline:SetFullHeight(true)
    inline:AddChild(previewInline)

    -- Preview Scroll Frame
    local previewScrollFrame = aceGUI:Create('ScrollFrame')
    previewScrollFrame:SetLayout('Fill')
    previewScrollFrame:SetFullHeight(true)
    previewScrollFrame:SetFullWidth(true)
    previewInline:AddChild(previewScrollFrame)

    -- Preview Text Box
    local previewLabel = aceGUI:Create('Label')
    previewLabel:SetFullWidth(true)
    previewLabel:SetFullHeight(true)
    previewLabel:SetFontObject('GameFontHighlight')
    previewLabel:SetColor(1, 1, 1)
    previewLabel:SetJustifyH('LEFT')
    previewLabel:SetJustifyV('TOP')
    previewLabel:SetText('')
    previewScrollFrame:AddChild(previewLabel)
    tblFrame.preview = previewLabel
end
-- *Create Home Frame
function home:CreateHomeFrame()
    local tblFrame, tblBase = self.tblFrame, ns.win.base.tblFrame

    -- Base Regular Frame
    local f = tblFrame.frame or CreateFrame('Frame', 'GR_HOME_FRAME', tblBase.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 20)
    f:SetPoint('BOTTOMRIGHT', tblBase.statusBar, 'TOPRIGHT', 0, -5)
    tblFrame.frame = f

    -- Ace GUI Frame for Ace Controls
    local inline = tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    tblFrame.inline = inline

    self:CreateInviteArea()
    self:CreateMessageSelection()
    self:CreateMessagePreview()

    self:MessageChanged(ns.pSettings.activeMessage)
end

-- *Support Functions
function home:GetWhisperMessages()
    local tblWhispers = {}
    local tblGMMessages = ns.gmSettings.messageList and ns.gmSettings.messageList or {}
    local tblPlayerMessages = ns.pSettings.messageList and ns.pSettings.messageList or {}

    self.tblWhipsers = table.wipe(self.tblWhipsers or {})
    local hasGuildLink = ns.guildInfo.guildLink ~= '' or false
    for _, r in pairs(tblGMMessages) do
        local msg = r.message
        local desc = ns.code:cText(GM_DESC_COLOR, r.desc)
        if hasGuildLink then msg = msg:gsub(L['GUILDLINK'], ns.guildInfo.guildLink) end
        tblWhispers[#tblWhispers + 1] = { message = msg, desc = desc, type = 'GM' }
    end

    for _, r in pairs(tblPlayerMessages) do
        local msg = r.message
        if hasGuildLink then msg = msg:gsub(L['GUILDLINK'], ns.guildInfo.guildLink) end
        tblWhispers[#tblWhispers + 1] = { message = msg, desc = r.desc, type = 'PLAYER' }
    end

    return tblWhispers
end
function home:MessageChanged(val)
    if not val or val == '' then return
    elseif type(val) ~= 'string' then val = tonumber(val) end

    self.activeMessage = nil
    ns.pSettings.activeMessage = val
    self.activeMessage = self.tblWhipsers[val].message:gsub('|c', ''):gsub('|r', ''):gsub(GM_DESC_COLOR, '')
    self.activeMessage = ns.code:variableReplacement(self.activeMessage)

    home:CreatePreview()
    --! Set Button States
end
function home:CreatePreview()
    local invFormat, msg = ns.pSettings.inviteFormat, nil

    if invFormat == 2 then msg = L['GUILD_INVITE_ONLY']
    elseif not self.activeMessage or self.activeMessage == '' then msg = L['SELECT_MESSAGE']
    else
        msg = ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName
        msg = msg..ns.code:cText('FFFF80FF', ']: '..(ns.code:variableReplacement(self.activeMessage, UnitName('player')) or ''))
    end
    self.tblFrame.preview:SetText(msg or '')
end
home:Init()