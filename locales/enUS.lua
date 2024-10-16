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

--* General Terms
L['ANTI_SPAM'] = 'Anti-Spam'
L['BLACKLIST'] = 'Blacklist'
L['DELETE_CONFIRMATION'] = 'Are you sure you want to delete this record?'
L['AUTO_LOCKED'] = 'Is now locked.'

-- * GR Home Screen
L['MESSAGE_ONLY'] = 'Message ONLY'
L['GUILD_INVITE_ONLY'] = 'Guild Invite ONLY'
L['GUILD_INVITE_AND_MESSAGE'] = 'Guild Invite and Message'
L['MESSAGE_ONLY_IF_INVITE_DECLINED'] = 'Message Only if Invitation is declined'

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
L['GEN_ACCOUNT_WIDE'] = 'Indicates all your charcters will be effected account wide.'
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

--* Invite Settings
L['ENABLE_BLOCK_INVITE_CHECK'] = 'Enable Check for Blocked Inviting.'
L['ENABLE_BLOCK_INVITE_CHECK_TOOLTIP'] = 'Attempts to check if the player being invited has Block Guild Invites enabled.'
L['INVITE_SETTINGS'] = 'Invite Settings'
L['ENABLED_NOTE'] = 'Note: Disabled items are controlled by GM.'
-- Anti-Spam is under general terms
L['ENABLE_ANTI_SPAM_DESC'] = 'Enable the Anti-Spam feature to prevent spamming players.'
L['ANTI_SPAM_DAYS'] = 'Re-invite Delay'
L['ANTI_SPAM_DAYS_DESC'] = 'Number of days before inviting a player again.'
L['GUILD_WELCOME_MSG'] = 'Guild Chat Welcome Message'
L['GUILD_WELCOME_MSG_DESC'] = 'The message send to guild chat when a new player joins.'
L['WHISPER_WELCOME_MSG'] = 'Whisper Welcome Message'
L['WHISPER_WELCOME_MSG_DESC'] = 'Whispered message sent to a player when they join the guild.'
L['GUILDLINK'] = 'GUILDLINK'
L['GUILDNAME'] = 'GUILDNAME'
L['PLAYERNAME'] = 'PLAYERNAME'

--* GM Specific
L['GM_INVITE_SETTINGS'] = 'GM Settings'
L['GM_INVITE_MESSAGES'] = 'GM Messages'
L['SYNC_MESSAGES'] = 'Sync this message.'
L['SYNC_MESSAGES_DESC'] = 'Sync this message with the guild.'

--* Invite Messages
L['INVITE_MESSAGES'] = 'Invite Messages'
L['PLAYER_SETTINGS_DESC'] = 'Orange colored messages are from the GM.'
L['INVITE_ACTIVE_MESSAGE'] = 'Invite Messages:'
L['INVITE_ACTIVE_MESSAGE_DESC'] = [[
The messages that will be sent to potential recruits.

NOTE: You might need to /rl after a sync to see changes.]]
L['NEW_MESSAGE_DESC'] = 'Add a description of the message to the invite list.'
L['INVITE_DESC'] = 'Description of the invite message:'
L['INVITE_DESC_TOOLTIP'] = 'A description of the invite message.'

L['MAX_CHARS'] = '(<sub> characters per message)'
L['LENGTH_INFO'] = 'Assumes 12 characters when using PLAYERNAME'
L['MESSAGE_LENGTH'] = 'Message Length'

L['MESSAGE_REPLACEMENT_INSTRUCTIONS'] = [[
GUILDLINK - Will create a clickable link to your guild.
GUILDNAME - Will display your guild name.
PLAYERNAME - Will display the invited player's name.]]

-- * BlackList Settings Window
L['BLACKLIST_REMOVE'] = 'Remove Selected Blacklist Entries'
L['ADD_TO_BLACKLIST'] = 'Add player to blacklist.'
L['BL_PRIVATE_REASON'] = 'Toggle Private Reason'
L['BL_PRIVATE_REASON_DESC'] = 'Toggle the private reason for blacklisting.'
L['BL_PRIVATE_REASON_ERROR'] = 'You did not blacklist'

-- * Invalid Settings Window
L['INVALID_ZONE'] = 'Invalid Zones'
L['ZONE_NOT_FOUND'] = 'Could not find zone'
L['ZONE_INSTRUCTIONS'] = 'The zone name must EXACTLY match the zone name in the game.'
L['ZONE_ID'] = 'Zone ID (Numeric ID)'
L['ZONE_NAME'] = 'Name of the Zone:'
L['ZONE_INVALID_REASON'] = 'Reason for being invalid:'
L['ZONE_ID_DESC'] = [[
The zone ID for the invalid zone.
List of instances:
https://wowpedia.fandom.com/wiki/InstanceID
Best World Zone IDs I can Find:
https://wowpedia.fandom.com/wiki/UiMapID
If you find a zone that should be added, please let me know.]]
L['ZONE_NOTE'] = 'Zones with |cFF00FF00*|r are the only editable zones.'
L['ZONE_LIST_NAME'] = 'The following zones will be ignored by the scanner:'

-- * About
L['ABOUT_LINE'] = 'Thank you for using Guild Recruiter, I hope you find this addon useful!'
L['ABOUT_DOC_LINKS'] = 'Documentation and Links'
L['GITHUB_LINK'] = 'GitHub (Support documentation)'
L['ABOUT_DISCORD_LINK'] = 'Discord Link'
L['SUPPORT_LINKS'] = 'Support Guild Recruiter Links'