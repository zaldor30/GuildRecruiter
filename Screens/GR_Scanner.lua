local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.scanner = {}
local scanner, scan, analytics = ns.scanner, {}, {}

local SCAN_WAIT_TIME = 6

local function obsCLOSE_SCREENS_SCANNER()
    ns.code:statusOut('')
    scan:CloseScanner()
end

-- Event Functions
local function CallBackWhoListUpdate()
    local tblConnected, tblFrame = ns.ds.tblConnected, scan.tblFrame.controls
    local tblWho, tblFound = scan.tblWho, scan.tblFound
    ns.events:Unregister('WHO_LIST_UPDATE', CallBackWhoListUpdate)

    tblFound = tblFound or {}
    tblWho = table.wipe(tblWho) or {}

    if not scan.isCompact then
        tblFrame.lblWho:SetText('Number of players found: '..#tblFound)
    end

    for i=1, C_FriendList.GetNumWhoResults() do
        local info = C_FriendList.GetWhoInfo(i)
        local pName = #tblConnected > 0 and info.fullName or info.fullName:gsub('-.*', '')
        local rec = {fullName = info.fullName, name = pName, class = info.filename, level = info.level, guild = (info.fullGuildName or ''), zone = info.area}
        tinsert(tblWho, rec)
    end

    analytics:TotalScanned(C_FriendList.GetNumWhoResults())
    scan:ShowResults('BOTH')
end

-- Global Accessable Routines
function scanner:ReturnWhispers() return scan.whisperMessage end
function scanner:ShowScanner(message, filter, minLevel, maxLevel)
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    scan:StartScanner(message, filter, minLevel, maxLevel)
end
function scanner:ChangeCompact()
    scan.isCompact = not scan.isCompact

    ns.settings.compactMode = scan.isCompact
    scan:SwitchCompactMode()
end
function scanner:GetSessionData() return analytics:GetSessionData() end -- Accessed through scanner
function scanner:TotalUnknown(amt) analytics:TotalUnknown(amt) end
function scanner:TotalInvited(amt) analytics:TotalInvited(amt) end
function scanner:TotalDeclined(amt) analytics:TotalDeclined(amt) end
function scanner:TotalAccepted(amt) analytics:TotalAccepted(amt) end
function scanner:TotalBlackList(amt) analytics:TotalBlackList(amt) end
function scanner:TotalScanned(amt) analytics:TotalScanned(amt) end
function scanner:ResetFilter() scan:BuildFilter() end

-- Local Scan Routines
function scan:Init()
    self.isCompact = false
    self.statusMsg = ''

    -- Session Analytics Variables
    self.totalInvites = 0
    self.totalBlackList = 0
    self.totalDeclined = 0
    self.totalAccepted = 0
    self.totalUnknown = 0
    self.totalScanned = 0

    self.tblFrame = {}
    self.tblFound = {}

    self.tblWho = {}

    self.filter = nil
    self.tblFilter = {}
    self.totalFilters = 0

    self.whisperMessage = nil
    self.minLevel, self.maxLevel = 1, MAX_CHARACTER_LEVEL
end
function scan:SwitchCompactMode()
    local tblFrame = self.tblFrame
    local tblScreen = ns.screen.tblFrame

    tblScreen.frame:SetSize(600, 470)
    if self.isCompact then
        tblScreen.frame:SetSize(215, 465)
        tblScreen.compactButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)
    else tblScreen.compactButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1) end

    if tblFrame.frame then
        tblFrame.frame:ClearAllPoints()
        tblFrame.frame:SetPoint('TOPLEFT', tblScreen.titleFrame, 'BOTTOMLEFT', -5, 20)
        tblFrame.frame:SetPoint('BOTTOMRIGHT', tblScreen.statusBar, 'TOPRIGHT', 0, -5)
    end

    if tblFrame.inline then
        self.tblFrame.controls = nil
        tblFrame.inline:ReleaseChildren()
    end

    self:BuildScannerControls()
    self:ShowResults('INVITE')
end
function scan:CloseScanner()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    local tblFrame = self.tblFrame
    local tblScreen = ns.screen.tblFrame
    if not tblScreen.frame then return end

    tblScreen.backButton:SetShown(false)
    tblScreen.resetButton:SetShown(false)
    tblScreen.compactButton:SetShown(false)

    if tblFrame.frame then
        tblFrame.frame:SetShown(false)
        tblFrame.inline.frame:Hide()
    end
