local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')

ns.screens = {}
ns.screens.base, ns.iconBar = {}, {}

-- Frame Dragging Routines
local function OnDragStart(self)
    if ns.screens.base.isMoveLocked then return end
    self:StartMoving()
end
local function OnDragStop(self)
    self:StopMovingOrSizing()

    ns.screens.base.screenPos.point,_,_, ns.screens.base.screenPos.x, ns.screens.base.screenPos.y = self:GetPoint()
    ns.settings.screenPos = ns.screens.base.screenPos
end

local base = ns.screens.base
function base:Init()
    self.isSyncing = false
    self.isMoveLocked = true

    self.tblFrame = {}

    self.screenPos = { -- Get default position and current position
        point = 'CENTER',
        x = 0,
        y = 0
    }
end
function base:StartUp()
    self:BuildBase()
    self.tblFrame.frame:SetShown(false)

    _G['GuildRecruiter'] = self.tblFrame.frame
    tinsert(UISpecialFrames, 'GuildRecruiter')
end
function base:BuildBase()
    if base.tblFrame.frame then return end

    local tblFrame = self.tblFrame
    local f = CreateFrame('Frame', 'GR_Base', UIParent, 'BackdropTemplate')
    self.screenPos = ns.settings.screenPos or self.screenPos
    f:SetPoint(self.screenPos.point, self.screenPos.x, self.screenPos.y)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetBackdropColor(0, 0, 0, .85)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:SetSize(500, 400)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript('OnMouseDown', OnDragStart)
    f:SetScript('OnMouseUp', OnDragStop)
    f:SetScript('OnHide', function()
        if ns.core.fullyStarted then
            ns.code:saveTables() end

        tblFrame.frame:SetShown(false)
        ns.observer:Notify('CLOSE_SCREENS')
    end)
    tblFrame.frame = f

    self:BuildTopFrame()
    self:BuildIconFrame()
    self:BuildStatusBarFrame()
end
function base:BuildTopFrame()
    local tblFrame = base.tblFrame

    local f = CreateFrame('Frame', 'GR_BASE_topFrame', tblFrame.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(1, 1, 1, .5)
    f:SetPoint('TOPLEFT', tblFrame.frame, 'TOPLEFT', 5, -5)
    f:SetPoint('BOTTOMRIGHT', tblFrame.frame, 'TOPRIGHT', -5, -55)
    f:SetShown(true)
    tblFrame.topFrame = f

    -- Application (About) Icon
    local appIconButton = CreateFrame('Button', 'GR_BASE_APPICON', f)
    appIconButton:SetSize(16, 16)
    appIconButton:SetPoint('TOPLEFT', 7, -7)
    appIconButton:SetNormalTexture(GR.icon)
    appIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    appIconButton:SetScript('OnClick', function() ns.screens.about:StartUp() end)
    appIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['About']..' '..L['TITLE']) end)
    appIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    appIconButton:SetShown(true)

    -- Title Text
    local textString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString:SetPoint('LEFT', appIconButton, 'RIGHT', 5, 0) -- Set the text position
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
    closeButton:SetScript('OnEnter', function() ns.code:createTooltip(L['Close']..' '..L['TITLE']) end)
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
    lockButton:SetScript('OnEnter', function() ns.code:createTooltip(L['Lock']..' '..L['TITLE']) end)
    lockButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    lockButton:SetShown(true)
