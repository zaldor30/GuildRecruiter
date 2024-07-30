local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.win.scanner = {}
local scanner = ns.win.scanner

local function obsCLOSE_SCREENS_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    local tblBase, tblFrame = ns.win.base.tblFrame, scanner.tblFrame
    if not tblBase.frame then return end

    tblBase.backButton:SetShown(false)
    tblBase.resetButton:SetShown(false)
    tblBase.compactButton:SetShown(false)
    ns.statusText:SetText('')

    if not tblFrame.frame then return end
    tblFrame.frame:SetShown(false)
    tblFrame.inline.frame:Hide()
end
local function CallBackWhoListUpdate()
end

function scanner:Init()
    self.tblScanner = {}
end
function scanner:SetShown(val)
    local tblBase = ns.win.base.tblFrame

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCREENS_SCANNER)

    self.tblScanner = {
        isCompact = self.tblScanner.isCompact or false,
        tblWho = self.tblScanner.tblWho and self.tblScanner.tblWho or {},
        tblInvites = self.tblScanner.tblInvites and self.tblScanner.tblInvites or {},
        tblFilter = self.tblScanner.tblFilter or self:CreateFilters(),
        totalFilters = self.tblScanner.totalFilters or 0,
        whisperMessage = tblBase.inviteMessage,
        minLevel = ns.pSettings.minLevel or MAX_CHARACTER_LEVEL - 5,
        maxLevel = ns.pSettings.maxLevel or MAX_CHARACTER_LEVEL,
        scanWaitTime = ns.gSettings.scanWaitTime or ns.core.addonSettings.global.settings.scanWaitTime or 6,
    }

    tblBase.backButton:SetShown(true)
    tblBase.resetButton:SetShown(true)
    tblBase.compactButton:SetShown(true)
    ns.win.base:SetShown(true)

    -- ToDo: Compact Mode
end

function scanner:CreateFilters()
end
scanner:Init()