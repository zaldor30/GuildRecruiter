-- Guild Recruiter Main Screen
local _, ns = ... -- Namespace (myaddon, namespace)
ms = {} 
local aceGUI = LibStub("AceGUI-3.0")
local global, profile = ns.db.global, ns.db.profile

-- Widgets that need to be accessed after functions
local errLabel = aceGUI:Create('Label')
local btnScan = aceGUI:Create('Button') -- Start scan button

local function GetActiveMessages()
    local isGM = IsGuildLeader()
    if (not global.inviteFormat or global.inviteFormat ~= 2) and (not global.messages or #global.messages == 0) then
        errLabel:SetText('You need create a message in options, click on settings.')
        btnScan:SetDisabled(true)
        return
    elseif global.messages and #global.messages ~= 0 then
        local tbl = {}
        for k, r in pairs(global.messages) do
            local gLinkFound = strfind(r.message, 'GUILDLINK')
            if (gLinkFound and isGM) or not gLinkFound then tbl[k] = r.desc
            elseif gLinkFound and k == profile.activeMessage then profile.activeMessage = nil end
        end
        return tbl
    end
end
local function FilterGroup_List()
    local tbl = {}
    tbl[0] = 'Default Filter'
    if global.filter then
        for x=1,#global.filter do
            tbl[x] = global.filter[x].desc
        end
    end
    return tbl
end

-- Create the main screen frame
function ns:ShowMainScreen()
    local dropdown, editBox, label = nil, nil, nil
    global, profile = ns.db.global, ns.db.profile

    -- Base Frame of the Main Screen
    if f then f:Show() return end
    f = aceGUI:Create('Frame')
    f:SetTitle('Guild Recruiter')
    f:SetStatusText('Guild Recruiter v:'..GRADDON.version)
    f:EnableResize(false)
    f:SetWidth(500)
    f:SetHeight(370)
    f:SetLayout('flow')

    -- Allows for ESC to exit
    _G["GuildRecruiter"] = f
    tinsert(UISpecialFrames, "GuildRecruiter")

    f:SetStatusText('Guild Recruiter v:'..GRADDON.version..' - Doing Maintenance')
    function ns:MaintenanceDone() f:SetStatusText('Guild Recruiter v:'..GRADDON.version) end
    ns:DoMaintenance()

    -- Setup the Inline Groups on the screen
    local grpSearch = aceGUI:Create('InlineGroup') -- Top search group
    grpSearch:SetTitle('Search Options')
    grpSearch:SetLayout("flow")
    grpSearch:SetFullWidth(true)
    grpSearch:SetHeight(250)
    f:AddChild(grpSearch)

    local grpFilter = aceGUI:Create('InlineGroup') -- Filter Group
    grpFilter:SetTitle('Available Filters')
    grpFilter:SetLayout("flow")
    grpFilter:SetWidth(215)
    f:AddChild(grpFilter)

    local spacer = aceGUI:Create('Label')
    spacer:SetText(' ')
    spacer:SetWidth(20)
    f:AddChild(spacer)

    local grpStats = aceGUI:Create('InlineGroup') -- Stats Group
    grpStats:SetTitle('Statistics')
    grpStats:SetLayout("flow")
    grpStats:SetWidth(230)
    f:AddChild(grpStats)

    -- Top Search Group Widgets ------------------------------------------------
    local msgDrop = aceGUI:Create('Dropdown') -- Select invite type
    msgDrop:SetLabel('Invite Format')
    msgDrop:SetRelativeWidth(.5)
    msgDrop:SetList({
        [1] = 'Message ONLY',
        [2] = 'Guild Invite ONLY',
        [3] = 'Guild Invite and Message',
        [4] = 'Message Only if Invitation is declined',
    })
    msgDrop:SetValue(global and global.inviteFormat or 1)
    msgDrop:SetCallback('OnValueChanged', function(_, _, val)
        if val ~= 2 and not global.messages then btnScan:SetDisabled(true)
        else btnScan:SetDisabled(false) end
        global.inviteFormat = val
    end)
    grpSearch:AddChild(msgDrop)

    ns.code.createPadding(grpSearch, .03)

    editBox = aceGUI:Create('EditBox') -- Minimum level for filter
    editBox:SetLabel('Min Level')
    editBox:SetText(profile and profile.minLevel or '1')
    editBox:SetMaxLetters(2)
    editBox:SetRelativeWidth(.13)
    editBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local maxLevel = profile.maxLevel and tonumber(profile.maxLevel) or MAX_CHARACTER_LEVEL
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val > maxLevel then error = true msg = 'You must enter a minimum level that is less than max level.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(profile.minLevel or '1')
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else profile.minLevel = val end
    end)
    grpSearch:AddChild(editBox)

    ns.code.createPadding(grpSearch, .02)

    local editBoxMax = aceGUI:Create('EditBox') -- Maximum level for filter
    editBoxMax:SetLabel('Max Level')
    editBoxMax:SetText(profile and profile.maxLevel or tostring(MAX_CHARACTER_LEVEL))
    editBoxMax:SetMaxLetters(2)
    editBoxMax:SetRelativeWidth(.13)
    editBoxMax:SetCallback('OnEnterPressed', function(widget,_, val)
        local minLevel = profile.minLevel and tonumber(profile.minLevel) or 1
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        val = tonumber(val:trim()) or nil
        if not val then error = true
        elseif val <= minLevel then error = true msg = 'Your max level must be equal or larger then minimum.'
        elseif not val or (val < 1 or val > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(profile.maxLevel or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else profile.maxLevel = val end
    end)
    grpSearch:AddChild(editBoxMax)

    ns.code.createPadding(grpSearch, .03)

    btnScan:SetText('Scan') -- Scan button
    btnScan:SetRelativeWidth(.15)
    btnScan:SetCallback('OnClick', function(_, button)
        if not profile.activeMessage and global.inviteFormat ~= 2 then
            errLabel:SetText(ns.code.cText('FFFF0000', 'You must select a valid message.'))
        else
            errLabel:SetText('')
            ns.ScanningScreen()
            f:Hide()
        end
    end)
    grpSearch:AddChild(btnScan)

    local cmb = aceGUI:Create('Dropdown') -- Dropdown of messages to send
    cmb:SetLabel('Active Message')
    cmb:SetList(GetActiveMessages())
    cmb:SetValue(profile and profile.activeMessage or nil)
    cmb:SetCallback('OnValueChanged', function(_,_, val) profile.activeMessage = val end)
    grpSearch:AddChild(cmb)

    ns.code.createPadding(grpSearch, .03)

    errLabel:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    errLabel:SetRelativeWidth(.5)
    grpSearch:AddChild(errLabel)

    -- Filter Group ------------------------------------------------
    dropdown = aceGUI:Create('Dropdown')
    dropdown:SetLabel('Filters')
    dropdown:SetRelativeWidth(1)
    dropdown:SetList(FilterGroup_List())
    dropdown:SetValue(profile and ((profile.activeFilter and profile.activeFilter == 99) and 0 or (profile.activeFilter or 0)) or 0)
    dropdown:SetFullWidth(true)
    dropdown:SetCallback('OnValueChanged', function(_, _, val) profile.activeFilter = (val == 0 and 99 or val) end)
    grpFilter:AddChild(dropdown)

    local btn = aceGUI:Create('Button') -- Start scan button
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, button)
        f:Hide()
        InterfaceOptionsFrame_OpenToCategory(ns.addonOptions)
    end)
    grpFilter:AddChild(btn)

    -- Analytics Group ------------------------------------------------
    local heading = AceGUI:Create("Label")
    heading:SetText(UnitName('player')..' Stats:')
    heading:SetFontObject(GameFontHighlightLarge)  -- Set the font style
    heading:SetColor(1, 0.82, 0)  -- Set the text color
    heading:SetFullWidth(true)
    heading:SetHeight(12)
    grpStats:AddChild(heading)
    
    label = aceGUI:Create('Label')
    label:SetText('Players Scanned: '..ns.Analytics.get('playersScanned', true))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    grpStats:AddChild(label)
    
    label = aceGUI:Create('Label')
    label:SetText('Players Invited: '..ns.Analytics.get('invitedPlayers', true))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    grpStats:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText('Players Black Listed: '..ns.Analytics.get('blackListed', true))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    grpStats:AddChild(label)

    heading = AceGUI:Create("Label")
    heading:SetText('Account Stats:')
    heading:SetFontObject(GameFontHighlightLarge)  -- Set the font style
    heading:SetColor(1, 0.82, 0)  -- Set the text color
    heading:SetFullWidth(true)
    heading:SetHeight(12)
    grpStats:AddChild(heading)

    label = aceGUI:Create('Label')
    label:SetText('Total Players Scanned: '..ns.Analytics.get('playersScanned'))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    grpStats:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText('Total Invites: '..ns.Analytics.get('invitedPlayers'))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    grpStats:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText('Total Black Listed: '..ns.Analytics.get('blackListed', true))
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetFullWidth(true)
    grpStats:AddChild(label)
end