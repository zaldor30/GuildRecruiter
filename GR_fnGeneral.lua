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
    print('|c'..(color or 'FF807e14')..'GR: '..(msg or 'did not get message')..'|r')
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
    if strupper(enable) == 'ENABLE' then SetCVar("Sound_EnableSFX", self.originalClickSound or "1")
    else SetCVar("Sound_EnableSFX", "0") end
end
code:Init()

ns.widgets = {}
local widgets = ns.widgets

function widgets:Init()
    self.defaultTimeout = 10
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
widgets:Init()