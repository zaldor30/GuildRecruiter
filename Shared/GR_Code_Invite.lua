local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.invite = {}
local invite = ns.invite

local testingPlayerName = 'Monkstrife'
local INVITE_TIME_OUT = 120

--#region Message Queue/Sender Routines
local queueRunning, messageQueue = false, {}
local function startQueue()
    if queueRunning then return end

    local function sendNextMessage()
        if #messageQueue == 0 then queueRunning = false return
        else queueRunning = true end

        local toSend = tremove(messageQueue, 1)
        local fName, message = toSend.sendTo:gsub('%-.*', ''), toSend.message
        if toSend.sendTo and fName and message then
            if not ns.pSettings.showWhispers then
                ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', function(_, _, msg) return msg == message end, message)
                ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', function(_, _, msg) return msg == message end, message)
            end

            SendChatMessage(message, 'WHISPER', nil, toSend.sendTo)

            if not ns.pSettings.showWhispers then
                ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER', message)
                ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER_INFORM', message)
            end
        end

        if #messageQueue > 0 then C_Timer.After(ns.g.timeBetweenMessages or 0.2, sendNextMessage) end
    end
    sendNextMessage()
end
local function queueMessage(player, message)
    if not player or not message then return end

    tinsert(messageQueue, { sendTo = player, message = message })
    startQueue()
end
--#endregion

--#region Invite Initialize Routines
function invite:Init()
    self.tblInvited = {}

    self.useGuild, self.useWhisper, self.useInvite = false, false, false
    self.msgGuild, self.msgWhisper, self.msgInvite = nil, nil, nil

    self:RegisterInviteObservers()
end
function invite:GetMessages()
    self.msgGuild = (ns.gmSettings.forceSendGuildGreeting and ns.gmSettings.sendGuildGreeting and ns.gmSettings.guildMessage ~= '') and ns.gmSettings.guildMessage or ns.gSettings.guildMessage or L['DEFAULT_GUILD_WELCOME']
    self.msgInvite = (ns.guild.messageList and ns.pSettings.activeMessage and ns.guild.messageList[ns.pSettings.activeMessage]) and ns.guild.messageList[ns.pSettings.activeMessage].message or nil
    self.msgWhisper = (ns.gmSettings.forceWhisperMessage and ns.gmSettings.sendWhisperGreeting and ns.gmSettings.whisperMessage ~= '') and ns.gmSettings.whisperMessage or (ns.pSettings.whisperMessage or nil)

    if ns.gmSettings.forceSendGuildGreeting and ns.gmSettings.sendGuildGreeting then self.useGuild = true
    elseif ns.isGM then self.useGuild = ns.gmSettings.sendGuildGreeting or false
    else self.useGuild = ns.pSettings.sendGuildGreeting or false end

    if ns.pSettings.inviteFormat == ns.InviteFormat.GUILD_INVITE_ONLY or not self.msgInvite then self.useInvite = false
    elseif ns.gmSettings.forceInviteMessage and ns.gmSettings.sendInviteMessage then self.useInvite = true
    else self.useInvite = self.msgInvite or false end

    if not self.msgWhisper then self.useWhisper = false
    elseif ns.gmSettings.forceWhisperMessage and ns.gmSettings.sendWhisperGreeting then self.useWhisper = true
    elseif ns.isGM then self.useWhisper = ns.gmSettings.sendWhisperGreeting or false
    else self.useWhisper = ns.pSettings.sendWhisperGreeting or false end
