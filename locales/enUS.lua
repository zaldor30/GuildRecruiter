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