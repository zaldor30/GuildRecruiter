local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.about = {}
local about = ns.about

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    about:SetShown(false)
end

function about:Init()
end
function about:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function about:SetShown(val)
    if not self.tblFrame or not self.tblFrame.frame then return
    elseif not val and not about:IsShown() then return
    elseif not val then
        self.tblFrame.frame:Hide()
    end
end