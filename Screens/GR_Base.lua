local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.base, ns.status = {}, nil
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
    self.syncActive = false
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
        ns.analytics:SaveData()
        return
    end

    if not self.tblFrame then
        self:Init()

        self:CreateBaseFrame()
        self:CreateIconAndStatusFrame()
        self:CreateTopIcons()
        self:CreateBottomIcons()
    end

    self.tblFrame.frame:SetShown(not hideAfter)
    base:buttonAction('HOME')
end
local baseHeight = -60
function base:SwitchToCompactMode(closed, isCompact)
    if closed then isCompact = false end

    local baseFrame = self.tblFrame.frame
    local baseX, baseY = ns.scanner.baseX, ns.scanner.baseY
    local normalX, normalY = 217, ns.scanner.baseY - 25
    local compactX, compactY = 217, 195

    if not closed and isCompact then
        if not ns.g.compactSize or ns.g.compactSize == 1 then baseFrame:SetSize(normalX, normalY)
        elseif isCompact and ns.g.compactSize == 2 then baseFrame:SetSize(compactX, compactY) end

        ns.frames:FixScrollBar("Invite_ScrollFrameScrollBar")
        self.tblFrame.icon:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 0, 0)
        self.tblFrame.icon:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'TOPRIGHT', 0, -35)
        self.tblFrame.iconFrame:SetShown(false)
        self.tblFrame.iconTexture:SetSize(20, 20)
        self.tblFrame.title:SetShown(false)
        self.tblFrame.version:SetShown(false)
        self.tblFrame.compact:SetNormalTexture(ns.BUTTON_EXPAND)
    else
        baseFrame:SetSize(baseX, baseY)
        self.tblFrame.icon:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 0, 0)
        self.tblFrame.icon:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'TOPRIGHT', 0, baseHeight)
        self.tblFrame.iconFrame:SetShown(true)
        self.tblFrame.iconTexture:SetSize(32, 32)
        self.tblFrame.title:SetShown(true)
        self.tblFrame.version:SetShown(true)
        self.tblFrame.compact:SetNormalTexture(ns.BUTTON_COMPACT)
    end
    ns.scanner:CompactModeChanged()
end
function base:CreateBaseFrame()
    local f = ns.frames:CreateFrame('Frame', 'GR_BaseFrame', UIParent)
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
    local f = ns.frames:CreateFrame('Frame', 'GR_BaseIconFrame', self.tblFrame.frame)
    f:SetPoint('TOPLEFT', self.tblFrame.frame, 'TOPLEFT', 0, 0)
    f:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'TOPRIGHT', 0, baseHeight)
    f:SetBackdropColor(0, 0, 0, 1)
    self.tblFrame.icon = f

    local t = f:CreateTexture(nil, 'ARTWORK')
    t:SetPoint('LEFT', f, 'LEFT', 10, 0)
    t:SetTexture(ns.GR_ICON)
    self.tblFrame.iconTexture = t

    local txt = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txt:SetPoint('TOPLEFT', t, 'TOPRIGHT', 10, 0)
    txt:SetText(L['TITLE'])
    txt:SetTextColor(1, 1, 1, 1)
    txt:SetFont(ns.DEFAULT_FONT, 16, 'OUTLINE')
    self.tblFrame.title = txt

    local txtVer = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txtVer:SetPoint('BOTTOMLEFT', t, 'BOTTOMRIGHT', 10, 0)
    txtVer:SetText(GR.versionOut:gsub("[%(%)]", ""))
    txtVer:SetTextColor(1, 1, 1, 1)
    txtVer:SetFont(ns.DEFAULT_FONT, 12, 'OUTLINE')
    self.tblFrame.version = txtVer
    --? End Icon Frame

    --* Create Status Frame
    local fStatus = ns.frames:CreateFrame('Frame', 'GR_BaseStatusFrame', self.tblFrame.frame)
    fStatus:SetPoint('BOTTOMLEFT', self.tblFrame.frame, 'BOTTOMLEFT', 0, 0)
    fStatus:SetPoint('BOTTOMRIGHT', self.tblFrame.frame, 'BOTTOMRIGHT', 0, 0)
    fStatus:SetHeight(30)
    fStatus:SetBackdropColor(0, 0, 0, 1)
    self.tblFrame.status = fStatus

    local txtStatus = fStatus:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    txtStatus:SetPoint('LEFT', fStatus, 'LEFT', 10, 0)
    txtStatus:SetTextColor(1, 1, 1, 1)
    txtStatus:SetFont(ns.DEFAULT_FONT, 14, 'OUTLINE')
    local function SetText(text)
        if not text then return end

        ns.frames:animateText(txtStatus, text)
    end
    ns.status = ns.status or {}
    ns.status.frame = fStatus
    self.tblFrame.status = fStatus
    ns.status.text = txtStatus
    function ns.status:SetText(text) SetText(text) end
