--[[-----------------------------------------------------------------------------
Invite Subsystem
-----------------------------------------------------------------------------]]--
local addonName, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ns.invite = ns.invite or {}
local invite = ns.invite

local INVITE_TIME_OUT = 120
local testName = ns.classic and "Hideme" or "Monkstrife"

--== utils ====================================================================
local function canonical_full(fullName)
  if not fullName or fullName == "" then return nil end
  fullName = fullName:gsub("|Hplayer:([^:|]+):.*", "%1") -- strip chat link payload
  fullName = fullName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  fullName = Ambiguate(fullName, "none")
  if not fullName:find("-", 1, true) then
    local rn = GetRealmName() or ""
    if rn ~= "" then fullName = fullName .. "-" .. rn end
  end
  return fullName
end

local function prepForInvite(fullName)
  fullName = canonical_full(fullName)
  if not fullName then return nil, nil end
  local name, realm = strsplit("-", fullName)
  return name, realm
end

-- single place to issue guild invites across versions
local function doGuildInvite(fullName)
  local just = select(1, strsplit("-", fullName))
  if C_GuildInfo and C_GuildInfo.Invite then
    if ns.classic then C_GuildInfo.Invite(just) else C_GuildInfo.Invite(fullName) end
  elseif GuildInvite then
    GuildInvite(just)
  else
    SendSystemMessage("Guild invite API not found; attempted '"..tostring(just).."'")
  end
end

--== registry =================================================================
local Invited = {}
Invited.__index = Invited

local _byFull = {} -- [lower("Name-Realm")] = record
local function keyFull(s) return s and strlower(s) or nil end

local function _armTimeout(fullName)
  return GR:ScheduleTimer(function()
    Invited.Remove(fullName)
    if ns and ns.code and ns.code.dOut then ns.code:dOut("Invite to "..fullName.." timed out.") end
    if ns and ns.analytics and ns.analytics.UpdateSessionData then
      ns.analytics:UpdateSessionData("SESSION_INVITE_TIMED_OUT")
      ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE", -1)
    end
  end, INVITE_TIME_OUT)
end

function Invited.Get(fullName) return _byFull[keyFull(canonical_full(fullName))] end
function Invited.CancelTimer(fullName)
  local o = Invited.Get(fullName)
  if o and o.timeInvited then GR:CancelTimer(o.timeInvited, true); o.timeInvited=nil; return true end
  return false
end
function Invited.Remove(fullName)
  fullName = canonical_full(fullName)
  local k = keyFull(fullName)
  local o = _byFull[k]; if not o then return nil end
  if o.timeInvited then GR:CancelTimer(o.timeInvited, true) end
  _byFull[k] = nil
  if invite.idxByShort and o.justName then invite.idxByShort[strlower(o.justName)] = nil end
  if invite.tblInvited then invite.tblInvited[o.fullName] = nil end
  return o
end
function Invited:New(fullName, justName, guildMessage, inviteMessage, whisperMessage)
  fullName = canonical_full(fullName); assert(fullName, "fullName required")
  local obj = setmetatable({
    fullName       = fullName,
    justName       = justName or (select(1, strsplit("-", fullName))),
    guildMessage   = guildMessage,   -- on ACCEPTED
    inviteMessage  = inviteMessage,  -- sent immediately if flagged
    whisperMessage = whisperMessage, -- on ACCEPTED
    timeInvited    = nil,
  }, self)
  _byFull[keyFull(fullName)] = obj
  invite.tblInvited[fullName] = obj
  invite.idxByShort[strlower(obj.justName or "")] = fullName
  obj.timeInvited = _armTimeout(fullName)
  if ns and ns.list and ns.list.AddToAntiSpam then ns.list:AddToAntiSpam(fullName) end
  if ns and ns.analytics then
    ns.analytics:UpdateData("INVITED_GUILD")
    ns.analytics:UpdateSessionData("SESSION_INVITED_GUILD")
    ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE")
  end
  return obj
end

