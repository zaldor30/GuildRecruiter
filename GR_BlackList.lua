local _, ns = ... -- Namespace (myaddon, namespace)
local blName = nil
local tblBlackList = {}

local POPUP_REASON = "inputReason"
StaticPopupDialogs[POPUP_REASON] = {
    text = "Enter a value:",
    button1 = "OK",
    button2 = "Cancel",
    OnAccept = function(self)
        local value = self.editBox:GetText()
        value = (value and value ~= '') and value or 'No reason'

        tblBlackList = ns.dbBl.BlackList or {}
        tblBlackList[blName] = { reason = value, whoDidIt = UnitGUID('player'), dateBlackList = GetTime() }
        ns.dbBl.BlackList = tblBlackList
        ns.analyticsAdd('BlackListed')
        ns.code.consoleOut(blName..' was added to the black list with \"'..value..'\" as a reason.')
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    hasEditBox = true,
    maxLetters = 20,
    -- You can add more properties as needed
}
function ns:AddBlackList(name)
    blName = name
    StaticPopup_Show(POPUP_REASON)
end