local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.list = {}
local list = ns.list

--* Anti-Spam Routines
function list:AddToAntiSpam(fullName)
    if not fullName then return end

    local newAntiSpam = {
        time = time(),
        name = fullName,
    }
    fullName = strlower(fullName:match('-') and fullName or fullName..'-'..GetRealmName())
    ns.tblAntiSpamList[fullName] = newAntiSpam
end

--* Blacklist Routines
function list:AddToBlackList(fullName, reason)
    if not fullName then return end

    local pName = fullName:match('-') and fullName:gsub('%-.*', '') or fullName
    fullName = strlower(fullName:match('-') and fullName or fullName..'-'..GetRealmName())
    ns.tblBlackList[fullName] = {
        name = pName,
        reason = reason,
        blBy = UnitName('player'),
        date = time(),
    }
end
function list:BlacklistReason(fullName)
    if not fullName then return end

    fullName = strlower(fullName:match('-') and fullName or fullName..'-'..GetRealmName())
    return ns.tblBlackList[fullName] and ns.tblBlackList[fullName].reason or ''
end
function list:ManualBlackList(blName, blMsg, POPUP_NAME)
    if blName then
        blName = strupper(blName:sub(1, 1))..strlower(blName:sub(2)) -- Capitalize first letter
        if list:CheckBlacklist(blName) then
            ns.code:fOut(blName..' '..L['IS_ON_BLACK_LIST'], 'FFFFFF00')
            return
        end
    end

    local POPUP_REASON = "inputReason"
    POPUP_NAME = POPUP_NAME or "inputName"

    StaticPopupDialogs[POPUP_NAME] = {
        text = blMsg,
        button1 = L['OK'],
        button2 = L['CANCEL'],
        OnAccept = function(data)
        local value = nil
        value = data.editBox:GetText()
        if not value or value == '' then return end

        blName = blName:match(GetRealmName()) and blName:gsub('%-.*', '') or blName
        blName = ns.code:capitalizeAfterHyphen(value) -- Capitalize first letter

        list:GetReason(blName, value, POPUP_REASON)
        list:GetReason(blName, POPUP_REASON)
        end,
        OnCancel = function() UIErrorsFrame:AddMessage(L['BL_NO_ONE_ADDED'], 1.0, 0.1, 0.1, 1.0) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        maxLetters = 255,
    }

    if not blName then StaticPopup_Show(POPUP_NAME)
    else list:GetReason(blMsg, blName, POPUP_REASON) end
end
function list:GetReason(blMsg, blName, POPUP_REASON)
    local value = nil
    StaticPopupDialogs[POPUP_REASON] = {
        text = string.format(L['BLACK_LIST_REASON_INPUT'], ('\n'..blName)),
        button1 = L['OK'],
        button2 = L['CANCEL'],
        OnAccept = function(rData)
            if not blName then return end

            value = rData.editBox:GetText()
            value = value ~= '' and value or L['NO_REASON_GIVEN']

            if not blName or not value then return end
            ns.list:AddToBlackList(blName, value)
            ns.code:fOut(string.format(blName..' '..L['ADDED_TO_BLACK_LIST'], '\"'..value..'\"'))
        end,
        OnCancel = function() UIErrorsFrame:AddMessage(blName..' '..L['BL_NAME_NOT_ADDED'], 1.0, 0.1, 0.1, 1.0) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        maxLetters = 255,
        -- You can add more properties as needed
    }

    StaticPopup_Show(POPUP_REASON)
end

--* Check Routines
function list:CheckAntiSpam(fullName)
    if not fullName then return end

    fullName = strlower(fullName:match('-') and fullName or fullName..'-'..GetRealmName())
    local antiSpam = ns.tblAntiSpamList[fullName]
    if not antiSpam then return false, L['ANTI_SPAM'] end

    return true, ''
end
function list:CheckBlacklist(fullName)
    if not fullName then return end

    fullName = strlower(fullName:match('-') and fullName or fullName..'-'..GetRealmName())
    return (ns.tblBlackList[fullName] or false), ((ns.tblBlackList[fullName] and ns.tblBlackList[fullName].reason) and ns.tblBlackList[fullName].reason or L['BLACKLIST'])
end