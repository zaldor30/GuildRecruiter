local addonName, ns = ... -- Namespace (myAddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.filters = {}
local filters = ns.filters

local function obsCLOSE_FILTERS()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_FILTERS)
    if filters.tblFrame and filters.tblFrame.frame then
        ns.frames:ResetFrame(filters.tblFrame.frame)
    end
    -- hard reset state so next open rebuilds UI
    filters.tblFrame     = nil
    filters.tblFilterOld = nil
    filters.activeFilter = nil
end

function filters:Init()

end

function ns.frames:Rule(parent, orient, length, thickness, r,g,b,a)
  local t = parent:CreateTexture(nil, "ARTWORK")
  if t.SetColorTexture then t:SetColorTexture(r or 1, g or 1, b or 1, a or 0.15)
  else t:SetTexture("Interface\\Buttons\\WHITE8x8"); t:SetVertexColor(r or 1, g or 1, b or 1, a or 0.15) end
  thickness = thickness or 1
  length = length or 20
  if (orient == "VERTICAL") then t:SetSize(thickness, length) else t:SetSize(length, thickness) end
  return t
end

function filters:IsShown() return (self.tblFrame and self.tblFrame.frame and self.tblFrame.frame:IsShown()) or false end
function filters:SetShown(val)
    if not val and not self:IsShown() then return
    elseif not val and self:IsShown() then
        self.tblFrame.frame:SetShown(false)
        return
    end

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_FILTERS)

    self.tblFrame   = self.tblFrame or {}
    self.filtering  = self.filtering or 'CLASS'
    self.tblFilter  = self.tblFilter or { class = {}, race = {} }

    -- Build ID-indexed lookups
    self.tblCFilters_CheckIndex = {}
    for token, info in pairs(ns.classes or {}) do
        if info and info.id then
            self.tblCFilters_CheckIndex[info.id] = {
                id=info.id, name=info.name or info.text or info.localizedName or token,
                color=info.color, token=token
            }
        end
    end
    self.tblRFilters_CheckIndex = {}
    for token, info in pairs(ns.races or {}) do
        if info and info.id then
            self.tblRFilters_CheckIndex[info.id] = {
                id=info.id, name=info.name or info.text or info.localizedName or token,
                color=info.color, token=token
            }
        end
    end

    ns.code:ChangeBaseFrameSize(500, 325)

    if not self.tblFrame.frame then
        self:CreateFilterFrame()
    end

    self.tblFilterOld = nil -- force rebuild on (re)open
    self:ChangeFiltering()
    self:UpdateButtonState()
