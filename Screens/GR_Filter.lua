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
    self.tblFilter = nil
    self.activeRecord = nil
end
function filter:StartUp()
    local tblBase = ns.screens.base.tblFrame

    -- Setup for Close Routines
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCloseScreens)

    tblBase.backButton:SetShown(true)
    tblBase.frame:SetSize(500, 500)
    tblBase.frame:SetShown(true)

    filter.fData:getFilters()

    self:BuildFilterScreen()
    self:BuildFilterTop()
    self:BuildClassList()
    self:BuildRaceList()

    self:CheckEnable()
end
function filter:BuildFilterScreen()
    local tblFrame, tblBase = self.tblFrame, ns.screens.base.tblFrame

    local f = tblFrame.frame or CreateFrame('Frame', nil, tblBase.frame)
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 20)
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
function filter:BuildFilterTop()
    local tblFrame = self.tblFrame

    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetFullWidth(true)
    tblFrame.inline:AddChild(inline)

    -- Title combobox
    local combobox = aceGUI:Create('Dropdown')
    combobox:SetLabel('Filter:')
    combobox:SetRelativeWidth(.5)
    combobox:SetList(filter.fData:getFilters())
    combobox:SetCallback('OnValueChanged', function(_, _, val)
        self.activeRecord = val
        filter.fData:loadFilter(self.activeRecord)
        self:CheckEnable()
    end)
    inline:AddChild(combobox)
    tblFrame.inline.filterCombo = combobox

    -- New Button
    local btnNew = aceGUI:Create('Button')
    btnNew:SetText('New Filter')
    btnNew:SetRelativeWidth(.25)
    btnNew:SetCallback('OnClick', function()
        self.activeRecord = nil
        filter.tblFilter = nil
        tblFrame.inline.filterCombo:SetValue(nil)

        self.fData:loadClassRace()
        self:CheckEnable()
    end)
    inline:AddChild(btnNew)
    tblFrame.inline.btnNew = btnNew

    -- Delete Button
    local btnDelete = aceGUI:Create('Button')
    btnDelete:SetText('Delete Filter')
    btnDelete:SetRelativeWidth(.25)
    btnDelete:SetCallback('OnClick', function()
        if not self.activeRecord then return end

        local tblFilters = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}
        tremove(tblFilters, self.activeRecord)
        ns.dbGlobal.filterList = tblFilters

        self.activeRecord = nil
        filter.tblFilter = nil

        tblFrame.inline.filterCombo:SetList(filter.fData:getFilters())
        tblFrame.inline.filterCombo:SetValue(nil)

        self.fData:loadClassRace()
        self:CheckEnable()
    end)
    inline:AddChild(btnDelete)
    tblFrame.inline.btnDelete = btnDelete

    -- Filter Name
    local editbox = aceGUI:Create('EditBox')
    editbox:SetLabel('-- FILTERS ARE UNDER CONSTRUCTION-- FbtnFilter Name/Desc:')
    editbox:SetRelativeWidth(.7)
    editbox:SetCallback('OnEnterPressed', function(_,_, text)
        local badName = false
        local tblFilters = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}
        for x=1,#tblFilters do
            if strlower(tblFilters[x].name) == strlower(text) then
                print(x, self.activeRecord)
                if x ~= self.activeRecord then
                    badName = true break end
            end
        end
        if badName then
            ns.screens.base.tblFrame.statusText:SetText(ns.code:cText('FFFF0000', 'Filter name already exists.'))
            return
        else ns.screens.base.tblFrame.statusText:SetText('') end

        if filter.tblFilter then filter.tblFilter.name = text
        else filter.tblFilter = filter.fData:new(text) end

        self.activeRecord = 0

        filter.fData:loadClassRace()
        filter:CheckEnable()
    end)
    inline:AddChild(editbox)
    tblFrame.inline.filterName = editbox

    local btnSave = aceGUI:Create('Button')
    btnSave:SetText('Save')
    btnSave:SetRelativeWidth(.3)
    btnSave:SetCallback('OnClick', function()
        --if not filter.tblFilter then return end
        if filter.tblFilter then return end

        local tblFilters = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}

        local badName = false
        for x=1,#tblFilters do
            if strlower(tblFilters[x].name) == strlower(filter.tblFilter.name) then
                badName = true
                break
            end
        end
        if badName then
            ns.screens.base.tblFrame.statusText:SetText(ns.code:cText('FFFF0000', 'Filter name already exists.'))
            return
        end

        if filter:CheckTheCheckBoxes() then return end

        local classes, races = {}, {}
        for k, v in pairs(filter.tblFrame.CLASS) do classes[k.name] = v:GetValue() or false end
        for k, v in pairs(filter.tblFrame.RACE) do races[k.name] = v:GetValue() or false end

        filter.tblFilter.classes = classes
        filter.tblFilter.races = races

        self.activeRecord = self.activeRecord > 0 and self.activeRecord or #tblFilters + 1
        tblFilters[self.activeRecord] = filter.tblFilter
        ns.dbGlobal.filterList = tblFilters

        tblFrame.inline.filterCombo:SetList(filter.fData:getFilters())

        self.activeRecord = nil
        filter.tblFilter = nil

        self.fData:loadClassRace()
        self:CheckEnable()
    end)
    inline:AddChild(btnSave)
    tblFrame.inline.btnSave = btnSave

    -- Who Command Editor
    local whoEditbox = aceGUI:Create('EditBox')
    whoEditbox:SetLabel('Who Command (Chosse classes/races bellow):')
    whoEditbox:SetFullWidth(true)
    whoEditbox:SetCallback('OnEnterPressed', function(_, _, text)
        if self.tblFilter then self.tblFilter.whoCommand = text end

        local whoCommand = self.tblFilter and self.tblFilter.whoCommand or nil
        if not whoCommand then return end

        whoCommand = whoCommand:gsub('%d%d?%p%d%d?', '')
    end)
    inline:AddChild(whoEditbox)
    tblFrame.inline.whoEditbox = whoEditbox
