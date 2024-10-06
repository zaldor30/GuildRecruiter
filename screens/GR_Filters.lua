local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GuildRecruiter')
local aceGUI = LibStub("AceGUI-3.0")

ns.win.filter = {}
local filter = ns.win.filter

local function obsCLOSE_Filters()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_Filters)
    filter:SetShown(false)
end

local scrollBoxHeight = 215 -- Class and Race Scrollbox Height

--* Metatable for filter frame
local tblRaces, tblClasses, tblFilters = { data = {}, selected = {} }, { data = {}, selected = {} }, { data = {}, selected = {} }
local metaRaces = {
    __index = function(tbl, key)
        if key == 'data' then
            return tbl.data
        end
    end,
    __newIndex = function(tbl, key, value)
        if key == 'data' then
            for i = 1, #value do
                tbl[key][i] = value[i]
            end
        end
    end,

    sort = function(tbl, key)
        local sortedList = {}
        for _, v in pairs(tbl.data) do
            local rec = v[key]
            rec.isChecked = true
            rec.checkbox = nil

            table.insert(sortedList, rec)
        end
        table.sort(sortedList, function(a, b) return a.name < b.name end)
        tbl.sortedByName = sortedList
        return sortedList
    end,
    hasChecks = function(self)
        for _, v in pairs(self.data) do
            if v.isChecked then return true end
        end
        return false
    end,
}
local metaClasses = {
    __index = function(tbl, key)
        if key == 'data' then
            return tbl.data
        end
    end,
    __newIndex = function(tbl, key, value)
        if key == 'data' then
            for i = 1, #value do
                tbl[key][i] = value[i]
            end
        end
    end,

    sort = function(tbl, key)
        local sortedList = {}
        for _, v in pairs(tbl.data) do
            local rec = v[key]
            rec.isChecked = true
            rec.checkbox = nil

            table.insert(sortedList, rec)
        end
        table.sort(sortedList, function(a, b) return a.name < b.name end)
        tbl.sortedByName = sortedList
        return sortedList
    end,
    hasChecks = function(self)
        for _, v in pairs(self.data) do
            if v.isChecked then return true end
        end
        return false
    end,
}
local metaFilters = {
    __index = function(tbl, key)
        if key == 'data' then
            return tbl.data
        end
    end,
    __newIndex = function(tbl, key, value)
        if key == 'data' then
            for i = 1, #value do
                tbl[key][i] = value[i]
            end
        end
    end,

    sort = function(tbl, key)
        local sortedList = {}
        for _, v in pairs(tbl.data) do
            local rec = v[key]
            rec.isChecked = true
            rec.checkbox = nil

            table.insert(sortedList, rec)
        end
        table.sort(sortedList, function(a, b) return a.name < b.name end)
        tbl.sortedByName = sortedList
        return sortedList
    end,
    hasChecks = function(self)
        for _, v in pairs(self.data) do
            if v.isChecked then return true end
        end
        return false
    end,
}

function filter:Init()
    self.tblFrame = {}
    self.badDesc = true -- Flag for bad description editbox

    setmetatable(tblRaces, metaRaces)
    setmetatable(tblClasses, metaClasses)
    setmetatable(tblFilters, metaFilters)
end

--* Frame Routines
function filter:SetShown(val)
    if not val then
        ns.statusText:SetText('')
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

    --* Reconfigure base frame
    ns.win.base.tblFrame.backButton:SetShown(true)
    ns.win.base.tblFrame.frame:SetSize(500, 580)
    ns.win.base.tblFrame.frame:SetShown(true)

    self:Init() -- Initialize filter frame
    self:CreateBaseFrame()
    self:FillTopFrame()
end
function filter:CreateBaseFrame()
    local frame = ns.win.base.tblFrame

    local f = self.tblFrame.frame or CreateFrame('Frame', nil, frame.frame, 'BackdropTemplate')
    f:SetPoint('TOPLEFT', frame.iconFrame, 'BOTTOMLEFT', 0, 0)
    f:SetPoint('BOTTOMRIGHT', frame.statusBar, 'TOPRIGHT', 0, 0)
    f:SetBackdrop(BackdropTemplate())
    f:SetBackdropColor(1, 1, 1, 0)
    self.tblFrame.frame = f

    local fTop = self.tblFrame.top or CreateFrame('Frame', nil, f, 'BackdropTemplate')
    fTop:SetBackdrop(BackdropTemplate())
    fTop:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, -10)
    fTop:SetPoint('BOTTOMRIGHT', f, 'TOPRIGHT', -5, -100)
    self.tblFrame.top = fTop

    local fBottom = self.tblFrame.fBottom or CreateFrame('Frame', nil, f, 'BackdropTemplate')
    fBottom:SetBackdrop(BackdropTemplate())
    fBottom:SetPoint('TOPLEFT', fTop, 'BOTTOMLEFT', 0, -10)
    fBottom:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -5, 10)
    self.tblFrame.fBottom = fBottom
end
function filter:FillTopFrame()
    local fTop = self.tblFrame.top

    local dropdown = CreateFrame("Frame", "Filter_Selection", fTop, "UIDropDownMenuTemplate")
    dropdown:SetPoint('TOPLEFT', fTop, 'TOPLEFT', 5, -10)
    local function InitializeDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()

        -- Loop through the list of names
        for index, name in ipairs({}) do
            info.text = name  -- Set the text to the name
            info.arg1 = index  -- The index is passed as arg1
            info.func = function(self, arg1)
                print("Selected index: ", arg1)
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
    UIDropDownMenu_SetWidth(dropdown, 350)  -- Set the width of the dropdown
    UIDropDownMenu_SetButtonWidth(dropdown, 250)  -- Set the button width
    UIDropDownMenu_JustifyText(dropdown, "LEFT")  -- Justify text to the left
    UIDropDownMenu_SetText(dropdown, 'Select a filter or enter a description for a new one.')
end