local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.win.scanner = {}
local scanner = ns.win.scanner

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    scanner:SetShown(false)
end
local function CallBackWhoListUpdate()
    ns.events:Unregister('WHO_LIST_UPDATE', CallBackWhoListUpdate)

    ns.analytics:saveStats('PlayersScanned', C_FriendList.GetNumWhoResults())

    local sessionStats = ns.analytics:getSessionStats('PlayersScanned')
    scanner:UpdateAnalytics()

    scanner:ProcessWhoList(C_FriendList.GetNumWhoResults())
end

function scanner:Init()
    self.tblScanner = {} -- Defaults Table
    self.invMessage = nil -- Invite Message

    self.ctrlBase = {} -- Base frame/controls table
    self.ctrlInvite = {} -- Invite frame/controls table
    self.ctrlWho = {} -- Who frame/controls table
    self.ctrlSearch = {} -- Search frame/controls table
    self.ctrlAnalyics = {} -- Analytics frame/controls table

    --* Data Tables
    self.tblWho = {} -- Who Results Table
    self.tblInvites = {} -- Players Ready for Invite
    self.tblFilters = nil -- Filter TableZ

    self.waitTimer = 0 -- Wait time remaining for next scan
end
function scanner:IsShown() return self.ctrlBase.frame and self.ctrlBase.frame:IsShown() end
function scanner:SetShown(isShown)
    local tblBase = ns.win.base.tblFrame

    if not isShown then
        tblBase.backButton:SetShown(false)
        tblBase.resetButton:SetShown(false)
        tblBase.compactButton:SetShown(false)
        ns.statusText:SetText('')

        if self.ctrlBase.inline then
            self.ctrlBase.inline:ReleaseChildren()
            self.ctrlBase.inline.frame:Hide()

            self.ctrlInvite = table.wipe(self.ctrlInvite or {})
            self.ctrlWho = table.wipe(self.ctrlWho or {})
            self.ctrlSearch = table.wipe(self.ctrlSearch or {})
            self.ctrlAnalyics = table.wipe(self.ctrlAnalyics or {})
        end

        return
    end

    --* Event Routines
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    --* Set Scanner Defaults
    self.tblScanner = {
        minLevel = ns.pSettings.minLevel or MAX_CHARACTER_LEVEL - 5, -- Default to 5 levels below max
        maxLevel = ns.pSettings.maxLevel or MAX_CHARACTER_LEVEL, -- Default to max level
        isCompact = ns.pSettings.isCompact or false,
        scanWaitTime = ns.gSettings.scanWaitTime or ns.core.addonSettings.global.settings.scanWaitTime or 6,
        -- Send Invite Message and Post Join Messages
        greetingMessage = ns.pSettings.greetingMessage or '', -- Greeting Message (guild chat) for new guild members
        whisperMessage = ns.pSettings.whisperMessage or '', -- Whisper Message (whisper) for new guild members
        inviteMessage = ns.pSettings.activeMessage or ns.win.home.activeMessage or '',
        -- Filter Settings
        activeFilter = ns.pSettings.activeFilter or 1,
        activeQuery = self.tblScanner.activeQuery or '',
        filterCount = self.tblScanner.filterCount or 0,
        totalFilters = self.tblScanner.totalFilters or 0,
    }

    --* Setup Base Frame
    tblBase.backButton:SetShown(true)
    tblBase.resetButton:SetShown(true)
    tblBase.compactButton:SetShown(true)
    ns.statusText:SetText('')

    local x, y = (self.tblScanner.isCompact and 215 or 600), (self.tblScanner.isCompact and 470 or 475)
    ns.win.base:SetShown(true)
    ns.win.base.tblFrame.frame:SetSize(x, y)

    --* Create Frames
    self:CreateBaseFrame() -- Uses ctrlBase
    self:CreateInviteFrame() -- Uses ctrlInvite
    self:CreateWhoFrame() -- Uses ctrlWho
    self:CreateStartSearchFrame() -- Uses ctrlSearch
    self:CreateAnalyticsFrame() -- Uses ctrlAnalytics

    --* Populate Data
    self:DisplayWhoList() -- Display Who List
    self:DispalyInviteList() -- Display Invite List

    if not self.tblFilters or ns.win.home.resetFilters then
        ns.win.home.resetFilters = false
        self.tblFilters = {}
        self:ResetFilters()
    end

    self:DisplayNextFilter() -- Display Next Filter
    self:UpdateAnalytics()
    self:SetInviteButtonsState()