--== init + prefs =============================================================
function invite:Init()
  self.tblInvited, self.idxByShort = {}, {}
  self.useGuild, self.useWhisper, self.useInvite = false, false, false
  self.msgGuild, self.msgWhisper, self.msgInvite = nil, nil, nil
  assert(ns.MQ, "ns.MQ is required")
  local interval = tonumber(ns.g and ns.g.timeBetweenMessages) or 0.1
  self.Q = self.Q or ns.MQ:New({ interval = interval })
  self:RegisterInviteObservers()
end

local function nz(s) return type(s)=="string" and s~="" and s or nil end
function invite:GetMessages()
  -- guild welcome
  local gm = nz(ns.gmSettings and ns.gmSettings.guildMessage)
  local pm = nz(ns.pSettings  and ns.pSettings.guildMessage)
  if ns.isGM then
    if ns.gmSettings and ns.gmSettings.sendGuildGreeting and gm then self.msgGuild,self.useGuild=gm,true else self.msgGuild,self.useGuild=nil,false end
  else
    if ns.gmSettings and ns.gmSettings.forceSendGuildGreeting and gm then self.msgGuild,self.useGuild=gm,true
    elseif ns.pSettings and ns.pSettings.sendGuildGreeting and pm then self.msgGuild,self.useGuild=pm,true
    else self.msgGuild,self.useGuild=nil,false end
  end
  -- invite whisper template
  self.msgInvite = nil
  if ns.guild and ns.guild.messageList and ns.pSettings and ns.pSettings.activeMessage then
    local e = ns.guild.messageList[ns.pSettings.activeMessage]; self.msgInvite = e and e.message or nil
  end
  self.useInvite = self.msgInvite and true or false
  if ns.pSettings and ns.InviteFormat and ns.pSettings.inviteFormat == ns.InviteFormat.GUILD_INVITE_ONLY then self.useInvite=false end
  if ns.gmSettings and ns.gmSettings.forceInviteMessage and ns.gmSettings.sendInviteMessage then self.useInvite = self.msgInvite and true or false end
  -- welcome whisper
  local gw = nz(ns.gmSettings and ns.gmSettings.whisperMessage)
  local pw = nz(ns.pSettings  and ns.pSettings.whisperMessage)
  if ns.isGM then
    if ns.gmSettings and ns.gmSettings.sendWhisperGreeting and gw then self.msgWhisper,self.useWhisper=gw,true else self.msgWhisper,self.useWhisper=nil,false end
  else
    if ns.gmSettings and ns.gmSettings.forceWhisperMessage and gw then self.msgWhisper,self.useWhisper=gw,true
    elseif ns.pSettings and ns.pSettings.sendWhisperGreeting and pw then self.msgWhisper,self.useWhisper=pw,true
    else self.msgWhisper,self.useWhisper=nil,false end
  end
end

--== public ===================================================================
function invite:AutoInvite(fullName, justName, inviteFormat)
  self:GetMessages()
  return self:InvitePlayer(
    fullName,
    (justName or select(1, prepForInvite(fullName))),
    (ns.pSettings.inviteFormat ~= ns.InviteFormat.MESSAGE_ONLY),
    self.useInvite,
    self.useGuild,
    self.useWhisper
  )
end

