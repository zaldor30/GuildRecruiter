local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local aTimer = LibStub("AceTimer-3.0")

ns.invite, ns.blackList, ns.antiSpam = {}, {}, {}
local invite, blackList, antiSpam = ns.invite, ns.blackList, ns.antiSpam

local invPlayer, invMonitor = {}, {}
function invMonitor:addPlayer(pName)
    if not pName then return end
    if not invPlayer[pName] or invMonitor[pName] then return end

    local iPlayer = invPlayer[pName]
    invMonitor[pName] = {
        name = iPlayer.name,
        fullName = iPlayer.fullName,
        colorName = iPlayer.colorName,

        useInviteMsg = iPlayer.useInviteMsg,
        useWhisperMsg = iPlayer.useWhisperMsg,
        useGreetingMsg = iPlayer.useGreetingMsg,

        isManual = iPlayer.isManual,
        sendInvite = iPlayer.sendInvite,
        inviteSent = iPlayer.inviteSent or false,
        messageSent = false,
    }
    return invPlayer[pName]
end

--* Timer Functions
local activeTimers = {}
local function timerFunc() -- Ace Timer Functions
    local tblFunc = {}
    function tblFunc:addTimer(name, time, func)
        if not name or not time or not func then return end
        if activeTimers[name] then return end

        activeTimers[name] = aTimer:ScheduleTimer(func, time)
    end
    function tblFunc:cancelTimer(name)
        if not name then return end
        if activeTimers[name] then
            aTimer:CancelTimer(activeTimers[name])
            activeTimers[name] = nil
        end
    end
    function tblFunc:cancelAllTimers()
        for k, v in pairs(activeTimers) do
            aTimer:CancelTimer(v)
            activeTimers[k] = nil
        end
    end

    return tblFunc
end
local timers = timerFunc()
--? End of Timer Functions

function invite:Init()
    self.tblSendMessages = {}

    self.inviteMessage = nil
    self.greetingMessage = nil
    self.greetingWhisper = nil
end
function invite:UpdateInvite() -- Setup Messages
    --* Guild Greeting Message
    if ns.core.hasGM or ns.gmSettings.forceMessageList then self.inviteMessage = ns.gmSettings.guildMessage or nil
    else self.greetingMessage = ns.gSettings.guildMessage or nil end

    --* Guild Greeting Whisper
    if ns.core.hasGM or ns.gmSettings.forceWhisperMessage then self.greetingWhisper = ns.gmSettings.whisperMessage or nil
    else self.greetingWhisper = ns.gSettings.whisperMessage or nil end

    --* Guild Invite Message (Selected)
    if ns.pSettings.activeMessage ~= '' then
        if (ns.core.hasGM or ns.gmSettings.forceMessageList) and ns.gmSettings.forceMessageList then
            self.inviteMessage = ns.gmSettings.messageList[ns.pSettings.activeMessage].message
        elseif ns.pSettings.activeMessage ~= '' and ns.gSettings.messageList then
            self.inviteMessage = ns.gSettings.messageList[ns.pSettings.activeMessage].message
        end
    end

    timers:cancelAllTimers()
end

--* Invite Player to Guild
function invite:SendAutoInvite(pName, class, sendInvMessage, sendInvite)
    self:StartInvite(pName, class, sendInvMessage, true, true, false, sendInvite)
end
function invite:SendManualInvite(pName, class, sendWhisper, sendGreeting, sendInvite)
    self:StartInvite(pName, class, false, sendWhisper, sendGreeting, true, sendInvite)
