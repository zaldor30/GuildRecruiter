-- Application Initialization
local _, ns = ... -- Namespace (myaddon, namespace)

GRADDON = LibStub('AceAddon-3.0'):NewAddon('GuildRecruiter', 'AceConsole-3.0', 'AceEvent-3.0')
GRADDON.playerFaction = UnitFactionGroup('player') == 'Horde' and 2 or 1
GRADDON.version = GetAddOnMetadata('GuildRecruiter', 'Version')
GRADDON.db = nil
GRADDON.bl = nil
GRADDON.ps = nil
GRADDON.realmID = GetRealmID()
GRADDON.whoQuery = {}
GRADDON.classInfo = {
	WARRIOR = {fClass = 'Warrior', color = 'ffc79c6e'},
	PALADIN = {fClass = 'Warrior', color = 'fff58cba'},
	HUNTER = {fClass = 'Warrior', color = 'ffabd473'},
	ROGUE = {fClass = 'Warrior', color = 'fffff569'},
	PRIEST = {fClass = 'Warrior', color = 'ffffffff'},
	DEATHKNIGHT = {fClass = 'Warrior', color = 'ffc41f3b'},
	SHAMAN = {fClass = 'Warrior', color = 'ff0070de'},
	MAGE = {fClass = 'Warrior', color = 'ff3fc7eb'},
	WARLOCK = {fClass = 'Warrior', color = 'ff8788ee'},
	MONK = {fClass = 'Warrior', color = 'ff00ff96'},
	DRUID = {fClass = 'Warrior', color = 'ffff7d0a'},
	DEMONHUNTER = {fClass = 'Warrior', color = 'ffa330c9'},
	EVOKER = {fClass = 'Warrior', color = 'ff308a77'},
}

-- Context Menu Creation for Guild Invite/Black List
AceEvent, AceGUI = LibStub("AceEvent-3.0"), LibStub('AceGUI-3.0')
AceEvent.UnregisterAllEvents('GuildRecruiter')
local function HandlesGlobalMouseEvent(self, button, event)
	if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton')then
		return true
	end
	return false
end
local f = AceGUI:Create('InlineGroup')
f:SetWidth(135)
f:SetLayout('flow')

local invite = AceGUI:Create('InteractiveLabel')
invite:SetText('Guild Invite')
invite:SetWidth(135)
invite:SetFont('Fonts\\FRIZQT__.ttf', 12, 'OUTLINE')
invite:SetHighlight(255,255,255,125)
invite.frame.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
invite:SetCallback('OnClick', function()
	if f.name then ns.code.InviteToGuild(f.name) end
	CloseDropDownMenus()
end)
invite:SetPoint('TOPLEFT', f.frame, 'TOPLEFT', 0, 0)
f:AddChild(invite)

local blacklist = AceGUI:Create('InteractiveLabel')
blacklist:SetText('Black List')
blacklist:SetWidth(135)
blacklist:SetFont('Fonts\\FRIZQT__.ttf', 12, 'OUTLINE')
blacklist:SetHighlight(255,255,255,125)
blacklist.frame.HandlesGlobalMouseEvent = HandlesGlobalMouseEvent
blacklist:SetCallback('OnClick', function()
	if f.name then ns:AddBlackList(f.name) end
	CloseDropDownMenus()
end)
blacklist:SetPoint('TOPLEFT', invite.frame, 'BOTTOMLEFT', 0, 0)
f:AddChild(blacklist)

local function DropDownOnShow(self)
	local dropdown = self.dropdown
	if not dropdown then return end

	f.frame:SetParent(self)
	f.frame:SetFrameStrata(self:GetFrameStrata())
	f.frame:SetFrameLevel(self:GetFrameLevel() + 2)
	f:ClearAllPoints()

	if dropdown.Button == LFGListFrameDropDownButton then
	elseif dropdown.which then -- UnitPopup
		local dropdownFullName = nil
		if dropdown.name then
			if dropdown.server and not dropdown.name:find('-') then
				dropdownFullName = dropdown.name .. '-' .. dropdown.server
			else dropdownFullName = dropdown.name end
		end
		f.name = dropdownFullName
	else return end

	if self:GetLeft() >= self:GetWidth() then f:SetPoint('TOPRIGHT', self, 'TOPLEFT',0,0)
	else f:SetPoint('TOPLEFT', self, 'TOPRIGHT',0,0) end
	f.frame:Show()
end
local function DropDownOnHide()
	f.frame:Hide()
end

DropDownList1:HookScript('OnShow', DropDownOnShow)
DropDownList1:HookScript('OnHide', DropDownOnHide)