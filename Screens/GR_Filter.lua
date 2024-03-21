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
    self.activeRecord = nil

    self.tblRaceByFileName = {}
    self.tblClassByFileName = {}
end
function filter:FilterTable()
    local tblFunc = {}

    -- Class/Race Table
    function tblFunc:rNew(fileName, regionName, isChecked, id)
        return {
            id = id or nil,
            fileName = fileName,
            regionName = regionName,
            isChecked = isChecked,
        }
    end
    function tblFunc:rSave(listType, id, isChecked, fileName, regionName)
        local tblFilter = filter.tblFilter
        if not tblFilter then return end

        local tbl = listType == 'CLASS' and tblFilter.CLASS or tblFilter.RACE

        if not tbl[id] then tbl[id] = filter.filterData:rNew(fileName, regionName, isChecked)
        else tbl[id].isChecked = isChecked end
    end
    function tblFunc:rGet(listType, key)
        local tblFilter = filter.tblFilter
        local tbl = listType == 'CLASS' and tblFilter.CLASS or tblFilter.RACE
        if type(key) == 'string' then
            key = strupper(key)
            tbl = listType == 'CLASS' and tblFilter.tblClassByclassFile or tblFilter.tblRaceByclassFile end

        return tbl[key]
    end

    -- Class/Race Routines
    function tblFunc:createRecords()
        local tblRaceByFileName = filter.tblRaceByFileName
        local tblClassByFileName = filter.tblClassByFileName

        for k, v in pairs(ns.tblRacesByName) do
            filter.filterData:rSave('RACE', v.id, true, v.raceFile, v.name)
            tblRaceByFileName[v.raceFile] = filter.filterData:rNew(v.raceFile, v.name, v.isChecked, k)
        end
        for k, v in pairs(ns.tblClassesByName) do
            filter.filterData:rSave('CLASS', v.id, true, v.classFile, v.name)
            tblClassByFileName[v.classFile] = filter.filterData:rNew(v.classFile, v.name, v.isChecked, k)
        end
    end

    -- Filter Record Table
    function tblFunc:fNew()
        local newRecord = {
            recordID = nil,
            name = nil,
            whoCommand = nil,
            RACE = {},
            CLASS = {},
        }
        newRecord.RACE.allChecked = true
        newRecord.CLASS.allChecked = true

        return newRecord
    end
    function tblFunc:fSave(name, whoCommand)
        if not filter.tblFilter then return end

        filter.tblFilter = {
            recordID = filter.tblFilter.recordID or nil,
            name = name or filter.tblFilter.name,
            whoCommand = whoCommand or filter.tblFilter.whoCommand,
            RACE = filter.tblFilter.RACE or {},
            CLASS = filter.tblFilter.CLASS or {},
        }
    end
    function tblFunc:fSaveCheck(listType, tbl)
        if not filter.tblFilter then return end

        filter.tblFilter[listType] = tbl
    end
    function tblFunc:fGetList()
    end

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

    -- Create Filter Table
    self.tblFilter = filter.filterData:fNew()
    self.filterData:createRecords()

    -- Create UI
    self.createUI:BaseFilterUI()
    self.createUI:BuildFilterTopUI()
    self.createUI:BuildClassListUI()
    self.createUI:BuildRaceListUI()
