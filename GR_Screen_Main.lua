local _, ns = ... -- Namespace (myaddon, namespace)
local aceGUI = LibStub("AceGUI-3.0")

ns.main = {}
local main = ns.main
function main:Init()
    -- AceGUI Widgets
    self.aMain = nil --Simple Group Frame
    self.inLine = nil
    self.fPreview = nil

    self.btnScan = aceGUI:Create('Button')
    self.filterDrop = aceGUI:Create('Dropdown')
    self.lblPreview = nil
    self.cmbMessages = aceGUI:Create('Dropdown')

    self.tblMessages = {}
    self.min = nil
    self.max = nil

    self.tblFormat = {
        [1] = 'Message ONLY',
        [2] = 'Guild Invite ONLY',
        [3] = 'Guild Invite and Message',
        --[4] = 'Message Only if Invitation is declined',
    }
end
function main:ScannerSettingsLayout()
    ns.screen.fMain:SetSize(500, 255)
    ns.screen:ResetMain()

    ns.screen.iconBack:Hide()
    ns.screen.iconReset:Hide()
    ns.screen.iconCompact:Hide()
    ns.screen.iconRestore:Hide()
    ns.screen:UpdateLastSync()

    local inline = aceGUI:Create('InlineGroup')
    inline:SetLayout('Flow')
    inline:SetWidth(ns.screen.fMain:GetWidth() - 20)
    inline:SetHeight(350)
    ns.screen.aMain:AddChild(inline)
    self.inLine = inline

    local msgDrop = aceGUI:Create('Dropdown') -- Select invite type
    if not msgDrop then aceGUI:Create('Dropdown') end
    msgDrop:SetLabel('Recruit Invite Format:')
    msgDrop:SetRelativeWidth(.5)
    msgDrop:SetList(self.tblFormat)
    msgDrop:SetValue(ns.db.settings.inviteFormat or 2)
    msgDrop:SetCallback('OnValueChanged', function(_, _, val)
        ns.db.settings.inviteFormat = tonumber(val)

        main:CreatePreview()
        main:SetButtonStates()
    end)
    inline:AddChild(msgDrop)

    ns.widgets:createPadding(inline, .03)

    local editBox = aceGUI:Create('EditBox') -- Minimum level for filter
    editBox:SetLabel('Min Level')
    editBox:SetText(ns.db.settings.minLevel)
    editBox:SetMaxLetters(2)
    editBox:SetRelativeWidth(.13)
    editBox:SetCallback('OnEnterPressed', function(widget,_, val)
        local maxLevel = ns.db.settings.maxLevel and tonumber(ns.db.settings.maxLevel) or MAX_CHARACTER_LEVEL
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        local min = tonumber(val:trim()) or nil
        if not min then error = true
        elseif min > maxLevel then error = true msg = 'You must enter a minimum level that is less than max level.'
        elseif not min or (min < 1 or min > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(ns.db.settings.minLevel or '1')
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else ns.db.settings.minLevel = val:trim() or nil end
        self.min = ns.db.settings.minLevel or 1
    end)
    inline:AddChild(editBox)
    self.min = ns.db.settings.minLevel or 1

    ns.widgets:createPadding(inline, .02)

    local editBoxMax = aceGUI:Create('EditBox') -- Maximum level for filter
    editBoxMax:SetLabel('Max Level')
    editBoxMax:SetText(ns.db.settings.maxLevel)
    editBoxMax:SetMaxLetters(2)
    editBoxMax:SetRelativeWidth(.13)
    editBoxMax:SetCallback('OnEnterPressed', function(widget,_, val)
        local minLevel = ns.db.settings.minLevel and tonumber(ns.db.settings.minLevel) or 1
        local error, msg = false, 'You must enter a number between 1 and '..tostring(MAX_CHARACTER_LEVEL)

        local max = tonumber(val:trim()) or nil
        if not max then error = true
        elseif max <= minLevel then error = true msg = 'Your max level must be equal or larger then minimum.'
        elseif not max or (max < 1 or max > MAX_CHARACTER_LEVEL) then error = true end

        if error then
            widget:SetText(ns.db.settings.maxLevel or tostring(MAX_CHARACTER_LEVEL))
            UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
        else ns.db.settings.maxLevel = val:trim() or nil end
        self.max = ns.db.settings.maxLevel or MAX_CHARACTER_LEVEL
    end)
    inline:AddChild(editBoxMax)
    self.max = ns.db.settings.maxLevel or MAX_CHARACTER_LEVEL

    ns.widgets:createPadding(inline, .03)
    self.btnScan:SetText('Start') -- Scan button
    self.btnScan:SetRelativeWidth(.15)
    self.btnScan:SetCallback('OnClick', function()
        ns.screen.status:SetText('')
        local msgID = ns.db.messages.activeMessage
        local msg = self.tblMessages[msgID] and self.tblMessages[msgID].message or nil
        ns.scanner:StartScanner(msg, self.min, self.max)
        self.fPreview:Hide()
    end)
    inline:AddChild(self.btnScan)

    main:GetMessageList()
    main:FilterList()
    main:MessagePreview()
end
function main:SetButtonStates()
    local db = ns.db
    local msgID = db.messages.activeMessage
    local msg = self.tblMessages[msgID] and self.tblMessages[msgID].message or nil
    local invFormat = db.settings.inviteFormat

    if (not msgID or not msg) and invFormat ~= 2 then
        self.btnScan:SetDisabled(true)
        ns.screen.status:SetText(ns.code:cText('FFFF0000', 'Select message or create one in settings.'))
        return
    else self.btnScan:SetDisabled(false) end
    if ns.screen.status:GetText() and string.match(ns.screen.status:GetText(), 'Select message') then ns.screen.status:SetText('') end
end

function main:GetMessageList()
    local tbl, mCount = {}, 0
    local db, dbMsg = ns.db, ns.db.messages

    local msgDrop = aceGUI:Create('Dropdown') -- Select invite type
    msgDrop:SetLabel('Message to recruit:')
    msgDrop:SetRelativeWidth(.5)

    if dbMsg then
        local hasGuildLink = ns.dbGlobal.guildLink or false

        ns.datasets:AllMessages()
        for k, r in pairs(ns.datasets.tblAllMessages or {}) do
            local gLinkFound = strfind(r.message, 'GUILDLINK') or false
            if not gLinkFound or (gLinkFound and hasGuildLink)  then
                if not r.gmMessage then tbl[k] = r.desc
                elseif r.gmMessage then tbl[k] = ns.code:cText('FFAF640C', r.desc) end
                self.tblMessages[k] = { desc = r.desc, message = r.message }
            elseif not hasGuildLink and gLinkFound and k == dbMsg.activeMessage then dbMsg.activeMessage = nil end
        end

        for _ in pairs(self.tblMessages) do mCount = mCount + 1 end

        dbMsg.activeMessage = (dbMsg.activeMessage and self.tblMessages[dbMsg.activeMessage]) and dbMsg.activeMessage or nil
    end

    msgDrop:SetList(tbl)
    msgDrop:SetValue(dbMsg.activeMessage or nil)
    msgDrop:SetDisabled(mCount == 0 or false)
    msgDrop:SetCallback('OnValueChanged', function(_,_, val)
        dbMsg.activeMessage = val

        main:CreatePreview()
        main:SetButtonStates()
    end)

    self.cmbMessages = msgDrop
    self.inLine:AddChild(msgDrop)

    main:SetButtonStates()
end
function main:FilterList() -- Add 10 to custom index to compensate for defaults
    local dropdown = aceGUI:Create('Dropdown')
    dropdown:SetLabel('Filters:')
    dropdown:SetRelativeWidth(.5)
    dropdown:SetCallback('OnValueChanged', function(_, _, val) ns.db.filter.activeFilter = (val == 0 and 99 or val) end)

    local db = ns.db
    local tbl = {
        [1] = 'Default Class Filter',
        [2] = 'Default Race Filter',
    }
    for k, r in pairs(db.filter.filterList or {}) do tbl[k+10] = r.desc end

    db.filter.activeFilter = (not db.filter or not db.filter.activeFilter) and 1 or (db.filter.activeFilter == 99 and 1 or (db.filter.activeFilter or 1))
    dropdown:SetList(tbl)
    dropdown:SetValue(db.filter.activeFilter)
    self.filterDrop = dropdown

    self.inLine:AddChild(dropdown)
end
function main:MessagePreview()
    local f = CreateFrame('Frame', 'Message_Preview_Frame', ns.screen.fMain, 'BackdropTemplate')
    f:SetSize(ns.screen.fMain:GetWidth() - 18, 50)
    f:SetPoint('BOTTOM', ns.screen.fMain, 'BOTTOM', 0, 20)
    f:SetBackdrop({
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0, 0, 0, .75)
    f:SetBackdropBorderColor(1, 1, 1, .5)
    self.fPreview = f

    local textString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 5, 0) -- Set the text position
    textString:SetText('Message Preview:')
    textString:SetFont(DEFAULT_FONT, 10, 'OUTLINE')
    textString:SetJustifyH('LEFT')

    textString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textString:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -5) -- Set the text position
    textString:SetSize(f:GetWidth() - 10, f:GetHeight() - 10)
    textString:SetText('')
    textString:SetTextColor(1, 1, 1, 1) -- Set the text color (r,g,b,a) values
    textString:SetFont(DEFAULT_FONT, 12, 'OUTLINE')
    textString:SetWordWrap(true)
    textString:SetJustifyH('LEFT')
    self.lblPreview = textString

    main:CreatePreview()
end
function main:CreatePreview()
    local msg = ''
    if ns.db.settings.inviteFormat == 2 then msg = 'No message will be sent. Only guild invite will be sent.'
    else
        local activeMsg = ns.db.messages.activeMessage or nil
        if not activeMsg then msg = ''
        else
            local preview = self.tblMessages[activeMsg].message or nil
            msg = ns.code:cText('FFFF80FF', 'To [')..ns.code.fPlayerName
            msg = msg..ns.code:cText('FFFF80FF', ']: '..(ns.code:GuildReplace(preview, UnitName('player')) or ''))
        end
    end
    self.lblPreview:SetText(msg)
end
main:Init()