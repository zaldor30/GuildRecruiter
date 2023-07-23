local _, ns = ... -- Namespace (myaddon, namespace)

--[[ This is for reusable code found throughout the addon
    This code contains the following namespaces:
        ns.code
        ns.invite
        ns.widgets
        ns.analytics
        ns.blackList
]]

ns.code = {}
local code = ns.code
function code:Init()
    self.fPlayerName = code:cPlayer('player')
    self.originalClickSound = GetCVar("Sound_EnableSFX")
end
function code:inc(data, count) return (data or 0) + (count or 1) end
function code:cText(color, text)
    if type(color) ~= 'string' or not text then return end
    return '|c'..color..text..'|r'
end
function code:cPlayer(uName, class)
    if strmatch(uName, 'raid') or strmatch(uName, 'party') or uName  == 'player' then
        uName = UnitName(uName) end

    local cClass = (class or select(2, UnitClass(uName))) and GRADDON.classInfo[(class or select(2, UnitClass(uName)))].color or nil

    if not cClass then return uName
    else return code:cText(cClass, uName) end
end
function code:consoleOut(msg, color, noPrefix)
    local prefix = not noPrefix and 'GR: ' or ''
    print('|c'..(color or 'FF3EB9D8')..prefix..(msg or 'did not get message')..'|r')
end
function code:GuildReplace(msg, playerName)
    if not ns.db then return end

    local gi = ns.dbGlobal
    if not gi or not msg then return end

    local gLink, gName = gi.guildLink or nil, gi.guildName or nil
    if gName and msg then
        msg = gLink and gsub(msg, 'GUILDLINK', gLink and gLink or 'No Guild Link') or msg
        msg = gName and gsub(msg, 'GUILDNAME', gName and '<'..gName..'>' or 'No Guild Name') or msg
        msg = gsub(msg, 'NAME', playerName or 'player')
    end

    return msg
end
function code:ClickSound(enable)
    if strupper(enable) == 'ENABLE' then
        SetCVar("Sound_EnableSFX", (self.originalClickSound or "1"))
    else SetCVar("Sound_EnableSFX", "0") end
end
code:Init()

ns.invite = {}
local invite = ns.invite
function invite:Init()
    self.antiSpam = false
    self.showWelcome = false
    self.showWhispers = false
    self.showGreeting = false

    self.msgWelcome = ''
    self.msgGreeting = ''

    self.tblSent = {}
    self.tblInvited = {}
end
function invite:InitializeInvite()
    self.tblInvited = ns.dbInv or {}

    self.antiSpam = ns.db.settings.antiSpam or true
    self.showWhispers = ns.db.settings.showWhispers or false

    self.showGreeting = ns.db.settings.showWelcome or ns.dbGlobal.guildInfo.greeting or false
    self.showGreeting = (self.showGreeting and (ns.db.settings.greetingMsg ~= '' or ns.dbGlobal.guildInfo.greetingMsg ~= '')) and true or false

    self.msgGreeting = (ns.dbGlobal.guildInfo.greeting and ns.dbGlobal.guildInfo.greetingMsg ~= '') and ns.dbGlobal.guildInfo.greetingMsg or ns.db.settings.greetingMsg

    self.showWelcome = ns.db.settings.showWelcome or false
    self.showWelcome = (self.showWelcome and ns.db.settings.welcomeMessage ~= '') and true or false

    self.msgWelcome = ns.db.settings.welcomeMessage
end
function invite:new(class)
    return {
        ['playerClass'] = class or '',
        ['invitedBy'] = UnitGUID('player'),
        ['invitedOn'] = C_DateAndTime.GetServerTimeLocal(),
    }
end
function invite:CheckAbilityToInvite(player, zone, skipChecks)
    invite:InitializeInvite()

    if skipChecks then return true
    elseif not player or not zone then return false
    else
        if self.tblInvited[player] then return false
        elseif ns.blackList:CheckBlackList(player) then return false
        elseif ns.datasets.tblBadByName[zone] then return false end
    end

    return true