end
function filter:CreateUI()
    local tblFunc = {}
    local skipCheckmarks = false

    -- CheckBox Routines
    local function evaluateIfAllChecked(listType)
        local checkBoxes = filter.tblFrame.inline[listType].checkBoxes

        skipCheckmarks = true
        filter.tblFrame.inline[listType].checkBoxAll:SetValue(true)
        for _, v in pairs(checkBoxes) do
            if not v:GetValue() then
                filter.tblFilter[listType].allChecked = false
                filter.tblFrame.inline[listType].checkBoxAll:SetValue(false)
                break
            end
        end
        skipCheckmarks = false
    end
    local function buildCheckBoxList(listType, control)
        local tblList = listType == 'CLASS' and ns.tblClasses or ns.tblRaces
        local tbl = ns.code:sortTableByField(tblList, 'name')

        filter.tblFrame.inline[listType].checkBoxes = {}
        for _, v in pairs(tbl) do
            local fName = listType == 'CLASS' and ns.code:cText(v.color, v.name) or v.name
            local checkBox = aceGUI:Create('CheckBox')
            checkBox:SetLabel(fName)
            checkBox:SetValue(filter.tblFilter[listType][v.id].isChecked or false)
            checkBox:SetRelativeWidth(.5)
            checkBox:SetCallback('OnValueChanged', function(_, _, isChecked)
                filter.filterData:rSave(listType, v.id, isChecked)
                evaluateIfAllChecked(listType)
            end)
            control:AddChild(checkBox)
            filter.tblFrame.inline[listType].checkBoxes[v.id] = checkBox
        end
    end
    local function checkAllCheckBoxes(listType)
        local checkBoxes = filter.tblFrame.inline[listType].checkBoxes
        skipCheckmarks = true

        for _, v in pairs(checkBoxes) do
            v:SetValue(filter.tblFilter[listType].allChecked)
        end
        skipCheckmarks = false
    end
    local function checkControls(disableSave)
        -- New Button
        filter.tblFrame.inline.btnNew:SetDisabled(not (filter.tblFilter.recordID or false))

        -- Delete Button
        filter.tblFrame.inline.btnDelete:SetDisabled(not (filter.tblFilter.recordID or false))

        -- Save Button
        filter.tblFrame.inline.btnSave:SetDisabled(disableSave or (not filter.tblFilter.name))
    end
    local function resetCustomFilter()
        local tblFrame = filter.tblFrame

        filter.tblFilter = filter.filterData:fNew()

        tblFrame.inline.filterName:SetText('')
        tblFrame.inline.whoEditbox:SetText('')
        tblFrame.inline.filterCombo:SetList(filter.filterData:fGetList())

        tblFrame.inline.RACE.checkBoxAll:SetValue(true)
        tblFrame.inline.CLASS.checkBoxAll:SetValue(true)

        checkAllCheckBoxes('RACE')
        checkAllCheckBoxes('CLASS')

        checkControls()
    end

    -- Base Filter UI
    function tblFunc:BaseFilterUI()
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
    function tblFunc:BuildFilterTopUI()
        local tblFrame = filter.tblFrame

        local inline = aceGUI:Create('InlineGroup')
        inline:SetLayout('Flow')
        inline:SetFullWidth(true)
        tblFrame.inline:AddChild(inline)

        -- Title combobox
        local combobox = aceGUI:Create('Dropdown')
        combobox:SetLabel(L['Custom Filters']..' (Still under development.):')
        combobox:SetRelativeWidth(.5)
        combobox:SetList(filter.filterData:fGetList())
        combobox:SetCallback('OnValueChanged', function(_, _, val)
        end)
        inline:AddChild(combobox)
        tblFrame.inline.filterCombo = combobox

        -- New Button
        local btnNew = aceGUI:Create('Button')
        btnNew:SetText(L['New'])
        btnNew:SetRelativeWidth(.25)
        btnNew:SetCallback('OnClick', function()
            resetCustomFilter()
        end)
        inline:AddChild(btnNew)
        tblFrame.inline.btnNew = btnNew

        -- Delete Button
        local btnDelete = aceGUI:Create('Button')
        btnDelete:SetText(L['Delete'])
        btnDelete:SetRelativeWidth(.25)
        btnDelete:SetCallback('OnClick', function()

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

            tblBase.statusText:SetText('')
            for _, r in pairs(ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}) do
                if strlower(r.name) == name then
                    tblBase.statusText:SetText(L['Filter Name Already Exists'])
                    checkControls('DISABLE_SAVE')
                    editbox:SetFocus() -- Set focus back to the editbox
                    return
                end
            end

            filter.filterData:fSave(name)
            checkControls()
        end)
        inline:AddChild(editbox)
        tblFrame.inline.filterName = editbox

        -- Save Button
        local btnSave = aceGUI:Create('Button')
        btnSave:SetText(L['Save'])
        btnSave:SetRelativeWidth(.3)
        btnSave:SetCallback('OnClick', function()
            local tblBase = ns.screens.base.tblFrame

            local tblFilters = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}

        end)
        inline:AddChild(btnSave)
        tblFrame.inline.btnSave = btnSave

        -- Who Command Editor
        local whoEditbox = aceGUI:Create('EditBox')
        whoEditbox:SetLabel(L['Who Command'])
        whoEditbox:SetFullWidth(true)
        whoEditbox:SetCallback('OnEnterPressed', function(_, _, text)
            filter.tblFilter.whoCommand = text
        end)
        inline:AddChild(whoEditbox)
        tblFrame.inline.whoEditbox = whoEditbox

        checkControls()
    end

    -- Build CheckBox List UI
    local scrollBoxHeight = 75
    function tblFunc:BuildClassListUI()
        local tblFrame = filter.tblFrame
        tblFrame.inline.CLASS, tblFrame.inline.RACE = {}, {}

        local inline = aceGUI:Create('InlineGroup')
        inline:SetTitle(L['Classes'])
        inline:SetLayout('Flow')
        inline:SetFullWidth(true)
        inline:SetHeight(scrollBoxHeight)
        tblFrame.inline:AddChild(inline)
        tblFrame.inline.CLASS.inline = inline

        local checkBox = aceGUI:Create('CheckBox')
        checkBox:SetLabel(ns.code:cText('FFFFFF00', 'Select/Deselect All Classes'))
        checkBox:SetValue(true)
        checkBox:SetRelativeWidth(1)
        checkBox:SetCallback('OnValueChanged', function(_, _, isChecked)
            if not skipCheckmarks then
                filter.tblFilter.CLASS.allChecked = isChecked
                checkAllCheckBoxes('CLASS')
            end
        end)
        inline:AddChild(checkBox)
        tblFrame.inline.CLASS.checkBoxAll = checkBox

        local scrollBox = aceGUI:Create('ScrollFrame')
        scrollBox:SetLayout('Flow')
        scrollBox:SetFullWidth(true)
        scrollBox:SetHeight(scrollBoxHeight)
        inline:AddChild(scrollBox)

        buildCheckBoxList('CLASS', scrollBox)
    end
    function tblFunc:BuildRaceListUI()
        local tblFrame = filter.tblFrame

        local inline = aceGUI:Create('InlineGroup')
        inline:SetTitle(L['Races'])
        inline:SetLayout('Flow')
        inline:SetFullWidth(true)
        inline:SetHeight(scrollBoxHeight)
        --inline:SetPoint('TOPLEFT', tblFrame.inline.CLASS.inline.frame, 'TOPRIGHT')
        tblFrame.inline:AddChild(inline)

        local checkBox = aceGUI:Create('CheckBox')
        checkBox:SetLabel(ns.code:cText('FFFFFF00', 'Select/Deselect All Races'))
        checkBox:SetValue(true)
        checkBox:SetRelativeWidth(1)
        checkBox:SetCallback('OnValueChanged', function(_, _, isChecked)
            if not skipCheckmarks then
                filter.tblFilter.RACE.allChecked = isChecked
                checkAllCheckBoxes('RACE')
            end
        end)
        inline:AddChild(checkBox)
        tblFrame.inline.RACE.checkBoxAll = checkBox

        local scrollBox = aceGUI:Create('ScrollFrame')
        scrollBox:SetLayout('Flow')
        scrollBox:SetFullWidth(true)
        scrollBox:SetHeight(scrollBoxHeight)
        inline:AddChild(scrollBox)

        buildCheckBoxList('RACE', scrollBox)--]]
    end

    return tblFunc
end
filter.createUI = filter:CreateUI()
filter.filterData = filter:FilterTable()
filter:Init()