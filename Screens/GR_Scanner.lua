local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.scanner = {}
local scanner = ns.scanner

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)

    local baseFrame = ns.base.tblFrame
    baseFrame.back:SetShown(false)
    baseFrame.reset:SetShown(false)
    baseFrame.compact:SetShown(false)

    ns.base:SwitchToCompactMode(true, true)
    ns.frames:ResetFrame(scanner.tblFrame.frame)
    scanner.tblFrame.frame = nil
end

local function CallBackWhoListUpdate()
    GR:UnregisterEvent('WHO_LIST_UPDATE', CallBackWhoListUpdate)

    ns.analytics:UpdateData('TOTAL_SCANNED', C_FriendList.GetNumWhoResults())
    ns.analytics:UpdateSessionData('SESSION_TOTAL_SCANNED', C_FriendList.GetNumWhoResults())
    scanner:ProcessWhoResults()
end

local function updateFilterProgress(skipInc)
    -- Progress in filter
    if not skipInc then scanner.filterCount = scanner.filterCount + 1 end
    ns.status:SetText(L['FILTER_PROGRESS']..': '..FormatPercentage(scanner.filterCount/scanner.filterTotal, true))
end

function scanner:Init()
    self.isCompact = false
    self.compactMode = ns.g.compactSize or 1

    ns.invite:GetMessages()

    self.baseX, self.baseY = 600, 475
    self.adjustedY = self.baseY - (ns.base.tblFrame.icon:GetHeight() + ns.status.frame:GetHeight() + 5)

    self.inviteFormat = ns.pSettings.inviteFormat or ns.InviteFormat.GUILD_INVITE_ONLY

    self.scanReset = ns.g.scanWaitTime -- Otherwise doesn't work
    self.tblFrame = {}
    self.tblFilter = self.tblFilter or nil
    self.filterCount = self.filterCount or 0
    self.filterTotal = self.filterTotal or 0

    self.tblWho = self.tblWho or {}
    self.tblToInvite = self.tblToInvite or {}
    self.tblToInviteSorted = {}

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

    self:UpdateButtons()
    self:DisplayWhoList()

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
    f:SetScript("OnKeyDown", function(self, key)
        local function ParseKeybinding(binding)
            local modifiers = {}
            local key = nil
        
            -- Split binding by "-" to separate modifiers from the key
            for part in string.gmatch(binding, "[^-]+") do
                if part == "CTRL" or part == "SHIFT" or part == "ALT" then
                    table.insert(modifiers, part)
                else
                    key = part  -- Assume last part is the actual key
                end
            end
            return modifiers, key
        end
        
        local function CheckKeybinding(binding, key)
            local modifiers, bindKey = ParseKeybinding(binding)
        
            -- Check current modifier states
            local ctrlDown = IsControlKeyDown()
            local shiftDown = IsShiftKeyDown()
            local altDown = IsAltKeyDown()
        
            -- Flags to check if the binding requires modifiers
            local ctrlNeeded, shiftNeeded, altNeeded = false, false, false
        
            for _, mod in ipairs(modifiers) do
                if mod == "CTRL" then ctrlNeeded = true end
                if mod == "SHIFT" then shiftNeeded = true end
                if mod == "ALT" then altNeeded = true end
            end
        
            -- Ensure key and modifiers match
            return key == bindKey and
                (ctrlNeeded == ctrlDown) and
                (shiftNeeded == shiftDown) and
                (altNeeded == altDown)
        end

        if ns.g.keybindings.scan and CheckKeybinding(ns.g.keybindings.scan, key) then
            if self.waitTimer and self.waitTimer > 0 then
                ns.code:fOut(L['PLEASE_WAIT']..' '..self.waitTimer..' '..L['ERROR_SCAN_WAIT'])
            else scanner:PerformSearch() end
            return
        -- Check for Invite Keybind (e.g., "CTRL-SHIFT-I")
        elseif ns.g.keybindings.invite and CheckKeybinding(ns.g.keybindings.invite, key) then
            scanner:InvitePlayer()
            return
        end

        self:SetPropagateKeyboardInput(true)
    end)
    self.tblFrame.frame = f
