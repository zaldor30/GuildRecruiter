local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.filters = {}
local filters = ns.filters

local function obsCLOSE_FILTERS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_FILTERS)

    if filters.tblFrame.frame then ns.frames:ResetFrame(filters.tblFrame.frame) end
    filters.tblFrame = nil
end

function filters:Init()

end

function filters:IsShown() return (self.tblFrame and self.tblFrame.frame and self.tblFrame.frame:IsShown()) or false end
function filters:SetShown(val)
    if not val and not self:IsShown() then return
    elseif not val and self:IsShown() then self.tblFrame.frame:SetShown(false) end

    -- Notify observers and register for close events
    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_FILTERS)

    self.tblFrame = self.tblFrame or {}
    self.filtering = self.filtering or 'CLASS' -- Default to class filtering
    self.tblCFilters, self.tblRFilters = {}, {}

    ns.code:ChangeBaseFrameSize(500, 325) -- Adjust base frame size for filters

    if not self.tblFrame.frame then
        self:CreateFilterFrame()
        --self:CreateResultBox()
    end

    self:ChangeFiltering()
    self:UpdateButtonState()
end
function filters:CreateFilterFrame()
    -- Implementation for creating the filter frame goes here
    local baseFrame = ns.base.tblFrame
    local f = ns.frames:CreateFrame("Frame", "GR_FilterFrame", baseFrame.frame)
    f:SetPoint("TOPLEFT", baseFrame.icon, "BOTTOMLEFT", 5, 0)
    f:SetPoint("BOTTOMRIGHT", baseFrame.status, "TOPRIGHT", -5, 0)
    f:SetBackdropColor(0,0,0,0)
    f:SetBackdropBorderColor(0,0,0,0)
    f:EnableMouse(false)
    f:SetShown(true)
    self.tblFrame.frame = f

    -- Class/Race Selector
    local bClass = ns.frames:CreateFrame("Button", "GR_ClassButton", f)
    bClass:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -8)
    bClass:SetSize(50, 20)

    -- use white font object and apply to all states
    bClass:SetNormalFontObject(GameFontHighlight)
    bClass:SetHighlightFontObject(GameFontHighlight)
    bClass:SetDisabledFontObject(GameFontDisable)

    bClass:SetText(L["CLASS"])
    bClass:SetHighlightTexture(ns.BLUE_HIGHLIGHT)

    -- force size 14 while keeping GameFontHighlight's file/flags
    local file, _, flags = GameFontHighlight:GetFont()
    local fs = bClass:GetFontString()
    fs:SetFont(file, 14, flags)

    local bSeparator = f:CreateTexture(nil, 'ARTWORK')
    bSeparator:SetSize(10, 20)
    bSeparator:SetPoint('LEFT', bClass, 'RIGHT', 0, 0)
    bSeparator:SetAtlas('AnimaChannel-Line-Mask')

    local bRace = ns.frames:CreateFrame('Button', 'GR_RaceButton', f)
    bRace:SetPoint('LEFT', bSeparator, 'RIGHT', 0, 0)
    bRace:SetSize(50, 20)

    -- use white font object and apply to all states
    bRace:SetNormalFontObject(GameFontHighlight)
    bRace:SetHighlightFontObject(GameFontHighlight)
    bRace:SetDisabledFontObject(GameFontDisable)

    bRace:SetText(L["RACE"])
    bRace:SetHighlightTexture(ns.BLUE_HIGHLIGHT)

    -- force size 14 while keeping GameFontHighlight's file/flags
    local bfs = bRace:GetFontString()
    bfs:SetFont(file, 14, flags)

    -- Class Button Handlers
    bClass:SetScript('OnClick', function()
        if self.filtering == 'CLASS' then return end -- Already filtering by class

        self.filtering = 'CLASS'
        self:ChangeFiltering()
    end)

    -- Race Button Handlers
    bRace:SetScript('OnClick', function()
        if self.filtering == 'RACE' then return end -- Already filtering by class

        self.filtering = 'RACE'
        self:ChangeFiltering()
    end)

    if self.filtering == 'CLASS' then fs:SetTextColor(0.53, 0.81, 1)
    else bfs:SetTextColor(0.53, 0.81, 1) end

    self:LoadDropdownList()

    local bNew = ns.frames:CreateFrame("Button", "GR_NewButton", f)
    bNew:SetPoint("TOPRIGHT", self.tblFrame.dropFilter.frame, "TOPLEFT", 5, -5)
    bNew:SetSize(50, 20)

    -- use white font object and apply to all states
    bNew:SetNormalFontObject(GameFontHighlight)
    bNew:SetHighlightFontObject(GameFontHighlight)
    bNew:SetDisabledFontObject(GameFontDisable)

    bNew:SetText(L["NEW"])
    bNew:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    bNew:SetScript('OnClick', function()
        bNew:Disable()
        filters.activeFilter = nil
        filters.tblFilterOld = nil
        filters.tblFrame.eSave:SetText('')
        filters:ChangeFiltering()
        filters:UpdateButtonState()
    end)

    fs = bNew:GetFontString()
    fs:SetFont(file, 14, flags)
    bNew:Disable() -- Disabled until implemented

    self.tblFrame.bNew = bNew
    self.tblFrame.bClass = bClass
    self.tblFrame.bRace = bRace
