-- Guild Recruiter Main Search Screen
local aceGUI = LibStub("AceGUI-3.0")

-- Main Search Screen
local f = nil
function GR_NAMESPACES:createMainSearch()
    if f then f:Show() return end
    f = aceGUI:Create('Frame')
    f:SetTitle('Guild Recruiter')
    f:SetStatusText('Guild Recruiter v:'..GR_ADDON.version)
    f:EnableResize(false)
    f:SetWidth(500)
    f:SetHeight(350)
    f:SetLayout('flow')

    local searchWidget = f.frame
    searchWidget:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        title = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    searchWidget:SetBackdropColor(0, 0, 0, 1) -- Set background color
    searchWidget:SetBackdropBorderColor(1, 1, 1, .5) -- Set border color

    _G["GuildRecruiter"] = searchWidget
    tinsert(UISpecialFrames, "GuildRecruiter")

    -- Frame Widgets
    local dropdown, editBox, label, InlineGroup = nil, nil, nil, nil

    -- Invite Type
    dropdown = aceGUI:Create('Dropdown')
    dropdown:SetLabel('Invite Format')
    dropdown:SetRelativeWidth(.5)
    dropdown:SetList({
        [1] = 'Message ONLY',
        [2] = 'Guild Invite ONLY',
        [3] = 'Guild Invite and Message',
        [4] = 'Message Only if Invitation is declined',
    })
    dropdown:SetValue(GRDB.global.inviteFormat or 1)
    dropdown:SetCallback('OnValueChanged', function(_, _, val) GRDB.global.inviteFormat = val end)
    f:AddChild(dropdown)

    -- Padding
    GR_CODE.createPadding(f, .1)

    -- Minimum Player Level
    editBox = aceGUI:Create('EditBox')
    editBox:SetLabel('Min Level')
    editBox:SetText(GRDB.global.minLevel or '1')
    editBox:SetMaxLetters(2)
    editBox:SetRelativeWidth(.11)
    editBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local maxLevel = GRDB.global.maxLevel and tonumber(GRDB.global.maxLevel) or MAX_CHARACTER_LEVEL
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val > maxLevel then error = true msg = 'You must enter a minimum level that is less than max level.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(GRDB.global.minLevel or '1')
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else GRDB.global.minLevel = val end
    end)
    f:AddChild(editBox)

    -- Padding
    GR_CODE.createPadding(f, .01)

    -- Maximum Player Level
    editBox = aceGUI:Create('EditBox')
    editBox:SetLabel('Max Level')
    editBox:SetText(GRDB.global.maxLevel or tostring(MAX_CHARACTER_LEVEL))
    editBox:SetMaxLetters(2)
    editBox:SetRelativeWidth(.12)
    editBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local minLevel = GRDB.global.minLevel and tonumber(GRDB.global.minLevel) or 1
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val <= minLevel then error = true msg = 'Your max level must be equal or larger then minimum.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(GRDB.global.maxLevel or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else GRDB.global.maxLevel = val end
    end)
    f:AddChild(editBox)

    -- Padding
    GR_CODE.createPadding(f, .01)

    -- Start Scan Button
    local btn = aceGUI:Create('Button')
    btn:SetText('Scan')
    btn:SetRelativeWidth(.15)
    btn:SetCallback('OnClick', function(_, button) print('CLICK') end)
    f:AddChild(btn)

    local filterGroup = aceGUI:Create('InlineGroup')
    filterGroup:SetTitle('Available Filters')
    filterGroup:SetFullWidth(true)
    filterGroup:SetLayout("fill")
    f:AddChild(filterGroup)

    local scroll = aceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetHeight(50)
    scroll:SetLayout('flow')
    filterGroup:AddChild(scroll)

    local statsGroup = aceGUI:Create('InlineGroup')
    statsGroup:SetTitle('Statistics')
    statsGroup:SetFullWidth(true)
    statsGroup:SetLayout("fill")
    f:AddChild(statsGroup)

    local scrollStats = aceGUI:Create("ScrollFrame")
    scrollStats:SetFullWidth(true)
    scrollStats:SetHeight(50)
    scrollStats:SetLayout('flow')
    statsGroup:AddChild(scrollStats)
end