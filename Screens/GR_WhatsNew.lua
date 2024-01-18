local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

local aceGUI = LibStub("AceGUI-3.0")

ns.screens.whatsnew = {}
local whatsnew = ns.screens.whatsnew

local function obsCLOSE_SCREENS()
    if not ns.core.fullyStarted then
        ns.core.fullyStarted = true
        return
    end

    local tblScreen = ns.screens.base.tblFrame

    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)

    whatsnew.tblFrame.frame:SetShown(false)
    if whatsnew.tblFrame.inline then
        whatsnew.tblFrame.inline:ReleaseChildren()
        whatsnew.tblFrame.inline.frame:Hide()
    end

    tblScreen.topFrame:SetShown(true)
    tblScreen.statusBar:SetShown(true)
    tblScreen.frame:SetShown(false)
end

function whatsnew:Init()
    self.tblFrame = {}

    self.title = nil
    self.body = nil
    self.height = 300
end
function whatsnew:StartUp()
    local tblScreen = ns.screens.base.tblFrame

    self.title, self.body, self.height, self.update = ns.ds:WhatsNew()
    if strlower(ns.ds.grVersion):match('beta') then
        self.title = self.title:gsub(GR.version, ns.ds.grVersion)
        self.title = self.title:gsub('-Beta', ' (Beta)'):gsub('-beta', ' (Beta)')
    end

    tblScreen.frame:SetSize(tblScreen.frame:GetWidth() + 50, self.height)
    tblScreen.frame:SetShown(true)
    tblScreen.topFrame:SetShown(false)
    tblScreen.statusBar:SetShown(false)

    self:BuildBaseFrame()
    self:BuildTopBar()
    self:BuildBody()

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)
end
function whatsnew:BuildBaseFrame()
    local tblFrame = self.tblFrame
    local tblScreen = ns.screens.base.tblFrame

    local f = tblFrame.frame or CreateFrame('Frame', 'GR_WhatsNew', tblScreen.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:SetPoint('TOPLEFT', tblScreen.frame, 'TOPLEFT', 10, -15)
    f:SetPoint('BOTTOMRIGHT', tblScreen.frame, 'TOPRIGHT', -5, -30)
    f:SetShown(true)
    tblFrame.frame = f
end
function whatsnew:BuildTopBar()
    local tblFrame = self.tblFrame

    local appIconButton = CreateFrame('Button', 'GR_BASE_APPICON', tblFrame.frame)
    appIconButton:SetSize(32, 32)
    appIconButton:SetPoint('TOPLEFT', 5, -5)
    appIconButton:SetNormalTexture(GR.icon)
    appIconButton:SetShown(true)

    -- Title text
    local titleText = tblFrame.frame:CreateFontString(nil, 'OVERLAY')
    titleText:SetFont(DEFAULT_FONT, 14, 'OUTLINE')
    titleText:SetPoint('TOP', 0, -5)
    titleText:SetText(L['TITLE'])
    titleText:SetShown(true)

    -- Close Button
    local closeButton = CreateFrame('Button', 'GR_BASE_CLOSE', tblFrame.frame)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint('TOPRIGHT', -5, -5)
    closeButton:SetNormalTexture(ICON_PATH..'GR_Exit')
    closeButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    closeButton:SetScript('OnClick', function()
        ns.core.fullyStarted = true
        ns.observer:Notify('CLOSE_SCREENS') end)
    closeButton:SetScript('OnEnter', function() ns.code:createTooltip("Close What's New?") end)
    closeButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    closeButton:SetShown(true)
end
function whatsnew:BuildBody()
    local tblFrame = self.tblFrame
    local tblScreen = ns.screens.base.tblFrame

    local title = tblFrame.frame:CreateFontString(nil, 'OVERLAY')
    title:SetFont(SKURRI_FONT, 30, 'OUTLINE')
    title:SetPoint('TOPLEFT', tblFrame.frame, 'TOPLEFT', 0, -30)
    title:SetPoint('TOPRIGHT', tblFrame.frame, 'TOPRIGHT', 0, -30)
    title:SetJustifyH('CENTER')
    title:SetText(self.title)
    title:SetShown(true)

    local showWhatsNew = true
    if type(ns.db.global.showWhatsNew) == "boolean" then showWhatsNew = ns.db.global.showWhatsNew or false end
    local checkbox = CreateFrame('CheckButton', 'GR_BASE_checkbox', tblFrame.frame, 'UICheckButtonTemplate')
    checkbox:SetPoint('BOTTOMRIGHT', tblScreen.frame, 'BOTTOMRIGHT', -5, 5)
    checkbox:SetSize(20, 20)
    checkbox:SetChecked(showWhatsNew)
    checkbox:SetScript('OnClick', function() ns.db.global.showWhatsNew = not ns.db.global.showWhatsNew end)

    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.text:SetPoint('RIGHT', checkbox, 'LEFT', -5, 0)
    checkbox.text:SetText('Show when new versions are available')

    local inline = tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Fill')
    inline:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -5)
    inline:SetPoint('BOTTOMRIGHT', checkbox, 'BOTTOMRIGHT', -5, 20)
    inline.frame:Show()
    tblFrame.inline = inline

    local scroll = aceGUI:Create('ScrollFrame')
    scroll:SetLayout('fill')
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    inline:AddChild(scroll)

    local body = aceGUI:Create('Label')
    body:SetFont(DEFAULT_FONT, 14, 'OUTLINE')
    body:SetColor(1, 1, 1)
    body:SetText(self.body)
    body:SetJustifyH('LEFT')
    body:SetJustifyV('TOP')
    body:SetFullWidth(true)
    body:SetFullHeight(true)
    scroll:AddChild(body)

    if not GR.debug then ns.db.global.version = ns.ds.grVersion end
end
whatsnew:Init()