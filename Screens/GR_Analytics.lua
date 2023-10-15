local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.stats = {}
local stats = ns.stats

local function obsCLOSE_SCREENS_SCANNER()
    local tblFrame = stats.tblFrame
    local tblScreen = ns.screen.tblFrame
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    tblScreen.backButton:SetShown(false)
    tblScreen.statsButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    if tblFrame.frame and tblFrame then
        tblFrame.frame:SetShown(false)
        tblFrame.inline.frame:SetShown(false)
    end
end

function stats:Init()
    self.tblFrame = {}
end
function stats:StartStatsScreen()
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    self.tblFrame.controls = self.tblFrame.controls or {}
    local tblFrame = self.tblFrame.controls
    local tblScreen = ns.screen.tblFrame

    tblScreen.frame:SetSize(500, 355)
    tblScreen.backButton:SetShown(true)
    tblScreen.statsButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    -- Base Frame for ACE3
    local f = self.tblFrame.frame or CreateFrame('Frame', 'GR_STATS_FRAME', tblScreen.frame, 'BackdropTemplate')
    f:ClearAllPoints()
    f:SetPoint('TOPLEFT', tblScreen.titleFrame, 'BOTTOMLEFT', -5, 20)
    f:SetPoint('BOTTOMRIGHT', tblScreen.statusBar, 'TOPRIGHT', 0, -5)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:EnableMouse(false)
    f:SetShown(true)
    self.tblFrame.frame = f

    if self.tblFrame.inline then
        self.tblFrame.inline:ReleaseChildren()
        self.tblFrame.controls = nil
    end

    -- Inline Group for Player Stats
    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline

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

    if not ns.dbAP.startDate then
        ns.dbAP.startDate = C_DateAndTime.GetServerTimeLocal()
    end

    local inlinePlayer = aceGUI:Create('InlineGroup')
    inlinePlayer:SetTitle('Start Date: '..(ns.dbAP.startDate and ns.code:ConvertDateTime(ns.dbAP.startDate, false) or 'unknown'))
    inlinePlayer:SetLayout('Flow')
    inlinePlayer:SetRelativeWidth(.5)
    inlinePlayer:SetHeight(100)
    inline:AddChild(inlinePlayer)

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

    if not ns.dbAP.startDate then
        ns.dbAG.startDate = C_DateAndTime.GetServerTimeLocal()
    end

    local inlineAccount = aceGUI:Create('InlineGroup')
    inlineAccount:SetTitle('Start Date: '..(ns.dbAG.startDate and ns.code:ConvertDateTime(ns.dbAG.startDate, false) or 'unknown'))
    inlineAccount:SetLayout('Flow')
    inlineAccount:SetRelativeWidth(.5)
    inlinePlayer:SetHeight(100)
    inline:AddChild(inlineAccount)

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
    inline:AddChild(inlineBottomRight)

    local statsScroll1 = aceGUI:Create("ScrollFrame")
    statsScroll1:SetLayout("Flow")
    statsScroll1:SetRelativeWidth(.5)
    statsScroll1:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll1)

    local tblCount = ns.scanner:GetSessionData()

    local lblTotalScanned = aceGUI:Create("Label")
    lblTotalScanned:SetText('Total Scanned: '..(tblCount['Total_Scanned'] or 0))
    lblTotalScanned:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalScanned:SetFullWidth(true)
    statsScroll1:AddChild(lblTotalScanned)

    local lblTotalInvites = aceGUI:Create("Label")
    lblTotalInvites:SetText('Total Invites: '..(tblCount['Total_Invited'] or 0))
    lblTotalInvites:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalInvites:SetFullWidth(true)
    statsScroll1:AddChild(lblTotalInvites)

    local lblUnknown = aceGUI:Create("Label")
    lblUnknown:SetText('Waiting On: '..ns.code:cText(((tblCount['Total_Unknown'] and tblCount['Total_Unknown'] and tblCount['Total_Unknown'] > 0) and 'FFFF0000' or 'FFFFFFFF'), (tblCount['Total_Unknown'] or 0)))
    lblUnknown:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblUnknown:SetFullWidth(true)
    statsScroll1:AddChild(lblUnknown)

    local statsScroll2 = aceGUI:Create("ScrollFrame")
    statsScroll2:SetLayout("Flow")
    statsScroll2:SetRelativeWidth(.5)
    statsScroll2:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll2)

    local lblTotalDeclined = aceGUI:Create("Label")
    lblTotalDeclined:SetText('Total Declined: '..(tblCount['Total_Declined'] or 0) )
    lblTotalDeclined:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalDeclined:SetFullWidth(true)
    statsScroll2:AddChild(lblTotalDeclined)

    local lblTotalAccepted = aceGUI:Create("Label")
    lblTotalAccepted:SetText('Total Accepted: '..(tblCount['Total_Accepted'] or 0))
    lblTotalAccepted:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalAccepted:SetFullWidth(true)
    statsScroll2:AddChild(lblTotalAccepted)

    local lblTotalBlackList = aceGUI:Create("Label")
    lblTotalBlackList:SetText('Total Black List: '..(tblCount['Total_BlackList'] or 0))
    lblTotalBlackList:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblTotalBlackList:SetFullWidth(true)
    statsScroll2:AddChild(lblTotalBlackList)

    local function refreshTimer()
        if not self.statsShown then return end
        lblUnknown:SetText('Waiting On: '..ns.code:cText(((tblCount['Total_Unknown'] and tblCount['Total_Unknown'] and tblCount['Total_Unknown'] > 0) and 'FFFF0000' or 'FFFFFFFF'), (tblCount['Total_Unknown'] or 0)))
        C_Timer.After(1, refreshTimer)
    end
    refreshTimer()
end
stats:Init()