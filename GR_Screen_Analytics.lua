local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.stats = {}
local stats = ns.stats
function stats:Init()
    self.statsShown = false
end
function stats:StartStatsScreen()
    ns.screen.fMain:SetSize(500, 305)
    ns.screen:ResetMain()
    ns.screen.aMain.frame:SetPoint("TOP", ns.screen.fTop_Icon, "BOTTOM", 1, 3)

    ns.screen.iconBack:Show()
    ns.screen.iconBack:SetScript('OnMouseUp', function() ns.main:ScannerSettingsLayout() end)

    self.statsShown = true
    local function createStatsLabel(text, value, parent)
        local lbl = aceGUI:Create('Label')
        lbl:SetText(text)
        lbl:SetFontObject('GameFontHighlight')
        lbl:SetRelativeWidth(.6)
        parent:AddChild(lbl)

        lbl = aceGUI:Create('Label')
        lbl:SetText(value)
        lbl:SetFontObject('GameFontHighlight')
        lbl:SetRelativeWidth(.4)
        parent:AddChild(lbl)
    end

    local inlinePlayer = aceGUI:Create('InlineGroup')
    inlinePlayer:SetTitle('Start Date: '..(ns.dbAnal.startDate and ns.code:ConvertDateTime(ns.dbAnal.startDate, false) or 'unknown'))
    inlinePlayer:SetLayout('Flow')
    inlinePlayer:SetRelativeWidth(.5)
    inlinePlayer:SetHeight(100)
    ns.screen.aMain:AddChild(inlinePlayer)

    local scrollPlayer = aceGUI:Create('ScrollFrame')
    scrollPlayer:SetLayout('Flow')
    scrollPlayer:SetFullWidth(true)
    scrollPlayer:SetHeight(100)
    inlinePlayer:AddChild(scrollPlayer)

    local lblPlayerHeader = aceGUI:Create('Label')
    lblPlayerHeader:SetText(ns.code:cText('FFFFFF00', UnitName('player')..' Stats:'))
    lblPlayerHeader:SetFontObject('GameFontHighlightLarge')
    lblPlayerHeader:SetFullWidth(true)
    scrollPlayer:AddChild(lblPlayerHeader)

    createStatsLabel('Players Scanned:', ns.analytics:get('Players_Scanned'), scrollPlayer)
    createStatsLabel('Invites Sent:', ns.analytics:get('Invited_Players'), scrollPlayer)
    createStatsLabel('Invites Accepted:', ns.analytics:get('Accepted_Invite'), scrollPlayer)
    createStatsLabel('Invites Declined:', ns.analytics:get('Declined_Invite'), scrollPlayer)
    createStatsLabel('Blacklisted Players:', ns.analytics:get('Black_Listed'), scrollPlayer)

    local inlineAccount = aceGUI:Create('InlineGroup')
    inlineAccount:SetTitle('Start Date: '..(ns.dbGAnal.startDate and ns.code:ConvertDateTime(ns.dbGlobal.startDate, false) or 'unknown'))
    inlineAccount:SetLayout('Flow')
    inlineAccount:SetRelativeWidth(.5)
    inlinePlayer:SetHeight(100)
    ns.screen.aMain:AddChild(inlineAccount)

    local scrollAccount = aceGUI:Create('ScrollFrame')
    scrollAccount:SetLayout('Flow')
    scrollAccount:SetFullWidth(true)
    scrollAccount:SetHeight(100)
    inlineAccount:AddChild(scrollAccount)

    local lblAccountHeader = aceGUI:Create('Label')
    lblAccountHeader:SetText(ns.code:cText('FFFFFF00', 'Account Stats:'))
    lblAccountHeader:SetFontObject('GameFontHighlightLarge')
    lblAccountHeader:SetFullWidth(true)
    scrollAccount:AddChild(lblAccountHeader)

    createStatsLabel('Players Scanned:', ns.analytics:get('Players_Scanned', true), scrollAccount)
    createStatsLabel('Invites Sent:', ns.analytics:get('Invited_Players', true), scrollAccount)
    createStatsLabel('Invites Accepted:', ns.analytics:get('Accepted_Invite', true), scrollAccount)
    createStatsLabel('Invites Declined:', ns.analytics:get('Declined_Invite', true), scrollAccount)
    createStatsLabel('Black Listed Players:', ns.analytics:get('Black_Listed', true), scrollAccount)

    self.statsInline = aceGUI:Create('InlineGroup')
    local inlineBottomRight = self.statsInline
    inlineBottomRight:SetTitle('Session Stats:')
    inlineBottomRight:SetLayout('Flow')
    inlineBottomRight:SetFullWidth(true)
    inlineBottomRight:SetHeight(100)
    ns.screen.aMain:AddChild(inlineBottomRight)

    local statsScroll1 = aceGUI:Create("ScrollFrame")
    statsScroll1:SetLayout("Flow")
    statsScroll1:SetRelativeWidth(.5)
    statsScroll1:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll1)

    local lblTotalScanned = aceGUI:Create("Label")
    lblTotalScanned:SetText('Total Scanned: '..ns.scanner.totalScanned)
    lblTotalScanned:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalScanned:SetFullWidth(true)
    statsScroll1:AddChild(lblTotalScanned)

    local lblTotalInvites = aceGUI:Create("Label")
    lblTotalInvites:SetText('Total Invites: '..ns.scanner.totalInvites)
    lblTotalInvites:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalInvites:SetFullWidth(true)
    statsScroll1:AddChild(lblTotalInvites)

    local lblUnknown = aceGUI:Create("Label")
    lblUnknown:SetText('Waiting On: '..ns.scanner.totalUnknown)
    lblUnknown:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblUnknown:SetFullWidth(true)
    statsScroll1:AddChild(lblUnknown)

    local statsScroll2 = aceGUI:Create("ScrollFrame")
    statsScroll2:SetLayout("Flow")
    statsScroll2:SetRelativeWidth(.5)
    statsScroll2:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll2)

    local lblTotalDeclined = aceGUI:Create("Label")
    lblTotalDeclined:SetText('Total Declined: '..ns.scanner.totalDeclined)
    lblTotalDeclined:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalDeclined:SetFullWidth(true)
    statsScroll2:AddChild(lblTotalDeclined)

    local lblTotalAccepted = aceGUI:Create("Label")
    lblTotalAccepted:SetText('Total Accepted: '..ns.scanner.totalAccepted)
    lblTotalAccepted:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalAccepted:SetFullWidth(true)
    statsScroll2:AddChild(lblTotalAccepted)

    local lblTotalBlackList = aceGUI:Create("Label")
    lblTotalBlackList:SetText('Total Black List: '..ns.scanner.totalBlackList)
    lblTotalBlackList:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalBlackList:SetFullWidth(true)
    statsScroll2:AddChild(lblTotalBlackList)

    local function refreshTimer()
        if not self.statsShown then return end
        lblUnknown:SetText('Waiting On: '..ns.scanner.totalUnknown)
        C_Timer.After(1, refreshTimer)
    end
    refreshTimer()
end
stats:Init()