local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.scanner = {}
local scanner = ns.scanner

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    ns.base:SwitchToCompactMode(true, true)
    ns.frames:ResetFrame(scanner.tblFrame.frame)
    scanner.tblFrame.frame = nil
end

local function CallBackWhoListUpdate()
    GR:UnregisterEvent('WHO_LIST_UPDATE', CallBackWhoListUpdate)

    ns.analytics:Reception('scanned', C_FriendList.GetNumWhoResults())
    scanner:ProcessWhoResults(C_FriendList.GetNumWhoResults())
end

local function updateFilterProgress(skipInc)
    -- Progress in filter
    if not skipInc then scanner.filterCount = scanner.filterCount + 1 end
    ns.status:SetText(L['FILTER_PROGRESS']..': '..FormatPercentage(scanner.filterCount/scanner.filterTotal, 2))
end

function scanner:Init()
    self.isCompact = false
    self.compactMode = ns.g.compactSize or 1

    self.baseX, self.baseY = 600, 475
    self.adjustedY = self.baseY - (ns.base.tblFrame.icon:GetHeight() + ns.status.frame:GetHeight() + 5)

    self.inviteFormat = ns.pSettings.inviteFormat or ns.InviteFormat.GUILD_INVITE_ONLY

    self.scanReset = ns.g.scanWaitTime -- Otherwise doesn't work
    self.tblFrame = {}
    self.tblFilter = self.tblFilter or nil
    self.filterCount = self.filterCount or 0
    self.filterTotal = self.filterTotal or 0

    self.tblWho = self.tblWho or {}
    self.tblToInivite = self.tblToInivite or {}

    self.minLevel, self.maxLevel = (ns.pSettings.minLevel or ns.MAX_CHARACTER_LEVEL - 5), ns.pSettings.maxLevel or ns.MAX_CHARACTER_LEVEL
    self.minLevel = type(self.minLevel) == 'string' and tonumber(self.minLevel) or self.minLevel
    self.maxLevel = type(self.maxLevel) == 'string' and tonumber(self.maxLevel) or self.maxLevel
end
function scanner:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function scanner:SetShown(val)
    if val and scanner:IsShown() then return
    elseif not val and not self:IsShown() then return
    elseif not val then self.tblFrame.frame:SetShown(false) end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    self:Init()
    self:CreateScannerBaseFrame()
    self:CreateInviteFrame()
    self:CreateWhoFrame()
    self:StartScanFrame()
    self:CreateAnalyticsFrame()

    local baseFrame = ns.base.tblFrame
    baseFrame.back:SetShown(true)
    baseFrame.reset:SetShown(true)
    baseFrame.compact:SetShown(true)
    self:CompactModeChanged(true)
    -- Size adjustment in compact routine

    if not self.tblFilter then self:BuildFilters() end

    ns.invite:Init()
    self:UpdateButtons()
    self:DisplayWhoList()
    self:DisplayInviteList()

    self.tblFrame.frame:SetShown(val)

    self:SetText(self.tblFrame.scannerFrame.nextFilterText, self:DisplayNextFilter())
    if self.filterTotal > 0 and self.filterCount > 0 then updateFilterProgress(true) end
end
function scanner:CreateScannerBaseFrame()
    local baseFrame = ns.base.tblFrame
    local f = ns.frames:CreateFrame('Frame', 'Scanner_BaseFrame', baseFrame.frame)
    f:SetPoint("TOPLEFT", baseFrame.icon, "BOTTOMLEFT", 5, -5)
    f:SetSize(self.baseX - 10, self.adjustedY)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f:EnableMouse(false)
    self.tblFrame.frame = f
