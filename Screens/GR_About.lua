local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local aceGUI = LibStub("AceGUI-3.0")

ns.win.about = {}
local about = ns.win.about

local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)
    about:SetShown(false)
end

function about:Init()
    self.tblFrame = {}
end
function about:SetShown(val)
    local tblBase = ns.win.base.tblFrame

    if not val then
        tblBase.backButton:SetShown(false)
        self.tblFrame.inline:ReleaseChildren()
        self.tblFrame.inline.frame:Hide()
        self.tblFrame.frame:Hide()
        ns.statusText:SetText('')
        ns.win.base.tblFrame.aboutButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
        return
    end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    tblBase.frame:SetSize(500, 365)
    tblBase.backButton:SetShown(true)
    ns.win.base:SetShown(true)

    ns.win.base.tblFrame.aboutButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)
    ns.statusText:SetText('Links are copyable. Highlight link and copy (CTRL+C).')

    self:CreateBaseFrame()
    self:CreateTitleFrame()
    self:CreateLinkSection()
end
function about:CreateBaseFrame()
    local tblBase = ns.win.base.tblFrame

    local f = self.tblFrame.frame or CreateFrame('Frame', 'GR_ABOUT_FRAME', tblBase.frame, 'BackdropTemplate')
    f:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 20)
    f:SetPoint('BOTTOMRIGHT', tblBase.statusBar, 'TOPRIGHT', 0, -5)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:EnableMouse(false)
    f:SetShown(true)
    self.tblFrame.frame = f

    -- Ace GUI Frame for Ace Controls
    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline
end
function about:CreateTitleFrame()
    local icon = aceGUI:Create('Icon')
    icon:SetImage(ICON_PATH..'GR_Logo')
    icon:SetImageSize(32, 32)
    icon:SetRelativeWidth(.1)
    self.tblFrame.inline:AddChild(icon)

    local lblTitle = aceGUI:Create('Label')
    lblTitle:SetText(L['TITLE']..(GR.isTest and ' ('..GR.testLevel..')')..'\n'..ns.code:cText('FFFFFFFF', 'Version: '..GR.version..' by '..GR.author..' (Dalaran-US)'))
    lblTitle:SetRelativeWidth(.9)
    lblTitle:SetFontObject('GameFontNormalLarge')
    lblTitle:SetColor(1, .82, 0, 1)
    self.tblFrame.inline:AddChild(lblTitle)

    local lblDesc = aceGUI:Create('Label')
    lblDesc:SetText(L['DONATION_MESSAGE'])
    lblDesc:SetRelativeWidth(1)
    lblDesc:SetFontObject('GameFontNormal')
    lblDesc:SetColor(1, 1, 1, 1)
    self.tblFrame.inline:AddChild(lblDesc)
end
function about:CreateLinkSection()
    local lblCurseForge = aceGUI:Create('Label')
    lblCurseForge:SetText('CurseForge:')
    lblCurseForge:SetRelativeWidth(.2)
    lblCurseForge:SetFontObject('GameFontNormal')
    lblCurseForge:SetColor(1, 1, 0, 1)
    self.tblFrame.inline:AddChild(lblCurseForge)

    local editCurseForge = aceGUI:Create('EditBox')
    editCurseForge:SetText('https://curseforge.com/wow/addons/guild-recruiter')
    editCurseForge:SetRelativeWidth(.7)
    self.tblFrame.inline:AddChild(editCurseForge)

    local lblGitHub = aceGUI:Create('Label')
    lblGitHub:SetText('GitHub:')
    lblGitHub:SetRelativeWidth(.2)
    lblGitHub:SetFontObject('GameFontNormal')
    lblGitHub:SetColor(1, 1, 0, 1)
    self.tblFrame.inline:AddChild(lblGitHub)

    local editGitHub = aceGUI:Create('EditBox')
    editGitHub:SetText('https://github.com/zaldor30/GuildRecruiter')
    editGitHub:SetRelativeWidth(.7)
    self.tblFrame.inline:AddChild(editGitHub)

    local lblDiscord = aceGUI:Create('Label')
    lblDiscord:SetText('Discord:')
    lblDiscord:SetRelativeWidth(.2)
    lblDiscord:SetFontObject('GameFontNormal')
    lblDiscord:SetColor(1, 1, 0, 1)
    self.tblFrame.inline:AddChild(lblDiscord)

    local editDiscord = aceGUI:Create('EditBox')
    editDiscord:SetText('https://discord.gg/ZtS6Q2sKRH')
    editDiscord:SetRelativeWidth(.7)
    self.tblFrame.inline:AddChild(editDiscord)

    local lblPatreon = aceGUI:Create('Label')
    lblPatreon:SetText('Patreon:')
    lblPatreon:SetRelativeWidth(.2)
    lblPatreon:SetFontObject('GameFontNormal')
    lblPatreon:SetColor(1, 1, 0, 1)
    self.tblFrame.inline:AddChild(lblPatreon)

    local PatreonLink = aceGUI:Create('EditBox')
    PatreonLink:SetText('https://www.patreon.com/AlwaysBeConvoking')
    PatreonLink:SetRelativeWidth(.7)
    self.tblFrame.inline:AddChild(PatreonLink)

    local lblBMC = aceGUI:Create('Label')
    lblBMC:SetText('Buy Me a Coffee:')
    lblBMC:SetRelativeWidth(.2)
    lblBMC:SetFontObject('GameFontNormal')
    lblBMC:SetColor(1, 1, 0, 1)
    self.tblFrame.inline:AddChild(lblBMC)

    local editBMC = aceGUI:Create('EditBox')
    editBMC:SetText('https://bmc.link/alwaysbeconvoking')
    editBMC:SetRelativeWidth(.7)
    self.tblFrame.inline:AddChild(editBMC)

    local btnMinor = aceGUI:Create('Button')
    btnMinor:SetText("What's New? in v"..GR.version)
    btnMinor:SetCallback('OnClick', function() ns.win.whatsnew:SetShown(true) end)
    self.tblFrame.inline:AddChild(btnMinor)
end
about:Init()