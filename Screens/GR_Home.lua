local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.screen.home = {}
local home = ns.screen.home

-- Observer Call Backs
local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)

    if not home.tblFrame.frame or not home.tblFrame.inline then return end
    home.tblFrame.frame:SetShown(false)
    home.tblFrame.inline.frame:Hide()
end

function home:Init()
    self.tblFrame = {}
    self.tblFilters = {}
    self.tblWhipsers = {}

    self.max = MAX_CHARACTER_LEVEL

    self.tblFormat = {
        [1] = 'Message ONLY',
        [2] = 'Guild Invite ONLY',
        [3] = 'Guild Invite and Message',
        --[4] = 'Message Only if Invitation is declined',
    }
end
function home:EnterHomeScreen()
    local tblScreen = ns.screen.tblFrame
    if not tblScreen.frame then return end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    -- Get Whisper Messages
    self.tblMessages = table.wipe(self.tblMessages or {})
    self.tblMessages = ns.ds:WhisperMessages('PERFORM_CHECK')

    for _,r in pairs(self.tblMessages) do
        r.desc = r.gmMessage and ns.code:cText(GM_DESC_COLOR, r.desc) or r.desc
    end

    -- Get Filters
    local tbl = {
        [1] = 'Default Class Filter',
        [2] = 'Default Race Filter',
    }
    for k, r in pairs(ns.db.filter.filterList and ns.db.filter.filterList or {}) do tbl[k+10] = r.desc end
    self.tblFilters = tbl

    if self.tblFrame.inline then
        self.tblFrame.inline:ReleaseChildren()
    end

    tblScreen.frame:SetSize(500, 300) -- Resi

    self:BuildHomeScreen()
    self.tblFrame.frame:SetShown(true)
    ns.screen.tblFrame.frame:SetShown(true)