end
function scanner:CreateInviteFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_InviteFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.frame, "TOPLEFT", 0, 0)
    f:SetSize(self.tblFrame.frame:GetWidth()*0.35, self.adjustedY*0.7)
    self.tblFrame.inviteFrame = f

    local InviteText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    InviteText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 5)
    InviteText:SetText("Players Found:")
    InviteText:SetTextColor(1, 1, 1, 1)

    local scrollFrame = ns.frames:CreateFrame('ScrollFrame', 'Invite_ScrollFrame', f, 'UIPanelScrollFrameTemplate')
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 75)
    self.tblFrame.inviteScroll = scrollFrame

    local bgTexture = scrollFrame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetAllPoints()  -- Make sure it covers the entire scroll frame
    bgTexture:SetColorTexture(0, 0, 0, 0.5)

    local scrollBar = scrollFrame.ScrollBar
    scrollBar:SetWidth(12)  -- Set the scrollbar width to be narrower (default is around 16-18)

    -- Adjust the position of the scrollbar to fit its new width
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -16)
    scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 16)

    local buttonInvite = ns.frames:CreateFrame('Button', 'InviteButton', f, 'UIPanelButtonTemplate')
    buttonInvite:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 0, -3)
    buttonInvite:SetText(self.inviteFormat == ns.InviteFormat.MESSAGE_ONLY and 'Send Message' or (self.inviteFormat == ns.InviteFormat.GUILD_INVITE_AND_MESSAGE and 'Send Invite and Message' or 'Send Invite'))
    buttonInvite:SetSize(f:GetWidth() - 20, 30)
    buttonInvite:SetScript("OnClick", function(self, button, down) scanner:InvitePlayer() end)
    buttonInvite:SetScript("OnEnter", function(self) ns.code:createTooltip('Invite Player', 'Do not check boxes to send invites.') end)
    buttonInvite:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.tblFrame.buttonInvite = buttonInvite

    local buttonBlacklist = ns.frames:CreateFrame('Button', 'BlacklistButton', f, 'UIPanelButtonTemplate')
    buttonBlacklist:SetPoint("TOPLEFT", buttonInvite, "BOTTOMLEFT", 0, 0)
    buttonBlacklist:SetText('Blacklist')
    buttonBlacklist:SetSize((buttonInvite:GetWidth() /2) - 3, 30)
    buttonBlacklist:SetScript("OnClick", function(self, button, down) scanner:BlacklistPlayer() end)
    buttonBlacklist:SetScript("OnEnter", function(self) ns.code:createTooltip('Add Selected Player(s) to Blacklist', 'Will add selected players to Blacklist.') end)
    buttonBlacklist:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.tblFrame.buttonBlacklist = buttonBlacklist

    local buttonSkip = ns.frames:CreateFrame('Button', 'SkipButton', f, 'UIPanelButtonTemplate')
    buttonSkip:SetPoint("LEFT", buttonBlacklist, "RIGHT", 5, 0)
    buttonSkip:SetText('Skip Player')
    buttonSkip:SetSize((buttonInvite:GetWidth() /2) - 3, 30)
    buttonSkip:SetScript("OnClick", function(self, button, down) scanner:AntiSpam() end)
    buttonSkip:SetScript("OnEnter", function(self) ns.code:createTooltip('Add Selected Player(s) to Anti-Spam List', 'Will add selected players to Anti-Spam list.') end)
    buttonSkip:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.tblFrame.buttonSkip = buttonSkip
end
function scanner:CreateWhoFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_WhoFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "TOPRIGHT", 5, 0)
    f:SetSize(self.tblFrame.frame:GetWidth() - (self.tblFrame.inviteFrame:GetWidth() + 5), self.tblFrame.inviteFrame:GetHeight())
    self.tblFrame.whoFrame = f

    local whoText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whoText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 5)
    whoText:SetText("Who Results:")
    whoText:SetTextColor(1, 1, 1, 1)
    self.tblFrame.whoText = whoText

    local scrollFrame = CreateFrame('ScrollFrame', 'Who_ScrollFrame', f, 'UIPanelScrollFrameTemplate')
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
    self.tblFrame.whoScroll = scrollFrame

    local bgTexture = scrollFrame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetAllPoints()  -- Make sure it covers the entire scroll frame
    bgTexture:SetColorTexture(0, 0, 0, 0.5)

    local scrollBar = scrollFrame.ScrollBar
    scrollBar:SetWidth(12)  -- Set the scrollbar width to be narrower (default is around 16-18)

    -- Adjust the position of the scrollbar to fit its new width
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -16)
    scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 16)
