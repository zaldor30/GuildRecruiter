local _, ns = ... -- Namespace (myaddon, namespace)

ns.code, ns.events = {}, {}
local code, events = ns.code, ns.events
function code:Init()
    self.fPlayerName = code:cPlayer('player')
    self.originalClickSound = GetCVar("Sound_EnableSFX")
end
-- Console and Other Output Commands
function code:cText(color, text)
    if type(color) ~= 'string' or not text then return end
    return '|c'..color..text..'|r'
end
function code:cPlayer(uName, class, color)
    if ns.dbGlobal and ns.dbGlobal.guildData and uName == ns.dbGlobal.guildData.guildName then return
    elseif strmatch(uName, 'raid') or strmatch(uName, 'party') or uName  == 'player' then
        uName = UnitName(uName) end

    local cClass = (class or select(2, UnitClass(uName))) and GRADDON.classInfo[(class or select(2, UnitClass(uName)))].color or (color or nil)

    if not cClass then return uName
    else return code:cText(cClass, uName) end
end
function code:cOut(msg, color, noPrefix, showConsole)
    if not msg or msg == '' then return end
    local prefix = not noPrefix and 'GR: ' or ''

    if showConsole or (ns.settings and ns.settings.showAppMsgs) then
        print('|c'..(color or 'FF3EB9D8')..prefix..(msg or 'Error: No message')..'|r') end
end
function code:fOut(msg, color, noPrefix) code:cOut(msg, color, noPrefix, true) end
function code:dOut(msg, color, noPrefix)
    if GRADDON.debug then code:cOut(msg, color, noPrefix, true) end
end
function code:statusOut(msg, color)
    if not msg or msg == '' then return end
    ns.screen.tblFrame.statusText:SetText('|c'..(color or 'FFFFFFFF')..msg..'|r')
