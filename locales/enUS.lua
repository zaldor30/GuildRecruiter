-- Localization file for English/United States
local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]        = "Player declined the guild invite."
L["PLAYER_ALREADY_IN_GUILD"]       = "That player is already in a guild."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]  = "That player is already in your guild."
L["PLAYER_ALREADY_INVITED_TO_GUILD"]= "That player has already been invited."
L["PLAYER_NOT_FOUND"]              = "Player not found."
L["PLAYER_NOT_PLAYING"]            = "Player is not playing World of Warcraft."
L["PLAYER_IGNORING_YOU"]           = "That player is ignoring you."
L["PLAYER_JOINED_GUILD"]           = "Player has joined a guild."
L["PLAYER_NOT_ONLINE"]             = "Player is not online."
L["PLAYER_IN_GUILD"]               = "Player is in a guild."

--#region General
L["INVITE"] = "Invite"
L["SCAN"] = "Scan"
L["ABOUT"] = "About"
L["CLOSE"] = "Close"
L["ENABLE"] = "Enable"
L["ENABLED"] = "Enabled"
L["DISABLE"] = "Disable"
L["DISABLED"] = "Disabled"
L["REMOVE"] = "Remove"
L["HELP"] = 'Help'
L['CONFIG'] = 'Config'
L["RACE"] = "Race"
L["CLASS"] = "Class"
--#endregion

--#region Button Text
L["CANCEL"] = "Cancel"
L["DELETE"] = "Delete"
L["SAVE"] = "Save"
L["NEW"] = "New"
L["YES"] = "Yes"
L["NO"] = "No"
L["OK"] = "OK"
L['FILTER_SAVE_SUCCESSFUL'] = 'Filter saved successfully.'
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L['BETA_INFORMATION'] = [[This is a VER version of Guild Recruiter.
Please report any issues on our Discord server.]]
L['AUTO_LOCKED'] = 'Moving screen is now locked.'
L['SUPPORT_LINKS'] = 'Support Links'
L['GITHUB_LINK'] = 'GitHub Repository'
L['DISCORD_LINK'] = 'Discord Server'
--#endregion

--#region Frequently used strings
L['ANTI_SPAM'] = 'Anti-Spam'
L['BLACKLIST'] = 'Blacklist'
L['SETTINGS'] = 'Settings'
L['PREVIEW_TITLE'] = 'Selected Message Preview'
--#endregion

--#region General Error Messages
L['NO_GUILD_NAME'] = 'No Guild Name, please reload your UI.'
L['BL_NO_ONE_ADDED'] = 'No one was added to the blacklist.'
L['GUILD_LINK_NOT_FOUND'] = 'Guild Link not found. Please reload your UI.'
L["GUILD_LINK_NOT_FOUND_LINE1"] = "Try /rl or relogging (It may take a few attempts)"
L["GM_GUILD_LINK_NOT_FOUND"] = "Try creating a recruitment in guild finder the /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "Try to sync with the guild to get the guild link."
--#endregion

--#region Context Menu
L['GUILD_INVITE_NO_MESSAGE'] = 'Guild Invite (No Messages)'
L['GUILD_INVITE_WELCOME_MESSAGE'] = 'Guild Invite (Welcome Messages)'
L['BLACKLIST_PLAYER'] = 'Blacklist Player'
L['KICK_PLAYER_FROM_GUILD'] = 'Kick Player from Guild (Add to Blacklist)'
L['KICK_PLAYER_CONFIRMATION'] = 'Are you sure you want to kick %s from the guild?'
--#endregion

