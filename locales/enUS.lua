-- Localization file for English/United States
local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

-- * General
L["TITLE"] = "Guild Recruiter"
L["INVITE"] = "Invite"
L["SCAN"] = "Scan"
L["ABOUT"] = "About"
L["CLOSE"] = "Close"
L["CANCEL"] = "Cancel"
L["SAVE"] = "Save"
L["YES"] = "Yes"
L["NO"] = "No"
L["OK"] = "OK"
L["ENABLE"] = "Enable"
L["ENABLED"] = "Enabled"
L["DISABLE"] = "Disable"
L["DISABLED"] = "Disabled"
L["REMOVE"] = "Remove"
L["NEW"] = "New"
L["DELETE"] = "Delete"

-- * WoW System Message Translations
--! MUST BE IN LOWERCASE!
L["PLAYER_NOT_ONLINE"] = "is not online"
L["PLAYER_NOT_PLAYING"] = "is currently playing"
L["PLAYER_NOT_FOUND"] = "no player named" -- Duplicate removed
L["PLAYER_IN_GUILD"] = "has already been invited to a guild"
L["PLAYER_ALREADY_IN_GUILD"] = "is already in a guild"
L["PLAYER_JOINED_GUILD"] = "has joined the guild"
L["PLAYER_DECLINED_INVITE"] = "declines your guild invitation"

--* v4.0
L["NOT_IN_GUILD"] = "Guild Recruiter is disabled because you are not in a guild."
L["NOT_IN_GUILD_LINE1"] = "If you join a guild type /rl to reload."
L["CANNOT_INVITE"] = "Guild Recruiter is disabled, because you do not have permission to invite."

L["GUILD_LINK_NOT_FOUND"] = "No guild link found"
L["GUILD_LINK_NOT_FOUND_LINE1"] = "Try /rl or relogging (It may take a few attempts)"
L["GUILD_LINK_NOT_FOUND_LINE2"] = "Also, it could take a few minutes to become available."
L["NO_LONGER_GUILD_LEADER"] = "is no longer the guild leader."
L["NO_ANTI_SPAM"] = "Anti-Spam is not enabled. Please enable it in the settings."

L['DEFAULT_GUILD_WELCOME'] = "Welcome PLAYERNAME to GUILDNAME!"
L['MINIMAP_TOOLTIP'] = [[
Left Click: Open Guild Recruiter
Right Click: Open Settings
Shift+Left Click: Open Scanner

%AntiSpam in invited list.
%BlackList in blacklisted list.]]
L['BETA_INFORMATION'] = [[This is a VER version of Guild Recruiter.
Please report any issues on our Discord server.]]

-- * Settings
L['GEN_GUILD_WIDE'] = 'Indicates only your current guild will be effected.'
L['GEN_ACCOUNT_WIDE'] = 'Indicates all your charcters will be effected guild wide.'
L['RELOAD_AFTER_CHANGE'] = 'You must reload your UI (/rl) after making changes.'
L['GEN_WHATS_NEW'] = 'Show What\'s New?'
L['GEN_WHATS_NEW_DESC'] = 'Show the What\'s New? window when Guild Recruiter is updated.'
L['GEN_TOOLTIPS'] = 'Show all tooltips'
L['GEN_TOOLTIP_DESC'] = 'Show all tooltips in the Guild Recruiter addon'
L['GEN_ADDON_MESSAGES'] = 'Show System Messages'
L['GEN_ADDON_MESSAGES_DESC'] = 'Show system messages from Guild Recruiter.'
L['KEEP_ADDON_OPEN'] = 'Keep the addon open'
L['KEEP_ADDON_OPEN_DESC'] = [[
Keep the addon open and ignore ESC and other things that could close it.

NOTE: You will need to do a /rl after changing this setting.]]
L['GEN_MINIMAP'] = 'Show Minimap Icon'
L['GEN_MINIMAP_DESC'] = 'Show the Guild Recruiter minimap icon.'
L['INVITE_SCAN_SETTINGS'] = 'Invite and Scan Settings'
L['AUTO_SYNC'] = 'Enable auto sync'
L['AUTO_SYNC_DESC'] = 'Automatically sync with guild members when logging in.'
L['SHOW_WHISPERS'] = 'Show whispers in chat'
L['SHOW_WHISPERS_DESC'] = [[
Show the message you send to players when inviting.

NOTE: You will need to do a /rl after changing this setting.]]
L['GEN_CONTEXT'] = 'Enable right click invite from chat'
L['GEN_CONTEXT_DESC'] = 'Show the Guild Recruiter context menu when right-clicking a name in chat.'
L['SCAN_WAIT_TIME'] = 'Scan delay in seconds'
L['SCAN_WAIT_TIME_DESC'] = [[
The time in seconds to wait before scanning for players (2 to 10 seconds).

NOTE: 5 or 6 seconds is recommended.]]
L['KEYBINDING_HEADER'] = 'Keybindings'
L['KEYBINDING_INVITE'] = 'Invite Keybinding'
L['KEYBINDING_INVITE_DESC'] = 'Keybinding to invite a player to the guild.'
L['KEYBINDING_SCAN'] = 'Scan Keybinding'
L['KEYBINDING_SCAN_DESC'] = 'Keybinding to scan for players looking for a guild.'
L['KEY_BINDING_NOTE'] = 'Note: Keybinds will not affect WoW keybindings.'
L['INVITE_SETTINGS'] = 'Invite Settings'
L['INVITE_MESSAGES'] = 'Invite Messages'
-- * About
L['ABOUT_LINE'] = 'Thank you for using Guild Recruiter, I hope you find this addon useful!'
L['ABOUT_DOC_LINKS'] = 'Documentation and Links'
L['GITHUB_LINK'] = 'GitHub (Support documentation)'
L['ABOUT_DISCORD_LINK'] = 'Discord Link'
L['SUPPORT_LINKS'] = 'Support Guild Recruiter Links'