local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

function ns.infoScreen()
    local f = CreateFrame('Frame', 'INFO_Screen_Frame', UIParent, 'BackdropTemplate')
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
    aceMain:SetHeight(300)
    aceMain.frame:SetParent(f)
    aceMain.frame:SetPoint("TOP", f, "TOP", 0, -10)
    aceMain.frame:Show()

    local aceScroll = aceGUI:Create('ScrollFrame')
    aceScroll:SetLayout('Flow')
    aceScroll:SetFullWidth(true)
    aceScroll:SetHeight(300)
    aceMain:AddChild(aceScroll)

    local label = aceGUI:Create('Label')
    label:SetText(ns.datasets:WhatsNew())
    label:SetFont(DEFAULT_FONT, 13, 'OUTLINE')
    label:SetColor(1, 1, 1)
    label:SetFullWidth(true)
    aceScroll:AddChild(label)

    local btnReload = aceGUI:Create('Button')
    btnReload:SetText('Reload UI')
    btnReload:SetWidth(100)
    btnReload:SetCallback('OnClick', function()
        ReloadUI()
    end)
    aceMain:AddChild(btnReload)
end