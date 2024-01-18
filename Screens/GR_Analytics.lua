local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

local aceGUI = LibStub("AceGUI-3.0")

ns.screens.analytics = {}
local analytics = ns.screens.analytics

local function obsCLOSE_SCREENS()
    analytics.isActive = false

    local tblFrame = analytics.tblFrame
    local tblScreen = ns.screens.base.tblFrame
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)

    tblScreen.backButton:SetShown(false)
    tblScreen.statsButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    if tblFrame.frame and tblFrame then
        tblFrame.frame:SetShown(false)
        tblFrame.inline.frame:SetShown(false)
    end
end

function analytics:Init()
    self.isActive = false

    self.tblFrame = {}
end
function analytics:StartStatsScreen()
    if self.isActive then return end

    self.isActive = true
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    self.tblFrame.controls = self.tblFrame.controls or {}
    local tblScreen = ns.screens.base.tblFrame

    tblScreen.frame:SetSize(500, 415)
    tblScreen.backButton:SetShown(true)
    tblScreen.statsButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    self:BuildBaseFrame()
    self:BuildProfileStats()
    self:BuildGlobalStats()
    self:BuildOverallStats()
    self:BuildSessionStats()
end
function analytics:BuildBaseFrame()
    local tblScreen = ns.screens.base.tblFrame

    -- Base Frame for ACE3
    local f = self.tblFrame.frame or CreateFrame('Frame', 'GR_STATS_FRAME', tblScreen.frame, 'BackdropTemplate')
    f:ClearAllPoints()
    f:SetPoint('TOPLEFT', tblScreen.topFrame, 'BOTTOMLEFT', -5, 20)
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
    end

    -- Inline Group for Player Stats
    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline
end
function analytics:BuildProfileStats()
    ns.dbAP.startDate = ns.dbAP.startDate or C_DateAndTime.GetServerTimeLocal()

    local inlinePlayer = aceGUI:Create('InlineGroup')
    inlinePlayer:SetTitle('Start Date: '..(ns.dbAP.startDate and ns.code:ConvertDateTime(ns.dbAP.startDate, false) or 'unknown'))
    inlinePlayer:SetLayout('Flow')
    inlinePlayer:SetRelativeWidth(.5)
    inlinePlayer:SetHeight(100)
    self.tblFrame.inline:AddChild(inlinePlayer)
    self.tblFrame.controls.inlinePlayer = inlinePlayer

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

    self:CreateStatsLabel(L['Players Scanned']..':', ns.analytics:getStats('PlayersScanned'), scrollPlayer)
    self:CreateStatsLabel(L['Total Invites']..':', ns.analytics:getStats('PlayersInvited'), scrollPlayer)
    self:CreateStatsLabel(L['Total Accepted']..':', ns.analytics:getStats('PlayersJoined'), scrollPlayer)
    self:CreateStatsLabel(L['Total Declined']..':', ns.analytics:getStats('PlayersDeclined'), scrollPlayer)
    self:CreateStatsLabel(L['Total Black List']..':', ns.analytics:getStats('PlayersBlackListed'), scrollPlayer)
end
function analytics:BuildGlobalStats()
    ns.dbAG.startDate = ns.dbAG.startDate or C_DateAndTime.GetServerTimeLocal()

    local inlineAccount = aceGUI:Create('InlineGroup')
    inlineAccount:SetTitle('Start Date: '..(ns.dbAG.startDate and ns.code:ConvertDateTime(ns.dbAG.startDate, false) or 'unknown'))
    inlineAccount:SetLayout('Flow')
    inlineAccount:SetRelativeWidth(.5)
    inlineAccount:SetHeight(100)
    self.tblFrame.inline:AddChild(inlineAccount)

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

    self:CreateStatsLabel(L['Players Scanned']..':', ns.analytics:getStats('PlayersScanned'), scrollAccount, false, true)
    self:CreateStatsLabel(L['Total Invites']..':', ns.analytics:getStats('PlayersInvited'), scrollAccount, false, true)
    self:CreateStatsLabel(L['Total Accepted']..':', ns.analytics:getStats('PlayersJoined'), scrollAccount, false, true)
    self:CreateStatsLabel(L['Total Declined']..':', ns.analytics:getStats('PlayersDeclined'), scrollAccount, false, true)
    self:CreateStatsLabel(L['Total Black List']..':', ns.analytics:getStats('PlayersBlackListed'), scrollAccount, false, true)
