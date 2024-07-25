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
L['IS_ENABLED'] = ' is enabled.'

-- * Default Values
L['DEFAULT_GUILD_WELCOME'] = 'Welcome PLAYERNAME to GUILDNAME!' -- Default Guild Welcome Message

-- * GR Core Messages
L['GUILD_LINK_INSTRUCTIONS'] = 'You can create a guild link only after setting up recruitment under (Guild and Communities).  Once you have done that type /rl to create a link.'

-- ? GR Error Messages
L['NO GUILD'] = "You are not in a guild."
L['NOT_LOADED'] = 'Guild Recruiter will not load.'
L['CANNOT_INVITE'] = 'You do not have permission to invite to the guild.'