end
--* System Message Chat Observers
function invite:RegisterInviteObservers()
    local function getPlayerName(msg)
        for k in pairs(self.tblInvited) do
            if msg:match(k) then return k
            elseif msg:match(k:gsub('%-.*', '')) then return k end
        end
    end
    local function eventPLAYER_JOINED_GUILD(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        local r = self.tblInvited[playerName]
        GR:CancelTimer(r.timeOutTimer)
        C_Timer.After(3, function()
            if r.useGuildWelcome then SendChatMessage(ns.code:variableReplacement(self.msgGuild, r.nameOnly, true), 'GUILD') end
            if r.useWelcomeWhisper then queueMessage(r.fullName, ns.code:variableReplacement(self.msgWhisper, r.nameOnly)) end
        end)

        ns.analytics:UpdateData('ACCEPTED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_ACCEPTED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)

        self.tblInvited[playerName] = nil
    end
    local function eventPLAYER_DECLINED_INVITE(...)
        local msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblInvited[playerName].timeOutTimer)
        self.tblInvited[playerName] = nil

        ns.analytics:UpdateData('DECLINED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_DECLINED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    end
    local function eventPLAYER_NOT_ONLINE(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblInvited[playerName].timeOutTimer)
        self.tblInvited[playerName] = nil

        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    end
    local function eventPLAYER_NOT_PLAYING(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblInvited[playerName].timeOutTimer)
        self.tblInvited[playerName] = nil

        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    end
    local function eventPLAYER_NOT_FOUND(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblInvited[playerName].timeOutTimer)
        self.tblInvited[playerName] = nil

        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    end
    local function eventPLAYER_IN_GUILD(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblInvited[playerName].timeOutTimer)
        self.tblInvited[playerName] = nil

        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    end
    local function eventPLAYER_ALREADY_IN_GUILD(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblInvited[playerName].timeOutTimer)
        self.tblInvited[playerName] = nil

        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    end

    ns.observer:Register('PLAYER_JOINED_GUILD', eventPLAYER_JOINED_GUILD)
    ns.observer:Register('PLAYER_DECLINED_INVITE', eventPLAYER_DECLINED_INVITE)
    ns.observer:Register('PLAYER_NOT_ONLINE', eventPLAYER_NOT_ONLINE)
    ns.observer:Register('PLAYER_NOT_PLAYING', eventPLAYER_NOT_PLAYING)
    ns.observer:Register('PLAYER_NOT_FOUND', eventPLAYER_NOT_FOUND)
    ns.observer:Register('PLAYER_IN_GUILD', eventPLAYER_IN_GUILD)
    ns.observer:Register('PLAYER_ALREADY_IN_GUILD', eventPLAYER_ALREADY_IN_GUILD)
end
--#endregion

--#region Check if can Invite Routines
function invite:CheckWhoList(player, zoneName) return self:CheckInvite(player, true, true, true, zoneName) end
function invite:CheckAutoInvite(player) return self:CheckInvite(player, false, true, false) end
function invite:CheckManualInvite(player) return self:CheckInvite(player, false, true, false) end
function invite:CheckInvite(player, antispam, blacklist, zones, zoneName)
    if not player then ns.code:cOut('CheckInvite: No name provided.') return end

    local blReason = ns.list:BlacklistReason(player)
    if antispam and ns.list:CheckAntiSpam(player) then return false, L["ANTI_SPAM"] end
    if blacklist and ns.list:CheckBlacklist(player) then return false, (blReason or L["BLACKLIST"]) end
    if zones and zoneName and (zoneName == 'Delves' or ns.invalidZones[strlower(zoneName)]) then return false, L['INVALID_ZONE'] end

    return true, ''
end
--#endregion

--#region Invite Player Routines
function invite:AutoInvite(fullName, justName, inviteFormat)
    justName = (not justName or justName:match('-')) and fullName:gsub('%-.*', '') or justName
    local sendInviteMessage = inviteFormat ~= ns.InviteFormat.MESSAGE_ONLY or false
    return self:InvitePlayer(fullName, justName, sendInviteMessage, self.useInvite, self.useGuild, self.useWhisper)
end
function invite:ManualInvite(fullName, justName, sendGuildInvite, sendInviteMessage, sendWelcomeMessage, sendWelcomeWhisper)
    justName = (not justName or justName:match('-')) and fullName:gsub('%-.*', '') or justName
    return self:InvitePlayer(fullName, justName, (sendGuildInvite or false), (sendInviteMessage or false), not ((sendWelcomeMessage and self.msgGuild) or false), not ((sendWelcomeWhisper and self.msgWhisper) or false))
end
function invite:InvitePlayer(fullName, justName, sendGuildInvite, useInviteMessage, useGuildWelcome, useWelcomeWhisper)
    local name_with_realm = strlower(fullName:match('-') and fullName or fullName .. '-' .. GetRealmName())

    if GR.isTesting then
        fullName =  testingPlayerName or ns.classic and 'Pokypoke' or 'Monkstrife'
        name_with_realm = strlower(fullName:match('-') and fullName or fullName .. '-' .. GetRealmName())
        ns.code:fOut('Testing mode is enabled. Invites sent to: '..fullName..'.')
    elseif self.tblInvited[name_with_realm] then return false, L['ALREADY_INVITED'] end

    useInviteMessage = (useInviteMessage and self.msgInvite) or false

    local newInvite = {
        pName = fullName,
        fullName = name_with_realm,
        nameOnly = justName,
        useGuildWelcome = useGuildWelcome,
        useWelcomeWhisper = useWelcomeWhisper,
        timeOutTimer = GR:ScheduleTimer(function()
            self.tblInvited[name_with_realm] = nil
            ns.code:cOut('Invite sent to '..fullName..' timed out.')
            ns.analytics:UpdateSessionData('SESSION_INVITE_TIMED_OUT') end, INVITE_TIME_OUT)
    }
    self.tblInvited[fullName] = newInvite
    ns.list:AddToAntiSpam(name_with_realm)

    ns.analytics:UpdateData('INVITED_GUILD')
    ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD')
    ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE')

    if sendGuildInvite then
        C_GuildInfo.Invite(fullName)
        ns.code:fOut(L['GUILD_INVITE_SENT']..' '..fullName, ns.COLOR_SYSTEM, true)
    end

    if useInviteMessage then
        local msg = ns.code:variableReplacement(self.msgInvite, justName)
        if ns.gmSettings.obeyBlockInvites or ns.gSettings.obeyBlockInvites then
            C_Timer.After(1, function()
                if self.tblInvited[fullName] then queueMessage(fullName, msg)
                else ns.code:cOut('Invite message skipped for '..fullName..' due to blocked guild invites.') end
            end)
        else queueMessage(fullName, msg) end
    end
end
--#endregion