end
function filters:CreateFilterFrame()
    local baseFrame = ns.base.tblFrame
    local f = ns.frames:CreateFrame("Frame", "GR_FilterFrame", baseFrame.frame)
    f:SetPoint("TOPLEFT", baseFrame.icon, "BOTTOMLEFT", 5, 0)
    f:SetPoint("BOTTOMRIGHT", baseFrame.status, "TOPRIGHT", -5, 0)
    f:SetBackdropColor(0,0,0,0)
    f:SetBackdropBorderColor(0,0,0,0)
    f:EnableMouse(false)
    f:SetShown(true)
    self.tblFrame.frame = f

    local bClass = ns.frames:CreateFrame("Button", "GR_ClassButton", f)
    bClass:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -8)
    bClass:SetSize(50, 20)
    bClass:SetNormalFontObject(GameFontHighlight)
    bClass:SetHighlightFontObject(GameFontHighlight)
    bClass:SetDisabledFontObject(GameFontDisable)
    bClass:SetText(L["CLASS"])
    bClass:SetHighlightTexture(ns.BLUE_HIGHLIGHT)

    local file, _, flags = GameFontHighlight:GetFont()
    local fs = bClass:GetFontString()
    fs:SetFont(file, 14, flags)

    local sep = ns.frames:Rule(f, "VERTICAL", 20, 1, 1,1,1, 0.25)
    sep:SetPoint("LEFT", bClass, "RIGHT", 6, 0)

    local bRace = ns.frames:CreateFrame('Button', 'GR_RaceButton', f)
    bRace:SetPoint('LEFT', sep, 'RIGHT', 0, 0)
    bRace:SetSize(50, 20)
    bRace:SetNormalFontObject(GameFontHighlight)
    bRace:SetHighlightFontObject(GameFontHighlight)
    bRace:SetDisabledFontObject(GameFontDisable)
    bRace:SetText(L["RACE"])
    bRace:SetHighlightTexture(ns.BLUE_HIGHLIGHT)

    local bfs = bRace:GetFontString()
    bfs:SetFont(file, 14, flags)

    bClass:SetScript('OnClick', function()
        if self.filtering == 'CLASS' then return end
        self.filtering = 'CLASS'
        self:ChangeFiltering()
    end)
    bRace:SetScript('OnClick', function()
        if self.filtering == 'RACE' then return end
        self.filtering = 'RACE'
        self:ChangeFiltering()
    end)

    if self.filtering == 'CLASS' then fs:SetTextColor(0.53, 0.81, 1) else bfs:SetTextColor(0.53, 0.81, 1) end

    self:LoadDropdownList()

    local bNew = ns.frames:CreateFrame("Button", "GR_NewButton", f)
    bNew:SetPoint("TOPRIGHT", self.tblFrame.dropFilter.frame, "TOPLEFT", 5, -5)
    bNew:SetSize(50, 20)
    bNew:SetNormalFontObject(GameFontHighlight)
    bNew:SetHighlightFontObject(GameFontHighlight)
    bNew:SetDisabledFontObject(GameFontDisable)
    bNew:SetText(L["NEW"])
    bNew:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    bNew:SetScript('OnClick', function()
        bNew:Disable()
        self.tblFilterOld = nil
        self:ResetUI(true)   -- clears checks + name + dropdown
        self:ChangeFiltering()
    end)
    bNew:GetFontString():SetFont(file, 14, flags)
    bNew:Disable()

    self.tblFrame.bNew = bNew
    self.tblFrame.bClass = bClass
    self.tblFrame.bRace = bRace
