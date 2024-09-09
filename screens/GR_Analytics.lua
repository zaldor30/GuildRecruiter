local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local aceGUI = LibStub("AceGUI-3.0")

ns.win.analytics = {}
local analytics = ns.win.analytics

local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)
    analytics:SetShown(false)
end

function analytics:Init()
    self.isActive = false
    self.tblFrame = {}
end
function analytics:SetShown(val)
    local tblBase = ns.win.base.tblFrame

    if not val then
        tblBase.backButton:SetShown(false)
        if self.tblFrame.inline then
            self.tblFrame.inline:ReleaseChildren()
            self.tblFrame.inline.frame:Hide()
        end
        self.tblFrame.frame:Hide()
        ns.statusText:SetText('')
        ns.win.base.tblFrame.statsButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
        return
    end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    tblBase.frame:SetSize(500, 415)
    tblBase.backButton:SetShown(true)
    ns.win.base.tblFrame.frame:SetShown(true)
    ns.win.base.tblFrame.statsButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    self:CreateBaseFrame()
    self:CreateProfileStats()
    self:CreateGlobalStats()
    self:CreateOverallStats()
    self:CreateSessionStats()
end
function analytics:CreateBaseFrame()
    local tblBase = ns.win.base.tblFrame

    local f = self.tblFrame.frame or CreateFrame('Frame', 'GR_STATS_FRAME', tblBase.frame, 'BackdropTemplate')
    f:ClearAllPoints()
    f:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 20)
    f:SetPoint('BOTTOMRIGHT', tblBase.statusBar, 'TOPRIGHT', 0, -5)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:EnableMouse(false)
    f:SetShown(true)
    self.tblFrame.frame = f

    -- Inline Group for Player Stats
    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline
end
function analytics:CreateProfileStats()
    local inlinePlayer = aceGUI:Create('InlineGroup')
    inlinePlayer:SetTitle('Start Date: '..(ns.code:ConvertDateTime(ns.analytics:getStats('startDate'), false) or 'unknown'))
    inlinePlayer:SetLayout('Flow')
    inlinePlayer:SetRelativeWidth(.5)
    inlinePlayer:SetHeight(100)
    self.tblFrame.inline:AddChild(inlinePlayer)

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

    self:CreateStatsLabel(L['TOTAL_SCANNED']..':', ns.analytics:getStats('PlayersScanned'), scrollPlayer)
    self:CreateStatsLabel(L['TOTAL_INVITED']..':', ns.analytics:getStats('PlayersInvited'), scrollPlayer)
    self:CreateStatsLabel(L['TOTAL_ACCEPTED']..':', ns.analytics:getStats('PlayersJoined'), scrollPlayer)
    self:CreateStatsLabel(L['TOTAL_DECLINED']..':', ns.analytics:getStats('PlayersDeclined'), scrollPlayer)
    self:CreateStatsLabel(L['TOTAL_BLACKLISTED']..':', ns.analytics:getStats('PlayersBlackListed'), scrollPlayer)
end
function analytics:CreateGlobalStats()
    local inlineAccount = aceGUI:Create('InlineGroup')
    inlineAccount:SetTitle('Start Date: '..(ns.code:ConvertDateTime(ns.analytics:getStats('startDate'), true) or 'unknown'))
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

    self:CreateStatsLabel(L['TOTAL_SCANNED']..':', ns.analytics:getStats('PlayersScanned'), scrollAccount, false, true)
    self:CreateStatsLabel(L['TOTAL_INVITED']..':', ns.analytics:getStats('PlayersInvited'), scrollAccount, false, true)
    self:CreateStatsLabel(L['TOTAL_ACCEPTED']..':', ns.analytics:getStats('PlayersJoined'), scrollAccount, false, true)
    self:CreateStatsLabel(L['TOTAL_DECLINED']..':', ns.analytics:getStats('PlayersDeclined'), scrollAccount, false, true)
    self:CreateStatsLabel(L['TOTAL_BLACKLISTED']..':', ns.analytics:getStats('PlayersBlackListed'), scrollAccount, false, true)
