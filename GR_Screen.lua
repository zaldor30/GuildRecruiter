-- Guild Recruiter Base Screen
local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.screen = {}
local screen = ns.screen
local function OnDragStart(self) -- Start dragging the frame
    self:StartMoving()
end
local function OnDragStop(self) -- Stop dragging the frame
    self:StopMovingOrSizing()
    screen.screenPos.point,_,_, screen.screenPos.x, screen.screenPos.y = self:GetPoint()
    ns.db.settings.screenPos = screen.screenPos
end

function screen:Init()
    self.fTop = nil
    self.fTopIcon = nil
    self.fMain = nil
    self.aMain = nil
    self.status = nil
    self.statusHold = nil

    -- Icon Bar icon values
    self.iconBack = nil
    self.iconSync = nil
    self.iconStats = nil
    self.iconReset = nil
    self.syncState = false

    self.textSync = nil
    self.activeScreen = nil

    self.tblFormat = {
        [1] = 'Message ONLY',
        [2] = 'Guild Invite ONLY',
        [3] = 'Guild Invite and Message',
        --[4] = 'Message Only if Invitation is declined',
    }

    self.screenPos = { -- Get default position and current position
        point = 'CENTER',
        x = 0,
        y = 0
    }
end
function screen:StartGuildRecruiter()
    self.activeScreen = 'MAIN'
    self.screenPos = ns.db.settings.screenPos or self.screenPos

    if self.fMain and self.fMain:IsShown() then return
    elseif self.fMain then self.fMain:Show()
    else screen:buildScreen() end

    ns.main:ScannerSettingsLayout()
