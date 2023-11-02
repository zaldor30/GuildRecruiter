local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

--[[ This is for reusable code found throughout the addon
    This code contains the following namespaces:
        ns.invite
        ns.analytics
        ns.blackList
]]

ns.invite, ns.blackList, ns.analytics = {}, {}, {}
local invite, blackList, analytics = ns.invite, ns.blackList, ns.analytics
local ap, ag = nil, nil

local function GuildRosterHandler(...)
    local _, msg =  ...
    if not msg or not invite.notifyActive then return end

    local newMsg = msg:gsub("'", ''):gsub(L['no player named'], ''):gsub(L["No Player Named"]..' ', '')
    local pName = newMsg:match("([^%s]+)")--("^(.-)%s")
    pName = pName and pName:gsub('-'..GetRealmName(), '') or pName

    if msg:match(L["is already in a guild"]) then
        ns.scanner:TotalInvited(-1)
        if invite.tblSent[pName] then invite.tblSent[pName] = nil end
        return
    end
    if not invite.tblSent[pName] then return end

    local forceWelcome = ns.dbGlobal.guildInfo.sendWelcome or false
    local showWelcome = forceWelcome or ns.settings.sendWelcome
    local msgWelcome = (forceWelcome and ns.dbGlobal.guildInfo.welcomeMsg ~= '') and ns.dbGlobal.guildInfo.welcomeMsg or (ns.settings.welcomeMessage or '')

    local forceGreeting = ns.dbGlobal.guildInfo.greeting or false
    local showGreeting = forceGreeting or ns.settings.sendGreeting or false
    local msgGreeting = (forceGreeting and ns.dbGlobal.guildInfo.greetingMsg ~= '') and ns.dbGlobal.guildInfo.greetingMsg or (ns.settings.greetingMsg or '')

    if invite.tblSent[pName].skipWeclcome then
        showGreeting, showWelcome = false, false
    end

    local function UpdateSent()
        for k, r in pairs(invite.tblSent) do
            if r and r.sentTime then
                local time = GetTime() - r.sentTime
                if time > 120 then
                    invite.tblSent[k] = nil
                    ns.scanner:TotalUnknown(-1)
                end
            end
        end

        local sentCount = 0
        for _ in pairs(invite.tblSent) do sentCount = sentCount + 1 end

        local tbl = ns.scanner:GetSessionData()
        if sentCount == 0 or (tbl and tbl['Total_Unknown'] == 0) then
            invite.notifyActive = false end
    end

    if msg:match(L["Player not found"]) then ns.scanner:TotalInvited(-1)
    elseif msg:match(L['is not online']) then ns.scanner:TotalInvited(-1)
    elseif strlower(msg):match(L['no player named']) then ns.scanner:TotalInvited(-1)
    elseif msg:match(L["joined the guild"]) then
        if showGreeting and  msgGreeting ~= '' and pName then
            SendChatMessage(ns.code:variableReplacement(msgGreeting, pName, 'REMOVE<>'), 'WHISPER', nil, pName)
        end
        if showWelcome and  msgWelcome ~= '' then
            C_Timer.After(math.random(3,8), function()
                SendChatMessage(ns.code:variableReplacement(msgWelcome, pName, 'REMOVE<>'):gsub('<', ''):gsub('>', ''), 'GUILD')
            end)
        end

        invite.tblSent[pName] = nil
        ns.scanner:TotalAccepted()
        ns.scanner:TotalUnknown(-1)

        ns.code:cOut(pName..' '..L['JOINED_GUILD_MESSAGE'])
        return
    elseif msg:match(L["is already in a guild"]) then ns.scanner:TotalInvited(-1)
    elseif msg:match(L['declines your guild invitation']) then ns.scanner:TotalDeclined() end

    if invite.tblSent[pName] then
        UpdateSent()
        invite.tblSent[pName] = nil
        ns.scanner:TotalUnknown(-1)
    end
end

-- Invite Routines
function invite:Init()
    self.notifyActive = false
    self.notifyEnabled = false

    -- Misc Variables
    self.antiSpam = false
    self.showWhsipers = false

    -- Message Shown in Guild Chat
    self.msgWelcome = ''
    self.showWelcome = false

    -- Message Whispered to Player After Invite
    self.msgGreeting = ''
    self.showGreeting = false

    self.tblSent = {}
