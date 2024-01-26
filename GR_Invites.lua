local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

-- CHAT_MSG_SYSTEM Event
local function UpdateInvitePlayerStatus(doUpdate, ...)
    local msg = ...
    local invite = ns.invite
    doUpdate = type(doUpdate) == 'boolean' and doUpdate or false
    if not doUpdate and not msg then return end

    local pName = ''
    if msg then
        local newMsg = msg:gsub("'", ''):gsub(L['no player named'], ''):trim()
        pName = newMsg:match("^(.-)%s")
        if not pName then return end
        pName = pName:match('-') and pName or pName..'-'..GetRealmName()
    end

    local function updateSent(index)
        if index then
            invite.tblSent[pName] = nil
            ns.analytics:saveStats(index, true)
            ns.analytics:saveStats('WaitingOnPlayer', -1)
            ns.code:dOut(pName.."'s invite has been "..index)
        end

        invite.sentCount = 0
        for k, r in pairs(invite.tblSent) do
            if r.sentTime then
                local time = GetTime() - r.sentTime
                if time >= 120 then
                    invite.tblSent[k] = nil
                    invite.sentCount = invite.sentCount - 1
                    ns.analytics:saveStats('WaitingOnPlayer', -1)
                    ns.code:dOut(k.."'s invite has timed out.")
                else invite.sentCount = invite.sentCount + 1 end
            end
        end
    end
    local function cancelInvite()
        if not invite.tblSent[pName] then return end

        invite.tblSent[pName] = nil
        ns.analytics:saveStats('PlayersInvited' -1)
        ns.analytics:saveStats('WaitingOnPlayer', -1)
        ns.code:dOut(pName.."'s invite has declined.")
    end

    if doUpdate then updateSent() return
    elseif not msg then return end

    if not invite.tblSent[pName] then
        ns.code:dOut('Player '..pName..' is not on the sent list.')
        return
    end

    local showWelcome = ns.gmSettings.sendWelcome or ns.gSettings.sendWelcome
    local msgWelcome = (ns.gmSettings.sendWelcome and ns.gmSettings.welcomeMessage) and ns.gmSettings.welcomeMessage or ns.gSettings.welcomeMessage

    local showGreeting = ns.gmSettings.sendGreeting or ns.gSettings.sendGreeting
    local msgGreeting = (ns.gmSettings.sendGreeting and ns.gmSettings.greetingMessage) and ns.gmSettings.greetingMessage or ns.gSettings.greetingMessage

    if msg:match(L['is not online']) then ns.code:dOut('Not Online') cancelInvite()
    elseif msg:match(L['has already been invited to a guild']) then cancelInvite()
    elseif strlower(msg):match(L["player not found"]) then cancelInvite()
    elseif msg:match(L["is already in a guild"]) then cancelInvite()
    elseif strlower(msg):match(L['no player named']) then cancelInvite()
    elseif msg:match(L['declines your guild invitation']) then updateSent('PlayersDeclined')
    elseif msg:match(L["joined the guild"]) then
        if not invite.tblSent[pName].skipGreetings and  showWelcome and msgWelcome then
            msgWelcome = ns.code:variableReplacement(msgWelcome, pName, 'REMOVE<>')
            SendChatMessage(msgWelcome, 'GUILD')
        end

        if not invite.tblSent[pName].skipGreetings and showGreeting and msgGreeting then
            msgGreeting = ns.code:variableReplacement(msgGreeting, pName, 'REMOVE<>')
            SendChatMessage(msgGreeting, 'WHISPER', nil, pName)
        end

        updateSent('PlayersJoined')
        ns.code:cOut(pName..' '..L['JOINED_GUILD_MESSAGE'])
    end
    ns.screens.scanner:UpdateAnalyticsSection()

    invite.sentCount = 0
    for _ in pairs(invite.tblSent) do invite.sentCount = invite.sentCount + 1 end
    if invite.sentCount == 0 then
        invite.sentCheckTimer = false
        ns.observer:Unregister("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)
    end
end

ns.invite = {}
local invite = ns.invite
function invite:Init()
    self.sentCount = 0
    self.sentCheckTimer = false

    self.antiSpam = false
    self.showWhispers = false

    self.tblSent = {}
end
function invite:StartUp()
    self.antiSpam = ns.gmSettings.antiSpam or  ns.gSettings.antiSpam
    self.showWhispers = ns.gmSettings.showWhispers or ns.gSettings.showWhispers
end
function invite:new(class, name)
    return {
        ['PlayerName'] = name,
        ['playerClass'] = class or '',
        ['invitedBy'] = UnitGUID('player'),
        ['invitedOn'] = C_DateAndTime.GetServerTimeLocal(),
    }
end
function invite:CheckIfCanBeInvited(r, skipChecks)
    local withRealm = r.fullName:match('-') and r.fullName or r.fullName..'-'..GetRealmName()
    if skipChecks then return true
    elseif not r or not r.fullName then
        ns.code:dOut('No invite record or name.')
        return false
    elseif ns.blackList:CheckBlackList(r.fullName) then
        ns.code:dOut('Player '..r.fullName..' is on the black list')
        return false
    elseif ns.tblInvited[r.fullName] or ns.tblInvited[withRealm] then
        ns.code:dOut(r.fullName..' is already on the invited list')
        return false
    elseif r.zone and ns.ds.tblBadZonesByName[r.zone] then
        ns.code:dOut('Player '..r.fullName..' is in '..ns.ds.tblBadZonesByName[r.zone].name)
        return false
    end

    return true
end
function invite:ReturnReason(name, zone)
    local withRealm = name:match('-') and name or name..'-'..GetRealmName()
    if not name then return ''
    elseif ns.tblInvited[name] or ns.tblInvited[withRealm] then return '<On Anti-Spam List>'
    elseif zone and ns.ds.tblBadZonesByName[zone] then return '<In an Instance>'
    elseif ns.blackList:CheckBlackList(withRealm) then return '<On Black List>'
    else return '' end
end
function invite:AddToInvitedList(name, class)
    if not name:trim() then ns.code:fOut((name or 'NO NAME')..' '..L['SENT_LIST_ERROR']) return false end

    name = name:match('-') and name or name..'-'..GetRealmName()
    if ns.tblInvited[name] then ns.code:dOut(name..' '..L['ALREADY_ON_SENT_LIST']) return true end

    ns.tblInvited[name] = invite:new(class, name)
    return true
end
function invite:InvitePlayer(name, sendGuildInvite, whisperMessage, skipGreetings, manualInvite)
    if not name then return
    elseif not CanGuildInvite() then ns.code:fOut(L['CANNOT_GUILD_INVITE']) return
    elseif sendGuildInvite and (GetGuildInfo(name) or GetGuildInfo(name..'-'..GetRealmName())) then ns.code:fOut(name..' '..L['PLAYER_IN_GUILD']) return end

    local nameWithRealm = name:match('-') and name or name..'-'..GetRealmName()
    if manualInvite and ns.blackList:CheckBlackList(nameWithRealm) then
        ns.code:fOut(nameWithRealm..' '..L['IS_ON_BLACK_LIST'])
        ns.code:fOut(L['Reason']..': '..(ns.blackList:GetBlackListReason(nameWithRealm) or L['No Reason']))
        if not ns.code:Confirmation(nameWithRealm..L['CONFIRM_BLACK_LIST_INVITE'], function() ns.code:dOut('Inviting player from black list.') end) then return end
        ns.tblBlackList[nameWithRealm].markedForDelete = true
    elseif ns.blackList:CheckBlackList(nameWithRealm) then return end

    if ns.settings.inviteFormat ~= 2 and not whisperMessage and not manualInvite then
        ns.code:fOut('No message selected. Please select a message in the home screen.')
        return
    end

    ns.observer:Register("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)

    if manualInvite or sendGuildInvite then
        GuildInvite(name)
        if not whisperMessage then
            ns.code:fOut(L['GUILD_INVITE_SENT']..' '..name) end
    end

    if not manualInvite and ns.settings.inviteFormat ~= 2 then
        whisperMessage = ns.code:variableReplacement(whisperMessage, name)

        -- Sets up for erasing whispered message
        local showWhispers = ns.gSettings.showWhispers
        local function MyWhisperFilter(_,_, message)
            if whisperMessage == message then return not showWhispers
            else return false end -- Returning true will hide the message
        end

        if not showWhispers then
            ns.code:fOut(L['GUILD_MESSAGE_SENT']..' '..name)
            ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", MyWhisperFilter, whisperMessage)
        end
        SendChatMessage(whisperMessage, 'WHISPER', nil, name)
    end

    ns.analytics:saveStats('PlayersInvited')
    self.tblSent[nameWithRealm] = { skipGreetings = (skipGreetings or false), sentTime = GetTime() }
    self.sentCount = self.sentCount + 1

    if not manualInvite and self.antiSpam and ns.settings.inviteFormat ~= 1 then
        ns.analytics:saveStats('WaitingOnPlayer', true)
    end
    if not manualInvite then invite:AddToInvitedList(nameWithRealm, UnitClass(nameWithRealm)) end
    ns.screens.scanner:UpdateAnalyticsSection()

    local function refreshSent()
        UpdateInvitePlayerStatus(true)
        ns.screens.scanner:UpdateAnalyticsSection()

        if self.sentCheckTimer and self.sentCount > 0 then
            C_Timer.After(30, function() refreshSent() end)
        elseif self.sentCount == 0 then
            self.sentCheckTimer = false
            ns.observer:Unregister("CHAT_MSG_SYSTEM", UpdateInvitePlayerStatus)
        end
    end

    if not self.sentCheckTimer then
        self.sentCheckTimer = true
        refreshSent()
    end
end
invite:Init()