end
function filters:CreateResultBox()
    local f = self.tblFrame.resultFrame or {}

    local saveLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    saveLabel:SetPoint("TOPLEFT", self.tblFrame.bClass, "BOTTOMLEFT", 10, -18)
    saveLabel:SetText(L['CUSTOM_FILTER_NAME']..":")
    saveLabel:SetTextColor(1, 1, 1, 1)

    local editSave = ns.frames:CreateFrame("EditBox", "Filter_Save", f, "InputBoxTemplate")
    editSave:SetSize(200, 20)
    editSave:SetPoint("LEFT", saveLabel, "RIGHT", 8, 0)
    editSave:SetAutoFocus(false)
    editSave:SetScript("OnTextChanged", function(self)
        filters:UpdateButtonState()
    end)
    local bSave = ns.frames:CreateFrame("Button", "GR_ClassButton", f)
    bSave:SetPoint("LEFT", editSave, "RIGHT", 0, -1)
    bSave:SetSize(50, 20)
    bSave:SetNormalFontObject(GameFontHighlight)
    bSave:SetHighlightFontObject(GameFontHighlight)
    bSave:SetDisabledFontObject(GameFontDisable)

    bSave:SetText(L['SAVE'])
    bSave:SetHighlightTexture(ns.BLUE_HIGHLIGHT)

    bSave:SetScript('OnClick', function()
        local name = (filters.tblFrame and filters.tblFrame.eSave) and filters.tblFrame.eSave:GetText() or ''
        if not name then return end

        for k, v in pairs(ns.gFilterList or {}) do
            if strlower(v.name) == strlower(name) then
                if ns.frames:Confirmation(v.name..L['FILTER_OVERWRITE'], function(confirmed)
                    if confirmed then
                        filters.activeFilter = k
                        return false
                    else
                        filters.tblFrame.eSave:SetText('')
                        filters.tblFrame.bSave:Disable()
                        filters:UpdateButtonState()
                        return true
                    end
                end) then return end
            end
        end

        local tblOut = {
            name = name,
            type = filters.filtering,
            criteria = filters.filtering == 'CLASS' and filters.tblFilter.class or filters.tblFilter.race
        }

        if filters.activeFilter and ns.gFilterList[filters.activeFilter] then print('overwrite') ns.gFilterList[filters.activeFilter] = tblOut
        else print('new') tinsert(ns.gFilterList, tblOut) end

        ns.code:updateStatusText(L['FILTER_SAVE_SUCCESSFUL'], { r=0, g=1, b=0, a=1}) -- Clear status
        C_Timer.After(5, function() ns.code:updateStatusText() end)
    end)

    local file, _, flags = GameFontHighlight:GetFont()
    local fs = bSave:GetFontString()
    fs:SetFont(file, 14, flags)

    local bSeparator = f:CreateTexture(nil, 'ARTWORK')
    bSeparator:SetSize(10, 20)
    bSeparator:SetPoint('LEFT', bSave, 'RIGHT', 0, 0)
    bSeparator:SetAtlas('AnimaChannel-Line-Mask')

    local bDelete = ns.frames:CreateFrame("Button", "GR_ClassButton", f)
    bDelete:SetPoint("LEFT", bSeparator, "RIGHT", 0, -1)
    bDelete:SetSize(50, 20)
    bDelete:SetNormalFontObject(GameFontHighlight)
    bDelete:SetHighlightFontObject(GameFontHighlight)
    bDelete:SetDisabledFontObject(GameFontDisable)

    bDelete:SetText(L['DELETE'])
    bDelete:SetHighlightTexture(ns.BLUE_HIGHLIGHT)

    fs = bDelete:GetFontString()
    fs:SetFont(file, 14, flags)
    bDelete:Disable() -- Disabled until implemented

    self.tblFrame.eSave = editSave
    self.tblFrame.bSave = bSave
    self.tblFrame.bDelete = bDelete -- To be implemented
