-- Handles whether or not player should be invited and saved for later
local _, ns = ... -- Namespace (myaddon, namespace)
local global, dbInv = nil, nil

local ip, tblInvited = nil, {}
local tblExpireLength = {
    [7] = 604800,
    [30] = 2592000,
    [90] = 7776000,
}
local invitedPlayers = {
    new = function() return { playerName = nil, invitedBy = nil, invitedOn = nil} end,
    save = function(pName, class)
        if not pName then return
        elseif not tblInvited[pName] then tblInvited[pName] = ip.new() end

        tblInvited[pName] = {
            playerName = pName,
            playerClass = class or '',
            playerRealm = GetRealmName(),
            invitedBy = UnitGUID('player'),
            invitedOn = GetTime(),
        }
        dbInv.invitedPlayers = tblInvited
    end,
    get = function(pName) return tblInvited[pName] end,
    loadData = function() return (dbInv and dbInv.invitedPlayers or ip.new()) end,
    saveToDB = function() dbInv.invitedPlayers = tblInvited end,
}
ip = invitedPlayers
tblInvited = ip.loadData()

function ns:DoMaintenance()
    if not ns.db.global then return end
    global, dbInv = ns.db.global, ns.dbInv.global

    tblInvited = ip.loadData()
    local lastMaint = global.lastMaintance or 0
    if lastMaint + 3600 < GetTime() then ns:MaintenanceDone() return end

    global.lastMaintance = GetTime()
    local clearTime = global.rememberTime and tblExpireLength[global.rememberTime] or tblExpireLength[7]

    for _, r in pairs(tblInvited) do
        if GetTime() - r.invitedOn > clearTime then r = nil end
    end

    ip.saveToDB()
    ns:MaintenanceDone()
end

function ns:IsPlayerAddOK(pName, zoneName)
    local bl = ns.dbBl.global or nil

    if not pName then return false
    elseif tblInvited[pName] then return false
    elseif GR_INSTANCE_ZONE_NAME[zoneName] then return false
    elseif bl and bl.blackList[pName] then return false
    else return true end
end
function ns:sentInvite(pName, class)
    ip.save(pName, class)
    ip.saveToDB()
end