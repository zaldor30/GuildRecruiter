local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI, aceEvent = LibStub("AceGUI-3.0"), LibStub("AceEvent-3.0")

local cText = ns.code.cText
local totalFilters = 0
local tblFound, tblLog = (tblFound or {}), {}
local global, profile = nil, nil

-- Widget Declarations
local btnSearch = aceGUI:Create('Button')
local btnInvite, btnRemove = aceGUI:Create('Button'), aceGUI:Create('Button')
local labelFound, labelLog = aceGUI:Create('Label'), aceGUI:Create('Label')
local labelProgress = aceGUI:Create("Label")
local labelPrevFilter, labelNextFilter = aceGUI:Create("Label"), aceGUI:Create("Label")
local pfScroll, whoScroll = aceGUI:Create("ScrollFrame"), aceGUI:Create("ScrollFrame")

-- Create checkboxes for potential invites -----------------
local function createFound(pName, class)
    local checkBox = aceGUI:Create('CheckBox')
    checkBox:SetLabel(cText(GRADDON.classInfo[class].color, pName))
    checkBox:SetFullWidth(true)
    checkBox:ToggleChecked(true)
    checkBox:SetCallback('OnValueChanged', function(val) tblFound[pName].checked = val end)
    pfScroll:AddChild(checkBox)
end
local function showFound()
    local c = 0
    pfScroll:ReleaseChildren()
    if not tblFound then tblFound = {}
    else
        for _,r in pairs(tblFound) do
            createFound(r.name, r.class)
            c = c + 1
        end
        labelFound:SetText('Inites Ready: '..c)
    end

    if c > 0 then
        btnInvite:SetDisabled(false)
        btnRemove:SetDisabled(false)
    else
        btnInvite:SetDisabled(true)
        btnRemove:SetDisabled(true)
    end
end

