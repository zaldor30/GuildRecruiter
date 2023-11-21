local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.screens.scanner = {}

local function obsCLOSE_SCREENS_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    local tblBase, tblFrame = ns.screens.base.tblFrame, ns.screens.scanner.tblFrame
    if not tblBase.frame then return end

    tblBase.backButton:SetShown(false)
    tblBase.resetButton:SetShown(false)
    tblBase.compactButton:SetShown(false)
    tblBase.statusText:SetText('')

    if not tblFrame.frame then return end
    tblFrame.frame:SetShown(false)
    tblFrame.inline.frame:Hide()
end
local function CallBackWhoListUpdate()
    local scanner = ns.screens.scanner
    local tblConnected, tblFrame = ns.tblConnectedRealms, scanner.tblFrame.inline.controls
    local tblWho, tblInvites = scanner.tblWho, scanner.tblInvites
    ns.events:Unregister('WHO_LIST_UPDATE', CallBackWhoListUpdate)

    tblInvites = tblInvites or {}
    tblWho = table.wipe(tblWho) or {}

    if not scanner.isCompact then
        tblFrame.lblWho:SetText(L['WHO_NUMBER_FOUND_DESC']..': '..C_FriendList.GetNumWhoResults())
    end

    for i=1, C_FriendList.GetNumWhoResults() do
        local info = C_FriendList.GetWhoInfo(i)
        local pName = #tblConnected > 0 and info.fullName or info.fullName:gsub('-.*', '')
        local rec = {fullName = info.fullName, name = pName, class = info.filename, level = info.level, guild = (info.fullGuildName or ''), zone = info.area}
        tinsert(tblWho, rec)
    end

    ns.analytics:saveStats('PlayersScanned', C_FriendList.GetNumWhoResults(), true)
    scanner:UpdateAnalyticsSection()
    scanner:ShowResults('BOTH')
end

local SCAN_WAIT_TIME = 6
local scanner = ns.screens.scanner
function scanner:Init()
    self.tblFrame = {}

    self.isCompact = false

    self.tblWho = {}
    self.tblInvites = {}

    self.tblFilter = nil
    self.totalFilters = 0 -- Used for progress

    self.whisperMessage = nil
    self.minLevel, self.maxLevel = 1, MAX_CHARACTER_LEVEL

    self.scanWaitTime = 0
end
function scanner:StartUp(whisperMessage, minLevel, maxLevel)
    local tblBase, tblFrame = ns.screens.base.tblFrame, self.tblFrame

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    self.isCompact = ns.settings.isCompact or false
    self.activeFilter = ns.settings.activeFilter or 1
    self.whisperMessage = whisperMessage or nil
    self.minLevel, self.maxLevel = (minLevel or 1), (maxLevel or MAX_CHARACTER_LEVEL)

    tblBase.backButton:SetShown(true)
    tblBase.resetButton:SetShown(true)
    tblBase.compactButton:SetShown(true)

    scanner:SwitchCompactMode()
