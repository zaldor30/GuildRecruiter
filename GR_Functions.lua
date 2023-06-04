-- Guild Recruiter Global Functions
local function AnalytecsCode()
    local tbl = {}
    function tbl:Invited()
        print('Invited')
        GRADDON.db.global.invitedPlayers = GRCODE.inc(GRADDON.db.global.invitedPlayers)
        GRADDON.db.global.invitedPlayers = GRCODE.inc(GRADDON.db.profile.invitedPlayers)
    end

    return tbl
end
local Analytecs = AnalytecsCode()

GRCODE = {
    -- Text Routines
    inc = function(data, count)
        print('inc')
        count = count or 1
        data = data and data + count or count
        print(data)
        return data
    end,
    cText = function(color, text) return '|c'..color..text..'|r' end,

    -- Guild Info Routines
    SetGuildInfo = function()
        local clubID = C_Club.GetGuildClubId() or nil
        local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
        if club then
            local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
            GRADDON.db.global.guildInfo = { [UnitGUID('player')] = {clubID = clubID, guildName = gName, guildLink = gLink } }
            return gLink, gName
        end
    end,
    GetGuildInfo = function()
        local clubID = C_Club.GetGuildClubId()
        local gInfo = GRADDON.db.global.guildInfo and GRADDON.db.global.guildInfo[UnitGUID('player')] or nil
        if not gInfo or clubID ~= gInfo.clubID then return nil
        else return gInfo.guildLink, gInfo.guildName end
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
    InviteToGuild = function(playerName)
        if CanGuildInvite() and not GetGuildInfo(playerName) then
            GuildInvite(playerName)
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