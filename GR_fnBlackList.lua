local _, ns = ... -- Namespace (myaddon, namespace)

ns.BlackList = {}
local blackList = ns.BlackList
function blackList:Init()
    self.tblBlackList = nil
end
function blackList:add(name)
    if not name then return end

    local POPUP_REASON, blName = "inputReason", nil
    StaticPopupDialogs[POPUP_REASON] = {
        text = "Enter a reason:",
        button1 = "OK",
        button2 = "Cancel",
        OnAccept = function(data)
            local value = data.editBox:GetText()
            value = strlen(value) > 0 and value or 'No reason'

            ns.BlackList.tblBlackList[blName] = { reason = value, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), markedForDelete = false }
            ns.dbBL.blackList = ns.BlackList.tblBlackList
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

    local realm = '-'..GetRealmName()
    blName = not name:match(realm) and name..realm or name

    self.tblBlackList = ns.dbBL.blackList or {}
    if self.tblBlackList[blName] then
        local dateTable = date("*t", self.tblBlackList[blName].dateBlackList)
        local formattedTime = string.format("%02d/%02d/%04d", dateTable.month, dateTable.day, dateTable.year)
        ns.code:consoleOut(blName..' is already black listed with \"'..self.tblBlackList[blName].reason..'\" as a reason on '..formattedTime..'.')
        return
    end
    StaticPopup_Show(POPUP_REASON)
end
function blackList:IsOnBlackList(name)
    local realm = '-'..GetRealmName()
    name = name:gsub(realm, '')
    name = strupper(name:sub(1,1))..name:sub(2)..realm

    self.tblBlackList = ns.dbBL.blackList or {}
    return (self.tblBlackList[name] and not self.tblBlackList[name].markedForDelete) and true or false
end
blackList:Init()