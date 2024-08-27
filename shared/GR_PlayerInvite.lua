local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.invite, ns.blackList, ns.antiSpam = {}, {}, {}
local invite, blackList, antiSpam = ns.invite, ns.blackList, ns.antiSpam

--* Invite
function invite:Init()
    self.tblSent = {}
    self.sentCount = 0

    self.msgWhisper = nil
    self.guildMessage = nil
end
function invite:IsInvalidZone(zone)
    if ns.tblInvalidZones[zone] then return true
    else
        for _, r in pairs(ns.tblInvalidZones) do
            if strlower(r.name):find(strlower(zone)) then return true end
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

function invite:SendAutoInvite(pName, class, sendInvMessage, sendInvite)
    self:StartInvite(pName, class, sendInvMessage, true, true, false, sendInvite)
end
function invite:SendManualInvite(pName, class, sendWhisper, sendGreeting, sendInvite)
    self:StartInvite(pName, class, false, sendWhisper, sendGreeting, true, sendInvite)
end
function invite:StartInvite(pName, class, useInviteMsg, useWhisperMsg, useGreetingMsg, isManual, sendInvite)
    if not pName then return end

    --pName = 'Monkstrife' --! Remove this line
    local fName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    local name = pName:gsub('*-', '') -- Remove realm name if present
    local cName = class and ns.code:cPlayerName(name, class) or name

    -- Make sure player is not on the black list or anti spam list
    if self.tblSent[strlower(pName)] then
        ns.code:fOut(cName..' '..L['INVITE_ALREADY_SENT'])
        return
    elseif blackList:IsOnBlackList(fName) then
        if not isManual then ns.code:fOut(fName..' '..L['IS_ON_BLACK_LIST'], 'FF0000') return
        elseif not ns.code:confirmDialog('Player '..fName..L['IS_ON_BLACK_LIST']..'\n'..L['OK_INVITE'], function() return true end) then return end
    elseif not isManual and antiSpam:isOnAntiSpamList(fName) then
        ns.code:fOut(fName..' '..L['IS_ON_SPAM_LIST'], 'FF0000')
        return
    end

    -- Message Prep
    local invFormat = ns.pSettings.inviteFormat or 2
    local msgInvite = useInviteMsg and ns.gSettings.messageList[ns.pSettings.activeMessage].message or nil
    if msgInvite then msgInvite = ns.code:variableReplacement(msgInvite, name) end

    -- Verify if there is a invite message if not guild invite only.
    if useInviteMsg and not msgInvite and not isManual then
        ns.code:fOut(L['NO_INVITE_MESSAGE'])
        return
    end

    -- Check if in my guild
    if isManual and ns.code:isInMyGuild(fName) then
        ns.code:fOut(cName..' '..L['INVITE_IN_GUILD'])
        return
    end

    if pName and sendInvite then -- Guild Invite
        C_GuildInfo.Invite(pName)
        ns.code:fOut(L['GUILD_INVITE_SENT']..' '..cName, 'FFFFFF00')
    end

    invite:RegisterInvite(pName, class, useWhisperMsg, useGreetingMsg, isManual)

    if invFormat ~= 2 and invFormat ~= 4 and useInviteMsg and msgInvite then
        if isManual or not ns.core.obeyBlockInvites then self:SendMessage(pName, name, msgInvite)
        else
            C_Timer.After(1, function()
                if invite.tblSent[strlower(fName)] then
                    self:SendMessage(pName, name, msgInvite)
                    invite.tblSent[strlower(fName)].sentAt = GetServerTime()
                else
                    ns.code:fOut(L['INVITE_REJECTED']..' '..cName, 'FFFFFF00')
                end
            end)
        end
    end
end
function invite:SendMessage(pName, cName, msgInvite, showMessage)
    msgInvite = ns.code:variableReplacement(msgInvite, pName:gsub('-.*', '')) -- Remove realm name
    if not ns.pSettings.showWhispers and not showMessage then
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', function(_, _, msg) return msg == msgInvite end, msgInvite)
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', function(_, _, msg) return msg == msgInvite end, msgInvite)
        ns.code:fOut(L['INVITE_MESSAGE_SENT']..' '..cName, 'FFFFFF00')
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER', msgInvite)
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER_INFORM', msgInvite)
    end
    SendChatMessage(msgInvite, 'WHISPER', nil, pName)
end

