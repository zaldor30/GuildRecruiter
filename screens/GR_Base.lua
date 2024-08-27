local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

ns.win, ns.statusText = {}, nil
ns.win.base, ns.win.iconBar = {}, {}

-- Frame Dragging Routines
local function OnDragStart(self)
    if ns.win.base.isMoveLocked then return end
    self:StartMoving()
end
local function OnDragStop(self)
    self:StopMovingOrSizing()

    ns.win.base.screenPos.point,_,_, ns.win.base.screenPos.x, ns.win.base.screenPos.y = self:GetPoint()
    ns.pSettings.screenPos = ns.win.base.screenPos
end

-- * Create the Main (base) Window
local base = ns.win.base
function base:Init()
    self.inviteMessage = nil
    self.isMoveLocked = true

    self.tblFrame = {}

    self.screenPos = { -- Get default position and current position
        point = 'CENTER',
        x = 0,
        y = 0
    }
end
function base:StartUp() -- Start the Main (base) Window.  Called from ns.core.
    self.screenPos = ns.pSettings.screenPos or self.screenPos

    self:CreateBaseFrame()
    self:CreateBaseHeaderFrame()
    self:CreateBaseIconFrame()
    self:CreateStatusBarFrame()
end
function base:CreateBaseFrame()
    local function checkIfGuildRecuiterIsEnabled()
        local notSpecial = false
        for _, r in pairs(UISpecialFrames) do
            if r == 'GuildRecruiter' then
                notSpecial = true
                break
            end
        end

        if not notSpecial and not ns.gSettings.keepOpen then
            _G['GuildRecruiter'] = self.tblFrame.frame
            tinsert(UISpecialFrames, 'GuildRecruiter')
        end
    end

    local f = CreateFrame('Frame', 'GR_Base', UIParent, 'BackdropTemplate')
    f:SetSize(500, 400)
    f:SetPoint(self.screenPos.point, self.screenPos.x, self.screenPos.y)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript('OnDragStart', OnDragStart)
    f:SetScript('OnDragStop', OnDragStop)
    f:SetScript('OnHide', function()
        ns.code:saveTables()

        self.tblFrame.frame:SetShown(false)
        ns.observer:Notify('CLOSE_SCREENS')
    end)

    self.tblFrame.frame = f
    checkIfGuildRecuiterIsEnabled()
end
function base:CreateBaseHeaderFrame()
    local tblFrame = base.tblFrame

    -- Create the top frame
    local f = tblFrame.topFrame or CreateFrame('Frame', 'GR_BASE_topFrame', tblFrame.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(1, 1, 1, .5)
    f:SetPoint('TOPLEFT', tblFrame.frame, 'TOPLEFT', 5, -5)
    f:SetPoint('BOTTOMRIGHT', tblFrame.frame, 'TOPRIGHT', -5, -60)
    f:SetShown(true)
    tblFrame.topFrame = f

    -- Application (About) Icon
    -- ToDo: Change onClick

    -- Title Text
    local textString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString:SetPoint('LEFT', 7, 12)
    textString:SetText(L['TITLE'])
    textString:SetTextColor(1, 1, 1, 1) -- Set the text color (r,g,b,a) values
    textString:SetFont(DEFAULT_FONT, 16, 'OUTLINE')

    -- Close Button
    local closeButton = CreateFrame('Button', 'GR_BASE_CLOSE', f)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint('TOPRIGHT', -7, -7)
    closeButton:SetNormalTexture(ICON_PATH..'GR_Exit')
    closeButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    closeButton:SetScript('OnClick', function() tblFrame.frame:SetShown(false) end)
    closeButton:SetScript('OnEnter', function() ns.code:createTooltip(L['CLOSE']..' '..L['TITLE']) end)
    closeButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    closeButton:SetShown(true)

    -- Lock Button
    local lockButton = CreateFrame('Button', 'GR_BASE_LOCK', f)
    lockButton:SetSize(20, 20)
    lockButton:SetPoint('TOPRIGHT', closeButton, 'TOPLEFT', 0, 2)
    lockButton:SetNormalTexture(BUTTON_LOCKED)
    lockButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    lockButton:SetScript('OnClick', function()
        self.isMoveLocked = not self.isMoveLocked
        tblFrame.frame:SetMovable(not self.isMoveLocked)

        if self.isMoveLocked then lockButton:SetNormalTexture(BUTTON_LOCKED)
        else lockButton:SetNormalTexture(BUTTON_UNLOCKED) end
    end)
    lockButton:SetScript('OnEnter', function() ns.code:createTooltip(L['LOCK']..' '..L['TITLE'], L['LOCK_TOOLTIP']) end)
    lockButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    lockButton:SetShown(true)

    -- Go Back Icon
    local backIconButton = CreateFrame('Button', 'GR_BASE_BACKICON', tblFrame.topFrame)
    backIconButton:SetSize(20, 20)
    backIconButton:SetPoint('TOPRIGHT', lockButton, 'TOPLEFT', 0, 0)
    backIconButton:SetNormalTexture(ICON_PATH..'GR_Back')
    backIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    backIconButton:SetScript('OnClick', function()
        ns.observer:Notify('CLOSE_SCREENS')
        ns.win.home:SetShown(true)
    end)
    backIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['HOME_BUTTON']) end)
    backIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    backIconButton:SetShown(false)
    tblFrame.backButton = backIconButton
