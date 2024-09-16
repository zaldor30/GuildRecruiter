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
    self.monitorRunning = false

    self.inviteMessage = nil
    self.greetingGuild = nil
    self.greetingWhisper = nil
end
function invite:GetWelcomeMessages()
    local location = ns.core.hasGM and ns.gmSettings or ns.gSettings
    local activeMessage = ns.pSettings.activeMessage or nil

    self.inviteMessage = (location.messageList and location.messageList[activeMessage]) and location.messageList[activeMessage].message or nil

    local useLocation = (ns.core.hasGM or ns.gmSettings.forceGuildMessage) and ns.gmSettings or ns.gSettings
    self.greetingGuild = (ns.gmSettings.forceGuildMessage or ns.gSettings.sendGuildGreeting) and useLocation.guildMessage or nil

    useLocation = (ns.core.hasGM or ns.gmSettings.forceWhisperMessage) and ns.gmSettings or ns.gSettings
    self.greetingWhisper = (ns.gmSettings.forceWhisperMessage or ns.gSettings.sendWhisperGreeting) and useLocation.whisperMessage or nil

    if ns.gSettings.invFormat  ~= 2 and (not self.inviteMessage and self.inviteMessage ~= '') then
        ns.code:fOut(L['NO_INVITE_MESSAGE'], 'FFFF0000')
    elseif (ns.gmSettings.forceSendGuildGreeting or ns.gSettings.sendGuildGreeting) and (not self.greetingGuild and self.greetingGuild ~= '') then
        ns.code:fOut(L['NO_GREETING_MESSAGE'], 'FFFF0000')
    elseif (ns.gmSettings.forceSendWhisper or ns.gSettings.sendWhisperGreeting) and (not self.greetingWhisper and self.greetingWhisper ~= '') then
        ns.code:fOut(L['NO_WHISPER_MESSAGE'], 'FFFF0000')
    end
end
function invite:SendAutoInvite(pName, class, useInviteMsg, sendInvite)
    self:StartInvite(pName, class, useInviteMsg, false, sendInvite)
end
function invite:SendManualInvite(pName, class, sendWhisper, sendGreeting, sendInvite)
    self:StartInvite(pName, class, false, true, sendInvite, (not sendWhisper and not sendGreeting))
end
function invite:StartInvite(pName, class, useInviteMsg, isManual, sendInvite, skipMessages)
    if not pName then return end
    if not CanGuildInvite() then ns.code:fOut(L['NO_GUILD_PERMISSIONS']) return end

    if GR.isTesting then pName = 'Monkstrife' end

    local fName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    local cName = (class or UnitClassBase(pName)) and ns.code:cPlayer(fName, class) or pName:gsub('%-.*', '')

    --* Handle Invite Rejects
    local checkResult = nil
    if not GR.isTesting then checkResult = self:PerformInviteChecks(fName, isManual) end
    if checkResult == 'GUILD' then return
    elseif checkResult == L['BLACK_LISTED'] then
        if not isManual then return end
        ns.code:fOut(pName..' '..L['PLAYER_IS_ON_BLACKLIST'], 'FFFFFF00')
        if not ns.code:Confirmation(L['PLAYER_MANUAL_ON_BLACKLIST']:gsub('%%REASON%%', ns.tblBlackList[pName].reason), function()
            return true end) then return end
    elseif not isManual and checkResult == L['ANTI_SPAM'] then return end
    antiSpam:AddToAntiSpamList(fName)
    --? End Handle Invite Rejects

    local function SendGuildInvite()
        C_GuildInfo.Invite(pName)
        ns.code:fOut(L['GUILD_INVITE_SENT']..' '..cName, 'FFFFFF00')
    end

    --* Manual Invite
    if isManual then
        if sendInvite then SendGuildInvite() end
        if useInviteMsg and self.inviteMessage then invite:SendMessage(pName, cName, self.inviteMessage, 'WHISPER') end
        if skipMessages then ns.analytics:incStats('PlayersInvited') return end
        invite:RegisterInvite(pName, cName, (class or UnitClassBase(pName)), isManual, skipMessages)
        return
    end
    --? End of Manual Invite

    --* Automated Invite Functions
    invite:RegisterInvite(pName, cName, (class or UnitClassBase(pName)), isManual, skipMessages)

    if sendInvite then SendGuildInvite() end
    if useInviteMsg then
        if (ns.core.hasGM or ns.gmSettings.forceObey) and not ns.gmSettings.obeyBlockInvites then tinsert(self.tblQueue, pName)
        elseif not ns.gmSettings.forceObey and not ns.gSettings.obeyBlockInvites then tinsert(self.tblQueue, pName)
        else
            C_Timer.After(1, function()
                if self.tblSent[pName] then tinsert(self.tblQueue, pName) end
                self:StartQueue()
            end)
        end
    end
    --? End of Automated Invite Functions

    self:StartQueue()
end

