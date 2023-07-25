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
function code:checkOut(msg, color, noPrefix)
    if not ns.db.showAppMsgs then return end
    local prefix = not noPrefix and 'GR: ' or ''
    print('|c'..(color or 'FF3EB9D8')..prefix..(msg or 'did not get message')..'|r')
end
function code:GuildReplace(msg, playerName)
    local gi = ns.dbGlobal.guildData
    if not gi or not msg then return end

    local gLink, gName = gi.guildLink or nil, gi.guildName or nil
    local needGlink = msg:match('GUILDLINK') and true or false
    local needGname = msg:match('GUILDNAME') and true or false
    local needPlayer = msg:match('PLAYERNAME') and true or false

    msg = (gLink and needGlink) and gsub(msg, 'GUILDLINK', gLink or 'No Guild Link') or msg
    msg = (gName and needGname) and gsub(msg, 'GUILDNAME', gName and '<'..gName..'>' or 'No Guild Name') or msg
    msg = needPlayer and gsub(msg, 'PLAYERNAME', (playerName or 'player')) or msg

    return msg
end
function code:ClickSound(enable)
    if strupper(enable) == 'ENABLE' then
        SetCVar("Sound_EnableSFX", (self.originalClickSound or "1"))
    else SetCVar("Sound_EnableSFX", "0") end
end
function code:fNumber(val)
    -- only positive numbers
    -- Not receiving a number will return 0 error
    val = type(val) == 'number' and tostring(val) or '0'
    return tostring(val):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end
function code:ConvertDateTime(val, showHours)
    local d = date("*t", val)
    return (d and showHours) and string.format("%02d/%02d/%04d %02d:%02d", d.month, d.day, d.year, d.hour, d.minute) or (string.format("%02d/%02d/%04d", d.month, d.day, d.year) or nil)
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

    self.eventsActive = false
    self.updateGuildRoster = false

    self.guildCount = 0

    self.tblSent = {}
    self.tblInvited = {}
