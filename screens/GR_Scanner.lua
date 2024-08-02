local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.win.scanner = {}
local scanner = ns.win.scanner

local function obsCLOSE_SCREENS_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)
    scanner:SetShown(false)
end
local function CallBackWhoListUpdate()
end

function scanner:Init()
    self.tblScanner = nil
    self.baseFrame = nil

    self.invControls = nil
    self.whoControls = nil
    self.scanControls = nil
    self.analyticControls = nil

    self.tblInvites = {}

    self.activeQuery = nil
end
function scanner:SetShown(val)
    self.tblScanner = self.tblScanner or {}
    self.tblScanner.frames = self.tblScanner.frames or {}

    local tblBase = ns.win.base.tblFrame
    local scannerBase = self.tblScanner.frames.baseFrame or nil

    if not val then
        tblBase.backButton:SetShown(false)
        tblBase.resetButton:SetShown(false)
        tblBase.compactButton:SetShown(false)
        ns.statusText:SetText('')

        if scannerBase and scannerBase.inline then
            scannerBase.inline:ReleaseChildren()
            scannerBase.inline.frame:Hide()
        end

        return
    end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    local resetFilters = false
    if not self.tblScanner or not self.tblScanner.tblFilter then resetFilters = true end

    self.tblScanner = self.tblScanner or {}
    self.tblScanner = {
        frames = {},
        isCompact = self.tblScanner.isCompact or false,
        tblWho = self.tblScanner.tblWho and self.tblScanner.tblWho or {},
        tblInvites = self.tblScanner.tblInvites and self.tblScanner.tblInvites or {},
        activeFilter = ns.pSettings.activeFilter or 1,
        tblFilter = self.tblScanner.tblFilter or nil,
        filterCount = 0,
        totalFilters = self.tblScanner.totalFilters or 0,
        whisperMessage = tblBase.inviteMessage,
        minLevel = ns.pSettings.minLevel or MAX_CHARACTER_LEVEL - 5,
        maxLevel = ns.pSettings.maxLevel or MAX_CHARACTER_LEVEL,
        scanWaitTime = ns.gSettings.scanWaitTime or ns.core.addonSettings.global.settings.scanWaitTime or 6,
    }
    if not self.tblScanner.tblFilter then self:ResetFilters(resetFilters) end

    tblBase.backButton:SetShown(true)
    tblBase.resetButton:SetShown(true)
    tblBase.compactButton:SetShown(true)

    local x, y = (self.tblScanner.isCompact and 215 or 600), (self.tblScanner.isCompact and 470 or 475)

    -- ToDo: Compact Mode
    ns.win.base:SetShown(true)
    ns.win.base.tblFrame.frame:SetSize(x, y)

    self:CreateScannerFrame()
    self:CreateInviteFrame()
    self:CreateWhoFrame()
    self:CreateScanSection()
    self:CreateAnalyticSection()
end
function scanner:CreateScannerFrame()
    self.tblScanner.frames.baseFrame = self.tblScanner.frames.baseFrame or {}
    local tblBase, baseFrame = ns.win.base.tblFrame, self.tblScanner.frames.baseFrame

    -- Base Regular Frame (With Scan Keybind)
    local f = baseFrame.frame or CreateFrame('Frame', 'GR_SCANNER_FRAME', tblBase.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:EnableMouse(false)
    f:SetPropagateKeyboardInput(true)
    f:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 20)
    f:SetPoint('BOTTOMRIGHT', tblBase.statusBar, 'TOPRIGHT', 0, -5)
    f:SetScript('OnKeyDown', function(_, key)
        if ns.global.keybindScan and key == ns.global.keybindScan then
            if self.scanWaitTime > 0 then
                ns.code:fOut(L['PLEASE_WAIT']..' '..self.scanWaitTime..' '..L['ERROR_SCAN_WAIT'])
            elseif self.tblFrame.inline.controls.btnSearch.disabled then ns.code:fOut(L['ERROR_CANNOT_SCAN'])
            else self:GetNextFilterRecord() end
        elseif ns.global.keybindInvite and key == ns.global.keybindInvite then self:InvitePlayers() end
    end)
    f:SetShown(true)
    baseFrame.frame = f

    -- Ace GUI Frame for Ace Controls
    local inline = baseFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:Show()
    baseFrame.inline = inline

    self.baseFrame = baseFrame
