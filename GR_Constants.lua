-- Guid Recruiter Constants
GR_LIBSTUB = LibStub('LibDBIcon-1.0')
MAX_CHARACTER_LEVEL = 70
GR_SCAN_WAIT_TIME = 5

GR_INSTANCE_ZONES = {
    --battlegrounds
		2597,
		6665,
		3358,
		4710,
		4384,
		3820,
		8485,
		6126,
		3277,
		5449,
		5031,
		7107,
		9136,
		6051,
		10176,
	--arenas
		8008,
		4406,
		6732,
		3968,
		4378,
		7816,
		6296,
		3698,
		3702,
		8624,
		14436,

		--@version-retail@
	--raids
		14663,
		14030,
		14663,
	--dungeons
		14032,
		13991,
		14082,
		14011,
		14063,
		13954,
		13982,
		13968,
		--M+ rotating
		9391,
		7546,
		8093,
}

-- Namespaces
GR_NAMESPACES = {}

-- Dialogue Boxes
local AceGUI = LibStub('AceGUI-3.0')

function INFO_BOX(title, msg, statusText, width, height)
	width = width and width or 400
	height = height and height or 100

	local f = AceGUI:Create('Frame')
	f:SetCallback('OnClose',function(widget) AceGUI:Release(widget) end)
	f:SetTitle(title)
	f:SetStatusText(statusText)
	f:EnableResize(false)
	f:SetLayout('Flow')
	f:SetWidth(width)
	f:SetHeight(height)

	local label = AceGUI:Create('Label')
	label:SetText(msg)
	label:SetWidth(width - 50)
	label:SetFont('Fonts\\FRIZQT__.ttf', 14, 'OUTLINE')
	f:AddChild(label)
end