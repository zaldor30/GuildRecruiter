--[[-----------------------------------------------------------------------------
Invite Subsystem
Author: Moonfury
Purpose:
  - Send guild invites and optional messages (guild, whisper, invite) with safe pacing.
  - Track pending invitees with TTL and finalize on accept/decline/error.
  - Work across Retail/Classic/Cata via GLOBAL_STRING pattern matching.

Key Concepts:
  - Full name = "Name-Realm" (always store canonical form).
  - Registry (Invited): holds one record per pending invite with an auto-timeout.
  - System monitoring:
      * Accepts detected by guild roster change (locale-safe).
      * Declines/errors detected by CHAT_MSG_SYSTEM matching localized strings.
  - Whisper queuing uses ns.MQ (no external libs).

Dependencies:
  - AceTimer via `GR:ScheduleTimer` and `GR:CancelTimer`
  - AceLocale-3.0
  - `ns` facilities: ns.MQ, ns.code (dOut/fOut/cOut/variableReplacement), ns.analytics, ns.list, settings
Notes:
  - All maps use case-insensitive keys with `strlower`.
  - Keep one queue instance (`invite.Q`).
-----------------------------------------------------------------------------]]--

local addonName, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.invite = {}
local invite = ns.invite

-- Testing helper: route all invites to a fixed name if testing mode is enabled
local testName = ns.classic and 'Hideme' or 'Monkstrife' -- Whitemane

-- Seconds before a pending invite is considered timed out
local INVITE_TIME_OUT = 120

--=============================================================================
-- Init & Configuration
--=============================================================================
function invite:Init()
    -- Mirrors of the core registry for easy external access and debug
    self.tblInvited = {}          -- [FullName] = InvitedRecord
    self.idxByShort = {}          -- [strlower(NameOnly)] = FullName

    -- Message toggles and templates (populated by GetMessages)
    self.useGuild, self.useWhisper, self.useInvite = false, false, false
    self.msgGuild, self.msgWhisper, self.msgInvite = nil, nil, nil

    -- Single ns.MQ instance for paced sending
    assert(ns.MQ, "ns.MQ is required")
    local interval = tonumber(ns.g and ns.g.timeBetweenMessages) or 0.1
    self.Q = self.Q or ns.MQ:New({ interval = interval })

    self:RegisterInviteObservers()
end

-- Utility: split "Name-Realm" and ensure realm
local function prepForInvite(fullName)
    local name, realm = strsplit('-', fullName)
    return name, (realm or GetRealmName())
end

--=============================================================================
-- Invited Registry (core data model)
--=============================================================================
-- Record structure (InvitedRecord):
-- {
--   fullName       = "Name-Realm",
--   justName       = "Name",
--   guildMessage   = string|nil,
--   inviteMessage  = string|nil,
--   whisperMessage = string|nil,
--   timeInvited    = timerHandle|nil
-- }

local Invited = {}
Invited.__index = Invited

-- Internal authoritative store: [strlower(FullName)] = InvitedRecord
local _byFull = {}

-- Case-insensitive key
local function keyFull(s) return s and strlower(s) or nil end

-- Lookup a record by full name ("Name-Realm")
function Invited.Get(fullName)
    return _byFull[keyFull(fullName)]
end

-- Return messages for a full name (table or nil)
function Invited.Messages(fullName)
    local o = Invited.Get(fullName)
    return o and { guild = o.guildMessage, invite = o.inviteMessage, whisper = o.whisperMessage } or nil
end

-- Cancel only the timeout timer for this record
function Invited.CancelTimer(fullName)
    local o = Invited.Get(fullName)
    if o and o.timeInvited then
        GR:CancelTimer(o.timeInvited, true)
        o.timeInvited = nil
        return true
    end
    return false
end

-- Remove a record, canceling its timer; returns the removed record or nil
function Invited.Remove(fullName)
    local k = keyFull(fullName)
    local o = _byFull[k]
    if not o then return nil end
    if o.timeInvited then
        GR:CancelTimer(o.timeInvited, true)
        o.timeInvited = nil
    end
    _byFull[k] = nil

    -- Keep mirrors in sync for external reads
    if invite.idxByShort and o.justName then invite.idxByShort[strlower(o.justName)] = nil end
    if invite.tblInvited then invite.tblInvited[o.fullName] = nil end
    return o
