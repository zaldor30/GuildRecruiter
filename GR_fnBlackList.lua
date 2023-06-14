local _, ns = ... -- Namespace (myaddon, namespace)
local g = nil

local tblBlackList = {}
local POPUP_REASON, blName = "inputReason", nil
StaticPopupDialogs[POPUP_REASON] = {
    text = "Enter a reason:",
    button1 = "OK",
    button2 = "Cancel",
    OnAccept = function(self)
        local value = self.editBox:GetText()
        value = strlen(value) > 0 and value or 'No reason'

        tblBlackList = g.blackList or {}
        tblBlackList[blName] = { reason = value, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), markedForDelete = false }
        g.blackList = tblBlackList
        ns.Analytics:add('Black_Listed')
        ns.code:consoleOut(blName..' was added to the black list with \"'..value..'\" as a reason.')
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    hasEditBox = true,
    maxLetters = 255,
    -- You can add more properties as needed
}

ns.BlackList = {}
local blackList = ns.BlackList
function blackList:Init()
end
function blackList:add(name)
    if not name then return end
    g = ns.dbBL.global

    blName = name

    tblBlackList = g.blackList or {}
    if tblBlackList[blName] then
        local dateTable = date("*t", tblBlackList[blName].dateBlackList)
        local formattedTime = string.format("%02d/%02d/%04d", dateTable.month, dateTable.day, dateTable.year)
        ns.code:consoleOut(blName..' is already black listed with \"'..tblBlackList[blName].reason..'\" as a reason on '..formattedTime..'.')
        return
    end
    StaticPopup_Show(POPUP_REASON)
end
function blackList:IsOnBlackList(name)
    local realm = '-'..GetRealmName()
    name = gsub(name, realm, '')
    g = ns.dbBL.global
    tblBlackList = g.blackList or {}
    return (tblBlackList[name] and not tblBlackList[name].markedForDelete) and true or false
end
blackList:Init()