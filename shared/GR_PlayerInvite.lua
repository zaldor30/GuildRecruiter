local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.invite, ns.blackList, ns.antiSpam = {}, {}, {}
local invite, blackList, antiSpam = ns.invite, ns.blackList, ns.antiSpam

--* Invite
function invite:Init()
    self.tblSent = {}
    self.sentCount = 0

    self.tblQueue = {}
    self.queueRunning = false

    self.inviteMessage = nil
    self.greetingGuild = nil
    self.greetingWhisper = nil
end
function invite:GetWelcomeMessages()
    local location = ns.core.hasGM and ns.gmSettings or ns.gSettings
    local activeMessage = ns.pSettings.activeMessage or nil

    self.inviteMessage = (location.messageList and location.messageList[activeMessage]) and location.messageList[activeMessage].message or nil
    local useLocation = (ns.core.hasGM or ns.gmSettings.forceGuildMessage) and ns.gmSettings or ns.gSettings
    self.greetingGuild = useLocation.guildMessage or nil

    useLocation = (ns.core.hasGM or ns.gmSettings.forceWhisperMessage) and ns.gmSettings or ns.gSettings
    self.greetingWhisper = useLocation.whisperMessage or nil

    if ns.gSettings.invFormat and not self.inviteMessage then ns.code:fOut(L['NO_INVITE_MESSAGE'], 'FFFF0000')
    elseif (ns.gmSettings.forceSendGuildGreeting or ns.gSettings.sendGuildGreeting) and not self.greetingGuild then ns.code:fOut(L['NO_GREETING_MESSAGE'], 'FFFF0000')
    elseif (ns.gmSettings.forceSendWhisper or ns.gSettings.sendWhsiper) and not self.greetingWhisper then ns.code:fOut(L['NO_WHISPER_MESSAGE'], 'FFFF0000')
    end
end
function invite:SendAutoInvite(pName, class, sendInvMessage, sendInvite)
    self:StartInvite(pName, class, sendInvMessage, false, sendInvite)
end
function invite:SendManualInvite(pName, class, sendWhisper, sendGreeting, sendInvite)
    self:StartInvite(pName, class, sendInvite, true, sendInvite, (sendWhisper and sendGreeting))
end
function invite:StartInvite(pName, class, useInviteMsg, isManual, sendInvite, useMessages)
    if not pName then return end
    if not CanGuildInvite() then ns.code:fOut(L['NO_GUILD_PERMISSIONS']) return end

    if GR.isTesting then pName = 'Monkstrife' end

    local fName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    local cName = (class or UnitClassBase(pName)) and ns.code:cPlayer(fName, class) or pName:gsub('-.*', '')

    --* Handle Invite Rejects
    local checkResult = nil
    if not GR.isTesting then checkResult = self:PerformInviteChecks(pName, isManual) end
    if checkResult == 'GUILD' then return
    elseif checkResult == L['BLACK_LISTED'] then
        if not isManual then return end
        ns.code:fOut(pName..' '..L['PLAYER_IS_ON_BLACKLIST'], 'FFFFFF00')
        if not ns.code:Confirmation(L['PLAYER_MANUAL_ON_BLACKLIST']:gsub('%%REASON%%', ns.tblBlackList[pName].reason), function()
            return true end) then return end
    elseif not isManual and checkResult == L['ANTI_SPAM'] then return end
    antiSpam:AddToAntiSpamList(pName)
    --? End Handle Invite Rejects

    local function SendGuildInvite()
        C_GuildInfo.Invite(pName)
        ns.code:fOut(L['GUILD_INVITE_SENT']..' '..cName, 'FFFFFF00')
    end

    --* Manual Invite
    if isManual then
        if sendInvite then SendGuildInvite() end
        if useInviteMsg and self.inviteMessage then invite:SendMessage(pName, self.inviteMessage, 'WHISPER') end
        invite:RegisterInvite(pName, cName, (class or UnitClassBase(pName)), useInviteMsg, isManual, useMessages)
        return
    end
    --? End of Manual Invite

    --* Automated Invite Functions
    invite:RegisterInvite(pName, cName, (class or UnitClassBase(pName)), useInviteMsg, isManual, useMessages)

    if sendInvite then SendGuildInvite() end
    if useInviteMsg then
        if (ns.core.hasGM or ns.gmSettings.forceObey) and not ns.gmSettings.obeyBlockInvites then self.tblQueue[pName] = tinsert(self.tblQueue, pName)
        elseif not ns.gmSettings.forceObey and not ns.gSettings.obeyBlockInvites then tinsert(self.tblQueue, pName)
        else
            C_Timer.After(1, function()
                if self.tblSent[pName] then self.tblQueue[pName] = tinsert(self.tblQueue, pName) end
                if not self.queueRunning and #self.tblQueue > 0 then self:StartQueue() end
            end)
        end
    end
    --? End of Automated Invite Functions

    if not self.queueRunning and #self.tblQueue > 0 then self:StartQueue() end
end

--* Invite Support Functions
function invite:whoInviteChecks(v) invite:PerformInviteChecks(v.fullName, false, v.zone) end
function invite:PerformInviteChecks(pName, isManual, zone)
    if not pName then return end
    local name = pName:match('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present

    if isManual and ns.core:IsInGuild(name) then
        ns.code:fOut(name..' '..L['IS_ALREADY_IN_GUILD'], 'FFFFFF00')
        return 'GUILD'
    elseif zone and ns.tblInvalidZones[strlower(zone)] then return zone
    elseif blackList:IsOnBlackList(name) then
        if not zone and not isManual then ns.code:fOut(name..' '..L['PLAYER_IS_ON_BLACKLIST'], 'FFFFFF00') end
        return L['BLACK_LISTED']
    elseif not isManual and antiSpam.isOnAntiSpamList(name) then
        if not zone then ns.code:fOut(name..' '..L['PLAYER_IS_ON_ANTISPAM_LIST'], 'FFFFFF00') end
        return L['ANTI_SPAM']
    end
end
function invite:SendMessage(pName, cName, message, showMessage)
    message = ns.code:variableReplacement(message, pName:gsub('-.*', '')) -- Remove realm name

    if not ns.pSettings.showWhispers and not showMessage then
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', function(_, _, msg) return msg == message end, message)
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', function(_, _, msg) return msg == message end, message)
        SendChatMessage(message, 'WHISPER', nil, pName)
        ns.code:fOut(L['INVITE_MESSAGE_SENT']..' '..cName, 'FFFFFF00')
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER', message)
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER_INFORM', message)
    else SendChatMessage(message, 'WHISPER', nil, pName) end
end
function invite:RegisterInvite(pName, cName, class, useInviteMsg, isManual, useMessages)
    self.tblSent[pName] = {
        name = pName:match('(.+)-'),
        pName = pName,
        cName = cName,
        class = class,
        manual = isManual,
        useMessages = useMessages,
    }

    ns.analytics:saveStats('PlayersInvited')
    ns.win.scanner:UpdateAnalytics()

    local function UpdateInvitePlayerStatus() invite:UpdateInvitePlayerStatus() end
    ns.observer:Register("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)
end
function invite:StartQueue()
    local function SendNextMessage()
        if #self.tblQueue == 0 then
            self.queueRunning = false
            return
        end

        local pName = tremove(self.tblQueue, 1)
        invite:SendMessage(pName, pName:gsub('-.*', ''), self.inviteMessage, 'WHISPER')
        C_Timer.After(1, function() SendNextMessage() end)
    end

    self.queueRunning = true
    SendNextMessage()
end
function invite:UpdateInvitePlayerStatus()
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