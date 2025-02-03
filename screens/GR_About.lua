local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.about = {}
local about = ns.about

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    about:SetShown(false)
end

function about:Init()
    self.tblFrame = {}
end
function about:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function about:SetShown(val)
    local tblBase = ns.base.tblFrame

    if not val and (not self.tblFrame or not self.tblFrame.frame) then return
    elseif not val and not about:IsShown() then return
    elseif not val then
        ns.frames:ResetFrame(self.tblFrame.frame)
        self.tblFrame.frame:Hide()

        ns.status:SetText('')
        tblBase.aboutButton:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
        return
    end

    self:Init()
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    tblBase.frame:SetSize(500, 450)
    tblBase.back:SetShown(true)

    tblBase.aboutButton:GetNormalTexture():SetVertexColor(0, 1, 0, 1)
    ns.status:SetText(L["COPY_LINK_MESSAGE"])

    self:CreateBaseFrame()
    self:CreateTitleFrame()
    self:CreateAddonLinks()
    self:CreateDonationLinks()
end
function about:CreateBaseFrame()
    local tblBase = ns.base.tblFrame

    local f = ns.frames:CreateFrame('Frame', 'GR_ABOUT_FRAME', tblBase.frame, 'BackdropTemplate')
    f:SetPoint('TOPLEFT', tblBase.icon, 'BOTTOMLEFT', 5, -5)
    f:SetPoint('BOTTOMRIGHT', tblBase.status, 'TOPRIGHT', -5, 5)
    f:SetFrameStrata('DIALOG')
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:EnableMouse(false)
    f:SetShown(true)
    self.tblFrame.frame = f

    --* What's New Button
    local whatsNew = ns.frames:CreateFrame('Button', 'GR_ABOUT_WHATS_NEW', f, 'BackdropTemplate')
    whatsNew:SetPoint('BOTTOM', f, 'BOTTOM', 0, 5)
    whatsNew:SetSize(150, 25)
    whatsNew:SetText(L['GEN_WHATS_NEW'])
    whatsNew:SetScript('OnClick', function(self)
        ns.base:SetShown(false)
        ns.whatsnew.returnToMain = true
        ns.whatsnew:SetShown(true)
    end)
end
function about:CreateTitleFrame()
    local f = self.tblFrame.frame

    local tFrame = ns.frames:CreateFrame('Frame', 'GR_ABOUT_TITLE_FRAME', f, 'BackdropTemplate')
    tFrame:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -5)
    tFrame:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -5, -5)
    tFrame:SetHeight(65)
    tFrame:SetBackdropColor(0, 0, 0, 0)
    tFrame:SetBackdropBorderColor(1, 1, 1, 0)
    tFrame:EnableMouse(false)
    tFrame:SetShown(true)
    self.tblFrame.tFrame = tFrame

    local version = tFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    version:SetPoint('TOPLEFT', tFrame, 'TOPLEFT', 5, -5)
    version:SetTextColor(1, 1, 1, 1)
    version:SetText('Author: Moonfury (Dalaran-US)')

    local donation = tFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    donation:SetPoint('TOPLEFT', version, 'BOTTOMLEFT', 0, -5)
    donation:SetTextColor(1, 1, 1, 1)
    donation:SetJustifyH('LEFT')
    donation:SetText(L["DONATION_MESSAGE"])
