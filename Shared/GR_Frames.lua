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
        child:Hide()
        child:SetParent(nil)
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
function frames:CreateFrame(frameType, name, parent, useBackdrop, backdropTemplate)
    useBackdrop = type(useBackdrop) == 'string' and true or (useBackdrop or false)
    -- Check if a frame is available in the pool
    local frame = table.remove(FramePool)

    if not frame then
        -- No available frames, create a new one
        frame = CreateFrame(frameType or "Frame", name, parent, useBackdrop and "BackdropTemplate" or nil, frameType)

        -- If using the BackdropTemplate, set up the backdrop
        if useBackdrop then
            frame:SetBackdrop(backdropTemplate or ns.BackdropTemplate())
            frame:SetBackdropColor(0, 0, 0, 0.7)
            frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end
    else
        -- Reuse frame, reset its properties
        frame:SetParent(parent or UIParent)
        frame:SetName(name)
        self:ResetFrame(frame)

        -- Handle BackdropTemplate logic
        if useBackdrop then
            if not frame.SetBackdrop then
                Mixin(frame, BackdropTemplateMixin)  -- Ensure the backdrop is available
            end
            frame:SetBackdrop(backdropTemplate or ns.BACKDROP_TEMPLATE)
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