end
function invite:InitializeInvite()
    ap, ag = ns.dbAP, ns.dbAG

    self.antiSpam = ns.settings.antiSpam or true
    self.showWhispers = ns.settings.showWhispers or false

    blackList.tblBlackList = ns.tblBlackList or {}
end
function invite:new(class, name)
    return {
        ['playerClass'] = class or '',
        ['invitedBy'] = UnitGUID('player'),
        ['invitedOn'] = C_DateAndTime.GetServerTimeLocal(),
    }
end
function invite:CheckIfCanBeInvited(r, skipChecks)
    if skipChecks then return true
    elseif not r or not r.fullName then
        ns.code:dOut('No invite record or name.')
        return false
    elseif ns.tblInvited[r.fullName] then
        --ns.code:dOut(r.name..' is already on the invited list')
        return false
    elseif r.zone and ns.ds.tblBadZones[r.zone] then
        ns.code:dOut('Player is nil or in a bad zone')
        return false
    elseif ns.blackList:CheckBlackList(r.fullName) then return false end

    return true
end
function invite:InvitePlayer(name, class, sendInvite, sendMessage, skipClassCheck, skipSent)
    class = class or select(2, UnitClass(name)) or nil
    local fName = (name and class) and ns.code:cPlayer(name, class) or name

    if not CanGuildInvite() then ns.code:fOut('You do not have permission to invite players to the guild.') return
    elseif not name or (not skipClassCheck and not class) then ns.code:fOut('Invite failed: Did not get a name or class.') return
    elseif sendInvite and GetGuildInfo(name) then ns.code:fOut(name..' is already in a guild.  Ask them to leave before inviting.') return end

    if blackList:CheckBlackList(name) then
        local tblBlackList = ns.tblBlackList[name] or ns.tblBlackList[name..'-'..GetRealmName()] or {}
        ns.code:fOut(fName..' is on the blacklist.')
        ns.code:fOut('Reason: '..(tblBlackList.reason or 'No reason given.'))
        ns.code:fOut('Blacklisted by: '..(select(6, GetPlayerInfoByGUID(tblBlackList.blacklistedBy)) or 'Unknown'))
        if not ns.code:Confirmation(fName..'Is on the black list.\n \n'..'Are you sure you want to invite this player?', function() ns.code:dOut('Inviting player from black list.') end) then return end
    end

    local whisperMessage = ns.scanner:ReturnWhispers()
    local msg = whisperMessage or nil
    if ns.settings.inviteFormat ~= 2 and sendMessage and not msg then
        ns.code:fOut('No message selected. Please select a message in the home screen.')
        return
    end

    if sendInvite == 'MANUAL' or (sendInvite and sendInvite ~= 1) then GuildInvite(name) end

    if ns.settings.inviteFormat ~= 2 and sendMessage and msg then
        msg = ns.code:variableReplacement(msg, name)

        local function MyWhisperFilter(_,_, message)
            if msg == message then return not self.showWhispers
            else return false end -- Returning true will hide the message
        end

        if not self.showWhispers then
            local msgOut = ns.settings.inviteFormat ~= 1 and 'Sent invite and message to ' or 'Sent message to '
            ns.code:fOut(msgOut..name)
            ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", MyWhisperFilter, msg)
        end

        SendChatMessage(msg, 'WHISPER', nil, name)
    end

    if self.antiSpam then
        invite:AddToSentList(name, class) end
    ns.scanner:TotalInvited()

    self.tblSent = self.tblSent or {}
    name = name and name:gsub('-'..GetRealmName(), '') or name
    self.tblSent[name] = self.tblSent[name] or {}
    self.tblSent[name] = {class = class, sentTime = GetTime() }
    self.tblSent[name].skipWeclcome = skipSent or false

    self.notifyActive = true
    if not self.notifyEnabled then
        self.notifyEnabled = true
        ns.observer:Register("CHAT_MSG_SYSTEM", GuildRosterHandler)
    end

    if ns.settings.inviteFormat ~= 1 then
        ns.scanner:TotalUnknown() end
end
function invite:AddToSentList(name, class)
    if not name or not class then ns.code:fOut((name or 'NO NAME')..' was not added to sent list.') return false
    elseif ns.tblInvited[name] then ns.code:dOut(name..' was already on the invited list.') return true end

    ns.tblInvited[name] = invite:new(class, name)
    return true
end
invite:Init()

function analytics:Scanned(amt)
    if not ap or not ag then return end
    ap.Players_Scanned = ns.code:inc(ap.Players_Scanned or 0, amt or 1)
    ag.Players_Scanned = ns.code:inc(ag.Players_Scanned or 0, amt or 1)