-- After Invite Routines
local function UpdateInvitePlayerStatus(_, ...)
    local msg = ...
    if not msg then return end

    msg = strlower(msg)
    local fName, key = nil, nil
    if msg and msg:find('Invited By:') and msg:find(UnitName('player')) then -- GRM
        if GR.isTest then print('you did the invite') end
        return
    elseif msg and msg:find('REINVITED') and GR.isTest then print('You reinvited') return
    elseif not invite.tblSent then
        ns.observer:Unregister('CHAT_MSG_SYSTEM', UpdateInvitePlayerStatus)
        return
    end


    for _, v in pairs(invite.tblSent) do
        local nHold = strlower(v.name)
        local noRealm = nHold:gsub('-.*', '') -- Remove realm name
        local withRealm = nHold:find('-') and nHold or nHold..'-'..GetRealmName() -- Add realm name if not present
        if msg:find(noRealm) or msg:find(strlower(withRealm)) then
            fName = withRealm break end
    end
    if not fName then return end

    --* CHAT_MSG_SYSTEM Response Routines
    key = strlower(fName) -- key is in lower case
    if not invite.tblSent[key] then return
    elseif msg:find(L['PLAYER_NOT_ONLINE']) then
        ns.analytics:saveStats('PlayersInvited', -1)
        invite.tblSent[key] = nil
    elseif msg:find(L['NO_PLAYER_NAMED']) then
        ns.analytics:saveStats('PlayersInvited', -1)
        invite.tblSent[key] = nil
    elseif msg:find(L['PLAYER_IN_GUILD']) or msg:find(L['PLAYER_ALREADY_IN_GUILD']) then
        ns.analytics:saveStats('PlayersInvited', -1)
        invite.tblSent[key] = nil
    elseif msg:find(L['PLAYER_JOINED_GUILD']) then
        local isGreetingOk = (invite.tblSent[key] and invite.tblSent[key].guild and invite.tblSent[key].guild ~= '') or false
        local isWhisperOk = (invite.tblSent[key] and invite.tblSent[key].whisper and invite.tblSent[key].whisper ~= '') or false

        if isGreetingOk or isWhisperOk then
            C_Timer.After(5, function()
                if not key or not invite.tblSent[key] then return end

                local pName = invite.tblSent[key].name
                pName = pName:find(GetRealmName()) and pName:gsub('-.*', '') or pName
                local guildMsg, whisperMsg = invite.tblSent[key].guild, invite.tblSent[key].whisper

                if isGreetingOk then SendChatMessage(guildMsg, 'GUILD') end
                if isWhisperOk then SendChatMessage(whisperMsg, 'WHISPER', nil, pName) end
                ns.analytics:saveStats('PlayersJoined')
                ns.win.scanner:UpdateAnalytics()
                invite.tblSent[key] = nil
            end)
        else
            ns.analytics:saveStats('PlayersJoined')
            invite.tblSent[key] = nil
        end
    elseif msg:find(L['PLAYER_DECLINED_INVITE']) then
        if ns.pSettings.inviteFormat == 4 and not invite.tblSent[key].isManual then
            local name = invite.tblSent[key].name:gsub('-.*', '') -- Remove realm name
            local invMsg = ns.code:variableReplacement(ns.gSettings.messageList[ns.pSettings.activeMessage].message, name)
            invite:SendMessage(fName, name, invMsg, true)
            invite.tblSent[key].sentAt = GetServerTime()
        else
            ns.analytics:saveStats('PlayersDeclined')
            invite.tblSent[key] = nil
        end
    elseif invite.tblSent[key].sentAt + 60 < GetServerTime() then
        ns.analytics:saveStats('PlayersDeclined')
        invite.tblSent[key] = nil
    end

    ns.win.scanner:UpdateAnalytics()
    if not next(invite.tblSent) then -- Close out event handler if not more invites
        --ns.observer:Unregister('CHAT_MSG_SYSTEM', UpdateInvitePlayerStatus)
    end