end

-- Create and register a new pending-invite record with TTL
function Invited:New(fullName, justName, guildMessage, inviteMessage, whisperMessage)
    assert(fullName, "fullName required")
    local obj = setmetatable({
        fullName       = fullName,
        justName       = justName,
        guildMessage   = guildMessage,
        inviteMessage  = inviteMessage,
        whisperMessage = whisperMessage,
        timeInvited    = nil,
    }, self)

    -- Authoritative store + public mirrors
    _byFull[keyFull(fullName)] = obj
    invite.tblInvited[fullName] = obj
    invite.idxByShort[strlower(justName)] = fullName

    -- Auto-timeout
    obj.timeInvited = GR:ScheduleTimer(function()
        Invited.Remove(fullName)
        if ns and ns.code and ns.code.dOut then
            ns.code:dOut("Invite sent to " .. fullName .. " timed out.")
        end
        if ns and ns.analytics and ns.analytics.UpdateSessionData then
            ns.analytics:UpdateSessionData("SESSION_INVITE_TIMED_OUT")
            ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE", -1)
        end
    end, INVITE_TIME_OUT)

    -- Anti-spam and analytics hooks
    if ns and ns.list and ns.list.AddToAntiSpam then ns.list:AddToAntiSpam(fullName) end
    if ns and ns.analytics then
        ns.analytics:UpdateData('INVITED_GUILD')
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD')
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE')
    end

    return obj
end

-- Optional utilities for debug/admin
function Invited.Count()
    local n = 0; for _ in pairs(_byFull) do n = n + 1 end; return n
end
function Invited.Clear()
    for _, o in pairs(_byFull) do
        if o.timeInvited then GR:CancelTimer(o.timeInvited, true) end
    end
    wipe(_byFull); wipe(invite.tblInvited); wipe(invite.idxByShort)
end

--=============================================================================
-- Invite Flow
--=============================================================================
-- Public helpers that construct parameters and call InvitePlayer.
function invite:AutoInvite(fullName, justName, inviteFormat)
    return self:InvitePlayer(
        fullName,
        (justName or prepForInvite(fullName)),
        (inviteFormat ~= ns.InviteFormat.MESSAGE_ONLY or false),
        self.useInvite,
        self.useGuild,
        self.useWhisper
    )
end

function invite:ManualInvite(fullName, sendGuildInvite, sendInviteMessage, sendWelcomeMessage, sendWelcomeWhisper)
    return self:InvitePlayer(fullName, prepForInvite(fullName), sendGuildInvite, sendInviteMessage, sendWelcomeMessage, sendWelcomeWhisper)
end

-- Core invite routine. Creates pending record, sends guild invite, and queues messages.
function invite:InvitePlayer(fullName, justName, sendGuildInvite, sendInviteMessage, sendGuildWelcome, sendGuildWhisper)
    if GR.isTesting then
        ns.code:fOut('Testing mode is enabled. Invites sent to: '..testName..'.')
        fullName = testName -- do NOT call prepForInvite here
    end

    local name, realm = prepForInvite(fullName)
    if not name or name == '' then return end
    fullName, justName = name..'-'..realm, name

    if not GR.isTesting and Invited.Get(fullName) then
        return false, L['ALREADY_INVITED']
    end

    local guildMessage   = sendGuildWelcome  and self.msgGuild   or nil
    local inviteMessage  = sendInviteMessage and self.msgInvite  or nil
    local whisperMessage = sendGuildWhisper  and self.msgWhisper or nil

    Invited:New(fullName, justName, guildMessage, inviteMessage, whisperMessage)
    ns.list:AddToAntiSpam(fullName)

    if sendGuildInvite then
        C_GuildInfo.Invite(fullName)
        ns.code:fOut(L['GUILD_INVITE_SENT']..' '..fullName, ns.COLOR_SYSTEM, true)
    end

    if sendInviteMessage and inviteMessage then
        local msg = ns.code:variableReplacement(inviteMessage, justName)
        if sendGuildInvite and (ns.gmSettings.obeyBlockInvites or ns.gSettings and ns.gSettings.obeyBlockInvites) then
            C_Timer.After(1, function()
                if Invited.Get(fullName) then
                    self.Q:Whisper(fullName, msg)
                    ns.code:cOut(L['INVITE_MESSAGE_QUEUED']..' '..fullName, ns.COLOR_SYSTEM, true)
                else
                    ns.code:cOut(L['GUILD_INVITE_BLOCKED'], fullName)
                end
            end)
        else
            self.Q:Whisper(fullName, msg)
            ns.code:cOut(L['INVITE_MESSAGE_QUEUED']..' '..fullName, ns.COLOR_SYSTEM, true)
        end
    end