end
function base:CreateBaseIconFrame()
    local tblFrame = base.tblFrame

    local f = CreateFrame('Frame', 'GR_BASE_ICONBAR', tblFrame.topFrame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetBackdropColor(1, 1, 1, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:SetPoint('TOPLEFT', tblFrame.topFrame, 'TOPLEFT', 0, -25)
    f:SetPoint('BOTTOMRIGHT', tblFrame.topFrame, 'BOTTOMRIGHT', 0, 0)
    f:SetShown(true)
    tblFrame.iconFrame = f

    -- Settings Icon
    local settingsIconButton = CreateFrame('Button', 'GR_BASE_SETTINGSICON', tblFrame.topFrame)
    settingsIconButton:SetSize(20, 20)
    settingsIconButton:SetPoint('BOTTOMLEFT', 5, 5)
    settingsIconButton:SetNormalTexture(ICON_PATH..'GR_Settings')
    settingsIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    settingsIconButton:SetScript('OnClick', function() Settings.OpenToCategory('Guild Recruiter') end)
    settingsIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['TITLE']..' '..L['SETTINGS'], L['SETTINGS_TOOLTIP']) end)
    settingsIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    settingsIconButton:SetShown(true)

    -- Sync Icon
    local syncIconButton = CreateFrame('Button', 'GR_BASE_SYNCICON', tblFrame.topFrame)
    syncIconButton:SetSize(20, 20)
    syncIconButton:SetPoint('LEFT', settingsIconButton, 'RIGHT', 5, 0)
    syncIconButton:SetNormalTexture(ICON_PATH..'GR_Sync')
    syncIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    syncIconButton:SetScript('OnClick', function() ns.sync:StartSyncRoutine(2) end)
    syncIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['SYNC']..' '..L['TITLE'], L['SYNC_TOOLTIP']) end)
    syncIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    if self.isSyncing then syncIconButton:GetNormalTexture():SetVertexColor(0,1,0,1)
    else syncIconButton:GetNormalTexture():SetVertexColor(1,1,1,1) end
    tblFrame.syncIcon = syncIconButton

    -- Stats Icon
    local statsIconButton = CreateFrame('Button', 'GR_BASE_STATSICON', tblFrame.topFrame)
    statsIconButton:SetSize(20, 20)
    statsIconButton:SetPoint('LEFT', syncIconButton, 'RIGHT', 5, 0)
    statsIconButton:SetNormalTexture(ICON_PATH..'GR_Stats')
    statsIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    statsIconButton:SetScript('OnClick', function() ns.win.analytics:SetShown(true) end)
    statsIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['TITLE']..' '..L['ANALYTICS'], L['ANALYTICS_TOOLTIP']) end)
    statsIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    tblFrame.statsButton = statsIconButton

    -- Add to Black List Icon
    local blacklistIconButton = CreateFrame('Button', 'GR_BASE_BLACKLISTICON', tblFrame.topFrame)
    blacklistIconButton:SetSize(20, 20)
    blacklistIconButton:SetPoint('LEFT', statsIconButton, 'RIGHT', 5, 0)
    blacklistIconButton:SetNormalTexture(ICON_PATH..'GR_Blacklist')
    blacklistIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    blacklistIconButton:SetScript('OnClick', function()
        ns.blackList:ManualBlackListPrompt(L['BLACK_LIST'], nil, true)
    end)
    blacklistIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['BLACK_LIST'], L['BLACKLIST_TOOLTIP']) end)
    blacklistIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    blacklistIconButton:SetShown(true)

    -- Create Filter 
    if ns.pSettings.debugMode then
        local filterIconButton = CreateFrame('Button', 'GR_BASE_FILTERICON', tblFrame.topFrame)
        filterIconButton:SetSize(20, 20)
        filterIconButton:SetPoint('LEFT', blacklistIconButton, 'RIGHT', 5, 0)
        filterIconButton:SetNormalTexture(ICON_PATH..'GR_Filter')
        filterIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
        filterIconButton:SetScript('OnClick', function() ns.win.filter:SetShown(true) end)
        filterIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['FILTER_EDITOR'], L['FILTER_EDITOR_TOOLTIP']) end)
        filterIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    end

    -- About Icon
    local aboutButton = CreateFrame('Button', 'GR_ABOUT_BUTTON', tblFrame.topFrame)
    aboutButton:SetSize(20, 20)
    aboutButton:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -5, 5)
    aboutButton:SetNormalTexture(ICON_PATH..'GR_About')
    aboutButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    aboutButton:SetScript('OnClick', function() ns.win.about:SetShown(true) end)
    aboutButton:SetScript('OnEnter', function() ns.code:createTooltip(L['ABOUT']..' '..L['TITLE'], L['ABOUT_TOOLTIP']) end)
    aboutButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    tblFrame.aboutButton = aboutButton

    -- Compact Mode Icon
    local compactIconButton = CreateFrame('Button', 'GR_BASE_COMPACTICON', tblFrame.topFrame)
    compactIconButton:SetSize(20, 20)
    compactIconButton:SetPoint('RIGHT', aboutButton, 'LEFT', -5, 0)
    compactIconButton:SetNormalTexture(ICON_PATH..'GR_Compact')
    compactIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    compactIconButton:SetShown(false)
    compactIconButton:SetScript('OnClick', function() ns.win.scanner:ChangeCompactMode() end)
    compactIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['COMPACT_MODE'], L['COMPACT_MODE_TOOLTIP']) end)
    compactIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    compactIconButton:SetShown(false)
    tblFrame.compactButton = compactIconButton

    -- Reset Filter Icon
    local resetIconButton = CreateFrame('Button', 'GR_BASE_RESETICON', tblFrame.topFrame)
    resetIconButton:SetSize(20, 20)
    resetIconButton:SetPoint('RIGHT', compactIconButton, 'LEFT', 2, 0)
    resetIconButton:SetNormalTexture(ICON_PATH..'GR_Reset')
    resetIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    resetIconButton:SetScript('OnClick', function() ns.win.scanner:ResetFilters() end)
    resetIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['RESET_FILTER'], L['RESET_FILTER_TOOLTIP']) end)
    resetIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    resetIconButton:SetShown(false)
    tblFrame.resetButton = resetIconButton
end
function base:CreateStatusBarFrame()
    local tblFrame = self.tblFrame

    -- Status Bar
    local statusBar = CreateFrame('StatusBar', 'GR_BASE_STATUSBAR', tblFrame.frame, 'BackdropTemplate')
    statusBar:SetPoint('BOTTOMLEFT', tblFrame.frame, 'BOTTOMLEFT', 5, 5)
    statusBar:SetSize(tblFrame.frame:GetWidth() - 10, 25)
    statusBar:SetBackdrop(BackdropTemplate())
    statusBar:SetBackdropColor(1, 1, 1, 1)
    statusBar:SetBackdropBorderColor(1, 1, 1, .5)
    statusBar:SetShown(true)
    tblFrame.statusBar = statusBar

    local statusText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("LEFT", statusBar, "LEFT", 5, 0) -- Set the text position
    statusText:SetText('')
    statusText:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    statusText:SetJustifyH('LEFT')
    tblFrame.statusText = statusText
    ns.statusText = statusText

    tblFrame.frame:SetScript('OnSizeChanged', function()
        statusBar:SetSize(tblFrame.frame:GetWidth() - 10, 25)
    end)
end
function base:SetShown(val) self.tblFrame.frame:SetShown(val) end
base:Init()