end
function analytics:Invited(amt)
    if not ap or not ag then return end
    ap.Invited_Players = ns.code:inc(ap.Invited_Players or 0, amt or 1)
    ag.Invited_Players = ns.code:inc(ag.Invited_Players or 0, amt or 1)
end
function analytics:Accepted(amt)
    if not ap or not ag then return end
    ap.Accepted_Invite = ns.code:inc(ap.Accepted_Invites or 0, amt or 1)
    ag.Accepted_Invite = ns.code:inc(ag.Accepted_Invites or 0, amt or 1)
end
function analytics:Declined(amt)
    if not ap or not ag then return end
    ap.Declined_Invite = ns.code:inc(ap.Declined_Invites or 0, amt or 1)
    ag.Declined_Invite = ns.code:inc(ag.Declined_Invites or 0, amt or 1)
end
function analytics:Blacklisted(amt)
    if not ap or not ag then return end
    ap.Blacklisted_Players = ns.code:inc(ap.Black_Listed or 0, amt or 1)
    ag.Blacklisted_Players = ns.code:inc(ag.Black_Listed or 0, amt or 1)
end
function analytics:get(key, isGlobal)
    if not ap or not ag then return end

    local tblAnalytics = {}
    tblAnalytics.profile = ap or {}
    tblAnalytics.global = ag or {}

    local val = isGlobal and (tblAnalytics.global[key] or 0) or (tblAnalytics.profile[key] or 0)
    local out = tostring(val):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    if isGlobal then return out else return out end
end

-- Blacklist Routines
function blackList:Init()
    self.tblBlackList = {}
end
function blackList:CheckBlackList(player)
    self.tblBlackList = ns.tblBlackList or {}
    if not player or not self.tblBlackList then return false end

    local found = (self.tblBlackList and self.tblBlackList[player]) and true or false
    found = not found and self.tblBlackList[player..'-'..GetRealmName()] and true or false
    if found then ns.code:dOut(player..' is on the blacklist.') end
    return found
end
function blackList:FixBlackList()
    self.tblBlackList = ns.tblBlackList or {}

    self.tblBlackList.blackList = nil
    for k in pairs(self.tblBlackList) do
        if type(k) == 'number' then self.tblBlackList[k] = nil end
    end
end
function blackList:AddToBlackList(name, reason)
    if not name then return end

    local POPUP_REASON, blName = "inputReason", nil
    local fName = select(2, UnitClass(name)) and ns.code:cPlayer(name, select(2, UnitClass(name))) or name
    StaticPopupDialogs[POPUP_REASON] = {
        text = "Why do you want to black list:\n"..(fName or blName),
        button1 = "OK",
        button2 = "Cancel",
        OnAccept = function(data)
            if not blName then return end

            local value = data.editBox:GetText()
            value = value ~= '' and value or 'No reason'

            self.tblBlackList[blName] = { reason = value, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), markedForDelete = false }
            ns.code:saveTables('BLACK_LIST')

            ns.scanner:TotalBlackList()
            ns.code:fOut(fName..' was added to the black list with \"'..value..'\" as a reason.')
        end,
        OnCancel = function() UIErrorsFrame:AddMessage(name..' was not added to Black List.', 1.0, 0.1, 0.1, 1.0) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        hasEditBox = true,
        maxLetters = 255,
        -- You can add more properties as needed
    }

    local realm = '-'..GetRealmName()
    blName = not name:match(realm) and name..realm or name
    if not blName then return end

    if self.tblBlackList[blName] then
        local dateTable = date("*t", self.tblBlackList[blName].dateBlackList)
        local formattedTime = string.format("%02d/%02d/%04d", dateTable.month, dateTable.day, dateTable.year)
        ns.code:cOut(fName..' is already black listed with \"'..self.tblBlackList[blName].reason..'\" as a reason on '..formattedTime..'.')
        return
    end

    if not reason then StaticPopup_Show(POPUP_REASON)
    else
        reason = reason == 'BULK_ADD_BLACKLIST' and 'Bulk Add' or reason
        self.tblBlackList[blName] = { reason = reason, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), markedForDelete = false }
        ns.code:saveTables('BLACK_LIST')

        ns.scanner:TotalBlackList()
        ns.code:cOut(fName..' was added to the black list with \"'..reason..'\" as a reason.')
    end
end