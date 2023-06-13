-- Guild Recruiter Main Screen
local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")
local p,g = nil, nil

ns.MainScreen = {}
local mainScreen = ns.MainScreen
function mainScreen:Init()
    self.f = nil
    self.cmbMessages = aceGUI:Create('Dropdown')
    self.btnScan = aceGUI:Create('Button')
    self.errLabel = aceGUI:Create('Label')
    self.grpAnal = aceGUI:Create('ScrollFrame')
end
function mainScreen:AddAnalytics(field, isGlobal)
    local desc = gsub(field, '_', ' ')

    local label = aceGUI:Create('Label')
    label:SetText(desc..': '..ns.Analytics:get(field, isGlobal))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    self.grpAnal:AddChild(label)
end
function mainScreen:GetMessageList()
    if (not p.inviteFormat or p.inviteFormat ~= 2) and (not g.messages or #g.messages == 0) then
        self.errLabel:SetText('You need create a message in options, click on settings.')
        self.btnScan:SetDisabled(true)
        return
    elseif g.messages then
        local tbl = {}
        for k, r in pairs(g.messages) do
            local gLinkFound = strfind(r.message, 'GUILDLINK')
            if (gLinkFound and p.guildInfo.guildLink) or not gLinkFound then tbl[k] = r.desc
            elseif not p.guildInfo.guildLink and gLinkFound and k == p.activeMessage then p.activeMessage = nil end
        end
        return tbl
    end
end
function mainScreen:FilterGroup_List()
    local tbl = {}
    tbl[1] = 'Default Class Filter'
    tbl[2] = 'Default Race Filter'
    if g.filter then
        for k, r in pairs(g.filter) do
            table(tbl, {[k] = g.filter[r].desc})
        end
    end
    return tbl
end
function mainScreen:Refresh(analyticsOnly)
    if not analyticsOnly then
        self.cmbMessages:SetList(mainScreen:GetMessageList())
        self.cmbMessages:SetValue(p and p.activeMessage or nil)
        mainScreen:FilterGroup_List()
    end

    local function analyticsHeader(title)
        local heading = aceGUI:Create("Label")
        heading:SetText(title)
        heading:SetFontObject(GameFontHighlightLarge)  -- Set the font style
        heading:SetColor(1, 0.82, 0)  -- Set the text color
        heading:SetFullWidth(true)
        heading:SetHeight(12)
        self.grpAnal:AddChild(heading)
    end

    self.grpAnal:ReleaseChildren()
    local tblAnalytics = ns.Analytics:getFields()
    analyticsHeader(UnitName('player')..' Stats:')
    for _, r in pairs(tblAnalytics) do mainScreen:AddAnalytics(r) end
    analyticsHeader('Account Stats:')
    for _, r in pairs(tblAnalytics) do mainScreen:AddAnalytics(r, 'isGlobal') end
end
function mainScreen:ShowMainScreen()
    p,g = ns.db.profile, ns.db.global
    if not p.inviteFormat then p.inviteFormat = 2 end

    if self.f then
        self.f:Show()
        mainScreen:Refresh()
        return
    end

    self.f = aceGUI:Create('Frame')
    self.f:SetTitle('Guild Recruiter')
    self.f:SetStatusText('Guild Recruiter v'..GRADDON.version)
    self.f:EnableResize(false)
    self.f:SetWidth(500)
    self.f:SetHeight(380)
    self.f:SetLayout('flow')
    self.f:SetCallback('OnClose', function(widget)
    end)

    -- Allows for ESC to exit
    _G["GuildRecruiter"] = self.f
    tinsert(UISpecialFrames, "GuildRecruiter")

    mainScreen:TopOptions()
    mainScreen:FilterOptions()
    ns.widgets:createPadding(self.f, 20)
    mainScreen:Analytics()
    mainScreen:Refresh('ANAL_ONLY')
end
function mainScreen:TopOptions()
    local editBox = nil

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
    msgDrop:SetList({
        [1] = 'Message ONLY',
        [2] = 'Guild Invite ONLY',
        [3] = 'Guild Invite and Message',
        [4] = 'Message Only if Invitation is declined',
    })
    msgDrop:SetValue(p and p.inviteFormat or 2)
    msgDrop:SetCallback('OnValueChanged', function(_, _, val)
        local msg = 'You must go to settings and create a message before using this option.'
        if val ~= 2 and not g.messages then
            self.errLabel:SetText(msg)
            self.btnScan:SetDisabled(true)
        else
            self.errLabel:SetText('')
            self.btnScan:SetDisabled(false)
        end
        p.inviteFormat = val
    end)
    grpSearch:AddChild(msgDrop)

    ns.widgets:createPadding(grpSearch, .03)
    editBox = aceGUI:Create('EditBox') -- Minimum level for filter
    editBox:SetLabel('Min Level')
    editBox:SetText(p and p.minLevel or '1')
    editBox:SetMaxLetters(2)
    editBox:SetRelativeWidth(.13)
    editBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local maxLevel = p.maxLevel and tonumber(p.maxLevel) or MAX_CHARACTER_LEVEL
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val > maxLevel then error = true msg = 'You must enter a minimum level that is less than max level.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(p.minLevel or '1')
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else p.minLevel = val end
    end)
    grpSearch:AddChild(editBox)

    ns.widgets:createPadding(grpSearch, .02)
    local editBoxMax = aceGUI:Create('EditBox') -- Maximum level for filter
    editBoxMax:SetLabel('Max Level')
    editBoxMax:SetText(p and p.maxLevel or tostring(MAX_CHARACTER_LEVEL))
    editBoxMax:SetMaxLetters(2)
    editBoxMax:SetRelativeWidth(.13)
    editBoxMax:SetCallback('OnEnterPressed', function(widget,_, val)
        local minLevel = p.minLevel and tonumber(p.minLevel) or 1
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val <= minLevel then error = true msg = 'Your max level must be equal or larger then minimum.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(p.maxLevel or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else p.maxLevel = val end
    end)
    grpSearch:AddChild(editBoxMax)

    ns.widgets:createPadding(grpSearch, .03)
    self.btnScan:SetText('Scan') -- Scan button
    self.btnScan:SetRelativeWidth(.15)
    self.btnScan:SetCallback('OnClick', function(_,_)
        if not p.activeMessage and p.inviteFormat ~= 2 then
            self.errLabel:SetText(ns.code.cText('FFFF0000', 'You must select a valid message.'))
        else
            self.errLabel:SetText('')
            ns.ScreenInvite:StartScreenScanner()
            self.f:Hide()
        end
    end)
    grpSearch:AddChild(self.btnScan)

    local cmb = self.cmbMessages -- Dropdown of messages to send
    cmb:SetLabel('Active Message')
    cmb:SetList(mainScreen:GetMessageList())
    cmb:SetValue(p and p.activeMessage or nil)
    cmb:SetCallback('OnValueChanged', function(_,_, val) p.activeMessage = val end)
    grpSearch:AddChild(cmb)

    ns.widgets:createPadding(grpSearch, .03)
    self.errLabel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    self.errLabel:SetRelativeWidth(.5)
    grpSearch:AddChild(self.errLabel)
