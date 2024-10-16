local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.scanner = {}
local scanner = ns.scanner

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    ns.base:SwitchToCompactMode(true)
    ns.frames:ResetFrame(scanner.tblFrame.frame)
    scanner.tblFrame.frame = nil
end

local function CallBackWhoListUpdate()
    ns.events:Unregister('WHO_LIST_UPDATE', CallBackWhoListUpdate)

    ns.analytics:incStats('PlayersScanned', C_FriendList.GetNumWhoResults())

    local sessionStats = ns.analytics:getSessionStats('PlayersScanned')
    scanner:UpdateAnalytics()

    scanner:ProcessWhoList(C_FriendList.GetNumWhoResults())
end

function scanner:Init()
    self.isCompact = false
    self.compactMode = ns.g.compactSize or 1
    self.baseX, self.baseY = 600, 475
    self.adjustedY = self.baseY - (ns.base.tblFrame.icon:GetHeight() + ns.status.frame:GetHeight())

    self.tblFrame = {}
end
function scanner:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function scanner:SetShown(val)
    if val and scanner:IsShown() then return
    elseif not val and not self:IsShown() then return
    elseif not val then self.tblFrame.frame:SetShown(false) end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    self:Init()
    if not self.tblFrame.frame then
        self:CreateScannerBaseFrame()
        self:CreateInviteFrame()
        self:CreateWhoFrame()
        self:StartScanFrame()
        self:CreateAnalyticsFrame()
    end

    local baseFrame = ns.base.tblFrame
    baseFrame.back:SetShown(true)
    baseFrame.reset:SetShown(true)
    baseFrame.compact:SetShown(true)

    self:SetCompactMode()
    self.tblFrame.frame:SetShown(val)
end
function scanner:SetCompactMode()
    self.isCompact = ns.pSettings.isCompact or false
    ns.base:SwitchToCompactMode(false, self.isCompact)
end
function scanner:CreateScannerBaseFrame()
    local baseFrame = ns.base.tblFrame
    local f = ns.frames:CreateFrame('Frame', 'Scanner_BaseFrame', baseFrame.frame)
    f:SetPoint("TOPLEFT", baseFrame.icon, "BOTTOMLEFT", 5, 0)
    f:SetSize(self.baseX - 10, self.adjustedY)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f:EnableMouse(false)
    self.tblFrame.frame = f
end
function scanner:CreateInviteFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_InviteFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.frame, "TOPLEFT", 0, 0)
    f:SetSize(self.tblFrame.frame:GetWidth()*0.35, self.adjustedY*0.6)
    self.tblFrame.inviteFrame = f
end
function scanner:CreateWhoFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_WhoFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "TOPRIGHT", 5, 0)
    f:SetSize(self.tblFrame.frame:GetWidth() - (self.tblFrame.inviteFrame:GetWidth() + 5), self.tblFrame.inviteFrame:GetHeight())
    self.tblFrame.whoFrame = f
end
function scanner:StartScanFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_ScanFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "BOTTOMLEFT", 0, 0)
    f:SetSize(self.tblFrame.inviteFrame:GetWidth(), self.adjustedY*0.4)
    self.tblFrame.scannerFrame = f
end
function scanner:CreateAnalyticsFrame()
    local f = ns.frames:CreateFrame('Frame', 'Scanner_AnalFrame', self.tblFrame.frame)
    f:SetPoint("TOPLEFT", self.tblFrame.whoFrame, "BOTTOMLEFT", 0, 0)
    f:SetSize(self.tblFrame.whoFrame:GetWidth(), self.adjustedY*0.4)
    self.tblFrame.analytics = f
end

--* Scanner Functions
function scanner:CompactModeChanged()
    self.compactMode = ns.pSettings.isCompact or false
    local compactSize = ns.g.compactSize or 1

    if self.compactMode then
        self.tblFrame.whoFrame:SetShown(false)
        self.tblFrame.analytics:SetShown(false)
        self.tblFrame.scannerFrame:SetPoint("TOPLEFT", ns.base.tblFrame.icon, "BOTTOMLEFT", 5, 0)
    else
        self.tblFrame.whoFrame:SetShown(true)
        self.tblFrame.analytics:SetShown(true)
        self.tblFrame.inviteFrame:SetShown(true)
        self.tblFrame.scannerFrame:SetPoint("TOPLEFT", self.tblFrame.inviteFrame, "BOTTOMLEFT", 0, 0)
        return
    end

    if self.compactMode and compactSize == 1 then
    elseif self.compactMode and compactSize == 2 then
        self.tblFrame.inviteFrame:SetShown(false)
    end
end