end
function base:BuildIconFrame()
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
    settingsIconButton:SetScript('OnClick', function() InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end)
    settingsIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['TITLE']..' '..L['Settings']) end)
    settingsIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    settingsIconButton:SetShown(true)

    -- Sync Icon
    local syncIconButton = CreateFrame('Button', 'GR_BASE_SYNCICON', tblFrame.topFrame)
    syncIconButton:SetSize(20, 20)
    syncIconButton:SetPoint('LEFT', settingsIconButton, 'RIGHT', 5, 0)
    syncIconButton:SetNormalTexture(ICON_PATH..'GR_Sync')
    syncIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    syncIconButton:SetScript('OnClick', function() ns.sync:StartSync(true) end)
    syncIconButton:SetScript('OnEnter', function() ns.code:createTooltip('Sync '..L['TITLE']) end)
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
    statsIconButton:SetScript('OnClick', function() ns.screens.analytics:StartStatsScreen() end)
    statsIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['TITLE']..' '..L['Analytics']) end)
    statsIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    tblFrame.statsButton = statsIconButton

    -- Add to Black List Icon
    local blacklistIconButton = CreateFrame('Button', 'GR_BASE_BLACKLISTICON', tblFrame.topFrame)
    blacklistIconButton:SetSize(20, 20)
    blacklistIconButton:SetPoint('LEFT', statsIconButton, 'RIGHT', 5, 0)
    blacklistIconButton:SetNormalTexture(ICON_PATH..'GR_Blacklist')
    blacklistIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    blacklistIconButton:SetScript('OnClick', function()
        local POPUP_NAME, POPUP_REASON, blName = "inputName", "inputReason", nil
        local blMsg = L['WHO_TO_BLACK_LIST']
        blMsg = blMsg..'\n'..L['BL_WARNING_LINE_1']
        blMsg = blMsg..'\n'..L['BL_WARNING_LINE_2']

        StaticPopupDialogs[POPUP_NAME] = {
            text = blMsg,
            button1 = L['OK'],
            button2 = L['Cancel'],
            OnAccept = function(data)
                local value = data.editBox:GetText()
                if not value or value == '' then return end

                blName = value

                StaticPopupDialogs[POPUP_REASON] = {
                    text = L['Why do you want to black list?']..'\n'..blName,
                    button1 = L['OK'],
                    button2 = L['Cancel'],
                    OnAccept = function(rData)
                        if not blName then return end

                        value = rData.editBox:GetText()
                        value = value ~= '' and value or L['No Reason']

                        if not blName or not value then return end
                        ns.blackList:AddToBlackList(blName, value)
                    end,
                    OnCancel = function() UIErrorsFrame:AddMessage(blName..' '..L['BL_NAME_NOT_ADDED'], 1.0, 0.1, 0.1, 1.0) end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                    preferredIndex = 3,
                    hasEditBox = true,
                    maxLetters = 255,
                    -- You can add more properties as needed
                }

                StaticPopup_Show(POPUP_REASON)
            end,
            OnCancel = function() UIErrorsFrame:AddMessage(L['BL_NO_ONE_ADDED'], 1.0, 0.1, 0.1, 1.0) end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            hasEditBox = true,
            maxLetters = 255,
            -- You can add more properties as needed
        }

        StaticPopup_Show(POPUP_NAME)
    end)
    blacklistIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['Add to Blacklist']) end)
    blacklistIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    blacklistIconButton:SetShown(true)

    -- Create Filter Icon
    local filterIconButton = CreateFrame('Button', 'GR_BASE_FILTERICON', tblFrame.topFrame)
    filterIconButton:SetSize(20, 20)
    filterIconButton:SetPoint('LEFT', blacklistIconButton, 'RIGHT', 5, 0)
    filterIconButton:SetNormalTexture(ICON_PATH..'GR_Filter')
    filterIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    filterIconButton:SetScript('OnClick', function() ns.stats:StartStatsScreen() end)
    filterIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['Create Filter']) end)
    filterIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)

    -- Reset Filter Icon
    local resetIconButton = CreateFrame('Button', 'GR_BASE_RESETICON', tblFrame.topFrame)
    resetIconButton:SetSize(20, 20)
    resetIconButton:SetPoint('LEFT', filterIconButton, 'RIGHT', 5, 0)
    resetIconButton:SetNormalTexture(ICON_PATH..'GR_Reset')
    resetIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    resetIconButton:SetScript('OnClick', function() ns.screens.scanner:BuildFilter(false, 'RESET') end)
    resetIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['Reset Filters']) end)
    resetIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    resetIconButton:SetShown(false)
    tblFrame.resetButton = resetIconButton

    -- Go Back Icon
    local backIconButton = CreateFrame('Button', 'GR_BASE_BACKICON', tblFrame.topFrame)
    backIconButton:SetSize(20, 20)
    backIconButton:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -5, 5)
    backIconButton:SetNormalTexture(ICON_PATH..'GR_Back')
    backIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    backIconButton:SetScript('OnClick', function() ns.screens.home:StartUp() end)
    backIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['Home']) end)
    backIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    backIconButton:SetShown(false)
    tblFrame.backButton = backIconButton

    -- Compact Mode Icon
    local compactIconButton = CreateFrame('Button', 'GR_BASE_COMPACTICON', tblFrame.topFrame)
    compactIconButton:SetSize(20, 20)
    compactIconButton:SetPoint('RIGHT', backIconButton, 'LEFT', -5, 0)
    compactIconButton:SetNormalTexture(ICON_PATH..'GR_Compact')
    compactIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    compactIconButton:SetShown(false)
    compactIconButton:SetScript('OnClick', function()
        ns.settings.compactMode = not ns.settings.compactMode
        ns.screens.scanner.isCompact = ns.settings.compactMode
        ns.screens.scanner:SwitchCompactMode()
    end)
    compactIconButton:SetScript('OnEnter', function() ns.code:createTooltip(L['Compact Mode']) end)
    compactIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    compactIconButton:SetShown(false)
    tblFrame.compactButton = compactIconButton
end
function base:BuildStatusBarFrame()
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

    tblFrame.frame:SetScript('OnSizeChanged', function()
        statusBar:SetSize(tblFrame.frame:GetWidth() - 10, 25)
    end)
end
base:Init()