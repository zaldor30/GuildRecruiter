-- Guild Recruiter Main Screen
local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.MainScreen = {}
local mainScreen = ns.MainScreen
function mainScreen:Init()
    self.maintActive = false
    self.scanIsDisabled = false

    self.defaultStatus = GR_VERSION_INFO

    self.tblFormat = {
        [1] = 'Message ONLY',
        [2] = 'Guild Invite ONLY',
        [3] = 'Guild Invite and Message',
        --[4] = 'Message Only if Invitation is declined',
    }

    self.f = nil
    self.btnScan = aceGUI:Create('Button')
    self.cmbMessages = aceGUI:Create('Dropdown')
    self.errLabel = aceGUI:Create('Label')

    self.filterDrop = aceGUI:Create('Dropdown')

    self.grpAnal = aceGUI:Create('ScrollFrame')

    self.btnSettings = aceGUI:Create('Button')
    self.syncButton = aceGUI:Create('Button')
    self.labelSync = aceGUI:Create('Label')
end
-- Sync
function mainScreen:UpdateSyncTime(msg) self.labelSync:SetText('Last Sync: '..(msg or (ns.db.settings.lastSync or '<none>'))) end
function mainScreen:SyncStatus(isDisabled, isMaster, msg) -- Disable and re-enable sync button
   if not isMaster then
        self.btnScan:SetDisabled(not isDisabled and self.scanIsDisabled or isDisabled)
        self.syncButton:SetDisabled(isDisabled)
   end

    mainScreen:UpdateSyncTime(msg)
