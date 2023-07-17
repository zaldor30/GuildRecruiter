local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI, aceTimer = LibStub('AceGUI-3.0'), LibStub('AceTimer-3.0')

local INVITE_PREFIX = 'Invites Found: '
local STATUS_TEXT_DEFAULT = 'Guild Recruiter'
local SEARCH_BUTTON_PREFIX = 'Search for Players'

ns.ScreenInvite, ns.Invite = {}, {}
local si, invite = ns.ScreenInvite, ns.Invite

function si:Init()
    self.isStarted = false
    self.isCompact = false
    self.showWhoQuery = false
    self.compactActive = false
    self.chatMsgCallBack = false

    self.mssage = nil
    self.totalFilters = 0

    self.tblLog = {}
    self.tblFound = {}
    self.tblFilter = {}

    -- Refrenced Widgets
    self.f = nil

    self.pfScroll = aceGUI:Create("ScrollFrame")
    self.whoScroll = aceGUI:Create("ScrollFrame")

    self.btnReset = aceGUI:Create('Button')
    self.btnSearch = aceGUI:Create('Button')
    self.btnInvite = aceGUI:Create('Button')
    self.btnRemove = aceGUI:Create('Button')

    self.labelLog = aceGUI:Create("Label")
    self.labelFound = aceGUI:Create("Label")
    self.labelNextFilter = aceGUI:Create("Label")
end
function si:StartScreenScanner()
    if not self.isStarted then
        self.isStarted = true
        self.isCompact = ns.db.settings.compactMode or false
        self.showWhoQuery = ns.db.settings.showWho or false
    end

    local dbMessageList = ns.datasets.tblGMMessages or {}
    self.message = ns.db.messages.activeMessage and ns.code:GuildReplace(dbMessageList[ns.db.messages.activeMessage].message) or nil

    if self.f and self.isCompact == self.compactActive then self.f:Show()
    elseif self.isCompact then si:CompactModeScanner()
    else si:FullSizeScreenScanner() end

    _G["GuildRecruiter"] = self.f
    tinsert(UISpecialFrames, "GuildRecruiter")

    si:performQuery('SKIP_NEXT')
end

-- Creation of Scanner Screen
function si:ResetFilter()
    local recFound = next(self.tblFound)
    if not recFound then
        si:performQuery('RESET_FILTER')
        ns.code:consoleOut('Filter has been reset.')
        return
    end
    StaticPopupDialogs["MY_YES_NO_DIALOG"] = {
        text = "Do you want to reset players found?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            self.tblFound = table.wipe(self.tblFound) or {}
            si:CreateResultWindows('PLAYERS_FOUND')
            si:performQuery('RESET_FILTER')
            ns.code:consoleOut('Filter has been reset.')
        end,
        OnCancel = function()
            si:performQuery('RESET_FILTER')
            ns.code:consoleOut('Filter has been reset.')
        end,
        timeout = 10,
        whileDead = true,
        hideOnEscape = false,
    }
    StaticPopup_Show("MY_YES_NO_DIALOG")
end
function si:ConfirmBlackList()
    StaticPopupDialogs["MY_YES_NO_DIALOG"] = {
        text = "Are you sure you want to Black List\nthe selected players?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            for k, r in pairs(self.tblFound or {}) do
                if r.checked then
                    invite.removedCount = invite.removedCount + 1
                    ns.BlackList:add(k)
                    self.tblFound[k] = nil
                end
            end
            si:CreateResultWindows('PLAYERS_FOUND')
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
    }
    StaticPopup_Show("MY_YES_NO_DIALOG")
end
function si:SaveShowType()
    local msg = 'Would you like to make '..(self.isCompact and 'full screen mode' or 'compact screen mode'..'\nyour default for next time?')

    self.f:Hide()
    self.isCompact = not self.isCompact
    si:StartScreenScanner()
    StaticPopupDialogs["MY_YES_NO_DIALOG"] = {
        text = msg,
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            ns.db.settings.compactMode = self.isCompact
        end,
        timeout = 10,
        whileDead = true,
        hideOnEscape = true,
    }
    if ns.db.settings.compactMode ~= self.isCompact then
        StaticPopup_Show("MY_YES_NO_DIALOG") end
