local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local aceGUI = LibStub("AceGUI-3.0")

ns.win.whatsnew = {}
local whatsnew = ns.win.whatsnew

local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)
    whatsnew:SetShown(false)
end

function whatsnew:Init()
    self.tblFrame = {}
    self.title = nil
    self.body = nil
    self.height = 300

    self.startUpWhatsNew = false
end
function whatsnew:SetShown(val)
    if not val then
        if whatsnew.tblFrame.inline then
            whatsnew.tblFrame.inline:ReleaseChildren()
            whatsnew.tblFrame.inline.frame:Hide()
        end
        ns.win.base.tblFrame.statusBar:SetShown(true)
        ns.win.base.tblFrame.topFrame:SetShown(true)
        ns.win.base.tblFrame.statusBar:SetShown(true)
        ns.win.base:SetShown(false)

        whatsnew.tblFrame.frame:SetShown(false)
        return
    end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    ns.win.base:SetShown(true)
    ns.win.base.tblFrame.topFrame:SetShown(false)
    ns.win.base.tblFrame.frame:SetSize(ns.win.base.tblFrame.frame:GetWidth() + 50, self.height)
    ns.win.base.tblFrame.statusBar:SetShown(false)

    ns.global.currentVersion = GR.version
    self.title, self.body, self.height, self.update = ns.ds:WhatsNew()

    self:CreateBaseFrame()
    self:CreateTopFrame()
    self:CreateBodyFrame()
end
function whatsnew:CreateBaseFrame()
    local tblBase = ns.win.base.tblFrame

    local f = self.tblFrame.frame or CreateFrame('Frame', 'GR_WhatsNew', tblBase.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:SetPoint('TOPLEFT', tblBase.frame, 'TOPLEFT', 10, -15)
    f:SetPoint('BOTTOMRIGHT', tblBase.frame, 'TOPRIGHT', -5, -30)
    f:SetShown(true)
    self.tblFrame.frame = f
end
function whatsnew:CreateTopFrame()
    local appIconButton = CreateFrame('Button', 'GR_BASE_APPICON', self.tblFrame.frame)
    appIconButton:SetSize(32, 32)
    appIconButton:SetPoint('TOPLEFT', 5, -5)
    appIconButton:SetNormalTexture(GR.icon)
    appIconButton:SetShown(true)

    -- Title text
    local titleText = self.tblFrame.frame:CreateFontString(nil, 'OVERLAY')
    titleText:SetFont(DEFAULT_FONT, 14, 'OUTLINE')
    titleText:SetPoint('TOP', 0, -5)
    titleText:SetText(L['TITLE'])
    titleText:SetShown(true)

    -- Close Button
    local closeButton = CreateFrame('Button', 'GR_BASE_CLOSE', self.tblFrame.frame)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint('TOPRIGHT', -5, -5)
    closeButton:SetNormalTexture(ICON_PATH..'GR_Exit')
    closeButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    closeButton:SetScript('OnClick', function()
        if self.startUpWhatsNew then
            self.startUpWhatsNew = false
            self:SetShown(false)
        else ns.win.home:SetShown(true) end
    end)
    closeButton:SetScript('OnEnter', function() ns.code:createTooltip("Close What's New?") end)
    closeButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    closeButton:SetShown(true)
end
function whatsnew:CreateBodyFrame()
    local title = self.tblFrame.frame:CreateFontString(nil, 'OVERLAY')
    title:SetFont(SKURRI_FONT, 30, 'OUTLINE')
    title:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 0, -30)
    title:SetPoint('TOPRIGHT', self.tblFrame.frame, 'TOPRIGHT', 0, -30)
    title:SetJustifyH('CENTER')
    title:SetText(self.title)
    title:SetShown(true)

    local showWhatsNew = true
    if type(ns.gSettings.showWhatsNew) == "boolean" then showWhatsNew = ns.gSettings.showWhatsNew or false end
    local checkbox = CreateFrame('CheckButton', 'GR_BASE_checkbox', self.tblFrame.frame, 'UICheckButtonTemplate')
    checkbox:SetPoint('BOTTOMRIGHT', ns.win.base.tblFrame.frame, 'BOTTOMRIGHT', -5, 5)
    checkbox:SetSize(20, 20)
    checkbox:SetChecked(showWhatsNew)
    checkbox:SetScript('OnClick', function() ns.global.showWhatsNew = not ns.global.showWhatsNew end)

    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.text:SetPoint('RIGHT', checkbox, 'LEFT', -5, 0)
    checkbox.text:SetText('Show when new versions are available')

    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Fill')
    inline:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -5)
    inline:SetPoint('BOTTOMRIGHT', checkbox, 'BOTTOMRIGHT', -5, 20)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline

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
end
whatsnew:Init()