end

--=============================================================================
-- Observer Wiring (accept/decline/error detection)
--=============================================================================
-- Pattern compiler: turn a localized GLOBAL_STRING with %s into a Lua pattern.
local function pat(gs)
    if not gs then return nil end
    gs = gs:gsub("([%^%$%(%)%%%.%*%+%-%?%[%]])","%%%1") -- escape Lua pattern chars
    gs = gs:gsub("%%%%s","(.+)")                        -- %s -> (.+)
    gs = gs:gsub("%%%%d","(%%d+)")                      -- %d -> (%d+)
    return "^" .. gs .. "$"
end

-- Pick the first available GLOBAL_STRING by key for x-version safety.
local function GS(...)
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        local s = _G[key]
        if type(s) == "string" and s ~= "" then return s end
    end
end

-- Status patterns (Retail/Classic/Cata). Nils are pruned.
local PATS = {
    DECLINED          = pat(GS("ERR_GUILD_DECLINE_S")),
    ALREADY_IN_GUILD  = pat(GS("ERR_ALREADY_IN_GUILD_S", "ERR_ALREADY_IN_GUILD")),
    ALREADY_IN_YOURS  = pat(GS("ERR_ALREADY_IN_YOUR_GUILD_S")),
    ALREADY_INVITED   = pat(GS("ERR_ALREADY_INVITED_TO_GUILD_S")),
    NOT_FOUND         = pat(GS("ERR_CHAT_PLAYER_NOT_FOUND_S", "ERR_PLAYER_NOT_FOUND_S")),
    NOT_PLAYING       = pat(GS("ERR_NOT_PLAYING_WOW_S")),
    IGNORES           = pat(GS("ERR_IGNORING_YOU_S")),
    JOINED_GUILD      = pat(GS("GUILD_EVENT_PLAYER_JOINED", "ERR_GUILD_JOIN_S", "GUILD_JOIN_S")),  -- sometimes seen on accept
}
for k,v in pairs(PATS) do if not v then PATS[k] = nil end end

-- Resolve a system-captured name ("Name" or "Name-Realm") to a full name in registry.
local function findFullNameFromSystem(capturedName)
    if invite.tblInvited[capturedName] then return capturedName end -- already full
    return invite.idxByShort[strlower(capturedName)]
end

-- Locale-safe accept check: scan guild roster for short name match.
local function isInGuildByShort(shortName)
    if not IsInGuild() then return false end
    local n = GetNumGuildMembers()
    for i = 1, n do
        local name = GetGuildRosterInfo(i)  -- may be "Name-Realm" or "Name"
        if name then
            local just = Ambiguate(name, "short")
            if strlower(just) == strlower(shortName) then return true end
        end
    end
    return false
end

-- Unified finalize: cancels timer, removes record, posts follow-ups, updates analytics.
local function finalize(fullName, status)
    local r = Invited.Remove(fullName)  -- also clears mirrors
    if not r then return end

    if status == "ACCEPTED" then
        C_Timer.After(3, function()
            if r.guildMessage and invite.useGuild then
                SendChatMessage(ns.code:variableReplacement(invite.msgGuild, r.justName, true), "GUILD")
            end
            if r.whisperMessage and invite.useWhisper then
                invite.Q:Whisper(fullName, ns.code:variableReplacement(invite.msgWhisper, r.justName))
            end
        end)
        if ns and ns.analytics then
            ns.analytics:UpdateData("ACCEPTED_INVITE")
            ns.analytics:UpdateSessionData("SESSION_ACCEPTED_INVITE")
        end
    else
        if ns and ns.analytics then
            ns.analytics:UpdateData("INVITED_GUILD", -1)
            ns.analytics:UpdateSessionData("SESSION_INVITED_GUILD", -1)
        end
    end
    if ns and ns.analytics then
        ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE", -1)
    end
