local _, ns = ... -- Namespace (myaddon, namespace)
local AceGUI = LibStub("AceGUI-3.0")
local p,g, dbInv = nil, nil, nil

ns.InviteScreen = {}
local is = ns.InviteScreen
function is:Init()
    self.fInvite = nil
    self.tblFound = {}

    self.foundCount = 0
    self.invitedCount = 0

    self.isRunning = false

    self.btnSend = AceGUI:Create('Button')
    self.lblProgress = AceGUI:Create('Label')

    self.startFound = nil
end
function is:SendInvitesOut()
    local msg, sendInvite = nil, false
    if p.inviteFormat ~= 2 and p.activeMessage then
        msg = ns.code:GuildReplace(g.messages[p.activeMessage].message)
    end
    sendInvite = p.inviteFormat ~= 1 and true or false

    function is:complete()
        self.isRunning = false
        self.lblProgress:SetText('Sent '..self.invitedCount..' invites to players.')
        self.fInvite:SetStatusText('Messages sent, press close.')

        local stored, queue = 0, 0
        for _ in pairs(dbInv.invitedPlayers or {}) do stored = stored + 1 end
        for _ in pairs(self.tblFound or {}) do queue = queue + 1 end
   
        if g.showSystem then
            ns.code:consoleOut('You started with '..self.startFound)
            ns.code:consoleOut('You invited '..self.invitedCount..' players.')
            ns.code:consoleOut('You now have '..stored..' recorded invites.')
            ns.code:consoleOut(queue..' players are still queued for invite.')
        end
        self.invitedCount = 0
    end
    function is:invitePlayers(guildMessage, skipTimer)
        if not self.isRunning then return end

        local k = next(self.tblFound)
        local tbl = self.tblFound[k] or nil
        self.tblFound[k] = nil

        if tbl then
            ns.Invite:invitePlayer(k, guildMessage, sendInvite, false, tbl.class)

            self.invitedCount = self.invitedCount + 1
            local percent = FormatPercentage(self.invitedCount / self.foundCount, 1)
            self.lblProgress:SetText(self.invitedCount..' of the '..self.foundCount..' has been invited.')
            self.fInvite:SetStatusText('Sending Invites, '..percent..' complete.')

            local function restart() is:invitePlayers(guildMessage) end
            local function enableButton() self.btnSend:SetDisabled(false) end

            if next(self.tblFound) then
                if not skipTimer then C_Timer.After(1, restart)
                elseif skipTimer then C_Timer.After(.5, enableButton) end
            else is:complete() end
        else is:complete() end
    end

    is:invitePlayers(msg, sendInvite)
end
function is:StartScreenInvite(tbl)
    p,g, dbInv = ns.db.profile, ns.db.global, ns.dbInv.global
    self.tblFound = tbl or {}
    self.foundCount, self.invitedCount = 0, 0
    for _ in pairs(self.tblFound) do self.foundCount = self.foundCount + 1 end

    self.startFound = 0
    for _ in pairs(dbInv.invitedPlayers or {}) do self.startFound = self.startFound + 1 end

    if self.foundCount > 0 then self.btnSend:SetDisabled(false) else self.btnSend:SetDisabled(true) end
    if not self.fInvite then is:CreateScreenInvite()
    else
        self.fInvite:Show()
        self.lblProgress:SetText(self.invitedCount..' of the '..self.foundCount..' has been invited.')
    end
end
function is:CreateScreenInvite()
    -- Base Frame of the Main Screen
    self.fInvite = AceGUI:Create('Frame')
    self.fInvite:SetLayout('flow')
    self.fInvite:SetTitle('Guild Recruiter')
    self.fInvite:SetStatusText('Invite Players, Waiting...')
    self.fInvite:EnableResize(false)
    self.fInvite:SetWidth(400)
    self.fInvite:SetHeight(160)
    self.fInvite:SetCallback('OnClose', function()
        self.isRunning = false
        is:complete()
        ns.ScreenInvite:StartScreenScanner(self.tblFound)
    end)

    local container = AceGUI:Create("InlineGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(false)
    container:SetLayout("Flow")
    self.fInvite:AddChild(container)

    self.lblProgress:SetText(self.invitedCount..' of the '..self.foundCount..' has been invited.')
    self.lblProgress:SetFont(DEFAULT_FONT, 16, 'OUTLINE')
    self.lblProgress:SetFullWidth(true)
    container:AddChild(self.lblProgress)

    self.btnSend:SetFullWidth(true)
    self.btnSend:SetText('Invite Player(s)')
    self.btnSend:SetCallback('OnClick', function(_,_)
        self.btnSend:SetDisabled(true)
        self.isRunning = true
        is:SendInvitesOut()
    end)
    self.fInvite:AddChild(self.btnSend)
end
is:Init()