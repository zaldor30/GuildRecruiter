-- Handle all invite routines
local _, ns = ... -- Namespace (myaddon, namespace)
local p,g = nil, nil

ns.Invite = {}
local invite = ns.Invite
function invite:Init()
    self.tblInvited = nil
end
function invite:updateDB() p,g = ns.dbInv.profile, ns.dbInv.global end
function invite:new(class)
    return {
        ['playerClass'] = class or '',
        ['invitedBy'] = UnitGUID('player'),
        ['invitedOn'] = GetTime(),
    }
end
function invite:load()
    invite:updateDB()
    self.tblInvited = p.invitedPlayers or {}
end
function invite:save()
    invite:updateDB()
    p.invitedPlayers = self.tblInvited
end
function invite:canAddPlayer(pName, zone, showError, force)
    if not pName then return false
    elseif not self.tblInvited then invite:load() end

    local canAddPlayer = nil
    if not force and self.tblInvited[pName] then canAddPlayer = 'INVITED'
    --elseif ns.BlackList:isOnBlackList(pName) then canAddPlayer = 'BLACKLIST'
    elseif zone and ns.datasets.tblBadZones[zone] then canAddPlayer = 'ZONE' end

    if not showError and not canAddPlayer then return true
    elseif not canAddPlayer then return true
    elseif canAddPlayer == 'INVITED' then ns.code:consoleOut(pName..' has been invited recently.')
    elseif canAddPlayer == 'BLACKLIST' then ns.code:consoleOut(pName..' has been black listed, remove before inviting.')
    elseif canAddPlayer == 'ZONE' then ns.code:consoleOut(pName..' is in an instanced zone.') end
end
function invite:logInvite(pName, class)
    if not self.tblInvited then invite:load() end
    class = class or select(2, UnitClass(pName))
    if pName and class and not self.tblInvited[pName] then
        ns.Analytics:add('Invited_Players')
        self.tblInvited[pName] = invite:new()
    end
end
function invite:invitePlayer(pName, msg, sendInvite, force, class)
    if not pName then return end

    class = class and class or select(2, UnitClass(pName))
    if invite:canAddPlayer(pName, class) then
        if msg then SendChatMessage(msg, 'WHISPER', nil, pName) end
        if sendInvite then
            local aceGUI = LibStub("AceGUI-3.0")
            local label = aceGUI:Create('Label')
            GRADDON:hooksecureHook(label, function() print('SENT INVITE') GuildInvite(pName) end)
            GRADDON:Unhook(label)
        end

    end
end
invite:Init()