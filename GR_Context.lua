-- GR_Context.lua — adds a "Guild Recruiter" block to Blizzard right-click menus
local addonName, ns = ...
ns = ns or {}

-- ---------- shared utils ----------
local function ResolveFullName(ctxOrDropdown, unit, name)
  local n, r
  if ctxOrDropdown and ctxOrDropdown.name then
    n, r = ctxOrDropdown.name, ctxOrDropdown.server
  else
    n, r = name, ctxOrDropdown and ctxOrDropdown.server
  end
  if unit and UnitExists(unit) then
    local un, ur = UnitName(unit); if un then n, r = un, ur end
  end
  if not n or n == "" then return nil end
  if r and r ~= "" and not n:find("-", 1, true) then n = n.."-"..r end
  return n
end

local function norm_full(name)
  if not name or name == "" then return nil end
  if not name:find("-", 1, true) then
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or nil
    if realm and realm ~= "" then name = name.."-"..realm end
  end
  return name:lower()
end

-- already in *my* guild?
local function InMyGuild(unit, fullName)
  if not IsInGuild() then return false end
  if unit and UnitIsInMyGuild and UnitIsInMyGuild(unit) then return true end
  if not fullName then return false end
  local target = norm_full(fullName); if not target then return false end

  if C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster()
  elseif GuildRoster then GuildRoster() end

  local total = (GetNumGuildMembers and GetNumGuildMembers())
             or (C_GuildInfo and C_GuildInfo.GetNumGuildMembers and C_GuildInfo.GetNumGuildMembers())
             or 0
  for i = 1, total do
    local name
    if GetGuildRosterInfo then
      name = GetGuildRosterInfo(i)                                 -- classic tuple; name is first
    elseif C_GuildInfo and C_GuildInfo.GetGuildRosterInfo then
      local v = C_GuildInfo.GetGuildRosterInfo(i)                  -- retail table or string
      name = (type(v) == "table") and v.name or v
    end
    if name and norm_full(name) == target then return true end
  end
  return false
end

-- ---------- your actions ----------
local function DoManualInvite(fullName, withMessage)
  if not fullName or fullName == "" then return end
  if withMessage then
        -- Invite to Guild (Message)
        ns.invite:ManualInvite(fullName, true, false, true, true)
    else
        -- Invite to Guild
        ns.invite:ManualInvite(fullName, true,  false, false, false)
    end
end

local function DoManualBlacklist(fullName)
  if not fullName or fullName == "" then return end
  if ns.list and ns.list.AddToBlackList then
    ns.list:AddToBlackList(fullName, "Manual Addition")
  else
    print("|cffff3333GR: ns.list:AddToBlackList not found|r")
  end
end

-- ===================== Retail (Dragonflight+) ===============================
if type(Menu) == "table" and type(Menu.ModifyMenu) == "function" then
  local function Inject(menuName, root, ctx)
    local who = ResolveFullName(ctx, ctx.unit, ctx.name)
    if not who then return end
    if InMyGuild(ctx.unit, who) then return end  -- skip block if already guilded

    root:CreateDivider()
    root:CreateTitle("|cffffd100Guild Recruiter|r")

    root:CreateButton("Invite to Guild", function()
      DoManualInvite(who, false)
    end, ctx)

    root:CreateButton("Invite to Guild (Message)", function()
      DoManualInvite(who, true)
    end, ctx)

    root:CreateButton("Add to Black List", function()
      DoManualBlacklist(who)
    end, ctx)
    -- no trailing divider
  end

  local keys = {
    "PLAYER","FRIEND","PARTY","RAID_PLAYER","RAID",
    "GUILD","GUILD_OFFLINE","CHAT_ROSTER",
    "COMMUNITIES_WOW_MEMBER","COMMUNITIES_GUILD_MEMBER",
    "BN_FRIEND","TARGET","FOCUS",
  }
  for _, k in ipairs(keys) do
    Menu.ModifyMenu("MENU_UNIT_"..k, Inject)
  end
end

-- ==================== Classic / Wrath / Cata ===============================
local function AddSeparatorClassic(level)
  level = level or UIDROPDOWNMENU_MENU_LEVEL or 1
  if UIDropDownMenu_AddSeparator then
    UIDropDownMenu_AddSeparator(level)
  elseif UIDROPDOWNMENU_SEPARATOR_INFO then
    UIDropDownMenu_AddButton(UIDROPDOWNMENU_SEPARATOR_INFO, level)
  else
    local info = UIDropDownMenu_CreateInfo()
    info.isTitle, info.isUninteractable, info.notCheckable = true, true, true
    info.text = ""
    UIDropDownMenu_AddButton(info, level)
  end
end

local function AddTitleClassic(text, level)
  local info = UIDropDownMenu_CreateInfo()
  info.isTitle, info.notCheckable, info.isUninteractable = true, true, true
  info.colorCode = "|cffffd100"
  info.text = text
  UIDropDownMenu_AddButton(info, level or UIDROPDOWNMENU_MENU_LEVEL or 1)
end

local function AddButtonClassic(text, fn, level)
  local info = UIDropDownMenu_CreateInfo()
  info.text, info.notCheckable = text, true
  info.func = function() if CloseDropDownMenus then CloseDropDownMenus() end; fn() end
  UIDropDownMenu_AddButton(info, level or UIDROPDOWNMENU_MENU_LEVEL or 1)
end

local function InjectClassic(dropdown, which, unit, name)
  if UIDROPDOWNMENU_MENU_LEVEL ~= 1 then return end
  if dropdown._grInjected then return end

  local who = ResolveFullName(dropdown, unit, name)
  if not who then return end
  if InMyGuild(unit, who) then return end  -- skip if already guilded

  dropdown._grInjected = true

  AddSeparatorClassic()
  AddTitleClassic("Guild Recruiter")

  AddButtonClassic("Invite to Guild", function()
    DoManualInvite(who, false)
  end)

  AddButtonClassic("Invite to Guild (Message)", function()
    DoManualInvite(who, true)
  end)

  AddButtonClassic("Add to Black List", function()
    DoManualBlacklist(who)
  end)
end

if type(UnitPopup_ShowMenu) == "function" then
  hooksecurefunc("UnitPopup_ShowMenu", InjectClassic)
end