end
-- Build Lists
function filter:BuildCheckBoxList(listType, control, tblList, tblData)
    control:ReleaseChildren()
    self.tblFrame[listType] = {}
    local tbl = ns.code:sortTableByField(tblList, 'name')
    for _, v in pairs(tbl) do
        local checkbox = aceGUI:Create('CheckBox')
        checkbox:SetLabel(v.name)
        checkbox:SetValue(tblData and (tblData[v] or false) or true)
        checkbox:SetCallback('OnValueChanged', function(_,_, value)
            tblData[v] = value
            filter:CheckTheCheckBoxes()
        end)
        control:AddChild(checkbox)
        self.tblFrame[listType][v] = checkbox

        if tblData then
            tblData[v] = type(tblData[v]) == 'boolean' and (tblData[v] or false) or true end
    end
end
function filter:BuildClassList()
    local tblFrame = self.tblFrame

    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetRelativeWidth(.5)
    inline:SetHeight(195)
    inline:SetTitle('Classes')
    tblFrame.inline:AddChild(inline)

    local scrollBox = aceGUI:Create('ScrollFrame')
    scrollBox:SetLayout('Flow')
    scrollBox:SetFullWidth(true)
    scrollBox:SetHeight(150)
    inline:AddChild(scrollBox)
    tblFrame.inline.classScrollBox = scrollBox

    self:BuildCheckBoxList('CLASS', scrollBox, ns.ds.tblClasses)

    local btnCheck = aceGUI:Create('Button')
    btnCheck:SetText('Check All')
    btnCheck:SetRelativeWidth(1)
    btnCheck:SetCallback('OnClick', function()
        for _, v in pairs(tblFrame.CLASS) do
            v:SetValue(true)
        end
    end)
    inline:AddChild(btnCheck)
    tblFrame.inline.btnClassCheck = btnCheck
