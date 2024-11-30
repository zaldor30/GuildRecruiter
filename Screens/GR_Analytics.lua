local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.stats = {}
local stats = ns.stats

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    ns.base.tblFrame.statsButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)

    if not stats.tblFrame then return end
    if stats.tblFrame.topFrame then ns.frames:ResetFrame(stats.tblFrame.topFrame) end
    if stats.tblFrame.bottomFrame then ns.frames:ResetFrame(stats.tblFrame.bottomFrame) end
    stats.tblFrame.frame = nil
end

function stats:Init()
    self.tblFrame = {}
end
function stats:IsShown() return self.tblFrame and self.tblFrame.frame and self.tblFrame.frame:IsShown() end
function stats:SetShown(val)
    local baseFrame = ns.base.tblFrame

    if not val and not self:IsShown() then return
    elseif not val then
        baseFrame.statsButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
        ns.frames:ResetFrame(self.tblFrame.frame)
        return
    end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    ns.status:SetText('')
    baseFrame.back:SetShown(true)
    baseFrame.frame:SetSize(500, 450)
    baseFrame.statsButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)

    self:Init()
    self:CreateBaseFrame()
    self:PopulateTopData()
    self:PopulateSessionData()
end
function stats:CreateBaseFrame()
    local baseFrame = ns.base.tblFrame
    local fTop = ns.frames:CreateFrame('Frame', 'GR_StatsTop', baseFrame.frame)
    fTop:SetPoint('TOPLEFT', baseFrame.icon, 'BOTTOMLEFT', 5, -5)
    fTop:SetPoint('TOPRIGHT', baseFrame.icon, 'BOTTOMRIGHT', -5, -5)
    fTop:SetHeight(175)
    self.tblFrame.topFrame = fTop

    local sTop = ns.frames:CreateFrame('ScrollFrame', 'GR_StatsTopScroll', fTop, 'UIPanelScrollFrameTemplate')
    sTop:SetPoint('TOPLEFT', fTop, 'TOPLEFT', 5, -5)
    sTop:SetPoint('BOTTOMRIGHT', fTop, 'BOTTOMRIGHT', -5, 5)
    sTop.ScrollBar:SetWidth(12)
    self.tblFrame.sTop = sTop

    sTop.ScrollBar:ClearAllPoints()
    sTop.ScrollBar:SetPoint("TOPRIGHT", sTop, "TOPRIGHT", -5, -20)
    sTop.ScrollBar:SetPoint("BOTTOMRIGHT", sTop, "BOTTOMRIGHT", 5, 20)

    local fBottom = ns.frames:CreateFrame('Frame', 'GR_StatsBottom', baseFrame.frame)
    fBottom:SetPoint('TOPLEFT', fTop, 'BOTTOMLEFT', 0, -5)
    fBottom:SetPoint('BOTTOMRIGHT', baseFrame.status, 'TOPRIGHT', -5, 5)
    self.tblFrame.bottomFrame = fBottom

    local sBottom = ns.frames:CreateFrame('ScrollFrame', 'GR_StatsTopScroll', fBottom, 'UIPanelScrollFrameTemplate')
    sBottom:SetPoint('TOPLEFT', fBottom, 'TOPLEFT', 5, -5)
    sBottom:SetPoint('BOTTOMRIGHT', fBottom, 'BOTTOMRIGHT', -5, 5)
    sBottom.ScrollBar:SetWidth(12)
    self.tblFrame.sBottom = sBottom

    sBottom.ScrollBar:ClearAllPoints()
    sBottom.ScrollBar:SetPoint("TOPRIGHT", sBottom, "TOPRIGHT", -5, -20)
    sBottom.ScrollBar:SetPoint("BOTTOMRIGHT", sBottom, "BOTTOMRIGHT", 5, 20)
end

--* Data Population Functions
local rowHeight = 20
local function createAnalyticsEntry(contentFrame, label, value, isTS)
    local row = ns.frames:CreateFrame('Frame', nil, contentFrame)
    row:SetBackdropColor(1, 1, 1, 0)
    row:SetBackdropBorderColor(0, 0, 0, 0)
    row:SetSize(contentFrame:GetWidth(), rowHeight)

    local rowLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rowLabel:SetPoint('LEFT', 10, 0)
    rowLabel:SetWidth(contentFrame:GetWidth()/2)
    if not isTS then rowLabel:SetTextColor(1, 1, 1, 1)
    else rowLabel:SetTextColor(1, 1, 0, 1) end
    rowLabel:SetJustifyH("LEFT")
    rowLabel:SetText(label)

    local rowValue = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rowValue:SetPoint('RIGHT', -25, 0) -- 25 is the width of the scroll bar
    rowValue:SetWidth(contentFrame:GetWidth()/2)
    if not isTS then rowLabel:SetTextColor(1, 1, 1, 1)
    else rowLabel:SetTextColor(1, 1, 0, 1) end
    rowValue:SetJustifyH("RIGHT")
    rowValue:SetText(type(value) == 'number' and ns.code:formatNumberWithCommas(value) or value)

    if not isTS then
        local rowTexture = row:CreateTexture(nil, "BACKGROUND")
        rowTexture:SetAtlas(ns.BLUE_LONG_HIGHLIGHT)
        rowTexture:SetAllPoints(row)
        rowTexture:SetBlendMode("ADD")
        rowTexture:Hide()

        row:SetScript("OnEnter", function(self) rowTexture:Show() end)
        row:SetScript("OnLeave", function(self) rowTexture:Hide() end)
    end

    return row