end

-- Register handlers:
--  * GUILD_ROSTER_UPDATE: detect "accepted" by roster presence.
--  * CHAT_MSG_SYSTEM: detect declines/errors by matching localized strings.
function invite:RegisterInviteObservers()
    -- Roster-driven acceptance
    local f = self._rosterFrame or CreateFrame("Frame")
    self._rosterFrame = f
    f:UnregisterAllEvents()
    f:RegisterEvent("GUILD_ROSTER_UPDATE")
    f:SetScript("OnEvent", function()
        if not next(invite.tblInvited) then return end
        for full, rec in pairs(invite.tblInvited) do
            if rec and isInGuildByShort(rec.justName) then
                finalize(full, "ACCEPTED")
            end
        end
    end)

    -- System-text declines/errors (locale-safe)
    local function SystemFilter(_, event, msg)
    if event ~= "CHAT_MSG_SYSTEM" or not next(invite.tblInvited) then return false end

    -- check all known patterns
    for tag, patn in pairs(PATS) do
        local captured = msg:match(patn)  -- the player name shown in the system text
        if captured then
            -- Resolve to our stored full name (Name-Realm) if possible
            local full = findFullNameFromSystem(captured)

            -- Notify: which exact PATS key matched
            -- Primary hook
            pcall(invite.inviteStatus, invite, tag, captured, full, msg)
            -- Optional alternate callback if registered
            if invite._statusHandler then pcall(invite._statusHandler, tag, captured, full, msg) end

            -- Finalize when we have a tracked player
            if full then
                -- JOINED_GUILD is effectively an accept
                local status = (tag == "JOINED_GUILD") and "ACCEPTED" or tag
                finalize(full, status)
            end
            break
        end
    end
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemFilter)

end

--=============================================================================
-- Message Preference Resolution
--=============================================================================
function invite:GetMessages()
    -- Guild welcome text
    self.msgGuild = L['DEFAULT_GUILD_WELCOME']
    if ns.isGM then self.msgGuild = ns.gmSettings.guildMessage or self.msgGuild
    else self.msgGuild = ns.pSettings.guildMessage or self.msgGuild end

    -- Invite whisper template (select active message if available)
    self.msgInvite = (ns.guild.messageList and ns.pSettings.activeMessage and ns.guild.messageList[ns.pSettings.activeMessage])
        and ns.guild.messageList[ns.pSettings.activeMessage].message
        or nil

    -- Welcome whisper text
    local function nonempty(s) return type(s)=="string" and s ~= "" and s or nil end

    do
        local gmMsg = nonempty(ns.gmSettings and ns.gmSettings.whisperMessage)
        local pMsg  = nonempty(ns.pSettings and ns.pSettings.whisperMessage)

        if ns.isGM then
            if ns.gmSettings and ns.gmSettings.sendWhisperGreeting and gmMsg then
                self.msgWhisper, self.useWhisper = gmMsg, true
            else
                self.msgWhisper, self.useWhisper = nil, false
            end
        else
            if ns.gmSettings and ns.gmSettings.forceWhisperMessage and gmMsg then
                self.msgWhisper, self.useWhisper = gmMsg, true
            elseif ns.pSettings and ns.pSettings.sendWhisperGreeting and pMsg then
                self.msgWhisper, self.useWhisper = pMsg, true
            else
                self.msgWhisper, self.useWhisper = nil, false
            end
        end
    end

    do
        local gmMsg = nonempty(ns.gmSettings and ns.gmSettings.guildMessage)
        local pMsg  = nonempty(ns.pSettings  and ns.pSettings.guildMessage)

        if ns.isGM then
            if ns.gmSettings and ns.gmSettings.sendGuildGreeting and gmMsg then
                self.msgGuild, self.useGuild = gmMsg, true
            else
                self.msgGuild, self.useGuild = nil, false
            end
        else
            if ns.gmSettings and ns.gmSettings.forceSendGuildGreeting and gmMsg then
                self.msgGuild, self.useGuild = gmMsg, true
            elseif ns.pSettings and ns.pSettings.sendGuildGreeting and pMsg then
                self.msgGuild, self.useGuild = pMsg, true
            else
                self.msgGuild, self.useGuild = nil, false
            end
        end
    end

    if ns.pSettings.inviteFormat == ns.InviteFormat.GUILD_INVITE_ONLY or not self.msgInvite then
        self.useInvite = false
    elseif ns.gmSettings.forceInviteMessage and ns.gmSettings.sendInviteMessage then
        self.useInvite = true
    else
        self.useInvite = self.msgInvite or false
    end
