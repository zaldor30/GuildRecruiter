-- Handles whether or not player should be invited and saved for later
local _, ns = ... -- Namespace (myaddon, namespace)
local global = ns.db.global or nil

local ip, tblInvited = nil, {}
local tblExpireLength = {
    [7] = 604800,
    [30] = 2592000,
    [90] = 7776000,
}
local invitedPlayers = {
    new = function() return { playerName = nil, invitedBy = nil, invitedOn = nil} end,
    save = function(guid, name)
        if not guid then return
        elseif not tblInvited[guid] then tblInvited[guid] = ip.new() end

        tblInvited[guid] = {
            playerName = name,
            invitedBy = UnitGUID('player'),
            invitedOn = GetTime(),
        }
    end,
    get = function(guid) return tblInvited[guid] end,
    loadData = function() return (global and global.invitedPlayers or ip.new()) end,
    saveToDB = function() dbGlobal.invitedPlayers = tblInvited end,
}
ip = invitedPlayers

function ns:DoMaintenance()
    if not ns.db.global then return end
    global = ns.db.global

    tblInvited = ip.loadData()
    local lastMaint = global.lastMaintance or 0
    if lastMaint + 3600 < GetTime() then ns:MaintenanceDone() return end

    global.lastMaintance = GetTime()
    local clearTime = dbGlobal.rememberTime and tblExpireLength[dbGlobal.rememberTime] or tblExpireLength[7]

    for _, r in pairs(tblInvited) do
        if GetTime() - r.invitedOn > clearTime then r = nil end
    end

    ip.saveToDB()
    ns:MaintenanceDone()
end

function ns:IsPlayerAddOK(guid) return tblInvited[guid] and false or true end
function ns:sentInvite(guid)
    ip.save(guid, select(6, GetPlayerInfoByGUID))
    ip.saveToDB()
end