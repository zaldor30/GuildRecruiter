local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI, aceTimer = LibStub('AceGUI-3.0'), LibStub('AceTimer-3.0')
local p,g, dbInv = nil, nil, nil

local INVITE_PREFIX = 'Invites Found: '
local STATUS_TEXT_DEFAULT = 'Guild Recruiter'
local SEARCH_BUTTON_PREFIX = 'Search for Players'

ns.ScreenInvite, ns.InvitePlayers = {}, {}
local si, ip = ns.ScreenInvite, ns.InvitePlayers
local function CallBackWhoQueryResults(...) si:CallBackWhoQueryResults() end

function si:Init()
    self.showWhoQuery = false

    self.tblLog = {}
    self.tblFound = {}
    self.tblFilter = {}

    -- Refrenced Widgets
    self.f = nil

    self.pfScroll = aceGUI:Create("ScrollFrame")
    self.whoScroll = aceGUI:Create("ScrollFrame")

    self.btnSearch = aceGUI:Create('Button')
    self.btnInvite = aceGUI:Create('Button')
    self.btnRemove = aceGUI:Create('Button')

    self.labelLog = aceGUI:Create("Label")
    self.labelFound = aceGUI:Create("Label")
    self.labelProgress = aceGUI:Create("Label")
    self.labelNextFilter = aceGUI:Create("Label")
