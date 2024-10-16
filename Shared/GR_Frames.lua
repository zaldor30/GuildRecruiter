local _, ns = ... -- Namespace (myaddon, namespace)

ns.frames = {}
local frames = ns.frames

--* Frame Pooling
local FramePool = {} -- Pool of frames to reuse
-- Function to reset a frame and all of its children
function frames:ResetFrame(frame)
    -- Clear all children
    local numChildren = select("#", frame:GetChildren())
    for i = 1, numChildren do
        local child = select(i, frame:GetChildren())
        if child then
            child:Hide()
            child:SetParent(nil)
        end
    end

    -- Clear any scripts
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEvent", nil)

    -- Reset position
    frame:ClearAllPoints()

    -- Hide the frame
    frame:Hide()
end
-- Function to get a frame from the pool or create a new one
function frames:CreateFrame(frameType, name, parent, backdropTemplate)
    -- Check if a frame is available in the pool
    local frame = table.remove(FramePool)

    if not frame then
        local template = nil
        if frameType == 'Frame' then template = backdropTemplate or "BackdropTemplate"
        elseif frameType == 'Button' and backdropTemplate then template = "UIPanelButtonTemplate"
        elseif frameType == 'EditBox' and backdropTemplate then template = "InputBoxTemplate"
        end
        -- No available frames, create a new one
        frame = CreateFrame(frameType or "Frame", name, parent, template)

        -- If using the BackdropTemplate, set up the backdrop
        if frameType == 'Frame' then
            frame:SetBackdrop(ns.BackdropTemplate())
            frame:SetBackdropColor(0, 0, 0, 0.7)
            frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end
    else
        -- Reuse frame, reset its properties
        frame:SetParent(parent or UIParent)
        frame:SetName(name)
        self:ResetFrame(frame)

        -- Handle BackdropTemplate logic
        if frameType == 'Frame' then
            if not frame.SetBackdrop then
                Mixin(frame, BackdropTemplateMixin)  -- Ensure the backdrop is available
            end
            frame:SetBackdrop(backdropTemplate or ns.BLANK_BACKGROUND)
            frame:SetBackdropColor(0, 0, 0, 0.7)
            frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        else frame:SetBackdrop(nil) end
    end

    frame:Show()
    return frame
end
-- Function to return a frame to the pool
function frames:release(frame)
    self:ResetFrame(frame)
    table.insert(FramePool, frame)
end

local tblFade = {}
function frames:animateAtlas(fontString, newData) frames:CreateAnimation(fontString, newData, 'ATLAS_IMAGE') end
function frames:animateTexture(fontString, newData) frames:CreateAnimation(fontString, newData, 'IMAGE') end
function frames:animateText(fontString, newText) frames:CreateAnimation(fontString, newText, 'TEXT') end
function frames:CreateAnimation(fontString, newData, type)
    -- Check if fadeOutGroup exists; if not, create it
    local fadeOutGroup = tblFade[fontString] and tblFade[fontString].fadeOutGroup
    if not fadeOutGroup then
        fadeOutGroup = fontString:CreateAnimationGroup()
        local fadeOut = fadeOutGroup:CreateAnimation('Alpha')
        fadeOut:SetFromAlpha(1)  -- Start fully visible
        fadeOut:SetToAlpha(0)    -- End fully invisible
        fadeOut:SetDuration(0.5)
        fadeOut:SetSmoothing("OUT")
        tblFade[fontString] = { fadeOutGroup = fadeOutGroup }
    end

    -- Check if fadeInGroup exists; if not, create it
    local fadeInGroup = tblFade[fontString] and tblFade[fontString].fadeInGroup
    if not fadeInGroup then
        fadeInGroup = fontString:CreateAnimationGroup()
        local fadeIn = fadeInGroup:CreateAnimation('Alpha')
        fadeIn:SetFromAlpha(0)  -- Start fully invisible
        fadeIn:SetToAlpha(1)    -- Fade to fully visible
        fadeIn:SetDuration(0.5)
        fadeIn:SetSmoothing("IN")
        tblFade[fontString] = { fadeInGroup = fadeInGroup }
    end

    -- When the fade-out finishes, change the text and start fade-in
    fadeOutGroup:SetScript('OnFinished', function()
        if type == 'TEXT' then fontString:SetText(newData)
        elseif type == 'IMAGE' then fontString:SetTexture(newData)
        elseif type == 'ATLAS_IMAGE' then fontString:SetAtlas(newData) end
        fadeOutGroup:Stop()
        fadeInGroup:Play()           -- Start the fade-in animation
    end)

    -- Immediately trigger fade-out and fade-in for the new text
    fadeOutGroup:Play()
end

--** Frame Constants **--
--* Backdrop Templates
ns.DEFAULT_BORDER = 'Interface\\Tooltips\\UI-Tooltip-Border'
ns.BLANK_BACKGROUND = 'Interface\\Buttons\\WHITE8x8'
ns.DIALOGUE_BACKGROUND = 'Interface\\DialogFrame\\UI-DialogBox-Background'
function ns.BackdropTemplate(bgImage, edgeImage, tile, tileSize, edgeSize, insets)
	tile = tile == 'NO_TILE' and false or true

	return {
		bgFile = bgImage or ns.DIALOGUE_BACKGROUND,
		edgeFile = edgeImage or ns.DEFAULT_BORDER,
		tile = true,
		tileSize = tileSize or 16,
		edgeSize = edgeSize or 16,
		insets = insets or { left = 3, right = 3, top = 3, bottom = 3 }
	}