end
function scanner:CreateInviteFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_InviteFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.frame, "TOPLEFT", 0, 0)
    f:SetSize(self.tblFrame.frame:GetWidth()*0.35, self.adjustedY*0.7)
    self.tblFrame.inviteFrame = f

    local InviteText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    InviteText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 3)
    InviteText:SetText(L['PLAYERS_FOUND']..':')
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
    buttonInvite:SetText(self.inviteFormat == ns.InviteFormat.MESSAGE_ONLY and L['SEND_MESSAGE'] or (self.inviteFormat == ns.InviteFormat.GUILD_INVITE_AND_MESSAGE and L['SEND_INVITE_AND_MESSAGE'] or L['SEND_INVITE']))
    buttonInvite:SetSize(f:GetWidth() - 20, 30)
    buttonInvite:SetScript("OnClick", function(self, button, down) scanner:InvitePlayer() end)
    buttonInvite:SetScript("OnEnter", function(self) ns.code:createTooltip('Invite Player', 'Do not check boxes to send invites.') end)
    buttonInvite:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.tblFrame.buttonInvite = buttonInvite

    local buttonBlacklist = ns.frames:CreateFrame('Button', 'BlacklistButton', f, 'UIPanelButtonTemplate')
    buttonBlacklist:SetPoint("TOPLEFT", buttonInvite, "BOTTOMLEFT", 0, 0)
    buttonBlacklist:SetText(L['BLACKLIST'])
    buttonBlacklist:SetSize((buttonInvite:GetWidth() /2) - 3, 30)
    buttonBlacklist:SetScript("OnClick", function(self, button, down) scanner:BlacklistPlayer() end)
    buttonBlacklist:SetScript("OnEnter", function(self) ns.code:createTooltip(L['BLACKLIST_TITLE'], L['BLACKLIST_SCANNER_TOOLTIP']) end)
    buttonBlacklist:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.tblFrame.buttonBlacklist = buttonBlacklist

    local buttonSkip = ns.frames:CreateFrame('Button', 'SkipButton', f, 'UIPanelButtonTemplate')
    buttonSkip:SetPoint("LEFT", buttonBlacklist, "RIGHT", 5, 0)
    buttonSkip:SetText(L['SKIP_PLAYER'])
    buttonSkip:SetSize((buttonInvite:GetWidth() /2) - 3, 30)
    buttonSkip:SetScript("OnClick", function(self, button, down)
        scanner:AntiSpam() end)
    buttonSkip:SetScript("OnEnter", function(self) ns.code:createTooltip(L['ANTISPAM_TITLE'], L['ANTISPAM_SCANNER_TOOLTIP']) end)
    buttonSkip:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.tblFrame.buttonSkip = buttonSkip
end
function scanner:CreateWhoFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_WhoFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "TOPRIGHT", 5, 0)
    f:SetSize(self.tblFrame.frame:GetWidth() - (self.tblFrame.inviteFrame:GetWidth() + 5), self.tblFrame.inviteFrame:GetHeight())
    self.tblFrame.whoFrame = f

    local whoText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    whoText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 3)
    whoText:SetText(string.format(L['WHO_RESULTS'], 0))
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
local defaultButtonText = L['SCAN_FOR_PLAYERS']
function scanner:StartScanFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_ScanFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "BOTTOMLEFT", 0, 0)
    f:SetSize(self.tblFrame.inviteFrame:GetWidth(), self.adjustedY*0.3)
    self.tblFrame.scannerFrame = {}
    self.tblFrame.scannerFrame.frame = f

    local ScanText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ScanText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 3)
    ScanText:SetText(L['SCAN_FOR_PLAYERS']..':')
    ScanText:SetTextColor(1, 1, 1, 1)

    local nextFilterLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nextFilterLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
    nextFilterLabel:SetFont(ns.DEFAULT_FONT, 10, "OUTLINE")
    nextFilterLabel:SetText(string.format(L['NEXT_QUERY'], 'none'))
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
    playerCountText:SetText(string.format(L['PLAYERS_QUEUED'], 0))
    playerCountText:SetTextColor(1, 1, 1, 1)
    self.tblFrame.scannerFrame.playerCountText = playerCountText
