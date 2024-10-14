local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.base, ns.statusText = {}, nil
local base = ns.base

-- Frame Dragging Routines
local function OnDragStart(self)
    if ns.base.isMoveLocked then return end
    self:StartMoving()
end
local function OnDragStop(self)
    self:StopMovingOrSizing()

    ns.base.screenPos.point,_,_, ns.base.screenPos.x, ns.base.screenPos.y = self:GetPoint()
    ns.pSettings.screenPos = ns.base.screenPos
end

function base:Init()
    self.isFGILoaded = false
    self.inviteMessage = nil
    self.isMoveLocked = true

    self.tblFrame = {}

    self.screenPos = ns.pSettings.screenPos or { -- Get default position and current position
        point = 'CENTER',
        x = 0,
        y = 0
    }
end
function base:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function base:SetShown(val, hideAfter)
    if not val and not self:IsShown() then return
    elseif not val then
        --ns.code:saveTables()
        --ns.analytics:UpdateSaveData()
        --ns.observer:Notify('CLOSE_SCREENS')

        self.tblFrame.frame:SetShown(val)
        return
    end

    self.isFGILoaded = C_AddOns.IsAddOnLoaded('FastGuildInvite')

    if not self.tblFrame then
        self:Init()

        self:CreateBaseFrame()
        self:CreateIconAndStatusFrame()
        self:CreateTopIcons()
        self:CreateBottomIcons()
    end

    self.tblFrame.frame:SetShown(not hideAfter)
end
function base:CreateBaseFrame()
    local f = ns.frames:CreateFrame('Frame', 'GR_BaseFrame', UIParent, 'BackdropTemplate')
    f:SetSize(500, 400)
    f:SetPoint(self.screenPos.point, self.screenPos.x, self.screenPos.y)
    f:SetFrameStrata(ns.DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript('OnDragStart', OnDragStart)
    f:SetScript('OnDragStop', OnDragStop)
    self.tblFrame.frame = f

    local special = false
    for _,r in pairs(UISpecialFrames) do
        if r == addonName then special = true break end
    end
    if not special and not ns.pSettings.keepOpen then
        _G[addonName] = self.tblFrame.frame
        tinsert(UISpecialFrames, addonName)
    end
end
function base:CreateIconAndStatusFrame()
    --* Create Icon Frame
    local f = ns.frames:CreateFrame('Frame', 'GR_BaseIconFrame', self.tblFrame.frame, 'BackdropTemplate')
    f:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 0, 0)
    f:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'TOPRIGHT', 0, -60)
    f:SetBackdropColor(0, 0, 0, 1)
    self.tblFrame.icon = f

    local t = f:CreateTexture(nil, 'ARTWORK')
    t:SetPoint('LEFT', f, 'LEFT', 10, 0)
    t:SetTexture(ns.GR_ICON)

    local txt = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txt:SetPoint('TOPLEFT', t, 'TOPRIGHT', 10, 0)
    txt:SetText(L['TITLE'])
    txt:SetTextColor(1, 1, 1, 1)
    txt:SetFont(ns.DEFAULT_FONT, 16, 'OUTLINE')

    local txtVer = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txtVer:SetPoint('BOTTOMLEFT', t, 'BOTTOMRIGHT', 10, 0)
    txtVer:SetText(GR.versionOut:gsub("[%(%)]", ""))
    txtVer:SetTextColor(1, 1, 1, 1)
    txtVer:SetFont(ns.DEFAULT_FONT, 12, 'OUTLINE')
    --? End Icon Frame

    --* Create Status Frame
    local fStatus = ns.frames:CreateFrame('Frame', 'GR_BaseStatusFrame', self.tblFrame.frame, 'BackdropTemplate')
    fStatus:SetPoint('BOTTOMLEFT', self.tblFrame.frame, 'BOTTOMLEFT', 0, 0)
    fStatus:SetSize(self.tblFrame.frame:GetWidth(), 30)
    fStatus:SetBackdropColor(0, 0, 0, 1)

    local txtStatus = fStatus:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txtStatus:SetPoint('LEFT', fStatus, 'LEFT', 10, 0)
    txtStatus:SetTextColor(1, 1, 1, 1)
    txtStatus:SetFont(ns.DEFAULT_FONT, 16, 'OUTLINE')
    local function SetText(text)
        if not text then return end

        ns.frames:animateText(txtStatus, text)
    end
    ns.statusText = SetText
end
local btnCloseFrame, lockTimer = nil, nil
function base:CreateTopIcons()
    local btnClose = ns.frames:CreateFrame('Button', 'GR_CloseButton', self.tblFrame.icon)
    btnClose:SetPoint('TOPRIGHT', self.tblFrame.icon, 'TOPRIGHT', -5, -5)
    btnClose:SetSize(20, 20)
    btnClose:SetNormalTexture(ns.BUTTON_EXIT)
    btnClose:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnClose:SetScript('OnClick', function() base:SetShown(false) end)
    btnCloseFrame = btnClose

    local btnLock = ns.frames:CreateFrame('Button', 'GR_LockButton', self.tblFrame.icon)
    btnLock:SetPoint('RIGHT', btnClose, 'LEFT', -5, 0)
    btnLock:SetSize(20, 20)
    btnLock:SetNormalTexture(ns.BUTTON_LOCKED)
    btnLock:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnLock:SetScript('OnClick', function()
        base.isMoveLocked = not base.isMoveLocked
        btnLock:SetNormalTexture(base.isMoveLocked and ns.BUTTON_LOCKED or ns.BUTTON_UNLOCKED)

        if base.isMoveLocked then
            if lockTimer then GR:CancelTimer(lockTimer) end
            lockTimer = nil
        elseif not base.isMoveLocked then
            lockTimer = GR:ScheduleTimer(function()
                if not lockTimer then return end
                GR:CancelTimer(lockTimer)
                lockTimer = nil

                base.isMoveLocked = true
                btnLock:SetNormalTexture(ns.BUTTON_LOCKED)
                base.tblFrame.frame:SetMovable(not self.isMoveLocked)
                ns.code:cOut(L['AUTO_LOCKED'])
            end, 10)
        end
    end)
end
function base:CreateBottomIcons()
    local btnAbout = ns.frames:CreateFrame('Button', 'GR_AboutButton', self.tblFrame.icon)
    btnAbout:SetPoint('TOP', btnCloseFrame, 'BOTTOM', 0, -5)
    btnAbout:SetSize(20, 20)
    btnAbout:SetNormalTexture(ns.BUTTON_ABOUT)
    btnAbout:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnAbout:SetScript('OnClick', function() ns.observer:Notify('OPEN_ABOUT') end)

    local btnSync = ns.frames:CreateFrame('Button', 'GR_SyncButton', self.tblFrame.icon)
    btnSync:SetPoint('RIGHT', btnAbout, 'LEFT', -5, 0)
    btnSync:SetSize(20, 20)
    btnSync:SetNormalTexture(ns.BUTTON_SYNC_OFF)
    btnSync:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnSync:SetScript('OnClick', function() ns.observer:Notify('SYNC_TOGGLE') end)
end