end

local lockTimer, iconX, iconY = nil, 18, 18
local function highlightButton(btn, normal)
    if not btn then return end

    local normTexture = btn:GetNormalTexture()
    if not normTexture then return
    else
        local r, g, b, a = normTexture:GetVertexColor()
        if r == 0 and g == 1 and b == 0 and a == 1 then return end
    end

    normTexture:SetAllPoints(true) -- Ensure the texture covers the entire button
    normTexture:SetBlendMode("BLEND") -- Enable alpha blending for transparency
    normTexture:SetTexCoord(0, 1, 0, 1) -- Use the full texture
    if normal then normTexture:SetVertexColor(1, 1, 1, 1)
    else normTexture:SetVertexColor(0.05, 0.70, 0.90, 1) end

    --if lostFocus then normTexture:SetVertexColor(1, 1, 1, 1)
    --else normTexture:SetVertexColor(12, 179, 230, 1) end
end
function base:CreateTopIcons()
    local btnClose = ns.frames:CreateFrame('Button', 'GR_CloseButton', self.tblFrame.icon)
    btnClose:SetPoint('TOPRIGHT', self.tblFrame.icon, 'TOPRIGHT', -10, -10)
    btnClose:SetSize(15, 15)
    btnClose:SetNormalTexture(ns.BUTTON_EXIT)
    btnClose:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnClose:SetScript('OnClick', function() base:SetShown(false) end)
    btnClose:SetScript('OnEnter', function() highlightButton(btnClose) ns.code:createTooltip(L["CLOSE"]..' '..L['TITLE']) end)
    btnClose:SetScript('OnLeave', function() highlightButton(btnClose, true) GameTooltip:Hide() end)

    local btnLock = ns.frames:CreateFrame('Button', 'GR_LockButton', self.tblFrame.icon)
    btnLock:SetPoint('RIGHT', btnClose, 'LEFT', -5, 0)
    btnLock:SetSize(15, 15)
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
    btnLock:SetScript('OnEnter', function() highlightButton(btnLock) ns.code:createTooltip(L['LOCK_TOOLTIP']) end)
    btnLock:SetScript('OnLeave', function() highlightButton(btnLock, true) GameTooltip:Hide() end)

    local btnBack = ns.frames:CreateFrame('Button', 'GR_BackButton', self.tblFrame.icon)
    btnBack:SetPoint('RIGHT', btnLock, 'LEFT', -5, 0)
    btnBack:SetSize(15, 15)
    btnBack:SetNormalTexture(ns.BUTTON_BACK)
    btnBack:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnBack:SetScript('OnClick', function() base:buttonAction('BACK') end)
    btnBack:SetScript('OnEnter', function() highlightButton(btnBack) ns.code:createTooltip(L['BACK'], L['BACK_TOOLTIP']) end)
    btnBack:SetScript('OnLeave', function() highlightButton(btnBack, true) GameTooltip:Hide() end)
    btnBack:SetShown(false)
    self.tblFrame.back = btnBack

    --* Reset Filter Button
    local btnReset = ns.frames:CreateFrame('Button', 'GR_ResetButton', self.tblFrame.icon)
    btnReset:SetPoint('RIGHT', btnBack, 'LEFT', -5, 0)
    btnReset:SetSize(15, 15)
    btnReset:SetNormalTexture(ns.BUTTON_RESET)
    btnReset:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnReset:SetScript('OnClick', function() base:buttonAction('OPEN_RESET') end)
    btnReset:SetScript('OnEnter', function(self) highlightButton(btnReset) ns.code:createTooltip(L['RESET_FILTER'], L['RESET_FILTER_TOOLTIP']) end)
    btnReset:SetScript('OnLeave', function(self) highlightButton(btnReset, true) GameTooltip:Hide() end)
    btnReset:SetShown(false)
    self.tblFrame.reset = btnReset

    --* Compact Button
    local btnCompact = ns.frames:CreateFrame('Button', 'GR_CompactButton', self.tblFrame.icon)
    btnCompact:SetPoint('RIGHT', btnReset, 'LEFT', -5, 0)
    btnCompact:SetSize(15, 15)
    btnCompact:SetNormalTexture(ns.BUTTON_COMPACT)
    btnCompact:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnCompact:SetScript('OnClick', function() base:buttonAction('OPEN_COMPACT') end)
    btnCompact:SetScript('OnEnter', function() highlightButton(btnCompact) ns.code:createTooltip(L['COMPACT_MODE'], 'Toggle compact mode.') end)
    btnCompact:SetScript('OnLeave', function() highlightButton(btnCompact, true) GameTooltip:Hide() end)
    btnCompact:SetShown(false)
    self.tblFrame.compact = btnCompact