end
function si:ScannerOnClose()
    if ns.db.settings.showSummary then
        if (invite.removedCount or 0) > 0 then
            ns.code:consoleOut('You added '..invite.removedCount..' players to the black list.') end
        if (invite.invitedCount or 0) > 0 then
            ns.code:consoleOut('You invited '..invite.invitedCount..' players to the guild.')
            ns.code:consoleOut(invite.acceptedCount..' players accepted the guild invite.')
            ns.code:consoleOut(invite.declinedCount..' players declined the guild invite.')
            local remain = invite.invitedCount - (invite.acceptedCount + invite.declinedCount)
            if remain > 0 then ns.code:consoleOut(remain..' player have not responed at this time.') end
        end
    end
    invite.invitedCount, invite.removedCount, self.acceptedCount, self.declinedCount = 0, 0, 0, 0

    aceTimer:CancelAllTimers()
    self.f:Hide()
end
function si:CompactModeScanner()
    self.compactActive = true

    self.f = nil
    self.f = aceGUI:Create('Frame')
    self.f:SetTitle('Recruiter Scanning')
    self.f:EnableResize(false)
    self.f:SetWidth(210)
    self.f:SetHeight(480)
    self.f:SetLayout('flow')
    self.f:SetCallback('OnClose', function() si:ScannerOnClose() end)

    local btn = aceGUI:Create('Button')
    btn:SetText('Full Size')
    btn:SetFullWidth(true)
    btn:SetCallback('OnClick', function() si:SaveShowType() end)
    self.f:AddChild(btn)

    btn = self.btnReset
    btn:SetText('Reset Filter')
    btn:SetFullWidth(true)
    btn:SetCallback('OnClick', function() si:ResetFilter() end)
    self.f:AddChild(btn)

    si:InviteGroup()
    si:FooterGroup()
    si:WhoGroup()

    btn = aceGUI:Create('Button')
    btn:SetText('Main Screen')
    btn:SetFullWidth(true)
    btn:SetCallback('OnClick', function()
        si:ScannerOnClose()
        ns.MainScreen:ShowMainScreen()
        self.f:Hide()
    end)
    self.f:AddChild(btn)
end
function si:FullSizeScreenScanner()
    self.compactActive = false

    self.f = nil
    self.f = aceGUI:Create('Frame')
    self.f:SetTitle('Guild Recruiter Scanning')
    self.f:SetStatusText(GR_VERSION_INFO)
    self.f:EnableResize(false)
    self.f:SetWidth(600)
    self.f:SetHeight(510)
    self.f:SetLayout('flow')
    self.f:SetCallback('OnClose', function() si:ScannerOnClose() end)

    si:InviteGroup()
    si:WhoGroup()
    si:FooterGroup()

    local btn = aceGUI:Create('Button')
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function()
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
        self.f:Hide()
    end)
    self.f:AddChild(btn)

    btn = aceGUI:Create('Button')
    btn:SetText('Main Screen')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function()
        ns.MainScreen:ShowMainScreen()
        self.f:Hide()
    end)
    self.f:AddChild(btn)
end

