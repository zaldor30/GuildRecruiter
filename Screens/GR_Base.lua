-- Guild Recruiter Base Screen
local _, ns = ... -- Namespace (myaddon, namespace)

ns.screen = {}
local screen, template = ns.screen, {}

-- Frame Dragging Routine
local function OnDragStart(self)
    if template.locked then return end
    self:StartMoving()
end
local function OnDragStop(self)
    self:StopMovingOrSizing()
    template.screenPos.point,_,_, template.screenPos.x, template.screenPos.y = self:GetPoint()
    ns.db.settings.screenPos = template.screenPos
end

function screen:Init()
    self.tblFrame = {}
end
function screen:AddonLoaded()
    template.screenPos = ns.db.settings.screenPos or template.screenPos

    template:BuildTemplate()
    self.tblFrame.frame:SetShown(false)
end
screen:Init()

function template:Init()
    self.locked = true

    self.screenPos = { -- Get default position and current position
        point = 'CENTER',
        x = 0,
        y = 0
    }
end
function template:BuildTemplate()
    if screen.tblFrame.frame then return end

    local tblFrame = screen.tblFrame

    local f = CreateFrame('Frame', 'GR_BASE_FRAME', UIParent, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetBackdropColor(0, 0, 0, .75)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:SetSize(500, 400)
    f:SetPoint(self.screenPos.point, self.screenPos.x, self.screenPos.y)
    f:EnableMouse(true)
    f:SetMovable(false)
    f:RegisterForDrag("LeftButton")
    f:SetScript('OnMouseDown', OnDragStart)
    f:SetScript('OnMouseUp', OnDragStop)
    f:SetScript('OnHide', function()
        tblFrame.frame:SetShown(false)
        ns.observer:Notify('CLOSE_SCREENS')
        ns.code:saveTables()
    end)
    tblFrame.frame = f

    _G["GuildRecruiter"] = f
    tinsert(UISpecialFrames, "GuildRecruiter")

    self:BuildTitleFrame()
    self:BuildIconBar()

    -- Status Bar
    local statusBar = CreateFrame('StatusBar', 'GR_BASE_STATUSBAR', f, 'BackdropTemplate')
    statusBar:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 5, 5)
    statusBar:SetSize(f:GetWidth() - 10, 25)
    statusBar:SetBackdrop(BackdropTemplate())
    statusBar:SetBackdropColor(1, 1, 1, 0)
    statusBar:SetBackdropBorderColor(1, 1, 1, .5)
    statusBar:SetShown(true)
    tblFrame.statusBar = statusBar

    local statusText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("LEFT", statusBar, "LEFT", 5, 0) -- Set the text position
    statusText:SetText('')
    statusText:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    statusText:SetJustifyH('LEFT')
    tblFrame.statusText = statusText

    f:SetScript('OnSizeChanged', function()
        statusBar:SetSize(f:GetWidth() - 10, 25)
    end)