end
function si:performQuery()
    local function hideWhoQueryWindow(show)
        ns.code:ClickSound('DISABLE')
        if self.showWhoQuery and not FriendsFrame:IsVisible() then
            FriendsFrame:Show()
            ns.code:ClickSound('ENABLE')
            return
        end

        if show then FriendsFrame:Show()
        else FriendsFrame:Hide() end
        ns.code:ClickSound('ENABLE')
    end
    local function createQueries()
        self.tblFilter = table.wipe(self.tblFilter) or {}
        local min, max = (p and p.minLevel or 1), (p and p.maxLevel or MAX_CHARACTER_LEVEL)

        local function createClassFilter()
            for _,r in pairs(ns.datasets.tblAllClasses) do
                local class = r.classFile:gsub('DEATHKNIGHT', 'DEATH KNIGHT'):gsub('DEMONHUNTER', 'DEMON HUNTER')
                local filter = 'c-"'..class..'"'
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
            if not filter then
                UIErrorsFrame:AddMessage('Filter Missing', 1.0, 0.1, 0.1, 1.0)
            else self.tblFilter = filter end
        end

        self.totalFilters = #self.tblFilter
        si:performQuery()
    end
    local function nextQuery()
        if not self.tblFilter or #self.tblFilter == 0 then
            createQueries()
            return
        end

        local function waitTimer(remain, nextFilter)
            if remain <= 0 then
                self.btnSearch:SetDisabled(false)
                self.btnSearch:SetText(SEARCH_BUTTON_PREFIX..' ('..(self.tblFilter[1] or '<none>')..')')
            else
                self.btnSearch:SetDisabled(true)
                self.btnSearch:SetText(SEARCH_BUTTON_PREFIX..' - Search cooldown '.. remain)
                remain = remain - 1
                C_Timer.After(1, function() waitTimer(remain, nextFilter) end)
            end
        end

        local filter = table.remove(self.tblFilter, 1)
        self.btnSearch:SetText(SEARCH_BUTTON_PREFIX..' ('..(self.tblFilter[1] or '<none>')..')')
        self.labelNextFilter:SetText('Current Filter: '..(filter or 'Press "Seach for Players" to restart filter.'), self.MAX_LENGTH)
        -- Show query window, search then hide again.
        hideWhoQueryWindow(true)
        C_FriendList.SendWho(filter)
        C_Timer.After(.5, function() hideWhoQueryWindow() end)
        waitTimer((g.scantime or SCAN_WAIT_TIME), (filter or '<none>'))

        local percent = (self.totalFilters - #self.tblFilter) / self.totalFilters
        self.f:SetStatusText(STATUS_TEXT_DEFAULT..' (Filter progress: '..FormatPercentage(percent, 2)..')')

    end

    nextQuery()
end

-- Build/Startup of Screen Scanner
function si:StartScreenScanner()
    p,g, dbInv = ns.db.profile, ns.db.global, ns.dbInv.global

    self.showWhoQuery = (p.showWhoQuery or false)
    ns.MainScreen.f:Hide()
    if self.f then self.f:Show()
    else
        si:buildScreenScanner()
        -- Initial registration of event, OnShow does not work on build
        GRADDON:RegisterEvent('WHO_LIST_UPDATE', CallBackWhoQueryResults)
    end

    local count = 0
    for _ in pairs(self.tblFilter or {}) do count = count + 1 end
    if count == 0 then si:performQuery() end
end
function si:buildScreenScanner()
    self.f = aceGUI:Create('Frame')
    self.f:SetTitle('Guild Recruiter Scanning')
    self.f:SetStatusText(GR_VERSION_INFO)
    self.f:EnableResize(false)
    self.f:SetWidth(600)
    self.f:SetHeight(475)
    self.f:SetLayout('flow')
    self.f:SetCallback('OnShow', function()
        self.showWho = p.showWho or false
        GRADDON:RegisterEvent('WHO_LIST_UPDATE', CallBackWhoQueryResults)
    end)
    self.f:SetCallback('OnClose', function()
        if ip.invitedCount > 0 then
            ns.code:consoleOut('You invited '..ip.invitedCount..' players to the guild.') end
        aceTimer:CancelAllTimers()
        GRADDON:UnregisterEvent('WHO_LIST_UPDATE')
    end)

    si:InviteGroup()
    si:WhoGroup()
    si:FooterGroup()

    local btn = aceGUI:Create('Button')
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function()
        GRADDON:UnregisterEvent('WHO_LIST_UPDATE')
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
        self.f:Hide()
    end)
    self.f:AddChild(btn)

    btn = aceGUI:Create('Button')
    btn:SetText('Main Screen')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function()
        GRADDON:UnregisterEvent('WHO_LIST_UPDATE')
        ns.MainScreen:ShowMainScreen()
        self.f:Hide()
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
    btnInvite:SetCallback('OnEnter', function()
        local title = 'Invite players to guild'
        local body = 'Checked players are for adding to black list.'
        ns.widgets:createTooltip(title, body)
    end)
    btnInvite:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnInvite:SetCallback('OnClick', function() ip:InvitePlayers() end)
    pfGroup:AddChild(btnInvite)

    local btnRemove = self.btnRemove
    btnRemove:SetText('BL')
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetDisabled(true)
    btnRemove:SetCallback('OnEnter', function()
        local title = 'Black List Players'
        local body = 'Checked players will be added to black list.'
        ns.widgets:createTooltip(title, body)
    end)
    btnRemove:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnRemove:SetCallback('OnClick', function()
    end)
    pfGroup:AddChild(btnRemove)

    local labelFound = self.labelFound
    labelFound:SetText(INVITE_PREFIX..#self.tblFound)
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
    whoScroll:SetHeight(230)
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

    self.labelNextFilter:SetFullWidth(true)
    self.labelNextFilter:SetText('Filter active: <none>')
    self.labelNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(self.labelNextFilter)

    self.btnSearch:SetText('Search for Players')
    self.btnSearch:SetFullWidth(true)
    self.btnSearch:SetCallback('OnClick', function() si:performQuery() end)
    footerGroup:AddChild(self.btnSearch)

    -- Create a label to display the progress percentage
    self.labelProgress:SetHeight(20)
    self.labelProgress:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(self.labelProgress)
end

-- Function Event Call Backs
function si:CreateResultWindows(whichOne)
    local function createWhoResults()
        self.whoScroll:ReleaseChildren()
        self.labelLog:SetText('Players found: '..(#self.tblLog or 0))

        local tbl = table.remove(self.tblLog, 1)
        while self.tblLog and #self.tblLog > 0 do
            local group = aceGUI:Create('SimpleGroup')
            group:SetFullWidth(true)
            group:SetLayout("flow")
            self.whoScroll:AddChild(group)

            local icon = aceGUI:Create('Icon')
            icon:SetImage(GRADDON.classInfo[tbl.class].icon)
            icon:SetImageSize(12, 12)
            icon:SetWidth(20)
            group:AddChild(icon)

            group:AddChild(ns.widgets:createLabel(ns.code:cPlayer(tbl.name, tbl.class), 100))
            group:AddChild(ns.widgets:createLabel(tbl.level, 20))
            group:AddChild(ns.widgets:createLabel(tbl.guild, 150))

            tbl = table.remove(self.tblLog, 1)
        end
    end
    local function createPlayersFound()
        self.pfScroll:ReleaseChildren()

        local rCount = 0
        for k, r in pairs(self.tblFound or {}) do
            rCount = rCount + 1
            local checkBox = aceGUI:Create('CheckBox')
            checkBox:SetLabel(ns.code:cPlayer(k, r.class or nil))
            checkBox:SetFullWidth(true)
            checkBox:SetCallback('OnValueChanged', function(val)
                local name = k
                self.tblFound[name].checked = val.checked

                local checked = false
                for _, rec in pairs(self.tblFound or {}) do
                    if rec.checked then checked = true break end
                end
                self.btnInvite:SetDisabled(checked)
                self.btnRemove:SetDisabled(not checked)
            end)
            self.pfScroll:AddChild(checkBox)
        end
        ip.totalFound = rCount

        self.labelFound:SetText(INVITE_PREFIX..rCount)
        self.btnInvite:SetDisabled(self.tblFound == {})
        self.btnRemove:SetDisabled(true)
    end

    if not whichOne then
        createPlayersFound()
        createWhoResults()
    elseif whichOne == 'PLAYERS_FOUND' then createPlayersFound()
    elseif whichOne == 'WHO_RESULTS' then createWhoResults() end
end
function si:CallBackWhoQueryResults()
    self.tblLog = table.wipe(self.tblLog) or {}
    self.tblFound = self.tblFound or {}

    for i=1,C_FriendList.GetNumWhoResults() do
        local info = C_FriendList.GetWhoInfo(i)
        local rec = {name = info.fullName, class = info.filename, level = info.level, guild = (info.fullGuildName or ''), info.area}

        table.insert(self.tblLog, rec)
        if info.fullGuildName == '' and not self.tblFound[info.fullName] and ns.Invite:canAddPlayer(info.fullName, info.area, false) then
            self.tblFound[info.fullName] = {name = info.fullName, class = info.filename, checked = false}
        end
    end

    si:CreateResultWindows()
    ns.Analytics:add('Players_Scanned', C_FriendList.GetNumWhoResults())
end
si:Init()

function ip:Init()
    self.totalFound = 0
    self.invitedCount = 0
end
function ip:InvitePlayers()
    local msg = (p.inviteFormat ~= 2 and p.activeMessage) and ns.code:GuildReplace(g.messages[p.activeMessage].message) or nil
    local sendInvite = p.inviteFormat ~= 1 or false

    local key = next(si.tblFound or {})
    local tbl = si.tblFound[key]
    if not tbl or tbl.checked then return end

    si.tblFound[key] = nil
    self.invitedCount = self.invitedCount + 1
    si.labelFound:SetText(INVITE_PREFIX..self.totalFound - self.invitedCount)
    ns.Invite:invitePlayer(key, msg, sendInvite, false, tbl.class)
    si:CreateResultWindows('PLAYERS_FOUND')

    si.btnSearch:SetDisabled(true)
    C_Timer.After(2, function() si.btnSearch:SetDisabled(false) end)
end
ip:Init()