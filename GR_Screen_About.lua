local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.about = {}
local about = ns.about
function about:StartAboutScreen()
    ns.screen:ResetMain()
    ns.screen.iconBack:Show()
    ns.screen.iconReset:Hide()
    ns.screen.fMain:SetSize(500, 335)

    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetWidth(ns.screen.fMain:GetWidth() - 20)
    inline:SetHeight(ns.screen.fMain:GetHeight() - 20)
    ns.screen.aMain:AddChild(inline)

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
    lblCurseForge:SetRelativeWidth(.2)
    lblCurseForge:SetFontObject('GameFontNormal')
    lblCurseForge:SetColor(1, 1, 0, 1)
    inline:AddChild(lblCurseForge)

    local editCurseForge = aceGUI:Create('EditBox')
    editCurseForge:SetText('https://www.curseforge.com/wow/addons/guild-recruiter')
    editCurseForge:SetRelativeWidth(.8)
    inline:AddChild(editCurseForge)

    local lblGitHub = aceGUI:Create('Label')
    lblGitHub:SetText('CurseForge: ')
    lblGitHub:SetRelativeWidth(.2)
    lblGitHub:SetFontObject('GameFontNormal')
    lblGitHub:SetColor(1, 1, 0, 1)
    inline:AddChild(lblGitHub)

    local editGitHub = aceGUI:Create('EditBox')
    editGitHub:SetText('https://github.com/zaldor30/GuildRecruiter')
    editGitHub:SetRelativeWidth(.8)
    inline:AddChild(editGitHub)

    local lblDiscord = aceGUI:Create('Label')
    lblDiscord:SetText('CurseForge: ')
    lblDiscord:SetRelativeWidth(.2)
    lblDiscord:SetFontObject('GameFontNormal')
    lblDiscord:SetColor(1, 1, 0, 1)
    inline:AddChild(lblDiscord)

    local editDiscord = aceGUI:Create('EditBox')
    editDiscord:SetText('https://discord.gg/ZtS6Q2sKRH')
    editDiscord:SetRelativeWidth(.8)
    inline:AddChild(editDiscord)

    local lblBMC = aceGUI:Create('Label')
    lblBMC:SetText('Buy Me a Coffee: ')
    lblBMC:SetRelativeWidth(.2)
    lblBMC:SetFontObject('GameFontNormal')
    lblBMC:SetColor(1, 1, 0, 1)
    inline:AddChild(lblBMC)

    local editBMC = aceGUI:Create('EditBox')
    editBMC:SetText('https://bmc.link/alwaysbeconvokingr')
    editBMC:SetRelativeWidth(.8)
    inline:AddChild(editBMC)
end