end
function home:BuildHomeScreen()
    local tblFrame = self.tblFrame
    local tblScreen = ns.screen.tblFrame
    if not tblScreen.frame then return end

    -- Base Regular Frame
    local f = tblFrame.frame or CreateFrame('Frame', 'GR_HOME_FRAME', tblScreen.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:SetPoint('TOPLEFT', tblScreen.titleFrame, 'BOTTOMLEFT', -5, 20)
    f:SetPoint('BOTTOMRIGHT', tblScreen.statusBar, 'TOPRIGHT', 0, -5)
    tblFrame.frame = f

    -- Ace GUI Frame for Ace Controls
    local inline = tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    tblFrame.inline = inline

    -- DropDown for Message Format Ace3
    local formatDrop = aceGUI:Create('Dropdown')
    formatDrop:SetLabel('Recruit Invite Format:')
    formatDrop:SetRelativeWidth(.5)
    formatDrop:SetList(self.tblFormat)
    formatDrop:SetValue(ns.settings.inviteFormat or 2)
    formatDrop:SetCallback('OnValueChanged', function(_, _, val)
        ns.settings.inviteFormat = tonumber(val)

        self:CreatePreview()
        self:SetButtonStates()
    end)
    inline:AddChild(formatDrop)

    tblFrame.format = formatDrop

    -- Padding for level boxes
    ns.code:createPadding(inline, .03)

    -- Minimum level for filter Ace3
    local minLevelBox = aceGUI:Create('EditBox')
    minLevelBox:SetLabel('Min Level')
    minLevelBox:SetText(ns.settings.minLevel)
    minLevelBox:SetMaxLetters(2)
    minLevelBox:SetRelativeWidth(.13)
    minLevelBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local maxLevel = ns.settings.maxLevel and tonumber(ns.settings.maxLevel) or MAX_CHARACTER_LEVEL
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        local min = tonumber(val:trim()) or nil
        if not min then error = true
        elseif min > maxLevel then error = true msg = 'You must enter a minimum level that is less than max level.'
        elseif not min or (min < 1 or min > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(ns.settings.minLevel or '1')
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else ns.settings.minLevel = val:trim() or nil end
        self.min = ns.settings.minLevel or 1
    end)
    inline:AddChild(minLevelBox)
    tblFrame.minLevel = minLevelBox

    -- Padding for max level box
    ns.code:createPadding(inline, .02)

    -- Maximum level for filter Ace3
    self.max = ns.settings.maxLevel or MAX_CHARACTER_LEVEL
    local maxLevelBox = aceGUI:Create('EditBox')
    maxLevelBox:SetLabel('Max Level')
    maxLevelBox:SetText(ns.settings.maxLevel)
    maxLevelBox:SetMaxLetters(2)
    maxLevelBox:SetRelativeWidth(.13)
    maxLevelBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local minLevel = ns.settings.minLevel and tonumber(ns.settings.minLevel) or 1
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        local max = tonumber(val:trim()) or nil
        if not max then error = true
        elseif max <= minLevel then error = true msg = 'Your max level must be equal or larger then minimum.'
        elseif not max or (max < 1 or max > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(ns.settings.maxLevel or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else ns.settings.maxLevel = val:trim() or nil end
        self.max = ns.settings.maxLevel or MAX_CHARACTER_LEVEL
    end)
    inline:AddChild(maxLevelBox)
    tblFrame.maxLevel = maxLevelBox

    -- Padding for Scan  Button
    ns.code:createPadding(inline, .03)

    -- Scan Button Ace3
    local scanButton = aceGUI:Create('Button')
    scanButton:SetText('Scan')
    scanButton:SetRelativeWidth(.15)
    scanButton:SetCallback('OnClick', function()
        tblScreen.statusText:SetText('')
        local msgID = ns.dbGlobal.activeMessage
        local msg = self.tblMessages[msgID] and self.tblMessages[msgID].message or nil

        ns.scanner:ShowScanner(msg, self.min, self.max)
    end)
    inline:AddChild(scanButton)
    tblFrame.scanButton = scanButton

    -- Convert self.tblMessages to a table for Ace3
    local tbl = {}
    for k, r in pairs(self.tblMessages) do
        tbl[k] = r.desc
    end

    -- Message List DropDown Ace3
    local msgListDropDown = aceGUI:Create('Dropdown')
    msgListDropDown:SetLabel('Message List:')
    msgListDropDown:SetRelativeWidth(.5)
    msgListDropDown:SetList(tbl)
    msgListDropDown:SetValue(ns.dbGlobal.activeMessage or 1)
    msgListDropDown:SetCallback('OnValueChanged', function(_, _, val)
        ns.dbGlobal.activeMessage = tonumber(val)

        self:CreatePreview()
        self:SetButtonStates()
    end)
    inline:AddChild(msgListDropDown)
    tblFrame.msgList = msgListDropDown

    -- Filter List DropDown Ace3
    local filterListDropDown = aceGUI:Create('Dropdown')
    filterListDropDown:SetLabel('Filter List:')
    filterListDropDown:SetRelativeWidth(.5)
    filterListDropDown:SetList(self.tblFilters)
    filterListDropDown:SetValue(ns.settings.activeFilter or 1)
    filterListDropDown:SetCallback('OnValueChanged', function(_, _, val) ns.db.filter.activeFilter = (val == 0 and 99 or val) end)
    inline:AddChild(filterListDropDown)
    tblFrame.filterList = filterListDropDown

    -- Preview Inline Group
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

    local val = msgListDropDown:GetValue()
    if val and val > 0 then ns.dbGlobal.activeMessage = val end

    self:CreatePreview()
    self:SetButtonStates()
end

function home:SetButtonStates()
    local msgID = ns.dbGlobal.activeMessage
    local msg = self.tblMessages[msgID] and self.tblMessages[msgID] or nil

    self.tblFrame.scanButton:SetDisabled(false)
    if (not msgID or not msg) and (ns.settings.inviteFormat and ns.settings.inviteFormat ~= 2) then
        self.tblFrame.scanButton:SetDisabled(true)
        ns.screen.tblFrame.statusText:SetText(ns.code:cText('FFFF0000', 'Select message or create one in settings.'))
    else ns.screen.tblFrame.statusText:SetText('') end
end
function home:CreatePreview()
    local msg = ''
    if ns.db.settings.inviteFormat == 2 then msg = 'No message will be sent. Only guild invite will be sent.'
    else
        local activeMsg = ns.dbGlobal.activeMessage or nil

        if not activeMsg then msg = ''
        elseif not self.tblMessages[activeMsg] or not self.tblMessages[activeMsg].message then msg = ''
        else
            local preview = self.tblMessages[activeMsg].message or nil
            msg = ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName
            msg = msg..ns.code:cText('FFFF80FF', ']: '..(ns.code:variableReplacement(preview, UnitName('player')) or ''))
        end
    end
    self.tblFrame.preview:SetText(msg)
end
home:Init()