end
function filters:CreateResultBox()
    if self.tblFrame.eSave then return end

    local f = self.tblFrame.resultFrame
    local saveLabel = self.tblFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    saveLabel:SetPoint("TOPLEFT", self.tblFrame.bClass, "BOTTOMLEFT", 10, -18)
    saveLabel:SetText(L['CUSTOM_FILTER_NAME']..":")
    saveLabel:SetTextColor(1,1,1,1)

    local editSave = ns.frames:CreateFrame("EditBox", "Filter_Save", f, "InputBoxTemplate")
    editSave:SetSize(200, 20)
    editSave:SetPoint("LEFT", saveLabel, "RIGHT", 8, 0)
    editSave:SetAutoFocus(false)
    editSave:SetScript("OnTextChanged", function() filters:UpdateButtonState() end)

    local bSave = ns.frames:CreateFrame("Button", "GR_FilterSaveButton", f)
    bSave:SetPoint("LEFT", editSave, "RIGHT", 0, -1)
    bSave:SetSize(50, 20)
    bSave:SetNormalFontObject(GameFontHighlight)
    bSave:SetHighlightFontObject(GameFontHighlight)
    bSave:SetDisabledFontObject(GameFontDisable)
    bSave:SetText(L['SAVE'])
    bSave:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    bSave:SetScript('OnClick', function()
        local name = (filters.tblFrame.eSave and filters.tblFrame.eSave:GetText()) or ''
        if not name or name == '' then return end

        for k, v in pairs(ns.gFilterList or {}) do
            if strlower(v.name) == strlower(name) then
                ns.frames:Confirmation(v.name..(L['FILTER_OVERWRITE'] or " will be overwritten."), function()
                    filters.activeFilter = k
                end)
                return
            end
        end

        local criteria = {}
        local src = (filters.filtering == 'CLASS') and (filters.tblFilter.class or {}) or (filters.tblFilter.race or {})
        for id, checked in pairs(src) do if checked then criteria[id] = true end end

        local tblOut = { name = name, type = filters.filtering, criteria = criteria }
        if filters.activeFilter and ns.gFilterList[filters.activeFilter] then
            ns.gFilterList[filters.activeFilter] = tblOut
        else
            tinsert(ns.gFilterList, tblOut)
        end

        ns.code:updateStatusText(L['FILTER_SAVE_SUCCESSFUL'], { r=0, g=1, b=0, a=1})
        filters:RefreshFilterDropdown()
        filters:ResetUI(true)
        C_Timer.After(5, function() ns.code:updateStatusText() end)
    end)

    local file, _, flags = GameFontHighlight:GetFont()
    bSave:GetFontString():SetFont(file, 14, flags)

    local sep = ns.frames:Rule(f, "VERTICAL", 20, 1, 1,1,1, 0.25)
    sep:SetPoint("LEFT", bSave, "RIGHT", 6, 0)

    local bDelete = ns.frames:CreateFrame("Button", "GR_FilterDeleteButton", f)
    bDelete:SetPoint("LEFT", sep, "RIGHT", 0, -1)
    bDelete:SetSize(60, 20)
    bDelete:SetNormalFontObject(GameFontHighlight)
    bDelete:SetHighlightFontObject(GameFontHighlight)
    bDelete:SetDisabledFontObject(GameFontDisable)
    bDelete:SetText(L['DELETE'])
    bDelete:SetHighlightTexture(ns.BLUE_HIGHLIGHT)
    bDelete:GetFontString():SetFont(file, 14, flags)
    bDelete:Disable()
    bDelete:SetScript('OnClick', function()
        local id = filters.activeFilter
        if not id or not (ns.gFilterList and ns.gFilterList[id]) then return end
        local name = ns.gFilterList[id].name or ("#" .. id)
        ns.frames:Confirmation((L['FILTER_DELETE_CONFIRM'] or "Delete filter '%s'?"):format(name), function()
            table.remove(ns.gFilterList, id)
            filters.activeFilter = nil
            filters:RefreshFilterDropdown()
            filters:ResetUI(true)
            filters:UpdateButtonState()
        end)
    end)

    self.tblFrame.eSave   = editSave
    self.tblFrame.bSave   = bSave
    self.tblFrame.bDelete = bDelete