--#region Core
L['RECRUITER'] = 'recruiter'
L['DEFAULT_GUILD_WELCOME'] = 'Welcome PLAYERNAME to GUILDNAME!'
L['DATABASE_RESET'] = [[
The database has been reset.
Due to integration of classic and cata, all data has been reset.
I apologize for the inconvenience.
|cFFFFFFFFPlease reload your UI (/rl or /reload).|r]]
L['SLASH_COMMANDS'] = [[
Guild Recruiter Slash Commands:
/rl will reload the WoW UI (like /reload).
/gr help - Displays this help message.
/gr config - Opens the configuration window.
/gr blacklist <player name> - Will add the player to the blacklist.]]
L['MINIMAP_TOOLTIP'] = [[
Left Click: Open Guild Recruiter
Shift+Left Click: Open Scanner
Right Click: Open Config
%AntiSpam in invited list.
%BlackList in blacklisted list.]]
L["NO_LONGER_GUILD_LEADER"] = "is no longer the guild leader."
L["NO_ANTI_SPAM"] = "Anti-Spam is not enabled. Please enable it in the settings."
L["CANNOT_INVITE"] = "You do not have permission to invite new members."
L["NOT_IN_GUILD"] = "Guild Recruiter is disabled because you are not in a guild."
L["NOT_IN_GUILD_LINE1"] = "If you join a guild type /rl to reload."
L['FGI_LOADED'] = '*WARNING* FGI is loaded. Please disable it to use Guild Recruiter.'
--#endregion

--#region Base Screen
L['BACK'] = 'Back'
L['BACK_TOOLTIP'] = 'Go back to previous screen.'
L['LOCK_TOOLTIP'] = 'Toggle moving of window'
L['RESET_FILTER'] = 'Reset Filter'
L['RESET_FILTER_TOOLTIP'] = 'Reset scanner filter to start over.'
L['COMPACT_MODE'] = 'Compact Mode'
L['COMPACT_MODE_TOOLTIP'] = [[Toggle compact mode.
Change the size of the compact mode in the settings.]]
L['ABOUT_TOOLTIP'] = 'Discord info, support info and to contribute, if you wish.'
L['SETTINGS_TOOLTIP'] = 'Change settings for Guild Recruiter.'
L['MANUAL_SYNC'] = 'Manual Sync'
L['MANUAL_SYNC_TOOLTIP'] = 'Manually sync your lists with others in the guild.'
L['VIEW_ANALYTICS'] = 'View Analytics'
L['VIEW_ANALYTICS_TOOLTIP'] = 'Breaks down your stats on inviting people to the guild.'
L['BLACKLIST_TOOLTIP'] = 'Add players from the blacklist.'

L['SELECT_FILTER'] = 'Select Filter or Create New'
L['CUSTOM_FILTER_NAME'] = 'Custom Filter Name'
L['CUSTOM_FILTERS'] = 'Custom Filters'
L['CUSTOM_FILTERS_TOOLTIP'] = 'Add custom filters to the scanner.'
L['CUSTOM_FILTERS_DESC'] = [[
Custom filters allow you to filter players based on specific criteria.
For example, you can filter players by class or race.
]]
L['FILTER_DUPLICATE_NAME'] = 'A filter with that name already exists. Please choose a different name.'
L['FILTER_OVERWRITE'] = ' will be overwritten.\nDo you want to continue?'
L['FILTER_NO_SAVE_NAME'] = 'Please enter a name for the filter.'
L['FILTER_SELECT_CLASS'] = 'Please select at least one class.'
L['FILTER_SELECT_RACE'] = 'Please select at least one race.'
L['FILTER_ALL_SELECTED'] = 'Checking all boxes is the same as default filter.'
L['NEW_FILTER_DESC'] = 'Create a new filter for the scanner.'
L['FILTER_SAVE_LIST'] = 'Save Filter List'
L['FILTER_SAVE_LIST_DESC'] = 'Choose a filter to modify.'
L['FILTER_NAME'] = 'Enter Filter Name:'
L['FILTER_NAME_EXISTS'] = 'Filter name already exists.'
L['FILTER_CLASS'] = 'Choose a Class or Class Combination:'
L['SELECT_ALL_CLASSES'] = 'Select All Classes'
L['CLEAR_ALL_CLASSES'] = 'Clear All Classes'
L['FILTER_SAVED'] = 'Filter saved successfully.'
L['FILTER_DELETED'] = 'Filter deleted successfully.'
L['FILTER_SAVE_ERROR'] = 'Select at least 1 class and/or race.'
--#endregion

