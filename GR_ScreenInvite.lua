local _, ns = ... -- Namespace (myaddon, namespace)
local AceGUI = LibStub("AceGUI-3.0")
local p,g = nil, nil

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
end
function is:SendInvitesOut()
    local msg, sendInvite = nil, false
    if p.inviteFormat ~= 2 and p.activeMessage then
        msg = ns.code:GuildReplace(g.messages[p.activeMessage].message)
    end
    sendInvite = p.inviteFormat ~= 1 and true or false

    function is:invitePlayers(guildMessage, skipTimer)
        if not self.isRunning then return end

        local k = next(self.tblFound)
        local tbl = self.tblFound[k] or nil
        if tbl then self.tblFound[k] = nil end
        if tbl then
            ns.Invite:invitePlayer(k, guildMessage, sendInvite, false, tbl.class)

            self.invitedCount = self.invitedCount + 1
            local percent = FormatPercentage(self.invitedCount / self.foundCount, 1)
            self.lblProgress:SetText(self.invitedCount..' of the '..self.foundCount..' has been invited.')
            self.fInvite:SetStatusText('Sending Invites, '..percent..' complete.')

            local function restart() is:invitePlayers(guildMessage) end
            local function enableButton() self.btnSend:SetDisabled(false) end
            if not skipTimer then C_Timer.After(1, restart)
            elseif skipTimer then C_Timer.After(.5, enableButton) end
        else
            self.isRunning = false
            self.lblProgress:SetText('Sent '..self.invitedCount..' invites to players.')
            self.fInvite:SetStatusText('Messages sent, press close.')
            self.invitedCount = 0
        end
    end

    is:invitePlayers(msg, sendInvite)
end
function is:StartScreenInvite(tbl)
    p,g = ns.db.profile, ns.db.global
    self.tblFound = tbl or {}
    self.foundCount, self.invitedCount = 0, 0
    for _ in pairs(self.tblFound) do self.foundCount = self.foundCount + 1 end

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