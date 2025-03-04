local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.whatsnew = {}
local whatsnew = ns.whatsnew

local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)
    whatsnew:SetShown(false)
end

local function parseMarkdown(text)
    text = text:gsub("### (.-)\n", "|cFFFFFFFF%1|r\n")
    text = text:gsub("## (.-)\n", "|cFF00FF00%1|r\n")
    text = text:gsub("# (.-)\n", "|cFFFFFF00%1|r\n")
    text = text:gsub("%*%*(.-)%*%*", "|cFFFFFFFF%1|r")
    text = text:gsub("%*(.-)%*", "|cFFAAAAAA%1|r")
    text = text:gsub("\n%- (.-)\n", "\n|cFFDDDDDD• %1|r\n")
    return text
end
local function highlightButton(btn, normal)
    if not btn then return end

    local normTexture = btn:GetNormalTexture()
    if not normTexture then return end

    normTexture:SetAllPoints(true) -- Ensure the texture covers the entire button
    normTexture:SetBlendMode("BLEND") -- Enable alpha blending for transparency
    normTexture:SetTexCoord(0, 1, 0, 1) -- Use the full texture
    if normal then normTexture:SetVertexColor(1, 1, 1, 1)
    else normTexture:SetVertexColor(0.05, 0.70, 0.90, 1) end

    --if lostFocus then normTexture:SetVertexColor(1, 1, 1, 1)
    --else normTexture:SetVertexColor(12, 179, 230, 1) end
end

whatsnew.returnToMain = false
function whatsnew:Init()
    self.tblFrame = self.tblFrame or {}
    self.oldVer = ns.g.shownVersion
    self.showBase = ns.base:IsShown() or false

    self.changes = parseMarkdown(ns.changeLog)
    self.startUpWhatsNew = ns.g.showWhatsNew

    self.screenPos = ns.pSettings.screenPos or { -- Get default position and current position
        point = 'CENTER',
        x = 0,
        y = 0
    }
end

function whatsnew:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function whatsnew:SetShown(val, startUpView)
    if whatsnew:IsShown() == val then return
    elseif not val then
        if not self.tblFrame or not self.tblFrame.frame then return end

        self.tblFrame.frame:Hide()
        ns.frames:ResetFrame(self.tblFrame.frame)
        ns.base:SetShown(self.showBase)
        return
    end

    whatsnew:Init()
    if startUpView and (not self.startUpWhatsNew or self.oldVer == GR.version) then return end
    ns.g.shownVersion = GR.version

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    self:CreateBaseFrame()
    self:CreateTopFrame()
    self:CreateFooterFrame()
    self:CreateNoteFrame()
end
local baseHeight = -60
function whatsnew:CreateBaseFrame()
    local f = ns.frames:CreateFrame('Frame', 'GR_WhatsNew', UIParent)
    f:SetPoint(self.screenPos.point, self.screenPos.x, self.screenPos.y)
    f:SetSize(400, 300)
    f:SetBackdropColor(0, 0, 0, .5)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:SetFrameStrata(ns.DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetShown(true)

    self.tblFrame.frame = f

    --* Create Icon Frame
    f = ns.frames:CreateFrame('Frame', 'GR_BaseIconFrame', self.tblFrame.frame)
    f:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 0, 0)
    f:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'TOPRIGHT', 0, baseHeight)
    f:SetBackdropColor(0, 0, 0, 1)
    self.tblFrame.icon = f

    local t = f:CreateTexture(nil, 'ARTWORK')
    t:SetPoint('LEFT', f, 'LEFT', 10, 0)
    t:SetTexture(ns.GR_ICON)

    local txt = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txt:SetPoint('TOPLEFT', t, 'TOPRIGHT', 10, 0)
    txt:SetText(L['TITLE'])
    txt:SetTextColor(1, 1, 1, 1)
    txt:SetFont(ns.DEFAULT_FONT, 16, 'OUTLINE')

    local txtVer = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txtVer:SetPoint('BOTTOMLEFT', t, 'BOTTOMRIGHT', 10, 0)
    txtVer:SetText(GR.versionOut:gsub("[%(%)]", ""))
    txtVer:SetTextColor(1, 1, 1, 1)
    txtVer:SetFont(ns.DEFAULT_FONT, 12, 'OUTLINE')
    --? End Icon Frame
    --self:CreateBodyFrame()
