local _, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.win.classic = {}
local classic = ns.win.classic

function classic:Init()
    self.tblFrame = {}
end

function classic:SetShown(val)
    if not val then
        if self.tblFrame.frame then
            self.tblFrame.frame:SetShown(false)
        end
        return
    end

    self:CreateFrame()
    if self.tblFrame.frame then
        self.tblFrame.frame:SetShown(true)
    end
end

function classic:CreateFrame()
    if self.tblFrame.frame then return end

    local f = CreateFrame('Frame', 'GR_Base', UIParent, 'BackdropTemplate')
    f:SetSize(530, 140)
    f:SetPoint('CENTER')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetShown(false)  -- Initially hidden until explicitly shown

    local btnClose = CreateFrame('Button', 'GR_Close', f, 'UIPanelCloseButton')
    btnClose:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 0, 0)
    btnClose:SetScript('OnClick', function() f:SetShown(false) end)

    local title = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    title:SetPoint('TOPLEFT', f, 'TOPLEFT', 10, -10)
    title:SetText('Guild Recruiter')

    local txtFrame = CreateFrame('Frame', 'GR_TextFrame', f, 'BackdropTemplate')
    txtFrame:SetSize(520, 100)
    txtFrame:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -30)
    txtFrame:SetBackdrop(BackdropTemplate())

    local txt = txtFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    txt:SetPoint('TOPLEFT', txtFrame, 'TOPLEFT', -20, -10)
    txt:SetText([[
        This version of Guild Recruiter is not compatible with Classic/Cata WoW.

        Please go to the CurseForge page to download the correct version.
        Right click on Guild Recuriter then click on "Release Type" and finally "Beta."
        
        Then type /rl (or /reload) in the chat window to reload the UI.
    ]])

    self.tblFrame.frame = f
end

-- Initialize the frame system
classic:Init()