end
function screen:buildScreen()
    self.fMain = CreateFrame('Frame', 'Main_Screen_Frame', UIParent, 'BackdropTemplate')
    local f = self.fMain
    f:SetBackdrop({
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0, 0, 0, .75)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:SetSize(500, 400)
    f:SetPoint(self.screenPos.point, self.screenPos.x, self.screenPos.y)
    f:SetMovable(not self.isLocked)
    f:EnableMouse(not self.isLocked)
    f:EnableKeyboard(true)
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    --f:SetScript('OnKeyDown', function(_, key) if key == 'ESCAPE' then screen:HideScreen() end end)
    f:SetScript('OnMouseDown', OnDragStart)
    f:SetScript('OnMouseUp', OnDragStop)
    f:Show()

    _G["GuildRecruiter"] = f
    tinsert(UISpecialFrames, "GuildRecruiter")

    local fTop = CreateFrame('Frame', 'TOP_Screen_Frame', f, 'BackdropTemplate')
    self.fTop = fTop
    fTop:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    fTop:SetBackdropColor(0, 0, 0, .75)
    fTop:SetBackdropBorderColor(1, 1, 1, 1)
    fTop:SetPoint('TOP', self.fMain, 'TOP', 0, -5)
    fTop:SetSize(self.fMain:GetWidth() - 8, 18)

    local textString = fTop:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString:SetPoint("LEFT", fTop, "LEFT", 20, 0) -- Set the text position
    textString:SetText(GRADDON.title)
    textString:SetTextColor(1, 1, 1, 1) -- Set the text color (r,g,b,a) values
    textString:SetFont(DEFAULT_FONT, 16, 'OUTLINE')

    local lineTexture = fTop:CreateTexture(nil, "ARTWORK")
    lineTexture:SetColorTexture(.25, .25, .25)
    lineTexture:SetHeight(1)
    lineTexture:SetPoint("BOTTOMLEFT", fTop, "BOTTOMLEFT", 0, 0)
    lineTexture:SetPoint("BOTTOMRIGHT", fTop, "BOTTOMRIGHT", 0, 0)

    local function createTopBarIcons(aFrame, image, title, body, pointB, xOffset, yOffset, pointA, width, height)
        local fIcon = CreateFrame('Button', nil, fTop, 'BackdropTemplate')
        fIcon:SetSize(width or 20, height or 20)
        fIcon:SetPoint(pointA or 'LEFT', aFrame, pointB or 'LEFT', xOffset or 0, yOffset or 0)

        fIcon:SetNormalTexture(image or '')
        fIcon:SetHighlightTexture(image or '')

        fIcon:SetScript('OnEnter', function() ns.widgets:createTooltip(title, body) end)
        fIcon:SetScript('OnLeave', function() GameTooltip:Hide() end)

        return fIcon
    end

    local fTop_Icon = CreateFrame('Frame', 'TOP_Screen_Frame', f, 'BackdropTemplate')
    fTop_Icon:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    fTop_Icon:SetBackdropColor(0, 0, 0, .5)
    fTop_Icon:SetBackdropBorderColor(1, 1, 1, 1)
    fTop_Icon:SetPoint('TOP', fTop, 'BOTTOM', 0, 0)
    fTop_Icon:SetSize(self.fMain:GetWidth() - 8, 20)
    self.fTop_Icon = fTop_Icon

    local prevFrame = createTopBarIcons(fTop, GRADDON.icon, 'About '..GRADDON.title, 'Shows information about this addon.', nil, 3, 1, nil, 15, 15)
    prevFrame = createTopBarIcons(fTop, ICON_PATH..'GR_Exit', 'Exit '..GRADDON.title, 'Closes the addon.', 'RIGHT', -3, 1, 'RIGHT', 15, 15)
    prevFrame:SetScript('OnMouseUp', function() screen:HideScreen() end)

    prevFrame = createTopBarIcons(fTop_Icon, ICON_PATH..'GR_Settings', 'Settings', 'Opens the addon settings.', 'LEFT', 3, 0)
    prevFrame:SetScript('OnMouseUp', function()
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
        ns.screen.fMain:Hide()
    end)
    self.iconSync = createTopBarIcons(prevFrame, ICON_PATH..'GR_Sync', 'Perform Sync', 'Performs a synchronization of data between officers.', 'RIGHT', 3, 0)
    self.iconSync:SetScript('OnClick', function() ns.Sync:StartSyncMaster() end)
    self.iconStats = createTopBarIcons(self.iconSync, ICON_PATH..'GR_Stats', 'Analytics', 'Show different analytics on invited, joined and more.', 'RIGHT', 3, 0)
    self.iconReset = createTopBarIcons(self.iconStats, ICON_PATH..'GR_Reset', 'Filter Reset', 'Restart the current filter.', 'RIGHT', 3, 0)
    self.iconReset:SetScript('OnClick', function() ns.scanner:SetupFilter() end)

    self.iconBack = createTopBarIcons(fTop_Icon, ICON_PATH..'GR_Back', 'Back', 'Returns to the main screen.', 'RIGHT', -3, 0, 'RIGHT')

    local fBottom = CreateFrame('Frame', 'BOTTOM_Screen_Frame', f, 'BackdropTemplate')
    fBottom:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    fBottom:SetBackdropColor(0, 0, 0, .5)
    fBottom:SetBackdropBorderColor(1, 1, 1, 1)
    fBottom:SetPoint('BOTTOM', f, 'BOTTOM', 0, 5)
    fBottom:SetSize(f:GetWidth() - 8, 15)

    lineTexture = fBottom:CreateTexture(nil, "ARTWORK")
    lineTexture:SetColorTexture(.25, .25, .25)
    lineTexture:SetHeight(1)
    lineTexture:SetPoint("TOPLEFT", fBottom, "TOPLEFT", 0, 0)
    lineTexture:SetPoint("TOPRIGHT", fBottom, "TOPRIGHT", 0, 0)

    self.status = fBottom:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString = self.status
    textString:SetPoint("LEFT", fBottom, "LEFT", 2, -1) -- Set the text position
    textString:SetText('')
    textString:SetTextColor(1, 1, 1, 1) -- Set the text color (r,g,b,a) values

    textString = fBottom:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString:SetPoint("RIGHT", fBottom, "RIGHT", -2, -1) -- Set the text position
    textString:SetTextColor(1, 1, 1, 1) -- Set the text color (r,g,b,a) values
    self.textSync = textString

    screen:UpdateLastSync()
end
function screen:HideScreen()
    -- Do closing routines for active screens
    if self.activeScreen == 'MAIN' then
        -- Do closing routines for main screen
    end

    if self.fMain then self.fMain:Hide() end
end
function screen:ResetMain()
    if ns.main.fPreview then ns.main.fPreview:Hide() end
    ns.main.inLine = nil

    if self.aMain then
        self.aMain.frame:Hide()
        self.aMain:SetParent(UIParent)
        self.aMain = nil
    end

    local aMain = aceGUI:Create('SimpleGroup')
    aMain:SetWidth(self.fMain:GetWidth() - 10)
    aMain:SetLayout('Flow')
    aMain.frame:SetParent(self.fMain)
    aMain.frame:SetPoint("TOP", self.fTop_Icon, "BOTTOM", 1, 15)
    self.aMain = aMain
    self.aMain:SetUserData("hidden", false)
    aMain.frame:Show()
end

-- Sync routines
function screen:UpdateStatus(state)
    if self.syncState == state then return end

    self.syncState = state
    if state then
        self.iconSync:SetNormalTexture(ICON_PATH..'GR_Sync_Active')
        self.iconSync:SetHighlightTexture(ICON_PATH..'GR_Sync_Active')
        self.statusHold = self.status:GetText() or ''
        self.status:SetText('Performing Sync...')
    else
        self.iconSync:SetNormalTexture(ICON_PATH..'GR_Sync')
        self.iconSync:SetHighlightTexture(ICON_PATH..'GR_Sync')
        screen:UpdateLastSync()
        print(self.statusHold or 'no status')
        self.status:SetText(self.statusHold)
    end
end
function screen:UpdateLastSync()
    self.textSync:SetText('Last Sync: '..(ns.db.settings.lastSync or '<none>'))
end
screen:Init()