end
function whatsnew:CreateTopFrame()
    local btnClose = ns.frames:CreateFrame('Button', 'GR_CloseButton', self.tblFrame.icon)
    btnClose:SetPoint('TOPRIGHT', self.tblFrame.icon, 'TOPRIGHT', -10, -10)
    btnClose:SetSize(15, 15)
    btnClose:SetNormalTexture(ns.BUTTON_EXIT)
    btnClose:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnClose:SetScript('OnClick', function()
        whatsnew:SetShown(false)

        if whatsnew.returnToMain then ns.base:SetShown(true) end
        self.returnToMain = false
    end)
    btnClose:SetScript('OnEnter', function() highlightButton(btnClose) ns.code:createTooltip(L["CLOSE"]..' '..L['TITLE']) end)
    btnClose:SetScript('OnLeave', function() highlightButton(btnClose, true) GameTooltip:Hide() end)
end
function whatsnew:CreateFooterFrame()
    local f = ns.frames:CreateFrame('Frame', 'GR_NoteFooter', self.tblFrame.frame)
    f:SetPoint('BOTTOMLEFT', self.tblFrame.frame, 'BOTTOMLEFT', 10, 10)
    f:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'BOTTOMRIGHT', -10, 10)
    f:SetHeight(30)
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    self.tblFrame.footer = f

    local btnShowWhatsNew = ns.frames:CreateFrame('Button', 'GR_ShowWhatsNew', f)
    btnShowWhatsNew:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -10, -8)
    btnShowWhatsNew:SetSize(15, 15)
    btnShowWhatsNew:SetNormalTexture(ns.g.showWhatsNew and ns.BUTTON_EXIT or ns.BUTTON_EXIT_EMPTY)
    btnShowWhatsNew:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnShowWhatsNew:SetScript('OnClick', function(self)
        ns.g.showWhatsNew = not ns.g.showWhatsNew
        self.startUpWhatsNew = ns.g.showWhatsNew
        self:SetNormalTexture(ns.g.showWhatsNew and ns.BUTTON_EXIT or ns.BUTTON_EXIT_EMPTY)
    end)
    btnShowWhatsNew:SetScript('OnEnter', function() highlightButton(btnShowWhatsNew) ns.code:createTooltip(L['GEN_WHATS_NEW'], L['GEN_WHATS_NEW_DESC']) end)
    btnShowWhatsNew:SetScript('OnLeave', function() highlightButton(btnShowWhatsNew, true) GameTooltip:Hide() end)

    local txt = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txt:SetPoint('TOPLEFT', f, 'TOPLEFT', 10, -10)
    txt:SetPoint('TOPRIGHT', btnShowWhatsNew, 'TOPLEFT', -10, -10)
    txt:SetTextColor(1, 1, 1, 1)
    txt:SetJustifyH('RIGHT')
    txt:SetText(L['GEN_WHATS_NEW'])
end
function whatsnew:CreateNoteFrame()
    local f = ns.frames:CreateFrame('Frame', 'GR_NoteFrame', self.tblFrame.frame)
    f:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 10, baseHeight)
    f:SetPoint('BOTTOMRIGHT', self.tblFrame.footer, 'TOPRIGHT', 0, 0)
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(1, 1, 1, 1)

    local scroll = ns.frames:CreateFrame('ScrollFrame', 'GR_NoteScroll', f, 'UIPanelScrollFrameTemplate')
    scroll:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    scroll:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -5, 5)

    local scrollBar = scroll.ScrollBar
    scrollBar:SetWidth(12)
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, -25)
    scrollBar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 25)

    local content = ns.frames:CreateFrame('Frame', 'GR_NoteContent', scroll)
    content:SetSize(scroll:GetWidth(), scroll:GetHeight())
    scroll:SetScrollChild(content)

    local txt = content:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txt:SetPoint('TOPLEFT', content, 'TOPLEFT', 5, -5)
    txt:SetPoint('TOPRIGHT', content, 'TOPRIGHT', -5, -5)
    txt:SetJustifyH('LEFT')
    txt:SetJustifyV('TOP')
    txt:SetText(parseMarkdown(ns.changeLog))
end