--#region Invite Formats
L['MESSAGE_ONLY'] = 'Message ONLY'
L['GUILD_INVITE_ONLY'] = 'Guild Invite ONLY'
L['GUILD_INVITE_AND_MESSAGE'] = 'Guild Invite and Message'
L['MESSAGE_ONLY_IF_INVITE_DECLINED'] = 'Message Only if Invitation is declined'
--#endregion

--#region Invite Code
L['ALREADY_INVITED_STATUS'] = 'Pending'
L['GUILD_INVITE_SENT'] = 'Guild invite sent to'
L['INVITE_MESSAGE_SENT'] = 'Invite message sent to'
L['INVITE_MESSAGE_QUEUED'] = 'Invite message queued to be sent to'
L['GUILD_INVITE_BLOCKED'] = 'Invite message skipped for %s due to blocked guild invites.'
--#endregion

--#region Home Screen
L['SELECT_A_FILTER'] = 'Select a filter'
L['MIN_LEVEL'] = 'Min Level'
L['MAX_LEVEL'] = 'Max Level'
L['MAX_LEVEL_ERROR'] =  'Please enter a number between 1 and '
L['LEVELS_FIXED'] = 'Levels Fixed'
L['LEVELS_TOO_CLOSE'] = 'Caution: Keep level range within 5 levels.'
L['SELECT_INVITE_TYPE'] = 'Select Invite Type'
L['SELECT_INVITE_MESSAGE'] = 'Select Invite Message'
L['CREATE_MESSAGE_IN_SETTINGS'] = 'Create message in settings'
--#endregion

--#region Scanner Screen
L['FILTER_PROGRESS'] = 'Filter Progress'
L['PLAYERS_FOUND'] = 'Players Found'
L['SEND_MESSAGE'] = 'Send Message'
L['SEND_INVITE'] = 'Send Invite'
L['SEND_INVITE_AND_MESSAGE'] = 'Send Invite and Message'
L['BLACKLIST_TITLE'] = 'Add Selected Player(s) to Blacklist'
L['BLACKLIST_SCANNER_TOOLTIP'] = 'Add selected players to the blacklist.'
L['ANTISPAM_TITLE'] = 'Add Selected Player(s) to Anti-Spam List'
L['ANTISPAM_SCANNER_TOOLTIP'] = 'Will add selected players to Anti-Spam list.'
L['WHO_RESULTS'] = 'Who Results: %d Players Found'
L['SCAN_FOR_PLAYERS'] = 'Scan for Players'
L['NEXT_QUERY'] = 'Next Query: %s'
L['NEXT_PLAYER_INVITE'] = 'Next Player to Invite (Queued: %d):'
L['PLAYERS_QUEUED'] = 'Players Queued: %d'
L['NO_QUEUED_PLAYERS'] = 'No players are queued.'
L['WAIT'] = 'Wait'
L['INVITE_FIRST_STEP'] = 'You must first click on Search for Players button.'
L['ADD_TO_ANTISPAM'] = 'Added %d players to Anti-Spam list.'
L['ADD_TO_BLACKLIST'] = 'Added %d players to the blacklist.'
L['SKIP_PLAYER'] = 'Skip Player'
L['SKIP'] = 'Skip'
--endregion

--#region About Screen
-- * Donation Message
L['DONATION_MESSAGE'] = [[
I hope you find this addon useful. I have put a lot of time and effort into
making this addon. If you would like to donate, please use the link below.
Thank you for your support!]]
L['ABOUT_LINK_MESSAGE'] = 'For more information, please visit the following links:'
L['COPY_LINK_MESSAGE'] = 'Links are copyable. Highlight link and copy (CTRL+C).'
--#endregion

