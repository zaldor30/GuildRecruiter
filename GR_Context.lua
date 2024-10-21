-- Create the custom menu frame
local myMenuFrame = CreateFrame("Frame", "MyCustomMenuFrame", UIParent, "UIDropDownMenuTemplate")

-- Ensure EasyMenu is defined (if not already)
if not EasyMenu then
    function EasyMenu(menuList, menuFrame, anchor, x, y, displayMode)
        if not menuFrame then
            menuFrame = CreateFrame("Frame", "EasyMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end
        UIDropDownMenu_Initialize(menuFrame, function(self, level, menuList)
            for _, item in ipairs(menuList) do
                UIDropDownMenu_AddButton(item, level)
            end
        end, displayMode, nil, menuList)
        menuFrame.displayMode = displayMode
        ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList)
    end
end

-- Create a frame to catch clicks outside the menu
local clickCatcher = CreateFrame("Button", nil, UIParent)
clickCatcher:SetFrameStrata("DIALOG")
clickCatcher:SetAllPoints(UIParent)
clickCatcher:EnableMouse(true)
clickCatcher:Hide()
clickCatcher:SetScript("OnClick", function(self, button)
    if myMenuFrame then
        myMenuFrame:SetShown(false)
    end
    self:SetShown(false)
end)

-- Function to adjust menu position
local function AdjustMenuPosition()
    local dropdownList = _G["DropDownList1"]
    if dropdownList and dropdownList:IsShown() then
        -- Get the menu's width and height
        local menuWidth = dropdownList:GetWidth()
        local menuHeight = dropdownList:GetHeight()
        local screenHeight = UIParent:GetHeight()

        -- Get the cursor position
        local cursorX, cursorY = GetCursorPosition()
        local uiScale = UIParent:GetEffectiveScale()
        cursorX = cursorX / uiScale
        cursorY = cursorY / uiScale

        -- Adjust the position
        dropdownList:ClearAllPoints()
        if (cursorX - menuWidth) < 0 then
            -- Menu would go off the left side, so move it up by the height of the menu
            local newY = cursorY + menuHeight

            -- Ensure the menu doesn't go off the top of the screen
            if newY > screenHeight then
                newY = screenHeight
            end

            dropdownList:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", cursorX, newY)
        else
            -- Normal position
            dropdownList:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", cursorX, cursorY)
        end

        -- Ensure the menu stays on screen
        dropdownList:SetClampedToScreen(true)

        -- Remove the OnUpdate script after adjusting position
        myMenuFrame:SetScript("OnUpdate", nil)
    end
end

-- Function to show the custom menu at the cursor position
local function ShowCustomMenu(name)
    local myMenu = {
        {
            text = "My Custom Option",
            func = function()
                print("Custom option clicked for " .. name)
                myMenuFrame:Hide()
                clickCatcher:Hide()
            end,
            notCheckable = true,
        },
        {
            text = "Invite to Group",
            func = function()
                InviteUnit(name)
                myMenuFrame:Hide()
                clickCatcher:Hide()
            end,
            notCheckable = true,
        },
        {
            text = "Cancel",
            func = function()
                myMenuFrame:Hide()
                clickCatcher:Hide()
            end,
            notCheckable = true,
        },
    }

    -- Initialize and display your custom menu at the cursor position
    EasyMenu(myMenu, myMenuFrame, "cursor", 0, 0, "MENU")

    -- Adjust the menu position immediately
    myMenuFrame:SetScript("OnUpdate", AdjustMenuPosition)

    -- Show the click catcher frame
    clickCatcher:Show()
end

-- Function to handle right-clicking player names in chat
local function OnHyperlinkShow(self, link, text, button)
    local linkType, name = link:match("^(.-):(.*)")
    if button == "RightButton" and linkType == "player" then
        -- Show your custom menu
        ShowCustomMenu(name)
        -- Call the default handler to show the Blizzard menu
        SetItemRef(link, text, button, self)
    else
        -- Call the default handler for other clicks
        SetItemRef(link, text, button, self)
    end
end

-- Hook into all chat frames to handle hyperlink clicks
for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame" .. i]
    frame:SetScript("OnHyperlinkClick", OnHyperlinkShow)
end
