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
local function buttonAction(button)
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
function base:SetShown(val, hideAfter) --! Double Check save
    if not val and not self:IsShown() then return
    elseif not val then
        --ns.code:saveTables()
        --ns.analytics:UpdateSaveData()
        ns.observer:Notify('CLOSE_SCREENS')

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
local btnCloseFrame, lockTimer, iconX, iconY = nil, nil, 18, 18
function base:CreateTopIcons()
    local btnClose = ns.frames:CreateFrame('Button', 'GR_CloseButton', self.tblFrame.icon)
    btnClose:SetPoint('TOPRIGHT', self.tblFrame.icon, 'TOPRIGHT', -10, -10)
    btnClose:SetSize(15, 15)
    btnClose:SetNormalTexture(ns.BUTTON_EXIT)
    btnClose:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnClose:SetScript('OnClick', function() base:SetShown(false) end)
    btnClose:SetScript('OnEnter', function() ns.code:createTooltip(L["CLOSE"]..' '..L['TITLE']) end)
    btnClose:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btnCloseFrame = btnClose

    local btnLock = ns.frames:CreateFrame('Button', 'GR_LockButton', self.tblFrame.icon)
    btnLock:SetPoint('RIGHT', btnClose, 'LEFT', -5, 0)
    btnLock:SetSize(15, 15)
    btnLock:SetNormalTexture(ns.BUTTON_LOCKED)
    btnLock:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnLock:SetScript('OnClick', function()
        base.isMoveLocked = not base.isMoveLocked
        btnLock:SetNormalTexture(base.isMoveLocked and ns.BUTTON_LOCKED or ns.BUTTON_UNLOCKED)

        local normTexture = btnLock:GetNormalTexture()
        if base.isMoveLocked then
            normTexture:SetVertexColor(1, 1, 1, 1)
            if lockTimer then GR:CancelTimer(lockTimer) end
            lockTimer = nil
        elseif not base.isMoveLocked then
            normTexture:SetVertexColor(0, 1, 0, 1)
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
    btnLock:SetScript('OnEnter', function() ns.code:createTooltip('Toggle moving of window') end)
    btnLock:SetScript('OnLeave', function() GameTooltip:Hide() end)

    local btnBack = ns.frames:CreateFrame('Button', 'GR_BackButton', self.tblFrame.icon)
    btnBack:SetPoint('RIGHT', btnLock, 'LEFT', -5, 0)
    btnBack:SetSize(15, 15)
    btnBack:SetNormalTexture(ns.BUTTON_BACK)
    btnBack:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnBack:SetScript('OnClick', function() buttonAction('BACK') end)
    btnBack:SetScript('OnEnter', function() ns.code:createTooltip('Back', 'Go back to previous screen.') end)
    btnBack:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btnBack:SetShown(false)
end
function base:CreateBottomIcons()
    local btnAbout = ns.frames:CreateFrame('Button', 'GR_AboutButton', self.tblFrame.icon)
    btnAbout:SetPoint('TOP', btnCloseFrame, 'BOTTOM', 0, -(iconY - 10))
    btnAbout:SetSize(iconX, iconY)
    btnAbout:SetNormalTexture(ns.BUTTON_ABOUT)
    btnAbout:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnAbout:SetScript('OnClick', function() buttonAction('OPEN_ABOUT') end)
    btnAbout:SetScript('OnEnter', function() ns.code:createTooltip(L["ABOUT"]..' '..L['TITLE'], 'Links to support and contributions.') end)
    btnAbout:SetScript('OnLeave', function() GameTooltip:Hide() end)

    local btnSync = ns.frames:CreateFrame('Button', 'GR_SyncButton', self.tblFrame.icon)
    btnSync:SetPoint('RIGHT', btnAbout, 'LEFT', -5, 0)
    btnSync:SetSize(iconX, iconY)
    btnSync:SetNormalTexture(ns.BUTTON_SYNC)
    btnSync:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnSync:SetScript('OnClick', function() buttonAction('SYNC_TOGGLE') end)
    btnSync:SetScript('OnEnter', function() ns.code:createTooltip('Toggle Syncing', 'Syncs data with other users.') end)
    btnSync:SetScript('OnLeave', function() GameTooltip:Hide() end)

    local btnStats = ns.frames:CreateFrame('Button', 'GR_StatsButton', self.tblFrame.icon)
    btnStats:SetPoint('RIGHT', btnSync, 'LEFT', -5, 0)
    btnStats:SetSize(iconX, iconY)
    btnStats:SetNormalTexture(ns.BUTTON_STATS)
    btnStats:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnStats:SetScript('OnClick', function() buttonAction('OPEN_STATS') end)
    btnStats:SetScript('OnEnter', function() ns.code:createTooltip('View Stats', 'View stats and data.') end)
    btnStats:SetScript('OnLeave', function() GameTooltip:Hide() end)

    local btnBlacklist = ns.frames:CreateFrame('Button', 'GR_BlacklistButton', self.tblFrame.icon)
    btnBlacklist:SetPoint('RIGHT', btnStats, 'LEFT', -5, 0)
    btnBlacklist:SetSize(iconX, iconY)
    btnBlacklist:SetNormalTexture(ns.BUTTON_BLACKLIST)
    btnBlacklist:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnBlacklist:SetScript('OnClick', function() buttonAction('OPEN_BLACKLIST') end)
    btnBlacklist:SetScript('OnEnter', function() ns.code:createTooltip(L['BLACKLIST'], 'Manually add players to blacklist.') end)
    btnBlacklist:SetScript('OnLeave', function() GameTooltip:Hide() end)

    local btnFilter = ns.frames:CreateFrame('Button', 'GR_FilterButton', self.tblFrame.icon)
    btnFilter:SetPoint('RIGHT', btnBlacklist, 'LEFT', -5, 0)
    btnFilter:SetSize(iconX, iconY)
    btnFilter:SetNormalTexture(ns.BUTTON_FILTER)
    btnFilter:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnFilter:SetScript('OnClick', function() buttonAction('OPEN_FILTER') end)
    btnFilter:SetScript('OnEnter', function() ns.code:createTooltip('Custom Filters', 'Create custom filters.') end)
    btnFilter:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btnFilter:SetShown(GR.enableFilter)

    local btnReset = ns.frames:CreateFrame('Button', 'GR_ResetButton', self.tblFrame.icon)
    local btnResetAnchor = btnFilter:IsShown() and btnFilter or btnBlacklist
    btnReset:SetPoint('RIGHT', btnResetAnchor, 'LEFT', -5, 0)
    btnReset:SetSize(iconX, iconY)
    btnReset:SetNormalTexture(ns.BUTTON_RESET)
    btnReset:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnReset:SetScript('OnClick', function() buttonAction('OPEN_RESET') end)
    btnReset:SetScript('OnEnter', function() ns.code:createTooltip('Reset Filter', 'Restart filter.') end)
    btnReset:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btnReset:SetShown(false)

    local btnCompact = ns.frames:CreateFrame('Button', 'GR_CompactButton', self.tblFrame.icon)
    btnCompact:SetPoint('RIGHT', btnReset, 'LEFT', -5, 0)
    btnCompact:SetSize(iconX, iconY)
    btnCompact:SetNormalTexture(ns.BUTTON_COMPACT)
    btnCompact:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnCompact:SetScript('OnClick', function() buttonAction('OPEN_COMPACT') end)
    btnCompact:SetScript('OnEnter', function() ns.code:createTooltip('Compact Mode', 'Toggle compact mode.') end)
    btnCompact:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btnCompact:SetShown(false)
end