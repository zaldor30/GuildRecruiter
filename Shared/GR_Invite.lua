local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.invite = {}
local invite = ns.invite

function invite:Init()
    self.mGuild = nil
    self.mInvite = nil
    self.mWhisper = nil

    self:GetMessage()
    self:RegisterInviteObservers()

    self.tblQueue = self.tblQueue or {}
    self.tblQueueMessages = self.tblQueueMessages or {}
    self.inviteQueueRunning = false
end

--* Get Messages
function invite:GetMessage()
    self.mGuild, self.mInvite, self.mWhisper = nil, nil, nil

    --* Guild Chat Welcome Message
    if ns.gmSettings.forceSendGuildGreeting or (ns.core.hasGM and ns.gmSettings.sendGuildGreeting) then
        self.mGuild = ns.gmSettings.guildMessage or L['DEFAULT_GUILD_WELCOME']
    elseif not ns.core.hasGM and ns.pSettings.sendGuildGreeting then
        self.mGuild = ns.pSettings.guildMessage or L['DEFAULT_GUILD_WELCOME']
    end

    --* Guild Invite Message
    if ns.pSettings.activeMessage and ns.guild.messageList[ns.pSettings.activeMessage] then
        self.mInvite = ns.guild.messageList[ns.pSettings.activeMessage].message
    end

    --* Whisper Welcome Message
    if ns.gmSettings.forceSendWhisper or (ns.core.hasGM and ns.gmSettings.sendWhisperGreeting) then
        self.mWhisper = (ns.gmSettings.whisperMessage and ns.gmSettings.whisperMessage ~= '') and ns.gmSettings.whisperMessage or nil
    elseif not ns.core.hasGM and ns.pSettings.sendWhisperGreeting then
        self.mWhisper = (ns.pSettings.whisperMessage and ns.pSettings.whisperMessage ~= '') and ns.pSettings.whisperMessage or nil
    end
end

--* Plaayer Invite Check Routines
function invite:CheckWhoList(player, zoneName) return self:CheckInvite(player, true, true, true, zoneName) end
function invite:CheckAutoInvite(player) return self:CheckInvite(player, false, true, false) end
function invite:CheckManualInvite(player) return self:CheckInvite(player, false, true, false) end
function invite:CheckInvite(player, antispam, blacklist, zones, zoneName)
    if not player then ns.code:cOut('CheckInvie: No name provided.') return end
    local fName = player:match('-') and player or player..'-'..GetRealmName()
    fName = strlower(fName)

    if antispam and ns.tblAntiSpamList[fName] then return false, L["ANTI_SPAM"] end
    if blacklist and ns.tblBlackList[fName] then return false, L["BLACKLIST"] end
    if zones and zoneName and ns.invalidZones[strlower(zoneName)] then return false, L['INVALID_ZONE'] end

    return true, ''
end

--* Player Invite Routines
function invite:AutoInvite(fullName, justName, inviteFormat)
    justName = (not justName or justName:match('-')) and fullName:gsub('%-.*', '') or justName
    local sendInvite = inviteFormat == ns.InviteFormat.MESSAGE_ONLY and false or true
    return self:InvitePlayer(fullName, justName, sendInvite, not self.mInvite, not self.mGuild, not self.mWhisper)
end
function invite:ManualInvite(fullName, justName, sendGuildInvite, skipInviteMessage, skipWelcomeGuild, skipWelcomeWhisper)
    justName = (not justName or justName:match('-')) and fullName:gsub('%-.*', '') or justName
    return self:InvitePlayer(fullName, justName, sendGuildInvite, skipInviteMessage, skipWelcomeGuild, skipWelcomeWhisper)
