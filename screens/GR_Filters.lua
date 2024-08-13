local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local aceGUI = LibStub("AceGUI-3.0")

ns.win.filter = {}
local filter = ns.win.filter

local function obsCLOSE_Filters()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_Filters)
    filter:SetShown(false)
end
function filter:Init()
    self.tblFrame = {}
    self.tblFilter = {}
end
function filter:SetShown(val)
    if not val then
        ns.win.base.tblFrame.backButton:SetShown(false)
        if self.tblFrame.inline then
            self.tblFrame.inline:ReleaseChildren()
            self.tblFrame.inline.frame:Hide()
        end
        return
    end

    --* Event Routines
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_Filters)

    ns.win.base.tblFrame.backButton:SetShown(true)
    ns.win.base.tblFrame.frame:SetSize(500, 580)
    ns.win.base.tblFrame.frame:SetShown(true)

    --* Create Display Tables
    self.tblFilter = {
        activeFilter = nil,

        tblRaceList = {},
        tblClassList = {},
        factionToShow = 1, -- Both Factions
    }
    for k, r in pairs(ns.tblRacesSortedByName) do
        self.tblFilter.tblRaceList[k] = {
            name = r.name,
            fName = r.name,
            faction = r.faction,
            fileName = r.raceFile,
            isChecked = true
        }
    end
    for k, c in pairs(ns.tblClassesSortedByName) do
        self.tblFilter.tblClassList[k] = {
            name = c.name,
            fName = ns.code:cPlayer(c.name, c.classFile),
            icon = c.icon,
            fileName = c.classFile,
            isChecked = true
        }
    end

    --* Create Controls
    self:CreateBaseFrame()
    self:CreateTopUIFrame()
    self:CreateRaceClassFrame()
    self:CreateRaceClassCheckboxes()
    self:CheckButtonEnable()
end

--* Construct UI
function filter:CreateBaseFrame()
    local tblBase = ns.win.base.tblFrame

    local f = self.tblFrame.frame or CreateFrame('Frame', nil, tblBase.frame)
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetPoint('TOPLEFT', tblBase.topFrame, 'BOTTOMLEFT', -5, 15)
    f:SetPoint('BOTTOMRIGHT', tblBase.statusBar, 'TOPRIGHT', 0, -5)
    f:SetShown(true)
    self.tblFrame.frame = f

    local inline = self.tblFrame.inline or aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, 0)
    inline:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 5)
    inline.frame:SetShown(true)
    self.tblFrame.inline = inline
end
--! Change filter Dropdown
--! Double check delete
--! Btndelete
--! Who Command Editor
function filter:CreateTopUIFrame()
    local function resetCustomFilter()
        self.activeFilter = nil
        self.tblFrame.filterCombo:SetList(filter.tbls:GetFilterList())
    end
    local function checkControlsEnabled()
    end

    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetFullWidth(true)
    self.tblFrame.inline:AddChild(inline)

    local combobox = aceGUI:Create('Dropdown')
    combobox:SetLabel(L['FILTERS'])
    combobox:SetRelativeWidth(.5)
    combobox:SetList(filter.tbls:GetFilterList())
    combobox:SetCallback('OnValueChanged', function(_, _, val)
    end)
    inline:AddChild(combobox)
    self.tblFrame.filterCombo = combobox

    -- New Button
    local btnNew = aceGUI:Create('Button')
    btnNew:SetText(L['NEW'])
    btnNew:SetRelativeWidth(.25)
    btnNew:SetCallback('OnClick', function() resetCustomFilter() end)
    inline:AddChild(btnNew)
    self.tblFrame.inline.btnNew = btnNew

    -- Delete Button
    local btnDelete = aceGUI:Create('Button')
    btnDelete:SetText(L['DELETE'])
    btnDelete:SetRelativeWidth(.25)
    btnDelete:SetCallback('OnClick', function()
        if not filter.activeFilter then return end

        ns.code:confirmation(L['DELETE_FILTER_CONFIRM'], function()
            ns.code:fOut('Filter Deleted: '..ns.global.filterList[filter.activeFilter].name)
            ns.global.filterList[filter.activeFilter] = nil
        end)

        resetCustomFilter()
    end)
    inline:AddChild(btnDelete)
    self.tblFrame.inline.btnDelete = btnDelete

    -- Filter Name
    local editbox = aceGUI:Create('EditBox')
    editbox:SetLabel(L['FILTER_DESC']..':')
    editbox:SetRelativeWidth(1)
    editbox:SetCallback('OnEnterPressed', function(_,_, text)
    end)
    inline:AddChild(editbox)
    self.tblFrame.inline.filterName = editbox

    -- Who Command Editor
    local whoEditbox = aceGUI:Create('EditBox')
    whoEditbox:SetLabel(L['WHO_COMMAND']..':')
    whoEditbox:SetFullWidth(true)
    whoEditbox:SetCallback('OnEnterPressed', function(_, _, text)
        filter.fData:saveFilter(nil, text)
    end)
    inline:AddChild(whoEditbox)
    self.tblFrame.inline.whoEditbox = whoEditbox
