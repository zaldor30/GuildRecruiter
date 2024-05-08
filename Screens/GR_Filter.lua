local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local aceGUI = LibStub("AceGUI-3.0")

ns.screens.filter = {}
local filter = ns.screens.filter

local function obsCloseScreens()
    ns.observer:Unregister('CLOSE_SCREENS', obsCloseScreens)
    if not filter.tblFrame.frame then return end

    filter.tblFrame.frame:SetShown(false)
    filter.tblFrame.inline.frame:SetShown(false)
    filter.tblFrame.inline:ReleaseChildren()

    ns.screens.base.tblFrame.statusText:SetText('')
end
function filter:Init()
    self.tblFrame = {}
    self.tblFilter = {}
    self.nameOk = false

    self.tblRaceByFileName = {}
    self.tblClassByFileName = {}
end
function filter.FilterData()
    local tblFunc = {}

    -- Filter data
    function tblFunc:getFilterList()
        local tbl = {}
        local nsFilter = ns.dbGlobal.filter and ns.dbGlobal.filter or {}

        for k, v in pairs(nsFilter) do tbl[k] = v.name end

        return tbl
    end
    function tblFunc:newFilter(recID, name, whoCommand, race, class)
        local tblRacesByName, tblClassesByName = {}, {}

        for _,r in pairs(ns.tblRacesByName) do -- Build Fresh Race Table
            tblRacesByName[r.name] = {
                fileName = r.raceFile,
                regionName = r.name,
                isChecked = true,
            }
        end
        for _,r in pairs(ns.tblClassesByName) do -- Build Fresh Class Table
            tblClassesByName[r.name] = {
                color = r.color,
                fileName = r.classFile,
                regionName = r.name,
                isChecked = true,
            }
        end

        local tbl = {
            recordID = recID or nil,
            name = name or nil,
            whoCommand = whoCommand or nil,
            RACE = race or tblRacesByName,
            CLASS = class or tblClassesByName,
        }
        tbl.RACE.allChecked = true
        tbl.CLASS.allChecked = true

        return tbl
    end
    function tblFunc:saveFilter(name, whoCommand, race, class)
        return {
            name = name or filter.tblFilter.name,
            whoCommand = whoCommand or filter.tblFilter.whoCommand,
            RACE = race or filter.tblFilter.RACE,
            CLASS = class or filter.tblFilter.CLASS,
        }
    end
    function tblFunc:saveFilterData()
        local tblBase = ns.screens.base.tblFrame
        local nsFilter = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}

        -- Setup Filter Data for Saving
        if nsFilter[filter.tblFilter.recordID] then nsFilter[filter.tblFilter.recordID] = nil end

        nsFilter[filter.tblFilter.name] = {
            name = filter.tblFilter.name,
            whoCommand = filter.tblFilter.whoCommand,
            RACE = filter.tblFilter.RACE,
            CLASS = filter.tblFilter.CLASS,
        }


        filter.tblFilter.recordID = filter.tblFilter.name
        tblBase.statusText:SetText(L['Filter Saved']..' '..filter.tblFilter.name)

        filter.tblFrame.inline.filterCombo:SetList(filter.filterData:fGetList())
        filter.tblFrame.inline.filterCombo:SetValue(filter.tblFilter.name)

        C_Timer.After(5, function()
            ns.screens.base.tblFrame.statusText:SetText('')
        end)
    end
    -- Filter Race/Class data

    return tblFunc
end

function filter:StartUp()
    local tblBase = ns.screens.base.tblFrame

    -- Setup for Close Routines
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCloseScreens)

    -- Set Base Frame
    tblBase.backButton:SetShown(true)
    tblBase.frame:SetSize(500, 580)
    tblBase.frame:SetShown(true)

    filter.tblFilter = filter.fData:newFilter()

    -- Create UI
    self.cUI:BaseUI()
    self.cUI:BuildFilterTopUI()
    self.cUI:BuildCheckBoxListUI()
end

