-- Handle all invite routines
local _, ns = ... -- Namespace (myaddon, namespace)
local p,g, dbInv = nil, nil, nil

-- Keep whispers from showing in chat (only if sentMsg matches)
local sentMsg, showWhispers = nil, true
local function MyWhisperFilter(self, event, message, sender)
    local killMessage = message:match('away') or false
    if showWhispers then ns.code:consoleOut('Sending invite message to '..sender) end
    if killMessage or message == sentMsg then return not showWhispers end -- Returning true will hide the message
end

ns.Invite = {}
local invite = ns.Invite
function invite:Init()
    self.tblInvited = nil
    self.tblSentInvite = {}

    self.waitWelcome = false
    self.chatWhisperInform = false
end
function invite:updateDB()
    p,g, dbInv = ns.db.profile, ns.db.global, ns.dbInv.global
    showWhispers = g.showWhisper or false
    self.tblInvited = dbInv.invitedPlayers or {}
end
function invite:new(class)
    return {
        ['playerClass'] = class or '',
        ['invitedBy'] = UnitGUID('player'),
        ['invitedOn'] = C_DateAndTime.GetServerTimeLocal(),
    }
end
-- Invite Routines
function invite:recordInvite(pName, class)
    if not self.tblInvited then invite:updateDB() end

    ns.Analytics:add('Invited_Players')
    if not pName or not class then return
    elseif g.rememberPlayers then
        pName = gsub(pName, '-'..GetRealmName(), '')
        self.tblInvited[pName] = invite:new(class)
        self.tblSentInvite[pName] = self.tblInvited[pName]
        dbInv.invitedPlayers = self.tblInvited
    end
end
function invite:canAddPlayer(pName, zone, showError, force)
    if not self.tblInvited then invite:updateDB() end

    local canAddPlayer = nil
    if not force and self.tblInvited[pName] then canAddPlayer = 'INVITED'
    elseif ns.BlackList:IsOnBlackList(pName) then canAddPlayer = 'BLACKLIST'
    elseif zone and ns.datasets.tblBadZones[zone] then canAddPlayer = 'ZONE' end

    if showError then
        if canAddPlayer == 'INVITED' then ns.code:consoleOut(pName..' has been invited recently.')
        elseif canAddPlayer == 'BLACKLIST' then ns.code:consoleOut(pName..' has been black listed, remove before inviting.')
        elseif canAddPlayer == 'ZONE' then ns.code:consoleOut(pName..' is in an instanced zone.') end
    end

    return not (canAddPlayer or false)
end
function invite:invitePlayer(pName, msg, sendInvite, _, class)
    if not self.tblInvited then invite:updateDB() end

    class = class and class or select(2, UnitClass(pName))
    if pName and CanGuildInvite() and not GetGuildInfo(pName) then
        if msg and p.inviteFormat ~= 4 then
            if not showWhispers then
                sentMsg = msg
                ns.code:consoleOut('Sent invite to '..(ns.code:cPlayer(pName, class) or pName))

                if not self.chatWhisperInform then
                    self.chatWhisperInform = true
                    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", MyWhisperFilter)
                end
            end
            SendChatMessage(msg, 'WHISPER', nil, pName)
        end

        if sendInvite then GuildInvite(pName) end
        invite:recordInvite(pName, class)
    end
end
-- Chat Message Handler
function invite:ChatMsgHandler(msg)
    if not self.tblInvited then invite:updateDB() end

    local function eraseRecord(pName)
        if not pName or not self.tblSentInvite[pName] then return
        else self.tblSentInvite[pName] = nil end
    end

    local pName = msg:match('(.-) ')
    pName = gsub(pName, '-'..GetRealmName(), '')
    if not strmatch(msg, 'guild') then return
    elseif strmatch(msg, 'to join your guild') then
        if pName and not self.tblSentInvite[pName] then
            invite:recordInvite(pName, select(2, UnitClass(pName)) or nil)
        end
    elseif strmatch(msg, 'joined the guild') and self.tblSentInvite and self.tblSentInvite[pName] then
        if not self.waitWelcome and p.showGreeting and p.greeting then
            self.waitWelcome = true
            C_Timer.After(5, function()
                ns.Invite.waitWelcome = false
                SendChatMessage(p.greeting, 'GUILD')
            end)
        end
        eraseRecord(pName)
        ns.Analytics:add('Accepted_Invite')
    elseif strmatch(msg, 'declines your guild') then
        ns.Analytics:add('Declined_Invite')
        eraseRecord(pName)
    end
end
function invite:ProcessGuildInvite()
    self.waitWelcome = false

    local c = 0
    for _ in pairs(self.tblSentInvite) do c = c + 1 end

    if c > 0 then
        C_GuildInfo.GuildRoster()

        local sendWelcome = false
        for index=1,GetNumGuildMembers() do
            local name = gsub(GetGuildRosterInfo(index), '-'..GetRealmName(), '')
            if self.tblSentInvite[name] then
                sendWelcome = true

                self.tblSentInvite[name] = nil
                ns.Analytics:add('Accepted_Invite')
            end
        end

        if sendWelcome and p.showGreeting and p.greeting then
            SendChatMessage(p.greeting, 'GUILD') end
    end
end
function invite:GuildRosterHandler(rosterUpdate)
    if rosterUpdate and not self.waitWelcome then
        C_GuildInfo.GuildRoster()
        self.waitWelcome = true
        C_Timer.After(5, function() ns.Invite:ProcessGuildInvite() end)
    end
end
invite:Init()