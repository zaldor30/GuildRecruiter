-- Gruild Recruiter Scanning Screen
local aceGUI = LibStub("AceGUI-3.0")
local aceEvent = LibStub("AceEvent-3.0")

local f, btnSearch = nil, aceGUI:Create('Button')
local p,g = nil, nil
local code, cText = GRCODE, GRCODE.cText

local totalFilters = 0
local tblFound, tblLog = {}, {}
local pfScroll, whoScroll = aceGUI:Create("ScrollFrame"), aceGUI:Create("ScrollFrame")

-- Canidates Window
local function createFound(pName, class)
    local checkBox = aceGUI:Create('CheckBox')
    checkBox:SetLabel(cText(GRADDON.classInfo[class].color, pName))
    checkBox:SetFullWidth(true)
    checkBox:ToggleChecked(true)
    checkBox:SetCallback('OnValueChanged', function(val) tblFound[pName].checked = val end)
    pfScroll:AddChild(checkBox)
end
local function showFound()
    pfScroll:ReleaseChildren()
    for _,r in pairs(tblFound) do createFound(r.name, r.class) end
end
local function checkFoundPlayers(name, class)
    tblFound[name] = {name = name, class = class, checked = true}
end

-- Log Window
local function CreateLog(tbl)
    local class, pName, level, guild = tbl.class, tbl.name, tbl.level, tbl.guild

    local label = aceGUI:Create('Label')
    label:SetText(cText(GRADDON.classInfo[class].color, pName))
    label:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    label:SetWidth(100)
    whoScroll:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText(level)
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetWidth(20)
    whoScroll:AddChild(label)

    label = aceGUI:Create('Label')
    label:SetText(guild)
    label:SetFont(DEFAULT_FONT, 11, 'OUTLINE')
    label:SetWidth(200)
    whoScroll:AddChild(label)
end
local function ShowTblLog()
    whoScroll:ReleaseChildren()
    while tblLog and #tblLog > 0 do CreateLog(table.remove(tblLog, 1)) end
end

-- Scanning Routines
local function searchWhoResultCallback(event, ...)
    tblLog = table.wipe(tblLog)
    for i=1,C_FriendList.GetNumWhoResults() do
        local info = C_FriendList.GetWhoInfo(i)
        if not info.fullGuildName or info.fullGuildName == '' then checkFoundPlayers(info.fullName, info.filename) end
        table.insert(tblLog, {name = info.fullName, class = info.filename, level = info.level, guild = info.fullGuildName or ''})
    end
    ShowTblLog()
    showFound()
end

local labelProgress = aceGUI:Create("Label")
aceEvent.RegisterEvent("GuildRecruiter", "WHO_LIST_UPDATE", searchWhoResultCallback)
local tblFilter = {}
local function NextSearch()
    local filter = table.remove(tblFilter, 1)
    C_FriendList.SendWho(filter)
    if #tblFilter > 0 then
        btnSearch:SetDisabled(true)
        local used = totalFilters - #tblFilter
        local percent = (used / totalFilters) * 100
        f:SetStatusText("Waiting for Blizz (Filter progress: " .. math.floor(percent) .. "%)")
        C_Timer.After(SCAN_WAIT_TIME, function()
            f:SetStatusText("Ready for next scan! (Filter Progress: " .. math.floor(percent) .. "%)")
            btnSearch:SetDisabled(false)
        end)
    else f:SetStatusText("Waiting ...") end
end
local function StartDefaultScan()
    -- Create a ranomizer for scanning
    tblFilter = table.wipe(tblFilter)
    for _,r in pairs(APC) do
        local min, max = (p.minLevel or 1), (p.maxLevel or MAX_CHARACTER_LEVEL)
        local filter = 'c-"'..r.classFile..'"'
        if max - min > 5 then
            local i, level = min, min
            while i <= max or i-5 <= max do
                level = i
                if i > max then level = i-5 end
                table.insert(tblFilter, filter..' '..level..'-'..(level + 5 <= max and level + 5 or max))
                i = i + 5
            end
        else table.insert(tblFilter, filter..' '..min..'-'..max) end
    end

    totalFilters = #tblFilter
    NextSearch()
end
local function startScanning()
    if not GRADDON.db then return end
    p,g = GRADDON.db.profile, GRADDON.db.global

    local filterID = p.activeFilter or 99
    if filterID == 99 then StartDefaultScan() return end

    local filter = g.filter[filterID].filter
    if not filter then GRCODE.createErrorWindow('Filter Missing') return end
end

local function PlayersFound()
    local pfGroup = aceGUI:Create('InlineGroup')
    pfGroup:SetTitle('Players Found')
    pfGroup:SetLayout("flow")
    pfGroup:SetWidth(182.5)
    f:AddChild(pfGroup)

    pfScroll:SetLayout("Flow")
    pfScroll:SetFullWidth(true)
    pfScroll:SetHeight(200)
    pfGroup:AddChild(pfScroll)

    local btn = aceGUI:Create('Button')
    btn:SetText('Invite')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        NS.MainScreen()
        f:Hide()
    end)
    pfGroup:AddChild(btn)

    btn = aceGUI:Create('Button')
    btn:SetText('Remove')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        NS.MainScreen()
        f:Hide()
    end)
    pfGroup:AddChild(btn)
end
local function WhoReport()
    local whoGroup = aceGUI:Create('InlineGroup')
    whoGroup:SetTitle('Who Results')
    whoGroup:SetLayout("flow")
    whoGroup:SetWidth(382.5)
    f:AddChild(whoGroup)

    whoScroll:SetLayout("Flow")
    whoScroll:SetFullWidth(true)
    whoScroll:SetHeight(225)
    whoGroup:AddChild(whoScroll)
end
local function Footer()
    local footerGroup = aceGUI:Create('InlineGroup')
    footerGroup:SetLayout("flow")
    footerGroup:SetFullWidth(true)
    footerGroup:SetHeight(150)
    f:AddChild(footerGroup)

    btnSearch:SetText('Search for Players')
    btnSearch:SetFullWidth(true)
    btnSearch:SetCallback('OnClick', function(_, _)
        FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
        if #tblFilter == 0 then startScanning()
        else NextSearch() end
    end)
    footerGroup:AddChild(btnSearch)

    -- Create a label to display the progress percentage
    labelProgress:SetHeight(20)
    labelProgress:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(labelProgress)
end
function NS.ScanningScreen()
    p,g = GRADDON.db.profile, GRADDON.db.global
    code, cText = GRCODE, GRCODE.cText

    if f then f:Show() return end

    f = aceGUI:Create('Frame')
    f:SetTitle('Guild Recruiter Scanning')
    f:SetStatusText('Waiting...')
    f:EnableResize(false)
    f:SetWidth(600)
    f:SetHeight(450)
    f:SetLayout('flow')

    local btn = aceGUI:Create('Button')
    btn:SetText('Main Screen')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        NS.MainScreen()
        f:Hide()
    end)
    f:AddChild(btn)

    btn = aceGUI:Create('Button')
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        InterfaceOptionsFrame_OpenToCategory(ADDON_OPTIONS)
        f:Hide()
    end)
    f:AddChild(btn)

    PlayersFound()
    WhoReport()
    Footer()
end