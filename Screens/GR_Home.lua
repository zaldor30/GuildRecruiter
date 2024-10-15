local addonName, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.home = {}
local home = ns.home

function home:Init()
    self.tblFrame = {}

    -- Holding Tables
    self.tblFilters = {}
    self.tblWhispers = {}

    self.minLevel = ns.MAX_CHARACTER_LEVEL - 5 -- Default Min Level
    self.maxLevel = ns.MAX_CHARACTER_LEVEL -- Default Max Level

    self.tblFormat = {
        [1] = L['MESSAGE_ONLY'],
        [2] = L['GUILD_INVITE_ONLY'],
        [3] = L['GUILD_INVITE_AND_MESSAGE'],
        [4] = L['MESSAGE_ONLY_IF_INVITE_DECLINED'],
    }
end
function home:IsShown() return (self.tblFrame and self.tblFrame.frame) and self.tblFrame.frame:IsShown() or false end
function home:SetShown(val)
    if not val and not self:IsShown() then return
    elseif not val then
    end

    if not self.tblFrame or not self.tblFrame.frame then
        self:Init()

        self:CreateBaseFrame()
    end
end
function home:CreateBaseFrame()
    local baseFrame = ns.base.tblFrame
    local f = ns.frames:CreateFrame("Frame", "GR_HomeFrame", baseFrame.frame, true)
    f:SetPoint("TOPLEFT", baseFrame.icon, "BOTTOMLEFT", 5, 0)
    f:SetPoint("BOTTOMRIGHT", baseFrame.status, "TOPRIGHT", -5, 0)
    f:SetBackdropColor(0,0,0,0)
    f:SetBackdropBorderColor(0,0,0,0)
    self.tblFrame.frame = f

    local entries = {
        { id = 1, description = "Option One" },
        { id = 2, description = "Option Two" },
        { id = 3, description = "Option Three" },
        { id = 4, description = "Option Four" },
    }
    local options = {
        onSelect = function(id, description)
            print("Selected ID:", id, "Description:", description)
            -- Save the selection
            MyAddonSettings.selectedFilterID = id
        end
    }
    local dropFilters = ns.dropdown:new(
        'GR_Filter_Dropdown', -- Name of the dropdown frame
        f,          -- Parent frame
        200,                  -- Width of the dropdown
        'Select a filter.',   -- Default text
        entries,              -- Entries for the dropdown
        options              -- Additional options (callbacks)
    )

    -- Position the dropdown within the parent frame
    dropFilters.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -30)
end