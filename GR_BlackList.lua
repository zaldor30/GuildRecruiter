local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.blackList = {}
local blackList = ns.blackList
function blackList:Init()
end
function blackList:FixBlackList()
    self.tblBlackList = ns.tblBlackList or {}

    self.tblBlackList.blackList = nil
    for k in pairs(self.tblBlackList) do
        if type(k) == 'number' then self.tblBlackList[k] = nil end
    end
end
function blackList:CheckBlackList(name)
    if not name then return end

    local realm = '-'..GetRealmName()
    local found = false
    local record = ns.tblBlackList[name] or ns.tblBlackList[name..realm] or nil
    if record and record.markedForDelete then return false
    else return record or false end
end
function blackList:AddToBlackList(name, reason)
    if not name then return end

    local POPUP_REASON, blName = "inputReason", nil
    local fName = select(2, UnitClass(name)) and ns.code:cPlayer(name, select(2, UnitClass(name))) or name
    StaticPopupDialogs[POPUP_REASON] = {
        text = L['Why do you want to black list?']..":\n"..(fName or blName),
        button1 = L["OK"],
        button2 = L["Cancel"],
        OnAccept = function(data)
            if not blName then return end

            local value = data.editBox:GetText()
            value = value ~= '' and value or L['No Reason']

            ns.tblBlackList[blName] = { reason = value, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), send = false, markedForDelete = false }
            ns.code:saveTables('BLACK_LIST')

            ns.analytics:saveStats('PlayersBlackListed', true)
            ns.code:fOut(string.format(blName..' '..L['was added to the black list with %s as a reason.'], ' \"'..value..'\"'))
        end,
        OnCancel = function() UIErrorsFrame:AddMessage(name..' '..L['BL_NAME_NOT_ADDED'], 1.0, 0.1, 0.1, 1.0) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        maxLetters = 255,
        -- You can add more properties as needed
    }

    local realm = '-'..GetRealmName()
    blName = not name:match('-') and name..realm or name
    if not blName then return end

    blName = blName:gsub("^%l", strupper)
    if not reason then StaticPopup_Show(POPUP_REASON)
    else
        reason = reason == 'BULK_ADD_BLACKLIST' and L['Bulk Add'] or reason
        ns.tblBlackList[blName] = { reason = reason, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), send = false, markedForDelete = false }
        ns.code:saveTables('BLACK_LIST')

        ns.analytics:saveStats('PlayersBlackListed', true)

        if reason ~= L['Bulk Add'] then
            ns.code:cOut(string.format(fName..' '..L['was added to the black list with %s as a reason.'], ' \"'..reason..'\"'))
        end
    end
    ns.screens.scanner:UpdateAnalyticsSection()
end
blackList:Init()