end
function invite:InvitePlayer(fullName, justName, sendGuildInvite, skipInviteMessage, skipWelcomeGuild, skipWelcomeWhisper)
    fullName = GR.isTesting and 'Hideme' or fullName
    local nameRealm = fullName:match('-') and fullName or fullName..'-'..GetRealmName()
    nameRealm = strlower(nameRealm)

    local queueTable = self.tblQueue[fullName] or nil
    if queueTable and queueTable.sentInvite then return end

    local timeOutTimer = GR:ScheduleTimer(function()
        self.tblQueue[fullName] = nil
        self:UpdateAnalytics('declined')
    end, 120)
    local newInvite = {
        sentInvite = sendGuildInvite,
        welcomeGuild = (skipWelcomeGuild or not self.mGuild) and nil or ns.code:variableReplacement(self.mGuild, justName, 'Remove <>'),
        welcomeWhisper = (skipWelcomeWhisper or not self.mWhisper) and nil or ns.code:variableReplacement(self.mWhisper, justName, 'Remove <>'),
        timeOutTimer = timeOutTimer
    }
    self.tblQueue[fullName] = newInvite

    local newAntiSpam = {
        time = time(),
        name = fullName,
        realm = GetRealmName()
    }
    ns.tblAntiSpamList[nameRealm] = newAntiSpam

    self:UpdateAnalytics('queued')
    self:UpdateAnalytics('invited')

    if sendGuildInvite then
        C_GuildInfo.Invite(fullName)
        ns.code:fOut(L['GUILD_INVITE_SENT']..' '..fullName, ns.COLOR_SYSTEM)
    end
    if not skipInviteMessage and self.mInvite and self.tblQueue[fullName] then
        local msg = ns.code:variableReplacement(self.mInvite, justName)
        if ns.gmSettings.obeyBlockInvites or ns.gSettings.obeyBlockInvites then
            C_Timer.After(1, function()
                if self.tblQueue[fullName] then tinsert(self.tblQueueMessages,  { name = fullName, msg = msg })
                else ns.code:fOut('Message skipped for '..fullName..' due to blocked guild invites.') end
            end)
        else tinsert(self.tblQueueMessages,  { name = fullName, msg = msg }) end

        if not self.inviteQueueRunning then
            self.inviteQueueRunning = true
            self:RunInviteQueue(#self.tblQueueMessages)
        end
    end
end

--* Send Message Queue
function invite:RunInviteQueue(remaining)
    remaining = (remaining and remaining > 0) and remaining or 0
    if remaining == 0 then self.inviteQueueRunning = false return end

    local rec = tremove(self.tblQueueMessages, 1)

    local message = rec.msg
    if not ns.pSettings.showWhispers then
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', function(_, _, msg) return msg == message end, message)
        ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', function(_, _, msg) return msg == message end, message)
        SendChatMessage(message, 'WHISPER', nil, rec.name)
        ns.code:fOut(L['INVITE_MESSAGE_SENT']..' '..rec.name, ns.COLOR_SYSTEM)
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER', message)
        ChatFrame_RemoveMessageEventFilter('CHAT_MSG_WHISPER_INFORM', message)
    else SendChatMessage(message, 'WHISPER', nil, rec.name) end

    C_Timer.After(0.2, function() self:RunInviteQueue(#self.tblQueueMessages or 0) end)
end

--* System Chat Obersvers
function invite:RegisterInviteObservers()
    local function getPlayerName(msg)
        for k in pairs(self.tblQueue) do
            if msg:match(k) then return k end
        end
    end
    local function sendMessages(r)
        if r.welcomeGuild then
            SendChatMessage(r.welcomeGuild, 'GUILD')
        end
        if r.welcomeWhisper then
            SendChatMessage(r.welcomeWhisper, 'WHISPER', nil, r.fullName)
        end
    end
    local function eventPLAYER_JOINED_GUILD(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblQueue[playerName].timeOutTimer)
        C_Timer.Afer(3, function() sendMessages(self.tblQueue[playerName]) end)
        invite:UpdateAnalytics('accepted')
        self.tblQueue[playerName] = nil
    end
    local function eventPLAYER_DECLINED_INVITE(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblQueue[playerName].timeOutTimer)
        self.tblQueue[playerName] = nil
        invite:UpdateAnalytics('declined')
    end
    local function eventPLAYER_NOT_ONLINE(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblQueue[playerName].timeOutTimer)
        self.tblQueue[playerName] = nil
        invite:UpdateAnalytics('offline')
    end
    local function eventPLAYER_NOT_PLAYING(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblQueue[playerName].timeOutTimer)
        self.tblQueue[playerName] = nil
        invite:UpdateAnalytics('playing')
    end
    local function eventPLAYER_NOT_FOUND(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblQueue[playerName].timeOutTimer)
        self.tblQueue[playerName] = nil
        invite:UpdateAnalytics('notfound')
    end
    local function eventPLAYER_IN_GUILD(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblQueue[playerName].timeOutTimer)
        self.tblQueue[playerName] = nil
        invite:UpdateAnalytics('alreadyinguild')
    end
    local function eventPLAYER_ALREADY_IN_GUILD(...)
        local _, msg = ...
        local playerName = getPlayerName(msg)
        if not playerName then return end

        GR:CancelTimer(self.tblQueue[playerName].timeOutTimer)
        self.tblQueue[playerName] = nil
        invite:UpdateAnalytics('alreadyinguild')
    end

    ns.observer:Register('PLAYER_JOINED_GUILD', eventPLAYER_JOINED_GUILD)
    ns.observer:Register('PLAYER_DECLINED_INVITE', eventPLAYER_DECLINED_INVITE)
    ns.observer:Register('PLAYER_NOT_ONLINE', eventPLAYER_NOT_ONLINE)
    ns.observer:Register('PLAYER_NOT_PLAYING', eventPLAYER_NOT_PLAYING)
    ns.observer:Register('PLAYER_NOT_FOUND', eventPLAYER_NOT_FOUND)
    ns.observer:Register('PLAYER_IN_GUILD', eventPLAYER_IN_GUILD)
    ns.observer:Register('PLAYER_ALREADY_IN_GUILD', eventPLAYER_ALREADY_IN_GUILD)
end -- System Chat Observers

function invite:UpdateAnalytics(field, amt)
    if not field then return end
    amt = amt or 1
end