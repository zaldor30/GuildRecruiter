local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

local aceGUI = LibStub("AceGUI-3.0")

ns.screens.home = {}

-- Observer Call Backs
local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)
    if not ns.screens.home.tblFrame.frame or not ns.screens.home.tblFrame.inline then return end

    ns.screens.home.tblFrame.frame:SetShown(false)
    ns.screens.home.tblFrame.inline.frame:Hide()
end
local home = ns.screens.home
function home:Init()
    self.tblFrame = {}
    self.tblFilters = {}
    self.tblWhipsers = {}

    self.max = MAX_CHARACTER_LEVEL

    self.tblFormat = {
        [1] = L['Message ONLY'],
        [2] = L['Guild Invite ONLY'],
        [3] = L['Guild Invite and Message'],
        --[4] = 'Message Only if Invitation is declined',
    }
end
function home:StartUp()
    local tblHome = ns.screens.base.tblFrame
    if not tblHome.frame then return end

    -- Setup for Close Routines
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    -- Get Invite Messages
    self.tblWhipsers = self:WhisperMessages('PERFORM_CHECK')

    -- Get Filters
    self.tblFilters = {
        [1] = L['Default Class Filter'],
        [2] = L['Default Race Filter'],
    }
    for k, r in pairs(ns.gSettings.filterList and ns.gSettings.filterList or {}) do self.tblFilters[k+100] = r.desc end

    -- Clear home Ace3 children
    if self.tblFrame.inline then
        self.tblFrame.inline:ReleaseChildren()
    end

    self:BuildHomeScreen()

    ns.screens.base.tblFrame.frame:SetSize(500, 300)
    ns.screens.base.tblFrame.frame:SetShown(true)
end
-- Build the Home screens
function home:BuildHomeScreen()
    local tblFrame, tblBase = self.tblFrame, ns.screens.base.tblFrame
    if not tblBase then return end

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

    self:BuildInviteArea()
    self:DropDownArea()
    self:BuildPreviewArea()

    self:SetButtonStates()
    self:CreatePreview()
end
-- Invite Area Routines
function home:BuildInviteArea()
    local inline = self.tblFrame.inline
    local tblFrame, tblBase = self.tblFrame, ns.screens.base.tblFrame

    -- Set Default Invite Format
    ns.settings.inviteFormat = ns.settings.inviteFormat or 2

    -- DropDown for Message Format Ace3
    local formatDrop = aceGUI:Create('Dropdown')
    formatDrop:SetLabel(L['Recruit Invite Format:'])
    formatDrop:SetRelativeWidth(.5)
    formatDrop:SetList(self.tblFormat)
    formatDrop:SetValue(ns.settings.inviteFormat or 2)
    formatDrop:SetCallback('OnValueChanged', function(_, _, val)
        ns.settings.inviteFormat = tonumber(val)

        self:CreatePreview()
        self:SetButtonStates()
    end)
    inline:AddChild(formatDrop)

    -- Padding for level boxes
    ns.code:createPadding(inline, .03)

    -- Minimum level for filter Ace3
    local minLevelBox = aceGUI:Create('EditBox')
    minLevelBox:SetLabel(L['Min Level'])
    minLevelBox:SetText(ns.settings.minLevel)
    minLevelBox:SetMaxLetters(2)
    minLevelBox:SetRelativeWidth(.13)
    minLevelBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local errMsg = nil
        local ilvlHold = ns.settings.minLevel or MAX_CHARACTER_LEVEL - 4
        if type(tonumber(val:trim())) ~= 'number' or (tonumber(val:trim()) < 0 or tonumber(val:trim()) > MAX_CHARACTER_LEVEL) then
            errMsg = L['You must enter a number between 1 and']..' '..tostring(MAX_CHARACTER_LEVEL)
        else
            local min = tonumber(val:trim()) or nil
            local maxLevel = ns.settings.maxLevel and tonumber(ns.settings.maxLevel) or MAX_CHARACTER_LEVEL

            if min > maxLevel then errMsg = L['Min level must be less than max level set.'] end
        end

        if errMsg then
            widget:SetText(ilvlHold or '1')
            UIErrorsFrame:AddMessage(errMsg, 1.0, 0.1, 0.1, 1.0)
            self.min = ilvlHold
            return
        else ns.settings.minLevel = val:trim() or nil end
        self.min = tonumber(ns.settings.minLevel or ilvlHold)
    end)
    inline:AddChild(minLevelBox)
    tblFrame.minLevel = minLevelBox

    -- Padding for max level box
    ns.code:createPadding(inline, .02)

    -- Maximum level for filter Ace3
    self.max = ns.settings.maxLevel or MAX_CHARACTER_LEVEL
    local maxLevelBox = aceGUI:Create('EditBox')
    maxLevelBox:SetLabel(L['Max Level'])
    maxLevelBox:SetText(ns.settings.maxLevel)
    maxLevelBox:SetMaxLetters(2)
    maxLevelBox:SetRelativeWidth(.13)
    maxLevelBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local errMsg = nil
        local ilvlHold = ns.settings.minLevel or MAX_CHARACTER_LEVEL - 4

        if type(tonumber(val:trim())) ~= 'number' or (tonumber(val:trim()) < 0 or tonumber(val:trim()) > MAX_CHARACTER_LEVEL) then
            errMsg = L['You must enter a number between 1 and']..' '..tostring(MAX_CHARACTER_LEVEL)
        else
            local max = tonumber(val:trim()) or nil
            local minLevel = ns.settings.minLevel and tonumber(ns.settings.minLevel) or 1
            if max <= minLevel then
                errMsg = L['Your max level must be equal or larger then minimum.'] end
        end

        if errMsg then
            widget:SetText(ilvlHold or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(errMsg, 1.0, 0.1, 0.1, 1.0)
            self.max = ilvlHold
            return
        else ns.settings.maxLevel = val:trim() or nil end
        self.max = tonumber(ns.settings.maxLevel) or MAX_CHARACTER_LEVEL
    end)
    inline:AddChild(maxLevelBox)
    tblFrame.maxLevel = maxLevelBox

    -- Padding for Scan  Button
    ns.code:createPadding(inline, .03)

    -- Scan Button Ace3
    local scanButton = aceGUI:Create('Button')
    scanButton:SetText(L['Scan'])
    scanButton:SetRelativeWidth(.15)
    scanButton:SetCallback('OnClick', function()
        tblBase.statusText:SetText('')
        local msgID = ns.settings.activeMessage
        local msg = (msgID and self.tblWhipsers[msgID]) and self.tblWhipsers[msgID].message or nil
        if ns.settings.inviteFormat ~= 2 and (not msgID or not msg) then
            tblFrame.statusText:SetText(ns.code:cText('FFFF0000', L['Select a message from the list or create one in settings.']))
            return
        end

        ns.screens.scanner:StartUp(msg)
    end)
    inline:AddChild(scanButton)
    tblFrame.scanButton = scanButton
