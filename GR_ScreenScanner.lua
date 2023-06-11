local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")
local p,g = nil, nil

ns.ScreenInvite = {}
local si = ns.ScreenInvite
function si:Init()
    self.tblLog = {}
    self.tblFound = {}
    self.tblFilter = {}

    self.showWho = false
    self.MAX_LENGTH = 30

    self.hidden = false
    self.totalFilters = 0

    self.f = nil
    self.pfScroll = aceGUI:Create("ScrollFrame")

    self.btnSearch = aceGUI:Create('Button')
    self.btnInvite = aceGUI:Create('Button')
    self.btnRemove = aceGUI:Create('Button')

    self.labelFound = aceGUI:Create("Label")

    self.whoScroll = aceGUI:Create("ScrollFrame")

    self.labelLog = aceGUI:Create("Label")
    self.labelPrevFilter = aceGUI:Create("Label")
    self.labelNextFilter = aceGUI:Create("Label")
    self.labelProgress = aceGUI:Create("Label")
end
-- Log and Found Routines
function si:showFound(foundTable)
    self.tblFound = foundTable
    local function createFound(pName)
        local checkBox = aceGUI:Create('CheckBox')
        checkBox:SetLabel(ns.code:cPlayer(pName))
        checkBox:SetValue(false)
        checkBox:ToggleChecked(true) -- Does not trigger callback
        checkBox:SetFullWidth(true)
        checkBox:SetCallback('OnValueChanged', function(val) self.tblFound[pName].checked = val.checked end)
        self.pfScroll:AddChild(checkBox)
    end

    local c = 0
    self.pfScroll:ReleaseChildren()
    if not self.tblFound then self.tblFound = {}
    else
        for _,r in pairs(self.tblFound) do
            createFound(r.name)
            c = c + 1
        end
        self.labelFound:SetText('Inites Ready: '..c)
    end

    if c > 0 then
        self.btnInvite:SetDisabled(false)
        self.btnRemove:SetDisabled(false)
    else
        self.btnInvite:SetDisabled(true)
        self.btnRemove:SetDisabled(true)
    end