-- Create UI
function filter:CreateUI()
    local tblFunc = {}

    local function resetCustomFilter()
    end
    local function checkControls()
    end
    local function createCheckBoxes(scrollFrame, tbl) -- tblFilter[listType]
        tbl.allChecked = nil
        local tblOut = ns.code:sortTableByField(tbl, 'regionName')

        -- Class Checkboxes
        for k in pairs(tblOut) do
            local v = tblOut[k]
            local checkbox = aceGUI:Create('CheckBox')
            local fName = v.color and ns.code:cText(v.color, v.regionName) or v.regionName

            checkbox:SetLabel(fName)
            checkbox:SetValue(v.isChecked)
            checkbox:SetCallback('OnValueChanged', function(_, _, val)
                v.isChecked = val

                local allChecked = true
                if not v.isChecked then tbl.allChecked = false
                else
                    for _, r in pairs(tblOut) do
                        if not r.isChecked then allChecked = false break end
                    end
                    tbl.allChecked = allChecked
                end
            end)
            scrollFrame:AddChild(checkbox)
        end
    end

    -- Base UI
    function tblFunc:BaseUI()
        local tblBase, tblFrame = ns.screens.base.tblFrame, filter.tblFrame

        local f = tblFrame.frame or CreateFrame('Frame', nil, tblBase.frame)
        f:SetFrameStrata(DEFAULT_STRATA)
        f:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 15)
        f:SetPoint('BOTTOMRIGHT', tblBase.statusBar, 'TOPRIGHT', 0, -5)
        f:SetShown(true)
        tblFrame.frame = f

        local inline = tblFrame.inline or aceGUI:Create('InlineGroup')
        inline:SetLayout('Flow')
        inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, 0)
        inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
        inline.frame:SetShown(true)
        tblFrame.inline = inline
    end

    -- Build Filter Top UI
    function tblFunc:BuildFilterTopUI()
        local tblFrame = filter.tblFrame

        local inline = aceGUI:Create('InlineGroup')
        inline:SetLayout('Flow')
        inline:SetFullWidth(true)
        tblFrame.inline:AddChild(inline)

        -- Select Filter Combobox
        local combobox = aceGUI:Create('Dropdown')
        combobox:SetLabel(L['Custom Filters']..' (Still under development):')
        combobox:SetRelativeWidth(.5)
        combobox:SetList(filter.fData:getFilterList())
        combobox:SetCallback('OnValueChanged', function(_, _, val)
            local nsTblFilter = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}

            for _, v in pairs(nsTblFilter) do
                if v.name == val then
                    filter.tblFilter = filter.fData:newFilter(val, v.name, v.whoCommand, v.RACE, v.CLASS)
                    -- Check race/class checkboxes
                    break
                end
            end
        end)
        inline:AddChild(combobox)
        tblFrame.inline.filterCombo = combobox

        -- New Button
        local btnNew = aceGUI:Create('Button')
        btnNew:SetText(L['New'])
        btnNew:SetRelativeWidth(.25)
        btnNew:SetCallback('OnClick', function() resetCustomFilter() end)
        inline:AddChild(btnNew)
        tblFrame.inline.btnNew = btnNew

        -- Delete Button
        local btnDelete = aceGUI:Create('Button')
        btnDelete:SetText(L['Delete'])
        btnDelete:SetRelativeWidth(.25)
        btnDelete:SetCallback('OnClick', function()
            if not filter.tblFilter.recordID then return end

            local nsFilter = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}
            nsFilter[filter.tblFilter.recordID] = nil

            filter.tblFrame.inline.filterCombo:SetList(filter.filterData:fGetList())

            resetCustomFilter()
        end)
        inline:AddChild(btnDelete)
        tblFrame.inline.btnDelete = btnDelete

        -- Filter Name
        local editbox = aceGUI:Create('EditBox')
        editbox:SetLabel(L['Filter Name']..':')
        editbox:SetRelativeWidth(.7)
        editbox:SetCallback('OnEnterPressed', function(_,_, text)
            local name = strlower(text)
            local tblBase = ns.screens.base.tblFrame
            local nsFilter = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}

            tblBase.statusText:SetText('')
            for _, r in pairs(nsFilter) do
                if strlower(filter.tblFilter.recordID) == name then break
                elseif strlower(r.name) == name then
                    filter.nameOk = false
                    tblBase.statusText:SetText(L['Filter Name Already Exists'])
                    checkControls()
                    editbox:SetFocus() -- Set focus back to the editbox
                    return
                end
            end

            filter.nameOk = true
            filter.fData:saveFilter(name)
            checkControls()
        end)
        inline:AddChild(editbox)
        tblFrame.inline.filterName = editbox

        -- Save Button
        local btnSave = aceGUI:Create('Button')
        btnSave:SetText(L['Save'])
        btnSave:SetRelativeWidth(.3)
        btnSave:SetCallback('OnClick', function() filter.fData:saveFilterData() end)
        inline:AddChild(btnSave)
        tblFrame.inline.btnSave = btnSave

        -- Who Command Editor
        local whoEditbox = aceGUI:Create('EditBox')
        whoEditbox:SetLabel(L['Who Command'])
        whoEditbox:SetFullWidth(true)
        whoEditbox:SetCallback('OnEnterPressed', function(_, _, text)
            filter.fData:saveFilter(nil, text)
        end)
        inline:AddChild(whoEditbox)
        tblFrame.inline.whoEditbox = whoEditbox

        checkControls()
    end

    -- Build Race/Class Checkboxes UI
    function tblFunc:BuildCheckBoxListUI() -- First so it is on the left
        local tblFrame = filter.tblFrame
        local scrollBoxHeight = 200

        local inline = aceGUI:Create('InlineGroup')
        inline:SetLayout('Flow')
        inline:SetFullWidth(true)
        inline:SetHeight(scrollBoxHeight)
        tblFrame.inline:AddChild(inline)
        tblFrame.inline.classInline = inline

        -- Class Header
        local header = aceGUI:Create('Heading')
        header:SetText(L['Classes'])
        header:SetRelativeWidth(.5)
        tblFrame.inline.classInline:AddChild(header)

        -- Race Header
        header = aceGUI:Create('Heading')
        header:SetText(L['Races'])
        header:SetRelativeWidth(.5)
        filter.tblFrame.inline.classInline:AddChild(header)

        -- Class Select/Deselect All
        local checkBox = aceGUI:Create('CheckBox')
        checkBox:SetLabel(ns.code:cText('FFFFFF00', 'Select/Deselect All Classes'))
        checkBox:SetValue(true)
        checkBox:SetRelativeWidth(.5)
        checkBox:SetCallback('OnValueChanged', function(_, _, isChecked)
        end)
        filter.tblFrame.inline.classInline:AddChild(checkBox)
        tblFrame.inline.classCheckBoxAll = checkBox

        -- Race Select/Deselect All
        checkBox = aceGUI:Create('CheckBox')
        checkBox:SetLabel(ns.code:cText('FFFFFF00', 'Select/Deselect All Races'))
        checkBox:SetValue(true)
        checkBox:SetRelativeWidth(.5)
        checkBox:SetCallback('OnValueChanged', function(_, _, isChecked)
        end)
        filter.tblFrame.inline.classInline:AddChild(checkBox)
        tblFrame.inline.raceCheckBoxAll = checkBox

        -- Class Scroll Frame
        local scrollFrame = aceGUI:Create('ScrollFrame')
        scrollFrame:SetLayout('Flow')
        scrollFrame:SetRelativeWidth(.5)
        scrollFrame:SetHeight(scrollBoxHeight)
        inline:AddChild(scrollFrame)

        createCheckBoxes(scrollFrame, filter.tblFilter.CLASS)

        -- Race Scroll Frame
        scrollFrame = aceGUI:Create('ScrollFrame')
        scrollFrame:SetLayout('Flow')
        scrollFrame:SetRelativeWidth(.5)
        scrollFrame:SetHeight(scrollBoxHeight)
        filter.tblFrame.inline.classInline:AddChild(scrollFrame)

        createCheckBoxes(scrollFrame, filter.tblFilter.RACE)
    end

    return tblFunc
end
filter:Init()

filter.cUI = filter:CreateUI()
filter.fData = filter:FilterData()