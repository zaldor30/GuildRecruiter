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