end
function about:CreateAddonLinks()
    local f = self.tblFrame.tFrame

    local linkFrame = ns.frames:CreateFrame('Frame', 'GR_ABOUT_LINK_FRAME', f, 'BackdropTemplate')
    linkFrame:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 0, -5)
    linkFrame:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, -150)
    linkFrame:SetBackdropColor(0, 0, 0, 0)
    linkFrame:SetBackdropBorderColor(1, 1, 1, 1)
    linkFrame:EnableMouse(false)
    linkFrame:SetShown(true)
    self.tblFrame.linkFrame = linkFrame

    local linkTitle = linkFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    linkTitle:SetPoint('TOPLEFT', linkFrame, 'TOPLEFT', 5, 3)
    linkTitle:SetTextColor(1, 1, 0, 1)
    linkTitle:SetText('Addon Links:')
    linkTitle:SetShown(true)

    --* GitHub Label
    local gitHub = linkFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    gitHub:SetPoint('TOPLEFT', linkTitle, 'BOTTOMLEFT', 10, -5)
    gitHub:SetTextColor(1, 1, 1, 1)
    gitHub:SetText('GitHub:')
    gitHub:SetShown(true)

    --* GitHub EditBox
    local gitHubEditBox = CreateFrame('EditBox', 'GR_ABOUT_GITHUB', f, "InputBoxTemplate")
    gitHubEditBox:SetPoint('TOPLEFT', gitHub, 'BOTTOMLEFT', 0, 0)
    gitHubEditBox:SetSize(450, 20)
    gitHubEditBox:SetText(ns.GITHUB)
    gitHubEditBox:SetShown(true)
    gitHubEditBox:SetScript('OnEnter', function(self)
        gitHubEditBox:SetFocus()
        gitHubEditBox:HighlightText()
     end)
    gitHubEditBox:SetScript('OnMouseUp', function(self)
        gitHubEditBox:SetFocus()
        gitHubEditBox:HighlightText()
    end)
    gitHubEditBox:SetScript('OnEditFocusLost', function(self)
        self:HighlightText(0, 0) -- Remove highlight by unselecting text
    end)
    gitHubEditBox:SetScript('OnTextChanged', function(self)
        if not gitHubEditBox:HasFocus() then return end

        gitHubEditBox:SetText(ns.GITHUB)
        gitHubEditBox:HighlightText()
    end)

    --* Discord Label
    local discord = linkFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    discord:SetPoint('TOPLEFT', gitHubEditBox, 'BOTTOMLEFT', 0, -5)
    discord:SetTextColor(1, 1, 1, 1)
    discord:SetText('Discord:')
    discord:SetShown(true)

    --* Discord EditBox
    local discordEditBox = CreateFrame('EditBox', 'GR_ABOUT_DISCORD', f, "InputBoxTemplate")
    discordEditBox:SetPoint('TOPLEFT', gitHubEditBox, 'BOTTOMLEFT', 0, -20)
    discordEditBox:SetSize(450, 20)
    discordEditBox:SetText(ns.DISCORD)
    discordEditBox:ClearFocus()
    discordEditBox:SetShown(true)
    discordEditBox:SetScript('OnEnter', function(self)
        discordEditBox:SetFocus()
        discordEditBox:HighlightText()
     end)
    discordEditBox:SetScript('OnMouseUp', function(self)
        discordEditBox:SetFocus()
        discordEditBox:HighlightText()
    end)
    discordEditBox:SetScript('OnEditFocusLost', function(self)
        self:HighlightText(0, 0) -- Remove highlight by unselecting text
    end)
    discordEditBox:SetScript('OnTextChanged', function(self)
        if not discordEditBox:HasFocus() then return end

        discordEditBox:SetText(ns.DISCORD)
        discordEditBox:HighlightText()
    end)

    --* CurseForge Label
    local curseForge = linkFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    curseForge:SetPoint('TOPLEFT', discordEditBox, 'BOTTOMLEFT', 0, -5)
    curseForge:SetTextColor(1, 1, 1, 1)
    curseForge:SetText('CurseForge:')

    --* CurseForge EditBox
    local curseForgeEditBox = CreateFrame('EditBox', 'GR_ABOUT_CURSEFORGE', f, "InputBoxTemplate")
    curseForgeEditBox:SetPoint('TOPLEFT', discordEditBox, 'BOTTOMLEFT', 0, -20)
    curseForgeEditBox:SetSize(450, 20)
    curseForgeEditBox:SetText(ns.CURSE_FORGE)
    curseForgeEditBox:ClearFocus()
    curseForgeEditBox:SetShown(true)
    curseForgeEditBox:SetScript('OnEnter', function(self)
        curseForgeEditBox:SetFocus()
        curseForgeEditBox:HighlightText()
     end)
    curseForgeEditBox:SetScript('OnMouseUp', function(self)
        curseForgeEditBox:SetFocus()
        curseForgeEditBox:HighlightText()
    end)
    curseForgeEditBox:SetScript('OnEditFocusLost', function(self)
        self:HighlightText(0, 0) -- Remove highlight by unselecting text
    end)
    curseForgeEditBox:SetScript('OnTextChanged', function(self)
        if not curseForgeEditBox:HasFocus() then return end

        curseForgeEditBox:SetText(ns.CURSE_FORGE)
        curseForgeEditBox:HighlightText()
    end)