end
function scanner:CreateAnalyticsFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_AnalFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.whoFrame, "BOTTOMLEFT", 0, 0)
    f:SetSize(self.tblFrame.whoFrame:GetWidth(), self.adjustedY*0.3)
    self.tblFrame.analytics = f

    local analText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    analText:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 3)
    analText:SetText("Session Analytics:")
    analText:SetTextColor(1, 1, 1, 1)
    self.tblFrame.analyticsText = analText

    local dataFrame = ns.frames:CreateFrame('Frame', 'Analytics_DataFrame', f)
    dataFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -10)
    dataFrame:SetSize(f:GetWidth() - 20, f:GetHeight() - 20)
    dataFrame:SetBackdropColor(0, 0, 0, 0.5)
    dataFrame:SetBackdropBorderColor(0, 0, 0, 0)
    self.tblFrame.analyticsData = dataFrame

    self:UpdateSessionData(dataFrame)
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
    self.tblFrame.whoText:SetText(string.format(L['WHO_RESULTS'], #self.tblWho))

    if self.tblWho then
        self.tblWho = ns.code:sortTableByField(self.tblWho, 'fullName') end

    self:UpdateButtons()
    self:DisplayWhoList()
end
function scanner:DisplayWhoList()
    self.tblWho = self.tblWho or {}
    self.tblToInvite = self.tblToInvite or {}

    local rowHeight = 20
    local sFrame = self.tblFrame.whoScroll
    local whoSorted = ns.code:sortTableByField(self.tblWho, 'fullName')

    -- Clear Records from Invite List
    if self.tblFrame.whoContent then
        ns.frames:ResetFrame(self.tblFrame.whoContent)
    end

    -- Create the frame to hold the content
    local content = ns.frames:CreateFrame('Frame', 'Who_Content', sFrame)
    content:SetSize(sFrame:GetWidth() - rowHeight, 1)
    content:SetBackdropColor(0, 0, 0, 0)
    content:SetBackdropBorderColor(0, 0, 0, 0)
    self.tblFrame.whoContent = content

    local function createWhoEntry(parent, r)
        local row = ns.frames:CreateFrame('Frame', nil, parent)
        row:SetBackdropColor(1, 1, 1, 0)
        row:SetBackdropBorderColor(0, 0, 0, 0)
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
        txtName:SetText(ns.code:cPlayer(r.fullName, r.class))

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
            local title = r.level..' '..r.fullName..' ('..r.raceStr..': '..(r.gender == 2 and 'Male' or 'Female')..')'
            local body = r.failed ~= '' and 'Failed: '..(r.failed or 'Unknown')..'\n' or ''
            body = body..'Guild: '..guild..'\n \nLocation: '..(r.zone or 'Unknown')
            ns.code:createTooltip(title, body, true)
        end)
        row:SetScript("OnLeave", function(self)
            rowTexture:Hide()
            GameTooltip:Hide()
        end)

        return row
    end

    for i, result in ipairs(whoSorted) do
        if result.guild == '' then
            local inviteOk, reason = ns.invite:CheckWhoList(result.fullName, result.zone)
            if inviteOk and not self.tblToInvite[result.fullName] then
                result.level = result.level == ns.MAX_CHARACTER_LEVEL and ns.code:cText('FF00FF00', result.level) or ns.code:cText('FFFFFFFF', result.level)
                self.tblToInvite[result.fullName] = result
                ns.analytics:UpdateData('SCANNED_NO_GUILD')
            else
                ns.analytics:UpdateSessionData('SESSION_SCANNED_NO_GUILD')
                result.level = ns.code:cText('FFFF0000', result.level)
                result.failed = ns.code:cText('FFFF0000', reason)
            end
        end

        local row = createWhoEntry(content, result)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((i-1) * rowHeight))
    end

    content:SetHeight(#whoSorted * rowHeight)
    sFrame:SetScrollChild(content)

    sFrame:SetVerticalScroll(0)
    sFrame:UpdateScrollChildRect()

    self:DisplayInviteList()
end
function scanner:DisplayInviteList()
    self.tblToInvite = self.tblToInvite or {}

    local rowHeight = 20
    local sFrame = self.tblFrame.scannerFrame
    local scrollFrame = self.tblFrame.inviteScroll
    self.tblToInviteSorted = ns.code:sortTableByField(self.tblToInvite, 'fullName')

    if self.tblFrame.inviteContent then
        ns.frames:ResetFrame(self.tblFrame.inviteContent) end

    local content = ns.frames:CreateFrame('Frame', 'Invite_Entry_Content', scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - rowHeight, #self.tblToInviteSorted * rowHeight)
    content:SetBackdropColor(0, 0, 0, 0)
    content:SetBackdropBorderColor(0, 0, 0, 0)
    content:Show()
    self.tblFrame.inviteContent = content

    local function createInviteEntry(parent, r)
        local row = ns.frames:CreateFrame('Frame', nil, parent)
        row:SetBackdropColor(1, 1, 1, 0)
        row:SetBackdropBorderColor(0, 0, 0, 0)
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
            local body = r.failed ~= '' and 'Failed: '..(r.failed  or 'Unknown')..'\n' or ''
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
    for i, result in ipairs(self.tblToInviteSorted) do
        local row = createInviteEntry(content, result)
        if row then
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((i-1) * rowHeight))
            rowCount = rowCount + 1
        end
    end

    scrollFrame:SetScrollChild(content)
    scrollFrame:UpdateScrollChildRect()
    scrollFrame:SetVerticalScroll(0)
    scrollFrame:Show()

    self.tblFrame.scannerFrame.playerCountText:SetText(string.format(L['PLAYERS_QUEUED'], #self.tblToInviteSorted))
    if sFrame.nextText then
        local nextPlayer = #self.tblToInviteSorted > 0 and self.tblToInviteSorted[1].name or L['NO_QUEUED_PLAYERS']
        sFrame.nextText:SetText(string.format(L['NEXT_PLAYER_INVITE'], #self.tblToInviteSorted))
        sFrame.nextPlayerText:SetText(nextPlayer)
    end
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
        txtNext:SetText(L['NEXT_PLAYER_INVITE'], 0)
        txtNext:SetJustifyH('CENTER')
        txtNext:SetTextColor(1, 1, 1, 1)
        sFrame.nextText = txtNext
        sFrame.nextText:SetShown(true)

        local txtNextPlayer = sFrame.nextPlayerText or sFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txtNextPlayer:SetPoint("TOPLEFT", txtNext, "BOTTOMLEFT", 2, -5)
        txtNextPlayer:SetText(L['NO_QUEUED_PLAYERS'])
        txtNextPlayer:SetTextColor(1, 1, 1, 1)
        txtNextPlayer:SetJustifyH('CENTER')
        sFrame.nextPlayerText = txtNextPlayer
        sFrame.nextPlayerText:SetShown(true)

        local buttonInvite = sFrame.buttonInvite or ns.frames:CreateFrame('Button', 'InviteButton', sFrame.frame, 'UIPanelButtonTemplate')
        buttonInvite:SetPoint("BOTTOMLEFT", sFrame.frame, "BOTTOMLEFT", 5, 5)
        buttonInvite:SetSize((sFrame.frame:GetWidth() /2) - 5, 20)
        buttonInvite:SetText(L["INVITE"])
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
        buttonSkip:SetText(L['SKIP'])
        buttonSkip:SetShown(true)
        buttonSkip:SetScript("OnClick", function(self, button, down) scanner:AntiSpam() end)
        buttonSkip:SetScript("OnEnter", function(self) ns.code:createTooltip('Add Player to Anti-Spam', 'Will add the queued player to Anti-Spam list.') end)
        buttonSkip:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
        sFrame.buttonSkip = buttonSkip

        self:DisplayWhoList()
    end
end
function scanner:BuildFilters()
    local filterID = ns.pSettings.activeFilter or 9999
    self.tblFilter = {}

    local min, max = self.minLevel, self.maxLevel
    local function createQuery(desc, criteria, lMin, rangeEnd)
        local fRec = {
            ['desc'] = desc..' ('..min..'-'..max..')',
            ['cmdWho'] = criteria..' '..min..'-'..max,
            ['min'] = lMin,
            ['max'] = rangeEnd,
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

    for _, v in pairs(tblSorted or {}) do
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
function scanner:DisplayNextFilter() return string.format(L['NEXT_QUERY'], self.tblFilter[1].desc) end
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
    ns.analytics:UpdateData('LAST_SCAN', date('%m/%d/%Y %H:%M:%S'))
    ns.analytics:UpdateSessionData('LAST_SCAN', date('%m/%d/%Y %H:%M:%S'))

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
            sFrame.buttonScan:SetText(L['WAIT']..' '..remain..'s')
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
    local tblInvite = self.tblToInvite
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
    if not self.tblToInviteSorted then return
    elseif #self.tblToInviteSorted == 0 then
        ns.code:fOut(L['INVITE_FIRST_STEP']) return
    end

    local tbl = tremove(self.tblToInviteSorted, 1)
    self.tblToInvite[tbl.fullName] = nil
    if not tbl then return end

    ns.invite:AutoInvite(tbl.fullName, tbl.pName, self.inviteFormat)
    self:DisplayWhoList()
end
function scanner:AntiSpam()
    if not self.tblToInvite then return end

    local count = 0
    for _, v in pairs(self.tblToInviteSorted) do
        if v.isChecked and not ns.list:CheckAntiSpam(v.fullName) then
            ns.list:AddToAntiSpam(v.fullName)
            self.tblToInvite[v.fullName] = nil
            count = count + 1
        end
    end
    ns.code:fOut(string.format(L['ADD_TO_ANTISPAM'], count))

    self:DisplayWhoList() -- Displays invite inside of function
end
function scanner:BlacklistPlayer()
    if not self.tblToInvite then return end

    local count = 0
    for _, v in pairs(self.tblToInvite) do
        if v.isChecked and not ns.list:CheckBlacklist(v.fullName) then
            ns.list:AddToBlackList(v.fullName, 'Blacklisted during invite process.')
            self.tblToInvite[v.fullName] = nil
            count = count + 1
        end
    end
    ns.code:fOut(string.format(L['ADD_TO_BLACKLIST'], count))

    self:DisplayWhoList() -- Displays invite inside of function
end

--* Analytics Functions
function scanner:UpdateSessionData(parent, rowsPerColumn)
    parent = parent or self.tblFrame.analyticsData
    local sorted = ns.code:sortTableByField(ns.analytics.sData, 'label')

    -- Layout constants
    local rowHeight = 20
    local columnSpacing = 190
    local maxRows = rowsPerColumn or 4
    local font = "GameFontNormal"

    ns.frames:ResetFontString(parent)

    -- Helper function to create a text row
    local function createTextRow(text, offsetX, offsetY, col)
        local fontString = ns.frames:getFontString(parent, font)
        fontString:SetPoint("TOPLEFT", parent, "TOPLEFT", offsetX, offsetY)
        fontString:SetWordWrap(false)
        if col == 1 then
            fontString:SetText(text..': ')
            fontString:SetJustifyH("RIGHT")
            fontString:SetWidth(115)
        else
            fontString:SetWidth(75)
            fontString:SetJustifyH("LEFT")
            fontString:SetText(ns.code:formatNumberWithCommas(tonumber(text)))
        end
        fontString:SetTextColor(1, 1, 1, 1)
        return fontString
    end

    -- Create table layout
    local offsetX = 10
    local offsetY = -10
    local currentRow = 1
    local currentColumn = 1

    for _, entry in ipairs(sorted) do
        if entry.key ~= 'TIMESTAMP' then
            -- Create description and value font strings
            createTextRow(entry.label, offsetX, offsetY - (rowHeight * (currentRow - 1)), 1)
            createTextRow(entry.value, offsetX + 115, offsetY - (rowHeight * (currentRow - 1)), 2)

            currentRow = currentRow + 1

            -- If we've reached the max rows, move to the next column
            if currentRow > maxRows then
                currentRow = 1
                currentColumn = currentColumn + 1
                offsetX = offsetX + columnSpacing
            end
        else self.tblFrame.analyticsText:SetText(string.format('Session Analytics: (%s)', entry.value)) end
    end

    --content:SetHeight((#sorted - 1) * rowHeight)
end