end
-- Main Screen Update Routines
function mainScreen:SetButtons()
    -- Scan Button
    local msg = ''
    local db, dbMsg = ns.db.settings, ns.db.messages

    self.btnScan:SetDisabled(false)
    if dbMsg and dbMsg.activeMessage then
        dbMsg.activeMessage = (not dbMsg or not dbMsg.activeMessage) and nil or ((not dbMsg.messageList or not dbMsg.messageList[dbMsg.activeMessage]) and nil or ((dbMsg and dbMsg.activeMessage) or nil))
    end
    if db.inviteFormat == 2 then self.errLabel:SetText('') return
    elseif not dbMsg or ((not db.inviteFormat or db.inviteFormat ~= 2) and (not dbMsg.messageList or #dbMsg.messageList == 0)) then
        msg = 'No messages created in settings.'
        self.errLabel:SetText(msg)
        self.btnScan:SetDisabled(true)
    elseif not dbMsg.activeMessage and db.inviteFormat ~= 2 then
        msg = 'You need to select a message.'
        self.errLabel:SetText(msg)
        self.btnScan:SetDisabled(true)
    end

    self.errLabel:SetText(msg) -- Refresh?
end
function mainScreen:GetMessageList()
    local db, dbMsg = ns.db, ns.db.messages

    if dbMsg then
        local tbl, hasGuildLink = {}, db.guildInfo.guildLink or false

        ns.datasets:GMessages()
        for k, r in pairs(ns.datasets.tblGMMessages or {}) do
            local gLinkFound = strfind(r.message, 'GUILDLINK') or false
            if not gLinkFound or (gLinkFound and hasGuildLink)  then
                if not r.gmMessage then tbl[k] = r.desc
                elseif r.gmMessage then tbl[k] = ns.code:cText('FFAF640C', r.desc) end
            elseif not hasGuildLink and gLinkFound and k == dbMsg.activeMessage then dbMsg.activeMessage = nil end
        end
        self.cmbMessages:SetList(tbl)

        dbMsg.activeMessage = (dbMsg.activeMessage and tbl[dbMsg.activeMessage]) and dbMsg.activeMessage or nil
        self.cmbMessages:SetValue(dbMsg.activeMessage)
    end
end
function mainScreen:FilterList() -- Add 10 to custom index to compensate for defaults
    local db = ns.db
    local tbl = {
        [1] = 'Default Class Filter',
        [2] = 'Default Race Filter',
    }
    for k, r in pairs(db.filter.filterList or {}) do tbl[k+10] = r.desc end

    db.filter.activeFilter = (not db.filter or not db.filter.activeFilter) and 1 or (db.filter.activeFilter == 99 and 1 or (db.filter.activeFilter or 1))
    self.filterDrop:SetList(tbl)
    self.filterDrop:SetValue(db.filter.activeFilter)
end
function mainScreen:RefreshAnalytics()
    local function analyticsHeader(title)
        local heading = aceGUI:Create("Label")
        heading:SetText(title)
        heading:SetHeight(12)
        heading:SetFullWidth(true)
        heading:SetColor(1, 0.82, 0)  -- Set the text color
        heading:SetFontObject(GameFontHighlightLarge)  -- Set the font style
        self.grpAnal:AddChild(heading)
    end
    local function addAnalytics(field, isGlobal)
        local desc = gsub(field, '_', ' ')

        local label = aceGUI:Create('Label')
        label:SetText(desc..': '..ns.Analytics:get(field, isGlobal))
        label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
        label:SetFullWidth(true)
        self.grpAnal:AddChild(label)
    end

    self.grpAnal:ReleaseChildren()
    local tblAnalytics = ns.Analytics:getFields()

    analyticsHeader(UnitName('player')..' Stats:')
    for _, r in pairs(tblAnalytics) do addAnalytics(r) end
    analyticsHeader('Account Stats:')
    for _, r in pairs(tblAnalytics) do addAnalytics(r, 'isGlobal') end
end
-- Build Main Screen Routines
function mainScreen:ShowMainScreen()
    ns.events:RegisterEvent('CHAT_MSG_SYSTEM')
    ns.events:RegisterEvent('GUILD_ROSTER_UPDATE')

    ns.db.settings.minLevel = ns.db.settings.minLevel or tostring(MAX_CHARACTER_LEVEL - 5)
    ns.db.settings.maxLevel = ns.db.settings.maxLevel or tostring(MAX_CHARACTER_LEVEL)
    if self.f then self.f:Show()
    else
        self.f = aceGUI:Create('Frame')
        self.f:SetTitle('Guild Recruiter')
        self.f:SetStatusText(self.defaultStatus)
        self.f:EnableResize(false)
        self.f:SetWidth(500)
        self.f:SetHeight(380)
        self.f:SetLayout('flow')
        self.f:SetCallback('OnShow', function(widget)
            mainScreen:SetButtons()
            mainScreen:RefreshAnalytics()
        end)

        mainScreen:Top()
        mainScreen:Filter()
        mainScreen:Analytics()
    end

    _G["GuildRecruiter"] = self.f
    tinsert(UISpecialFrames, "GuildRecruiter")

    mainScreen:SetButtons()
    mainScreen:FilterList()
    mainScreen:GetMessageList()
    mainScreen:RefreshAnalytics()
end
function mainScreen:Top()
    local grpSearch = aceGUI:Create('InlineGroup')
    grpSearch:SetTitle('Search Options')
    grpSearch:ClearAllPoints()
    grpSearch:SetLayout("flow")
    grpSearch:SetFullWidth(true)
    grpSearch:SetHeight(250)
    self.f:AddChild(grpSearch)

    local msgDrop = aceGUI:Create('Dropdown') -- Select invite type
    msgDrop:SetLabel('Invite Format')
    msgDrop:SetRelativeWidth(.5)
    msgDrop:SetList(self.tblFormat)
    msgDrop:SetValue(ns.db.settings.inviteFormat or 2)
    msgDrop:SetCallback('OnValueChanged', function(_, _, val)
        ns.db.settings.inviteFormat = tonumber(val)
        mainScreen:SetButtons()
    end)
    grpSearch:AddChild(msgDrop)

    ns.widgets:createPadding(grpSearch, .03)

    local editBox = aceGUI:Create('EditBox') -- Minimum level for filter
    editBox:SetLabel('Min Level')
    editBox:SetText(ns.db.settings.minLevel)
    editBox:SetMaxLetters(2)
    editBox:SetRelativeWidth(.13)
    editBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local maxLevel = ns.db.settings.maxLevel and tonumber(ns.db.settings.maxLevel) or MAX_CHARACTER_LEVEL
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        local min = tonumber(val:trim()) or nil
        if not min then error = true
        elseif min > maxLevel then error = true msg = 'You must enter a minimum level that is less than max level.'
        elseif not min or (min < 1 or min > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(ns.db.settings.minLevel or '1')
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else ns.db.settings.minLevel = val:trim() or nil end
    end)
    grpSearch:AddChild(editBox)

    ns.widgets:createPadding(grpSearch, .02)

    local editBoxMax = aceGUI:Create('EditBox') -- Maximum level for filter
    editBoxMax:SetLabel('Max Level')
    editBoxMax:SetText(ns.db.settings.maxLevel)
    editBoxMax:SetMaxLetters(2)
    editBoxMax:SetRelativeWidth(.13)
    editBoxMax:SetCallback('OnEnterPressed', function(widget,_, val)
        local minLevel = ns.db.settings.minLevel and tonumber(ns.db.settings.minLevel) or 1
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        local max = tonumber(val:trim()) or nil
        if not max then error = true
        elseif max <= minLevel then error = true msg = 'Your max level must be equal or larger then minimum.'
        elseif not max or (max < 1 or max > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(ns.db.settings.maxLevel or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else ns.db.settings.maxLevel = val:trim() or nil end
    end)
    grpSearch:AddChild(editBoxMax)

    ns.widgets:createPadding(grpSearch, .03)
    self.btnScan:SetText('Scan') -- Scan button
    self.btnScan:SetRelativeWidth(.15)
    self.btnScan:SetCallback('OnClick', function()
        if not ns.db.messages.activeMessage and ns.db.settings.inviteFormat ~= 2 then
            local msg = ns.code.cText('FFFF0000', 'You must select a valid message.')
            self.errLabel:SetText(msg)
            self.errLabel:SetText(msg) -- Refresh?
        else
            self.errLabel:SetText('')
            ns.ScreenInvite:StartScreenScanner()
            self.f:Hide()
        end
    end)

    grpSearch:AddChild(self.btnScan)

    -- Dropdown of messages to send
    local cmb = self.cmbMessages
    cmb:SetLabel('Active Invite Message')
    cmb:SetCallback('OnEnter', function() ns.widgets:createTooltip('Invite Messages', 'Highlighted messages are GM approved.') end)
    cmb:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    cmb:SetCallback('OnValueChanged', function(_,_, val)
        ns.db.messages.activeMessage = val
        mainScreen:SetButtons()
    end)
    grpSearch:AddChild(cmb)

    ns.widgets:createPadding(grpSearch, .03)

    self.errLabel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    self.errLabel:SetRelativeWidth(.5)
    self.errLabel:SetPoint("BOTTOM", grpSearch.frame, "BOTTOM", 0, -30)
    grpSearch:AddChild(self.errLabel)
end
function mainScreen:Filter()
    local grpFilter = aceGUI:Create('InlineGroup')
    grpFilter:ClearAllPoints()
    grpFilter:SetTitle('Available Filters')
    grpFilter:SetLayout("flow")
    grpFilter:SetWidth(215)
    grpFilter:SetHeight(150)
    self.f:AddChild(grpFilter)

    local dropdown = self.filterDrop
    dropdown:SetLabel('Filters')
    dropdown:SetFullWidth(true)
    dropdown:SetCallback('OnValueChanged', function(_, _, val) ns.db.filter.activeFilter = (val == 0 and 99 or val) end)
    grpFilter:AddChild(dropdown)

    local btn = self.btnSettings -- Start scan button
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function()
        self.f:Hide()
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
    end)
    grpFilter:AddChild(btn)

    btn = self.syncButton
    btn:SetText('Sync')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function() ns.Sync:StartSyncMaster() end)
    grpFilter:AddChild(btn)

    local label = self.labelSync
    label:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    label:SetFullWidth(true)
    grpFilter:AddChild(label)
    mainScreen:UpdateSyncTime()
end
function mainScreen:Analytics()
    local inlineGroup = aceGUI:Create('InlineGroup')
    inlineGroup:ClearAllPoints()
    inlineGroup:SetTitle('Statistics')
    inlineGroup:SetLayout("Fill")
    inlineGroup:SetWidth(250)
    inlineGroup:SetHeight(150)
    self.f:AddChild(inlineGroup)

    self.grpAnal:SetFullWidth(true)
    self.grpAnal:SetFullHeight(true)
    self.grpAnal:SetLayout("Flow")
    inlineGroup:AddChild(self.grpAnal)
end
mainScreen:Init()