function invite:ManualInvite(fullName, sendGuildInvite, sendInviteMessage, sendWelcomeMessage, sendWelcomeWhisper)
  self:GetMessages()
  local full = canonical_full(fullName); if not full then return false, "Unknown" end

  -- straight guild invite only
  if sendGuildInvite and not sendInviteMessage and not sendWelcomeMessage and not sendWelcomeWhisper then
    local rec = Invited.Get(full)
    if rec then
      if rec.timeInvited then GR:CancelTimer(rec.timeInvited,true) end
      rec.guildMessage,rec.inviteMessage,rec.whisperMessage=nil,nil,nil
      rec.timeInvited=_armTimeout(full)
    else
      Invited:New(full, select(1,strsplit("-",full)), nil,nil,nil)
    end
    doGuildInvite(full)
    if ns and ns.code then ns.code:fOut(L["GUILD_INVITE_SENT"].." "..full, ns.COLOR_SYSTEM, true) end
    return true
  end

  -- welcome-on-join: invite NOW, send welcome/whisper after ACCEPTED
  if sendGuildInvite and not sendInviteMessage and sendWelcomeMessage and sendWelcomeWhisper then
    local just = select(1,strsplit("-", full))
    self:GetMessages()
    local gm = nz(self.msgGuild); local wm = nz(self.msgWhisper)
    local rec = Invited.Get(full)
    if rec then
      if rec.timeInvited then GR:CancelTimer(rec.timeInvited,true) end
      rec.guildMessage,rec.inviteMessage,rec.whisperMessage = gm,nil,wm
      rec.timeInvited=_armTimeout(full)
    else
      Invited:New(full, just, gm, nil, wm)
    end
    doGuildInvite(full)
    if ns and ns.code then ns.code:fOut(L["GUILD_INVITE_SENT"].." "..full, ns.COLOR_SYSTEM, true) end
    return true
  end

  -- fallback: full pipeline with checks
  local ok, reason = self:CheckManualInvite(full)
  if not ok then if ns and ns.code and ns.code.dOut then ns.code:dOut("Invite blocked: "..tostring(reason)) end; return false, reason end
  return self:InvitePlayer(full, select(1,strsplit("-",full)), sendGuildInvite, sendInviteMessage, sendWelcomeMessage, sendWelcomeWhisper)
end

-- context: no validation, always invite now
function invite:ContextGuildInviteOnly(fullName)
  local full = canonical_full(fullName); if not full then return false end
  local just = select(1,strsplit("-", full))
  local rec = Invited.Get(full)
  if rec then
    if rec.timeInvited then GR:CancelTimer(rec.timeInvited,true) end
    rec.guildMessage,rec.inviteMessage,rec.whisperMessage=nil,nil,nil
    rec.timeInvited=_armTimeout(full)
  else
    Invited:New(full, just, nil,nil,nil)
  end
  doGuildInvite(full)
  if ns and ns.code then ns.code:fOut(L["GUILD_INVITE_SENT"].." "..full, ns.COLOR_SYSTEM, true) end
  return true
end

-- context “message”: identical invite call, plus arm welcome + whisper on ACCEPTED
function invite:ContextGuildInviteWithWelcome(fullName)
  local full = canonical_full(fullName); if not full then return false end
  local just = select(1,strsplit("-", full))
  self:GetMessages()
  local gm = nz(self.msgGuild); local wm = nz(self.msgWhisper)
  local rec = Invited.Get(full)
  if rec then
    if rec.timeInvited then GR:CancelTimer(rec.timeInvited,true) end
    rec.guildMessage,rec.inviteMessage,rec.whisperMessage = gm,nil,wm
    rec.timeInvited = _armTimeout(full)
  else
    rec = Invited:New(full, just, gm, nil, wm)
  end
  doGuildInvite(full)
  if ns and ns.code then ns.code:fOut(L["GUILD_INVITE_SENT"].." "..full, ns.COLOR_SYSTEM, true) end
  return true
end

-- core
function invite:InvitePlayer(fullName, justName, sendGuildInvite, sendInviteMessage, sendGuildWelcome, sendGuildWhisper)
  if GR.isTesting then ns.code:fOut("Testing mode is enabled. Invites sent to "..testName.."."); fullName = canonical_full(testName) end
  local name, realm = prepForInvite(fullName); if not name or name=="" then return end
  fullName, justName = name.."-"..realm, name
  if not GR.isTesting and Invited.Get(fullName) then return false, L["ALREADY_INVITED"] end

  local guildMessage   = sendGuildWelcome  and self.msgGuild   or nil
  local inviteMessage  = sendInviteMessage and self.msgInvite  or nil
  local whisperMessage = sendGuildWhisper  and self.msgWhisper or nil

  Invited:New(fullName, justName, guildMessage, inviteMessage, whisperMessage)
  if ns.list and ns.list.AddToAntiSpam then ns.list:AddToAntiSpam(fullName) end
  if sendGuildInvite then doGuildInvite(fullName); ns.code:fOut(L["GUILD_INVITE_SENT"].." "..fullName, ns.COLOR_SYSTEM, true) end
  if sendInviteMessage and inviteMessage then
    local msg = ns.code:variableReplacement(inviteMessage, justName)
    if ns.HideWhisperOnceTo then ns.HideWhisperOnceTo(fullName, msg) end -- hide only this one line
    self.Q:Whisper(fullName, msg)
    ns.code:cOut(L["INVITE_MESSAGE_QUEUED"].." "..fullName, ns.COLOR_SYSTEM, true)
  end
  return true
