-- Guild Recruiter Global Functions
local code = GR_CODE
GR_CODE = {
    -- Text Routines
    cText = function(color, text) return '|c'..color..text..'|r' end,

    -- Guild Info Routines
    SetGuildInfo = function()
        local clubID = C_Club.GetGuildClubId() or nil
        local club = clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or nil
        if club then
            local gName, gLink = club.name, GetClubFinderLink(club.clubFinderGUID, club.name)
            GRDB.global.guildInfo = { [UnitGUID('player')] = {clubID = clubID, guildName = gName, guildLink = gLink } }
            return gLink, gName
        end
    end,
    GetGuildInfo = function()
        local clubID = C_Club.GetGuildClubId()
        local gInfo = GRDB.global.guildInfo and GRDB.global.guildInfo[UnitGUID('player')] or nil
        if not gInfo or clubID ~= gInfo.clubID then return nil
        else return gInfo.guildLink, gInfo.guildName end
    end,
    GuildReplace = function(msg)
        local gLink, gName = nil, nil
        if GR_CODE.GetGuildInfo() then gLink, gName = GR_CODE.GetGuildInfo()
        else gLink, gName = GR_CODE.SetGuildInfo() end

        if gLink and gName and msg then
            msg = gsub(msg, 'GUILDLINK', gLink and gLink or 'No Guild Link')
            msg = gsub(msg, 'GUILDNAME', gName and '<'..gName..'>' or 'No Guild Name')
            msg = gsub(msg, 'NAME', UnitName('player') or 'Player Name')
        end

        return msg
    end,

    -- Frame Routines
    createPadding = function(f, rWidth)
        local widget = LibStub("AceGUI-3.0"):Create('Label')
        widget:SetRelativeWidth(rWidth)
        f:AddChild(widget)
    end,
}