end
function stats:PopulateTopData()
    ns.analytics:RetrieveSavedData()

    local sTop = self.tblFrame.sTop
    local gSorted = ns.code:sortTableByField(ns.analytics.gData, 'label') or {}
    local pSorted = ns.code:sortTableByField(ns.analytics.pData, 'label') or {}

    --* Guild and Profile Analytics
    if self.tblFrame.contentTop then ns.frames:ResetFrame(self.tblFrame.contentTop) end
    local contentTop = ns.frames:CreateFrame('Frame', 'GR_StatsTopContent', sTop)
    contentTop:SetSize(sTop:GetWidth(), 1)
    contentTop:SetBackdropColor(0, 0, 0, 0)
    contentTop:SetBackdropBorderColor(1, 1, 1, 0)
    self.tblFrame.contentTop = contentTop

    local rowCount = 0
    local tsRow = createAnalyticsEntry(contentTop, L['GUILD_ANALYTICS']..' ('..ns.analytics.gData.TIMESTAMP.value..'):', '', true)
    tsRow:SetPoint("TOPLEFT", contentTop, "TOPLEFT", 0, -(rowCount * rowHeight))
    for i=1, #gSorted do
        local result = gSorted[i]

        if result and result.key ~= 'TIMESTAMP' and result.key ~= 'LAST_SCAN' then
            rowCount = rowCount + 1
            local row = createAnalyticsEntry(contentTop, result.label, result.value)
            row:SetPoint("TOPLEFT", contentTop, "TOPLEFT", 0, -((rowCount) * rowHeight))
        end
    end
    rowCount = rowCount + 1
    tsRow = createAnalyticsEntry(contentTop, L['LAST_SCAN'], ns.analytics.gData.LAST_SCAN.value, true)
    tsRow:SetPoint("TOPLEFT", contentTop, "TOPLEFT", 0, -(rowCount * rowHeight))

    rowCount = rowCount + 2
    tsRow = createAnalyticsEntry(contentTop, L['PROFILE_ANALYTICS']..' ('..ns.analytics.pData.TIMESTAMP.value..'):', '', true)
    tsRow:SetPoint("TOPLEFT", contentTop, "TOPLEFT", 0, -(rowCount * rowHeight))
    for i=1, #pSorted do
        local result = pSorted[i]

        if result and result.key ~= 'TIMESTAMP' and result.key ~= 'LAST_SCAN' then
            rowCount = rowCount + 1
            local row = createAnalyticsEntry(contentTop, result.label, result.value)
            row:SetPoint("TOPLEFT", contentTop, "TOPLEFT", 0, -((rowCount) * rowHeight))
        end
    end
    rowCount = rowCount + 1
    tsRow = createAnalyticsEntry(contentTop, L['LAST_SCAN'], ns.analytics.pData.LAST_SCAN.value, true)
    tsRow:SetPoint("TOPLEFT", contentTop, "TOPLEFT", 0, -(rowCount * rowHeight))

    contentTop:SetHeight(rowCount * rowHeight)
    sTop:SetScrollChild(contentTop)

    sTop:SetVerticalScroll(0)
    sTop:UpdateScrollChildRect()
    --* End of Guild and Profile Analytics
end
function stats:PopulateSessionData()
    local sBottom = self.tblFrame.sBottom
    local sSorted = ns.code:sortTableByField(ns.analytics.sData, 'label') or {}

    if self.tblFrame.contentBottom then ns.frames:ResetFrame(self.tblFrame.contentBottom) end
    local contentBottom = ns.frames:CreateFrame('Frame', 'GR_StatsBottomContent', sBottom)
    contentBottom:SetSize(sBottom:GetWidth(), 1)
    contentBottom:SetBackdropColor(0, 0, 0, 0)
    contentBottom:SetBackdropBorderColor(1, 1, 1, 0)
    self.tblFrame.contentBottom = contentBottom -- Save the content frame for later use

    local rowCount = 0
    local tsRow = createAnalyticsEntry(contentBottom, L['SESSION_ANALYTICS']..' ('..ns.analytics.sData.TIMESTAMP.value..'):', '', true)
    tsRow:SetPoint("TOPLEFT", contentBottom, "TOPLEFT", 0, -(rowCount * rowHeight))
    for i=1, #sSorted do
        local result = sSorted[i]

        if result and result.key ~= 'TIMESTAMP' then
            rowCount = rowCount + 1
            local row = createAnalyticsEntry(contentBottom, result.label, result.value)
            row:SetPoint("TOPLEFT", contentBottom, "TOPLEFT", 0, -((rowCount) * rowHeight))
        end
    end

    contentBottom:SetHeight(rowCount * rowHeight)
    sBottom:SetScrollChild(contentBottom)

    sBottom:SetVerticalScroll(0)
    sBottom:UpdateScrollChildRect()
end