end
function invite:InitializeInvite()
    self.tblInvited = ns.dbInv or {}

    self.antiSpam = ns.db.settings.antiSpam or true
    self.showWhispers = ns.db.settings.showWhispers or false

    self.showGreeting = ns.db.settings.sendGreeting or ns.dbGlobal.guildInfo.greeting or false
    self.msgGreeting = ns.dbGlobal.guildInfo.greetingMsg ~= '' and ns.dbGlobal.guildInfo.greetingMsg or ns.db.settings.greetingMsg

    self.showWelcome = ns.db.settings.sendWelcome or false
    self.msgWelcome = ns.db.settings.welcomeMessage or ''
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

        self.tblSent[pName] = GetTime()

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
    local function UpdateSent()
        for k, r in pairs(invite.tblSent) do
            if r and r ~= '' then
                local time = GetTime() - r
                if time > 120 then
                    invite.tblSent[k] = nil
                    ns.scanner.analytics:WaitingOn(-1)
                end
            end
        end

        if ns.scanner.totalUnknown == 0 then
            self.eventsActive = false
            self.updateGuildRoster = false

            GRADDON:UnregisterEvent('CHAT_MSG_SYSTEM')
        end
    end
    local function GuildRosterHandler(...)
        local _, msg =  ...
        if not msg then return end

        invite:InitializeInvite()

        local newMsg = msg:gsub("'", ''):gsub('No Player Named ', '')
        local pName = newMsg:match('(.-) ')
        pName = gsub(pName, '-'..GetRealmName(), '')

        if not self.tblSent[pName] then return
        elseif msg:match('not found') then ns.scanner.analytics:TotalInvites(-1)
        elseif msg:match('is not online') then ns.scanner.analytics:TotalInvites(-1)
        elseif msg:match('No Player Named') then ns.scanner.analytics:TotalInvites(-1)
        elseif not msg:match('guild') then return
        elseif msg:match('has joined the guild') then
            if self.tblSent[pName] then
                ns.code:consoleOut(pName..' joined the guild!')
                if  invite.showGreeting and  invite.msgGreeting ~= '' and pName then
                    ns.scanner.analytics:TotalAccepted()
                    SendChatMessage(ns.code:GuildReplace( invite.msgGreeting, pName):gsub('<', ''):gsub('>', ''), 'WHISPER', nil, pName)
                end
                if  invite.showWelcome and  invite.msgWelcome ~= '' then
                    C_Timer.After(math.random(3,10), function()
                        SendChatMessage(ns.code:GuildReplace( invite.msgWelcome, pName):gsub('<', ''):gsub('>', ''), 'GUILD')
                    end)
                end

                UpdateSent()
                invite.tblSent[pName] = nil
                ns.scanner.analytics:TotalAccepted()
                ns.scanner.analytics:WaitingOn(-1)
                return
            end
        elseif msg:match('is already in a guild') then ns.scanner.analytics:TotalInvites(-1)
        elseif msg:match('declines your guild invitation') then ns.scanner.analytics:TotalDeclined() end

        UpdateSent()
        invite.tblSent[pName] = nil
        ns.scanner.analytics:WaitingOn(-1)
    end

    if not self.eventsActive then
        self.eventsActive = true
        GRADDON:RegisterEvent('CHAT_MSG_SYSTEM', GuildRosterHandler)
    end
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
            ns.dbBL = ns.BlackList.tblBlackList
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
function blackList:FormAddToBlackList()
    self.tblBlackList = ns.dbBL or {}

    local attachTo = ns.screen.fMain:IsShown() and ns.screen.fMain or UIParent
    local frame = CreateFrame("Frame", nil, attachTo, "BackdropTemplate")
    frame:SetSize(300, 200)
    frame:SetPoint("CENTER", attachTo, "CENTER")
    frame:SetBackdrop({
        bgFile = 'Interface\\Buttons\\WHITE8x8',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0,0,0,1)
    frame:SetBackdropBorderColor(0.4,0.4,0.4,1)
    frame:SetFrameStrata("LOW")

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Add player to Black List")

    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOP", frame, "TOP", 0, -40)
    desc:SetText("Enter the name of the player you\nwant to add to the black list.")
    desc:SetTextColor(1,1,1,1)

    local editBox_Name = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox_Name:SetSize(200, 20)
    editBox_Name:SetPoint("TOP", desc, "TOP", 40, -40)
    editBox_Name:SetAutoFocus(false)
    editBox_Name:SetFocus()
    editBox_Name:SetFontObject("GameFontHighlight")

    local boxTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    boxTitle:SetPoint("RIGHT", editBox_Name, "LEFT", -5, 0)
    boxTitle:SetText("Player: ")
    boxTitle:SetTextColor(1,1,1,1)

    local editBox_Reason = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox_Reason:SetSize(200, 20)
    editBox_Reason:SetPoint("TOP", editBox_Name, "TOP", 0, -30)
    editBox_Reason:SetAutoFocus(false)
    editBox_Reason:SetFontObject("GameFontHighlight")

    boxTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    boxTitle:SetPoint("RIGHT", editBox_Reason, "LEFT", -5, 0)
    boxTitle:SetText("Reason: ")
    boxTitle:SetTextColor(1,1,1,1)

    local function addRecordClick()
        local name = editBox_Name:GetText() and editBox_Name:GetText() or nil
        local reason = editBox_Reason:GetText() or 'No reason'

        name = name and strlower(name):gsub('-'..strlower(GetRealmName()), '') or name
        name = name and strupper(strsub(name,1,1))..strlower(strsub(name,2)) or name
        local lookup = (name and name:match('-'..GetRealmName())) and name or name..'-'..GetRealmName()

        print(name, lookup, UnitExists('Dianix'), UnitIsPlayer('Dianix'))
        if not name or name == '' then
            ns.widgets:createErorrWindow('You must enter a name to add to the black list.', true, frame)
        elseif ns.blackList.tblBlackList[lookup] then
            local dateTable = date("*t", self.tblBlackList[lookup].dateBlackList)
            local formattedTime = string.format("%02d/%02d/%04d", dateTable.month, dateTable.day, dateTable.year)
            ns.widgets:createErorrWindow(name..' is already black listed with\n\"'..ns.code:cText('FFFFFF00', self.tblBlackList[lookup].reason)..'\" as a reason\non '..formattedTime..'.', true, frame)
        elseif name and name ~= '' then
            local tbl = { [name] = { reason = reason, whoDidIt = UnitGUID('player'), dateBlackList = C_DateAndTime.GetServerTimeLocal(), markedForDelete = false } }
            tinsert(self.tblBlackList, tbl)
            ns.dbBL = self.tblBlackList
            ns.code:consoleOut(name..' was added to the black list with \"'..reason..'\" as a reason.')
            frame:Hide()
        end
    end

    local btnAdd = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnAdd:SetSize(100, 20)
    btnAdd:SetPoint("TOP", editBox_Reason, "TOP", -100, -40)
    btnAdd:SetText("Add")
    btnAdd:SetScript("OnClick", function() addRecordClick() end)

    local btnCancel = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnCancel:SetSize(100, 20)
    btnCancel:SetPoint("LEFT", btnAdd, "RIGHT", 5, 0)
    btnCancel:SetText("Cancel")
    btnCancel:SetScript("OnClick", function() frame:Hide() end)
    frame:Show()

    editBox_Name.tabCycle = editBox_Reason
    editBox_Reason.tabCycle = editBox_Name

    local function tabPressed(dest)
        if dest.tabCycle and IsShiftKeyDown() then dest.tabCycle:SetFocus()
        elseif dest.tabCycle then dest.tabCycle:SetFocus() end
    end

    editBox_Name:SetScript("OnTabPressed", tabPressed)
    editBox_Name:SetScript("OnEnterPressed", tabPressed)
    editBox_Reason:SetScript("OnTabPressed", tabPressed)
    editBox_Reason:SetScript("OnEnterPressed", function() addRecordClick() end)
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
function widgets:createErorrWindow(msg, alert, frame)
    --[[local errorDialog = {
        text = msg,
        button1 = 'Okay',
        timeout = self.defaultTimeout,
        showAlert = alert,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            self:SetPoint('CENTER', frame or UIParent, 'CENTER')
        end,
    }
    StaticPopupDialogs['MY_ERROR_DIALOG'] = errorDialog
    StaticPopup_Show('MY_ERROR_DIALOG')--]]
    local errorFrame = CreateFrame("Frame", nil, frame or UIParent, "BackdropTemplate")
    errorFrame:SetSize(300, 100)
    errorFrame:SetPoint("CENTER", frame or UIParent, "CENTER")
    errorFrame:SetBackdrop({
        bgFile = 'Interface\\Buttons\\WHITE8x8',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    errorFrame:SetBackdropColor(0,0,0,1)
    errorFrame:SetBackdropBorderColor(0.4,0.4,0.4,1)
    errorFrame:SetFrameStrata("DIALOG")

    local title = errorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", errorFrame, "TOP", 0, -10)
    title:SetText("Entry Error")

    local desc = errorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOP", errorFrame, "TOP", 0, -25)
    desc:SetText(msg)
    desc:SetTextColor(1,1,1,1)

    local btnOkay = CreateFrame("Button", nil, errorFrame, "UIPanelButtonTemplate")
    btnOkay:SetSize(100, 20)
    btnOkay:SetPoint("TOP", desc, "TOP", 0, -50)
    btnOkay:SetText("Okay")
    btnOkay:SetScript("OnClick", function() errorFrame:Hide() end)
    errorFrame:Show()
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
function analytics:get(key, isGlobal)
    local tblAnalytics = {}
    tblAnalytics.profile = ns.dbAnal or {}
    tblAnalytics.global = ns.dbGAnal or {}

    local val = isGlobal and (tblAnalytics.global[key] or 0) or (tblAnalytics.profile[key] or 0)
    local out = tostring(val):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    if isGlobal then return out else return out end
end