end
function filters:CreateCheckBoxes()
    self.tblFilter = self.tblFilter or {}
    self.tblFilter.class = self.tblFilter.class or {}
    self.tblFilter.race = self.tblFilter.race or {}

    local fResults = ns.frames:CreateFrame("Frame", "Filter_Results", self.tblFrame.frame)
    fResults:SetPoint("TOPLEFT", self.tblFrame.resultFrame, "TOPLEFT", 0, -30)
    fResults:SetPoint("BOTTOMRIGHT", self.tblFrame.resultFrame, "BOTTOMRIGHT", 0, 5)
    fResults:EnableMouse(true)

    fResults:SetBackdropColor(0,0,0,0)
    fResults:SetBackdropBorderColor(0,0,0,0)

    if self.filtering == 'CLASS' then
        self.tblFilter.class, self.tblFrame.classChecks = ns.frames:BuildTwoColumnChecks(
            fResults,
            ns.classes,            -- items to show
            self.tblFilter.class,  -- SAVE TABLE (booleans per key)
            false,                 -- defaultChecked (unchecked)
            function(key, checked) ns.filters:UpdateButtonState() end
        )

        self.tblFrame.class = fResults
    elseif self.filtering == 'RACE' then
        self.tblFilter.class, self.tblFrame.classChecks = ns.frames:BuildTwoColumnChecks(
            fResults,
            ns.races,            -- items to show
            self.tblFilter.races,  -- SAVE TABLE (booleans per key)
            false,                 -- defaultChecked (unchecked)
            function(key, checked) ns.filters:UpdateButtonState() end
        )

        self.tblFrame.class = fResults
    end
end
function filters:UpdateButtonState()
    if not self.tblFrame or not self.tblFrame.eSave or not self.tblFrame.bSave then return end

    if self.activeFilter then
        self.tblFrame.bNew:Enable()
        self.tblFrame.bDelete:Enable()
    else
        self.tblFrame.bNew:Disable()
        self.tblFrame.bDelete:Disable()
    end

    if strlen(self.tblFrame.eSave:GetText() or '') == 0 then
        ns.code:updateStatusText(L['FILTER_NO_SAVE_NAME'], { r = 1, g = 0, b = 0, a = 1 })
        self.tblFrame.bSave:Disable()
        return
    end

    local total = #(self.tblFrame.class._checks or {})
    local checkCount, checkFound = 0, false
    for _, cb in ipairs(self.tblFrame.class._checks or {}) do
        if cb:GetChecked() then
            checkFound = true
            checkCount = checkCount + 1
            --print(cb.Text:GetText())
        end
    end

    if total == checkCount then
        ns.code:updateStatusText(L['FILTER_ALL_SELECTED'], { r = 1, g = 0, b = 0, a = 1 })
        self.tblFrame.bSave:Disable()
        return
    elseif not checkFound then
        if self.filtering == 'CLASS' then ns.code:updateStatusText(L['FILTER_SELECT_CLASS'], { r = 1, g = 0, b = 0, a = 1 })
        else ns.code:updateStatusText(L['FILTER_SELECT_RACE'], { r = 1, g = 0, b = 0, a = 1 }) end
        self.tblFrame.bSave:Disable()
        return
    end

    self.tblFrame.bNew:Enable()
    ns.code:updateStatusText() -- Clear status
    self.tblFrame.bSave:Enable()
