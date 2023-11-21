local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

local aceGUI = LibStub("AceGUI-3.0")

ns.screens.about = {}
local about = ns.screens.about

local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)

    ns.screens.base.tblFrame.backButton:SetShown(false)

    if not about.tblFrame.frame or not about.tblFrame.inline then return end
    about.tblFrame.frame:SetShown(false)
    about.tblFrame.inline.frame:Hide()

    local tblFrame = about.tblFrame or {}
    if tblFrame.frame then
        tblFrame.frame:SetShown(false)
        tblFrame.inline.frame:SetShown(false)
    end
end

function about:Init()
    self.tblFrame = {}
end
function about:StartUp()
    self.tblFrame = self.tblFrame or {}
    self.tblFrame.controls = self.tblFrame.controls or {}

    local tblScreen = ns.screens.base.tblFrame

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    tblScreen.frame:SetSize(500, 400)
    tblScreen.backButton:SetShown(true)

    self:BuildBaseFrame()
    self:BuildTitleSection()
    self:BuildLinkSection()
end
function about:BuildBaseFrame()
    local tblScreen = ns.screens.base.tblFrame

    local f = self.tblFrame.frame or CreateFrame('Frame', 'GR_ABOUT_FRAME', tblScreen.frame, 'BackdropTemplate')
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
        self.tblFrame.inline.frame:Show()
    end

    -- Ace GUI Frame for Ace Controls
    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline
end
function about:BuildTitleSection()
    local inline = self.tblFrame.inline

    local icon = aceGUI:Create('Icon')
    icon:SetImage(ICON_PATH..'GR_Logo')
    icon:SetImageSize(32, 32)
    icon:SetRelativeWidth(.1)
    inline:AddChild(icon)

    local lblTitle = aceGUI:Create('Label')
    lblTitle:SetText(L['TITLE']..'\n'..ns.code:cText('FFFFFFFF', 'Version: '..GR.version..' by '..GR.author..' (Dalaran-US)'))
    lblTitle:SetRelativeWidth(.9)
    lblTitle:SetFontObject('GameFontNormalLarge')
    lblTitle:SetColor(1, .82, 0, 1)
    inline:AddChild(lblTitle)

    local lblDesc = aceGUI:Create('Label')
    lblDesc:SetText(L['DONATION_MESSAGE'])
    lblDesc:SetRelativeWidth(1)
    lblDesc:SetFontObject('GameFontNormal')
    lblDesc:SetColor(1, 1, 1, 1)
    inline:AddChild(lblDesc)
end
function about:BuildLinkSection()
    local inline = self.tblFrame.inline

    local lblCurseForge = aceGUI:Create('Label')
    lblCurseForge:SetText('CurseForge:')
    lblCurseForge:SetRelativeWidth(.3)
    lblCurseForge:SetFontObject('GameFontNormal')
    lblCurseForge:SetColor(1, 1, 0, 1)
    inline:AddChild(lblCurseForge)

    local editCurseForge = aceGUI:Create('EditBox')
    editCurseForge:SetText('https://www.curseforge.com/wow/addons/guild-recruiter')
    editCurseForge:SetRelativeWidth(.7)
    inline:AddChild(editCurseForge)

    local lblGitHub = aceGUI:Create('Label')
    lblGitHub:SetText('GitHub:')
    lblGitHub:SetRelativeWidth(.3)
    lblGitHub:SetFontObject('GameFontNormal')
    lblGitHub:SetColor(1, 1, 0, 1)
    inline:AddChild(lblGitHub)

    local editGitHub = aceGUI:Create('EditBox')
    editGitHub:SetText('https://github.com/zaldor30/GuildRecruiter')
    editGitHub:SetRelativeWidth(.7)
    inline:AddChild(editGitHub)

    local lblDiscord = aceGUI:Create('Label')
    lblDiscord:SetText('Discord:')
    lblDiscord:SetRelativeWidth(.3)
    lblDiscord:SetFontObject('GameFontNormal')
    lblDiscord:SetColor(1, 1, 0, 1)
    inline:AddChild(lblDiscord)

    local editDiscord = aceGUI:Create('EditBox')
    editDiscord:SetText('https://discord.gg/ZtS6Q2sKRH')
    editDiscord:SetRelativeWidth(.7)
    inline:AddChild(editDiscord)

    local lblPatreon = aceGUI:Create('Label')
    lblPatreon:SetText('Patreon:')
    lblPatreon:SetRelativeWidth(1)
    lblPatreon:SetFontObject('GameFontNormal')
    lblPatreon:SetColor(1, 1, 0, 1)
    inline:AddChild(lblPatreon)

    local PatreonLink = aceGUI:Create('EditBox')
    PatreonLink:SetText('https://www.patreon.com/AlwaysBeConvoking')
    PatreonLink:SetRelativeWidth(1)
    inline:AddChild(PatreonLink)

    local lblBMC = aceGUI:Create('Label')
    lblBMC:SetText('Buy Me a Coffee:')
    lblBMC:SetRelativeWidth(1)
    lblBMC:SetFontObject('GameFontNormal')
    lblBMC:SetColor(1, 1, 0, 1)
    inline:AddChild(lblBMC)

    local editBMC = aceGUI:Create('EditBox')
    editBMC:SetText('https://bmc.link/alwaysbeconvoking')
    editBMC:SetRelativeWidth(1)
    inline:AddChild(editBMC)

    local btnMinor = aceGUI:Create('Button')
    btnMinor:SetText("What's New? in v"..ns.ds.grVersion)
    btnMinor:SetCallback('OnClick', function() ns.screens.whatsnew:StartUp() end)
    inline:AddChild(btnMinor)
end
about:Init()