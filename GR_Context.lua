local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- Create a custom dropdown menu frame
local customMenuFrame = CreateFrame("Frame", "CustomChatDropdownMenu", UIParent, "UIDropDownMenuTemplate")

-- Function to initialize the custom dropdown menu
local function InitializeCustomMenu(frame, level, menuList)
    if not level or level ~= 1 then return end

    local playerName = frame.targetName
    if not playerName then return end

    local isInGuild, faction = ns.code:isInMyGuild(playerName)
    if faction then return end

    local title = UIDropDownMenu_CreateInfo()
    title = {
        text = playerName,
        isTitle = true,
        fontObject = GameFontHighlightLarge,
        notCheckable = true,
        justifyH = "CENTER"
    }
    UIDropDownMenu_AddButton(title, level)

    -- Add a separator line
    local separator = UIDropDownMenu_CreateInfo()
    separator.text = " " -- No text for the separator
    separator.notCheckable = true
    separator.isTitle = true
    separator.disabled = true
    separator.iconOnly = true
    separator.icon = "Interface\\Common\\UI-TooltipDivider-Transparent" -- Use a built-in divider texture
    separator.iconInfo = {
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
        tSizeX = 0,
        tSizeY = 8,
        tFitDropDownSizeX = true
    }
    UIDropDownMenu_AddButton(separator, level)

    if not isInGuild and faction ~= 'differentFaction' then
        local invNoMessage = UIDropDownMenu_CreateInfo()
        invNoMessage = {
            text = L['GUILD_INVITE_NO_MESSAGE'],
            notCheckable = true,
            func = function()
            end,
        }
        UIDropDownMenu_AddButton(invNoMessage, level)
        local invWelcomeMessage = UIDropDownMenu_CreateInfo()
        invWelcomeMessage = {
            text = L['GUILD_INVITE_WELCOME_MESSAGE'],
            notCheckable = true,
            func = function()
            end,
        }
        UIDropDownMenu_AddButton(invWelcomeMessage, level)

        UIDropDownMenu_AddButton(separator, level)

        local blacklistPlayer = UIDropDownMenu_CreateInfo()
        blacklistPlayer = {
            text = L['BLACKLIST_PLAYER'],
            notCheckable = true,
            func = function()
            end,
        }
        UIDropDownMenu_AddButton(blacklistPlayer, level)
    elseif isInGuild then
        print("Player is in a different guild.")
        local kickPlayerOut = UIDropDownMenu_CreateInfo()
        kickPlayerOut = {
            text = L['KICK_PLAYER_FROM_GUILD'],
            notCheckable = true,
            func = function()
            end,
        }
        UIDropDownMenu_AddButton(kickPlayerOut, level)
    end
end

-- Function to show the custom dropdown menu
local function ShowCustomMenu(name)
    -- Set the name for the menu frame
    customMenuFrame.targetName = name
    UIDropDownMenu_Initialize(customMenuFrame, InitializeCustomMenu, "MENU")

    -- Determine screen width and cursor position to adjust menu placement
    local screenWidth = GetScreenWidth()
    local menuWidth = 150 -- Approximate width of the dropdown menu
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    cursorX = cursorX / uiScale

    local xOffset = 175
    if (cursorX + xOffset + menuWidth) > screenWidth then
        xOffset = -185 -- Position the menu to the left if it would go off the screen
    end

    -- Set the dropdown menu position explicitly and display it
    ToggleDropDownMenu(1, nil, customMenuFrame, "cursor", xOffset, 0)
end

-- Hook the right-click event in chat frames to display the custom menu
for i = 1, NUM_CHAT_WINDOWS do
    local chatFrame = _G["ChatFrame" .. i]
    if chatFrame then
        chatFrame:HookScript("OnHyperlinkClick", function(self, link, text, button)
            if button == "RightButton" then
                local linkType, playerName = strsplit(":", link)
                if linkType == "player" and playerName then ShowCustomMenu(playerName)
                else
                    ns.code:dOut("Link type or player name not valid:", linkType, playerName) -- Debug message
                end
            end
        end)
    end
end