end
function scanner:CreateBaseFrame()
    --? Uses ctrlBase for controls/frame
    local tblHome = ns.win.base.tblFrame -- Home Frame or main screen

    -- Base Regular Frame (With Scan Keybind)
    local f = self.ctrlBase.frame or CreateFrame('Frame', 'GR_SCANNER_FRAME', tblHome.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:EnableMouse(false)
    f:SetPropagateKeyboardInput(true)
    f:SetPoint('TOPLEFT', tblHome.topFrame, 'BOTTOMLEFT', -5, 20)
    f:SetPoint('BOTTOMRIGHT', tblHome.statusBar, 'TOPRIGHT', 0, -5)
    f:SetScript('OnKeyDown', function(_, key)
        if ns.global.keybindScan and key == ns.global.keybindScan then
            if self.waitTimer and self.waitTimer > 0 then
                ns.code:fOut(L['PLEASE_WAIT']..' '..self.waitTimer..' '..L['ERROR_SCAN_WAIT'])
            elseif self.ctrlSearch.btnSearch.disabled then ns.code:fOut(L['ERROR_CANNOT_SCAN'])
            else self:GetNextFilterRecord() end
        elseif ns.global.keybindInvite and key == ns.global.keybindInvite then self:InvitePlayers() end
    end)
    f:SetShown(true)
    self.ctrlBase.frame = f

    -- Ace GUI Frame for Ace Controls
    local inline = self.ctrlBase.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:Show()
    self.ctrlBase.inline = inline
end
function scanner:CreateInviteFrame()
    --? Uses ctrlInvite for contrls/frame
    -- Base Inline Group for Invite Controls
    local inlineInvite = self.ctrlInvite.inline or aceGUI:Create('InlineGroup')
    inlineInvite:SetLayout('Flow')
    inlineInvite:SetRelativeWidth(self.tblScanner.isCompact and 1 or .4)
    inlineInvite.frame:SetFrameStrata(DEFAULT_STRATA)
    inlineInvite:SetHeight(200)
    self.ctrlBase.inline:AddChild(inlineInvite)
    self.ctrlInvite.inline = inlineInvite

    -- Invite ScrollBox
    local scrollInvite = self.ctrlInvite.scrollInvite or aceGUI:Create('ScrollFrame')
    scrollInvite:SetLayout('Flow')
    scrollInvite:SetFullWidth(true)
    scrollInvite:SetHeight(160)
    inlineInvite:AddChild(scrollInvite)
    self.ctrlInvite.scrollInvite = scrollInvite

    -- Invite Button
    local btnInvite = self.ctrlInvite.btnInvite or aceGUI:Create('Button')
    btnInvite:SetText(L['INVITE'])
    btnInvite:SetRelativeWidth(.5)
    btnInvite:SetDisabled(true)
    btnInvite:SetCallback('OnEnter', function()
        local title = L['INVITE_BUTTON_TOOLTIP']
        local body = L['INVITE_BUTTON_BODY_TOOLTIP']
        ns.code:createTooltip(title, body)
    end)
    btnInvite:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnInvite:SetCallback('OnClick', function() self:InvitePlayers() end)
    inlineInvite:AddChild(btnInvite)
    self.ctrlInvite.btnInvite = btnInvite

    -- Black List Player Button
    local btnRemove = self.ctrlInvite.btnRemove or aceGUI:Create('Button')
    btnRemove:SetText(L['BL'])
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetDisabled(true)
    btnRemove:SetCallback('OnEnter', function()
        local title = L['BL_BUTTON_TOOLTIP']
        local body = L['SKIP_BUTTON_BODY_TOOLTIP']
        ns.code:createTooltip(title, body)
    end)
    btnRemove:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnRemove:SetCallback('OnClick', function(...) scanner:BlackListPlayer() end)
    inlineInvite:AddChild(btnRemove)
    self.ctrlInvite.btnRemove = btnRemove

    -- Skip Button
    local btnSkip = self.ctrlInvite.btnSkip or aceGUI:Create('Button')
    btnSkip:SetText(L['SKIP'])
    btnSkip:SetRelativeWidth(.5)
    btnSkip:SetDisabled(true)
    btnSkip:SetCallback('OnEnter', function()
        local title = L['SKIP_BUTTON_TOOLTIP']
        local body = L['SKIP_BUTTON_BODY_TOOLTIP']
        ns.code:createTooltip(title, body)
    end)
    btnSkip:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnSkip:SetCallback('OnClick', function() self:SkipPlayerInvite() end)
    inlineInvite:AddChild(btnSkip)
    self.ctrlInvite.btnSkip = btnSkip

    -- Players found using the /who command
    local lblFound = self.ctrlInvite.lblFound or aceGUI:Create("Label")
    lblFound:SetText(L['READY_INVITE']..': '..#self.tblInvites)
    lblFound:SetRelativeWidth(.5)
    inlineInvite:AddChild(lblFound)
    self.ctrlInvite.lblFound = lblFound
end
function scanner:CreateWhoFrame()
    if self.tblScanner.isCompact then return end

    --? Uses ctrlWho for controls/frame
    --? Uses tblWho for data
    -- Base Inline Group for Who Controls
    local inlineWho = self.ctrlWho.inline or aceGUI:Create('InlineGroup')
    inlineWho:SetLayout('Flow')
    inlineWho:SetRelativeWidth(.6)
    self.ctrlBase.inline:AddChild(inlineWho)
    self.ctrlWho.inline = inlineWho

    -- Who ScrollBox
    local scrollWho = self.ctrlWho.scrollWho or aceGUI:Create('ScrollFrame')
    scrollWho:SetLayout('Flow')
    scrollWho:SetFullWidth(true)
    scrollWho:SetHeight(200)
    inlineWho:AddChild(scrollWho)
    self.ctrlWho.scrollWho = scrollWho

    -- Who Results Text
    local lblWho = aceGUI:Create("Label")
    lblWho:SetText(L['NUMBER_PLAYERS_FOUND']..': '..(#self.tblWho or 0))
    lblWho:SetFullWidth(true)
    lblWho:SetRelativeWidth(.5)
    inlineWho:AddChild(lblWho)
    self.ctrlWho.lblWhoFound = lblWho

    -- Who Current Query Text
    local lblWhoQuery = aceGUI:Create("Label")
    lblWhoQuery:SetText(self.tblScanner.activeQuery or '')
    lblWhoQuery:SetFullWidth(true)
    lblWhoQuery:SetRelativeWidth(.5)
    inlineWho:AddChild(lblWhoQuery)
    self.ctrlWho.lblWhoQuery = lblWhoQuery
end
function scanner:CreateStartSearchFrame()
    --? Uses ctrlSearch for controls/frame
    --? Uses tblInvites for data

    -- Base Inline Group for Scan Controls
    local inlineScan = aceGUI:Create('InlineGroup')
    inlineScan:SetLayout('Flow')
    inlineScan:SetHeight(150)
    inlineScan:SetRelativeWidth(self.tblScanner.isCompact and 1 or .4)
    inlineScan.frame:SetFrameStrata(DEFAULT_STRATA)
    self.ctrlBase.inline:AddChild(inlineScan)

    -- Scan Button
    local btnSearch = aceGUI:Create('Button')
    btnSearch:SetText('Start Search')
    btnSearch:SetFullWidth(true)
    btnSearch:SetCallback('OnClick', function() self:GetNextFilterRecord() end)
    inlineScan:AddChild(btnSearch)
    self.ctrlSearch.btnSearch = btnSearch

    -- Next Filter Title
    local lblNextTitle = aceGUI:Create("Label")
    lblNextTitle:SetText(L['NEXT_FILTER']..': ')
    lblNextTitle:SetFont(DEFAULT_FONT, 10, 'OUTLINE')
    lblNextTitle:SetFullWidth(true)
    inlineScan:AddChild(lblNextTitle)

    -- Next Filter Text
    local lblNextFilter = aceGUI:Create("Label")
    lblNextFilter:SetText(' ')
    lblNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblNextFilter:SetFullWidth(true)
    inlineScan:AddChild(lblNextFilter)
    self.ctrlSearch.lblNextFilter = lblNextFilter
end
function scanner:CreateAnalyticsFrame()
    if self.tblScanner.isCompact then return end
    --? Uses ctrlAnalytics for controls/frame
    --? Uses tblAnalytics for data

    -- Base Inline Group for Analytics Controls
    local inlineAnalytics = aceGUI:Create('InlineGroup')
    inlineAnalytics:SetLayout('Flow')
    inlineAnalytics:SetRelativeWidth(.6)
    inlineAnalytics:SetTitle('Session Analytics:')
    inlineAnalytics:SetHeight(95)
    self.ctrlBase.inline:AddChild(inlineAnalytics)

    -- Left Analytic ScrollBox
    local scrollLeftAnalytic = aceGUI:Create('ScrollFrame')
    scrollLeftAnalytic:SetLayout('Flow')
    scrollLeftAnalytic:SetRelativeWidth(.5)
    scrollLeftAnalytic:SetHeight(55)
    inlineAnalytics:AddChild(scrollLeftAnalytic)

    -- Right Analytic ScrollBox
    local scrollRightAnalytic = aceGUI:Create('ScrollFrame')
    scrollRightAnalytic:SetLayout('Flow')
    scrollRightAnalytic:SetRelativeWidth(.5)
    scrollRightAnalytic:SetHeight(55)
    inlineAnalytics:AddChild(scrollRightAnalytic)

    -- Left Analytic Controls
    local lblScanned = aceGUI:Create("Label")
    lblScanned:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblScanned:SetText(' ')
    lblScanned:SetFullWidth(true)
    scrollLeftAnalytic:AddChild(lblScanned)
    self.ctrlAnalyics.lblPlayersScanned = lblScanned

    local lblInvited = aceGUI:Create("Label")
    lblInvited:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblInvited:SetText(' ')
    lblInvited:SetFullWidth(true)
    scrollLeftAnalytic:AddChild(lblInvited)
    self.ctrlAnalyics.lblTotalInvites = lblInvited

    local lblWaitingOn = aceGUI:Create("Label")
    lblWaitingOn:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblWaitingOn:SetText(' ')
    lblWaitingOn:SetFullWidth(true)
    scrollLeftAnalytic:AddChild(lblWaitingOn)
    self.ctrlAnalyics.lblWaitingOn = lblWaitingOn

    -- Right Analytic Controls
    local lblDeclined = aceGUI:Create("Label")
    lblDeclined:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblDeclined:SetText(' ')
    lblDeclined:SetFullWidth(true)
    scrollRightAnalytic:AddChild(lblDeclined)
    self.ctrlAnalyics.lblDeclined = lblDeclined

    local lblTotalAccepted = aceGUI:Create("Label")
    lblTotalAccepted:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalAccepted:SetText(' ')
    lblTotalAccepted:SetFullWidth(true)
    scrollRightAnalytic:AddChild(lblTotalAccepted)
    self.ctrlAnalyics.lblAccepted = lblTotalAccepted

    local lblBlackList = aceGUI:Create("Label")
    lblBlackList:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblBlackList:SetText(' ')
    lblBlackList:SetFullWidth(true)
    scrollRightAnalytic:AddChild(lblBlackList)
    self.ctrlAnalyics.lblTotalBlackList = lblBlackList
end
function scanner:ChangeCompactMode()
    self.tblScanner.isCompact = not self.tblScanner.isCompact
    ns.pSettings.isCompact = self.tblScanner.isCompact

    self:SetShown(true)
end
function scanner:UpdateAnalytics()
    if not self.ctrlBase.frame
        or self.tblScanner.isCompacts
        or not self.ctrlAnalyics.lblPlayersScanned then return end

    local sessionStats = ns.analytics:getSessionStats('PlayersScanned')
    self.ctrlAnalyics.lblPlayersScanned:SetText(L['TOTAL_SCANNED']..': '..sessionStats)

    sessionStats = ns.analytics:getSessionStats('PlayersInvited')
    self.ctrlAnalyics.lblTotalInvites:SetText(L['TOTAL_INVITED']..': '..sessionStats)

    sessionStats = ns.analytics:getSessionStats('WaitingOnInvite')
    self.ctrlAnalyics.lblWaitingOn:SetText(L['INVITES_PENDING']..': '..sessionStats)

    sessionStats = ns.analytics:getSessionStats('PlayersDeclined')
    self.ctrlAnalyics.lblDeclined:SetText(L['TOTAL_DECLINED']..': '..sessionStats)

    sessionStats = ns.analytics:getSessionStats('PlayersJoined')
    self.ctrlAnalyics.lblAccepted:SetText(L['TOTAL_ACCEPTED']..': '..sessionStats)

    sessionStats = ns.analytics:getSessionStats('PlayersBlackListed')
    self.ctrlAnalyics.lblTotalBlackList:SetText(L['TOTAL_BLACKLISTED']..': '..sessionStats)
end

--* Invite Routines
-- Button Routines
function scanner:SkipPlayerInvite()
    local tbl = {}
    for k, v in pairs(self.tblInvites) do
        if v.isChecked then
            if ns.antiSpam:AddToAntiSpamList(v.fullName) then
                tbl[k] = true end
        end
    end
    for k in pairs(tbl) do self.tblInvites[k] = nil end
    ns.code:saveTables('ANTI_SPAM_LIST')

    -- Update Data and Button State
    self:DisplayWhoList()
    self:DispalyInviteList()
    self:SetInviteButtonsState()
end
function scanner:BlackListPlayer()
    local tbl = {}
    for k, v in pairs(self.tblInvites) do
        if v.isChecked then
            if ns.blackList:AddToBlackList(v.fullName, 'Black listed by Scanner') then
                tbl[k] = true end
        end
    end
    for k in pairs(tbl) do self.tblInvites[k] = nil end
    ns.code:saveTables('BLACK_LIST')

    -- Update Data and Button State
    self:DisplayWhoList()
    self:DispalyInviteList()
    self:SetInviteButtonsState()
end
function scanner:InvitePlayers()
    local key, tbl = next(self.tblInvites)
    if not tbl then return end

    self.tblInvites[key] = nil
    self:DispalyInviteList()

ns.invite:SendAutoInvite(tbl.fullName, (select(2, UnitClass(tbl.fullName)) or nil), ((ns.pSettings.inviteFormat ~= 2) or false), ((ns.pSettings.inviteFormat ~= 1) or false))
end
function scanner:SetInviteButtonsState()
    local anyChecked, count = false, 0
    for _, v in pairs(self.tblInvites) do
        if v.isChecked then anyChecked = true break
        else count = count + 1 end
    end

    if anyChecked then
        self.ctrlInvite.btnInvite:SetDisabled(true)
        self.ctrlInvite.btnRemove:SetDisabled(false)
        self.ctrlInvite.btnSkip:SetDisabled(false)
    elseif count > 0 then
        self.ctrlInvite.btnInvite:SetDisabled(false)
        self.ctrlInvite.btnRemove:SetDisabled(true)
        self.ctrlInvite.btnSkip:SetDisabled(true)
    else
        self.ctrlInvite.btnInvite:SetDisabled(true)
        self.ctrlInvite.btnRemove:SetDisabled(true)
        self.ctrlInvite.btnSkip:SetDisabled(true)
    end
end
-- Parsing Invite Routines
function scanner:DispalyInviteList()
    local tblInvites, invControls = self.tblInvites, self.ctrlInvite

    -- Create Checkboxes for each player
    local function createCheckBox(fullName, pName, pClass, pLevel, isChecked)
        pLevel = tonumber(pLevel)
        local maxLevel = tonumber(scanner.tblScanner.maxLevel)
        local levelOut = pLevel < maxLevel and ns.code:cText('FFFFFF00', pLevel) or ns.code:cText('FF00FF00', pLevel)

        local cb = aceGUI:Create('CheckBox')
        cb:SetLabel(ns.code:cPlayer(pName, pClass))
        cb:SetRelativeWidth(.85)
        cb:SetValue(isChecked)
        cb:SetCallback('OnValueChanged', function(_, _, value)
            if not tblInvites[fullName] then return end

            tblInvites[fullName].isChecked = value
            scanner:SetInviteButtonsState()
        end)
        invControls.scrollInvite:AddChild(cb)

        local lb = aceGUI:Create('Label')
        lb:SetText(levelOut)
        lb:SetRelativeWidth(.15)
        lb:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        invControls.scrollInvite:AddChild(lb)
    end

    -- Display CheckBoxes
    invControls.scrollInvite:ReleaseChildren()
    local tbl = ns.code:sortTableByField(tblInvites, 'fullName') or {}

    for _, v in pairs(tbl) do
        createCheckBox(v.fullName, v.name, v.class, v.level, v.isChecked)
    end

    invControls.lblFound:SetText(L['READY_INVITE']..': '..#tbl)
    scanner:SetInviteButtonsState()
end
function scanner:ParsePlayersToInvite()
    local tblWho = self.tblWho
    local tblInvites = self.tblInvites

    for _, v in ipairs(tblWho) do
        if not tblInvites[v.fullName] and v.guild == '' then
            tblInvites[v.fullName] = v end
    end

    self:DispalyInviteList()
end

--* Who Routines
function scanner:DisplayWhoList()
    if self.tblScanner.isCompact then return end

    local tblWho = self.tblWho
    local whoControls = self.ctrlWho

    local function createWhoEntry(r)
        local lblLevel = aceGUI:Create("Label")
        lblLevel:SetText(r.level)
        lblLevel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblLevel:SetRelativeWidth(.1)
        whoControls.scrollWho:AddChild(lblLevel)

        local lblName = aceGUI:Create("Label")
        lblName:SetText(ns.code:cPlayer(r.name, r.class) or 'No Name')
        lblName:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblName:SetRelativeWidth(.35)
        whoControls.scrollWho:AddChild(lblName)

        local lblGuild = aceGUI:Create("Label")
        lblGuild:SetText(r.guild or '')
        lblGuild:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblGuild:SetRelativeWidth(.52)
        whoControls.scrollWho:AddChild(lblGuild)

        return lblLevel
    end

    whoControls.lblWhoFound:SetText(L['NUMBER_PLAYERS_FOUND']..': '..#tblWho)
    whoControls.scrollWho:ReleaseChildren()
    for k, v in ipairs(tblWho) do
        local lblLevel = nil
        if not self.tblInvites[k] and v.guild == '' then
            local inviteOkResult = ns.invite:whoInviteChecks(v)
            if inviteOkResult then v.guild = ns.code:cText('FFFF0000', '('..inviteOkResult..')') end

            lblLevel = createWhoEntry(v)
            lblLevel:SetText(ns.code:cText((not inviteOkResult and 'FF00FF00' or 'FFFFFFFF'), v.level))
        else lblLevel = createWhoEntry(v) end
    end
end
function scanner:ProcessWhoList(whoResults)
    self.tblWho = table.wipe(self.tblWho) or {}

    for i = 1, whoResults do
        local info = C_FriendList.GetWhoInfo(i)
        local pName = strmatch(info.fullName, GetRealmName()) and info.fullName:gsub('-.*', '') or info.fullName
        local rec = {
            fullName = info.fullName,
            name = pName,
            class = info.filename,
            level = info.level,
            guild = info.fullGuildName or '',
            zone = info.area,
            isChecked = false,
        }

        tinsert(self.tblWho, rec)
    end

    -- ToDo: Analytics
    self:DisplayWhoList()
    self:ParsePlayersToInvite()
end

--* Filter Routines
function scanner:ResetFilters() self:CreateFilters() end
function scanner:DisplayNextFilter() self:CreateFilters(true) end
function scanner:GetNextFilterRecord() self:CreateFilters(false, true) end
function scanner:CreateFilters(displayOnly, nextRecord)
    --? Uses tblFilters for data
    if displayOnly and self.tblFilters then
        local desc = (self.tblFilters and self.tblFilters[1]) and self.tblFilters[1].desc or nil
        self.ctrlSearch.lblNextFilter:SetText(desc or '')
        return
    elseif nextRecord and self.tblFilters then
        local tbl = tremove(self.tblFilters, 1)
        if not tbl then self:ResetFilters() return end
        self:DisplayNextFilter()

        -- Update Progress
        self.tblScanner.filterCount = self.tblScanner.filterCount + 1
        ns.statusText:SetText(L['FILTER_PROGRESS']..': '..FormatPercentage(self.tblScanner.filterCount/self.tblScanner.totalFilters, 2))

        -- Start Who Query
        FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
        ns.events:RegisterEvent('WHO_LIST_UPDATE', CallBackWhoListUpdate)

        C_FriendList.SetWhoToUi(true)
        C_FriendList.SendWho(tbl.who)

        local function waitTimer(remain)
            if not self.ctrlSearch.btnSearch then return
            elseif remain > 0 then
                self.waitTimer = remain
                self.ctrlSearch.btnSearch:SetDisabled(true)
                self.ctrlSearch.btnSearch:SetText('Wait '..remain..'s')
                C_Timer.After(1, function() waitTimer(remain - 1) end)
            else
                self.waitTimer = 0
                self.ctrlSearch.btnSearch:SetDisabled(false)
                self.ctrlSearch.btnSearch:SetText('Start Search')
            end
        end
        waitTimer(self.tblScanner.scanWaitTime or 6)

        return
    end

    local function createClassFilter()
        for _, v in pairs(ns.tblClassesSortedByName) do
            local query = 'c-"'..v.name..'"'
            local min, max = tonumber(self.tblScanner.minLevel), tonumber(self.tblScanner.maxLevel)

            while min <= max do
                local rangeEnd = min + 5 > max and max or min + 5
                self.tblFilters[#self.tblFilters + 1] = {
                    desc = v.name..' ('..min..'-'..rangeEnd..')',
                    who = query..' '..min..'-'..rangeEnd,
                }

                min = (rangeEnd < max and (rangeEnd - min > 0)) and rangeEnd or max + 1
                if max - min > 0 then min = min + 1 end
            end
        end
    end
    local function createRaceFilter()
        for _, v in pairs(ns.tblRacesSortedByName) do
            local query = 'r-"'..v.name..'"'
            local min, max = tonumber(self.tblScanner.minLevel), tonumber(self.tblScanner.maxLevel)

            while min <= max do
                local rangeEnd = min + 5 > max and max or min + 5
                self.tblFilters[#self.tblFilters + 1] = {
                    desc = v.name..' ('..min..'-'..rangeEnd..')',
                    who = query..' '..min..'-'..rangeEnd,
                }

                min = (rangeEnd < max and (rangeEnd - min > 0)) and rangeEnd or max + 1
                if max - min > 0 then min = min + 1 end
            end
        end
    end
    local function createCustomFilter()
    end

    self.tblFilters = table.wipe(self.tblFilters or {})
    local activeFilter = self.tblScanner.activeFilter
    if activeFilter == 1 then createClassFilter()
    elseif activeFilter == 2 then createRaceFilter()
    elseif activeFilter >= 3 then createCustomFilter() end

    ns.statusText:SetText('')
    self.tblScanner.activeQuery = ''
    self.tblScanner.filterCount = 0
    self.tblScanner.totalFilters = self.tblFilters and #self.tblFilters or 0
    self:DisplayNextFilter()
end
scanner:Init()

-- ToDo: Check Keybinds (Add to scanner:CreateBaseFrame)
-- ToDo: Create Analytics (Add to scanner:CreateAnalyticsFrame)
-- ToDo: Create Analytics (Add to scanner:ProcessWhoList)
-- ToDo: Create Custom Filters (Add to scanner:CreateFilters)