-- Create Scan Log Window --------------------------------
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

    labelLog:SetText('Players found: '..#tblLog)
    while tblLog and #tblLog > 0 do
        CreateLog(table.remove(tblLog, 1))
    end
end

-- Scanning Routines --------------------------------
local function searchWhoResultCallback(event, ...) -- When WHO_LIST_UPDATE event is returned
    tblLog = table.wipe(tblLog)

    local info = {}
    ns.Analytics:analyticsAdd('playersScanned', C_FriendList.GetNumWhoResults())
    for i=1,C_FriendList.GetNumWhoResults() do
        info = C_FriendList.GetWhoInfo(i)
        table.insert(tblLog, {name = info.fullName, class = info.filename, level = info.level, guild = info.fullGuildName or '', info.area})
        if not info.fullGuildName or info.fullGuildName == '' then
            if ns:IsPlayerAddOK(info.fullName, info.area) then
                tblFound[info.fullName] = {name = info.fullName, class = info.filename, checked = true} end
        end
    end
    ShowTblLog()
    showFound()
end
aceEvent.RegisterEvent("GuildRecruiter", "WHO_LIST_UPDATE", searchWhoResultCallback)

local function HideWhoFrame()
    if WhoFrame:IsShown() then HideUIPanel(WhoFrame) end
end
hooksecurefunc("ToggleFriendsFrame", HideWhoFrame)
HideUIPanel(WhoFrame)

-- Creating Filter ------------------------------------------------
local function startWaitTimer(timeRemain, percent)
    timeRemain = type(timeRemain) ~= 'number' and tonumber(timeRemain) or timeRemain
    if timeRemain <= 0 then
        btnSearch:SetDisabled(false)
        btnSearch:SetText('Search for Players')
        ns.scannerFrame:SetStatusText('Ready for next scan! (Filter Progress: '..percent..')')
    else
        C_Timer.After(timeRemain, function()
            btnSearch:SetText('Search for Players ('..timeRemain..')')
            startWaitTimer(timeRemain - 1, percent)
        end)
    end
end
local function NextSearch() -- Creates the next query for /who
    if not tblFilter or #tblFilter == 0 then ns.scannerFrame:SetStatusText('Waiting ...') return end

    local filter = table.remove(tblFilter, 1)
    labelPrevFilter:SetText('Current Search: '..filter)
    labelNextFilter:SetText('Next Search: '..(tblFilter[1] or '<none>'))
    C_FriendList.SendWho(filter)
    btnSearch:SetDisabled(true)

    local percent = (totalFilters - #tblFilter) / totalFilters
    startWaitTimer(global.scanTime or SCAN_WAIT_TIME, FormatPercentage(percent, 2))
    ns.scannerFrame:SetStatusText('Waiting for Blizz (Filter progress: '..FormatPercentage(percent, 2)..')')
end

-- Setup Filters for Scans
local function StartDefaultScan()
    -- Create a ranomizer for scanning
    tblFilter = table.wipe(tblFilter)
    for _,r in pairs(APC) do
        local filter = 'c-"'..r.classFile..'"'
        local min, max = (profile and profile.minLevel or 1), (profile and profile.maxLevel or MAX_CHARACTER_LEVEL)

        local level = min
        if max - min > 5 then
            while level <= max do
                if level > max then level = level-5 end
                table.insert(tblFilter, filter..' '..level..'-'..(level + 5 <= max and level + 5 or max))
                level = level + 5
            end
        else table.insert(tblFilter, filter..' '..min..'-'..max) end
    end

    totalFilters = #tblFilter
    NextSearch()
end
local function setupFilterForScan()
    if not ns.db then return end

    local filterID = profile and profile.activeFilter or 99
    if filterID == 99 then StartDefaultScan() return end

    local filter = global.filter[filterID].filter
    if not filter then ns.code.createErrorWindow('Filter Missing') return end
end
function ns:resetFilter()
    tblFilter = table.wipe(tblFilter)
    setupFilterForScan()
end

function ns:ScannerReturned(tbl)
    tblFound = tbl or {}
    showFound()
end
function ns.ScanningScreen() -- Create or show the scanning screen
    global, profile = ns.db.global, ns.db.profile
    if ns.scannerFrame then ns.scannerFrame:Show() return end

    ns.scannerFrame = aceGUI:Create('Frame')
    ns.scannerFrame:SetTitle('Guild Recruiter Scanning')
    ns.scannerFrame:SetStatusText('Waiting...')
    ns.scannerFrame:EnableResize(false)
    ns.scannerFrame:SetWidth(600)
    ns.scannerFrame:SetHeight(470)
    ns.scannerFrame:SetLayout('flow')
    ns.scannerFrame:SetCallback('OnClose', function()
        FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
    end)

    local btn = aceGUI:Create('Button')
    btn:SetText('Main Screen')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        ns:ShowMainScreen()
        ns.scannerFrame:Hide()
    end)
    ns.scannerFrame:AddChild(btn)

    btn = aceGUI:Create('Button')
    btn:SetText('Settings')
    btn:SetRelativeWidth(.5)
    btn:SetCallback('OnClick', function(_, _)
        InterfaceOptionsFrame_OpenToCategory(ADDON_OPTIONS)
        ns.scannerFrame:Hide()
    end)
    ns.scannerFrame:AddChild(btn)

    -- Inline Groups --------------------------------
    local pfGroup = aceGUI:Create('InlineGroup') -- Potential invite group
    pfGroup:SetTitle('Players Found')
    pfGroup:SetLayout("flow")
    pfGroup:SetWidth(182.5)
    ns.scannerFrame:AddChild(pfGroup)

    pfScroll:SetLayout("Flow")
    pfScroll:SetFullWidth(true)
    pfScroll:SetHeight(200)
    pfGroup:AddChild(pfScroll)

    btnInvite:SetText('Invite')
    btnInvite:SetRelativeWidth(.5)
    btnInvite:SetDisabled(true)
    btnInvite:SetCallback('OnClick', function(_, _)
        ns:InvitePlayers(tblFound)
        ns.scannerFrame:Hide()
    end)
    pfGroup:AddChild(btnInvite)

    btnRemove:SetText('Remove')
    btnRemove:SetRelativeWidth(.5)
    btnRemove:SetCallback('OnClick', function(_, _)
    end)
    pfGroup:AddChild(btnRemove)

    labelFound:SetText('Inites Ready: '..#tblFound)
    labelFound:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    labelFound:SetFullWidth(true)
    pfGroup:AddChild(labelFound)

    -- Who Logs --------------------------------
    local whoGroup = aceGUI:Create('InlineGroup')
    whoGroup:SetTitle('Who Results')
    whoGroup:SetLayout("flow")
    whoGroup:SetWidth(382.5)
    ns.scannerFrame:AddChild(whoGroup)

    whoScroll:SetLayout("Flow")
    whoScroll:SetFullWidth(true)
    whoScroll:SetHeight(225)
    whoGroup:AddChild(whoScroll)

    labelLog:SetText('Players Found: '..#tblLog)
    labelLog:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    labelLog:SetFullWidth(true)
    whoGroup:AddChild(labelLog)

    -- Footer --------------------------------
    local footerGroup = aceGUI:Create('InlineGroup')
    footerGroup:SetTitle('Note: Not all players can get invites, those will not get messages.')
    footerGroup:SetLayout("flow")
    footerGroup:SetFullWidth(true)
    footerGroup:SetHeight(150)
    ns.scannerFrame:AddChild(footerGroup)

    labelPrevFilter:SetWidth(280)
    labelPrevFilter:SetText('Filter active: <none>')
    labelPrevFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(labelPrevFilter)

    labelNextFilter:SetWidth(250)
    labelNextFilter:SetText('Filter active: <none>')
    labelNextFilter:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(labelNextFilter)

    btnSearch:SetText('Search for Players')
    btnSearch:SetFullWidth(true)
    btnSearch:SetCallback('OnClick', function(_, _)
        FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
        if #tblFilter == 0 then setupFilterForScan()
        else NextSearch() end
    end)
    footerGroup:AddChild(btnSearch)

    -- Create a label to display the progress percentage
    labelProgress:SetHeight(20)
    labelProgress:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    footerGroup:AddChild(labelProgress)
end