end
-- DropDowns Area Routines
function home:DropDownArea()
    local inline = self.tblFrame.inline
    local tblFrame = self.tblFrame

    -- Convert self.tblWhipsers to a table for Ace3
    local tbl = {}
    for k, r in pairs(self.tblWhipsers) do
        tbl[k] = r.desc
    end

    -- Message List DropDown Ace3
    local msgListDropDown = aceGUI:Create('Dropdown')
    msgListDropDown:SetLabel(L['Message List']..':')
    msgListDropDown:SetRelativeWidth(.5)
    msgListDropDown:SetList(tbl)
    msgListDropDown:SetValue(ns.settings.activeMessage or 1)
    msgListDropDown:SetCallback('OnValueChanged', function(_, _, val)
        ns.settings.activeMessage = tonumber(val)

        self:CreatePreview()
        self:SetButtonStates()
    end)
    inline:AddChild(msgListDropDown)
    tblFrame.msgList = msgListDropDown

    -- Filter List DropDown Ace3
    local filterListDropDown = aceGUI:Create('Dropdown')
    filterListDropDown:SetLabel(L['Filter List']..':')
    filterListDropDown:SetRelativeWidth(.5)
    filterListDropDown:SetList(self.tblFilters)
    filterListDropDown:SetValue(ns.settings.activeFilter or 1)
    filterListDropDown:SetCallback('OnValueChanged', function(_, _, val) ns.gSettings.activeFilter = (val == 0 and 99 or val) end)
    inline:AddChild(filterListDropDown)
    tblFrame.filterList = filterListDropDown
end
-- Preview Area Routines
function home:BuildPreviewArea()
    local inline = self.tblFrame.inline
    local tblFrame = self.tblFrame
    local msgListDropDown = tblFrame.msgList

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
    if val and val > 0 then ns.settings.activeMessage = val end
end

-- Other Routines
function home:WhisperMessages()
    local dbGuildInfo = ns.dbGlobal.guildInfo
    local tblWhispers = {}
    local tblGMMessages = ns.gmSettings.messageList and ns.gmSettings.messageList or {}
    local tblPlayerMessages = ns.gSettings.messageList and ns.gSettings.messageList or {}

    tblWhispers = table.wipe(ns.screens.home.tblMessages or {})
    local hasGuildLink = dbGuildInfo.guildLink and true or false
    for _, r in pairs(tblGMMessages) do
        local includesGuildLink = strmatch(r.message, 'GUILDLINK')
        if not includesGuildLink or (hasGuildLink and includesGuildLink) then
            tblWhispers[#tblWhispers + 1] = { desc = ns.code:cText(GM_DESC_COLOR, r.desc), gmMessage = r.gmMessage, message = r.message }
        end
    end

    local id = 100
    for _, r in pairs(tblPlayerMessages) do
        local includesGuildLink = strmatch(r.message, 'GUILDLINK')
        if not includesGuildLink or (hasGuildLink and includesGuildLink) then
            id = id + 1
            tblWhispers[id] = { desc = r.desc, gmMessage = r.gmMessage, message = r.message }
        end
    end

    return tblWhispers
end
function home:SetButtonStates()
    local msgID, invFormat = ns.settings.activeMessage, ns.settings.inviteFormat
    local msg = self.tblWhipsers[msgID] and self.tblWhipsers[msgID] or nil

    self.tblFrame.scanButton:SetDisabled(false)
    if (not msgID or not msg) and (invFormat and invFormat ~= 2) then
        self.tblFrame.scanButton:SetDisabled(true)
        ns.screens.base.tblFrame.statusText:SetText(ns.code:cText('FFFF0000', 'Select message or create one in settings.'))
    else ns.screens.base.tblFrame.statusText:SetText('') end
end
function home:CreatePreview()
    local msg = nil
    local msgID, invFormat = ns.settings.activeMessage, ns.settings.inviteFormat

    if invFormat == 2 then msg = L['No message will be sent. Only guild invite will be sent.']
    elseif not msgID then msg = L['Select a message from the list or create one in settings.']
    else
        ns.code:realMessageID(msgID)

        if not self.tblWhipsers[msgID] or not self.tblWhipsers[msgID].message then
            msg = L['Select a message from the list or create one in settings.']
        else
            local preview = self.tblWhipsers[msgID].message or nil
            msg = ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName
            msg = msg..ns.code:cText('FFFF80FF', ']: '..(ns.code:variableReplacement(preview, UnitName('player')) or ''))
        end
    end
    self.tblFrame.preview:SetText(msg)
end
home:Init()