end
function scanner:CreateInviteFrame()
    self.tblScanner.frames.inviteFrame = self.tblScanner.frames.inviteFrame or {}
    local baseFrame, invFrame = self.tblScanner.frames.baseFrame, self.tblScanner.frames.inviteFrame
    local baseInline, invControls = baseFrame.inline, invFrame.controls or {}

    -- Base Inline Group for Invite Controls
    local inlineInvite = invControls.inlineInvite or aceGUI:Create('InlineGroup')
    inlineInvite:SetLayout('Flow')
    inlineInvite:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineInvite.frame:SetFrameStrata(DEFAULT_STRATA)
    inlineInvite:SetHeight(200)
    baseInline:AddChild(inlineInvite)
    invFrame.inline = inlineInvite

    -- Invite ScrollBox
    local scrollInvite = invControls.scrollInvite or aceGUI:Create('ScrollFrame')
    scrollInvite:SetLayout('Flow')
    scrollInvite:SetFullWidth(true)
    scrollInvite:SetHeight(160)
    inlineInvite:AddChild(scrollInvite)
    invControls.scrollInvite = scrollInvite

    -- Invite Button
    local btnInvite = invControls.btnInvite or aceGUI:Create('Button')
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
    invControls.btnInvite = btnInvite

    -- Black List Player Button
    local btnRemove = invControls.btnRemove or aceGUI:Create('Button')
    btnRemove:SetText(L['BL'])
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetDisabled(true)
    btnRemove:SetCallback('OnEnter', function()
        local title = L['BL_BUTTON_TOOLTIP']
        local body = L['SKIP_BUTTON_BODY_TOOLTIP']
        ns.code:createTooltip(title, body)
    end)
    btnRemove:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnRemove:SetCallback('OnClick', function()
    end)
    inlineInvite:AddChild(btnRemove)
    invControls.btnRemove = btnRemove

    -- Skip Button
    local btnSkip = invControls.btnSkip or aceGUI:Create('Button')
    btnSkip:SetText(L['SKIP'])
    btnSkip:SetRelativeWidth(.5)
    btnSkip:SetDisabled(true)
    btnSkip:SetCallback('OnEnter', function()
        local title = L['SKIP_BUTTON_TOOLTIP']
        local body = L['SKIP_BUTTON_BODY_TOOLTIP']
        ns.code:createTooltip(title, body)
    end)
    btnSkip:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    btnSkip:SetCallback('OnClick', function()
    end)
    inlineInvite:AddChild(btnSkip)
    invControls.btnSkip = btnSkip

    self.invControls = invControls