end

--=============================================================================
-- Validation helpers
--=============================================================================
function invite:CheckWhoList(player, zoneName) return self:CheckInvite(player, true,  true,  true,  zoneName) end
function invite:CheckAutoInvite(player)        return self:CheckInvite(player, false, true,  false) end
function invite:CheckManualInvite(player)      return self:CheckInvite(player, false, true,  false) end

-- Returns: ok:boolean, reason:string
function invite:CheckInvite(player, antispam, blacklist, zones, zoneName)
    if not player or player == '' then ns.code:dOut('CheckInvite: No name provided'); return false, 'Unknown' end
    local blReason = ns.list:BlacklistReason(player) or L["BLACKLIST"]
    if Invited.Get(player) then return false, L['ALREADY_INVITED_STATUS'] end
    if antispam  and ns.list:CheckAntiSpam(player) then return false, L["ANTI_SPAM"] end
    if blacklist and ns.list:CheckBlacklist(player) then return false, blReason end
    if zones and zoneName and (zoneName == 'Delves' or ns.invalidZones[strlower(zoneName)]) then return false, L['INVALID_ZONE'] end
    return true, ''
end

-- =============================================================================
-- Status Callback Registration (Hooks) for Blizzard string matches
-- =============================================================================
function ns.invite:inviteStatus(tag, name, captured, full, msg)
    -- Notify: which exact PATS key matched
    if tag == 'DECLINED' then
        ns.code:dOut("Invite to "..(full or captured).." was DECLINED.")
        ns.analytics:UpdateData('DECLINED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_DECLINED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    elseif tag == 'ALREADY_IN_GUILD' or tag == 'ALREADY_IN_YOURS' then
        ns.code:dOut((full or captured).." is already in a guild.")
        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    elseif tag == 'ALREADY_INVITED' then
        ns.code:dOut("Already invited "..(full or captured)..".")
        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    elseif tag == 'NOT_FOUND' or tag == 'NOT_PLAYING' then
        ns.code:dOut("Player "..(full or captured).." not found.")
        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    elseif tag == 'IGNORES' then
        ns.code:dOut((full or captured).." is ignoring you.")
        ns.analytics:UpdateData('INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_INVITED_GUILD', -1)
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    elseif tag == 'JOINED_GUILD' then
        ns.code:dOut((full or captured).." has JOINED the guild.")
        ns.analytics:UpdateData('ACCEPTED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_ACCEPTED_INVITE')
        ns.analytics:UpdateSessionData('SESSION_WAITING_RESPONSE', -1)
    end
end

--[[
    local PATS = {
        DECLINED          = pat(GS("ERR_GUILD_DECLINE_S")),
        ALREADY_IN_GUILD  = pat(GS("ERR_ALREADY_IN_GUILD_S", "ERR_ALREADY_IN_GUILD")),
        ALREADY_IN_YOURS  = pat(GS("ERR_ALREADY_IN_YOUR_GUILD_S")),
        ALREADY_INVITED   = pat(GS("ERR_ALREADY_INVITED_TO_GUILD_S")),
        NOT_FOUND         = pat(GS("ERR_CHAT_PLAYER_NOT_FOUND_S", "ERR_PLAYER_NOT_FOUND_S")),
        NOT_PLAYING       = pat(GS("ERR_NOT_PLAYING_WOW_S")),
        IGNORES           = pat(GS("ERR_IGNORING_YOU_S")),
        JOINED_GUILD      = pat(GS("GUILD_EVENT_PLAYER_JOINED", "ERR_GUILD_JOIN_S", "GUILD_JOIN_S")),  -- sometimes seen on accept
    }
--]]