end
function analytics:BuildOverallStats()
    self.statsOverall = aceGUI:Create('InlineGroup')
    local inlineMiddle = self.statsOverall
    inlineMiddle:SetTitle('Stored Stats:')
    inlineMiddle:SetLayout('Flow')
    inlineMiddle:SetFullWidth(true)
    inlineMiddle:SetHeight(100)
    self.tblFrame.inline:AddChild(inlineMiddle)

    local statsScrollOverall = aceGUI:Create("ScrollFrame")
    statsScrollOverall:SetLayout("Flow")
    statsScrollOverall:SetRelativeWidth(.5)
    statsScrollOverall:SetHeight(20)
    inlineMiddle:AddChild(statsScrollOverall)

    local iCount = 0
    for _ in pairs(ns.tblInvited) do iCount = iCount + 1 end
    self:CreateStatsLabel(L['Players on Anti-Spam']..':', tostring(iCount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", ""), statsScrollOverall)

    local statsScrollBLOverall = aceGUI:Create("ScrollFrame")
    statsScrollBLOverall:SetLayout("Flow")
    statsScrollBLOverall:SetRelativeWidth(.5)
    statsScrollBLOverall:SetHeight(20)
    inlineMiddle:AddChild(statsScrollBLOverall)

    local blCount = 0
    for _ in pairs(ns.tblBlackList) do blCount = blCount + 1 end
    self:CreateStatsLabel(L['Total Black List']..':', tostring(blCount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", ""), statsScrollBLOverall)
end
function analytics:BuildSessionStats()
    self.statsInline = aceGUI:Create('InlineGroup')
    local inlineBottomRight = self.statsInline
    inlineBottomRight:SetTitle(L['Session Stats']..':')
    inlineBottomRight:SetLayout('Flow')
    inlineBottomRight:SetFullWidth(true)
    inlineBottomRight:SetHeight(100)
    self.tblFrame.inline:AddChild(inlineBottomRight)

    local statsScroll1 = aceGUI:Create("ScrollFrame")
    statsScroll1:SetLayout("Flow")
    statsScroll1:SetRelativeWidth(.5)
    statsScroll1:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll1)

    self:CreateStatsLabel(L['Players Scanned']..':', ns.analytics:getStats('PlayersScanned', true), statsScroll1)
    self:CreateStatsLabel(L['Total Invites']..':', ns.analytics:getStats('PlayersInvited', true), statsScroll1)

    local pending = ns.analytics:getStats('WaitingOnPlayer', true) or 0
    local lblUnknown = aceGUI:Create("Label")
    lblUnknown:SetText('Waiting On: '..ns.code:cText(pending > 0 and 'FFFF0000' or 'FF00FF00', pending))
    lblUnknown:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    lblUnknown:SetFullWidth(true)
    statsScroll1:AddChild(lblUnknown)

    local statsScroll2 = aceGUI:Create("ScrollFrame")
    statsScroll2:SetLayout("Flow")
    statsScroll2:SetRelativeWidth(.5)
    statsScroll2:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll2)

    self:CreateStatsLabel(L['Total Declined']..':', ns.analytics:getStats('PlayersDeclined', true), statsScroll2)
    self:CreateStatsLabel(L['Total Accepted']..':', ns.analytics:getStats('PlayersJoined', true), statsScroll2)
    self:CreateStatsLabel(L['Total Black List']..':', ns.analytics:getStats('PlayersBlackListed', true), statsScroll2)

    local function refreshTimer()
        pending = ns.analytics:getStats('WaitingOnPlayer', true)

        if not self.statsShown then return end
        lblUnknown:SetText(L['Pending']..': '..ns.code:cText(pending > 0 and 'FFFF0000' or 'FFFFFFFF', pending))
        C_Timer.After(3, refreshTimer)
    end
    refreshTimer()
end

-- Other Functions
function analytics:CreateStatsLabel(text, value, parent)
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
analytics:Init()