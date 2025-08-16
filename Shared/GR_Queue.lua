-- MessageQueue.lua -----------------------------------------------------------
-- ns.MQ : simple FIFO queue for chat + addon messages. No external libs.
-- Chat: send verbatim (no length checks). Addon: UTF-8 safe chunking with P#| labels.

local addonName, ns = ...
ns = ns or {}

local MQ = {}
MQ.__index = MQ

local MAX_ADDON, MAX_PREFIX = 255, 16

-- UTF-8 safe byte-limited cut: returns end-index ≤ i+limit-1 on codepoint boundary
local function utf8_cut(s, i, limit)
  local bytes, j = 0, i
  local n = #s
  while j <= n do
    local c = s:byte(j)
    local clen = (c < 0x80) and 1 or (c < 0xE0) and 2 or (c < 0xF0) and 3 or 4
    if bytes + clen > limit then break end
    bytes = bytes + clen
    j = j + clen
  end
  return j - 1
end

-- Outgoing whisper visibility toggle (Retail + Classic)
local _w = { map = {}, ttl = 4 }  -- seconds
local function _whispersEnabled()
  local v = ns and ns.pSettings and ns.pSettings.showWhispers
  return v == true or v == 1 or v == "1" or v == "true"
end
local function _markWhisper(msg)
  local e = _w.map[msg]
  if e then
    e.n, e.t = e.n + 1, GetTime()
  else
    _w.map[msg] = { n = 1, t = GetTime() }
  end
end
local function _wFilter(_, _, msg)
  if _whispersEnabled() then return false end
  local e = _w.map[msg]; if not e then return false end
  if (GetTime() - e.t) <= _w.ttl and e.n > 0 then
    e.n = e.n - 1
    if e.n == 0 then _w.map[msg] = nil end
    return true -- suppress this outgoing whisper line
  end
  _w.map[msg] = nil
  return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", _wFilter)
pcall(ChatFrame_AddMessageEventFilter, "CHAT_MSG_BN_WHISPER_INFORM", _wFilter)

-- internal senders -----------------------------------------------------------
local function send_chat(job)
  local msg, chatType, lang, target = job.msg, job.chatType, job.languageID, job.target
  if chatType == "WHISPER" then
    if ns.classic then target = Ambiguate(target or "", "short") end
    _markWhisper(msg) -- record so filter can hide if configured off
  end
  SendChatMessage(msg, chatType, lang, target)
end

local function send_addon(job)
  C_ChatInfo.SendAddonMessage(job.prefix, job.msg, job.channel, job.target)
end

-- ctor -----------------------------------------------------------------------
function MQ:New(opts)
  local o = setmetatable({}, self)
  o.interval = math.max(0.01, tonumber(opts and opts.interval) or 0.1)
  o.q, o.h, o.t = {}, 1, 0
  o.ticker, o.onSend = nil, nil
  return o
end

-- queue core -----------------------------------------------------------------
function MQ:_push(job)
  self.t = self.t + 1
  self.q[self.t] = job
  if not self.ticker then
    self.ticker = C_Timer.NewTicker(self.interval, function() self:_tick() end)
  end
end

function MQ:_tick()
  if self.h > self.t then
    if self.ticker then self.ticker:Cancel(); self.ticker = nil end
    self.q, self.h, self.t = {}, 1, 0
    return
  end
  local job = self.q[self.h]; self.q[self.h] = nil; self.h = self.h + 1
  if job then
    local ok, err = pcall(function()
      if job.kind == "chat" then send_chat(job) else send_addon(job) end
    end)
    if not ok and DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff3333MQ error: "..tostring(err))
    end
    if self.onSend then pcall(self.onSend, job) end
  end
end

-- public API -----------------------------------------------------------------
function MQ:EnqueueChat(chatType, msg, target, languageID)
  if not chatType or not msg then return end
  self:_push({ kind="chat", chatType=chatType, msg=msg, target=target, languageID=languageID, when=GetTime() })
end

function MQ:Whisper(player, msg)
  if not player or not msg then return end
  self:EnqueueChat("WHISPER", msg, player, nil)
end

-- Splits addon message into ≤255-byte UTF-8 chunks; if >1 chunk, each chunk is prefixed "P#|"
function MQ:EnqueueAddon(prefix, msg, channel, target)
  if not prefix or not msg or not channel then return end
  assert(#prefix <= MAX_PREFIX, "addon prefix must be ≤16 bytes")

  local total = #msg
  if total <= MAX_ADDON then
    self:_push({ kind="addon", prefix=prefix, msg=msg, channel=channel, target=target, when=GetTime() })
    return
  end

  local i, part = 1, 1
  while i <= total do
    local label = ("P%d|"):format(part)
    local allow = MAX_ADDON - #label
    local j = utf8_cut(msg, i, allow)
    local chunk = label .. msg:sub(i, j)
    self:_push({ kind="addon", prefix=prefix, msg=chunk, channel=channel, target=target, when=GetTime() })
    i = j + 1
    part = part + 1
  end
end

-- controls -------------------------------------------------------------------
function MQ:SetInterval(sec)
  self.interval = math.max(0.01, tonumber(sec) or 0.1)
  if self.ticker then
    self.ticker:Cancel()
    self.ticker = C_Timer.NewTicker(self.interval, function() self:_tick() end)
  end
end

function MQ:Pause()  if self.ticker then self.ticker:Cancel(); self.ticker = nil end end
function MQ:Resume() if not self.ticker and self.h <= self.t then self.ticker = C_Timer.NewTicker(self.interval, function() self:_tick() end) end end
function MQ:Clear()  if self.ticker then self.ticker:Cancel(); self.ticker = nil end; for i=self.h,self.t do self.q[i]=nil end; self.h,self.t=1,0 end

-- expose ---------------------------------------------------------------------
ns.MQ = MQ