--* Invite Support Functions
function invite:whoInviteChecks(v) return invite:PerformInviteChecks(v.fullName, false, v.zone) end
function invite:PerformInviteChecks(pName, isManual, zone)
    if not pName then return end
    local name = pName:match('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    
    if isManual and ns.code:isInMyGuild(name) then
        ns.code:fOut(name..' '..L['PLAYER_ALREADY_IN_GUILD'], 'FFFFFF00')
        return 'GUILD'
    elseif zone and ns.tblInvalidZones[strlower(zone)] then return zone
    elseif ns.tblBlackList[name] or blackList.IsOnBlackList(name) then
        if isManual then ns.code:fOut(name..' '..L['PLAYER_IS_ON_BLACKLIST'], 'FFFFFF00') end
        return L['BLACK_LISTED']
    elseif not isManual and ns.tblAntiSpamList[name] then
        if not zone then ns.code:fOut(name..' '..L['PLAYER_IS_ON_ANTISPAM_LIST'], 'FFFFFF00') end
        return L['ANTI_SPAM']
    end

    return false
end
function invite:SendMessage(pName, cName, message, channel)
    message = ns.code:variableReplacement(message, pName:gsub('%-.*', '')) -- Remove realm name

    if not ns.pSettings.showWhispers and message and channel and pName then
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', function(_, _, msg) return msg == message end, message)
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', function(_, _, msg) return msg == message end, message)
        SendChatMessage(message, channel, nil, pName)
        ns.code:fOut(L['INVITE_MESSAGE_SENT']..' '..cName, 'FFFFFF00')
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER', message)
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER_INFORM', message)
    elseif message and channel and pName then SendChatMessage(message, channel, nil, pName) end
end
local function UpdateInvitePlayerStatus(_, ...) invite:UpdateInvitePlayerStatus(...) end
function invite:RegisterInvite(pName, cName, class, isManual, skipMessages)
    self.tblSent[pName] = {
        name = pName:gsub('%-.*', ''),
        pName = pName,
        cName = cName,
        class = class,
        manual = isManual,
        skipWelcome = skipMessages,
        sentAt = time(),
    }

    ns.analytics:incStats('PlayersInvited')
    ns.analytics:WaitingOnPlayer('WaitingOnInvite')
    ns.win.scanner:UpdateAnalytics()

    if not self.monitorRunning then
        ns.observer:Register("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus) end
end
function invite:StartQueue()
    local function SendNextMessage()
        if #self.tblQueue == 0 then
            self.queueRunning = false
            return
        end

        local pName = tremove(self.tblQueue, 1)
        invite:SendMessage(pName, pName:gsub('%-.*', ''), self.inviteMessage, 'WHISPER')
        C_Timer.After(.5, function() SendNextMessage() end)
    end

    if self.queueRunning then return end
    self.queueRunning = true
    SendNextMessage()
end

function invite:UpdateInvitePlayerStatus(msg)
    if not msg then return end

    local count = 0
    for _ in pairs(self.tblSent) do count = count + 1 end

    local lowerMsg = strlower(msg)
    if lowerMsg:match('invited by') and msg:match(UnitName('player')) then
        ns.code:dOut('You invited '..' to join the guild.', 'FFFFFF00')
        return
    elseif msg:match('reinvited') and msg:match(UnitName('player')) then
        ns.code:dOut('You reinvited '..' to join the guild.', 'FFFFFF00')
        return
    elseif count == 0 then
        ns.observer:Unregister("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)
        self.monitorRunning = false
        return
    end

    local key = nil
    for k,v in pairs(self.tblSent) do
        if msg:match(k) or msg:match(v.name) then key = k break end
    end
    if not key then return end

    local removePlayer = false
    if msg:match(L['PLAYER_NOT_ONLINE']) or msg:match(L['PLAYER_NOT_FOUND'])
        or msg:match(L['NO_PLAYER_NAMED']) or msg:match(L['PLAYER_IN_GUILD'])
        or msg:match(L['PLAYER_ALREADY_IN_GUILD']) then
        ns.analytics:incStats('PlayersInvited', -1)
        removePlayer = true
    elseif msg:find(L['PLAYER_JOINED_GUILD']) then
        if not self.tblSent[key].skipMessages then
            C_Timer.After(3, function()
                if self.greetingGuild then SendChatMessage(ns.code:variableReplacement(self.greetingGuild, key:gsub('%-.*', ''), true), 'GUILD') end
                if self.greetingWhisper then SendChatMessage(ns.code:variableReplacement(self.greetingWhisper, key:gsub('%-.*', ''), true), 'WHISPER', nil, key) end
            end)
        end
        ns.analytics:incStats('PlayersJoined')
        removePlayer = true
    elseif msg:find(L['PLAYER_DECLINED_INVITE']) then
        if self.tblSent[key].sentAt + 60 < time() then
            removePlayer = true
            ns.analytics:incStats('PlayersInvited', -1)
        elseif ns.pSettings.inviteFormat == 4 and not self.tblSent[key].manual then
            ns.analytics:incStats('PlayersDeclined')
            invite:SendMessage(key, key:gsub('%-.*', ''), self.greetingGuild, 'WHISPER')
            tinsert(self.tblQueue, key)
            self:StartQueue()
        else ns.analytics:incStats('PlayersDeclined') end
        removePlayer = true
    end

    if removePlayer then
        ns.analytics:WaitingOnPlayer('WaitingOnInvite', -1)
        self.tblSent[key] = nil
    end

    ns.win.scanner:UpdateAnalytics()
    if count == 0 then
        ns.observer:Unregister("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)
        self.monitorRunning = false
        return
    end
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
    if ns.tblBlackList[pName] then return false end

    ns.tblBlackList[pName] = {
        name = pName,
        reason = reason,
        blBy = UnitName('player'),
        date = time(),
    }
    ns.analytics:incStats('PlayersBlackListed')

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
            value = value ~= '' and value or L['NO_REASON']

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
        if k == pName then found = true break end
    end

    return found
end
function antiSpam:AddToAntiSpamList(pName)
    if not pName then return false end

    pName = pName:find('-') and pName or pName..'-'..GetRealmName() -- Add realm name if not present
    if ns.tblAntiSpamList[pName] then return false end

    ns.tblAntiSpamList[pName] = {
        name = pName,
        asBy = UnitName('player'),
        date = time(),
    }

    return true
end