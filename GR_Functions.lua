-- Guild Recruiter Global Functions
local db = GRADDON.db
local p,g = nil, nil
local Analytecs = nil
local function AnalytecsCode()
    if not db then return end

    local tbl = {}
    -- Guild Invite Analytics Code
    function tbl:playersScanned(amt)
        g.playersScanned = (g.playersScanned or 0) + amt
        p.playersScanned = (p.playersScanned or 0) + amt
    end
    function tbl:Invited()
        g.invitedPlayers = GRCODE.inc(g.invitedPlayers)
        p.invitedPlayers = GRCODE.inc(p.invitedPlayers)
    end
    function tbl:acceptedInvite()
        g.acceptedInvite = GRCODE.inc(g.acceptedInvite)
        p.acceptedInvite = GRCODE.inc(p.acceptedInvite)
    end
    function tbl:declinedInvite()
        g.declinedInvite = GRCODE.inc(g.declinedInvite)
        p.declinedInvite = GRCODE.inc(p.declinedInvite)
    end
    -- Black List Analytics Code
    function tbl:blackListed(remove)
        g.blackListed = GRCODE.inc(g.blackListed, (remove and -1 or 1))
        p.blackListed = GRCODE.inc(p.blackListed, (remove and -1 or 1))
    end

    return tbl
end
function RefreshFNData(data)
    db = data
    p,g = db.profile, db.global
    Analytecs = AnalytecsCode()
end

GRCODE = {
    -- Text Routines
    inc = function(data, count) return (data or 0) + (count or 1) end,
    cText = function(color, text) return '|c'..color..text..'|r' end,

    -- Guild Info Routines
    SetGuildInfo = function()
        local clubID = C_Club.GetGuildClubId() or nil
        local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
        if club then
            local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
            p.guildInfo = { [UnitGUID('player')] = {clubID = clubID, guildName = gName, guildLink = gLink } }
            return gLink, gName
        elseif clubID and C_Club.GetClubInfo(clubID) then
            p.guildInfo = { [UnitGUID('player')] = {clubID = clubID, guildName = C_Club.GetClubInfo(clubID).name, guildLink = nil } }
        end
    end,
    GetGuildInfo = function()
        local clubID = C_Club.GetGuildClubId()
        local gInfo = p.guildInfo and p.guildInfo[UnitGUID('player')] or nil
        if not gInfo or clubID ~= gInfo.clubID then return nil
        else return (gInfo.guildLink or 'GUILDLINK'), gInfo.guildName end
    end,
    GuildReplace = function(msg)
        local gLink, gName = nil, nil
        if GRCODE.GetGuildInfo() then gLink, gName = GRCODE.GetGuildInfo()
        else gLink, gName = GRCODE.SetGuildInfo() end

        if gLink and gName and msg then
            msg = gsub(msg, 'GUILDLINK', gLink and gLink or 'No Guild Link')
            msg = gsub(msg, 'GUILDNAME', gName and '<'..gName..'>' or 'No Guild Name')
            msg = gsub(msg, 'NAME', UnitName('player') or 'Player Name')
        end

        return msg
    end,

    -- Analytecs and Player Interactions
    startInviteTimer = function(playerName)
        local AceTimer = LibStub("AceTimer-3.0")
        local function GuildInviteTimer(name)
            local nameFound = false
            for i=1,GetNumGuildMembers() do
                local gName = GetGuildRosterInfo(i)
                if gName == name then
                    nameFound = true
                    Analytecs:acceptedInvite()
                    break
                end
            end
            if not nameFound then Analytecs:declinedInvite() end
        end
        AceTimer:ScheduleTimer(GuildInviteTimer, 60, playerName)
    end,
    InviteToGuild = function(playerName)
        local name = playerName
        if CanGuildInvite() and not GetGuildInfo(playerName) then
            GuildInvite(playerName) -- Needs to be first
            GRCODE.startInviteTimer(name)
            Analytecs:Invited()
        end
    end,

    -- Frame Routines
    createPadding = function(f, rWidth)
        local widget = LibStub("AceGUI-3.0"):Create('Label')
        widget:SetRelativeWidth(rWidth)
        f:AddChild(widget)
    end,
}