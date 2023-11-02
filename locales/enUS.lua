--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GuildRecruiter", "enUS", true)

L['TITLE'] = "Guild Recruiter"

-- System Messages
L["Player not found"] = true
L["joined the guild"] = true
L["No Player Named"] = true
L['no player named'] = true
L["is already in a guild"] = true
L['is not online'] = true
L['has joined the guild'] = true
L['declines your guild invitation'] = true
L['JOINED_GUILD_MESSAGE'] = true

-- Generic Terms
L['ENABLED'] = 'is enabled'
L['DISABLED'] = 'is disabled'

-- Slash Commands
L['help'] = 'help'
L['config'] = 'config'
L['reload'] = 'reload'
L['recruiter'] = "recruiter"
L['blacklist'] = 'blacklist'

-- Core Startup
L['FIRST_RUN'] = 'You can use "/gr help or /recruiter" to get a list of commands.'
L['ANTI_SPAM_REMOVAL'] = 'Removed %s players from anti-spam list.'
L['BL_REMOVAL'] = ' were removed from the black list after the 30 day wait period.'

-- Minimap Tooltip
L['LEFT_MOUSE_BUTTON'] = 'LMB - Start Recruit Search'
L['RIGHT_MOUSE_BUTTON'] = 'RMB - Open Configuration'

-- Slash Help Commands
L['SLASH_HELP1'] = '%s - Help'
L['SLASH_HELP2'] = 'You can use "/gr help or /recruiter" to get a list of commands.'
L['SLASH_HELP3'] = 'config - Takes you to Guild Recruiter settings screen.'
L['SLASH_HELP4'] = 'blacklist <player name> - This will add player to the black list (do not use the <>)'
L['SLASH_HELP5'] = 'reload - You can type /rl to reload your UI (same as /reload).'

-- Guild Related
L['NO_GUILD'] = 'No guild found, Guild Recruiter disabled.'
L['BAD_GUILD_DATA'] = 'There was an issue accessing the guild data.'
