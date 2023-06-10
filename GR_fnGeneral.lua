-- Functions for everyone
local _, ns = ... -- Namespace (myaddon, namespace)
ns.code = {}
local code = ns.code

function code:Init()
    self.fPlayerName = code:cPlayer('player')
end
function code:inc(data, count) return (data or 0) + (count or 1) end
function code:cText(color, text)
    if type(color) ~= 'string' or not text then return end
    return '|c'..color..text..'|r'
end
function code:cPlayer(uName)
    if strmatch(uName, 'raid') or strmatch(uName, 'party') or strmatch(uName, 'player') then
        uName = UnitName(uName) end

    local cClass = GRADDON.classInfo[select(2, UnitClass(uName))].color
    return code:cText(cClass, uName)
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