end
local defaultButtonText = 'Search for Players'
function scanner:StartScanFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_ScanFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "BOTTOMLEFT", 0, 0)
    f:SetSize(self.tblFrame.inviteFrame:GetWidth(), self.adjustedY*0.3)
    self.tblFrame.scannerFrame = {}
    self.tblFrame.scannerFrame.frame = f

    local ScanText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ScanText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 5)
    ScanText:SetText("Scan for Players:")
    ScanText:SetTextColor(1, 1, 1, 1)

    local nextFilterLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nextFilterLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
    nextFilterLabel:SetFont(ns.DEFAULT_FONT, 10, "OUTLINE")
    nextFilterLabel:SetText("Next Query: None")
    nextFilterLabel:SetTextColor(1, 1, 1, 1)
    self.tblFrame.scannerFrame.nextFilterText = nextFilterLabel

    local buttonScan = ns.frames:CreateFrame('Button', 'ScanButton', f, 'UIPanelButtonTemplate')
    buttonScan:SetPoint("TOPLEFT", nextFilterLabel, "BOTTOMLEFT", 0, -5)
    buttonScan:SetText(defaultButtonText)
    buttonScan:SetSize(f:GetWidth() - 20, 30)
    buttonScan:SetScript("OnClick", function(self, button, down)
        if buttonScan:IsEnabled() then scanner:PerformSearch() end
    end)
    self.tblFrame.scannerFrame.buttonScan = buttonScan

    local playerCountText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerCountText:SetPoint("TOPLEFT", buttonScan, "BOTTOMLEFT", 0, 0)
    playerCountText:SetPoint("TOPRIGHT", buttonScan, "BOTTOMRIGHT", 0, 0)
    playerCountText:SetHeight(20)
    playerCountText:SetText("Players Queued: 0")
    playerCountText:SetTextColor(1, 1, 1, 1)
    self.tblFrame.scannerFrame.playerCountText = playerCountText
end
function scanner:CreateAnalyticsFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_AnalFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.whoFrame, "BOTTOMLEFT", 0, 0)
    f:SetSize(self.tblFrame.whoFrame:GetWidth(), self.adjustedY*0.3)
    self.tblFrame.analytics = f

    local analText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    analText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 5)
    analText:SetText("Session Analytics:")
    analText:SetTextColor(1, 1, 1, 1)
end