end
function analytics:CreateOverallStats()
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
    for _ in pairs(ns.tblAntiSpamList) do iCount = iCount + 1 end
    self:CreateStatsLabel(L['TOTAL_ANTI_SPAM']..':', tostring(iCount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", ""), statsScrollOverall)

    local statsScrollBLOverall = aceGUI:Create("ScrollFrame")
    statsScrollBLOverall:SetLayout("Flow")
    statsScrollBLOverall:SetRelativeWidth(.5)
    statsScrollBLOverall:SetHeight(20)
    inlineMiddle:AddChild(statsScrollBLOverall)

    local blCount = 0
    for _ in pairs(ns.tblBlackList) do blCount = blCount + 1 end
    self:CreateStatsLabel(L['TOTAL_BLACKLISTED']..':', tostring(blCount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", ""), statsScrollBLOverall)
end
function analytics:CreateSessionStats()
    self.statsInline = aceGUI:Create('InlineGroup')
    local inlineBottomRight = self.statsInline
    inlineBottomRight:SetTitle(L['SESSION_STATS']..':')
    inlineBottomRight:SetLayout('Flow')
    inlineBottomRight:SetFullWidth(true)
    inlineBottomRight:SetHeight(100)
    self.tblFrame.inline:AddChild(inlineBottomRight)

    local statsScroll1 = aceGUI:Create("ScrollFrame")
    statsScroll1:SetLayout("Flow")
    statsScroll1:SetRelativeWidth(.5)
    statsScroll1:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll1)

    self:CreateStatsLabel(L['TOTAL_SCANNED']..':', ns.analytics:getSessionStats('PlayersScanned'), statsScroll1)
    self:CreateStatsLabel(L['TOTAL_INVITED']..':', ns.analytics:getSessionStats('PlayersInvited'), statsScroll1)

    local pending = ns.analytics:getStats('WaitingOnInvite', true) or 0
    local lblUnknown = aceGUI:Create("Label")
    lblUnknown:SetText(L['INVITES_PENDING']..':')
    lblUnknown:SetFontObject('GameFontHighlight')
    lblUnknown:SetRelativeWidth(.6)
    statsScroll1:AddChild(lblUnknown)

    local lblUnknown2 = aceGUI:Create("Label")
    lblUnknown2:SetText(ns.code:cText(pending > 0 and 'FFFF0000' or 'FF00FF00', pending))
    lblUnknown2:SetFontObject('GameFontHighlight')
    lblUnknown2:SetRelativeWidth(.4)
    statsScroll1:AddChild(lblUnknown2)

    local statsScroll2 = aceGUI:Create("ScrollFrame")
    statsScroll2:SetLayout("Flow")
    statsScroll2:SetRelativeWidth(.5)
    statsScroll2:SetHeight(55)
    inlineBottomRight:AddChild(statsScroll2)

    self:CreateStatsLabel(L['TOTAL_DECLINED']..':', ns.analytics:getSessionStats('PlayersDeclined'), statsScroll2)
    self:CreateStatsLabel(L['TOTAL_ACCEPTED']..':', ns.analytics:getSessionStats('PlayersJoined'), statsScroll2)
    self:CreateStatsLabel(L['TOTAL_BLACKLISTED']..':', ns.analytics:getSessionStats('PlayersBlackListed'), statsScroll2)

    local function refreshTimer()
        pending = ns.analytics:getSessionStats('WaitingOnInvite')

        if not self.statsShown then return end
        lblUnknown2:SetText(ns.code:cText(pending > 0 and 'FFFF0000' or 'FFFFFFFF', pending))
        C_Timer.After(3, refreshTimer)
    end
    refreshTimer()
end

--* Create Stats Label
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