end
function si:showLog(logTable)
    self.tblLog = logTable
    local function CreateLog(tbl)
        local class, pName, level, guild = tbl.class, tbl.name, tbl.level, tbl.guild

        local icon = aceGUI:Create('Icon')
        icon:SetImage(GRADDON.classInfo[class].icon)
        icon:SetImageSize(12, 12)
        icon:SetWidth(20)
        self.whoScroll:AddChild(icon)

        local label = aceGUI:Create('Label')
        label:SetText(ns.code:cPlayer(pName, class))
        label:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        label:SetWidth(100)
        self.whoScroll:AddChild(label)

        label = aceGUI:Create('Label')
        label:SetText(level)
        label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
        label:SetWidth(20)
        self.whoScroll:AddChild(label)

        label = aceGUI:Create('Label')
        label:SetText(guild)
        label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
        label:SetWidth(190)
        self.whoScroll:AddChild(label)
    end

    self.whoScroll:ReleaseChildren()
    self.labelLog:SetText('Players found: '..(#self.tblLog or 0))
    while self.tblLog and #self.tblLog > 0 do
        CreateLog(table.remove(self.tblLog, 1))
    end
end

-- Filter Routines
function si:startWaitTimer(timeRemain, percent)
    timeRemain = type(timeRemain) ~= 'number' and tonumber(timeRemain) or timeRemain
    if timeRemain <= 0 then
        self.btnSearch:SetDisabled(false)
        self.btnSearch:SetText('Search for Players')
        self.f:SetStatusText('Ready for next scan! (Filter Progress: '..percent..')')
    elseif not self.hidden then
        C_Timer.After(timeRemain, function()
            self.btnSearch:SetText('Search for Players ('..timeRemain..')')
            si:startWaitTimer(timeRemain - 1, percent)
        end)
    end
end
function si:createFilter()
    self.tblFilter = self.tblFilter and table.wipe(self.tblFilter) or {}
    local min, max = (p and p.minLevel or 1), (p and p.maxLevel or MAX_CHARACTER_LEVEL)

    local function createClassFilter()
        for _,r in pairs(ns.datasets.tblAllClasses) do
            local filter = 'c-"'..r.classFile..'"'
            local level, lMax = min, max
            if lMax - level > 5 and max ~= level then
                while level <= lMax do
                    if level > lMax then level = level-5 end
                    table.insert(self.tblFilter, filter..' '..level..'-'..(level + 5 <= lMax and level + 5 or lMax))
                    level = level + 5
                end
            else table.insert(self.tblFilter, filter..' '..min..'-'..max) end
        end
    end
    local function createRaceFilter()
        for _,r in pairs(ns.datasets.tblAllRaces) do
            local filter = 'r-"'..r..'"'
            local level, lMax = min, max
            if lMax - level > 5 then
                while level <= lMax do
                    if level > lMax then level = level-5 end
                    table.insert(self.tblFilter, filter..' '..level..'-'..(level + 5 <= lMax and level + 5 or lMax))
                    level = level + 5
                end
            else table.insert(self.tblFilter, filter..' '..min..'-'..max) end
        end
    end

    local filterID = p and p.activeFilter or 1
    if filterID == 1 then createClassFilter()
    elseif filterID == 2 then createRaceFilter()
    else
        local filter = g.filter[filterID].filter
        if not filter then ns.code.createErrorWindow('Filter Missing')
        else self.tblFilter = filter end
    end

    self.totalFilters = #self.tblFilter
    si:nextSearch()
end
function si:nextSearch()
    if not self.tblFilter or #self.tblFilter == 0 then self.f:SetStatusText('Waiting ...') return end

    local filter = table.remove(self.tblFilter, 1)
    self.labelPrevFilter:SetText(ns.code:TruncateString('Current Search: '..filter, self.MAX_LENGTH))
    self.labelNextFilter:SetText(ns.code:TruncateString('Next Search: '..(self.tblFilter[1] or '<none>'), self.MAX_LENGTH))
    C_FriendList.SendWho(filter)
    self.btnSearch:SetDisabled(true)

    local percent = (self.totalFilters - #self.tblFilter) / self.totalFilters
    si:startWaitTimer(g.scanTime or SCAN_WAIT_TIME, FormatPercentage(percent, 2))
    self.f:SetStatusText('Waiting for Blizz (Filter progress: '..FormatPercentage(percent, 2)..')')
end

-- Screen Routines
function si:HideFriendsList()
    if not FriendsFrame:IsVisible() then return end

    ns.code:ClickSound('DISABLE')
    FriendsFrame:Hide()
    ns.code:ClickSound('ENABLE')
end
function si:hide()
    GRADDON:UnregisterEvent('WHO_LIST_UPDATE')
    self.hidden = true
    self.f:Hide()
end
function si:RefreshScannerScreen(tbl, skip) -- WHO_LIST_UPDATE located here
    function GRADDON:searchWhoResultCallback(_, ...) -- When WHO_LIST_UPDATE event is returned
        if not self.showWho then si:HideFriendsList() end
        self.tblLog = self.tblLog and table.wipe(self.tblLog) or {}
        self.tblFound = self.tblFound and self.tblFound or {}

        ns.Analytics:add('Players_Scanned', C_FriendList.GetNumWhoResults())
        for i=1,C_FriendList.GetNumWhoResults() do
            local info = C_FriendList.GetWhoInfo(i)
            table.insert(self.tblLog, {name = info.fullName, class = info.filename, level = info.level, guild = info.fullGuildName or '', info.area})
            if not info.fullGuildName or info.fullGuildName == '' then
                if not self.tblFound[info.fullName] and ns.Invite:canAddPlayer(info.fullName, info.area) then
                    self.tblFound[info.fullName] = {name = info.fullName, class = info.filename, checked = true}
                end
            end
        end

        si:showLog(self.tblLog)
        si:showFound(self.tblFound)
    end

    self.hidden = false
    self.tblFound = tbl and tbl or self.tblFound
    GRADDON:RegisterEvent('WHO_LIST_UPDATE', 'searchWhoResultCallback')
    if self.f and not skip then self.f:Show() end
end
function si:ScreenScanner()
    p,g = ns.db.profile, ns.db.global
    self.showWho = p.showWho or false

    if self.f then self.f:Show() return end
    si:RefreshScannerScreen(nil, 'SKIP')

    self.f = aceGUI:Create('Frame')
    self.f:SetTitle('Guild Recruiter Scanning')
    self.f:SetStatusText('Waiting...')
    self.f:EnableResize(false)
    self.f:SetWidth(600)
    self.f:SetHeight(470)
    self.f:SetLayout('flow')
    self.f:SetCallback('OnClose', function()
        FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
    end)

    si:InviteGroup()
    si:WhoGroup()
    si:FooterGroup()

    local btn = aceGUI:Create('Button')
    btn:SetText('Main Screen')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        ns.MainScreen:ShowMainScreen()
        si:hide()
    end)
    self.f:AddChild(btn)

    btn = aceGUI:Create('Button')
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
        si:hide()
    end)
    self.f:AddChild(btn)
end
function si:InviteGroup()
    local pfGroup = aceGUI:Create('InlineGroup') -- Potential invite group
    pfGroup:SetTitle('Players Found')
    pfGroup:SetLayout("flow")
    pfGroup:SetWidth(182.5)
    self.f:AddChild(pfGroup)

    local pfScroll = self.pfScroll
    pfScroll:SetLayout("Flow")
    pfScroll:SetFullWidth(true)
    pfScroll:SetHeight(200)
    pfGroup:AddChild(pfScroll)

    local btnInvite = self.btnInvite
    btnInvite:SetText('Invite')
    btnInvite:SetRelativeWidth(.5)
    btnInvite:SetDisabled(true)
    btnInvite:SetCallback('OnClick', function(_, _)
        local tbl, c = {}, 0
        for k, r in pairs(self.tblFound) do
            if not r.checked then
                c = c + 1
                tbl[k] = r
            end
        end
        if c > 0 then
            ns:InvitePlayers(tbl)
            self.f:Hide()
        else ns.code.consoleOut('There are no records marked to invite.') end
    end)
    pfGroup:AddChild(btnInvite)

    local btnRemove = self.btnRemove
    btnRemove:SetText('Remove')
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetCallback('OnClick', function(_, _)
        local rCount = 0
        for k, r in pairs(self.tblFound) do
            if r.checked then
                rCount = rCount + 1
                ns.Invite:logInvite(k, r.class)
                self.tblFound[k] = nil
            end
        end

        si:showFound()
        ns.code.consoleOut(rCount..' players were added to invited list.')
    end)
    pfGroup:AddChild(btnRemove)

    local labelFound = self.labelFound
    labelFound:SetText('Inites Ready: '..#self.tblFound)
    labelFound:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    labelFound:SetFullWidth(true)
    pfGroup:AddChild(labelFound)
end
function si:WhoGroup()
    local whoGroup = aceGUI:Create('InlineGroup')
    whoGroup:SetTitle('Who Results')
    whoGroup:SetLayout("flow")
    whoGroup:SetWidth(382.5)
    self.f:AddChild(whoGroup)

    local whoScroll = self.whoScroll
    whoScroll:SetLayout("Flow")
    whoScroll:SetFullWidth(true)
    whoScroll:SetHeight(225)
    whoGroup:AddChild(whoScroll)

    self.labelLog:SetText('Players Found: '..#self.tblLog)
    self.labelLog:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    self.labelLog:SetFullWidth(true)
    whoGroup:AddChild(self.labelLog)
end
function si:FooterGroup()
    local footerGroup = aceGUI:Create('InlineGroup')
    footerGroup:SetTitle('Note: Not all players can get invites, those will not get messages.')
    footerGroup:SetLayout("flow")
    footerGroup:SetFullWidth(true)
    footerGroup:SetHeight(150)
    self.f:AddChild(footerGroup)

    self.labelPrevFilter:SetWidth(280)
    self.labelPrevFilter:SetText('Filter active: <none>')
    self.labelPrevFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(self.labelPrevFilter)

    self.labelNextFilter:SetWidth(250)
    self.labelNextFilter:SetText('Filter active: <none>')
    self.labelNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(self.labelNextFilter)

    self.btnSearch:SetText('Search for Players')
    self.btnSearch:SetFullWidth(true)
    self.btnSearch:SetCallback('OnClick', function(_, _)
        if not self.tblFilter or #self.tblFilter == 0 then si:createFilter()
        else si:nextSearch() end
    end)
    footerGroup:AddChild(self.btnSearch)

    -- Create a label to display the progress percentage
    self.labelProgress:SetHeight(20)
    self.labelProgress:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(self.labelProgress)
end
si:Init()