end
function template:BuildTitleFrame()
    local tblFrame = screen.tblFrame

    local f = CreateFrame('Frame', 'GR_BASE_titleFrame', tblFrame.frame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(1, 1, 1, .5)
    f:SetPoint('TOPLEFT', tblFrame.frame, 'TOPLEFT', 5, -5)
    f:SetPoint('BOTTOMRIGHT', tblFrame.frame, 'TOPRIGHT', -5, -55)
    f:SetShown(true)

    tblFrame.titleFrame = f

    -- Application (About) Icon
    local appIconButton = CreateFrame('Button', 'GR_BASE_APPICON', f)
    appIconButton:SetSize(16, 16)
    appIconButton:SetPoint('TOPLEFT', 7, -7)
    appIconButton:SetNormalTexture(GRADDON.icon)
    appIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    appIconButton:SetScript('OnClick', function() ns.screen.about:EnterAboutScreen() end)
    appIconButton:SetScript('OnEnter', function() ns.code:createTooltip('About '..GRADDON.title) end)
    appIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    appIconButton:SetShown(true)

    -- Title Text
    local textString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString:SetPoint('LEFT', appIconButton, 'RIGHT', 5, 0) -- Set the text position
    textString:SetText(GRADDON.title)
    textString:SetTextColor(1, 1, 1, 1) -- Set the text color (r,g,b,a) values
    textString:SetFont(DEFAULT_FONT, 16, 'OUTLINE')

    -- Close Button
    local closeButton = CreateFrame('Button', 'GR_BASE_CLOSE', f)
    closeButton:SetSize(16, 16)
    closeButton:SetPoint('TOPRIGHT', -7, -7)
    closeButton:SetNormalTexture(ICON_PATH..'GR_Exit')
    closeButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    closeButton:SetScript('OnClick', function() tblFrame.frame:SetShown(false) end)
    closeButton:SetScript('OnEnter', function() ns.code:createTooltip('Close '..GRADDON.title) end)
    closeButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    closeButton:SetShown(true)

    -- Lock Button
    local lockButton = CreateFrame('Button', 'GR_BASE_LOCK', f)
    lockButton:SetSize(20, 20)
    lockButton:SetPoint('TOPRIGHT', closeButton, 'TOPLEFT', 0, 2)
    lockButton:SetNormalTexture(BUTTON_LOCKED)
    lockButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    lockButton:SetScript('OnClick', function()
        self.locked = not self.locked
        tblFrame.frame:SetMovable(not self.locked)

        if self.locked then
            lockButton:SetNormalTexture(BUTTON_LOCKED)
        else
            lockButton:SetNormalTexture(BUTTON_UNLOCKED)
        end
    end)
    lockButton:SetScript('OnEnter', function() ns.code:createTooltip('Lock '..GRADDON.title) end)
    lockButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    lockButton:SetShown(true)
end
function template:BuildIconBar()
    local tblFrame = screen.tblFrame

    local f = CreateFrame('Frame', 'GR_BASE_ICONBAR', tblFrame.titleFrame, 'BackdropTemplate')
    f:SetBackdrop(BackdropTemplate())
    f:SetBackdropColor(1, 1, 1, 0)
    f:SetBackdropBorderColor(1, 1, 1, 0)
    f:SetPoint('TOPLEFT', tblFrame.titleFrame, 'TOPLEFT', 0, -25)
    f:SetPoint('BOTTOMRIGHT', tblFrame.titleFrame, 'BOTTOMRIGHT', 0, 0)
    f:SetShown(true)

    tblFrame.iconFrame = f

    -- Settings Icon
    local settingsIconButton = CreateFrame('Button', 'GR_BASE_SETTINGSICON', tblFrame.titleFrame)
    settingsIconButton:SetSize(20, 20)
    settingsIconButton:SetPoint('BOTTOMLEFT', 5, 5)
    settingsIconButton:SetNormalTexture(ICON_PATH..'GR_Settings')
    settingsIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    settingsIconButton:SetScript('OnClick', function() InterfaceOptionsFrame_OpenToCategory(ns.addonOptions) end)
    settingsIconButton:SetScript('OnEnter', function() ns.code:createTooltip(GRADDON.title..' Settings') end)
    settingsIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    settingsIconButton:SetShown(true)

    -- Sync Icon
    local syncIconButton = CreateFrame('Button', 'GR_BASE_SYNCICON', tblFrame.titleFrame)
    syncIconButton:SetSize(20, 20)
    syncIconButton:SetPoint('LEFT', settingsIconButton, 'RIGHT', 5, 0)
    syncIconButton:SetNormalTexture(ICON_PATH..'GR_Sync')
    syncIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    syncIconButton:SetScript('OnClick', function() ns.sync:StartSyncServer() end)
    syncIconButton:SetScript('OnEnter', function() ns.code:createTooltip('Sync '..GRADDON.title) end)
    syncIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    screen.tblFrame.syncIcon = syncIconButton

    -- Stats Icon
    local statsIconButton = CreateFrame('Button', 'GR_BASE_STATSICON', tblFrame.titleFrame)
    statsIconButton:SetSize(20, 20)
    statsIconButton:SetPoint('LEFT', syncIconButton, 'RIGHT', 5, 0)
    statsIconButton:SetNormalTexture(ICON_PATH..'GR_Stats')
    statsIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    statsIconButton:SetScript('OnClick', function() ns.stats:StartStatsScreen() end)
    statsIconButton:SetScript('OnEnter', function() ns.code:createTooltip(GRADDON.title..' Stats') end)
    statsIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    screen.tblFrame.statsButton = statsIconButton

    -- Add to Black List Icon
    local blacklistIconButton = CreateFrame('Button', 'GR_BASE_BLACKLISTICON', tblFrame.titleFrame)
    blacklistIconButton:SetSize(20, 20)
    blacklistIconButton:SetPoint('LEFT', statsIconButton, 'RIGHT', 5, 0)
    blacklistIconButton:SetNormalTexture(ICON_PATH..'GR_Blacklist')
    blacklistIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    blacklistIconButton:SetScript('OnClick', function()
        local POPUP_NAME, POPUP_REASON, blName = "inputName", "inputReason", nil
        StaticPopupDialogs[POPUP_NAME] = {
            text = "Who would you like to Black List?\nSpelling counts, include realm name if needed.\n \nBetter to right click on player\nto add to black list.",
            button1 = "OK",
            button2 = "Cancel",
            OnAccept = function(data)
                local value = data.editBox:GetText()
                if not value or value == '' then return end

                blName = value

                StaticPopupDialogs[POPUP_REASON] = {
                    text = "Why do you want to black list:\n"..blName,
                    button1 = "OK",
                    button2 = "Cancel",
                    OnAccept = function(rData)
                        if not blName then return end

                        value = rData.editBox:GetText()
                        value = value ~= '' and value or 'No reason'

                        if not blName or not value then return end
                        ns.blackList:AddToBlackList(blName, value)
                    end,
                    OnCancel = function() UIErrorsFrame:AddMessage(blName..' was not added to Black List.', 1.0, 0.1, 0.1, 1.0) end,
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
            OnCancel = function() UIErrorsFrame:AddMessage('No one will be added to the black list.', 1.0, 0.1, 0.1, 1.0) end,
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
    blacklistIconButton:SetScript('OnEnter', function() ns.code:createTooltip('Add to Blacklist') end)
    blacklistIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    blacklistIconButton:SetShown(true)

    -- Reset Filter Icon
    local resetIconButton = CreateFrame('Button', 'GR_BASE_RESETICON', tblFrame.titleFrame)
    resetIconButton:SetSize(20, 20)
    resetIconButton:SetPoint('LEFT', blacklistIconButton, 'RIGHT', 5, 0)
    resetIconButton:SetNormalTexture(ICON_PATH..'GR_Reset')
    resetIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    resetIconButton:SetScript('OnClick', function() ns.scanner:ResetFilter() end)
    resetIconButton:SetScript('OnEnter', function() ns.code:createTooltip('Reset Filters') end)
    resetIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    resetIconButton:SetShown(false)
    tblFrame.resetButton = resetIconButton

    -- Go Back Icon
    local backIconButton = CreateFrame('Button', 'GR_BASE_BACKICON', tblFrame.titleFrame)
    backIconButton:SetSize(20, 20)
    backIconButton:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -5, 5)
    backIconButton:SetNormalTexture(ICON_PATH..'GR_Back')
    backIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    backIconButton:SetScript('OnClick', function()
        ns.screen.home:EnterHomeScreen()
    end)
    backIconButton:SetScript('OnEnter', function() ns.code:createTooltip('Go Back') end)
    backIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    backIconButton:SetShown(false)
    tblFrame.backButton = backIconButton

    -- Compact Mode Icon
    local compactIconButton = CreateFrame('Button', 'GR_BASE_COMPACTICON', tblFrame.titleFrame)
    compactIconButton:SetSize(20, 20)
    compactIconButton:SetPoint('RIGHT', backIconButton, 'LEFT', -5, 0)
    compactIconButton:SetNormalTexture(ICON_PATH..'GR_Compact')
    compactIconButton:SetHighlightTexture(BLUE_HIGHLIGHT)
    compactIconButton:SetShown(false)
    compactIconButton:SetScript('OnClick', function() ns.scanner:ChangeCompact() end)
    compactIconButton:SetScript('OnEnter', function() ns.code:createTooltip('Compact Mode') end)
    compactIconButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    compactIconButton:SetShown(false)
    tblFrame.compactButton = compactIconButton
end
template:Init()