end
function code:maxLength(originalText, maxWidth)
    if not originalText then return end

    local textWidth = strlen(originalText)
    maxWidth = maxWidth or 50
    if textWidth > maxWidth then
        return originalText:sub(1, math.floor(maxWidth / textWidth * #originalText)) .. "..."
    else return originalText end
end
function code:wordWrap(inputString, maxLineLength)
    local lines = {}
    local currentLine = ""

    maxLineLength = maxLineLength or 50
    for word in inputString:gmatch("%S+") do
        if #currentLine + #word <= maxLineLength then
            currentLine = currentLine .. " " .. word
        else
            table.insert(lines, currentLine)
            currentLine = word
        end
    end

    table.insert(lines, currentLine)
    return table.concat(lines, "\n")
end
-- Whisper Message Routines
function code:capitalKeyWord(input, key)
    local startPos, endPos = (strupper(input)):find(key)

    if startPos then
        local prefix = string.sub(input, 1, startPos - 1)
        local suffix = string.sub(input, endPos + 1)
        local modifiedString = prefix..strupper(key)..suffix
        return modifiedString
    end

    return input
end
function code:variableReplacement(msg, playerName)
    local gi = ns.dbGlobal.guildData
    if not gi or not msg then return end

    msg = code:capitalKeyWord(msg, 'GUILDLINK')
    msg = code:capitalKeyWord(msg, 'GUILDNAME')
    msg = code:capitalKeyWord(msg, 'PLAYERNAME')

    local gLink, gName = gi.guildLink or nil, gi.guildName or nil
    local needGlink = msg:match('GUILDLINK') and true or false
    local needGname = msg:match('GUILDNAME') and true or false
    local needPlayer = msg:match('PLAYERNAME') and true or false

    msg = (gLink and needGlink) and gsub(msg, 'GUILDLINK', gLink or 'No Guild Link') or msg
    msg = (gName and needGname) and gsub(msg, 'GUILDNAME', gName and '<'..gName..'>' or 'No Guild Name') or msg
    msg = needPlayer and gsub(msg, 'PLAYERNAME', (playerName or 'player')) or msg

    return msg
end
-- Shared Code
function code:inc(data, count) return (data or 0) + (count or 1) end
function code:round(num, numDecimalPlaces)
    if not num then return end
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
function code:ClickSound(enable)
    if strupper(enable) == 'ENABLE' then
        SetCVar("Sound_EnableSFX", (self.originalClickSound or "1"))
    else SetCVar("Sound_EnableSFX", "0") end
end
function code:sortTableByField(tbl, sortField, reverse)
    if not sortField then return end

    local keyArray = {}
    for key, item in pairs(tbl) do
        item.key = key
        table.insert(keyArray, item)
    end

    reverse = reverse or false
    local sortFunc = function(a, b)
        if reverse then return a[sortField] > b[sortField]
        else return a[sortField] < b[sortField] end
    end

    table.sort(keyArray, sortFunc)

    return keyArray
end
function code:ConvertDateTime(val, showHours)
    local d = date("*t", val)
    return (d and showHours) and string.format("%02d/%02d/%04d %02d:%02d", d.month, d.day, d.year, d.hour, d.minute) or (string.format("%02d/%02d/%04d", d.month, d.day, d.year) or nil)
end
function code:createTooltip(text, body, force, frame)
    if not force and not ns.db.settings.showTooltips then return end
    local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
    if frame then uiScale, x, y = 0, 0, 0 end
    CreateFrame("GameTooltip", nil, nil, "GameTooltipTemplate")
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR") -- Attaches the tooltip to cursor
    GameTooltip:SetPoint("BOTTOMLEFT", (frame or nil), "BOTTOMLEFT", (uiScale ~= 0 and (x / uiScale) or 0),  (uiScale ~= 0  and (y / uiScale) or 0))
    GameTooltip:SetText(text)
    if body then GameTooltip:AddLine(body,1,1,1) end
    GameTooltip:Show()
end
function code:verifyRealm(realm)
    if not realm then return end

    if not realm:match('-') then return true
    elseif realm:match(GetRealmName()) then return true end
    for k in pairs(ns.ds.tblConnected) do
        if realm:match(k) then return true end
    end

    return false
end
-- Create Padding Using Ace3
function code:createPadding(frame, rWidth)
    local widget = LibStub("AceGUI-3.0"):Create('Label')
    if rWidth <=2 then widget:SetRelativeWidth(rWidth)
    else widget:SetWidth(rWidth) end
    frame:AddChild(widget)
end

-- Other Controls
function code:Confirmation(msg, func)
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
code:Init()

ns.observer = {}
local observer = ns.observer
function observer:Init()
    self.tblObservers = {}
end
function observer:Register(event, callback)
    if not event or not callback then return end
    if not self.tblObservers[event] then self.tblObservers[event] = {} end
    table.insert(self.tblObservers[event], callback)
end
function observer:Unregister(event, callback)
    if not event or not callback then return end
    if not self.tblObservers[event] then return end
    for i=#self.tblObservers[event],1,-1 do
        if self.tblObservers[event][i] == callback then
            table.remove(self.tblObservers[event], i)
        end
    end
end
function observer:UnregisterAll(event)
    if not event then return end
    if not self.tblObservers[event] then return end
    for i=#self.tblObservers[event],1,-1 do
        table.remove(self.tblObservers[event], i)
    end
end
function observer:Notify(event, ...)
    if not event or not self.tblObservers[event] then return end

    for i=1,#self.tblObservers[event] do
        self.tblObservers[event][i](...)
    end
end
observer:Init()

local function observerSendMessageNotify(event, ...) observer:Notify(event, ...) end
function events:Init()
    self.tblEvents = {}
    self.tblMessages = {}
end
function events:RegisterEvent(event, callback)
    if not event or not callback then return
    elseif self.tblEvents[event] then return end

    self.tblEvents[event] = true
    GRADDON:RegisterEvent(event, callback)
end
function events:RegisterMessage(event, callback ,cb)
    if not event then return
    elseif self.tblEvents[event] then return end

    self.tblMessages[event] = true
    if not cb then GRADDON:RegisterMessage(event, observerSendMessageNotify)
    else GRADDON:RegisterMessage(event, callback) end
end
function events:Unregister(event)
    if not event or not self.tblEvents then return end

    if event == 'ALL_EVENTS' then
        for k in pairs(self.tblEvents or {}) do
            observer:UnregisterAll(k)
            GRADDON:UnregisterEvent(k)
            self.tblEvents[k] = nil
        end
    elseif event == 'ALL_MESSAGES' then
        for k in pairs(self.tblMessages or {}) do
            observer:UnregisterAll(k)
            GRADDON:UnregisterMessage(k)
            self.tblMessages[k] = nil
        end
    elseif self.tblEvents[event] then
        observer:UnregisterAll(event)
        GRADDON:UnregisterEvent(event)
        self.tblEvents[event] = nil
    elseif self.tblMessages[event] then
        observer:UnregisterAll(event)
        GRADDON:UnregisterMessage(event)
        self.tblMessages[event] = nil
    end
end
events:Init()