end
function filters:_ClearChecks()
    local c = self.tblFrame and self.tblFrame.checkContainer
    if not c then return end
    for _, child in ipairs({ c:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
    c:Hide()
    c:SetParent(nil)
    self.tblFrame.checkContainer = nil
    self.tblFrame.class = nil -- for UpdateButtonState counting
end
function filters:CreateCheckBoxes()
    self.tblFilter       = self.tblFilter or {}
    self.tblFilter.class = self.tblFilter.class or {}
    self.tblFilter.race  = self.tblFilter.race  or {}

    -- unnamed container avoids global name reuse
    local container = ns.frames:CreateFrame("Frame", nil, self.tblFrame.resultFrame)
    container:SetPoint("TOPLEFT",     self.tblFrame.resultFrame, "TOPLEFT",     0, -30)
    container:SetPoint("BOTTOMRIGHT", self.tblFrame.resultFrame, "BOTTOMRIGHT", 0,  5)
    container:EnableMouse(true)
    container:SetBackdropColor(0,0,0,0)
    container:SetBackdropBorderColor(0,0,0,0)

    if self.filtering == 'CLASS' then
        local items = self.tblCFilters_CheckIndex or {}
        local save  = self.tblFilter.class
        local _, checks = ns.frames:BuildTwoColumnChecks(
            container, items, save, false,
            function(id, checked)
                if checked then save[id] = true else save[id] = nil end
                ns.filters:UpdateButtonState()
            end
        )
        container._checks = checks
    else
        local items = self.tblRFilters_CheckIndex or {}
        local save  = self.tblFilter.race
        local _, checks = ns.frames:BuildTwoColumnChecks(
            container, items, save, false,
            function(id, checked)
                if checked then save[id] = true else save[id] = nil end
                ns.filters:UpdateButtonState()
            end
        )
        container._checks = checks
    end

    self.tblFrame.checkContainer = container
    self.tblFrame.class = container -- used by UpdateButtonState
end
function filters:UpdateButtonState()
    if not self.tblFrame then return end

    local eSave   = self.tblFrame.eSave
    local bSave   = self.tblFrame.bSave
    local bNew    = self.tblFrame.bNew
    local bDelete = self.tblFrame.bDelete
    local checksC = self.tblFrame.class and self.tblFrame.class._checks or {}

    local nameText = eSave and eSave:GetText() or ""
    local hasName  = strlen(nameText) > 0

    local total, checked = #checksC, 0
    for _, cb in ipairs(checksC) do
        if cb:GetChecked() then checked = checked + 1 end
    end
    local anyChecked   = checked > 0
    local allChecked   = (total > 0) and (checked == total)

    -- New: enable if any condition
    if bNew then
        if self.activeFilter or anyChecked or hasName then bNew:Enable() else bNew:Disable() end
    end

    -- Delete: only when a saved filter is active
    if bDelete then
        if self.activeFilter then bDelete:Enable() else bDelete:Disable() end
    end

    -- Save: needs name + some selection, but not all
    local canSave = hasName and anyChecked and not allChecked
    if bSave then
        if canSave then
            bSave:Enable()
            ns.code:updateStatusText()
        else
            bSave:Disable()
            -- status hints
            if not hasName then
                ns.code:updateStatusText(L['FILTER_NO_SAVE_NAME'], { r=1,g=0,b=0,a=1 })
            elseif not anyChecked then
                if self.filtering == 'CLASS' then
                    ns.code:updateStatusText(L['FILTER_SELECT_CLASS'], { r=1,g=0,b=0,a=1 })
                else
                    ns.code:updateStatusText(L['FILTER_SELECT_RACE'], { r=1,g=0,b=0,a=1 })
                end
            elseif allChecked then
                ns.code:updateStatusText(L['FILTER_ALL_SELECTED'], { r=1,g=0,b=0,a=1 })
            else
                ns.code:updateStatusText()
            end
        end
    end
end
function filters:ChangeFiltering()
    local needRoot = not (self.tblFrame and self.tblFrame.resultFrame)
    if not needRoot and self.tblFilterOld == self.filtering then return end

    local fileName = (self.tblFrame.eSave and self.tblFrame.eSave:GetText()) or ''
    self.tblFilterOld = self.filtering -- do NOT clear self.activeFilter here

    local bClass, bRace = self.tblFrame.bClass, self.tblFrame.bRace
    if bRace then bRace:GetFontString():SetTextColor(1, 1, 1) end
    if bClass then bClass:GetFontString():SetTextColor(1, 1, 1) end
    if self.filtering == 'CLASS' and bClass then
        bClass:GetFontString():SetTextColor(0.53, 0.81, 1)
    elseif self.filtering == 'RACE' and bRace then
        bRace:GetFontString():SetTextColor(0.53, 0.81, 1)
    end

    if needRoot then
        local f = ns.frames:CreateFrame("Frame", nil, self.tblFrame.frame)
        f:SetPoint("TOPLEFT", self.tblFrame.bClass, "BOTTOMLEFT", 0, -8)
        f:SetPoint("BOTTOMRIGHT", ns.base.tblFrame.status, "TOPRIGHT", -8, 0)
        f:SetShown(true)
        self.tblFrame.resultFrame = f
        self.tblFrame.eSave = nil
        self:CreateResultBox()
    end

    self:_ClearChecks()
    self:CreateCheckBoxes()

    if self.tblFrame.eSave then self.tblFrame.eSave:SetText(fileName) end
    self:UpdateButtonState() -- ensure Delete reflects activeFilter
end
function filters:RefreshFilterDropdown()
    local drop = self.tblFrame and self.tblFrame.dropFilter and self.tblFrame.dropFilter.frame
    if not drop then return end

    local tblPresort = {}
    for k, v in ipairs(ns.gFilterList or {}) do
        tinsert(tblPresort, { description = v.name, id = k })
    end
    self.tblSorted = ns.code:sortTableByField(tblPresort or {}, 'description', false)

    drop.entries = self.tblSorted
    UIDropDownMenu_SetSelectedID(drop, nil)
    UIDropDownMenu_SetText(drop, L['SELECT_FILTER'])

    if drop.initialize then
        UIDropDownMenu_Initialize(drop, drop.initialize)
    end
end

function filters:LoadDropdownList()
    local f = self.tblFrame.frame
    if not f then return end

    local filterSelected = {
        onSelect = function(id)
            filters.activeFilter = id
            local filter = ns.gFilterList and ns.gFilterList[id]
            if not filter then
                ns.code:updateStatusText(L['FILTER_LOAD_ERROR'], { r=1, g=0, b=0, a=1 })
                C_Timer.After(5, function() ns.code:updateStatusText() end)
                filters.activeFilter = nil
                return
            end

            -- Set mode to the filter's type
            filters.filtering = filter.type or 'CLASS'

            -- Preload selection tables by **numeric** ID
            filters.tblFilter = filters.tblFilter or {}
            local crit = filter.criteria or {}

            if filters.filtering == 'CLASS' then
                filters.tblFilter.class = {}
                for id2, v in pairs(crit) do
                    if v then filters.tblFilter.class[tonumber(id2) or id2] = true end
                end
                filters.tblFilter.race = filters.tblFilter.race or {}
            else
                filters.tblFilter.race = {}
                for id2, v in pairs(crit) do
                    if v then filters.tblFilter.race[tonumber(id2) or id2] = true end
                end
                filters.tblFilter.class = filters.tblFilter.class or {}
            end

            -- Force rebuild even if staying on same tab (prevents early-return)
            filters.tblFilterOld = nil
            filters:ChangeFiltering()

            -- Set name box and refresh buttons
            if filters.tblFrame and filters.tblFrame.eSave then
                filters.tblFrame.eSave:SetText(filter.name or '')
            end
            filters:UpdateButtonState()
        end
    }

    local tblPresort = {}
    for k, v in ipairs(ns.gFilterList or {}) do
        tinsert(tblPresort, { description = v.name, id = k })
    end
    self.tblSorted = ns.code:sortTableByField(tblPresort or {}, 'description', false)

    local dropInvite = ns.dropdown:new(
        'GR_Filter_Dropdown',
        f,
        210,
        L['SELECT_FILTER'],
        self.tblSorted,
        filterSelected
    )
    dropInvite.frame:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -3)
    self.tblFrame.dropFilter = dropInvite
end
function filters:ResetUI(clearName)
    self.activeFilter = nil
    self.tblFilter = { class = {}, race = {} }

    if clearName and self.tblFrame and self.tblFrame.eSave then
        self.tblFrame.eSave:SetText('')
    end

    if self.tblFrame and self.tblFrame.dropFilter and self.tblFrame.dropFilter.frame then
        UIDropDownMenu_SetSelectedID(self.tblFrame.dropFilter.frame, nil)
        UIDropDownMenu_SetText(self.tblFrame.dropFilter.frame, L['SELECT_FILTER'])
    end

    if self.tblFrame and self.tblFrame.checkContainer then
        local c = self.tblFrame.checkContainer
        for _, child in ipairs({ c:GetChildren() }) do
            child:Hide(); child:SetParent(nil)
        end
        c._checks = nil
        c:Hide(); c:SetParent(nil)
        self.tblFrame.checkContainer = nil
        self.tblFrame.class = nil
    end

    if self.tblFrame and self.tblFrame.resultFrame then
        self:CreateCheckBoxes()
    end

    self:UpdateButtonState()
end