end
function invite:RegisterInvite(pName, class, useWhisperMsg, useGreetingMsg, isManual)
    if not pName then return end
    local fName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    local oName = pName:gsub('*-', '') -- Remove realm name if present
    local cName = class and ns.code:cPlayerName(oName, class) or oName

    local msgWhisper = self.msgWhisper and ns.code:variableReplacement(self.msgWhisper, pName) or nil
    local guildMessage = self.guildMessage and ns.code:variableReplacement(self.guildMessage, pName) or nil

    self.tblSent[strlower(fName)] = {
        name = pName,
        fName = fName,
        cName = cName,
        whisper = (useWhisperMsg and msgWhisper) and msgWhisper:gsub('<', ''):gsub('>', '') or nil,
        guild = (useGreetingMsg and guildMessage) and guildMessage:gsub('<', ''):gsub('>', '') or nil,
        sentMsg = false,
        sentAt = GetServerTime(),
        isManual = isManual,
    }

    ns.analytics:saveStats('PlayersInvited')
    ns.win.scanner:UpdateAnalytics()
    ns.antiSpam:AddToAntiSpamList(fName)
end
function invite:GetWelcomeMessages()
    local guildMessage, msgWhisper = false, false

    if ns.core.hasGM or (ns.gmSettings.sendGuildGreeting and ns.gmSettings.guildMessage ~= '') then
        guildMessage = ns.gmSettings.guildMessage
    elseif not ns.core.hasGM and ns.gmSettings.forceSendGuildGreeting and ns.gmSettings.guildMessage ~= '' then
        guildMessage = ns.gmSettings.guildMessage
    elseif not ns.core.hasGM and ns.gSettings.sendGuildGreeting and ns.gSettings.guildMessage ~= '' then
        guildMessage = ns.gSettings.guildMessage
    end

    if ns.core.hasGM or (ns.gmSettings.sendWhisperGreeting and ns.gmSettings.whisperMessage ~= '') then
        msgWhisper = ns.gmSettings.whisperMessage
    elseif not ns.core.hasGM and ns.gmSettings.forceSendWhisper and ns.gmSettings.whisperMessage ~= '' then
        msgWhisper = ns.gmSettings.whisperMessage
    elseif not ns.core.hasGM and ns.gSettings.sendWhisperGreeting and ns.gSettings.whisperMessage ~= '' then
        msgWhisper = ns.gSettings.whisperMessage
    end

    self.msgWhisper = msgWhisper
    self.guildMessage = guildMessage
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
function blackList:ManualBlackListPrompt(blMsg, blName, POPUP_NAME)
    local name = (blName and blName:find('-')) and blName or (blName and blName..'-'..GetRealmName() or nil) -- Add realm name if not present
    if blName and blackList:IsOnBlackList(name) then
        ns.code:fOut(blName..' '..L['IS_ON_BLACK_LIST'], 'FFFFFF00')
        return
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

        blName = value

            StaticPopupDialogs[POPUP_REASON] = {
                text = L['BLACK_LIST_REASON_INPUT']..'\n'..blName,
                button1 = L['OK'],
                button2 = L['CANCEL'],
                OnAccept = function(rData)
                    if not blName then return end

                    value = rData.editBox:GetText()
                    value = value ~= '' and value or L['NO_REASON']

                    if not blName or not value then return end
                    ns.blackList:AddToBlackList(blName, value)
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
        end,
        OnCancel = function() UIErrorsFrame:AddMessage(L['BL_NO_ONE_ADDED'], 1.0, 0.1, 0.1, 1.0) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        maxLetters = 255,
    }

    StaticPopup_Show(POPUP_NAME)
end
function blackList:BlackListReasonPrompt(blName)
    local name = blName:find('-') and blName or blName..'-'..GetRealmName() -- Add realm name if not present
    if blackList:IsOnBlackList(name) then
        ns.code:fOut(blName..' '..L['IS_ON_BLACK_LIST'], 'FFFFFF00')
        return
    end

    local POPUP_REASON = "inputReason"
    local fName = select(2, UnitClass(blName)) and ns.code:cPlayer(blName, select(2, UnitClass(blName))) or blName
    StaticPopupDialogs[POPUP_REASON] = {
        text = L['BLACK_LIST_REASON_INPUT']..":\n"..(fName or blName),
        button1 = L["OK"],
        button2 = L["CANCEL"],
        OnAccept = function(data)
            if not blName then return end

            local value = data.editBox:GetText()
            value = value ~= '' and value or L['No Reason']

            blackList:AddToBlackList(blName, value)

            ns.code:fOut(string.format(blName..' '..L['ADDED_TO_BLACK_LIST'], '\"'..value..'\"'))
        end,
        OnCancel = function() UIErrorsFrame:AddMessage(L['BL_NAME_NOT_ADDED'], 1.0, 0.1, 0.1, 1.0) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        maxLetters = 255,
    }

    StaticPopup_Show(POPUP_REASON)
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

ns.observer:Register("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)