--#region Guild Recruiter Settings
L['MAX_CHARS'] = '(<sub> characters per message)'
L['LENGTH_INFO'] = 'Assumes 12 characters when using PLAYERNAME'
L['MESSAGE_LENGTH'] = 'Message Length'
L['GEN_GUILD_WIDE'] = 'Indicates only your current guild will be effected.'
L['GEN_ACCOUNT_WIDE'] = 'Indicates all your characters will be effected account wide.'
L['ENABLED_NOTE'] = 'Blocking invites only works when using Guild Invite and Message.'
L['RELOAD_AFTER_CHANGE'] = 'You must reload your UI (/rl) after making changes.'
L['MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC'] = '' --  Leave blank for now
L['MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1'] = 'GUILDLINK - Will create a clickable link to your guild.'
L['MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2'] = [[
GUILDNAME - Will display your guild name.
PLAYERNAME - Will display the invited player's name.]]
L['GUILDLINK'] = 'GUILDLINK'
L['GUILDNAME'] = 'GUILDNAME'
L['PLAYERNAME'] = 'PLAYERNAME'
--#region General Settings
L['GR_SETTINGS'] = 'GR Settings'
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
L['SEND_MESSAGE_WAIT_TIME'] = 'Send Message Delay'
L['SEND_MESSAGE_WAIT_TIME_DESC'] = 'The time in seconds to wait before sending queued messages (0.1 to 1 second).'
L['AUTO_SYNC'] = 'Enable auto sync'
L['AUTO_SYNC_DESC'] = 'Automatically sync with guild members when logging in.'
L['SHOW_WHISPERS'] = 'Show whispers in chat'
L['SHOW_WHISPERS_DESC'] = [[
Show the message you send to players when inviting.

NOTE: You will need to do a /rl after changing this setting.]]
L['GEN_CONTEXT'] = 'Enable right click invite from chat'
L['GEN_CONTEXT_DESC'] = 'Show the Guild Recruiter context menu when right-clicking a name in chat.'
L['COMPACT_SIZE'] = 'Compact Size'
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
--#endregion
--#region GM Invite Settings
L['GM_INVITE_SETTINGS'] = 'GM Settings'
L['FORCE_OPTION'] = 'Force non-GM to use'
L['ENABLE_BLOCK_INVITE_CHECK'] = 'Enable Check for Blocked Inviting.'
L['ENABLE_BLOCK_INVITE_CHECK_TOOLTIP'] = 'Attempts to check if the player being invited has Block Guild Invites enabled.'
L['ENABLE_ANTI_SPAM_DESC'] = 'Enable the Anti-Spam feature to prevent spamming players.'
L['ANTI_SPAM_DAYS'] = 'Re-invite Delay'
L['ANTI_SPAM_DAYS_DESC'] = 'Number of days before inviting a player again.'
L['GUILD_WELCOME_MSG'] = 'Guild Chat Welcome Message'
L['GUILD_WELCOME_MSG_DESC'] = 'The message send to guild chat when a new player joins.'
L['WHISPER_WELCOME_MSG'] = 'Whisper Welcome Message'
L['WHISPER_WELCOME_MSG_DESC'] = 'Whispered message sent to a player when they join the guild.'
--#endregion
--#region GM Invite Messages
L['GM_INVITE_MESSAGES'] = 'GM Messages'
L['PLAYER_SETTINGS_DESC'] = 'Orange colored messages are from the GM.'
L['INVITE_ACTIVE_MESSAGE'] = 'Invite Messages:'
L['INVITE_ACTIVE_MESSAGE_DESC'] = [[
The messages that will be sent to potential recruits.

NOTE: You might need to /rl after a sync to see changes.]]
L['NEW_MESSAGE_DESC'] = 'Add a description of the message to the invite list.'
L['INVITE_DESC'] = 'Description of the invite message:'
L['INVITE_DESC_TOOLTIP'] = 'A description of the invite message.'
L['SYNC_MESSAGES'] = 'Sync this message.'
L['SYNC_MESSAGES_DESC'] = 'Sync this message with the guild.'

--#endregion
--#region Player Invite Settings
L['INVITE_SETTINGS'] = 'Invite Settings'
L['INVITE_MESSAGES'] = 'Invite Messages'
--#endregion
--#region Blacklist
L['BLACKLIST_REMOVE'] = 'Remove Selected Blacklist Entries'
L['ADD_TO_BLACKLIST'] = 'Add player to blacklist.'
L['BL_PRIVATE_REASON'] = 'Toggle Private Reason'
L['BL_PRIVATE_REASON_DESC'] = 'Toggle the private reason for blacklisting.'
L['BL_PRIVATE_REASON_ERROR'] = 'You did not blacklist'
L['NO_REASON_GIVEN'] = 'No reason given'
L['ADDED_TO_BLACK_LIST'] = 'has been added to the blacklist with the reason %s.'
L['BL_NAME_NOT_ADDED'] = 'was not added to the blacklist.'
L['IS_ON_BLACK_LIST'] = 'is already on the blacklist.'
L['BLACK_LIST_REASON_INPUT'] = 'Please enter a reason for blacklisting %s.'
L['BLACKLIST_NAME_PROMPT'] = [[
Please enter the name of the player
you want to blacklist.

Different realm, add - and the realm name.
(Playername-Realmname)
]]
--#endregion
--#region Invalid Zones
L['INVALID_ZONE'] = 'Invalid Zone'
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
--#endregion
--#endregion

--#region Analytics
L['ANALYTICS'] = 'Analytics'
L['ANALYTICS_DESC'] = 'View your stats on inviting players to the guild.'
L['ANALYTICS_BLACKLISTED'] = 'Players you blacklisted'
L['ANALYTICS_SCANNED'] = 'Total players scanned'
L['ANALYTICS_INVITED'] = 'Players you invited to the guild'
L['ANALYTICS_DECLINED'] = 'Players that declined invite'
L['ANALYTICS_ACCEPTED'] = 'Players that accepted invite'
L['ANALYTICS_NO_GUILD'] = 'Players with no guild found'
L['ANALYTICS_STATS_START'] = 'Stats beginning on'
L['ANALYTICS_SESSION'] = 'Session'
L['ANALYTICS_SESSION_SCANNED'] = 'Scanned'
L['ANALYTICS_SESSION_BLACKLISTED'] = 'Blacklisted'
L['ANALYTICS_SESSION_INVITED'] = 'Invited'
L['ANALYTICS_SESSION_DECLINED'] = 'Declined Invite'
L['ANALYTICS_SESSION_ACCEPTED'] = 'Accepted Invite'
L['ANALYTICS_SESSION_WAITING'] = 'Waiting on'
L['ANALYTICS_SESSION_TIMED_OUT'] = 'Invite Timed Out'
L['ANALYTICS_SESSION_NO_GUILD'] = 'Potential Found'
L['ANALYTICS_SESSION_STARTED'] = 'Session Started'
L['LAST_SCAN'] = 'Last Player Scanned'

L['GUILD_ANALYTICS'] = 'Guild Analytics'
L['PROFILE_ANALYTICS'] = 'Character Analytics'
L['SESSION_ANALYTICS'] = 'Session Analytics'
--#endregion

--#region Sync
L['SYNC_ALREADY_IN_PROGRESS'] = 'Sync is already in progress'
L['SYNC_FAIL_TIMER'] = 'Sync timed out, please try again.'
-- Server
L['AUTO_SYNC_STARTED'] = 'You have initiated an auto sync with your guild.'
L['MANUAL_SYNC_STARTED'] = 'You have initiated a sync with your guild.'
L['SYNC_CLIENTS_FOUND'] = 'You found %d clients to sync with.'
-- Client
L['SYNC_CLIENT_STARTED'] = 'has requested to sync with Guild Recruiter.'
-- Either
L['SYNC_SETTINGS_FAILED'] = 'Failed to prep settings for send.'

-- Errors
L['DATA_WAIT_TIMEOUT'] = 'Did not get data from client(s).'
L['REQUEST_WAIT_TIMEOUT'] = 'Did not get a reply from server.'
L['NO_CLIENTS_FOUND_TO_SYNC_WITH'] = 'No clients found to sync with.'

-- Sync Messages
L['AUTO_SYNC'] = 'Auto Sync'
L['MANUAL_SYNC'] = 'Manual Sync'
L['CLIENT_SYNC'] = 'Client Sync'
L['SYNC_FINISHED'] = 'has finished.'

-- End of Sync Messages
L['SETTINGS_CHANGED'] = 'Settings have been updated.'
L['MESSAGE_LIST_CHANGED'] = 'Message list has been updated.'
L['BLACKLIST_CHANGED'] = 'Blacklist has been updated with %d entries.'
L['ANTISPAM_CHANGED'] = 'Anti-Spam list has been updated with %d entries.'
--#endregion