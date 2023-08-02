local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.info = {}
ns.info.frame = nil
ns.info.inline = nil
function ns.infoScreen(forceDBUpdate)
    if not ns.info.frame then
        ns.info.frame = CreateFrame('Frame', 'INFO_Screen_Frame', UIParent, 'BackdropTemplate')
    else
        if ns.info.inline then
            ns.info.inline.frame:Hide()
            ns.info.inline.frame:SetParent(UIParent)
            ns.info.inline = nil
        end
        ns.info.frame:Hide()
    end
    local f = ns.info.frame
    f:SetBackdrop(DEFAULT_FRAME_TEMPLATE)
    f:SetBackdropColor(0, 0, 0, .75)
    f:SetBackdropBorderColor(1, 1, 1, 1)
    f:SetSize(500, 395)
    f:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    f:EnableKeyboard(true)
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:Show()

    local fTop = CreateFrame('Frame', 'TOP_Screen_Frame', f, 'BackdropTemplate')
    fTop:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    fTop:SetBackdropColor(0, 0, 0, .75)
    fTop:SetBackdropBorderColor(1, 1, 1, 1)
    fTop:SetPoint('TOP', f, 'TOP', 0, -5)
    fTop:SetSize(f:GetWidth() - 8, 18)

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

    local function createTopBarIcons(aFrame, image, pointB, xOffset, yOffset, pointA, width, height)
        local fIcon = CreateFrame('Button', nil, fTop, 'BackdropTemplate')
        fIcon:SetSize(width or 20, height or 20)
        fIcon:SetPoint(pointA or 'LEFT', aFrame, pointB or 'LEFT', xOffset or 0, yOffset or 0)

        fIcon:SetNormalTexture(image or '')
        fIcon:SetHighlightTexture(image or '')

        return fIcon
    end
    local prevFrame = createTopBarIcons(fTop, GRADDON.icon, nil, 3, 1, nil, 15, 15)

    local aceMain = aceGUI:Create('InlineGroup')
    aceMain:SetLayout('Flow')
    aceMain:SetWidth(f:GetWidth() - 20)
    aceMain.frame:SetParent(f)
    aceMain.frame:SetPoint("TOP", f, "TOP", 0, -10)
    ns.info.inline = aceMain
    ns.info.inline:SetUserData("hidden", false)
    aceMain.frame:Show()

    local aceScroll = aceGUI:Create('ScrollFrame')
    aceScroll:SetLayout('Flow')
    aceScroll:SetFullWidth(true)
    aceMain:AddChild(aceScroll)

    local label = aceGUI:Create('Label')
    label:SetText('')
    label:SetFont(DEFAULT_FONT, 13, 'OUTLINE')
    label:SetColor(1, 1, 1)
    label:SetFullWidth(true)
    aceScroll:AddChild(label)

    local button = aceGUI:Create('Button')
    button:SetWidth(100)
    aceMain:AddChild(button)

    local height = 275
    if forceDBUpdate or ns.db.settings.dbVer == ns.core.addonSettings.profile.settings.dbVer then
        height = forceDBUpdate and height or 225
        label:SetText(forceDBUpdate and ns.datasets:WhatsNew() or ns.datasets:LatestUpdates())
        button:SetText('Ok')
        button:SetCallback('OnClick', function()
            f:Hide()
        end)
    else
        label:SetText(ns.datasets:WhatsNew())
        button:SetText('Reload UI')
        button:SetCallback('OnClick', function()
            ReloadUI()
        end)
    end

    f:SetHeight(height + 85)
    f:Show()
    aceMain:SetHeight(height)
    aceScroll:SetHeight(height)
end