end
function invite:SendInviteToPlayer(pName, msg, sendInvite, class)
    pName = gsub(pName, '-'..GetRealmName(), '')
    if self.tblSent[pName] then return end

    invite:InitializeInvite()

    local function MyWhisperFilter(_,_, message)
        if msg == message then return not self.showWhispers
        else return false end -- Returning true will hide the message
    end

    class = class and class or select(2, UnitClass(pName))
    if pName and CanGuildInvite() and not GetGuildInfo(pName) then
        if sendInvite then GuildInvite(pName) end
        if msg and ns.db.settings.inviteFormat ~= 2 then
            if not self.showWhispers then
                local msgOut = sendInvite and 'Sent invite and message to ' or 'Sent invite message to '
                ns.code:consoleOut(msgOut..(ns.code:cPlayer(pName, class) or pName))
                ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", MyWhisperFilter, msg)
            end
            SendChatMessage(msg, 'WHISPER', nil, pName)
        end

        self.tblSent[pName] = true

        ns.scanner.analytics:WaitingOn()
        ns.scanner.analytics:TotalInvites()

        if self.antiSpam then
            self.tblInvited[pName] = invite:new(class)
            ns.dbInv[pName] = self.tblInvited[pName]
        end

        invite:RegisterGuildInviteEvent()
    else ns.code:consoleOut('You do not have invite permissions or not in a guild.') end
end
function invite:RegisterGuildInviteEvent()
    if ns.tblEvents['CHAT_MSG_SYSTEM'] then return end

    local function GuildRosterHandler(...)
        local _, msg =  ...
        if not msg then return end

        local pName = msg:match('(.-) ')
        pName = gsub(pName, '-'..GetRealmName(), '')

        if not self.tblSent[pName] then return
        elseif msg:match('not found') then ns.scanner.analytics:TotalInvites(-1)
        elseif msg:match('is not online') then ns.scanner.analytics:TotalInvites(-1)
        elseif not msg:match('guild') then return
        elseif msg:match('is already in a guild') then ns.scanner.analytics:TotalInvites(-1)
        elseif msg:match('has joined the guild') then
            ns.scanner.analytics:TotalAccepted()

            if self.showWelcome then
                SendChatMessage(self.msgGreeting, 'WHISPER', nil, pName)
            end
            if self.showGreeting then
                C_Timer.After(math.random(3-10), function()
                    SendChatMessage(ns.code:GuildReplace(self.msgWelcome, pName), 'GUILD')
                end)
            end
        elseif msg:match('declines your guild invitation') then ns.scanner.analytics:TotalDeclined() end

        invite.tblSent[pName] = nil
        ns.scanner.analytics:WaitingOn(-1)
    end

    GRADDON:RegisterEvent('CHAT_MSG_SYSTEM', GuildRosterHandler)
end
invite:Init()

ns.blackList = {}
local blackList = ns.blackList
function blackList:Init()
    self.tblBlackList = {}
end
function blackList:CheckBlackList(name)
    self.tblBlackList = ns.dbBL or {}

    local realm = '-'..GetRealmName()
    name = name:gsub(realm, '')
    name = strupper(name:sub(1,1))..name:sub(2)..realm

    return (self.tblBlackList[name] and not self.tblBlackList[name].markedForDelete) and true or false
end
function blackList:AddToBlackList(name)
    if not name then return end
    self.tblBlackList = ns.dbBL or {}

    local POPUP_REASON, blName = "inputReason", nil
    local fName = select(2, UnitClass(name)) and ns.code:cPlayer(name, select(2, UnitClass(name))) or name
    StaticPopupDialogs[POPUP_REASON] = {
        text = "Why do you want to black list:\n"..fName,
        button1 = "OK",
        button2 = "Cancel",
        OnAccept = function(data)
            local value = data.editBox:GetText()
            value = strlen(value) > 0 and value or 'No reason'

            ns.BlackList.tblBlackList[blName] = { reason = value, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), markedForDelete = false }
            ns.dbBL.blackList = ns.BlackList.tblBlackList
            ns.Analytics:add('Black_Listed')
            ns.code:consoleOut(blName..' was added to the black list with \"'..value..'\" as a reason.')
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

    if self.tblBlackList[blName] then
        local dateTable = date("*t", self.tblBlackList[blName].dateBlackList)
        local formattedTime = string.format("%02d/%02d/%04d", dateTable.month, dateTable.day, dateTable.year)
        ns.code:consoleOut(blName..' is already black listed with \"'..self.tblBlackList[blName].reason..'\" as a reason on '..formattedTime..'.')
        return
    end
    StaticPopup_Show(POPUP_REASON)
