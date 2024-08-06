local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.invite, ns.blackList, ns.antiSpam = {}, {}, {}
local invite, blackList, antiSpam = ns.invite, ns.blackList, ns.antiSpam

--* Invite
function invite:Init()
end
function invite:IsInvalidZone(zone)
    if ns.tblInvalidZonesByName[zone] then return true
    else
        for _, r in pairs(ns.tblInvalidZones) do
            if strlower(r.name) == strlower(zone) then return true end
        end
    end

    return false
end

function invite:whoInviteChecks(r)
    if self:IsInvalidZone(r.zone) then return r.zone
    elseif antiSpam:isOnAntiSpamList(r.fullName) then return L['ANTI_SPAM']
    elseif blackList:IsOnBlackList(r.fullName) then return L['BLACK_LISTED'] end

    return nil -- Returns error is not ok to invite
end

function invite:SendAutoInvite(pName, sendInvMessage)
    self:StartInvite(pName, sendInvMessage, true, true, false)
end
function invite:SendManualInvite(pName, sendWhisper, sendGreeting)
    self:StartInvite(pName, false, sendWhisper, sendGreeting, true)
end
function invite:StartInvite(pName, invMessage, sendWhisper, sendGreeting, isManual)
    if not pName then return end

    local fName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    pName = pName:gsub('*-', '') -- Remove realm name if present

    if blackList:isOnBlackList(fName) then
        if not isManual then ns.code:fOut(fName..' is on the Black List', 'FF0000') return
        elseif not ns.code:confirmDialog('Player '..fName..' is on the Black List. Do you want to invite anyway?', function() return true end) then return end
    elseif not isManual and antiSpam:isOnAntiSpamList(fName) then
        ns.code:fOut(fName..' is on the Anti Spam List', 'FF0000')
        return
    end

    local GMOverride = ns.gSettings.GMOverride or false
    local msgInvite = (invMessage and ns.scanner.invMessage) and ns.scanner.invMessage or nil
    local msgGreeting = (GMOverride or not ns.gmSettings.sendWhisperGreeting) and (ns.gSettings.whisperMessage or nil) or (ns.gmSettings.whisperMessage or nil)
    if msgGreeting then
        
    end
    local msgWelcome = (ns.scanner.sendWhisperGreeting and ((GMOverride and ns.gSettings.sendWhisperGreeting) or ns.gmSettings.sendWhisperGreeting)) and ns.scanner.greetingMessage or nil
end
invite:Init() -- Init invite

--* Black List
function blackList:Init()
end
function blackList:IsOnBlackList(pName)
    if not pName then return false end
    pName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present

    if not ns.tblBlackList then
        ns.code:fOut('Black List table not found', 'FF0000')
        return false
    elseif not pName then
        ns.code:fOut('Player name not found', 'FF0000')
        return false
    end

    local found = false
    for k in pairs(ns.tblBlackList) do
        if strlower(k) == strlower(pName) then found = true break end
    end

    return found
end
function blackList:AddToBlackList(pName, reason)
    print('AddToBlackList', pName, reason)
    if not pName then return false end

    pName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    if blackList.IsOnBlackList(pName) then return false end

    ns.tblBlackList[pName] = {
        name = pName,
        reason = reason,
        blBy = UnitName('player'),
        date = C_DateAndTime.GetServerTimeLocal(),
    }
    ns.analytics:saveStats('PlayersBlackListed')

    return true
end
blackList:Init() -- Init blackList

--* Anti Spam
function antiSpam:Init()
end
function antiSpam:isOnAntiSpamList(pName)
    if not ns.tblAntiSpamList then return false
    elseif not pName then return false end
    pName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present

    local found = false
    for k in pairs(ns.tblAntiSpamList) do
        if strlower(k) == strlower(pName) then found = true break end
    end

    return found
end
function antiSpam:AddToAntiSpamList(pName)
    if not pName then return false end

    pName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    if antiSpam.isOnAntiSpamList(pName) then return false end

    ns.tblAntiSpamList[pName] = {
        name = pName,
        asBy = UnitName('player'),
        date = C_DateAndTime.GetServerTimeLocal(),
    }

    return true
end
antiSpam:Init() -- Init antiSpam