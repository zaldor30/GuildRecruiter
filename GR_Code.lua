local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local aceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

ns.code = {}
local code = ns.code
function code:Init()
    self.fPlayerName = nil
    self.originalClickSound = GetCVar("Sound_EnableSFX")
end
function code:realMessageID(msgID)
    if not msgID then return end
    return msgID < 100 and msgID or msgID - 100
end
-- Text Colors
function code:cText(color, text)
    if type(color) ~= 'string' or not text then return end
    return '|c'..color..text..'|r'
end
function code:cPlayer(uName, class, color)
    if ns.dbGlobal and ns.dbGlobal.guildData and uName == ns.dbGlobal.guildData.guildName then return
    elseif strmatch(uName, 'raid') or strmatch(uName, 'party') or uName  == 'player' then
        uName = UnitName(uName) end

    local cClass = (class or select(2, UnitClass(uName))) and ns.tblClasses[(class or select(2, UnitClass(uName)))].color or (color or nil)

    if not cClass then return uName
    else return code:cText(cClass, uName) end
end
-- Compress and decompress data
function code:compressData(data, encode)
    if not data then return end

    local serializedData = aceSerializer:Serialize(data)
    local compressedData = LibDeflate:CompressDeflate(serializedData)
    return (encode and LibDeflate:EncodeForWoWAddonChannel(compressedData) or compressedData)
end
function code:decompressData(data, decode)
    if not data or data == '' or type(data) ~= 'string' then return false, nil end

    data = (decode and LibDeflate:DecodeForWoWAddonChannel(data) or data)
    local decompressedData = LibDeflate:DecompressDeflate(data)
    if decompressedData then print('decomp', aceSerializer:Deserialize(decompressedData)) return aceSerializer:Deserialize(decompressedData)
    else print('no decomp') return false, nil end -- Decompression failed
end
function code:saveTables(whichOne)
    if whichOne == 'BLACK_LIST' then ns.dbBL = ns.code:compressData(ns.tblBlackList)
    elseif whichOne == 'INVITED' then ns.dbInv = ns.code:compressData(ns.tblInvited)
    else
        ns.dbGlobal.blackList = ns.code:compressData(ns.tblBlackList) or ''
        ns.dbGlobal.antiSpamList = ns.code:compressData(ns.tblInvited) or ''
        ns.dbGlobal.sessionData = ns.code:compressData(ns.ds.tblSavedSessions) or ''
    end
end
function code:sortTableByField(tbl, sortField, reverse)
    if not tbl or not sortField then return end

    local keyArray = {}
    for key, rec in pairs(tbl) do
        if type(key) == 'string' then rec.key = key end
        table.insert(keyArray, rec)
    end

    reverse = reverse or false
    local sortFunc = function(a, b)
        if a[sortField] and b[sortField] then
            if reverse then return a[sortField] > b[sortField]
            else return a[sortField] < b[sortField] end
        end
    end

    table.sort(keyArray, sortFunc)

    return keyArray
end
-- Console Output
function code:cOut(msg, color, noPrefix, showConsole)
    if not msg or msg == '' then return end
    local prefix = not noPrefix and 'GR: ' or ''

    if showConsole or (ns.settings and ns.settings.showAppMsgs) then
        print('|c'..(color and color or 'FF3EB9D8')..prefix..(msg or 'Error: No message')..'|r') end
end
function code:fOut(msg, color, noPrefix) code:cOut(msg, color, noPrefix, true) end
function code:dOut(msg, color, noPrefix)
    if GR.debug then code:cOut(msg, color, noPrefix, true) end
end
-- Tooltip Routine
function code:createTooltip(text, body, force, frame)
    if not force and not ns.gSettings.showToolTips then return end
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
-- Guild Message Modication Routines
function code:capitalKeyWord(input)
    if not input or input == '' then return end

    local keys = { L['GUILDLINK'], L['GUILDNAME'], L['PLAYERNAME'] }

    for i=1,#keys do
        local startPos, endPos = (strupper(input)):find(keys[i])

        if startPos then
            local prefix = string.sub(input, 1, startPos - 1)
            local suffix = string.sub(input, endPos + 1)
            input = prefix..strupper(keys[i])..suffix
        end
    end

    return input
end
function code:variableReplacement(msg, playerName, removeGT)
    local gi = ns.dbGlobal.guildInfo
    if not gi or not msg or msg == '' then return end

    playerName = strsplit('-', playerName)

    msg = code:capitalKeyWord(msg)
    if not msg then return end

    local gLink, gName = gi.guildLink or nil, gi.guildName or nil

    msg = msg:gsub(L['GUILDLINK'], (gLink or L['No Guild Link']))
    msg = msg:gsub(L['GUILDNAME'], (gName and (removeGT and gName or '<'..gName..'>') or L['No Guild Name']))
    msg = msg:gsub(L['PLAYERNAME'], (playerName or 'player'))

    return msg
end
-- Interface Routines
function code:createPadding(frame, rWidth)
    local widget = LibStub("AceGUI-3.0"):Create('Label')
    if rWidth <=2 then widget:SetRelativeWidth(rWidth)
    else widget:SetWidth(rWidth) end
    frame:AddChild(widget)
end
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
-- Other Shared Code
function code:inc(data, count) return (data or 0) + (count or 1) end
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
function code:ConvertDateTime(val, showHours)
    local d = date("*t", val)
    return (d and showHours) and string.format("%02d/%02d/%04d %02d:%02d", d.month, d.day, d.year, d.hour, d.minute) or (string.format("%02d/%02d/%04d", d.month, d.day, d.year) or nil)
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
code:Init()