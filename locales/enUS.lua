--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GuildRecruiter", "enUS", true)

L["TITLE"] = "Guild Recruiter"

-- * WoW System Message Translations
L["is not online"] = true
L["no player named"] = true
L["player not found"] = true
L["joined the guild"] = true
L["has joined the guild"] = true
L["is already in a guild"] = true
L["declines your guild invitation"] = true
L["has already been invited to a guild"] = true

-- * Icon Menu and Slash Commands
L["HELP"] = 'help'
L["CONFIG"] = 'cofig'
L["RELOAD"] = 'reload'
L["RECRUITER"] = 'recruiter'
L["BLACKLIST"] = 'blacklist'

-- * GR General Messages
L['IS_ENABLED'] = 'is enabled.'

-- * Default Values
L['DEFAULT_GUILD_WELCOME'] = 'Welcome PLAYERNAME to GUILDNAME!' -- Default Guild Welcome Message

-- * GR Core Messages
L['FIRST_TIME_INFO'] = [[
Welcome to Guild Recruiter!
You can access by right clicking on the minimap icon or by typing /gr config.
Left click on the minimap icon to open the recruitment window.
If you have any issues, click on the About menu option to get our Discord link.
]]
L['NEW_VERSION_INFO'] = [[
Guild Recruiter has been updated!
Please check the " What's New?" for what has changed.
]]
L['BETA_INFORMATION'] = [[
You are using a beta version of Guild Recruiter.
Please report any issues on our Discord server.]]

-- ? GR Error Messages
L['NO GUILD'] = "You are not in a guild."
L['NOT_LOADED'] = 'Guild Recruiter will not load.'
L['CANNOT_INVITE'] = 'You do not have permission to invite to the guild.'

-- * GR Slash Commands
L['SLASH_COMMANDS'] = [[
Guild Recruiter Slash Commands:
/rl will reload the WoW UI (like /reload).
/gr help - Displays this help message.
/gr config - Opens the configuration window.
/gr blacklist <player name> - Will add the player to the blacklist.
]]

-- * GR Minimap Icon Tooltip
-- Keep %AntiSpam and %BlackList in the tooltip.
L['MINIMAP_TOOLTIP'] = [[
Left Click: Open Guild Recruiter
Right Click: Open Config

%AntiSpam in invited list.
%BlackList in blacklisted list.]]

-- * GR Config Window Messages
L['General Settings'] = true

-- ? GR Config Window Tooltips
L['GEN_TOOLTIPS'] = 'Show all tooltips'
L['GEN_TOOLTIP_DESC'] = 'Show all tooltips in the Guild Recruiter addon'
L['GEN_MINIMAP'] = 'Show Minimap Icon'
L['GEN_MINIMAP_DESC'] = 'Show the Guild Recruiter minimap icon.'
L['GEN_CONTEXT'] = 'Enable inviting from chat'
L['GEN_CONTEXT_DESC'] = 'Show the Guild Recruiter context menu when right clicking a name in chat.'
L['GEN_WHATS_NEW'] = 'Show What\'s New?'
L['GEN_WHATS_NEW_DESC'] = 'Show the What\'s New? window when Guild Recruiter is updated.'
L['GEN_ADDON_MESSAGES'] = 'Show System Messages'
L['GEN_ADDON_MESSAGES_DESC'] = 'Show system messages from Guild Recruiter.'
L['KEYBINDING_HEADER'] = 'Keybindings'
L['KEYBINDING_INVITE'] = 'Invite Keybinding'
L['KEYBINDING_INVITE_DESC'] = 'Keybinding to invite a player to the guild.'
L['KEYBINDING_SCAN'] = 'Scan Keybinding'
L['KEYBINDING_SCAN_DESC'] = 'Keybinding to scan for players looking for a guild.'
L['KEY_BINDING_NOTE'] = 'Note: Keybinds will not effect WoW keybindings.'
L['GEN_ACCOUNT_WIDE'] = 'indicates effects all guild-wide characters'