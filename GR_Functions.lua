local _, ns = ... -- Namespace (myaddon, namespace)
code = {
    -- Text Routines
    inc = function(data, count) return (data or 0) + (count or 1) end,
    cText = function(color, text)
        if type(color) ~= 'string' or not text then return end
        return '|c'..color..text..'|r'
    end,
    consoleOut = function(msg) print('|cFF807e14GR: '..msg..'|r') end,

    -- Guild Info Routines
    GetGuildInfo = function()
        local clubID = C_Club.GetGuildClubId()
        local gInfo = p.guildInfo and p.guildInfo[UnitGUID('player')] or nil
        if not gInfo or clubID ~= gInfo.clubID then return nil
        else return (gInfo.guildLink or 'GUILDLINK'), gInfo.guildName end
    end,
    GuildReplace = function(msg)
        local gi = ns.db.profile.guildInfo
        local gLink, gName = gi.guildLink, gi.guildName
        
        if gName and msg then
            msg = gLink and gsub(msg, 'GUILDLINK', gLink and gLink or 'No Guild Link') or msg
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
                    ns.Analytics:analyticsAdd('acceptedInvite')
                    break
                end
            end
            if not nameFound then ns.Analytics:analyticsAdd('declinedInvite') end
        end
        AceTimer:ScheduleTimer(GuildInviteTimer, 60, playerName)
    end,
    InviteToGuild = function(playerName)
        local name = playerName
        local tblBL = ns.dbBl.BlackList or {}
        if not tblBL[playerName] and CanGuildInvite() and not GetGuildInfo(playerName) then
            GuildInvite(playerName) -- Needs to be first
            ns.code.startInviteTimer(name)
            ns.Analytics:analyticsAdd('invitedPlayers')
        elseif tblBL[playerName] then ns.code.consoleOut(playerName..' has been black listed for \"'..tblBL[playerName].reason..'\".') end
    end,

    -- Frame Routines
    createErrorWindow = function(msg)
        local errorDialog = {
            text = msg,
            button1 = 'Okay',
            timeout = 10,
            showAlert = true,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnShow = function(self)
                self:SetPoint("CENTER")
            end,
        }
        StaticPopupDialogs["MY_ERROR_DIALOG"] = errorDialog
        StaticPopup_Show("MY_ERROR_DIALOG")
    end,
    createPadding = function(f, rWidth)
        local widget = LibStub("AceGUI-3.0"):Create('Label')
        if rWidth <=2 then widget:SetRelativeWidth(rWidth)
        else widget:SetWidth(rWidth) end
        f:AddChild(widget)
    end,
}
ns.code = code