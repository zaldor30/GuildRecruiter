-- Guild Recruiter Main Screen
local aceGUI = LibStub("AceGUI-3.0")

local f = nil
local errLabel = aceGUI:Create('Label')
local p,g = nil, nil

local function GetActiveMessages()
    local isGM = IsGuildLeader()
    if not g.messages then return end
    local tbl = {}
    for k, r in pairs(g.messages) do
        local gLinkFound = strfind(r.message, 'GUILDLINK')
        if (gLinkFound and isGM) or not gLinkFound then tbl[k] = r.desc
        elseif gLinkFound and k == p.activeMessage then p.activeMessage = nil end
    end
    return tbl
end
local function MainScreen_Primary()
    p,g = GRADDON.db.profile, GRADDON.db.global
    local dropdown, editBox = nil, nil

    local primary = aceGUI:Create('InlineGroup')
    primary:SetTitle('Search Options')
    primary:SetLayout("flow")
    primary:SetFullWidth(true)
    primary:SetHeight(250)
    f:AddChild(primary)

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
    dropdown:SetValue(g.inviteFormat or 1)
    dropdown:SetCallback('OnValueChanged', function(_, _, val) g.inviteFormat = val end)
    primary:AddChild(dropdown)

    GRCODE.createPadding(primary, .03)

    -- Minimum Player Level
    editBox = aceGUI:Create('EditBox')
    editBox:SetLabel('Min Level')
    editBox:SetText(p.minLevel or '1')
    editBox:SetMaxLetters(2)
    editBox:SetRelativeWidth(.13)
    editBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local maxLevel = p.maxLevel and tonumber(p.maxLevel) or MAX_CHARACTER_LEVEL
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val > maxLevel then error = true msg = 'You must enter a minimum level that is less than max level.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(p.minLevel or '1')
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else p.minLevel = val end
    end)
    primary:AddChild(editBox)

    -- Padding
    GRCODE.createPadding(primary, .02)

    -- Maximum Player Level
    local editBoxMax = aceGUI:Create('EditBox')
    editBoxMax:SetLabel('Max Level')
    editBoxMax:SetText(p.maxLevel or tostring(MAX_CHARACTER_LEVEL))
    editBoxMax:SetMaxLetters(2)
    editBoxMax:SetRelativeWidth(.13)
    editBoxMax:SetCallback('OnEnterPressed', function(widget,_, val)
        local minLevel = p.minLevel and tonumber(p.minLevel) or 1
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val <= minLevel then error = true msg = 'Your max level must be equal or larger then minimum.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(p.maxLevel or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else p.maxLevel = val end
    end)
    primary:AddChild(editBoxMax)

    -- Padding
    GRCODE.createPadding(primary, .03)

    -- Start Scan Button
    local btn = aceGUI:Create('Button')
    btn:SetText('Scan')
    btn:SetRelativeWidth(.15)
    btn:SetCallback('OnClick', function(_, button)
        if not p.activeMessage then
            errLabel:SetText(GRCODE.cText('FFFF0000', 'You must select a valid message.'))
        else
            errLabel:SetText('')
            NS.ScanningScreen()
            f:Hide()
        end
    end)
    primary:AddChild(btn)

    -- Message Selection
    local cmb = aceGUI:Create('Dropdown')
    cmb:SetLabel('Active Message')
    cmb:SetList(GetActiveMessages())
    cmb:SetValue(p.activeMessage)
    cmb:SetCallback('OnValueChanged', function(_,_, val) p.activeMessage = val end)
    primary:AddChild(cmb)

    GRCODE.createPadding(primary, .03)

    errLabel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    errLabel:SetRelativeWidth(.5)
    primary:AddChild(errLabel)
end

local function FilterGroup_List()
    local tbl = {}
    tbl[0] = 'Default Filter'
    if GRADDON.db.global.filter then
        for x=1,#GRADDON.db.global.filter do
            tbl[x] = GRADDON.db.global.filter[x].desc
        end
    end
    return tbl
end

function NS.MainScreen()
    p,g = GRADDON.db.profile, GRADDON.db.global
    if f then f:Show() return end

    f = aceGUI:Create('Frame')
    f:SetTitle('Guild Recruiter')
    f:SetStatusText('Guild Recruiter v:'..GRADDON.version)
    f:EnableResize(false)
    f:SetWidth(500)
    f:SetHeight(350)
    f:SetLayout('flow')

    -- Allows for ESC to exit
    _G["GuildRecruiter"] = f
    tinsert(UISpecialFrames, "GuildRecruiter")

    MainScreen_Primary()
    local filterGroup = aceGUI:Create('InlineGroup')
    filterGroup:SetTitle('Available Filters')
    filterGroup:SetLayout("flow")
    filterGroup:SetWidth(215)
    f:AddChild(filterGroup)

    local dropdown = aceGUI:Create('Dropdown')
    dropdown:SetLabel('Filters')
    dropdown:SetRelativeWidth(.5)
    dropdown:SetList(FilterGroup_List())
    dropdown:SetValue((p.activeFilter and p.activeFilter == 99) and 0 or (p.activeFilter or 0))
    dropdown:SetFullWidth(true)
    dropdown:SetCallback('OnValueChanged', function(_, _, val) p.activeFilter = (val == 0 and 99 or val) end)
    filterGroup:AddChild(dropdown)

    local spacer = aceGUI:Create('Label')
    spacer:SetText(' ')
    spacer:SetWidth(20)
    f:AddChild(spacer)

    local statsGroup = aceGUI:Create('InlineGroup')
    statsGroup:SetTitle('Statistics')
    statsGroup:SetLayout("flow")
    statsGroup:SetWidth(230)
    f:AddChild(statsGroup)

    local label = aceGUI:Create('Label')
    label:SetText(UnitName('player')..' Scanned: '..(p.playersScanned or 0))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    statsGroup:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText('Total Players Scanned (Account): '..(g.playersScanned or 0))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    statsGroup:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText(UnitName('player')..' Invited: '..(p.invitedPlayers or 0))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    statsGroup:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText('Total Invites (Account): '..(g.invitedPlayers or 0))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    statsGroup:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText(UnitName('player')..' Black Listed: '..(p.blackListed or 0))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    statsGroup:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText('Total Black Listed (Account): '..(g.blackListed or 0))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    statsGroup:AddChild(label)
end