end

--== observers ================================================================
local function pat(gs)
  if not gs then return nil end
  gs = gs:gsub("([%^%$%(%)%%%.%*%+%-%?%[%]])","%%%1"):gsub("%%%%s","(.+)"):gsub("%%%%d","(%%d+)")
  return "^"..gs.."$"
end
local function GS(...)
  for i=1,select("#", ...) do local key=select(i, ...); local s=_G[key]; if type(s)=="string" and s~="" then return s end end
end

local PATS = {
  DECLINED          = pat(GS("ERR_GUILD_DECLINE_S")),
  ALREADY_IN_GUILD  = pat(GS("ERR_ALREADY_IN_GUILD_S","ERR_ALREADY_IN_GUILD")),
  ALREADY_IN_YOURS  = pat(GS("ERR_ALREADY_IN_YOUR_GUILD_S")),
  ALREADY_INVITED   = pat(GS("ERR_ALREADY_INVITED_TO_GUILD_S")),
  NOT_FOUND         = pat(GS("ERR_CHAT_PLAYER_NOT_FOUND_S","ERR_PLAYER_NOT_FOUND_S")),
  NOT_PLAYING       = pat(GS("ERR_NOT_PLAYING_WOW_S")),
  IGNORES           = pat(GS("ERR_IGNORING_YOU_S")),
  JOINED_GUILD      = pat(GS("GUILD_EVENT_PLAYER_JOINED","ERR_GUILD_JOIN_S","GUILD_JOIN_S")),
}
for k,v in pairs(PATS) do if not v then PATS[k]=nil end end

local function findFullNameFromSystem(capturedName)
  if invite.tblInvited[capturedName] then return capturedName end
  return invite.idxByShort[strlower(capturedName)]
end

-- full-name acceptance to avoid cross-realm false positives
local function isInGuildAccepted(rec)
  if not rec or not IsInGuild() then return false end
  local wantFull = canonical_full(rec.fullName)
  local wantShort = rec.justName and strlower(rec.justName) or ""
  local wantRealm = select(2, strsplit("-", wantFull or "")) or GetRealmName()
  local n = (GetNumGuildMembers and GetNumGuildMembers()) or 0

  for i = 1, n do
    local name = GetGuildRosterInfo(i)
    if name then
      local roFull = canonical_full(name)
      if roFull and strlower(roFull) == strlower(wantFull) then
        return true
      end
      -- fallback: roster shows short only for same-realm entries sometimes
      local roShort = Ambiguate(name, "short")
      if roShort and strlower(roShort) == wantShort then
        if not tostring(name):find("-", 1, true) and wantRealm == (GetRealmName() or "") then
          return true
        end
      end
    end
  end
  return false
end

