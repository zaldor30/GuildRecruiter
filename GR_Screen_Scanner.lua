local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

local INVITE_WAIT_TIME = 1

ns.scanner = {}
local scanner = ns.scanner
function scanner:Init()
    self.analytics = self:analytics()

    self.message = nil -- Message from main
    self.isCompact = false
    self.isCompactOveride = false

    -- Data Tables
    self.tblWho = {}
    self.tblFound = {}
    self.tblFilter = {}

    -- Filter Variables
    self.totalFilters = 0
    self.inviteFormat = nil
    self.message = nil
    self.filter = nil
    self.min = nil
    self.max = nil

    -- Session Analytics Variables
    self.totalInvites = 0
    self.totalBlackList = 0
    self.totalDeclined = 0
    self.totalAccepted = 0
    self.totalUnknown = 0
    self.totalScanned = 0

    -- Inline Analytics Group Widgets
    self.lblUnknown = aceGUI:Create("Label")
    self.lblTotalInvites = aceGUI:Create("Label")
    self.lblTotalBlackList = aceGUI:Create("Label")
    self.lblTotalDeclined = aceGUI:Create("Label")
    self.lblTotalAccepted = aceGUI:Create("Label")
    self.lblTotalScanned = aceGUI:Create("Label")

    -- Invite Inline Group Widgets
    self.invInline = nil
    self.invScroll = aceGUI:Create("ScrollFrame")
    self.btnInvite = aceGUI:Create('Button')
    self.btnRemove = aceGUI:Create('Button')
    self.lblFound = aceGUI:Create("Label")

    -- Who Inline Group Widgets
    self.whoInline = nil
    self.whoScroll = aceGUI:Create("ScrollFrame")
    self.lblWho = aceGUI:Create("Label")

    -- Recruit Scanning Inline Group Widgets
    self.btnSearch = aceGUI:Create('Button')
    self.lblNextFilter = aceGUI:Create("Label")

    self.statsInline = nil
end
function scanner:SetButtonStates()
    local foundCount, checkCount = 0, 0
    for _, r in pairs(self.tblFound) do
        foundCount = foundCount + 1
        if r.isChecked then checkCount = checkCount + 1 end
    end

    self.lblFound:SetText('Ready for invite: '..foundCount)
    if foundCount == 0 then
        self.btnInvite:SetDisabled(true)
        self.btnRemove:SetDisabled(true)
    elseif checkCount == 0 then
        self.btnInvite:SetDisabled(false)
        self.btnRemove:SetDisabled(true)
    else
        self.btnInvite:SetDisabled(true)
        self.btnRemove:SetDisabled(false)
    end
