-- Handle all invite routines
local _, ns = ... -- Namespace (myaddon, namespace)
local p,g, dbInv = nil, nil, nil

ns.Invite = {}
local invite = ns.Invite
function invite:Init()
    self.tblInvited = nil
    self.tblSentInvite = {}
end
function invite:updateDB() p,g, dbInv = ns.db.profile, ns.db.global, ns.dbInv.global end
function invite:new(class)
    return {
        ['playerClass'] = class or '',
        ['invitedBy'] = UnitGUID('player'),
        ['invitedOn'] = C_DateAndTime.GetServerTimeLocal(),
    }
end
function invite:load()
    invite:updateDB()
    self.tblInvited = dbInv.invitedPlayers or {}
end
function invite:save()
    invite:updateDB()
    dbInv.invitedPlayers = self.tblInvited
end
function invite:canAddPlayer(pName, zone, showError, force)
    if not pName then return false
    elseif not self.tblInvited then invite:load() end

    local canAddPlayer = nil
    if not force and self.tblInvited[pName] then canAddPlayer = 'INVITED'
    elseif ns.BlackList:IsOnBlackList(pName) then canAddPlayer = 'BLACKLIST'
    elseif zone and ns.datasets.tblBadZones[zone] then canAddPlayer = 'ZONE' end

    if not showError and not canAddPlayer then return true
    elseif not showError and canAddPlayer then return false
    elseif not canAddPlayer then return true
    elseif canAddPlayer == 'INVITED' then ns.code:consoleOut(pName..' has been invited recently.')
    elseif canAddPlayer == 'BLACKLIST' then ns.code:consoleOut(pName..' has been black listed, remove before inviting.')
    elseif canAddPlayer == 'ZONE' then ns.code:consoleOut(pName..' is in an instanced zone.') end
end
function invite:logInvite(pName, class)
    if not pName or not class or self.tblInvited[pName] then return
    elseif g.rememberPlayers then
        if not self.tblInvited then invite:load() end
        self.tblInvited[pName] = invite:new(class)
        invite:save()
    end
end

function GRADDON:ChatMsgHandler(_, msg,_)
    if not self.tblSentInvite then self.tblSentInvite = {} end

    local function eraseRecord(pName)
        if not pName or not self.tblSentInvite[pName] then return
        else self.tblSentInvite[pName] = nil end
    end

    local pName = msg:match('(.-) ')
    if not strmatch(msg, 'guild') then return
    elseif strmatch(msg, 'to join your guild') then
        local trimmed = gsub(msg, 'You have invited ', '')
        pName = trimmed:match('(.-) ') or nil
        if pName then self.tblSentInvite[pName] = true end
        ns.Analytics:add('Invited_Players')
    elseif strmatch(msg, 'joined the guild') then
        if dbInv.invitedPlayers[pName] then
            ns.Analytics:add('Accepted_Invite')
            eraseRecord(pName)
        end
    elseif strmatch(msg, 'declines your guild') then
        if dbInv.invitedPlayers[pName] then
            ns.Analytics:add('Declined_Invite')
            eraseRecord(pName)
        end
    end

    local c = 0
    if self.tblSentInvite then
        for _ in pairs(self.tblSentInvite) do c = c + 1 end
    end
    if c == 0 then GRADDON:UnregisterEvent('CHAT_MSG_SYSTEM') end
end
function invite:invitePlayer(pName, msg, sendInvite, _, class)
    if not pName then return end

    invite:updateDB()
    class = class and class or select(2, UnitClass(pName))
    if pName and CanGuildInvite() and not GetGuildInfo(pName) then
        if msg and p.inviteFormat ~= 4 then SendChatMessage(msg, 'WHISPER', nil, pName) end
        GRADDON:RegisterEvent('CHAT_MSG_SYSTEM', 'ChatMsgHandler')
        if sendInvite then GuildInvite(pName)
        else
            if pName then
                self.tblSentInvite[pName] = true
                GRADDON:UnregisterEvent('CHAT_MSG_SYSTEM')
            end
            ns.Analytics:add('Invited_Players')
        end

        invite:logInvite(pName, class)
    end
end
invite:Init()