end
function invite:StartInvite(pName, class, useInviteMsg, useWhisperMsg, useGreetingMsg, isManual, sendInvite)
    if not CanGuildInvite() then
        ns.code:fOut(L['NO_GUILD_PERMISSIONS'])
        return
    elseif not pName then return end

    if GR.isTesting then pName = 'Monkstrife' end

    local name = pName:gsub('*-', '')
    local fullName = pName:find('-') and pName or pName .. '-' .. GetRealmName()
    local colorName = class and ns.code:cPlayer(name, class) or name

    --* Check Messages
    useInviteMsg = (useInviteMsg and ns.pSettings.inviteFormat ~= 2) and useInviteMsg or false
    if useInviteMsg then
        if useInviteMsg and not self.inviteMessage then
            useInviteMsg = false
            ns.code:fOut(L['NO_INVITE_MESSAGE'], 'FFFF0000') end
        if useWhisperMsg and not self.greetingWhisper then
            useWhisperMsg = false
            ns.code:fOut(L['NO_WHISPER_MESSAGE'], 'FFFF0000') end
        if useGreetingMsg and not self.greetingMessage then
            useGreetingMsg = false
            ns.code:fOut(L['NO_GREETING_MESSAGE'], 'FFFF0000') end
    end
    --? End of Check Messages

    invPlayer[pName] = {
        name = name,
        fullName = fullName,
        colorName = colorName,

        useInviteMsg = useInviteMsg,
        useWhisperMsg = useWhisperMsg,
        useGreetingMsg = useGreetingMsg,
        inviteFormat = ns.pSettings.inviteFormat or 2,

        isManual = isManual,
        sendInvite = sendInvite,
        inviteSent = false,
    }
    local curPlayer = invPlayer[pName]
    if curPlayer == 1 then curPlayer.messageSent = false end

    -- Verify player can be invited (double check)
    if not isManual and not GR.isTesting then
        local result = invite:CheckPlayerInviteStatus(pName)
        if result == 'BlackList' then
            ns.code:fOut(pName..' '..L['IS_ON_BLACK_LIST'], 'FFFF0000')
            return
        elseif result == 'AntiSpam' then
            ns.code:fOut(pName..' '..L['IS_ON_ANTI_SPAM'], 'FFFF0000')
            return
        end
    elseif isManual then
        if ns.code:isInMyGuild(pName) then
            ns.code:fOut(curPlayer.colorName..' '..L['INVITE_IN_GUILD'])
            return
        end
        if invite:ManualInvitePlayerCheck(pName) then
            ns.code:fOut(pName..' '..L['IS_ON_BLACK_LIST'], 'FFFF0000')
            if not ns.code:Confirmation(pName..L['IS_ON_BLACK_LIST']..'\n'..ns.tblBlackList[pName].reason..'\n\nAre you sure you want to invite?', function() blackList:AddToBlackList(pName) return true end) then
                return end
        end
    end

    -- Add Player to Invite Monitor List
    local monPlayer = invMonitor:addPlayer(pName)
    curPlayer.inviteSent = useInviteMsg
    curPlayer.messageSent = useInviteMsg

    timers:addTimer(pName..'INVITE_TIMEOUT', 120, function()
        timers:cancelTimer(pName..'INVITE_TIMEOUT')
    end)

    if pName and sendInvite then
        C_GuildInfo.Invite(pName)

        ns.code:fOut(L['GUILD_INVITE_SENT']..' '..curPlayer.colorName)
        timers:addTimer(pName..'INVITE_MESSAGE_WAIT', 1, function()
            if monPlayer and useInviteMsg then monPlayer.inviteSent = false end
            if monPlayer and useWhisperMsg then monPlayer.messageSent = false end
            timers.cancelTimer(pName..'INVITE_MESSAGE_WAIT')

            tinsert(self.tblSendMessages, pName)
            if #self.tblSendMessages == 1 then self:SendInviteMessages() end
        end)
    elseif pName and useInviteMsg then
        if monPlayer and useInviteMsg then monPlayer.messageSent = false end
        tinsert(self.tblSendMessages, pName)
        if #self.tblSendMessages == 1 then self:SendInviteMessages() end
    end

end
--? End of Invite Player to Guild

--* Invite Check Routines
function invite:ManualInvitePlayerCheck(name)
    invite:CheckPlayerInviteStatus(name, nil, true)
end
function invite:CheckPlayerInviteStatus(name, zone, skipAntiSpam)
    if zone and ns.tblInvalidZones[zone] then return zone
    elseif blackList:IsOnBlackList(name) then return 'BlackList'
    elseif not skipAntiSpam and antiSpam:isOnAntiSpamList(name) then return 'AntiSpam' end
end
--? End of Invite Check Routines

--* Invite Message Routines
function invite:SendInviteMessages()
    local isRunning = false

    local function sendNextMessage()
        if #self.tblSendMessages == 0 then isRunning = false return end
        local k = tremove(self.tblSendMessages, 1)

        invMonitor[k].messageSent = true
        SendChatMessage(self.inviteMessage, 'WHISPER', nil, k)
        C_Timer.After(1, function() sendNextMessage() end)
    end

    if isRunning then return end

    isRunning = true
    sendNextMessage()
end
--? End of Invite Message Routines
invite:Init()

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

local function UpdateInvitePlayerStatus(_, ...)
end
ns.observer:Register("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)