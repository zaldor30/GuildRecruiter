-- Functions for everyone
local _, ns = ... -- Namespace (myaddon, namespace)
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
function code:consoleOut(msg, color)
    print('|c'..(color or 'FF3EB9D8')..'GR: '..(msg or 'did not get message')..'|r')
end
function code:TruncateString(msg, length)
    return strlen(msg) > length and strsub(msg,1,length)..'...' or msg
end
function code:GuildReplace(msg)
    if not msg then return end

    local gi = ns.db.profile.guildInfo
    local gLink, gName = gi.guildLink or nil, gi.guildName or nil

    if gName and msg then
        msg = gLink and gsub(msg, 'GUILDLINK', gLink and gLink or 'No Guild Link') or msg
        msg = gName and gsub(msg, 'GUILDNAME', gName and '<'..gName..'>' or 'No Guild Name') or msg
        msg = gsub(msg, 'NAME', UnitName('player') or 'PLAYERNAME')
    end

    return msg
end
function code:ClickSound(enable)
    if strupper(enable) == 'ENABLE' then
        SetCVar("Sound_EnableSFX", (self.originalClickSound or "1"))
    else SetCVar("Sound_EnableSFX", "0") end
end
code:Init()

ns.widgets = {}
local widgets = ns.widgets

function widgets:Init()
    self.defaultTimeout = 10
end
function widgets:createTooltip(text, body)
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
widgets:Init()

ns.maint = {}
local maint = ns.maint
local global, dbInv = nil, nil
function maint:Init()
    self.maintenanceActive = false
end
function maint:StartMaintenance()
    global, dbInv = ns.db.global, ns.dbInv.global

    local removeCount = 0
    local cutOffTime = C_DateAndTime.GetServerTimeLocal() - ((global.rememberTime or 7) * 86400)

    self.maintenanceActive = true
    ns.MainScreen:DoingMaintenance()

    ns.code:consoleOut('Starting database maintenance...')
    for _,r in pairs(dbInv.invitedPlayers or {}) do
        local invitedOn = (type(r) == 'table' and r.invitedOn) and (type(r.invitedOn) == 'string' and tonumber(r.invitedOn) or r.invitedOn) or nil
        if invitedOn and invitedOn <= cutOffTime then
            r = nil
            removeCount = removeCount + 1
        elseif not invitedOn then r = nil end
    end
    if global.showSystem then
        ns.code:consoleOut(removeCount..' were removed from the invitied players list.') end

    self.maintenanceActive = false
    ns.MainScreen:DoingMaintenance()
    ns.code:consoleOut('Database maintenance complete.')
end
maint:Init()