end
function mainScreen:FilterOptions()
    local dropdown, btn = nil, nil

    local grpFilter = aceGUI:Create('InlineGroup')
    grpFilter:ClearAllPoints()
    grpFilter:SetTitle('Available Filters')
    grpFilter:SetLayout("flow")
    grpFilter:SetWidth(215)
    grpFilter:SetHeight(150)
    self.f:AddChild(grpFilter)

    dropdown = aceGUI:Create('Dropdown')
    dropdown:SetLabel('Filters')
    dropdown:SetRelativeWidth(1)
    dropdown:SetList(mainScreen:FilterGroup_List())
    dropdown:SetValue(p and ((p.activeFilter and p.activeFilter == 99) and 1 or (p.activeFilter or 1)) or 1)
    dropdown:SetFullWidth(true)
    dropdown:SetCallback('OnValueChanged', function(_, _, val) p.activeFilter = (val == 0 and 99 or val) end)
    grpFilter:AddChild(dropdown)

    btn = aceGUI:Create('Button') -- Start scan button
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, button)
        self.f:Hide()
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
    end)
    grpFilter:AddChild(btn)

    btn = aceGUI:Create('Button') -- Start scan button
    btn:SetText('Sync')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, button) ns:SyncData() end)
    grpFilter:AddChild(btn)
end
function mainScreen:Analytics()
    local inlineGroup = aceGUI:Create('InlineGroup')
    inlineGroup:ClearAllPoints()
    inlineGroup:SetTitle('Statistics')
    inlineGroup:SetLayout("Fill")
    inlineGroup:SetWidth(230)
    inlineGroup:SetHeight(150)
    self.f:AddChild(inlineGroup)

    self.grpAnal:SetFullWidth(true)
    self.grpAnal:SetFullHeight(true)
    self.grpAnal:SetLayout("Flow")
    inlineGroup:AddChild(self.grpAnal)

    mainScreen:Refresh('analyticsOnly')
end
mainScreen:Init()