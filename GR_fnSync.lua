local _, ns = ... -- Namespace (myaddon, namespace)
local db, dbInv, dbBL = nil, nil, nil
local comPrefix = GRADDON.prefix
local lastSent = GetServerTime() - 60

function GRADDON:OnCommReceived(prefix, message, distribution, sender)
    db, dbInv, dbBL = ns.db.profile, ns.dbInv.global, ns.dbBL.global

    if prefix ~= comPrefix or sender == UnitName('player') then return end
    ns.code:consoleOut('Receiving data with '..sender..'.')
    local success, tblData = GRADDON:Deserialize(message)
    if not success then
        ns.code.consoleOut('Syncing data with other guild members'..ns.code.cText("FFFF0000", 'FAILED')'.')
        return
    end

    local cBL, cBLSkip = 0, 0
    local tblBlackList = dbBL or {}
    for k, r in pairs(tblData.blackList) do
        cBL = cBL + 1
        if tblBlackList[k] then cBLSkip = cBLSkip + 1
        else tblBlackList[k] = r end
    end
    dbBL = tblBlackList

    local cInv, cSkip = 0, 0
    local tblInvited = dbInv.invitedPlayers or {}
    for k, r in pairs(tblData.invitedPlayers) do
        cInv = cInv + 1
        if tblInvited[k] then cSkip = cSkip + 1
        else
            cInv = cInv + 1
            tblInvited[k] = r end
    end
    dbInv.invitedPlayers = tblInvited

    if tblData.guildLink and not db.guildInfo.guildLink then
        db.guildInfo.guildLink = tblData.guildLink
        ns.code:consoleOut('Added a guild link '..db.guildLink..' you can use GUILDLINK now.')
    end

    ns.code:consoleOut('Guild Recruiter just performed a sync.', 'FFFFFF00')
    ns.code:consoleOut(cInv..' invited players found, added '..(cInv-cSkip)..' entries.', 'FFFFFF00')
    ns.code:consoleOut(cBL..' black listed players found, added '..(cBL - cBLSkip)..' entries.', 'FFFFFF00')
    ns.code:consoleOut('End of sync with '..sender, 'FFFFFF00')
    ns:SyncData()
end

function ns:SyncData()
    db, dbInv, dbBL = ns.db.profile, ns.dbInv.global, ns.dbBL.global

    if GetServerTime() - lastSent > 60 then
        ns.code:consoleOut('Prepairing data to be synced with guild members.')
        local dataToSend = {
            blackList = dbBL.blackList or {},
            invitedPlayers = dbInv.invitedPlayers or {},
            guildLink = db.guildInfo.guildLink or nil,
        }

        local serializedData = GRADDON:Serialize(dataToSend)
        ns.code:consoleOut('Sending sync data to guild members.')
        GRADDON:SendCommMessage(comPrefix, serializedData, 'GUILD')
        lastSent = GetServerTime()
    end
end
GRADDON:RegisterComm(comPrefix, 'OnCommReceived')