local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local aceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

ns.code = {}
local code = ns.code

-- * Data Compression Routines
function code:compressData(data, encode, skipCompression)
    if not data then return end

    local serializedData = aceSerializer:Serialize(data)
    local compressedData = not skipCompression and LibDeflate:CompressDeflate(serializedData) or serializedData
    return (encode and LibDeflate:EncodeForWoWAddonChannel(compressedData) or compressedData)
end
function code:decompressData(data, decode, skipCompression)
    if not data or data == '' or type(data) ~= 'string' then return false, nil end

    data = (decode and LibDeflate:DecodeForWoWAddonChannel(data) or data)
    if not data then
        ns.code:dOut('Failed to decode data', 'FF0000')
        return false, nil
    end
    local decompressedData = not skipCompression and LibDeflate:DecompressDeflate(data) or data
    if not decompressedData then
        ns.code:dOut('Failed to decompress data', 'FF0000')
        return false, nil
    end

    return aceSerializer:Deserialize(decompressedData)
end

-- *Console Text Output Routines
function code:cText(color, text)
    if text == '' then return end

    color = color == '' and 'FFFFFFFF' or color
    return '|c'..color..text..'|r'
end
function code:cPlayer(name, class, color) -- Colorize player names
    if name == '' or ((not class or class == '') and (not color or color == '')) or not name then return end
    local c = (not class or class == '') and color or select(4, GetClassColor(class))

    if c then return code:cText(c, name)
    else return end
end
function code:consolePrint(msg, color, noPrefix) -- Console print routine
    if msg == '' or not msg then return end

    local prefix = not noPrefix and self:cText(ns.COLOR_DEFAULT, 'GR: ') or ''
    color = strlen(color) == 6 and 'FF'..color or color
    DEFAULT_CHAT_FRAME:AddMessage(prefix..code:cText(color or 'FFFFFFFF', msg))
end
function code:cOut(msg, color, noPrefix) -- Console print routine
    if ns.pSettings and not ns.pSettings.showAppMsgs then return
    elseif msg == '' or not msg then return end

    code:consolePrint(msg, (color or ns.COLOR_DEFAULT), noPrefix)
end
function code:dOut(msg, color, noPrefix) -- Debug print routine
    if msg == '' or not GR.debug then return end
    code:consolePrint(msg, (color or ns.COLOR_DEBUG), noPrefix)
end
function code:fOut(msg, color, noPrefix) -- Force console print routine)
    if msg == '' then return
    else code:consolePrint(msg, (color or ns.COLOR_DEFAULT), noPrefix) end
end
-- *Keyword Replacement Routines
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
    local gi = ns.guildInfo
    if not gi or not msg or msg == '' then return end

    playerName = (playerName and playerName ~= '') and strsplit('-', playerName) or ''

    msg = code:capitalKeyWord(msg)
    if not msg then return end

    local gLink, gName = gi.guildLink or nil, gi.guildName or nil

    msg = msg:gsub(L['GUILDLINK'], ((gLink and gi.guildLink) and gLink or L['GUILD_LINK_NOT_FOUND']))
    msg = msg:gsub(L['GUILDNAME'], (gName and (removeGT and gName or '<'..gName..'>') or L['NO_GUILD_NAME']))
    msg = msg:gsub(L['PLAYERNAME'], (playerName or 'player'))

    return msg
end

-- *Tooltip Routine
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

-- * Tables and Data Sorting Routines
function code:saveTables(whichOne)
    ns.g.blackList = ns.code:compressData(ns.tblBlackList) or ''
    ns.g.antiSpamList = ns.code:compressData(ns.tblAntiSpamList) or ''

    if ns.tblAntiSpamList then return end
    if whichOne == 'BLACK_LIST' then ns.g.blackList = ns.code:compressData(ns.tblBlackList)
    elseif whichOne == 'ANTI_SPAM_LIST' then ns.g.antiSpamList = ns.code:compressData(ns.tblAntiSpamList)
    else
        --if ns.guildSession then ns.gAnalytics.session = ns.code:compressData(ns.guildSession) end
    end
end
function code:sortTableByField(tbl, sortField, reverse, showit)
    if not tbl or not sortField then return end

    local keyArray = {}
    for key, rec in pairs(tbl) do
        if type(key) == 'string' then
            rec.key = key
            table.insert(keyArray, rec)
        end
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

-- *Frame Routines
function code:createPadding(frame, rWidth)
    local widget = LibStub("AceGUI-3.0"):Create('Label')
    if rWidth <=2 then widget:SetRelativeWidth(rWidth)
    else widget:SetWidth(rWidth) end
    frame:AddChild(widget)
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
function code:AcceptDialog(msg, func)

    StaticPopupDialogs["MY_ACCEPT_DIALOG"] = {
        text = msg,
        button1 = "Ok",
        OnAccept = func,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("MY_ACCEPT_DIALOG")
end