end
function filter:CreateRaceClassFrame()
    local scrollBoxHeight = 215

    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetRelativeWidth(.5)
    inline:SetHeight(scrollBoxHeight)
    self.tblFrame.inline:AddChild(inline)

    local cScrollbox = aceGUI:Create('ScrollFrame')
    cScrollbox:SetLayout('Flow')
    cScrollbox:SetFullWidth(true)
    cScrollbox:SetFullHeight(true)
    cScrollbox:SetHeight(scrollBoxHeight)
    inline:AddChild(cScrollbox)
    self.tblFrame.inline.classScrollbox = cScrollbox

    -- Class Header
    local header = aceGUI:Create('Heading')
    header:SetText(L['CLASSES'])
    header:SetRelativeWidth(1)
    self.tblFrame.inline.classScrollbox:AddChild(header)

    local rinline = aceGUI:Create('InlineGroup')
    rinline:SetLayout('Flow')
    rinline:SetRelativeWidth(.5)
    rinline:SetHeight(scrollBoxHeight)
    self.tblFrame.inline:AddChild(rinline)

    local rScrollbox = aceGUI:Create('ScrollFrame')
    rScrollbox:SetLayout('Flow')
    rScrollbox:SetFullWidth(true)
    rScrollbox:SetFullHeight(true)
    rScrollbox:SetHeight(scrollBoxHeight)
    rinline:AddChild(rScrollbox)
    self.tblFrame.inline.raceScrollbox = rScrollbox

    -- Race Header
    header = aceGUI:Create('Heading')
    header:SetText(L['RACES'])
    header:SetRelativeWidth(1)
    self.tblFrame.inline.raceScrollbox:AddChild(header)

    -- Blank Space
    local padding = aceGUI:Create('Label')
    padding:SetText(' ')
    padding:SetRelativeWidth(.7)
    self.tblFrame.inline:AddChild(padding)

    -- Save Button
    local btnSave = aceGUI:Create('Button')
    btnSave:SetText(L['SAVE'])
    btnSave:SetRelativeWidth(.3)
    btnSave:SetCallback('OnClick', function() filter.fData:saveFilterData() end)
    self.tblFrame.inline:AddChild(btnSave)
    self.tblFrame.inline.btnSave = btnSave
end
function filter:CreateRaceClassCheckboxes()
    local function createCheckbox(tbl, parent, isRaces)
        local hordeColor, allianceColor = 'FF8C1616', 'FF2E4994'
        local fName = not isRaces and tbl.fName or tbl.name
        if isRaces then
            fName = tbl.faction == 'Alliance' and ns.code:cText(allianceColor, fName) or ns.code:cText(hordeColor, fName)
        end

        local checkbox = aceGUI:Create('CheckBox')
        checkbox:SetLabel(fName)
        checkbox:SetRelativeWidth(.5)
        checkbox:SetValue(tbl.isChecked)
        checkbox:SetCallback('OnEnter', function()
            if not isRaces then return end
            ns.code:createTooltip(tbl.name, ns.code:cText(tbl.faction == 'Alliance' and allianceColor or hordeColor, tbl.faction))
        end)
        checkbox:SetCallback('OnLeave', function() GameTooltip:Hide() end)
        checkbox:SetCallback('OnValueChanged', function(_, _, val)
            tbl.isChecked = val
            filter:CheckButtonEnable()
        end)
        parent:AddChild(checkbox)
        return checkbox
    end

    for _, c in pairs(self.tblFilter.tblClassList) do
        createCheckbox(c, self.tblFrame.inline.classScrollbox)
    end

    for _, r in pairs(self.tblFilter.tblRaceList) do
        createCheckbox(r, self.tblFrame.inline.raceScrollbox, true)
    end
end
--* Filter Support Routines
function filter:tblFunctions()
    local tblFunc = {}
    function tblFunc:GetFilterList()
        local tbl = {}
        local tblList = ns.global.filterList and ns.global.filterList or {}
        for k, v in pairs(tblList) do
            tbl[k] = v.name
        end

        return tbl
    end

    return tblFunc
end
function filter:CheckButtonEnable()
end
filter:Init()
filter.tbls = filter:tblFunctions()