end
function filters:ChangeFiltering()
    if self.tblFilterOld ~= self.filtering then
        local fileName = self.tblFrame.eSave and self.tblFrame.eSave:GetText() or ''

        self.activeFilter = nil
        self.tblFilterOld = self.filtering

        local bClass, bRace = self.tblFrame.bClass, self.tblFrame.bRace
        if bRace then bRace:GetFontString():SetTextColor(1, 1, 1) end
        if bClass then bClass:GetFontString():SetTextColor(1, 1, 1) end

        if self.filtering == 'CLASS' and bClass then bClass:GetFontString():SetTextColor(0.53, 0.81, 1)
        elseif self.filtering == 'RACE' and bRace then bRace:GetFontString():SetTextColor(0.53, 0.81, 1) end

        if self.tblFrame.checkBoxes then ns.frames:ResetFrames(self.tblFrame.checkBoxes) end
        if self.tblFrame.resultFrame then ns.frames:ResetFrame(self.tblFrame.resultFrame) end

        if self.tblFrame.resultFrame then ns.frames:ResetFrame(self.tblFrame.resultFrame) end
        local f = ns.frames:CreateFrame("Frame", "Filter_Results", self.tblFrame.frame)
        f:SetPoint("TOPLEFT", self.tblFrame.bClass, "BOTTOMLEFT", 0, -8)
        f:SetPoint("BOTTOMRIGHT", ns.base.tblFrame.status, "TOPRIGHT", -8, 0)
        f:SetHeight(250)
        f:SetShown(true)

        self.tblFrame.resultFrame = f
        self:CreateResultBox()
        self:CreateCheckBoxes()

        if self.tblFrame.eSave then self.tblFrame.eSave:SetText(fileName) end
    end
end
function filters:LoadDropdownList()
    local f = self.tblFrame.frame
    if not f then return end

    local filterSelected = {
        onSelect = function(id, description)
            filters.activeFilter = id
            if ns.gFilterList and ns.gFilterList[id] then
                local filter = ns.gFilterList[id]
                filters.filtering = filter.type or 'CLASS'
                filters:ChangeFiltering()

                if filters.tblFrame and filters.tblFrame.eSave then
                    filters.tblFrame.eSave:SetText(filter.name or '')
                end
                -- Load criteria
                if filter.type == 'CLASS' and filter.criteria then
                    for k, v in pairs(filters.tblFilter.class or {}) do
                        print(k, filter.criteria[k], filter.criteria[k])
                        filters.tblFilter.class[k] = (filter.criteria[k] == true)
                    end
                elseif filter.type == 'RACE' and filter.criteria then
                    for k, v in pairs(filters.tblFilter.race or {}) do
                        filters.tblFilter.race[k] = (filter.criteria[k] == true)
                    end
                end
            else
                ns.code:updateStatusText(L['FILTER_LOAD_ERROR'], { r=1, g=0, b=0, a=1 })
                C_Timer.After(5, function() ns.code:updateStatusText() end)
                filters.activeFilter = nil
                return
            end
        end
    }

    local tblPresort = {}
    for k, v in ipairs(ns.gFilterList or {}) do
        tinsert(tblPresort, { description = v.name, id = k })
    end
    self.tblSorted = ns.code:sortTableByField(tblPresort or {}, 'description', false)

    local dropInvite = ns.dropdown:new(
        'GR_Filter_Dropdown', -- Name of the dropdown frame
        f,          -- Parent frame
        210,                  -- Width of the dropdown
        L['SELECT_FILTER'],   -- Default text
        self.tblSorted,              -- Entries for the dropdown
        filterSelected              -- Additional options (callbacks)
    )
    dropInvite.frame:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -3)

    self.tblFrame.dropFilter = dropInvite
end