end
function scanner:CreateWhoFrame()
    if self.isCompact then return end

    local baseFrame, whoFrame = self.tblScanner.frames.baseFrame, (self.tblScanner.frames.whoFrame or {})
    local baseInline, whoControls = baseFrame.inline, (whoFrame.controls or {})

    -- Base Inline Group for Who Controls
    local inlineWho = whoControls.inlineWho or aceGUI:Create('InlineGroup')
    inlineWho:SetLayout('Flow')
    inlineWho:SetRelativeWidth(.6)
    baseInline:AddChild(inlineWho)
    whoFrame.inline = inlineWho

    -- Who ScrollBox
    local scrollWho = whoControls.scrollWho or aceGUI:Create('ScrollFrame')
    scrollWho:SetLayout('Flow')
    scrollWho:SetFullWidth(true)
    scrollWho:SetHeight(200)
    inlineWho:AddChild(scrollWho)
    whoControls.scrollWho = scrollWho

    -- Who Results Text
    local lblWho = aceGUI:Create("Label")
    lblWho:SetText(L['NUMBER_PLAYERS_FOUND']..': '..#self.tblScanner.tblWho)
    lblWho:SetFullWidth(true)
    lblWho:SetRelativeWidth(.5)
    inlineWho:AddChild(lblWho)
    whoControls.lblWhoFound = lblWho

    local lblWhoQuery = aceGUI:Create("Label")
    lblWhoQuery:SetText(self.activeQuery or 'TEST')
    lblWhoQuery:SetFullWidth(true)
    lblWhoQuery:SetRelativeWidth(.5)
    inlineWho:AddChild(lblWhoQuery)
    whoControls.lblWhoQuery = lblWhoQuery

    self.whoControls = whoControls
end
function scanner:CreateScanSection()
    local baseFrame, scanFrame = self.tblScanner.frames.baseFrame, self.tblScanner.frames.scanFrame or {}
    local baseInline, scanControls = baseFrame.inline, (self.scanControls or {})

    -- Base Inline Group for Scan Controls
    local inlineScan = aceGUI:Create('InlineGroup')
    inlineScan:SetLayout('Flow')
    inlineScan:SetRelativeWidth(self.isCompact and 1 or .4)
    inlineScan.frame:SetFrameStrata(DEFAULT_STRATA)
    inlineScan:SetHeight(120)
    baseInline:AddChild(inlineScan)

    -- Scan Button
    local btnSearch = aceGUI:Create('Button')
    btnSearch:SetText('Start Search')
    btnSearch:SetFullWidth(true)
    btnSearch:SetCallback('OnClick', function() self:GetNextFilterRecord() end)
    inlineScan:AddChild(btnSearch)
    scanControls.btnSearch = btnSearch

    local lblNextTitle = aceGUI:Create("Label")
    lblNextTitle:SetText(L['NEXT_FILTER']..': ')
    lblNextTitle:SetFont(DEFAULT_FONT, 10, 'OUTLINE')
    lblNextTitle:SetFullWidth(true)
    inlineScan:AddChild(lblNextTitle)

    local lblNextFilter = aceGUI:Create("Label")
    lblNextFilter:SetText('')
    lblNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblNextFilter:SetFullWidth(true)
    lblNextFilter:SetCallback('OnEnter', function()
        local title = L['NEXT_FILTER_TOOLTIP']
        local body = L['Checked players are for adding to black list.']
        ns.code:createTooltip(title, body)
    end)
    lblNextFilter:SetCallback('OnLeave', function() GameTooltip:Hide() end)
    inlineScan:AddChild(lblNextFilter)
    scanControls.lblNextFilter = lblNextFilter

    self.scanControls = scanControls
    self:DisplayNextFilter()
end
function scanner:CreateAnalyticSection()
    if self.isCompact then return end

    local baseFrame, analyticFrame = self.tblScanner.frames.baseFrame, self.tblScanner.frames.analyticFrame or {}
    local baseInline, analyticControls = baseFrame.inline, analyticFrame.controls or {}

    -- Base Inline Group for Analytic Controls
    local inlineAnalytic = analyticFrame.inlineAnalytic or aceGUI:Create('InlineGroup')
    inlineAnalytic:SetLayout('Flow')
    inlineAnalytic:SetRelativeWidth(.6)
    inlineAnalytic:SetHeight(100)
    baseInline:AddChild(inlineAnalytic)

    -- Left Analytic ScrollBox
    local scrollLeftAnalytic = analyticControls.scrollLeftAnalytic or aceGUI:Create('ScrollFrame')
    scrollLeftAnalytic:SetLayout('Flow')
    scrollLeftAnalytic:SetRelativeWidth(.5)
    scrollLeftAnalytic:SetHeight(55)
    inlineAnalytic:AddChild(scrollLeftAnalytic)
    analyticControls.scrollLeftAnalytic = scrollLeftAnalytic

    -- Right Analytic ScrollBox
    local scrollRightAnalytic = analyticControls.scrollRigthAnalytic or aceGUI:Create('ScrollFrame')
    scrollRightAnalytic:SetLayout('Flow')
    scrollRightAnalytic:SetRelativeWidth(.5)
    scrollRightAnalytic:SetHeight(55)
    inlineAnalytic:AddChild(scrollRightAnalytic)
    analyticControls.scrollRightAnalytic = scrollRightAnalytic

    --* Analytic Controls
    -- Left Analytic Controls
    local lblScanned = aceGUI:Create("Label")
    lblScanned:SetText(L['TOTAL_SCANNED']..': ')
    lblScanned:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblScanned:SetFullWidth(true)
    scrollLeftAnalytic:AddChild(lblScanned)
    analyticControls.lblPlayersScanned = lblScanned

    local lblInvited = aceGUI:Create("Label")
    lblInvited:SetText(L['TOTAL_INVITED']..': ')
    lblInvited:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblInvited:SetFullWidth(true)
    scrollLeftAnalytic:AddChild(lblInvited)
    analyticControls.lblTotalInvites = lblInvited

    local lblWaitingOn = aceGUI:Create("Label")
    lblWaitingOn:SetText(L['INVITES_PENDING']..': ')
    lblWaitingOn:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblWaitingOn:SetFullWidth(true)
    scrollLeftAnalytic:AddChild(lblWaitingOn)
    analyticControls.lblWaitingOn = lblWaitingOn

    local lblDeclined = aceGUI:Create("Label")
    lblDeclined:SetText(L['TOTAL_DECLINED']..': ')
    lblDeclined:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblDeclined:SetFullWidth(true)
    scrollRightAnalytic:AddChild(lblDeclined)
    analyticControls.lblDeclined = lblDeclined

    local lblTotalAccepted = aceGUI:Create("Label")
    lblTotalAccepted:SetText(L['TOTAL_ACCEPTED']..': ')
    lblTotalAccepted:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalAccepted:SetFullWidth(true)
    scrollRightAnalytic:AddChild(lblTotalAccepted)
    analyticControls.lblAccepted = lblTotalAccepted

    local lblBlackList = aceGUI:Create("Label")
    lblBlackList:SetText(L['TOTAL_BLACKLISTED']..': ')
    lblBlackList:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblBlackList:SetFullWidth(true)
    scrollRightAnalytic:AddChild(lblBlackList)
    analyticControls.lblTotalBlackList = lblBlackList

    self.analyticControls = analyticControls
end

--* Filter Routines
function scanner:ResetFilters() self:CreateFilters() end
function scanner:DisplayNextFilter() self:CreateFilters(true) end
function scanner:GetNextFilterRecord() self:CreateFilters(false, true) end
function scanner:CreateFilters(displayOnly, nextRecord)
    self.tblScanner.tblFilter = self.tblScanner.tblFilter or {}
    local tblScanner, tblFilters = self.tblScanner, self.tblScanner.tblFilter
    local activeFilterID = tblScanner.activeFilter or ns.pSettings.activeFilter or 1
    local totalFilters = tblFilters and #tblFilters or 0

    if displayOnly and tblFilters then
        if not self.scanControls then return end

        local desc = (tblFilters and tblFilters[1]) and tblFilters[1].desc or nil
        self.scanControls.lblNextFilter:SetText(desc or '')

        return
    elseif nextRecord then
        local tbl = tremove(tblFilters, 1)
        if tbl then
            self.whoControls.lblWhoQuery:SetText('Query: '..tbl.desc)
            scanner:DisplayNextFilter()

            -- Update Progress
            self.tblScanner.filterCount = self.tblScanner.filterCount + 1
            local percent = (self.tblScanner.filterCount / self.tblScanner.totalFilters) * 100        ns.statusText:SetText('Scanning Progress: '..percent..'%')
            ns.statusText:SetText('Scanning Progress: '..string.format("%d%%", percent))
        end

        if not tblFilters or #tblFilters == 0 then
            scanner:ResetFilters()
            ns.statusText:SetText(L['RESETTING_FILTERS'])
        end

        return
    end

    local function createClassFilter()
        for _, v in pairs(ns.tblClassesSortedByName) do
            local query = 'c-"'..v.name..'"'
            local min, max = tonumber(tblScanner.minLevel), tonumber(tblScanner.maxLevel)

            while min <= max do
                local rangeEnd = min + 5 > max and max or min + 5
                tblFilters[#tblFilters + 1] = {
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
            local min, max = tonumber(tblScanner.minLevel), tonumber(tblScanner.maxLevel)

            while min <= max do
                local rangeEnd = min + 5 > max and max or min + 5
                tblFilters[#tblFilters + 1] = {
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

    if activeFilterID == 1 then createClassFilter()
    elseif activeFilterID == 2 then createRaceFilter()
    elseif activeFilterID == 3 then createCustomFilter() end

    self.tblScanner.filterCount = 0
    self.tblScanner.totalFilters = tblFilters and #tblFilters or 0
    ns.statusText:SetText('')
    self:DisplayNextFilter()
end
scanner:Init()