end
function scanner:BuildScannerScreen()
    local tblBase, tblFrame = ns.screens.base.tblFrame, self.tblFrame

    -- Base Regular Frame (With Scan Keybind)
    local f = tblFrame.frame or CreateFrame('Frame', 'GR_SCANNER_FRAME', tblBase.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:EnableMouse(false)
    f:SetPropagateKeyboardInput(true)
    f:SetScript('OnKeyDown', function(_, key)
        if ns.db.global.keybindScan and key == ns.db.global.keybindScan then
            if self.scanWaitTime > 0 then
                ns.code:fOut(L['Please wait']..' '..self.scanWaitTime..' '..L['ERROR_SCAN_WAIT'])
            elseif self.tblFrame.controls.btnSearch.disabled then ns.code:fOut(L['ERROR_CANNOT_SCAN'])
            else self:GetNextFilterRecord() end
        elseif ns.db.global.keybindInvite and key == ns.db.global.keybindInvite then self:InvitePlayers() end
    end)
    f:SetShown(true)
    tblFrame.frame = f

    -- Ace GUI Frame for Ace Controls
    local inline = tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:Show()
    tblFrame.inline = inline
end
function scanner:BuildInviteAndWho()
    local inline = self.tblFrame.inline
    local tblControls = inline.controls or {}

    -- Invite Control
    local inlineInvite = aceGUI:Create('InlineGroup')
    inlineInvite:SetLayout('Flow')
    inlineInvite:SetTitle(L['Invites:'])
    inlineInvite:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineInvite:SetHeight(200)
    inline:AddChild(inlineInvite)
    tblControls.inlineInvite = inlineInvite

    local scrollInvite = aceGUI:Create('ScrollFrame')
    scrollInvite:SetLayout('Flow')
    scrollInvite:SetFullWidth(true)
    scrollInvite:SetHeight(160)
    inlineInvite:AddChild(scrollInvite)
    tblControls.scrollInvite = scrollInvite

    local btnInvite = aceGUI:Create('Button')
    btnInvite:SetText('Invite')
    btnInvite:SetRelativeWidth(.5)
    btnInvite:SetDisabled(true)
    btnInvite:SetCallback('OnEnter', function()
        local title = L['Invite players to guild']
        local body = L['Checked players are for adding to black list.']
        ns.code:createTooltip(title, body)
    end)
    btnInvite:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnInvite:SetCallback('OnClick', function(_, button, key) self:InvitePlayers() end)
    inlineInvite:AddChild(btnInvite)
    tblControls.btnInvite = btnInvite

    local btnRemove = tblControls.btnRemove or aceGUI:Create('Button')
    btnRemove:SetText(L['BL'])
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetDisabled(true)
    btnRemove:SetCallback('OnEnter', function()
        local title = L['Black List Players']
        local body = L['Selected players will be added to the black list.']
        ns.code:createTooltip(title, body)
    end)
    btnRemove:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnRemove:SetCallback('OnClick', function()
        local msg = L['ADD_TO_BL_PROMPT']
        local func = function()
            for k, r in pairs(self.tblInvites) do
                if r.isChecked then
                    ns.blackList:AddToBlackList(k, 'BULK_ADD_BLACKLIST')
                    self.tblInvites[k] = nil
                end
            end

            self:ShowResults('INVITE', true)
            self:SetButtonStates()
        end
        ns.code:Confirmation(msg, func)
    end)
    inlineInvite:AddChild(btnRemove)
    tblControls.btnRemove = btnRemove

    local lblFound = tblControls.lblFound or aceGUI:Create("Label")
    lblFound:SetText(L['Ready for invite']..': '..#self.tblInvites)
    lblFound:SetRelativeWidth(.5)
    inlineInvite:AddChild(lblFound)
    tblControls.lblFound = lblFound

    local btnSkip = tblControls.btnSkip or aceGUI:Create('Button')
    btnSkip:SetText('Skip')
    btnSkip:SetRelativeWidth(.5)
    btnSkip:SetDisabled(true)
    btnSkip:SetCallback('OnClick', function()
        for k, r in pairs(self.tblInvites) do
            if r.isChecked and ns.invite:AddToInvitedList(k, (r.class or nil)) then
                self.tblInvites[k] = nil end
        end

        self:ShowResults('INVITE', true)
        self:SetButtonStates()
    end)
    btnSkip:SetCallback('OnEnter', function()
        local title = L['Skip players']
        local body = ns.code:wordWrap(L['SKIP_DESC'])
        ns.code:createTooltip(title, body)
    end)
    btnSkip:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    inlineInvite:AddChild(btnSkip)
    tblControls.btnSkip = btnSkip

    -- Who Control
    if not self.isCompact then
        local inlineWho = tblControls.inlineWho or nil
        if not inlineWho then
            inlineWho = aceGUI:Create('InlineGroup')
            inlineWho:SetTitle(L['Who Results']..':')
            inlineWho:SetLayout('Flow')
            inlineWho:SetRelativeWidth(.6)
            inline:AddChild(inlineWho)
            tblControls.whoInline = inlineWho
        end

        local whoScroll = aceGUI:Create('ScrollFrame')
        whoScroll:SetLayout("Flow")
        whoScroll:SetFullWidth(true)
        whoScroll:SetHeight(200)
        inlineWho:AddChild(whoScroll)
        tblControls.whoScroll = whoScroll

        local lblWho = aceGUI:Create("Label")
        lblWho:SetText(L['Number of players found']..': '..#self.tblWho)
        lblWho:SetFullWidth(true)
        inlineWho:AddChild(lblWho)
        tblControls.lblWho = lblWho
    end

    inline.controls = tblControls
end
function scanner:BuildScanSection()
    local inline = self.tblFrame.inline
    local tblControls = inline.controls or {}
    local tblBase, tblFrame = ns.screens.base.tblFrame, self.tblFrame
    local scrollHeight = 55

    local inlineBottomLeft = tblControls.inlineScanner or aceGUI:Create('InlineGroup')
    inlineBottomLeft:SetTitle(L['Recruit Scanning']..':')
    inlineBottomLeft:SetLayout('Flow')
    inlineBottomLeft:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineBottomLeft:SetHeight(120)
    inline:AddChild(inlineBottomLeft)
    tblControls.inlineScanner = inlineBottomLeft

    local spacer = aceGUI:Create("ScrollFrame")
    spacer:SetLayout("Flow")
    spacer:SetRelativeWidth(1)
    spacer:SetHeight(scrollHeight)
    inlineBottomLeft:AddChild(spacer)

    local btnSearch = aceGUI:Create('Button')
    btnSearch:SetText('Start Search')
    btnSearch:SetFullWidth(true)
    btnSearch:SetCallback('OnClick', function() self:GetNextFilterRecord() end)
    spacer:AddChild(btnSearch)
    tblControls.btnSearch = btnSearch

    local lblNextTitle = aceGUI:Create("Label")
    lblNextTitle:SetText(L['Next filter']..': ')
    lblNextTitle:SetFont(DEFAULT_FONT, 10, 'OUTLINE')
    lblNextTitle:SetFullWidth(true)
    spacer:AddChild(lblNextTitle)

    local lblNextFilter = tblFrame.lblNextFilter or aceGUI:Create("Label")
    lblNextFilter:SetText('')
    lblNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblNextFilter:SetFullWidth(true)
    spacer:AddChild(lblNextFilter)
    tblControls.lblNextFilter = lblNextFilter

    inline.controls = tblControls
end
function scanner:BuildAnalytics()
    local inline = self.tblFrame.inline
    local tblControls = inline.controls or {}

    if self.isCompact then return end
    local inlineBottomRight = aceGUI:Create('InlineGroup')
    inlineBottomRight:SetTitle(L['Session Stats']..':')
    inlineBottomRight:SetLayout('Flow')
    inlineBottomRight:SetRelativeWidth(.6)
    inlineBottomRight:SetHeight(100)
    inline:AddChild(inlineBottomRight)

    local leftScroll = aceGUI:Create("ScrollFrame")
    leftScroll:SetLayout("Flow")
    leftScroll:SetRelativeWidth(.5)
    leftScroll:SetHeight(55)
    inlineBottomRight:AddChild(leftScroll)

    local rightScroll = aceGUI:Create("ScrollFrame")
    rightScroll:SetLayout("Flow")
    rightScroll:SetRelativeWidth(.5)
    rightScroll:SetHeight(55)
    inlineBottomRight:AddChild(rightScroll)

    local lblScanned = aceGUI:Create("Label")
    lblScanned:SetText(L['Players Scanned']..': ')
    lblScanned:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblScanned:SetFullWidth(true)
    leftScroll:AddChild(lblScanned)
    tblControls.lblPlayersScanned = lblScanned

    local lblInvited = aceGUI:Create("Label")
    lblInvited:SetText(L['Total Invites']..': ')
    lblInvited:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblInvited:SetFullWidth(true)
    leftScroll:AddChild(lblInvited)
    tblControls.lblTotalInvites = lblInvited

    local lblWaitingOn = aceGUI:Create("Label")
    lblWaitingOn:SetText(L['Pending']..': ')
    lblWaitingOn:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblWaitingOn:SetFullWidth(true)
    leftScroll:AddChild(lblWaitingOn)
    tblControls.lblWaitingOn = lblWaitingOn

    local lblDeclined = aceGUI:Create("Label")
    lblDeclined:SetText(L['Total Declined']..': ')
    lblDeclined:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblDeclined:SetFullWidth(true)
    rightScroll:AddChild(lblDeclined)
    tblControls.lblDeclined = lblDeclined

    local lblTotalAccepted = aceGUI:Create("Label")
    lblTotalAccepted:SetText(L['Total Accepted']..': ')
    lblTotalAccepted:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalAccepted:SetFullWidth(true)
    rightScroll:AddChild(lblTotalAccepted)
    tblControls.lblAccepted = lblTotalAccepted

    local lblBlackList = aceGUI:Create("Label")
    lblBlackList:SetText(L['Total Black List']..': ')
    lblBlackList:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblBlackList:SetFullWidth(true)
    rightScroll:AddChild(lblBlackList)
    tblControls.lblTotalBlackList = lblBlackList

    inline.controls = tblControls
end
function scanner:UpdateAnalyticsSection()
    if self.isCompact or not self.tblFrame.inline or not self.tblFrame.inline.controls then return end

    local tblSession = ns.analytics.tblSession
    local tblControls = self.tblFrame.inline.controls

    local waitingOn = tblSession['WaitingOnPlayer'] or 0
    local pendingOut = waitingOn == 0 and ns.code:cText('FF00FF00', waitingOn) or ns.code:cText('FFFF0000', waitingOn)

    tblControls.lblPlayersScanned:SetText(L['Players Scanned']..': '..(tblSession['PlayersScanned'] or 0))
    tblControls.lblTotalInvites:SetText(L['Total Invites']..': '..(tblSession['PlayersInvited'] or 0))
    tblControls.lblWaitingOn:SetText(L['Pending']..': '..pendingOut)
    tblControls.lblDeclined:SetText(L['Total Declined']..': '..(tblSession['PlayersDeclined'] or 0))
    tblControls.lblAccepted:SetText(L['Total Accepted']..': '..(tblSession['PlayersJoined'] or 0))
    tblControls.lblTotalBlackList:SetText(L['Total Black List']..': '..(tblSession['PlayersBlackListed'] or 0))

    if ns.settings.inviteFormat == 1 then
        tblControls.lblWaitingOn:SetText(L['Pending']..': <'..L['Disabled']..'>')
    end
end

-- Filter Routines
function scanner:BuildFilter(skipNext, isReset)
    self.tblFilter = {}

    local filter = ns.dbGlobal.filter
    local min, max = (self.minLevel), (self.maxLevel)

    local function createClassFilter()
        for _,c in pairs(ns.tblClassesByName) do
            local query = 'c-"'..c.name..'"'
            for i=min, max, 5 do
                local rangeStart, rangeEnd = i, i + 5
                if rangeEnd > max then rangeEnd = max end
                tinsert(self.tblFilter, { name = c.name, query =  query..' '..rangeStart..'-'..rangeEnd })
            end
        end
        self.tblFilter = ns.code:sortTableByField(self.tblFilter, 'name')
    end
    local function createRaceFilter()
        for _,r in pairs(ns.tblRaces) do
            local query = 'r-"'..r.name..'"'
            for i=min, max, 5 do
                local rangeStart, rangeEnd = i, i + 5
                if rangeEnd > max then rangeEnd = max end
                tinsert(self.tblFilter, { name = r.name, query = query..' '..rangeStart..'-'..rangeEnd })
            end
        end
        self.tblFilter = ns.code:sortTableByField(self.tblFilter, 'name')
    end
    local function createCustomFilter(filterList)
        if not filterList then return end
            local tblAllClasses = ns.tblClassesByName or {}

            local raceKey = next(filterList.race)
            local classKey = next(filterList.class)

            local raceType = raceKey:match('ALL') and 'ALL_RACES' or nil
            local classType = classKey:match('ALL') and strlower(classKey:gsub('ALL_', '')) or nil
            local tblClass = classType and tblAllClasses or filterList.class

            local tbl = {}
            local function buildLevelFilter(filterOut)
                for i=min, max, 5 do
                    local rangeStart, rangeEnd = i, i + 4
                    if rangeEnd > max then rangeEnd = max end
                    tinsert(tbl, filterOut..' '..rangeStart..'-'..rangeEnd)
                end
            end

            for cKey in pairs(tblClass or {}) do
                local key = strupper(cKey:gsub(' ',''))
                if not classType or classType == 'classes' or (classType and tblClass[key] and tblClass[key][classType]) then
                local classOut = 'c-"'..cKey..'"'
                local filterOut = classOut
                if raceType ~= 'ALL_RACES' then
                    for rKey in pairs(filterList.race or {}) do
                        local raceOut = ' r-"'..rKey..'"'
                        filterOut = classOut..raceOut
                        buildLevelFilter(filterOut)
                    end
                else buildLevelFilter(filterOut) end
            end
        end

        return tbl
    end

    local fID = ns.settings.activeFilter or 1
    if fID == 1 then createClassFilter()
    elseif fID == 2 then createRaceFilter()
    elseif fID >= 100 then
        fID = fID - 100
        local tblFilter = filter.filterList[fID] or nil
        if self.tblFilter then self.tblFilter = createCustomFilter(tblFilter) end
    end

    self.totalFilters = #self.tblFilter -- Used for progress
    if isReset then ns.screens.base.tblFrame.statusText:SetText('') end
    if not skipNext and #self.tblFilter > 0 then
        self:GetNextFilterRecord('DISPLAY_ONLY') end
end
function scanner:GetNextFilterRecord(onlyDisplay)
    local tblControls = self.tblFrame.inline.controls
    if #self.tblFilter == 0 then self:BuildFilter(true) return end

    local filter = self.tblFilter[1].query
    if not onlyDisplay then
        filter = table.remove(self.tblFilter, 1)
        if #self.tblFilter == 0 then self:BuildFilter('SKIP') end

        local function startWhoQuery()
            if ns.settings.showWho and FriendsFrame:IsShown() then
                FriendsFrame:RegisterEvent('WHO_LIST_UPDATE')
            else FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE") end

            ns.events:RegisterEvent('WHO_LIST_UPDATE', CallBackWhoListUpdate)

            C_FriendList.SetWhoToUi(true)
            C_FriendList.SendWho(filter.query)
        end
        local function waitTimer(remain, nextFilter)
            tblControls = self.tblFrame.inline.controls

            self.scanWaitTime = remain
            if remain > 0 or self.scanWaitTime > 0 then
                tblControls.btnSearch:SetDisabled(true)
                tblControls.btnSearch:SetText('Next Search: '..remain)
                C_Timer.After(1, function() waitTimer(remain - 1, nextFilter) end)
            else
                tblControls.btnSearch:SetDisabled(false)
                tblControls.btnSearch:SetText('Start Search')
            end
        end

        startWhoQuery()
        self:ProgressPercent()

        waitTimer((ns.settings.scanWaitTime or SCAN_WAIT_TIME), filter)
    end

    self:ProgressPercent()
    tblControls.lblNextFilter:SetText(ns.code:cText('FF00FF00', self.tblFilter[1].query))
end
function scanner:ProgressPercent()
    local percent = (self.totalFilters - #self.tblFilter) / self.totalFilters
    local statusMsg = 'Filter progress: '..FormatPercentage(percent, 2)
    ns.screens.base.tblFrame.statusText:SetText(statusMsg)
end

-- Invite and /who Routines
function scanner:ShowResults(whichResult, refreshInvite)
    local tblFrame = self.tblFrame.inline.controls

    local function showWhoResults()
        if self.isCompact then return end

        local function createWhoEntry(r)
            local lblLevel = aceGUI:Create("Label")
            lblLevel:SetText(r.level)
            lblLevel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            lblLevel:SetRelativeWidth(.1)
            tblFrame.whoScroll:AddChild(lblLevel)

            local lblName = aceGUI:Create("Label")
            lblName:SetText(ns.code:cPlayer(r.name, r.class) or 'No Name')
            lblName:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            lblName:SetRelativeWidth(.35)
            tblFrame.whoScroll:AddChild(lblName)

            local lblGuild = aceGUI:Create("Label")
            lblGuild:SetText(r.guild or '')
            lblGuild:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            lblGuild:SetRelativeWidth(.52)
            tblFrame.whoScroll:AddChild(lblGuild)

            return lblGuild
        end

        local noGuildCount = 0
        tblFrame.whoScroll:ReleaseChildren()
        for i=1,#self.tblWho do
            local r = self.tblWho[i]
            local lblGuild = createWhoEntry(r)
            if r.guild == '' then
                noGuildCount = noGuildCount + 1
                lblGuild:SetText(ns.code:cText('FFFF0000', ns.invite:ReturnReason(r.fullName, r.zone)))
            end
        end

        local msg = L['WHO_NUMBER_FOUND_DESC']..': '..#self.tblWho
        msg = msg..' - '..L['Unguilded']..': '..noGuildCount
        tblFrame.lblWho:SetText(msg)
    end
    local function showInviteResults()
        local function createCheckbox(pName, pClass, pLevel)
            local level = pLevel == MAX_CHARACTER_LEVEL and ns.code:cText('FF00FF00', pLevel) or (pLevel >= MAX_CHARACTER_LEVEL - 10 and ns.code:cText('FFFFFF00', pLevel) or pLevel)

            local checkBox = aceGUI:Create('CheckBox')
            checkBox:SetLabel(ns.code:cPlayer(pName, pClass))
            checkBox:SetRelativeWidth(.85)
            checkBox:SetValue(false)
            checkBox:SetCallback('OnValueChanged', function(_, _, value)
                self.tblInvites[pName].isChecked = value
                self:SetButtonStates()
            end)
            tblFrame.scrollInvite:AddChild(checkBox)

            local lblLevel = aceGUI:Create("Label")
            lblLevel:SetText(level)
            lblLevel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            lblLevel:SetRelativeWidth(.15)
            tblFrame.scrollInvite:AddChild(lblLevel)
        end

        local foundCount = 0
        if not refreshInvite then
            for _, r in pairs(self.tblWho) do
                local name = ns.tblConnectedRealms and r.fullName or (r.fullName:match('-') or r.fullName..'-'..GetRealmName())
                if (not r.guild or r.guild == '') and ns.invite:CheckIfCanBeInvited(r) then
                    self.tblInvites[name] = r
                    self.tblInvites[name].isChecked = false
                end
            end
        end

        tblFrame.scrollInvite:ReleaseChildren()
        local tbl = ns.code:sortTableByField(self.tblInvites, 'fullName') or {}
        for _, r in pairs(tbl) do
            foundCount = foundCount + 1
            local name = r.key:match(GetRealmName()) and r.key:gsub('-'..GetRealmName(), '') or r.key
            createCheckbox(name, r.class, r.level)
        end

        tblFrame.lblFound:SetText('Ready for invite: '..foundCount)
    end

    if strupper(whichResult) == 'WHO' then showWhoResults()
    elseif strupper(whichResult) == 'INVITE' then showInviteResults()
    else showWhoResults() showInviteResults() end

    self:SetButtonStates()
end
function scanner:InvitePlayers()
    if not self.tblInvites then return
    elseif self.tblFrame.inline.controls.btnInvite.disabled then
        ns.code:fOut(L['CANNOT_INVITE'])
        return
    end

    local tbl = ns.code:sortTableByField(self.tblInvites, 'fullName') or {}
    local name = tbl[1].key
    if not name then return end

    self.tblInvites[name] = nil
    ns.invite:InvitePlayer(name, ns.settings.inviteFormat ~= 1, self.whisperMessage)

    self:ShowResults('INVITE', true)
    self:SetButtonStates()
end

-- Other Routines
function scanner:SwitchCompactMode()
    ns.screens.scanner.isCompact = ns.settings.compactMode or false
    local tblBase, tblFrame = ns.screens.base.tblFrame, self.tblFrame

    if tblFrame.inline then
        tblFrame.inline:ReleaseChildren()
        tblFrame.inline.controls = nil
    end

    self:BuildScannerScreen()
    self:BuildInviteAndWho()
    self:BuildScanSection()
    self:BuildAnalytics()
    self:UpdateAnalyticsSection()

    if not self.tblFilter then self:BuildFilter()
    else scanner:GetNextFilterRecord('onlyDisplay') end

    tblBase.frame:SetSize(600, 470)
    if self.isCompact then
        tblBase.frame:SetSize(215, 465)
        tblBase.compactButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)
        self:ShowResults('INVITE', true)
    else
        tblBase.compactButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
        self:ShowResults('BOTH', true)
    end

    if tblFrame.frame then
        tblFrame.frame:ClearAllPoints()
        tblFrame.frame:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 20)
        tblFrame.frame:SetPoint('BOTTOMRIGHT', tblBase.statusBar, 'TOPRIGHT', 0, -5)
    end

    scanner:SetButtonStates()
    self:UpdateAnalyticsSection()
end
function scanner:SetButtonStates()
    local tblControls = self.tblFrame.inline.controls
    local foundCount, checkCount = 0, 0
    for _, r in pairs(self.tblInvites) do
        foundCount = foundCount + 1
        if r.isChecked then checkCount = checkCount + 1 end
    end

    tblControls.lblFound:SetText('Ready for invite: '..foundCount)
    if foundCount == 0 then
        tblControls.btnInvite:SetDisabled(true)
        tblControls.btnRemove:SetDisabled(true)
        tblControls.btnSkip:SetDisabled(true)
    elseif checkCount == 0 then
        tblControls.btnInvite:SetDisabled(false)
        tblControls.btnRemove:SetDisabled(true)
        tblControls.btnSkip:SetDisabled(true)
    else
        tblControls.btnInvite:SetDisabled(true)
        tblControls.btnRemove:SetDisabled(false)
        tblControls.btnSkip:SetDisabled(false)
    end

    if self.scanWaitTime > 0 then
        tblControls.btnSearch:SetDisabled(true)
        tblControls.btnSearch:SetText('Next Search: '..self.scanWaitTime)
    end
end
scanner:Init()