end
function base:CreateBottomIcons()
    local iconFrame = ns.frames:CreateFrame('Frame', 'GR_IconFrame', self.tblFrame.icon)
    iconFrame:SetPoint('BOTTOMRIGHT', self.tblFrame.icon, 'BOTTOMRIGHT', 0, 10)
    iconFrame:SetBackdropColor(0, 0, 0, 0)
    iconFrame:SetBackdropBorderColor(0, 0, 0, 0)
    iconFrame:SetSize(6 * iconX, iconY)
    iconFrame:SetBackdropColor(0, 0, 0, 1)
    self.tblFrame.iconFrame = iconFrame

    --* About Button
    local btnAbout = ns.frames:CreateFrame('Button', 'GR_AboutButton', iconFrame)
    btnAbout:SetPoint('RIGHT', iconFrame, 'RIGHT', -10, 0)
    btnAbout:SetSize(iconX, iconY)
    btnAbout:SetNormalTexture(ns.BUTTON_ABOUT)
    btnAbout:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnAbout:SetScript('OnClick', function() base:buttonAction('OPEN_ABOUT') end)
    btnAbout:SetScript('OnEnter', function() highlightButton(btnAbout) ns.code:createTooltip(L["ABOUT"]..' '..L['TITLE'], L['ABOUT_TOOLTIP']) end)
    btnAbout:SetScript('OnLeave', function() highlightButton(btnAbout, true) GameTooltip:Hide() end)
    self.tblFrame.aboutButton = btnAbout

    --* Settings Button
    local btnSettings = ns.frames:CreateFrame('Button', 'GR_SettingsButton', iconFrame)
    btnSettings:SetPoint('RIGHT', btnAbout, 'LEFT', -5, 0)
    btnSettings:SetSize(iconX, iconY)
    btnSettings:SetNormalTexture(ns.BUTTON_SETTINGS)
    btnSettings:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnSettings:SetScript('OnClick', function() base:buttonAction('OPEN_SETTINGS') end)
    btnSettings:SetScript('OnEnter', function() highlightButton(btnSettings) ns.code:createTooltip(L['SETTINGS'], L['SETTINGS_TOOLTIP']) end)
    btnSettings:SetScript('OnLeave', function() highlightButton(btnSettings, true) GameTooltip:Hide() end)

    --* Sync Button
    local btnSync = ns.frames:CreateFrame('Button', 'GR_SyncButton', iconFrame)
    btnSync:SetPoint('RIGHT', btnSettings, 'LEFT', -5, 0)
    btnSync:SetSize(iconX, iconY)
    btnSync:SetNormalTexture(ns.BUTTON_SYNC)
    btnSync:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnSync:SetScript('OnClick', function() base:buttonAction('SYNC_TOGGLE') end)
    btnSync:SetScript('OnEnter', function()
        if not self.syncActive then highlightButton(btnSync) end
        ns.code:createTooltip(L['MANUAL_SYNC'], L['MANUAL_SYNC_TOOLTIP']) end)
    btnSync:SetScript('OnLeave', function() highlightButton(btnSync, true) GameTooltip:Hide() end)
    self.tblFrame.syncButton = btnSync

    --* Stats Button
    local btnStats = ns.frames:CreateFrame('Button', 'GR_StatsButton', iconFrame)
    btnStats:SetPoint('RIGHT', btnSync, 'LEFT', -5, 0)
    btnStats:SetSize(iconX, iconY)
    btnStats:SetNormalTexture(ns.BUTTON_STATS)
    btnStats:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnStats:SetScript('OnClick', function() base:buttonAction('OPEN_STATS') end)
    btnStats:SetScript('OnEnter', function() highlightButton(btnStats) ns.code:createTooltip(L['VIEW_ANALYTICS'], L['VIEW_ANALYTICS_TOOLTIP']) end)
    btnStats:SetScript('OnLeave', function() highlightButton(btnStats, true) GameTooltip:Hide() end)
    self.tblFrame.statsButton = btnStats

    --* Blacklist Button
    local btnBlacklist = ns.frames:CreateFrame('Button', 'GR_BlacklistButton', iconFrame)
    btnBlacklist:SetPoint('RIGHT', btnStats, 'LEFT', -5, 0)
    btnBlacklist:SetSize(iconX, iconY)
    btnBlacklist:SetNormalTexture(ns.BUTTON_BLACKLIST)
    btnBlacklist:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnBlacklist:SetScript('OnClick', function() base:buttonAction('OPEN_BLACKLIST') end)
    btnBlacklist:SetScript('OnEnter', function() highlightButton(btnBlacklist) ns.code:createTooltip(L['BLACKLIST'], L['BLACKLIST_TOOLTIP']) end)
    btnBlacklist:SetScript('OnLeave', function() highlightButton(btnBlacklist, true) GameTooltip:Hide() end)

    --* Filter Button
    local btnFilter = ns.frames:CreateFrame('Button', 'GR_FilterButton', iconFrame)
    btnFilter:SetPoint('RIGHT', btnBlacklist, 'LEFT', -5, 0)
    btnFilter:SetSize(iconX, iconY)
    btnFilter:SetNormalTexture(ns.BUTTON_FILTER)
    btnFilter:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    btnFilter:SetScript('OnClick', function() base:buttonAction('OPEN_FILTER') end)
    btnFilter:SetScript('OnEnter', function(self) highlightButton(btnFilter) ns.code:createTooltip(L['CUSTOM_FILTERS'], L['CUSTOM_FILTERS_TOOLTIP']) end)
    btnFilter:SetScript('OnLeave', function(self) highlightButton(btnFilter, true) GameTooltip:Hide() end)
    btnFilter:SetShown(GR.enableFilter)