local function finalize(fullName, status)
  local r = Invited.Remove(fullName); if not r then return end
  if status == "ACCEPTED" then
    C_Timer.After(3, function()
      if r.guildMessage and r.guildMessage ~= "" then
        SendChatMessage(ns.code:variableReplacement(r.guildMessage, r.justName, true), "GUILD")
      end
      if r.whisperMessage and r.whisperMessage ~= "" then
        invite.Q:Whisper(fullName, ns.code:variableReplacement(r.whisperMessage, r.justName))
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
  if ns and ns.analytics then ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE", -1) end
end

function invite:RegisterInviteObservers()
  local f = self._rosterFrame or CreateFrame("Frame"); self._rosterFrame = f
  f:UnregisterAllEvents(); f:RegisterEvent("GUILD_ROSTER_UPDATE")
  f:SetScript("OnEvent", function()
    if not next(invite.tblInvited) then return end
    for full, rec in pairs(invite.tblInvited) do
      if rec and isInGuildAccepted(rec) then
        finalize(full, "ACCEPTED")
      end
    end
  end)

  local function SystemFilter(_, event, msg)
    if event ~= "CHAT_MSG_SYSTEM" or not next(invite.tblInvited) then return false end
    for tag, patn in pairs(PATS) do
      local captured = msg:match(patn)
      if captured then
        local full = findFullNameFromSystem(captured)
        pcall(invite.inviteStatus, invite, tag, captured, full, msg)
        if full then finalize(full, (tag == "JOINED_GUILD") and "ACCEPTED" or tag) end
        break
      end
    end
    return false
  end
  ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemFilter)
end

--== validation ===============================================================
function invite:CheckWhoList(player, zoneName) return self:CheckInvite(player, true,  true,  true,  zoneName) end
function invite:CheckAutoInvite(player)        return self:CheckInvite(player, false, true,  false) end
function invite:CheckManualInvite(player)      return self:CheckInvite(player, false, true,  false) end
function invite:CheckInvite(player, antispam, blacklist, zones, zoneName)
  if not player or player=="" then ns.code:dOut("CheckInvite: No name provided"); return false, "Unknown" end
  local blReason = ns.list:BlacklistReason(player) or L["BLACKLIST"]
  if Invited.Get(player) then return false, L["ALREADY_INVITED_STATUS"] end
  if antispam  and ns.list:CheckAntiSpam(player) then return false, L["ANTI_SPAM"] end
  if blacklist and ns.list:CheckBlacklist(player) then return false, blReason end
  if zones and zoneName and (zoneName == "Delves" or ns.invalidZones[strlower(zoneName)]) then return false, L["INVALID_ZONE"] end
  return true, ""
end

--== optional status log ======================================================
function ns.invite:inviteStatus(tag, name, captured, full, msg)
  if tag == "DECLINED" then
    ns.code:dOut("Invite to "..(full or captured).." was DECLINED.")
    ns.analytics:UpdateData("DECLINED_INVITE"); ns.analytics:UpdateSessionData("SESSION_DECLINED_INVITE"); ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE",-1)
  elseif tag == "ALREADY_IN_GUILD" or tag == "ALREADY_IN_YOURS" then
    ns.code:dOut((full or captured).." is already in a guild.")
    ns.analytics:UpdateData("INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE",-1)
  elseif tag == "ALREADY_INVITED" then
    ns.code:dOut("Already invited "..(full or captured)..".")
    ns.analytics:UpdateData("INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE",-1)
  elseif tag == "NOT_FOUND" or tag == "NOT_PLAYING" then
    ns.code:dOut("Player "..(full or captured).." not found.")
    ns.analytics:UpdateData("INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE",-1)
  elseif tag == "IGNORES" then
    ns.code:dOut((full or captured).." is ignoring you.")
    ns.analytics:UpdateData("INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_INVITED_GUILD",-1); ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE",-1)
  elseif tag == "JOINED_GUILD" then
    ns.code:dOut((full or captured).." has JOINED the guild.")
    ns.analytics:UpdateData("ACCEPTED_INVITE"); ns.analytics:UpdateSessionData("SESSION_ACCEPTED_INVITE"); ns.analytics:UpdateSessionData("SESSION_WAITING_RESPONSE",-1)
  end
end

--== convenience ==============================================================
function invite:ManualGuildInviteOnly(fullName)                return self:ManualInvite(fullName, true,  false, false, false) end
function invite:ManualGuildInviteWithWelcome(fullName)         return self:ManualInvite(fullName, true,  false, true,  true ) end
function invite:ContextGuildInviteOnlyWrapper(fullName)        return self:ContextGuildInviteOnly(fullName) end
function invite:ContextGuildInviteWithWelcomeWrapper(fullName) return self:ContextGuildInviteWithWelcome(fullName) end