end

-- Start and Build Scanner Screen
function scan:StartScanner(message, minLevel, maxLevel)
    local tblFrame = self.tblFrame
    local tblScreen = ns.screen.tblFrame
    if not tblScreen.frame then return end

    self.filter = ns.settings.activeFilter or 1
    self.whisperMessage = message or self.whisperMessage
    self.minLevel = minLevel or self.minLevel or 1
    self.maxLevel = maxLevel or self.maxLevel or MAX_CHARACTER_LEVEL

    tblScreen.backButton:SetShown(true)
    tblScreen.resetButton:SetShown(true)
    tblScreen.compactButton:SetShown(true)

    if tblFrame.frame then
        tblFrame.frame:Show()
        tblFrame.inline.frame:Show()
    else self:BuildScannerScreen() end

    self.isCompact = (ns.settings.compactMode == nil or ns.settings.compactMode) and true or false
    self:SwitchCompactMode()

    self:SetButtonStates()
    tblScreen.statusText:SetText(self.statusMsg)
end
function scan:BuildScannerScreen()
    local tblFrame = self.tblFrame
    local tblScreen = ns.screen.tblFrame

    -- Base Regular Frame
    local f = CreateFrame('Frame', 'GR_SCANNER_FRAME', tblScreen.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:EnableMouse(false)
    tblFrame.frame = f

    -- Ace GUI Frame for Ace Controls
    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    tblFrame.inline = inline
end
function scan:BuildScannerControls()
    self.tblFrame.controls = self.tblFrame.controls or {}
    local tblFrame = self.tblFrame.controls

    local inline = self.tblFrame.inline
    local inlineInvite = self.tblFrame.inlineInvite or aceGUI:Create('InlineGroup')
    inlineInvite:SetLayout('Flow')
    inlineInvite:SetTitle('Invites:')
    inlineInvite:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineInvite:SetHeight(200)
    if not self.tblFrame.inlineInvite then
        inline:AddChild(inlineInvite) end
    tblFrame.inlineInvite = inlineInvite

    local scrollInvite = self.tblFrame.scrollInvite or aceGUI:Create('ScrollFrame')
    scrollInvite:SetLayout('Flow')
    scrollInvite:SetFullWidth(true)
    scrollInvite:SetHeight(160)
    if not self.tblFrame.scrollInvite then
        inlineInvite:AddChild(scrollInvite) end
    tblFrame.scrollInvite = scrollInvite

    local btnInvite = self.tblFrame.btnInvite or aceGUI:Create('Button')
    btnInvite:SetText('Invite')
    btnInvite:SetRelativeWidth(.5)
    btnInvite:SetDisabled(true)
    btnInvite:SetCallback('OnEnter', function()
        local title = 'Invite players to guild'
        local body = 'Checked players are for adding to black list.'
        ns.code:createTooltip(title, body)
    end)
    btnInvite:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnInvite:SetCallback('OnClick', function()
        if not self.tblFound then return end

        local name = next(self.tblFound)
        if not name and not self.tblFound[name] then return end

        local tblFound = self.tblFound[name]
        ns.invite:InvitePlayer(name, tblFound.class, (ns.settings.inviteFormat or 2), 'SEND_MESSAGE')
        self.tblFound[name] = nil

        scan:ShowResults('INVITE')
        scan:SetButtonStates()
    end)
    if not self.tblFrame.btnInvite then
        inlineInvite:AddChild(btnInvite) end
    tblFrame.btnInvite = btnInvite

    local btnRemove = self.tblFrame.btnRemove or aceGUI:Create('Button')
    btnRemove:SetText('BL')
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetDisabled(true)
    btnRemove:SetCallback('OnEnter', function()
        local title = 'Black List Players'
        local body = 'Selected players will be added to the black list.'
        ns.code:createTooltip(title, body)
    end)
    btnRemove:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnRemove:SetCallback('OnClick', function()
        local msg = 'Are you sure you want to add then\nselected players to the black list?'
        local func = function()
            for k, r in pairs(scan.tblFound) do
                if r.isChecked then
                    ns.blackList:AddToBlackList(k, 'BULK_ADD_BLACKLIST')
                    scan.tblFound[k] = nil
                end
            end

            self:ShowResults('INVITE')
            self:SetButtonStates()
        end
        ns.code:Confirmation(msg, func)
    end)
    if not self.tblFrame.btnRemove then
        inlineInvite:AddChild(btnRemove) end
    tblFrame.btnRemove = btnRemove

    self.lblFound = tblFrame.lblFound or aceGUI:Create("Label")
    self.lblFound:SetText('Ready for invite: '..#self.tblFound)
    self.lblFound:SetRelativeWidth(.5)
    if not self.tblFrame.lblFound then
        inlineInvite:AddChild(self.lblFound) end
    tblFrame.lblFound = self.lblFound

    local btnSkip = self.tblFrame.btnSkip or aceGUI:Create('Button')
    btnSkip:SetText('Skip')
    btnSkip:SetRelativeWidth(.5)
    btnSkip:SetDisabled(true)
    btnSkip:SetCallback('OnClick', function()
        for k, r in pairs(self.tblFound) do
            if r.isChecked and ns.invite:AddToSentList(k, r.class) then
                self.tblFound[k] = nil end
        end

        self:ShowResults('INVITE')
        self:SetButtonStates()
    end)
    btnSkip:SetCallback('OnEnter', function()
        local title = 'Skip players'
        local body = ns.code:wordWrap('Selected players will be skipped and added to the anti-spam list.')
        ns.code:createTooltip(title, body)
    end)
    btnSkip:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    if not self.tblFrame.btnSkip then
        inlineInvite:AddChild(btnSkip) end
    tblFrame.btnSkip = btnSkip

    if not self.isCompact then -- Who Result Controls
        local inlineWho = tblFrame.inlineWho or nil
        if not inlineWho then
            inlineWho = tblFrame.whoInline or aceGUI:Create('InlineGroup')
            inlineWho:SetTitle('Who Results:')
            inlineWho:SetLayout('Flow')
            inlineWho:SetRelativeWidth(.6)
            if not tblFrame.whoInline then
                inline:AddChild(inlineWho) end
            tblFrame.whoInline = inlineWho
        end

        local whoScroll = tblFrame.whoScroll or aceGUI:Create('ScrollFrame')
        whoScroll:SetLayout("Flow")
        whoScroll:SetFullWidth(true)
        whoScroll:SetHeight(200)
        if not tblFrame.whoScroll then
            inlineWho:AddChild(whoScroll) end
        tblFrame.whoScroll = whoScroll

        local lblWho = tblFrame.lblWho or aceGUI:Create("Label")
        lblWho:SetText('Number of players found: '..#self.tblFound)
        lblWho:SetFullWidth(true)
        if not tblFrame.lblWho then
            inlineWho:AddChild(lblWho) end
        tblFrame.lblWho = lblWho
    end

    local scrollHeight = 55
    local inlineBottomLeft = tblFrame.inlineBottomLeft or aceGUI:Create('InlineGroup')
    inlineBottomLeft:SetTitle('Recruit Scanning:')
    inlineBottomLeft:SetLayout('Flow')
    inlineBottomLeft:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineBottomLeft:SetHeight(120)
    if not tblFrame.inlineBottomLeft then
        inline:AddChild(inlineBottomLeft) end
    tblFrame.inlineBottomLeft = inlineBottomLeft

    local spacer = tblFrame.spacer or aceGUI:Create("ScrollFrame")
    spacer:SetLayout("Flow")
    spacer:SetRelativeWidth(1)
    spacer:SetHeight(scrollHeight)
    if not tblFrame.statsScroll then
        inlineBottomLeft:AddChild(spacer) end
    tblFrame.spacer = spacer

    local btnSearch = tblFrame.btnSearch or aceGUI:Create('Button')
    btnSearch:SetText('Start Search')
    btnSearch:SetFullWidth(true)
    btnSearch:SetCallback('OnClick', function() self:GetNextFilterRecord() end)
    if not tblFrame.btnSearch then
        spacer:AddChild(btnSearch) end
    tblFrame.btnSearch = btnSearch

    local lblNextTitle = tblFrame.lblNextTitle or aceGUI:Create("Label")
    lblNextTitle:SetText('Next filter: ')
    lblNextTitle:SetFont(DEFAULT_FONT, 10, 'OUTLINE')
    lblNextTitle:SetFullWidth(true)
    if not tblFrame.lblNextTitle then
        spacer:AddChild(lblNextTitle) end
    tblFrame.lblNextTitle = lblNextTitle

    local lblNextFilter = tblFrame.lblNextFilter or aceGUI:Create("Label")
    lblNextFilter:SetText('')
    lblNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblNextFilter:SetFullWidth(true)
    if not tblFrame.lblNextFilter then
        spacer:AddChild(lblNextFilter) end
    tblFrame.lblNextFilter = lblNextFilter

    if not self.isCompact then -- Session Stats Controls
        local inlineBottomRight = tblFrame.inlineBottomRight or aceGUI:Create('InlineGroup')
        inlineBottomRight:SetTitle('Session Stats:')
        inlineBottomRight:SetLayout('Flow')
        inlineBottomRight:SetRelativeWidth(.6)
        inlineBottomRight:SetHeight(100)
        if not tblFrame.inlineBottomRight then
            inline:AddChild(inlineBottomRight) end
        tblFrame.inlineBottomRight = inlineBottomRight

        local statsScroll1 = tblFrame.statsScroll1 or aceGUI:Create("ScrollFrame")
        statsScroll1:SetLayout("Flow")
        statsScroll1:SetRelativeWidth(.5)
        statsScroll1:SetHeight(55)
        if not tblFrame.statsScroll then
            inlineBottomRight:AddChild(statsScroll1) end
        tblFrame.statsScroll1 = statsScroll1

        local lblTotalScanned = tblFrame.lblTotalScanned or aceGUI:Create("Label")
        lblTotalScanned:SetText('Total Scanned: '..self.totalScanned)
        lblTotalScanned:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalScanned:SetFullWidth(true)
        if not tblFrame.lblTotalScanned then
            statsScroll1:AddChild(lblTotalScanned) end
        tblFrame.lblTotalScanned = lblTotalScanned

        local lblTotalInvites = tblFrame.lblTotalInvites or aceGUI:Create("Label")
        lblTotalInvites:SetText('Total Invites: '..self.totalInvites)
        lblTotalInvites:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalInvites:SetFullWidth(true)
        if not tblFrame.lblTotalInvites then
            statsScroll1:AddChild(lblTotalInvites) end
        tblFrame.lblTotalInvites = lblTotalInvites

        local lblUnknown = tblFrame.lblUnknown or aceGUI:Create("Label")
        lblUnknown:SetText('Pending: '..self.totalUnknown)
        lblUnknown:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblUnknown:SetFullWidth(true)
        if not tblFrame.lblUnknown then
            statsScroll1:AddChild(lblUnknown) end
        tblFrame.lblUnknown = lblUnknown

        local statsScroll2 = tblFrame.statsScroll2 or aceGUI:Create("ScrollFrame")
        statsScroll2:SetLayout("Flow")
        statsScroll2:SetRelativeWidth(.5)
        statsScroll2:SetHeight(55)
        if not tblFrame.statsScroll2 then
            inlineBottomRight:AddChild(statsScroll2) end
        tblFrame.statsScroll2 = statsScroll2

        local lblTotalDeclined = tblFrame.lblTotalDeclined or aceGUI:Create("Label")
        lblTotalDeclined:SetText('Total Declined: '..self.totalDeclined)
        lblTotalDeclined:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalDeclined:SetFullWidth(true)
        if not tblFrame.lblTotalDeclined then
            statsScroll2:AddChild(lblTotalDeclined) end
        tblFrame.lblTotalDeclined = lblTotalDeclined

        local lblTotalAccepted = tblFrame.lblTotalAccepted or aceGUI:Create("Label")
        lblTotalAccepted:SetText('Total Accepted: '..self.totalAccepted)
        lblTotalAccepted:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalAccepted:SetFullWidth(true)
        if not tblFrame.lblTotalAccepted then
            statsScroll2:AddChild(lblTotalAccepted) end
        tblFrame.lblTotalAccepted = lblTotalAccepted

        local lblTotalBlackList = tblFrame.lblTotalBlackList or aceGUI:Create("Label")
        lblTotalBlackList:SetText('Total Black List: '..self.totalBlackList)
        lblTotalBlackList:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalBlackList:SetFullWidth(true)
        if not tblFrame.lblTotalBlackList then
            statsScroll2:AddChild(lblTotalBlackList) end
        tblFrame.lblTotalBlackList = lblTotalBlackList
    end

    if not self.tblFilter or #self.tblFilter == 0 then self:BuildFilter()
    else tblFrame.lblNextFilter:SetText(ns.code:cText('FF00FF00', self.tblFilter[1])) end

    analytics:ShowAnalytics()
end

-- Filter Routines
function scan:BuildFilter(skipNext)
    self.tblFilter = {}

    local settings, filter = ns.settings, ns.db.filter
    local min, max = (tonumber(settings.minLevel) or 1), (tonumber(settings.maxLevel) or MAX_CHARACTER_LEVEL)

    local function createRaceFilter()
        for _,r in pairs(ns.ds.tblRaces) do
            local query = 'r-"'..r..'"'
            for i=min, max, 5 do
                local rangeStart, rangeEnd = i, i + 5
                if rangeEnd > max then rangeEnd = max and max or (MAX_CHARACTER_LEVEL or 70) end
                tinsert(self.tblFilter, query..' '..rangeStart..'-'..rangeEnd)
            end
        end
    end
    local function createClassFilter()
        for _,r in pairs(ns.ds.tblClassesByName or {}) do
            local class = r.className
            local query = 'c-"'..class..'"'
            for i=min, max, 5 do
                local rangeStart, rangeEnd = i, i + 5
                if rangeEnd > max then rangeEnd = max and max or (MAX_CHARACTER_LEVEL or 70) end
                tinsert(self.tblFilter, query..' '..rangeStart..'-'..rangeEnd)
            end
        end
    end
    local function createCustomFilter(filterList)
        if not filterList then return end
            local tblAllClasses = ns.ds.tblClassesByName or {}

            local minLevel, maxLevel = tonumber(settings.minLevel), tonumber(settings.maxLevel)
            local raceKey = next(filterList.race)
            local classKey = next(filterList.class)

            local raceType = raceKey:match('ALL') and 'ALL_RACES' or nil
            local classType = classKey:match('ALL') and strlower(classKey:gsub('ALL_', '')) or nil
            local tblClass = classType and tblAllClasses or filterList.class

            local tbl = {}
            local function buildLevelFilter(filterOut)
                for i=minLevel, maxLevel, 5 do
                    local rangeStart, rangeEnd = i, i + 4
                    if rangeEnd > maxLevel then rangeEnd = maxLevel and maxLevel or (MAX_CHARACTER_LEVEL or 70) end
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

    local fID = filter.activeFilter or 1

    if fID == 1 then createClassFilter()
    elseif fID == 2 then createRaceFilter()
    elseif fID >= 10 then
        fID = fID - 10
        local tblFilter = filter.filterList[fID] or nil
        if not tblFilter then
            self.lblNextFilter:SetText(ns.code:cText('FFFF0000', 'Invalid Filter'))
            return
        else self.tblFilter = createCustomFilter(tblFilter) end
    else createClassFilter() end

    self.totalFilters = #self.tblFilter
    if not skipNext and #self.tblFilter > 0 then
        self:GetNextFilterRecord('DISPLAY_ONLY') end
end -- Build filter and display next filter
function scan:GetNextFilterRecord(onlyDisplay)
    local tblFrame = self.tblFrame.controls
    if #self.tblFilter == 0 then self:BuildFilter() return end

    local filter = self.tblFilter[1]
    if not onlyDisplay then
        self.tblWho = table.wipe(self.tblWho) or {}
        filter = table.remove(self.tblFilter, 1)
        if #self.tblFilter == 0 then self:BuildFilter('SKIP') end

        local function startWhoQuery()
            if ns.settings.showWho and FriendsFrame:IsShown() then
                FriendsFrame:RegisterEvent('WHO_LIST_UPDATE')
            else FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE") end

            ns.events:RegisterEvent('WHO_LIST_UPDATE', CallBackWhoListUpdate)

            C_FriendList.SetWhoToUi(true)
            C_FriendList.SendWho(filter)
        end
        local function waitTimer(remain, nextFilter)
            if remain > 0 then
                tblFrame.btnSearch:SetDisabled(true)
                tblFrame.btnSearch:SetText('Next Search: '..remain)
                C_Timer.After(1, function() waitTimer(remain - 1, nextFilter) end)
            else
                tblFrame.btnSearch:SetDisabled(false)
                tblFrame.btnSearch:SetText('Start Search')
            end
        end

        startWhoQuery()
        local percent = (self.totalFilters - #self.tblFilter) / self.totalFilters
        local statusMsg = 'Filter progress: '..FormatPercentage(percent, 2)
        self.statusMsg = statusMsg
        ns.code:statusOut(statusMsg)

        waitTimer((ns.settings.scanWaitTime or SCAN_WAIT_TIME), filter)
    end

    tblFrame.lblNextFilter:SetText(ns.code:cText('FF00FF00', self.tblFilter[1]))
end -- Get Next Filter Record and Display Next Filter Record

function scan:ShowResults(showWhich) -- Populate Invite and Who Tables
    local tblPotential = self.tblWho or {}

    local function createCheckbox(pName, pClass, pLevel)
        local tblFrame = self.tblFrame.controls
        local level = pLevel == MAX_CHARACTER_LEVEL and ns.code:cText('FF00FF00', pLevel) or (pLevel >= MAX_CHARACTER_LEVEL - 10 and ns.code:cText('FFFFFF00', pLevel) or pLevel)

        local checkBox = aceGUI:Create('CheckBox')
        checkBox:SetLabel(ns.code:cPlayer(pName, pClass))
        checkBox:SetRelativeWidth(.85)
        checkBox:SetValue(false)
        checkBox:SetCallback('OnValueChanged', function(_, _, value)
            self.tblFound[pName].isChecked = value
            self:SetButtonStates()
        end)
        tblFrame.scrollInvite:AddChild(checkBox)

        local lblLevel = aceGUI:Create("Label")
        lblLevel:SetText(level)
        lblLevel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblLevel:SetRelativeWidth(.15)
        tblFrame.scrollInvite:AddChild(lblLevel)
    end
    local function showInvites()
        local tblFrame = self.tblFrame.controls

        while #tblPotential > 0 do
            local r = tremove(tblPotential, 1)
            if (not r.guild or r.guild == '') and ns.invite:CheckIfCanBeInvited(r) then
                self.tblFound[r.fullName] = r
                self.tblFound[r.fullName].isChecked = false
            end
        end

        local foundCount = 0
        tblFrame.scrollInvite:ReleaseChildren()
        for _, r in pairs(self.tblFound) do
            foundCount = foundCount + 1
            createCheckbox(r.fullName, r.class, r.level)
        end

        tblFrame.lblFound:SetText('Ready for invite: '..foundCount)
    end
    local function showWho()
        local tblFrame = self.tblFrame.controls

        if self.isCompact then return end

        local function createWhoEntry(tbl)
            local lblLevel = aceGUI:Create("Label")
            lblLevel:SetText(tbl.level == MAX_CHARACTER_LEVEL and ns.code:cText('FF00FF00', tbl.level) or (tbl.level >= MAX_CHARACTER_LEVEL - 10 and ns.code:cText('FFFFFF00', tbl.level) or tbl.level))
            lblLevel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            lblLevel:SetRelativeWidth(.1)
            tblFrame.whoScroll:AddChild(lblLevel)

            local lblName = aceGUI:Create("Label")
            lblName:SetText(ns.code:cPlayer(tbl.name, tbl.class) or 'No Name')
            lblName:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            lblName:SetRelativeWidth(.35)
            tblFrame.whoScroll:AddChild(lblName)

            local lblGuild = aceGUI:Create("Label")
            lblGuild:SetText(tbl.guild or '')
            lblGuild:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
            lblGuild:SetRelativeWidth(.52)
            tblFrame.whoScroll:AddChild(lblGuild)
        end

        local noGuild = 0
        tblFrame.whoScroll:ReleaseChildren()
        for i=1, #self.tblWho do
            local r = self.tblWho[i]
            if not r.guild or r.guild == '' then noGuild = noGuild + 1 end
            createWhoEntry(r)
        end

        local msg = 'Number of players found: '..#self.tblWho
        msg = msg..' - Unguilded: '..noGuild
        tblFrame.lblWho:SetText(msg)
    end

    if showWhich == 'WHO' then showWho()
    elseif showWhich == 'INVITE' then showInvites()
    else showWho() showInvites() end

    self:SetButtonStates()
end

-- Other Routines
function scan:SetButtonStates()
    local tblFrame = self.tblFrame.controls
    local foundCount, checkCount = 0, 0
    for _, r in pairs(self.tblFound) do
        foundCount = foundCount + 1
        if r.isChecked then checkCount = checkCount + 1 end
    end

    tblFrame.lblFound:SetText('Ready for invite: '..foundCount)
    if foundCount == 0 then
        tblFrame.btnInvite:SetDisabled(true)
        tblFrame.btnRemove:SetDisabled(true)
        tblFrame.btnSkip:SetDisabled(true)
    elseif checkCount == 0 then
        tblFrame.btnInvite:SetDisabled(false)
        tblFrame.btnRemove:SetDisabled(true)
        tblFrame.btnSkip:SetDisabled(true)
    else
        tblFrame.btnInvite:SetDisabled(true)
        tblFrame.btnRemove:SetDisabled(false)
        tblFrame.btnSkip:SetDisabled(false)
    end
end -- Enable/Disable Buttons

-- Analytics Update Routines
local tblCount = {}
function analytics:ShowAnalytics()
    if not scan.tblFrame or not scan.tblFrame.frame or scan.isCompact then return end

    local tblFrame = scan.tblFrame.controls
    tblFrame.lblTotalScanned:SetText('Total Scanned: '..(tblCount['Total_Scanned'] and tblCount['Total_Scanned'] or 0))
    tblFrame.lblTotalInvites:SetText('Total Invites: '..(tblCount['Total_Invited'] and tblCount['Total_Invited'] or 0))
    tblFrame.lblTotalDeclined:SetText('Total Declined: '..(tblCount['Total_Declined'] and tblCount['Total_Declined'] or 0))
    tblFrame.lblTotalAccepted:SetText('Total Accepted: '..(tblCount['Total_Accepted'] and tblCount['Total_Accepted'] or 0))
    tblFrame.lblTotalBlackList:SetText('Total Black List: '..(tblCount['Total_BlackList'] and tblCount['Total_BlackList'] or 0))
    if ns.settings.inviteFormat == 1 then
        tblFrame.lblUnknown:SetText('Pending: <Disabled>')
    else tblFrame.lblUnknown:SetText('Pending: '..ns.code:cText(((tblCount['Total_Unknown'] and tblCount['Total_Unknown'] and tblCount['Total_Unknown'] > 0) and 'FFFF0000' or 'FFFFFFFF'), (tblCount['Total_Unknown'] or 0))) end
end
function analytics:GetSessionData() return tblCount end -- Accessed through scanner
function analytics:TotalScanned(amt)
    ns.analytics:Scanned(amt)
    tblCount['Total_Scanned'] = (tblCount['Total_Scanned'] or 0) + (amt or 1)
    analytics:ShowAnalytics()
end
function analytics:TotalInvited(amt)
    ns.analytics:Invited(amt or 1)
    tblCount['Total_Invited'] = (tblCount['Total_Invited'] or 0) + (amt or 1)
    analytics:ShowAnalytics()
end
function analytics:TotalDeclined(amt)
    ns.analytics:Declined(amt or 1)
    tblCount['Total_Declined'] = (tblCount['Total_Declined'] or 0) + (amt or 1)
    analytics:ShowAnalytics()
end
function analytics:TotalAccepted(amt)
    ns.analytics:Accepted(amt or 1)
    tblCount['Total_Accepted'] = (tblCount['Total_Accepted'] or 0) + (amt or 1)
    analytics:ShowAnalytics()
end
function analytics:TotalBlackList(amt)
    ns.analytics:Blacklisted(amt or 1)
    tblCount['Total_BlackList'] = (tblCount['Total_BlackList'] or 0) + (amt or 1)
    analytics:ShowAnalytics()
end
function analytics:TotalUnknown(amt)
    if ns.settings.inviteFormat == 1 then return end
    local remain = (tblCount['Total_Unknown'] or 0) + (amt or 1)
    tblCount['Total_Unknown'] = remain > 0 and remain or 0
    analytics:ShowAnalytics()
end
scan:Init()