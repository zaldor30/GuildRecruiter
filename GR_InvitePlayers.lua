local _, ns = ... -- Namespace (myaddon, namespace)
local AceGUI = LibStub("AceGUI-3.0")

local fInvite = nil
local tblFound, tblInvite, tblKeySent = {}, {}
local lblProgress = AceGUI:Create('Label')
local foundCount, isRunning = 0, false
local cInvited = 0

local function SendInvites()
    cInvited = cInvited + 1
    print('Sending Invite', cInvited, tblInvite[cInvited].old.name)
    lblProgress:SetText(cInvited..' of the '..foundCount..' has been invited.')
    if cInvited < foundCount and isRunning then
        local percent = FormatPercentage(cInvited / foundCount,1)
        fInvite:SetStatusText('Sending Invites, '..percent..' complete.')
        C_Timer.After(1, SendInvites)
    else
        lblProgress:SetText('Sent '..cInvited..' invites to players.')
        fInvite:SetStatusText('Messages sent, press close.')
    end
end

function ns:InvitePlayers(tbl)
    local dropdown, editBox, label = nil, nil, nil
    global, profile = ns.db.global, ns.db.profile

    tblFound = tbl or {}

    foundCount, cInvited = 0, 0
    for _ in pairs(tblFound) do foundCount=foundCount+1 end

    -- Base Frame of the Main Screen
    fInvite = AceGUI:Create('Frame')
    fInvite:SetLayout('flow')
    fInvite:SetTitle('Guild Recruiter')
    fInvite:SetStatusText('Invite Players, Waiting...')
    fInvite:EnableResize(false)
    fInvite:SetWidth(400)
    fInvite:SetHeight(160)
    fInvite:SetCallback('OnClose', function()
        isRunning = false
        ns.scannerFrame:Show()
        ns:ScannerReturned(tblFound)
        fInvite:Release()
    end)

    local container = AceGUI:Create("InlineGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(false)
    container:SetLayout("Flow")
    fInvite:AddChild(container)

    lblProgress:SetText(cInvited..' of the '..foundCount..' has been invited.')
    lblProgress:SetFont(DEFAULT_FONT, 16, 'OUTLINE')
    lblProgress:SetFullWidth(true)
    container:AddChild(lblProgress)

    local btnSend = AceGUI:Create('Button')
    btnSend:SetFullWidth(true)
    btnSend:SetText('Invite Player(s)')
    btnSend:SetCallback('OnClick', function(_,_)
        btnSend:SetDisabled(true)
        for k,r in pairs(tblFound) do
            tblInvite[#tblInvite+1] = {
                old = r,
                sent = false,
            }
        end

        isRunning = true
        SendInvites()
    end)
    fInvite:AddChild(btnSend)
end