end
function scanner:StartScanner(message, min, max)
    self.isCompact = self.isCompactOveride and self.isCompact or (ns.db.settings.compactMode or false)
    if self.isCompact then ns.screen.fMain:SetSize(200, 405)
    else ns.screen.fMain:SetSize(500, 405) end
    ns.screen:ResetMain()

    ns.screen.aMain.frame:SetPoint("TOP", ns.screen.fTop_Icon, "BOTTOM", 1, 3)
    ns.screen.textSync:SetText()

    ns.screen.iconCompact:Hide()
    ns.screen.iconRestore:Hide()

    ns.screen.iconReset:Show()
    ns.screen.iconBack:Show()
    ns.screen.iconBack:SetScript('OnMouseUp', function() ns.main:ScannerSettingsLayout() end)
    if not self.isCompact then
        ns.screen.iconCompact:Show()
        ns.screen.iconCompact:SetScript('OnMouseUp', function()
            self.isCompact = true
            self.isCompactOveride = true
            ns.scanner:StartScanner()
        end)
    elseif self.isCompact then
        ns.screen.iconRestore:Show()
        ns.screen.iconRestore:SetScript('OnClick', function()
            self.isCompact = false
            self.isCompactOveride = true
            ns.scanner:StartScanner()
        end)
    end

    self.min = min
    self.max = max
    self.filter = ns.db.filter.activeFilter
    self.message = message
    self.inviteFormat = ns.db.settings.inviteFormat or 2

    self.invInline = aceGUI:Create('InlineGroup')
    local inlineInivte = self.invInline
    inlineInivte:SetTitle('Invites:')
    inlineInivte:SetLayout('Flow')
    inlineInivte:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineInivte:SetHeight(200)
    ns.screen.aMain:AddChild(inlineInivte)

    local invScroll = self.invScroll
    invScroll:SetLayout("Flow")
    invScroll:SetFullWidth(true)
    invScroll:SetHeight(160)
    inlineInivte:AddChild(invScroll)

    local btnInvite = self.btnInvite
    btnInvite:SetText('Invite')
    btnInvite:SetRelativeWidth(.5)
    btnInvite:SetDisabled(true)
    btnInvite:SetCallback('OnEnter', function()
        local title = 'Invite players to guild'
        local body = 'Checked players are for adding to black list.'
        ns.widgets:createTooltip(title, body)
    end)
    btnInvite:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnInvite:SetCallback('OnClick', function() scanner:InvitePlayer() end)
    inlineInivte:AddChild(btnInvite)

    local btnRemove = self.btnRemove
    btnRemove:SetText('BL')
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetDisabled(true)
    btnRemove:SetCallback('OnEnter', function()
        local title = 'Black List Players'
        local body = 'Selected players will be added to the black list.'
        ns.widgets:createTooltip(title, body)
    end)
    btnRemove:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnRemove:SetCallback('OnClick', function()
        local msg = 'Are you sure you want to add then\nselected players to the black list?'
        local func = function()
            local tbl = {}
            for k, r in pairs(ns.scanner.tblFound) do
                if r.isChecked then tbl[k] = true end
            end
            ns.blackList:BulkAddToBlackList(tbl)
        end
        ns.widgets:Confirmation(msg, func)
    end)
    inlineInivte:AddChild(btnRemove)

    self.lblFound = aceGUI:Create("Label")
    self.lblFound:SetText('Ready for invite: '..#self.tblFound)
    self.lblFound:SetFullWidth(true)
    inlineInivte:AddChild(self.lblFound)

    if not self.isCompact then
        self.whoInline = aceGUI:Create('InlineGroup')
        local inlineWho = self.whoInline
        inlineWho:SetTitle('Who Results:')
        inlineWho:SetLayout('Flow')
        inlineWho:SetRelativeWidth(.6)
        inlineWho:SetHeight(200)
        ns.screen.aMain:AddChild(inlineWho)

        local whoScroll = self.whoScroll
        whoScroll:SetLayout("Flow")
        whoScroll:SetFullWidth(true)
        whoScroll:SetHeight(187)
        inlineWho:AddChild(whoScroll)

        local lblWho = self.lblWho
        lblWho:SetText('Number of players found: '..#self.tblFound)
        lblWho:SetFullWidth(true)
        inlineWho:AddChild(lblWho)
    end

    local inlineBottomLeft = aceGUI:Create('InlineGroup')
    inlineBottomLeft:SetTitle('Recruit Scanning:')
    inlineBottomLeft:SetLayout('Flow')
    inlineBottomLeft:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineBottomLeft:SetHeight(100)
    ns.screen.aMain:AddChild(inlineBottomLeft)

    local searchScroll = aceGUI:Create("ScrollFrame")
    searchScroll:SetLayout("Flow")
    searchScroll:SetFullWidth(true)
    searchScroll:SetHeight(55)
    inlineBottomLeft:AddChild(searchScroll)

    local btnSearch = self.btnSearch
    btnSearch:SetText('Start Search')
    btnSearch:SetFullWidth(true)
    btnSearch:SetCallback('OnClick', function() scanner:NextQuery() end)
    searchScroll:AddChild(btnSearch)

    local lblNextTitle = aceGUI:Create("Label")
    lblNextTitle:SetText('Next filter: ')
    lblNextTitle:SetFont(DEFAULT_FONT, 10, 'OUTLINE')
    lblNextTitle:SetFullWidth(true)
    searchScroll:AddChild(lblNextTitle)

    local lblNextFilter = self.lblNextFilter
    lblNextFilter:SetText('')
    lblNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblNextFilter:SetFullWidth(true)
    searchScroll:AddChild(lblNextFilter)

    if not self.isCompact then
        self.statsInline = aceGUI:Create('InlineGroup')
        local inlineBottomRight = self.statsInline
        inlineBottomRight:SetTitle('Session Stats:')
        inlineBottomRight:SetLayout('Flow')
        inlineBottomRight:SetRelativeWidth(.6)
        inlineBottomRight:SetHeight(100)
        ns.screen.aMain:AddChild(inlineBottomRight)

        local statsScroll1 = aceGUI:Create("ScrollFrame")
        statsScroll1:SetLayout("Flow")
        statsScroll1:SetRelativeWidth(.5)
        statsScroll1:SetHeight(55)
        inlineBottomRight:AddChild(statsScroll1)

        local lblTotalScanned = self.lblTotalScanned
        lblTotalScanned:SetText('Total Scanned: '..self.totalScanned)
        lblTotalScanned:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalScanned:SetFullWidth(true)
        statsScroll1:AddChild(lblTotalScanned)

        local lblTotalInvites = self.lblTotalInvites
        lblTotalInvites:SetText('Total Invites: '..self.totalInvites)
        lblTotalInvites:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalInvites:SetFullWidth(true)
        statsScroll1:AddChild(lblTotalInvites)

        local lblUnknown = self.lblUnknown
        lblUnknown:SetText('Waiting On: '..self.totalUnknown)
        lblUnknown:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblUnknown:SetFullWidth(true)
        statsScroll1:AddChild(lblUnknown)

        local statsScroll2 = aceGUI:Create("ScrollFrame")
        statsScroll2:SetLayout("Flow")
        statsScroll2:SetRelativeWidth(.5)
        statsScroll2:SetHeight(55)
        inlineBottomRight:AddChild(statsScroll2)

        local lblTotalDeclined = self.lblTotalDeclined
        lblTotalDeclined:SetText('Total Declined: '..self.totalDeclined)
        lblTotalDeclined:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalDeclined:SetFullWidth(true)
        statsScroll2:AddChild(lblTotalDeclined)

        local lblTotalAccepted = self.lblTotalAccepted
        lblTotalAccepted:SetText('Total Accepted: '..self.totalAccepted)
        lblTotalAccepted:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalAccepted:SetFullWidth(true)
        statsScroll2:AddChild(lblTotalAccepted)

        local lblTotalBlackList = self.lblTotalBlackList
        lblTotalBlackList:SetText('Total Black List: '..self.totalBlackList)
        lblTotalBlackList:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblTotalBlackList:SetFullWidth(true)
        statsScroll2:AddChild(lblTotalBlackList)
    end

    scanner:SetupFilter()
    scanner:SetButtonStates()
end
function scanner:InvitePlayer()
    local db = ns.db.settings

    local pName = next(self.tblFound or {})
    if not pName or self.tblFound[pName].checked then return end

    local sendInvite = db.inviteFormat ~= 1 or false
    local invMessage = ns.code:GuildReplace(self.message, pName) or ''
    ns.invite:SendInviteToPlayer(pName, invMessage, sendInvite, self.tblFound[pName].class or nil)
    self.tblFound[pName] = nil

    scanner:SetButtonStates()
    scanner:ShowResults('INVITE')

    local function invWait(remain)
        if remain > 0 then
            self.btnInvite:SetDisabled(true)
            self.btnInvite:SetText('Waiting...')
            C_Timer.After(1, function() invWait(remain - 1) end)
        else
            scanner:SetButtonStates()
            self.btnInvite:SetText('Invite')
        end
    end
    scanner:SetButtonStates()
    self.btnInvite:SetDisabled(true)
    invWait(INVITE_WAIT_TIME)
end
function scanner:SetupFilter()
    local db, dbFilter = ns.db.settings, ns.db.filter
    self.tblFilter = self.tblFilter and table.wipe(self.tblFilter) or {}
    local min, max = (tonumber(db.minLevel) or 1), (tonumber(db.maxLevel) or MAX_CHARACTER_LEVEL)

    local function createRaceFilter()
        for _,r in pairs(ns.datasets.tblAllRaces) do
            local filter = 'r-"'..r..'"'
            for i=min, max, 5 do
                local rangeStart, rangeEnd = i, i + 4
                if rangeEnd > max then rangeEnd = max and max or (MAX_CHARACTER_LEVEL or 70) end
                tinsert(self.tblFilter, filter..' '..rangeStart..'-'..rangeEnd)
            end
        end
    end
    local function createClassFilter()
        for _,r in pairs(ns.datasets.tblAllClasses or {}) do
            local class = r.classFile:gsub('DEATHKNIGHT', 'DEATH KNIGHT'):gsub('DEMONHUNTER', 'DEMON HUNTER')
            local filter = 'c-"'..class..'"'
            for i=min, max, 5 do
                local rangeStart, rangeEnd = i, i + 4
                if rangeEnd > max then rangeEnd = max and max or (MAX_CHARACTER_LEVEL or 70) end
                tinsert(self.tblFilter, filter..' '..rangeStart..'-'..rangeEnd)
            end
        end
    end
    local function createCutomFilter(filterList)
        if not filterList then return end
            local tblAllClasses = ns.datasets.tblAllClasses or {}

            local minLevel, maxLevel = tonumber(db.minLevel), tonumber(db.maxLevel)
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

    local fID = dbFilter.activeFilter or 1
    if fID == 2 then createRaceFilter()
    elseif fID >= 10 then
        fID = fID - 10
        local filter = dbFilter.filterList[fID] or nil
        if not filter then
            self.lblNextFilter:SetText(ns.code:cText('FFFF0000', 'Invalid Filter'))
            return
        else self.tblFilter = createCutomFilter(filter) end
    else createClassFilter() end

    self.lblNextFilter:SetText((ns.code:cText('FF00FF00', self.tblFilter[1]) or ns.code:cText('FFFF0000', 'Invalid Filter')))
    if not self.tblFilter[1] then
        self.btnSearch:SetDisabled(true)
        self.btnSearch:SetText('Start Search')
    else
        self.btnSearch:SetDisabled(false)
        self.totalFilters = #self.tblFilter
    end
end
function scanner:NextQuery()
    self.tblWho = table.wipe(self.tblWho)

    local filter = tremove(self.tblFilter, 1)
    if not filter or #self.tblFilter == 0 then
        scanner:SetupFilter()
        if #self.tblFilter == 0 then return end
        filter = filter or self.tblFilter[1]
    else self.lblNextFilter:SetText(ns.code:cText('FF00FF00', self.tblFilter[1])) end

    local function StartWhoQuery()
        if ns.db.settings.showWho and FriendsFrame:IsShown() then FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
        else FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE") end

        local function CallBackWhoListUpdate()
            GRADDON:UnregisterEvent('WHO_LIST_UPDATE')

            self.tblWho = table.wipe(self.tblWho) or {}
            self.tblFound = self.tblFound or {}

            ns.events:UnregisterEvent('WHO_LIST_UPDATE')
            for i=1,C_FriendList.GetNumWhoResults() do
                local info = C_FriendList.GetWhoInfo(i)
                local pName = gsub(info.fullName, '-'..GetRealmName(), '')
                local rec = {name = pName, class = info.filename, level = info.level, guild = (info.fullGuildName or ''), zone = info.area}

                tinsert(self.tblWho, rec)
            end

            if not self.isCompact then
                self.lblWho:SetText('Number of players found: '..C_FriendList.GetNumWhoResults())
            end
            self.analytics:TotalScanned(C_FriendList.GetNumWhoResults())
            scanner:ShowResults('BOTH')
        end
        GRADDON:RegisterEvent('WHO_LIST_UPDATE', CallBackWhoListUpdate)

        C_FriendList.SetWhoToUi(true)
        C_FriendList.SendWho(filter)
    end
    local function waitTimer(remain, nextFilter)
        if remain > 0 then
            self.btnSearch:SetDisabled(true)
            self.btnSearch:SetText('Next search in '..remain)
            C_Timer.After(1, function() waitTimer(remain - 1, nextFilter) end)
        else
            self.btnSearch:SetDisabled(false)
            self.btnSearch:SetText('Search Ready')
        end
    end

    StartWhoQuery()
    local percent = (self.totalFilters - #self.tblFilter) / self.totalFilters
    local statusMsg = 'Filter progress: '..FormatPercentage(percent, 2)
    ns.screen.status:SetText(statusMsg)

    waitTimer((ns.db.settings.scanWaitTime or SCAN_WAIT_TIME), filter)
end
function scanner:ShowResults(ShowWhich)
    local tblPotential = self.tblWho or self.tblFound or {}

    local function createCheckBox(pName, pClass, pLevel)
        local level = pLevel == MAX_CHARACTER_LEVEL and ns.code:cText('FF00FF00', pLevel) or (pLevel >= MAX_CHARACTER_LEVEL - 10 and ns.code:cText('FFFFFF00', pLevel) or pLevel)

        local checkBox = aceGUI:Create('CheckBox')
        checkBox:SetLabel(ns.code:cPlayer(pName, pClass))
        checkBox:SetRelativeWidth(.85)
        checkBox:SetValue(false)
        checkBox:SetCallback('OnValueChanged', function(_, _, value)
            self.tblFound[pName].isChecked = value
            scanner:SetButtonStates()
        end)
        self.invScroll:AddChild(checkBox)

        local lblLevel = aceGUI:Create("Label")
        lblLevel:SetText(level)
        lblLevel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblLevel:SetRelativeWidth(.15)
        self.invScroll:AddChild(lblLevel)
    end
    local function createWhoEntry(tbl)
        local lblLevel = aceGUI:Create("Label")
        lblLevel:SetText(tbl.level == MAX_CHARACTER_LEVEL and ns.code:cText('FF00FF00', tbl.level) or (tbl.level >= MAX_CHARACTER_LEVEL - 10 and ns.code:cText('FFFFFF00', tbl.level) or tbl.level))
        lblLevel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblLevel:SetRelativeWidth(.1)
        self.whoScroll:AddChild(lblLevel)

        local lblName = aceGUI:Create("Label")
        lblName:SetText(ns.code:cPlayer(tbl.name, tbl.class) or 'No Name')
        lblName:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblName:SetRelativeWidth(.35)
        self.whoScroll:AddChild(lblName)

        local lblGuild = aceGUI:Create("Label")
        lblGuild:SetText(tbl.guild or '')
        lblGuild:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        lblGuild:SetRelativeWidth(.52)
        self.whoScroll:AddChild(lblGuild)
    end
    local function showWho()
        for i=1, #self.tblWho do
            local rec = self.tblWho[i]
            print(rec.name, rec.class, rec.level, rec.guild)
        end
        if self.isCompact then return end

        self.whoScroll:ReleaseChildren()
        for i=1, #self.tblWho do
            local rec = self.tblWho[i]
            createWhoEntry({ name = rec.name, class = rec.class, level = rec.level, guild = rec.guild })
        end
    end
    local function showInvites()
        self.invScroll:ReleaseChildren()

        while #tblPotential > 0 do
            local rec = tremove(tblPotential, 1)
            if (not rec.guild or rec.guild == '') and ns.invite:CheckAbilityToInvite(rec.name, rec.zone) then
                self.tblFound[rec.name] = { name = rec.name, class = rec.class, level = rec.level, isChecked = false }
            end
        end

        local foundCount = 0
        for k, r in pairs(self.tblFound) do
            foundCount = foundCount + 1
            createCheckBox(k, r.class, r.level)
        end

        self.lblFound:SetText('Ready for invite: '..foundCount)
    end

    if ShowWhich == 'WHO' then showWho()
    elseif ShowWhich == 'INVITE' then showInvites()
    elseif ShowWhich == 'BOTH' then
        showWho()
        showInvites()
    end

    scanner:SetButtonStates()
end
function scanner:analytics()
    local tbl = {}
    function tbl:TotalScanned(amt)
        ns.scanner.totalScanned = ns.scanner.totalScanned + (amt or 1)
        ns.scanner.lblTotalScanned:SetText('Total Scanned: '..ns.scanner.totalScanned)

        ns.analytics:Scanned(amt)
    end
    function tbl:TotalInvites(amt)
        ns.scanner.totalInvites = ns.scanner.totalInvites + (amt or 1)
        ns.scanner.lblTotalInvites:SetText('Total Invites: '..ns.scanner.totalInvites)

        ns.analytics:Invited(amt)
    end
    function tbl:TotalBlackList(amt)
        ns.scanner.totalBlackList = ns.scanner.totalBlackList + (amt or 1)
        ns.scanner.lblTotalBlackList:SetText('Total Black List: '..ns.scanner.totalBlackList)

        ns.analytics:BlackListed(amt)
    end
    function tbl:TotalDeclined(amt)
        ns.scanner.totalDeclined = ns.scanner.totalDeclined + (amt or 1)
        ns.scanner.lblTotalDeclined:SetText('Total Declined: '..ns.scanner.totalDeclined)

        ns.analytics:Declined(amt)
    end
    function tbl:TotalAccepted(amt)
        ns.scanner.totalAccepted = ns.scanner.totalAccepted + (amt or 1)
        ns.scanner.lblTotalAccepted:SetText('Total Accepted: '..ns.scanner.totalAccepted)

        ns.analytics:Accepted(amt)
    end
    function tbl:WaitingOn(amt)
        ns.scanner.totalUnknown = ns.scanner.totalUnknown + (amt or 1)
        ns.scanner.lblUnknown:SetText('Waiting On: '..ns.scanner.totalUnknown)
    end
    return tbl
end
scanner:Init()