end
function about:CreateDonationLinks()
    local f = self.tblFrame.tFrame

    local linkFrame = ns.frames:CreateFrame('Frame', 'GR_ABOUT_DONATION_FRAME', f, 'BackdropTemplate')
    linkFrame:SetPoint('TOPLEFT', self.tblFrame.linkFrame, 'BOTTOMLEFT', 0, -100)
    linkFrame:SetPoint('BOTTOMRIGHT', self.tblFrame.linkFrame, 'BOTTOMRIGHT', 0, -5)
    linkFrame:SetBackdropColor(0, 0, 0, 0)
    linkFrame:SetBackdropBorderColor(1, 1, 1, 1)
    linkFrame:EnableMouse(false)
    linkFrame:SetShown(true)
    self.tblFrame.linkFrame = linkFrame

    local linkTitle = linkFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    linkTitle:SetPoint('TOPLEFT', linkFrame, 'TOPLEFT', 5, 3)
    linkTitle:SetTextColor(1, 1, 0, 1)
    linkTitle:SetText('Donation Links:')
    linkTitle:SetShown(true)

    --* Patreon Label
    local patreon = linkFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    patreon:SetPoint('TOPLEFT', linkTitle, 'BOTTOMLEFT', 10, -5)
    patreon:SetTextColor(1, 1, 1, 1)
    patreon:SetText('Patreon:')
    patreon:SetShown(true)

    --* Patreon EditBox
    local patreonEditBox = CreateFrame('EditBox', 'GR_ABOUT_PATREON', f, "InputBoxTemplate")
    patreonEditBox:SetPoint('TOPLEFT', patreon, 'BOTTOMLEFT', 0, 0)
    patreonEditBox:SetSize(450, 20)
    patreonEditBox:SetText(ns.PATREON)
    patreonEditBox:SetShown(true)
    patreonEditBox:SetScript('OnEnter', function(self)
        patreonEditBox:SetFocus()
        patreonEditBox:HighlightText()
     end)
    patreonEditBox:SetScript('OnMouseUp', function(self)
        patreonEditBox:SetFocus()
        patreonEditBox:HighlightText()
    end)
    patreonEditBox:SetScript('OnEditFocusLost', function(self)
        self:HighlightText(0, 0) -- Remove highlight by unselecting text
    end)
    patreonEditBox:SetScript('OnTextChanged', function(self)
        if not patreonEditBox:HasFocus() then return end

        patreonEditBox:SetText(ns.PATREON)
        patreonEditBox:HighlightText()
    end)

    --*Buy Me A Coffee Label
    local coffee = linkFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    coffee:SetPoint('TOPLEFT', patreonEditBox, 'BOTTOMLEFT', 0, -5)
    coffee:SetTextColor(1, 1, 1, 1)
    coffee:SetText('Buy Me A Coffee:')
    coffee:SetShown(true)

    --* Buy Me A Coffee EditBox
    local coffeeEditBox = CreateFrame('EditBox', 'GR_ABOUT_COFFEE', f, "InputBoxTemplate")
    coffeeEditBox:SetPoint('TOPLEFT', patreonEditBox, 'BOTTOMLEFT', 0, -20)
    coffeeEditBox:SetSize(450, 20)
    coffeeEditBox:SetText(ns.BUY_ME_COFFEE)
    coffeeEditBox:ClearFocus()
    coffeeEditBox:SetShown(true)
    coffeeEditBox:SetScript('OnEnter', function(self)
        coffeeEditBox:SetFocus()
        coffeeEditBox:HighlightText()
     end)
    coffeeEditBox:SetScript('OnMouseUp', function(self)
        coffeeEditBox:SetFocus()
        coffeeEditBox:HighlightText()
    end)
    coffeeEditBox:SetScript('OnEditFocusLost', function(self)
        self:HighlightText(0, 0) -- Remove highlight by unselecting text
    end)
    coffeeEditBox:SetScript('OnTextChanged', function(self)
        if not coffeeEditBox:HasFocus() then return end

        coffeeEditBox:SetText(ns.BUY_ME_COFFEE)
        coffeeEditBox:HighlightText()
    end)
end