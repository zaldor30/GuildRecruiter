local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.whatsnew = {}
local whatsnew, wn = ns.whatsnew, {}

local function obsCLOSE_SCREENS() whatsnew:CloseWhatsNew() end

function whatsnew:ShowWhatsNew()
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)
    wn.title, wn.body, wn.height, wn.update = ns.ds:WhatsNew()

    ns.screen.tblFrame.titleFrame:SetShown(false)
    ns.screen.tblFrame.statusBar:SetShown(false)
    ns.screen.tblFrame.frame:SetShown(true)

    wn:BuildWhatsNew()
end
function whatsnew:CloseWhatsNew()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)

    wn.tblFrame.frame:SetShown(false)
    wn.tblFrame.inline:ReleaseChildren()
    wn.tblFrame.inline:Release()

    ns.screen.tblFrame.titleFrame:SetShown(true)
    ns.screen.tblFrame.statusBar:SetShown(true)
    ns.screen.tblFrame.frame:SetShown(false)
end

function wn:Init()
    self.tblFrame = {}

    self.title = nil
    self.body = nil
    self.height = 300
end
function wn:BuildWhatsNew() 
    local tblFrame = self.tblFrame
    local tblScreen = ns.screen.tblFrame

    tblScreen.frame:SetSize(tblScreen.frame:GetWidth(), self.height)

    local f = tblFrame.frame or CreateFrame('Frame', 'GR_WhatsNew', tblScreen.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:SetPoint('TOPLEFT', tblScreen.frame, 'TOPLEFT', 10, -15)
    f:SetPoint('BOTTOMRIGHT', tblScreen.frame, 'TOPRIGHT', -5, -30)
    f:SetShown(true)
    tblFrame.frame = f

    local appIconButton = CreateFrame('Button', 'GR_BASE_APPICON', f)
    appIconButton:SetSize(32, 32)
    appIconButton:SetPoint('TOPLEFT', 5, -5)
    appIconButton:SetNormalTexture(GRADDON.icon)
    appIconButton:SetShown(true)

    -- Title text
    local titleText = f:CreateFontString(nil, 'OVERLAY')
    titleText:SetFont(DEFAULT_FONT, 14, 'OUTLINE')
    titleText:SetPoint('TOP', 0, -5)
    titleText:SetText(GRADDON.title)
    titleText:SetShown(true)

    -- Close Button
    local closeButton = CreateFrame('Button', 'GR_BASE_CLOSE', f)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint('TOPRIGHT', -5, -5)
    closeButton:SetNormalTexture(ICON_PATH..'GR_Exit')
    closeButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    closeButton:SetScript('OnClick', function()
        whatsnew:CloseWhatsNew()
    end)
    closeButton:SetScript('OnEnter', function() ns.code:createTooltip("Close What's New?") end)
    closeButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    closeButton:SetShown(true)

    local title = f:CreateFontString(nil, 'OVERLAY')
    title:SetFont(SKURRI_FONT, 30, 'OUTLINE')
    title:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, -30)
    title:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 0, -30)
    title:SetJustifyH('CENTER')
    title:SetText(wn.title)
    title:SetShown(true)

    local checkbox = CreateFrame('CheckButton', 'GR_BASE_checkbox', f, 'UICheckButtonTemplate')
    checkbox:SetPoint('BOTTOMRIGHT', tblScreen.frame, 'BOTTOMRIGHT', -5, 5)
    checkbox:SetSize(20, 20)
    checkbox:SetChecked(true)
    checkbox:SetScript('OnClick', function()
        if checkbox:GetChecked() then
            ns.dbGlobal.showUpdates = false else ns.dbGlobal.showUpdates = true end
    end)

    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.text:SetPoint('RIGHT', checkbox, 'LEFT', -5, 0)
    checkbox.text:SetText('Do not show again')

    local inline = tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Fill')
    inline:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -5)
    inline:SetPoint('BOTTOMRIGHT', checkbox, 'BOTTOMRIGHT', -5, 20)
    tblFrame.inline = inline

    local scroll = aceGUI:Create('ScrollFrame')
    scroll:SetLayout('fill')
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    inline:AddChild(scroll)

    local body = aceGUI:Create('Label')
    body:SetFont(DEFAULT_FONT, 14, 'OUTLINE')
    body:SetColor(1, 1, 1)
    body:SetText(wn.body)
    body:SetJustifyH('LEFT')
    body:SetJustifyV('TOP')
    body:SetFullWidth(true)
    body:SetFullHeight(true)
    scroll:AddChild(body)

    if not GRADDON.debug then ns.dbGlobal.version = ns.ds.GR_VERSION end
end
wn:Init()