end
function base:buttonAction(button)
    --ns.frames:AcceptDialog('Sync\nUnder Construction!!', function() return end)
    if button == 'HOME' then
        base.tblFrame.back:SetShown(false)
        base.tblFrame.reset:SetShown(false)
        base.tblFrame.compact:SetShown(false)
        ns.home:SetShown(true)
    elseif button == 'BACK' then
        ns.observer:Notify('CLOSE_SCREENS')
        base:buttonAction('HOME')
    elseif button == 'OPEN_SCANNER' then
        local valid, msg = ns.home:validate_data_scan_button()
        ns.status:SetText(msg)
        if not valid then return end
        ns.scanner:SetShown(true)
    elseif button == 'OPEN_ABOUT' then ns.about:SetShown(true)
    elseif button == 'OPEN_SETTINGS' then Settings.OpenToCategory('Guild Recruiter')
    elseif button == 'SYNC_TOGGLE' then ns.sync:BeginSync('SERVER')
    elseif button == 'OPEN_STATS' then ns.stats:SetShown(true)
    elseif button == 'OPEN_BLACKLIST' then
        ns.list:ManualBlackList(nil, L['BLACKLIST_NAME_PROMPT'], true)
    elseif button == 'OPEN_RESET' then
        local oldStatus = ns.status.text:GetText()
        ns.status:SetText('Filter was reset.')
        ns.scanner:BuildFilters()
        C_Timer.After(2.5, function() ns.status:SetText(oldStatus) end)
    elseif button == 'OPEN_COMPACT' then
        ns.pSettings.isCompact = not ns.pSettings.isCompact
        ns.scanner:CompactModeChanged(true)
    else ns.frames:AcceptDialog('Under Construction!!', function() return end) end
end