end
function blackList:BulkAddToBlackList(tbl)
    self.tblBlackList = ns.dbBL or {}

    local realm, bCount, tCount = '-'..GetRealmName(), 0, 0
    for k in pairs(tbl) do
        tCount = tCount + 1
        local name = not k:match(realm) and k..realm or k
        if not self.tblBlackList[name] then
            bCount = bCount + 1
            ns.dbBL[name] = { reason = 'Bulk Add', whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), selected = false, markedForDelete = false }
        end
    end

    ns.scanner.analytics:TotalBlackList(bCount)
    ns.code:consoleOut(bCount..' of '..tCount..' players were added to the black list.')
end
blackList:Init()

ns.widgets = {}
local widgets = ns.widgets

function widgets:Init()
    self.defaultTimeout = 10
end
function widgets:createTooltip(text, body, force)
    if not force and not ns.db.settings.showTooltips then return end
    local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
    CreateFrame("GameTooltip", nil, nil, "GameTooltipTemplate")
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR") -- Attaches the tooltip to cursor
    GameTooltip:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", x / uiScale, y / uiScale)
    GameTooltip:SetText(text)
    if body then GameTooltip:AddLine(body,1,1,1) end
    GameTooltip:Show()
end
function widgets:createErorrWindow(msg, alert)
    local errorDialog = {
        text = msg,
        button1 = 'Okay',
        timeout = self.defaultTimeout,
        showAlert = alert,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            self:SetPoint('CENTER', UIParent, 'CENTER')
        end,
    }
    StaticPopupDialogs['MY_ERROR_DIALOG'] = errorDialog
    StaticPopup_Show('MY_ERROR_DIALOG')
end
function widgets:createPadding(frame, rWidth)
    local widget = LibStub("AceGUI-3.0"):Create('Label')
    if rWidth <=2 then widget:SetRelativeWidth(rWidth)
    else widget:SetWidth(rWidth) end
    frame:AddChild(widget)
end
function widgets:createLabel(text, width, font, fontSize)
    local label = LibStub("AceGUI-3.0"):Create('Label')
    label:SetText(text)
    label:SetFont((font or DEFAULT_FONT), (fontSize or DEFAULT_FONT_SIZE), 'OUTLINE')
    if width == 'full' then label:SetFullWidth(true)
    else label:SetWidth(width) end
    return label
end
function widgets:Confirmation(msg, func)
    StaticPopupDialogs["MY_YES_NO_DIALOG"] = {
        text = msg,
        button1 = "Yes",
        button2 = "No",
        OnAccept = func,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
    }
    StaticPopup_Show("MY_YES_NO_DIALOG")
end
widgets:Init()

ns.analytics = {}
local analytics, p, g = ns.analytics, nil, nil
function analytics:Scanned(amt)
    p, g = ns.dbAnal, ns.dbGAnal
    p.Players_Scanned = code:inc(p.Players_Scanned or 0, amt or 1)
    g.Players_Scanned = code:inc(g.Players_Scanned or 0, amt or 1)
end
function analytics:Invited(amt)
    p, g = ns.dbAnal, ns.dbGAnal
    p.Invited_Players = code:inc(p.Invited_Players or 0, amt or 1)
    g.Invited_Players = code:inc(g.Invited_Players or 0, amt or 1)
end
function analytics:BlackListed(amt)
    p, g = ns.dbAnal, ns.dbGAnal
    p.Black_Listed = code:inc(p.Black_Listed or 0, amt or 1)
    g.Black_Listed = code:inc(g.Black_Listed or 0, amt or 1)
end
function analytics:Accepted(amt)
    p, g = ns.dbAnal, ns.dbGAnal
    p.Accepted_Invite = code:inc(p.Accepted_Invite or 0, amt or 1)
    g.Accepted_Invite = code:inc(g.Accepted_Invite or 0, amt or 1)
end
function analytics:Declined(amt)
    p, g = ns.dbAnal, ns.dbGAnal
    p.Declined_Invite = code:inc(p.Declined_Invite or 0, amt or 1)
    g.Declined_Invite = code:inc(g.Declined_Invite or 0, amt or 1)
end