end
function filter:BuildRaceList()
    local tblFrame = self.tblFrame

    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetRelativeWidth(.5)
    inline:SetHeight(215)
    inline:SetTitle('Races')
    tblFrame.inline:AddChild(inline)

    local scrollBox = aceGUI:Create('ScrollFrame')
    scrollBox:SetLayout('Flow')
    scrollBox:SetFullWidth(true)
    scrollBox:SetHeight(145)
    inline:AddChild(scrollBox)
    tblFrame.inline.raceScrollBox = scrollBox

    self:BuildCheckBoxList('RACE', scrollBox, ns.ds.tblRaces)

    local btnCheck = aceGUI:Create('Button')
    btnCheck:SetText('Check All')
    btnCheck:SetRelativeWidth(1)
    btnCheck:SetCallback('OnClick', function()
        for _, v in pairs(tblFrame.RACE) do
            v:SetValue(true)
        end
    end)
    inline:AddChild(btnCheck)
    tblFrame.inline.btnRaceCheck = btnCheck
end

-- Filter Data
function filter:tableFilterData()
    local tblFunc = {}
    function tblFunc:new(name)
        return {
            name = name or nil,
            whoCommand = nil,
            races = {},
            classes = {},
        }
    end
    function tblFunc:getFilters()
        local tblFilter = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}

        local tbl = {}
        for x=1,#tblFilter do
            tinsert(tbl, tblFilter[x].name)
        end
        return tbl
    end
    function tblFunc:loadFilter(filterID)
        if not filterID or filterID < 1 then return end

        local tblFilters = ns.dbGlobal.filterList and ns.dbGlobal.filterList or {}
        local tblFilter = tblFilters[filterID]
        filter.tblFrame.inline.filterName:SetText(tblFilter.name)
        for k in pairs(filter.tblFrame.CLASS) do
            filter.tblFrame.CLASS[k]:SetValue(tblFilter.classes[k.name] or false)
        end
        for k in pairs(filter.tblFrame.RACE) do
            filter.tblFrame.RACE[k]:SetValue(tblFilter.races[k.name] or false)
        end
    end
    function tblFunc:loadClassRace()
        local tblFrame, tblFilter = ns.screens.filter.tblFrame.inline, ns.screens.filter.tblFilter

        filter:BuildCheckBoxList('RACE', tblFrame.raceScrollBox, ns.ds.tblRaces, (tblFilter and tblFilter.races or nil))
        filter:BuildCheckBoxList('CLASS', tblFrame.classScrollBox, ns.ds.tblClasses, (tblFilter and tblFilter.classes or nil))

        tblFrame.filterName:SetText(tblFilter and tblFilter.name or nil)
        tblFrame.whoEditbox:SetText(tblFilter and tblFilter.whoCommand or nil)
    end

    return tblFunc
end
-- Set Enable/Disable
function filter:CheckEnable()
    local tblFrame = self.tblFrame.inline
    local enableAll = false

    if self.activeRecord and self.activeRecord > 0 then enableAll = true end

    tblFrame.filterCombo:SetDisabled(enableAll)
    tblFrame.whoEditbox:SetDisabled(not enableAll)

    for _, v in pairs(self.tblFrame.CLASS) do
        v:SetDisabled(not enableAll)
    end

    for _, v in pairs(self.tblFrame.RACE) do
        v:SetDisabled(not enableAll)
    end

    tblFrame.btnNew:SetDisabled(not enableAll)
    tblFrame.btnSave:SetDisabled(not enableAll)
    tblFrame.btnDelete:SetDisabled(not (self.activeRecord and self.activeRecord > 0))
    tblFrame.btnRaceCheck:SetDisabled(not enableAll)
    tblFrame.btnClassCheck:SetDisabled(not enableAll)
end
function filter:CheckTheCheckBoxes()
    ns.screens.base.tblFrame.statusText:SetText('')

    local noClass = true
    for _, v in pairs(filter.tblFilter.classes) do
        if v then noClass = false break end
    end
    if noClass then
        ns.screens.base.tblFrame.statusText:SetText(ns.code:cText('FFFF0000', 'You must select at least one class.'))
        return true
    end

    local noRace = true
    for _, v in pairs(filter.tblFilter.races) do
        if v then noRace = false break end
    end
    if noRace then
        ns.screens.base.tblFrame.statusText:SetText(ns.code:cText('FFFF0000', 'You must select at least one race.'))
        return true
    end

    return false
end
filter:Init()

filter.fData = filter:tableFilterData()