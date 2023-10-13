local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.screen.about = {}
local about = ns.screen.about

-- Observer Call Backs
local function obsCLOSE_SCREENS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS)

    ns.screen.tblFrame.backButton:SetShown(false)

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
function about:EnterAboutScreen()
    self.tblFrame = self.tblFrame or {}
    self.tblFrame.controls = self.tblFrame.controls or {}

    local tblFrame = self.tblFrame
    local tblScreen = ns.screen.tblFrame
    if not tblScreen.frame then return end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS)

    tblScreen.frame:SetSize(500, 400)
    tblScreen.backButton:SetShown(true)

    if not self.tblFrame.frame then
        -- Base Regular Frame
        local f = CreateFrame('Frame', 'GR_ABOUT_FRAME', tblScreen.frame, 'BackdropTemplate')
        f:SetPoint('TOPLEFT', tblScreen.titleFrame, 'BOTTOMLEFT', -5, 20)
        f:SetPoint('BOTTOMRIGHT', tblScreen.statusBar, 'TOPRIGHT', 0, -5)
        f:SetBackdrop(BackdropTemplate())
        f:SetFrameStrata(DEFAULT_STRATA)
        f:SetBackdropColor(0, 0, 0, 0)
        f:SetBackdropBorderColor(1, 1, 1, 0)
        f:EnableMouse(false)
        self.tblFrame.frame = f
    elseif self.tblFrame.inline then
        self.tblFrame.inline:ReleaseChildren()
    end
    self.tblFrame.frame:SetShown(true)

    -- Ace GUI Frame for Ace Controls
    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 5, -5)
    inline:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline
    
    local icon = aceGUI:Create('Icon')
    icon:SetImage(ICON_PATH..'GR_Logo')
    icon:SetImageSize(32, 32)
    icon:SetRelativeWidth(.1)
    inline:AddChild(icon)

    local lblTitle = aceGUI:Create('Label')
    lblTitle:SetText(GRADDON.title)
    lblTitle:SetRelativeWidth(.9)
    lblTitle:SetFontObject('GameFontNormalLarge')
    lblTitle:SetColor(1, .82, 0, 1)
    inline:AddChild(lblTitle)

    local lblVersion = aceGUI:Create('Label')
    lblVersion:SetText('Version: '..GRADDON.version..' by '..GRADDON.author..' (Dalaran-US)')
    lblVersion:SetRelativeWidth(1)
    lblVersion:SetFontObject('GameFontNormal')
    lblVersion:SetColor(1, 1, 1, 1)
    inline:AddChild(lblVersion)

    local lblDesc = aceGUI:Create('Label')
    lblDesc:SetText('\nGuild Recruiter is an addon designed to assit Guild Masters and Officers with the chore of recruiting good guild members.')
    lblDesc:SetRelativeWidth(1)
    lblDesc:SetFontObject('GameFontNormal')
    lblDesc:SetColor(1, 1, 1, 1)
    inline:AddChild(lblDesc)

    local lblDesc2 = aceGUI:Create('Label')
    lblDesc2:SetText('\nSupport and information links Bellow:')
    lblDesc2:SetRelativeWidth(1)
    lblDesc2:SetFontObject('GameFontNormal')
    lblDesc2:SetColor(1, 1, 1, 1)
    inline:AddChild(lblDesc2)

    local lblCurseForge = aceGUI:Create('Label')
    lblCurseForge:SetText('CurseForge: ')
    lblCurseForge:SetRelativeWidth(.3)
    lblCurseForge:SetFontObject('GameFontNormal')
    lblCurseForge:SetColor(1, 1, 0, 1)
    inline:AddChild(lblCurseForge)

    local editCurseForge = aceGUI:Create('EditBox')
    editCurseForge:SetText('https://www.curseforge.com/wow/addons/guild-recruiter')
    editCurseForge:SetRelativeWidth(.7)
    inline:AddChild(editCurseForge)

    local lblGitHub = aceGUI:Create('Label')
    lblGitHub:SetText('GitHub: ')
    lblGitHub:SetRelativeWidth(.3)
    lblGitHub:SetFontObject('GameFontNormal')
    lblGitHub:SetColor(1, 1, 0, 1)
    inline:AddChild(lblGitHub)

    local editGitHub = aceGUI:Create('EditBox')
    editGitHub:SetText('https://github.com/zaldor30/GuildRecruiter')
    editGitHub:SetRelativeWidth(.7)
    inline:AddChild(editGitHub)

    local lblDiscord = aceGUI:Create('Label')
    lblDiscord:SetText('Discord: ')
    lblDiscord:SetRelativeWidth(.3)
    lblDiscord:SetFontObject('GameFontNormal')
    lblDiscord:SetColor(1, 1, 0, 1)
    inline:AddChild(lblDiscord)

    local editDiscord = aceGUI:Create('EditBox')
    editDiscord:SetText('https://discord.gg/ZtS6Q2sKRH')
    editDiscord:SetRelativeWidth(.7)
    inline:AddChild(editDiscord)

    local lblBMC = aceGUI:Create('Label')
    lblBMC:SetText('Buy Me a Coffee: ')
    lblBMC:SetRelativeWidth(.3)
    lblBMC:SetFontObject('GameFontNormal')
    lblBMC:SetColor(1, 1, 0, 1)
    inline:AddChild(lblBMC)

    local editBMC = aceGUI:Create('EditBox')
    editBMC:SetText('https://bmc.link/alwaysbeconvoking')
    editBMC:SetRelativeWidth(.7)
    inline:AddChild(editBMC)

    local btnMinor = aceGUI:Create('Button')
    btnMinor:SetText("What's New? in v"..ns.ds.GR_VERSION)
    btnMinor:SetCallback('OnClick', function() ns.whatsnew:ShowWhatsNew() end)
    inline:AddChild(btnMinor)
end
about:Init()