-- Screen Scanner Sections and Widgets
function si:InviteGroup()
    local pfGroup = aceGUI:Create('InlineGroup') -- Potential invite group
    pfGroup:SetTitle('Players Found')
    pfGroup:SetLayout("flow")
    pfGroup:SetWidth(182.5)
    self.f:AddChild(pfGroup)

    if not self.isCompact then
        local btn = aceGUI:Create('Button')
        btn:SetText('Compact Mode')
        btn:SetFullWidth(true)
        btn:SetCallback('OnClick', function() si:SaveShowType() end)
        pfGroup:AddChild(btn)
    end

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
    btnInvite:SetCallback('OnClick', function() invite:ScannerInvitePlayer() end)
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
    btnRemove:SetCallback('OnClick', function() si:ConfirmBlackList() end)
    pfGroup:AddChild(btnRemove)

    local labelFound = self.labelFound
    labelFound:SetText(INVITE_PREFIX..#self.tblFound)
    labelFound:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    labelFound:SetFullWidth(true)
    pfGroup:AddChild(labelFound)
end
function si:WhoGroup()
    local whoGroup = nil
    if not self.isCompact then
        whoGroup = aceGUI:Create('InlineGroup')
        whoGroup:SetTitle('Who Results')
        whoGroup:SetLayout("flow")
        whoGroup:SetWidth(382.5)
        self.f:AddChild(whoGroup)

        local whoScroll = self.whoScroll
        whoScroll:SetLayout("Flow")
        whoScroll:SetFullWidth(true)
        whoScroll:SetHeight(255)
        whoGroup:AddChild(whoScroll)
    end

    self.labelLog:SetText('Players Found: '..#self.tblLog)
    self.labelLog:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    self.labelLog:SetFullWidth(true)
    local parent = whoGroup and whoGroup or self.f
    parent:AddChild(self.labelLog)
end
function si:FooterGroup()
    local footerGroup = nil
    if not self.isCompact then
        footerGroup = aceGUI:Create('InlineGroup')
        footerGroup:SetTitle('Note: Not all players can get invites, those will not get messages.')
        footerGroup:SetLayout("flow")
        footerGroup:SetHeight(150)
        footerGroup:SetFullWidth(true)
        self.f:AddChild(footerGroup)

        self.labelNextFilter:SetWidth(340)
        self.labelNextFilter:SetText('Filter active: <Reset Filter>')
        self.labelNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
        footerGroup:AddChild(self.labelNextFilter)

        local btn = self.btnReset
        btn:SetText('Reset Filter')
        btn:SetFullWidth(false)
        btn:SetWidth(200)
        btn:SetCallback('OnClick', function() si:ResetFilter() end)
        footerGroup:AddChild(btn)
    end

    local parent = (footerGroup or self.f)
    self.btnSearch:SetText(SEARCH_BUTTON_PREFIX)
    self.btnSearch:SetFullWidth(true)
    self.btnSearch:SetCallback('OnClick', function() si:performQuery() end)
    parent:AddChild(self.btnSearch)
end

-- Call Back Routines and Create Found/Log
function si:eventWhoQueryResults()
    self.tblLog = table.wipe(self.tblLog) or {}
    self.tblFound = self.tblFound or {}

    ns.events:UnregisterEvent('WHO_LIST_UPDATE')
    for i=1,C_FriendList.GetNumWhoResults() do
        local info = C_FriendList.GetWhoInfo(i)
        local pName = gsub(info.fullName, '-'..GetRealmName(), '')
        local rec = {name = pName, class = info.filename, level = info.level, guild = (info.fullGuildName or ''), info.area}

        if not self.isCompact then tinsert(self.tblLog, rec) end
        if rec.guild == '' then
            self.tblFound[pName] = {name = pName, class = info.filename, zone = info.area, level = info.level, checked = false}
        end
    end

    si:CreateResultWindows('BOTH', C_FriendList.GetNumWhoResults())
    ns.Analytics:add('Players_Scanned', C_FriendList.GetNumWhoResults())
end
function si:CreateResultWindows(whichOne, resultCount)
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
            group:AddChild(ns.widgets:createLabel(tbl.level, 25))
            group:AddChild(ns.widgets:createLabel(tbl.guild, 150))

            tbl = table.remove(self.tblLog, 1)
        end
    end
    local function createPlayersFound()
        self.pfScroll:ReleaseChildren()
        local rCount = 0
        for k, r in pairs(self.tblFound or {}) do
            if ns.Invite:canAddPlayer(k, r.zone) then
                rCount = rCount + 1
                local checkBox = aceGUI:Create('CheckBox')
                checkBox:SetLabel(ns.code:cPlayer(k, r.class or nil)..' ('..r.level..')')
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
            else self.tblFound[k] = nil end
        end
        invite.totalFound = rCount

        self.labelFound:SetText(INVITE_PREFIX..rCount)
        self.btnInvite:SetDisabled(rCount == 0)
        self.btnRemove:SetDisabled(true)
    end

    if not whichOne or whichOne == 'BOTH' then
        createPlayersFound()
        if not self.isCompact then createWhoResults()
        else self.labelLog:SetText('Players found: '..(resultCount or 0)) end
    elseif whichOne == 'PLAYERS_FOUND' then createPlayersFound()
    elseif whichOne == 'WHO_RESULTS' then createWhoResults() end
end

-- Perform Query Routines
function si:performQuery(reset)
    local function createQueries()
        local db, dbFilter = ns.db.settings, ns.db.filter
        self.tblFilter = table.wipe(self.tblFilter) or {}
        local min, max = (tonumber(db.minLevel) or 1), (tonumber(db.maxLevel) or MAX_CHARACTER_LEVEL)

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
        local function buildCustomFilter(filterList)
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

        local filterID = (dbFilter and dbFilter.activeFilter) or 1
        if filterID == 1 then createClassFilter()
        elseif filterID == 2 then createRaceFilter()
        elseif filterID > 10 then
            filterID = filterID - 10
            local filter = dbFilter.filterList[filterID] or nil
            if not filter then
                UIErrorsFrame:AddMessage('Filter Missing', 1.0, 0.1, 0.1, 1.0)
                return
            else self.tblFilter = buildCustomFilter(filter) end
        end

        self.totalFilters = #self.tblFilter
        local searchMessage = self.isCompact and SEARCH_BUTTON_PREFIX or SEARCH_BUTTON_PREFIX..' ('..(self.tblFilter[1] or '<none>')..')'
        self.btnSearch:SetText(searchMessage)
        if not self.isCompact then
            self.labelNextFilter:SetText('Current Filter: '..(self.tblFilter[2] or 'Press "Seach for Players" to restart filter.'), self.MAX_LENGTH) end
        if reset ~= 'SKIP_NEXT' and reset ~= 'RESET_FILTER' then si:performQuery() end
    end
    local function nextQuery()
        if reset == 'RESET_FILTER' or not self.tblFilter or #self.tblFilter == 0 then
            createQueries()
            return
        elseif reset == 'SKIP_NEXT' then return end


        local function GetWho(query)
            ns.events:RegisterEvent('WHO_LIST_UPDATE')

            if FriendsFrame:IsShown() then
                FriendsFrame:RegisterEvent("WHO_LIST_UPDATE");
            elseif not ns.db.settings.showWho then
                FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE");
            end

            C_FriendList.SetWhoToUi(true)
            C_FriendList.SendWho(query)
        end

        local filter = table.remove(self.tblFilter, 1)
        local searchMessage = self.isCompact and SEARCH_BUTTON_PREFIX or SEARCH_BUTTON_PREFIX..' ('..(self.tblFilter[1] or '<Reset Filter>')..')'
        local function waitTimer(remain, nextFilter)
            if remain <= 0 then
                self.btnReset:SetDisabled(false)
                self.btnSearch:SetDisabled(false)
                self.btnSearch:SetText(searchMessage)
            else
                self.btnReset:SetDisabled(true)
                self.btnSearch:SetDisabled(true)
                self.btnSearch:SetText(SEARCH_BUTTON_PREFIX..' ('.. remain..')')
                remain = remain - 1
                C_Timer.After(1, function() waitTimer(remain, nextFilter) end)
            end
        end

        self.btnSearch:SetText(searchMessage)
        if not self.isCompact then
            self.labelNextFilter:SetText('Current Filter: '..(filter or 'Press "Seach for Players" to restart filter.'), self.MAX_LENGTH) end

        GetWho(filter)

        local percent = (self.totalFilters - #self.tblFilter) / self.totalFilters
        local statusMsg = self.isCompact and FormatPercentage(percent, 2) or STATUS_TEXT_DEFAULT..' (Filter progress: '..FormatPercentage(percent, 2)..')'
        self.f:SetStatusText(statusMsg)
        waitTimer((ns.db.settings.scanWaitTime or SCAN_WAIT_TIME), (filter or '<Resetting Filter>'))
    end

    nextQuery()
end
si:Init()

function invite:Init()
    self.tblInvited = nil
    self.tblSentInvite = {}

    self.waitWelcome = false
    self.welcomeWaitTime = 5

    self.antiSpam = true
    self.showWhispers = false

    -- Session Counts
    self.totalFound = 0
    self.removedCount = 0
    self.invitedCount = 0
    self.acceptedCount = 0
    self.declinedCount = 0
end
function invite:InitializeInvite()
    self.tblInvited = ns.dbInv.invitedPlayers or {}
    self.antiSpam = ns.db.settings.antiSpam or true
    self.showWhispers = ns.db.settings.showWhispers or false
end
function invite:new(class)
    return {
        ['playerClass'] = class or '',
        ['invitedBy'] = UnitGUID('player'),
        ['invitedOn'] = C_DateAndTime.GetServerTimeLocal(),
    }
end
function invite:canAddPlayer(pName, zone, showError, force)
    local canAddPlayer = nil
    if not force and self.tblInvited[pName] then canAddPlayer = 'INVITED'
    elseif ns.BlackList:IsOnBlackList(pName) then canAddPlayer = 'BLACKLIST'
    elseif zone and ns.datasets.tblBadByName[zone] then canAddPlayer = 'ZONE' end

    if showError then
        if canAddPlayer == 'INVITED' then ns.code:consoleOut(pName..' has been invited recently.')
        elseif canAddPlayer == 'BLACKLIST' then ns.code:consoleOut(pName..' has been black listed, remove before inviting.')
        elseif canAddPlayer == 'ZONE' then ns.code:consoleOut(pName..' is in an instanced zone.') end
    end

    return not (canAddPlayer or false)
end
function invite:recordInvite(pName, class)
    ns.Analytics:add('Invited_Players')
    if not pName or not class then return
    elseif self.antiSpam then
        pName = gsub(pName, '-'..GetRealmName(), '')
        self.tblInvited[pName] = invite:new(class)
        self.tblSentInvite[pName] = self.tblInvited[pName]
        ns.dbInv.invitedPlayers = self.tblInvited
    end
end
function invite:invitePlayer(pName, msg, sendInvite, force, class)
    local function MyWhisperFilter(_,_, message)
        if msg == message then return not ns.Invite.showWhispers
        else return false end -- Returning true will hide the message
    end

    class = class and class or select(2, UnitClass(pName))
    if pName and CanGuildInvite() and not GetGuildInfo(pName) then
        if sendInvite then GuildInvite(pName) end
        if msg and ns.db.settings.inviteFormat ~= 2 then
            if not self.showWhispers then
                local msgOut = sendInvite and 'Sent invite and message to ' or 'Sent invite message to '
                ns.code:consoleOut(msgOut..(ns.code:cPlayer(pName, class) or pName))
                ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", MyWhisperFilter, msg)
            end
            SendChatMessage(msg, 'WHISPER', nil, pName)
        end
        invite:recordInvite(pName, class)
    end
end
function invite:ScannerInvitePlayer()
    local db, dbMsg, msgList = ns.db.settings, ns.db.messages, ns.datasets.tblGMMessages or {}
    local inviteFormat = db.inviteFormat

    local sendInvite = inviteFormat ~= 1 or false

    local key = next(si.tblFound or {})
    local tbl = si.tblFound[key]
    if not tbl or tbl.checked then return end

    local msg = (inviteFormat ~= 2 and dbMsg.activeMessage) and ns.code:GuildReplace(msgList[dbMsg.activeMessage].message, si.tblFound[key].name) or nil

    si.tblFound[key] = nil
    self.invitedCount = self.invitedCount + 1
    si.labelFound:SetText(INVITE_PREFIX..self.totalFound - self.invitedCount)
    ns.Invite:invitePlayer(key, msg, sendInvite, false, tbl.class)
    si:CreateResultWindows('PLAYERS_FOUND')

    si.btnSearch:SetDisabled(true)
    C_Timer.After(2, function() si.btnSearch:SetDisabled(false) end)
end

-- Event Call Back Routines
function invite:ChatMsgHandler(...)
    local _, msg =  ...
    if not msg then return end

    local function eraseRecord(pName)
        if not pName or not self.tblSentInvite[pName] then return
        else self.tblSentInvite[pName] = nil end
    end

    local pName = msg:match('(.-) ')
    pName = gsub(pName, '-'..GetRealmName(), '')

    if msg:match('not found') then
        self.invitedCount = self.invitedCount - 1
        ns.Analytics:add('Invited_Players', -1)
        eraseRecord(pName)
    elseif not strmatch(msg, 'guild') then return
    elseif strmatch(msg, 'joined the guild') and self.tblSentInvite and self.tblSentInvite[pName] then
        ns.Analytics:add('Accepted_Invite')
        self.acceptedCount = self.acceptedCount + 1
        local sendGreeting = (not ns.dbGlobal.greeting and ns.db.settings.sendGreeting) and ns.db.settings.greetingMsg or ns.dbGlobal.greeting
        local greetingMessage = ns.dbGlobal.greeting and ns.dbGlobal.greetingMsg or ns.db.settings.greetingMsg
        if not self.waitWelcome and sendGreeting and greetingMessage ~= '' then
            self.waitWelcome = true
            C_Timer.After(ns.db.settings.sendGreetWait or 2, function()
                ns.Invite.waitWelcome = false
                SendChatMessage(greetingMessage, 'WHISPER', nil, pName)
            end)
        end
        if ns.db.settings.sendWelcome and ns.db.settings.welcomeMessage ~= '' then
            local welcomeMsg = ns.code:GuildReplace(ns.db.settings.welcomeMessage, pName)
            welcomeMsg = welcomeMsg and welcomeMsg:gsub('<', ''):gsub('>', '') or ''
            C_Timer.After(math.random(3,8), function() SendChatMessage(welcomeMsg, 'GUILD') end)
        end
        eraseRecord(pName)
    elseif strmatch(msg, 'declines your guild') then
        self.declinedCount = self.declinedCount + 1
        ns.Analytics:add('Declined_Invite')
        eraseRecord(pName)
    end
end
function invite:GuildRosterHandler(...)
    local _, rosterUpdate = ...

    local function ProcessGuildInvite()
        self.waitWelcome = false

        local c = 0
        for _ in pairs(ns.Invite.tblSentInvite) do c = c + 1 end

        if c > 0 then
            C_GuildInfo.GuildRoster()

            local sendWelcome = false
            for index=1,GetNumGuildMembers() do
                local name = gsub(GetGuildRosterInfo(index), '-'..GetRealmName(), '')
                if self.tblSentInvite[name] then
                    sendWelcome = true

                    self.tblSentInvite[name] = nil
                    ns.Analytics:add('Accepted_Invite')
                end
            end

            if sendWelcome and ns.db.settings.sendGreeting and ns.db.settings.greetingMsg then
                SendChatMessage(ns.db.settings.greetingMsg, 'GUILD') end
        end
    end

    if rosterUpdate and not self.waitWelcome then
        self.waitWelcome = true
        C_Timer.After(self.welcomeWaitTime or 5, function() ProcessGuildInvite() end)
    end
end
invite:Init()