end

--* Frame Stratas
ns.BACKGROUND_STRATA = 'BACKGROUND'
ns.LOW_STRATA = 'LOW'
ns.MEDIUM_STRATA = 'MEDIUM'
ns.HIGH_STRATA = 'HIGH'
ns.DIALOG_STRATA = 'DIALOG'
ns.TOOLTIP_STRATA = 'TOOLTIP'
ns.DEFAULT_STRATA = ns.BACKGROUND_STRATA

-- *Frame Routines
function frames:Confirmation(msg, func)
    StaticPopupDialogs["MY_YES_NO_DIALOG"] = {
        text = msg,
        button1 = "Yes",
        button2 = "No",
        OnAccept = func,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
    }
    StaticPopup_Show("MY_YES_NO_DIALOG")
end
function frames:AcceptDialog(msg, func)

    StaticPopupDialogs["MY_ACCEPT_DIALOG"] = {
        text = msg,
        button1 = "Ok",
        OnAccept = func,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("MY_ACCEPT_DIALOG")
end

--* Single Level Dropdown
ns.dropdown = ns.dropdown or {}
ns.dropdown.__index = ns.dropdown

-- Dropdown Class Definition
function ns.dropdown:new(name, parent, width, defaultText, entries, options)
    -- Create the dropdown frame using WoW's UIDropDownMenuTemplate
    local dropdownFrame = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdownFrame:SetWidth(width or 150)
    dropdownFrame:SetHeight(30)

    -- Initialize the dropdown menu
    UIDropDownMenu_SetWidth(dropdownFrame, width or 150)
    UIDropDownMenu_SetText(dropdownFrame, defaultText or "Select an option")

    -- Store entries and options for later use
    dropdownFrame.entries = entries or {}
    dropdownFrame.options = options or {}

    -- Function to initialize the dropdown menu
    local function InitializeDropdown(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for index, entry in ipairs(dropdownFrame.entries) do
            info.text = entry.description
            info.value = entry.id
            info.func = function(_, value)
                UIDropDownMenu_SetSelectedID(dropdownFrame, index) -- Set selection by index
                if dropdownFrame.options.onSelect and type(dropdownFrame.options.onSelect) == "function" then
                    dropdownFrame.options.onSelect(entry.id, entry.description)
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    -- Initialize the dropdown with the setup function
    UIDropDownMenu_Initialize(dropdownFrame, InitializeDropdown)

    -- Method to set the selected value programmatically
    function dropdownFrame:SetSelectedValue(id)
        for index, entry in ipairs(self.entries) do
            if entry.id == id then
                UIDropDownMenu_SetSelectedID(self, index)
                break
            end
        end
    end

    -- Method to get the currently selected value
    function dropdownFrame:GetSelectedValue()
        local selectedID = UIDropDownMenu_GetSelectedID(dropdownFrame)
        if selectedID and self.entries[selectedID] then
            return self.entries[selectedID].id, self.entries[selectedID].description
        end
        return nil, nil
    end

    -- Store the frame reference in the object
    local obj = { frame = dropdownFrame }

    setmetatable(obj, ns.dropdown)

    return obj
end
-- Dropdown class definition
function ns.dropdown:new(name, parent, width, defaultText, entries, options)
    -- Create the dropdown frame using WoW's UIDropDownMenuTemplate
    local dropdownFrame = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdownFrame:SetWidth(width or 150)
    dropdownFrame:SetHeight(30)

    -- Initialize the dropdown menu
    UIDropDownMenu_SetWidth(dropdownFrame, width or 150)
    UIDropDownMenu_SetText(dropdownFrame, defaultText or "Select an option")

    -- Store the entries and options in the dropdown object
    dropdownFrame.entries = entries or {}
    dropdownFrame.options = options or {}

    -- Function to initialize the dropdown menu
    local function InitializeDropdown(self, level, menuList)
        for index, entry in ipairs(dropdownFrame.entries) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = entry.description
            info.value = entry.id
            info.func = function()
                UIDropDownMenu_SetSelectedID(dropdownFrame, index) -- Set selection by index
                if dropdownFrame.options.onSelect and type(dropdownFrame.options.onSelect) == "function" then
                    dropdownFrame.options.onSelect(entry.id, entry.description)
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    -- Initialize the dropdown with the setup function
    UIDropDownMenu_Initialize(dropdownFrame, InitializeDropdown)
    dropdownFrame.Text:SetJustifyH("LEFT")

    -- Method to set the selected value programmatically
    function dropdownFrame:SetSelectedValue(id)
        for index, entry in ipairs(self.entries) do
            if entry.id == id then
                UIDropDownMenu_SetSelectedID(self, index)
                break
            end
        end
    end

    -- Method to get the currently selected value
    function dropdownFrame:GetSelectedValue()
        local selectedID = UIDropDownMenu_GetSelectedID(dropdownFrame)
        if selectedID and self.entries[selectedID] then
            return self.entries[selectedID].id, self.entries[selectedID].description
        end
        return nil, nil
    end

    -- Store the frame reference
    local obj = {
        frame = dropdownFrame
    }

    setmetatable(obj, ns.dropdown)

    return obj
end
--? End of Single Level Dropdown