--* Who Functions
function scanner:ProcessWhoResults()
    self.tblWho = table.wipe(self.tblWho) or {}

    -- Analytics in event function
    for i=1, C_FriendList.GetNumWhoResults() do
        local info = C_FriendList.GetWhoInfo(i)
        local pName = strmatch(info.fullName, GetRealmName()) and info.fullName:gsub('-.*', '') or info.fullName
        local rec = {
            fullName = info.fullName,
            name = ns.code:cPlayer(info.fullName, info.filename),
            pName = pName,
            classStr = info.classStr,
            raceStr = info.raceStr,
            gender = info.gender,
            class = info.filename,
            level = info.level,
            guild = info.fullGuildName or '',
            zone = info.area,
            failed = '',
            isChecked = false,
        }
        tinsert(self.tblWho, rec)
    end
    self.tblFrame.whoText:SetText('Who Results: '..#self.tblWho..' Players Found')

    if self.tblWho then
        self.tblWho = ns.code:sortTableByField(self.tblWho, 'fullName') end

    self:UpdateButtons()
    self:DisplayWhoList()
end
function scanner:DisplayWhoList()
    local tblWho = self.tblWho
    local rowHeight = 20
    local scrollFrame = self.tblFrame.whoScroll

    ns.frames:ResetFrame(self.tblFrame.whoContent)

    local content = ns.frames:CreateFrame('Frame', 'Who_Entry_Content', scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 20, 1)
    self.tblFrame.whoContent = content

    local function createWhoEntry(parent, r)
        local row = ns.frames:CreateFrame('Frame', nil, parent)
        row:SetSize(parent:GetWidth(), rowHeight)

        local rowTexture = row:CreateTexture(nil, "BACKGROUND")
        rowTexture:SetAtlas(ns.BLUE_LONG_HIGHLIGHT)
        rowTexture:SetAllPoints(row)
        rowTexture:SetBlendMode("ADD")
        rowTexture:Hide()

        local txtLevel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtLevel:SetPoint('LEFT', 10, 0)
        txtLevel:SetWidth(20)
        txtLevel:SetTextColor(1, 1, 1, 1)
        txtLevel:SetJustifyH("LEFT")
        txtLevel:SetText(r.guild == '' and ns.code:cText('FF00FF00', r.level) or r.level)

        local txtName = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtName:SetPoint("LEFT", txtLevel, "RIGHT", 10, 0)
        txtName:SetWidth(100)
        txtName:SetJustifyH("LEFT")
        txtName:SetWordWrap(false)
        txtName:SetText(r.name)

        local txtGuild = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtGuild:SetPoint("LEFT", txtName, "RIGHT", 10, 0)
        txtGuild:SetWidth(150)
        txtGuild:SetTextColor(1, 1, 1, 1)
        txtGuild:SetJustifyH("LEFT")
        txtGuild:SetWordWrap(false)
        txtGuild:SetText(r.guild == '' and r.failed or r.guild)

        row:SetScript("OnEnter", function(self)
            rowTexture:Show()
            local guild = r.guild == '' and '-  No Guild -' or r.guild
            local title = r.level..' '..r.name..' ('..r.raceStr..': '..(r.gender == 2 and 'Male' or 'Female')..')'
            local body = r.failed ~= '' and 'Failed: '..r.failed..'\n' or ''
            body = body..'Guild: '..guild..'\n \nLocation: '..(r.zone or 'Unknown')
            ns.code:createTooltip(title, body, true)
        end)
        row:SetScript("OnLeave", function(self)
            rowTexture:Hide()
            GameTooltip:Hide()
        end)

        return row
    end

    local function findPlayer(name)
        for _, v in ipairs(self.tblToInivite) do
            if v.fullName == name then return true end
        end

        return false
    end

    for i, result in ipairs(tblWho) do
        local inviteOk, reason = ns.invite:CheckWhoList(result.fullName, result.area)
        if inviteOk and not findPlayer(result.fullName) and result.guild == '' then
            tinsert(self.tblToInivite, result)
        elseif not inviteOk then
            result.level = ns.code:cText('FFFF0000', result.level)
            result.failed = ns.code:cText('FFFF0000', reason)
        end

        local row = createWhoEntry(content, result)
        if row then
            row:SetPoint("TOPLEFT", 0, -(i - 1) * rowHeight) end
    end
    content:SetHeight(#tblWho * rowHeight)
    scrollFrame:SetScrollChild(content)

    scrollFrame:SetVerticalScroll(0)
    scrollFrame:UpdateScrollChildRect()

    if self.tblToInivite then
        self.tblToInivite = ns.code:sortTableByField(self.tblToInivite, 'fullName') end

    self:DisplayInviteList()
end
function scanner:DisplayInviteList()
    local rowHeight = 20
    local sFrame = self.tblFrame.scannerFrame
    local scrollFrame = self.tblFrame.inviteScroll

    ns.frames:ResetFrame(self.tblFrame.inviteContent)

    local content = ns.frames:CreateFrame('Frame', 'Invite_Entry_Content', scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 20, 1)
    self.tblFrame.inviteContent = content

    local function createInviteEntry(parent, r)
        local row = ns.frames:CreateFrame('Frame', nil, parent)
        row:SetSize(parent:GetWidth(), rowHeight)

        local rowTexture = row:CreateTexture(nil, "BACKGROUND")
        rowTexture:SetAtlas(ns.BLUE_LONG_HIGHLIGHT)
        rowTexture:SetAllPoints(row)
        rowTexture:SetBlendMode("ADD")
        rowTexture:Hide()

        local checkBox = CreateFrame('CheckButton', nil, row, 'UICheckButtonTemplate')
        checkBox:SetPoint('LEFT', 5, 0)
        checkBox:SetSize(20, 20)
        checkBox:SetChecked(r.isChecked)
        checkBox:SetScript("OnClick", function(self)
            r.isChecked = self:GetChecked()
            scanner:UpdateButtons()
        end)

        local txtLevel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtLevel:SetPoint("LEFT", checkBox, "RIGHT", 10, 0)
        txtLevel:SetWidth(20)
        txtLevel:SetTextColor(1, 1, 1, 1)
        txtLevel:SetJustifyH("LEFT")
        txtLevel:SetText(r.guild == '' and ns.code:cText('FF00FF00', r.level) or r.level)

        local txtName = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtName:SetPoint("LEFT", txtLevel, "RIGHT", 10, 0)
        txtName:SetWidth(100)
        txtName:SetJustifyH("LEFT")
        txtName:SetWordWrap(false)
        txtName:SetText(r.name)

        row:SetScript("OnEnter", function(self)
            rowTexture:Show()
            local guild = r.guild == '' and '-  No Guild -' or r.guild
            local title = r.level..' '..r.name..' ('..r.raceStr..': '..(r.gender == 2 and 'Male' or 'Female')..')'
            local body = r.failed ~= '' and 'Failed: '..r.failed..'\n' or ''
            body = body..'Guild: '..guild..'\n \nLocation: '..(r.zone or 'Unknown')
            ns.code:createTooltip(title, body, true)
        end)
        row:SetScript("OnLeave", function(self)
            rowTexture:Hide()
            GameTooltip:Hide()
        end)

        return row
    end

    local rowCount = 0
    for _, result in pairs(self.tblToInivite) do
        local row = createInviteEntry(content, result)
        if row then
            rowCount = rowCount + 1
            row:SetPoint("TOPLEFT", 0, -(rowCount - 1) * rowHeight)
        end
    end
    self.tblFrame.scannerFrame.playerCountText:SetText('Players Queued: '..#self.tblToInivite)
    if sFrame.nextText then
        sFrame.nextText:SetText('Next Player to Invite (Queued: '..#self.tblToInivite..'):')
        if #self.tblToInivite > 0 then sFrame.nextPlayerText:SetText(self.tblToInivite[1].name)
        else sFrame.nextPlayerText:SetText('No players in queue.') end
    end

    content:SetHeight(#self.tblToInivite * rowHeight)
    scrollFrame:SetScrollChild(content)

    scrollFrame:SetVerticalScroll(0)
    scrollFrame:UpdateScrollChildRect()
end

--* Scanner Functions
function scanner:SetText(ctrl, text) ns.frames:animateText(ctrl, text) end
function scanner:CompactModeChanged(startCompact, closed)
    if startCompact then
        self.isCompact = ns.pSettings.isCompact or false
        ns.base:SwitchToCompactMode((closed or false), self.isCompact)
        return
    end

    self.compactMode = ns.pSettings.isCompact or false

    local f = self.tblFrame.scannerFrame.frame
    local sFrame = self.tblFrame.scannerFrame
    local compactSize = ns.g.compactSize or 1

    if self.compactMode then
        self.tblFrame.whoFrame:SetShown(false)
        self.tblFrame.analytics:SetShown(false)
    else
        self.tblFrame.whoFrame:SetShown(true)
        self.tblFrame.analytics:SetShown(true)
        self.tblFrame.inviteFrame:SetShown(true)

        ns.frames:FixScrollBar(self.tblFrame.whoScroll)
        ns.frames:FixScrollBar(self.tblFrame.inviteScroll)

        f:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "BOTTOMLEFT", 0, 0)
        f:SetSize(self.tblFrame.inviteFrame:GetWidth(), self.adjustedY*0.3)
        sFrame.frame:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "BOTTOMLEFT", 0, 0)

        sFrame.nextFilterText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
        sFrame.playerCountText:SetShown(true)

        if sFrame.nextText and sFrame.nextPlayerText then
            sFrame.nextText:SetShown(false)
            sFrame.nextPlayerText:SetShown(false)
            sFrame.buttonInvite:SetShown(false)
            sFrame.buttonSkip:SetShown(false)
        end

        return
    end

    if self.compactMode and compactSize == 1 then
    elseif self.compactMode and compactSize == 2 then
        self.tblFrame.inviteFrame:SetShown(false)
        sFrame.frame:SetPoint("TOPLEFT", ns.base.tblFrame.icon, "BOTTOMLEFT", 5, -5)
        sFrame.frame:SetHeight(sFrame.frame:GetHeight() + 10)

        sFrame.nextFilterText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -15)
        sFrame.playerCountText:SetShown(false)

        local txtNext = sFrame.nextText or sFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtNext:SetFont(ns.DEFAULT_FONT, 10, "OUTLINE")
        txtNext:SetPoint("TOPLEFT", sFrame.buttonScan, "BOTTOMLEFT", -2, -5)
        txtNext:SetText("Next Player to Invite (Queued: 0):")
        txtNext:SetTextColor(1, 1, 1, 1)
        sFrame.nextText = txtNext
        sFrame.nextText:SetShown(true)

        local txtNextPlayer = sFrame.nextPlayerText or sFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtNextPlayer:SetPoint("TOPLEFT", txtNext, "BOTTOMLEFT", 2, -5)
        txtNextPlayer:SetText("No players in queue.")
        txtNextPlayer:SetTextColor(1, 1, 1, 1)
        sFrame.nextPlayerText = txtNextPlayer
        sFrame.nextPlayerText:SetShown(true)

        local buttonInvite = sFrame.buttonInvite or ns.frames:CreateFrame('Button', 'InviteButton', sFrame.frame, 'UIPanelButtonTemplate')
        buttonInvite:SetPoint("BOTTOMLEFT", sFrame.frame, "BOTTOMLEFT", 5, 5)
        buttonInvite:SetSize((sFrame.frame:GetWidth() /2) - 5, 20)
        buttonInvite:SetText('Invite')
        buttonInvite:SetShown(true)
        buttonInvite:SetScript("OnClick", function(self, button, down) scanner:InvitePlayer() end)
        buttonInvite:SetScript("OnEnter", function(self)
            local nextPlayer = txtNextPlayer:GetText():match('No players in queue.') and 'Next Found Player.' or txtNextPlayer:GetText()
            ns.code:createTooltip('Invite '..nextPlayer, 'Invite this player to the guild.') end)
        buttonInvite:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
        sFrame.buttonInvite = buttonInvite

        local buttonSkip = sFrame.buttonSkip or ns.frames:CreateFrame('Button', 'InviteButton', sFrame.frame, 'UIPanelButtonTemplate')
        buttonSkip:SetPoint("LEFT", buttonInvite, "RIGHT", 3, 0)
        buttonSkip:SetSize((sFrame.frame:GetWidth() /2) - 15, 20)
        buttonSkip:SetText('Skip')
        buttonSkip:SetShown(true)
        buttonSkip:SetScript("OnClick", function(self, button, down) scanner:AntiSpam() end)
        buttonSkip:SetScript("OnEnter", function(self) ns.code:createTooltip('Add Player to Anti-Spam', 'Will add the queued player to Anti-Spam list.') end)
        buttonSkip:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
        sFrame.buttonSkip = buttonSkip

        self:DisplayInviteList()
    end
end
function scanner:BuildFilters()
    local filter = ns.pSettings.filterList or {}
    local filterID = ns.pSettings.activeFilter or 9999
    self.tblFilter = {}

    local min, max = self.minLevel, self.maxLevel
    local function createQuery(desc, criteria)
        local fRec = {
            ['desc'] = desc..' ('..min..'-'..max..')',
            ['cmdWho'] = criteria..' '..min..'-'..max,
        }
        return fRec
    end

    local tblSorted, prefix = nil, nil
    if filterID == 9998 then
        prefix = 'r-'
        tblSorted = ns.code:sortTableByField(ns.races, 'name')
    elseif filterID == 9999 then
        prefix = 'c-'
        tblSorted = ns.code:sortTableByField(ns.classes, 'name') end

    for _, v in pairs(tblSorted) do
        local lMin, lMax = min, max
        while lMin <= lMax do
            local query = prefix..v.name
            local rangeEnd = lMin + 5 > lMax and lMax or lMin + 5
            table.insert(self.tblFilter, createQuery(v.name, query, lMin, rangeEnd))

            lMin = (rangeEnd < lMax and (rangeEnd - lMin > 0)) and rangeEnd or lMax + 1
            if lMax - lMin > 0 then lMin = lMin + 1 end
        end
    end

    self.filterCount, self.filterTotal = 0, #self.tblFilter or 0
    self:SetText(self.tblFrame.scannerFrame.nextFilterText, self:DisplayNextFilter())
end
function scanner:DisplayNextFilter() return 'Next Query: '..self.tblFilter[1].desc end
function scanner:PerformSearch()
    local sFrame = self.tblFrame.scannerFrame
    local tblNext = tremove(self.tblFilter, 1)
    if not tblNext then
        scanner:buildFilters()
        if #self.tblFilter > 0 then scanner:PerformSearch() end
        sFrame.buttonScan:SetText(defaultButtonText)
        return
    end

    updateFilterProgress()

    FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
    GR:RegisterEvent('WHO_LIST_UPDATE', CallBackWhoListUpdate)

    C_FriendList.SetWhoToUi(true)
    C_FriendList.SendWho(tblNext.cmdWho)

    if #self.tblFilter == 0 then scanner:BuildFilters() end
    self:SetText(sFrame.nextFilterText, self:DisplayNextFilter())
    sFrame.buttonScan:SetText('Next Query')

    self:SetText(sFrame.nextFilterText, self:DisplayNextFilter())
    local function waitTimer(remain)
        remain = type(remain) == 'string' and tonumber(remain) or remain
        if not sFrame.buttonScan then return
        elseif remain > 0 then
            self.waitTimer = remain
            sFrame.buttonScan:Disable()
            sFrame.buttonScan:SetText('Wait '..remain..'s')
            C_Timer.After(1, function() waitTimer(remain - 1) end)
        else
            self.waitTimer = 0
            sFrame.buttonScan:Enable()
            sFrame.buttonScan:SetText(defaultButtonText)
            return
        end
    end
    waitTimer(self.scanReset or 6)
end
function scanner:UpdateButtons()
    local tblInvite = self.tblToInivite
    local sFrame = self.tblFrame

    local checked = false
    for _, v in pairs(tblInvite) do
        if v.isChecked then checked = true break end
    end

    if checked then
        sFrame.buttonInvite:Disable()
        sFrame.buttonBlacklist:Enable()
        sFrame.buttonSkip:Enable()
    else
        sFrame.buttonInvite:Enable()
        sFrame.buttonBlacklist:Disable()
        sFrame.buttonSkip:Disable()
    end
end

--* Invite Functions
function scanner:InvitePlayer()
    if not scanner.tblToInivite then return
    elseif #scanner.tblToInivite == 0 then
        ns.code:fOut('You must first click on Search for Players button.') return
    end

    local tbl = tremove(scanner.tblToInivite, 1)
    if not tbl then return end

    ns.invite:AutoInvite(tbl.fullName, tbl.pName, self.inviteFormat)
    scanner:DisplayInviteList()
end
function scanner:AntiSpam()
    if not self.tblToInivite then return end

    local count = 0
    for k, v in pairs(self.tblToInivite) do
        if v.isChecked and not ns.list:CheckAntiSpam(v.fullName) then
            ns.list:AddToAntiSpam(v.fullName)
            self.tblToInivite[k] = nil
            count = count + 1
        end
    end
    ns.code:fOut(string.format('Added %d players to Anti-Spam list.', count))

    self:DisplayWhoList() -- Displays invite inside of function
end
function scanner:BlacklistPlayer()
    if not self.tblToInivite then return end

    local count = 0
    for k, v in pairs(self.tblToInivite) do
        if v.isChecked and not ns.list:CheckBlacklist(v.fullName) then
            ns.list:AddToBlackList(v.fullName, 'Blacklisted during invite process.')
            self.tblToInivite[k] = nil
            count = count + 1
        end
    end
    ns.code:fOut(string.format('Added %d players to Blacklist.', count))

    self:DisplayWhoList() -- Displays invite inside of function
end