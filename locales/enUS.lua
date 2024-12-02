-- Localization file for English/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GuildRecruiter", "enUS", true)
if not L then return end

L['CLASSIC_WARNING'] = [[
This version only works for Retail WoW.
In Curseforge, right click on Guild Recruiter
and select Release Type Beta for Classic WoW
and Cata WoW.
]]

-- * General
L["TITLE"] = "Guild Recruiter"
L["INVITE"] = 'Invite'
L["SCAN"] = 'Scan'
L["ABOUT"] = 'About'
L["CLOSE"] = 'Close'
L["CANCEL"] = 'Cancel'
L["SAVE"] = 'Save'
L["YES"] = 'Yes'
L["NO"] = 'No'
L["OK"] = 'OK'
L["ENABLE"] = 'Enable'
L["DISABLE"] = 'Disable'
L["REMOVE"] = 'Remove'
L["NEW"] = 'New'
L["DELETE"] = 'Delete'

-- * WoW System Message Translations
--! MUST BE IN LOWERCASE!
L['PLAYER_NOT_ONLINE'] = "is not online"
L['PLAYER_NOT_PLAYING'] = "is currently playing"
L['NO_PLAYER_NAMED'] = "no player named"
L['PLAYER_NOT_FOUND'] = "no player named" -- Duplicate removed
L['PLAYER_IN_GUILD'] = "has already been invited to a guild"
L['PLAYER_ALREADY_IN_GUILD'] = "is already in a guild"
L['PLAYER_JOINED_GUILD'] = "has joined the guild"
L['PLAYER_DECLINED_INVITE'] = "declines your guild invitation"

--? 3.3.56 Changes
L['NO_WHISPER_MESSAGE'] = 'You selected whisper greeting message, but do not have one.'
L['NO_GREETING_MESSAGE'] = 'You selected guild greeting message, but do not have one.'
L['SYNC_TIMED_OUT'] = 'Sync failed to respond.'
L['FINDING_CLIENTS_SYNC'] = 'Finding players to sync with.'
L['SYNC_REQUEST_RECEIVED'] = 'Sync request received from'
L['CLIENTS_FOUND'] = 'players found to sync with:'
L['NO_REASON_GIVEN'] = 'No reason given.'

L['PLAYER_IS_IN_GUILD'] = 'is already in the guild.'
L['PLAYER_IS_ON_BLACKLIST'] = 'is on the blacklist.'
L['PLAYER_IS_ON_ANTISPAM_LIST'] = 'is on the Anti-Spam list.'
L['PLAYER_MANUAL_ON_BLACKLIST'] = 'is on the blacklist.\nReason: %REASON%\n\nDo you want to invite them to the guild?'

--? 3.2 Changes
L['SYNC_ALREADY_IN_PROGRESS'] = 'Sync already in progress with'
L['NO_CLIENTS_FOUND'] = 'No clients found to sync with.'
L['NO_BLACKLISTED_ADDED'] = 'No blacklisted players added.'
L['NO_ANTISPAM_ADDED'] = 'No players added to the Anti-Spam list.'
L['CLIENT_REQUEST_DATA_TIMEOUT'] = 'Data request timeout for'
L['FAILED_TO_RECEIVE_SYNC_DATA'] = 'Failed to receive sync data from'
L['OUTDATED_VERSION'] = 'is using an outdated version'
L['OLDER_VERSION'] = 'is using an older version'
L['NEWER_VERSION'] = 'is using a newer version'
L['NOT_GUILD_LEADER'] = 'This character is not the guild leader.  Make sure you log into the new guild leader.'

-- * Donation Message
L['DONATION_MESSAGE'] = [[
I hope you find this addon useful. I have put a lot of time and effort into
making this addon. If you would like to donate, please use the link below.
Thank you for your support!]]

-- * GR Basic Command Messages
L['INVITE_MESSAGES_MENU'] = 'Invite with Messages'
L['INVITE_NO_MESSAGES_MENU'] = 'Invite without Messages'
L['DELETE_CONFIRMATION'] = 'Are you sure you want to delete this record?'
L['ABOUT_TOOLTIP'] = 'See What\'s New and support info.'
L['PLEASE_WAIT'] = 'Please wait'
L['ERROR_SCAN_WAIT'] = 'seconds before scanning again.'

--? Version 3.0 Changes

-- * GR Icon Bar
L['LOCK'] = 'Lock'
L['LOCK_TOOLTIP'] = 'Lock or unlock the window from repositioning.'
L['SETTINGS'] = 'Settings'
L['SETTINGS_TOOLTIP'] = 'Open the Guild Recruiter settings window.'
L['SYNC'] = 'Sync'
L['SYNC_TOOLTIP'] = 'Manual sync with guild members.'
L['ANALYTICS'] = 'Analytics'
L['ANALYTICS_TOOLTIP'] = 'View the analytics window.'
L['BLACKLIST'] = 'Blacklist'
L['NO_REASON'] = 'No reason given.'
L['BLACKLIST_TOOLTIP'] = 'Add a player to the blacklist.'
L['BLACK_LIST_REASON_INPUT'] = 'Why do you want to blacklist?'
L['BL_NAME_NOT_ADDED'] = 'Black list name not added.'
L['ADDED_TO_BLACK_LIST'] = 'was added to the blacklist with %s as a reason.'
L['FILTER_EDITOR'] = 'Filter Editor'
L['FILTER_EDITOR_TOOLTIP'] = 'Open the filter editor window.'
L['COMPACT_MODE'] = 'Compact Mode'
L['COMPACT_MODE_TOOLTIP'] = 'Toggle compact scanner compact mode.'
L['RESET_FILTER'] = 'Reset Filter'
L['RESET_FILTER_TOOLTIP'] = 'Reset the filter to the restart scan.'
L['FILTERS'] = 'Filters'

-- * Icon Menu and Slash Commands
L["HELP"] = 'help'
L["CONFIG"] = 'config'
L["RELOAD"] = 'reload'
L["RECRUITER"] = 'recruiter'
L['HOME_BUTTON'] = 'Home'

-- * GR General Messages
L['IS_ENABLED'] = 'is enabled.'

-- * Default Values
L['DEFAULT_GUILD_WELCOME'] = 'Welcome PLAYERNAME to GUILDNAME!'
L['GUILDLINK'] = 'GUILDLINK'
L['GUILD_LINK_NOT_FOUND'] = 'No Guild Link'
L['GUILDNAME'] = 'GUILDNAME'
L['NO_GUILD_NAME'] = 'No Guild Name'
L['PLAYERNAME'] = 'PLAYERNAME'
L['NO_PLAYER_NAME'] = 'player'
L['BLACK_LIST'] = 'Blacklist'
L['OK_INVITE'] = 'Do you want to invite anyway?'
L['INVITE_REJECTED'] = 'Message not sent, appears player has Block Guild Invites on.'
L['NO_INVITE_MESSAGE'] = 'No message selected. Please select a message at the home screen.'
L['INVITE_IN_GUILD'] = 'is already in the guild'
L['IS_ON_SPAM_LIST'] = 'is on the Anti-Spam list'
L['GUILD_INVITE_SENT'] = 'Guild invite sent to'
L['INVITE_MESSAGE_SENT'] = 'Invite message sent to'
L['INVITE_ALREADY_SENT'] = 'has already been invited'
L['NO_GUILD_LINK'] = 'No guild link found. Sync with GM or log into a GM character.'
L['NO_GUILD_LINK2'] = 'Try reloading your UI (/rl) and see if you get the message again (might have to do this a couple times.).'
L['SELECT_MESSAGE'] = 'Select a message from the list or create one in settings.'
L['FORCE_ANTI_SPAM'] = 'Force Anti-Spam'
L['FORCE_ANTI_SPAM_DESC'] = 'Force the Anti-Spam feature to prevent spamming players.'

--* GR Filter Messages
L['FILTERS'] = 'Filters'
L['DELETE_FILTER'] = 'Delete Filter'
L['DELETE_FILTER_CONFIRM'] = 'Are you sure you want to delete this filter?'
L['FILTER_DESC'] = 'Description of the filter'
L['WHO_COMMAND'] = 'Who Command'
L['CLASSES'] = 'Classes'
L['RACES'] = 'Races'

-- * GR Scanner Messages
L['BL'] = 'BL'
L['BLACK_LISTED'] = 'Black listed'
L['IS_ON_BLACK_LIST'] = 'is on the Blacklist.'
L['BLACK_LIST_CONFIRM'] = 'Are you sure you want to add this player to the blacklist?'
L['ANTI_SPAM'] = 'Anti-Spam'
L['READY_INVITE'] = 'Ready to invite'
L['BL_ADD_PLAYER'] = 'Add Player to blacklist'
L['SKIP'] = 'Skip'
L['SKIP_DESC'] = 'Skip the current player and move to the next player.'
L['WHO_RESULTS'] = 'Who Results'
L['NEXT_FILTER'] = 'Next Query'
L['FILTER_PROGRESS'] = 'Filter Progress'
L['RESETTING_FILTERS'] = 'Resetting filters on next scan.'
L['NUMBER_PLAYERS_FOUND'] = 'Number of players found'
L['INVITE_BUTTON_TOOLTIP'] = 'Invite player to the guild.'
L['INVITE_BUTTON_BODY_TOOLTIP'] = [[Only unchecked players will be invited.
Checked players are for blacklist and skip.]]
L['BL_BUTTON_TOOLTIP'] = 'Add player to the blacklist.'
L['BL_BUTTON_BODY_TOOLTIP'] = [[Add the player to the blacklist and skip to the next player.
Can only invite if no players are checked.]]
L['SKIP_BUTTON_TOOLTIP'] = 'Skip player and move to the next player.'
L['SKIP_BUTTON_BODY_TOOLTIP'] = [[Skip the current player and move to the next player.
This will add the player to already invited and will try to
invite the player after the anti-spam expires.
Can only invite if no players are checked.]]

-- * Analytics
L['TOTAL_SCANNED'] = 'Players Scanned'
L['TOTAL_INVITED'] = 'Players Invited'
L['INVITES_PENDING'] = 'Invites Pending'
L['TOTAL_DECLINED'] = 'Invites Declined'
L['TOTAL_ACCEPTED'] = 'Invites Accepted'
L['TOTAL_BLACKLISTED'] = 'Blacklisted'
L['TOTAL_ANTI_SPAM'] = 'Players on Anti-Spam'
L['SESSION_STATS'] = 'Session Stats'

-- * GR Core Messages
L['FIRST_TIME_INFO'] = [[
Welcome to Guild Recruiter!
You can access by right clicking on the minimap icon
or by typing /gr config. Left click on the minimap
icon to open the recruitment window.
If you have any issues, click on the About menu
option to get our Discord link.
IMPORTANT: Please type /rl to reload your UI, just the one time.]]
L['NEW_VERSION_INFO'] = [[
Guild Recruiter has been updated!
Please check the "What's New?" for what has changed.]]
L['BETA_INFORMATION'] = [[This is a VER version of Guild Recruiter.
Please report any issues on our Discord server.]]

-- * GR Error Messages
L['NO GUILD'] = "You are not in a guild."
L['NOT_LOADED'] = 'Guild Recruiter will not load.'
L['CANNOT_INVITE'] = 'You do not have permission to invite to the guild.'

-- * GR Slash Commands
L['SLASH_COMMANDS'] = [[
Guild Recruiter Slash Commands:
/rl will reload the WoW UI (like /reload).
/gr help - Displays this help message.
/gr config - Opens the configuration window.
/gr blacklist <player name> - Will add the player to the blacklist.]]

-- * GR Minimap Icon Tooltip
-- Keep %AntiSpam and %BlackList in the tooltip.
L['MINIMAP_TOOLTIP'] = [[
Left Click: Open Guild Recruiter
Shift+Left Click: Open Scanner
Right Click: Open Config
%AntiSpam in invited list.
%BlackList in blacklisted list.]]

-- * GR Home Screen
L['MESSAGE_ONLY'] = 'Message ONLY'
L['GUILD_INVITE_ONLY'] = 'Guild Invite ONLY'
L['GUILD_INVITE_AND_MESSAGE'] = 'Guild Invite and Message'
L['MESSAGE_ONLY_IF_INVITE_DECLINED'] = 'Message Only if Invitation is declined'
L['CLASS_FILTER'] = 'Default Class Filter'
L['RACE_FILTER'] = 'Default Race Filter'
L['INVITE_FORMAT'] = 'Recruit Invite Format:'
L['MIN_LVL'] = 'Min Level:'
L['MAX_LVL'] = 'Max Level:'
L['MESSAGE_LIST'] = 'Invite Messages'
L['INVITE_MESSAGE_ONLY'] = 'Send Invite Message Only'

-- * GR Error Message
L['INVALID_LEVEL'] = 'You must enter a number between 1 and'
L['MIN_LVL_HIGHER_ERROR'] = 'The minimum level must be higher than the maximum level.'
L['MAX_LVL_LOWER_ERROR'] = 'The maximum level must be lower than the minimum level.'

-- * GR Config Window Messages
L['GENERAL_SETTINGS'] = 'General Settings'
L['SYSTEM_SETTINGS'] = 'System Settings'
L['INVITE_SCAN_SETTINGS'] = 'Invite and Scan Settings'
L['MESSAGE_REPLACEMENT_INSTRUCTIONS'] = [[
GUILDLINK - Will create a clickable link to your guild.
GUILDNAME - Will display your guild name.
PLAYERNAME - Will display the invited player's name.]]
L['INVITE_DESC'] = 'Description of the invite message:'
L['INVITE_DESC_TOOLTIP'] = 'A description of the invite message.'
L['INVITE_ACTIVE_MESSAGE'] = 'Invite Messages:'
L['INVITE_ACTIVE_MESSAGE_DESC'] = 'The messages that will be sent to potential recruits. Note: You might need to /rl after a sync to see changes.'
L['NEW_MESSAGE_DESC'] = 'Add a description of the message to the invite list.'

-- * GR Config Window Tooltips
L['GEN_TOOLTIPS'] = 'Show all tooltips'
L['GEN_TOOLTIP_DESC'] = 'Show all tooltips in the Guild Recruiter addon'
L['GEN_MINIMAP'] = 'Show Minimap Icon'
L['GEN_MINIMAP_DESC'] = 'Show the Guild Recruiter minimap icon.'
L['GEN_CONTEXT'] = 'Enable inviting from chat'
L['GEN_CONTEXT_DESC'] = 'Show the Guild Recruiter context menu when right-clicking a name in chat.'
L['GEN_WHATS_NEW'] = 'Show What\'s New?'
L['AUTO_SYNC'] = 'Enable auto sync at login'
L['AUTO_SYNC_DESC'] = 'Automatically sync with guild members when logging in.'
L['SHOW_WHISPERS'] = 'Show whispers |cFF00FF00 Use /rl|r'
L['SHOW_WHISPERS_DESC'] = 'Show the message you send to players when inviting.'
L['SCAN_WAIT_TIME'] = 'Scan delay in seconds'
L['SCAN_WAIT_TIME_DESC'] = 'The time in seconds to wait before scanning for players (2 to 10 seconds).'
L['GEN_WHATS_NEW_DESC'] = 'Show the What\'s New? window when Guild Recruiter is updated.'
L['GEN_ADDON_MESSAGES'] = 'Show System Messages'
L['GEN_ADDON_MESSAGES_DESC'] = 'Show system messages from Guild Recruiter.'
L['KEYBINDING_HEADER'] = 'Keybindings'
L['KEYBINDING_INVITE'] = 'Invite Keybinding'
L['KEYBINDING_INVITE_DESC'] = 'Keybinding to invite a player to the guild.'
L['KEYBINDING_SCAN'] = 'Scan Keybinding'
L['KEYBINDING_SCAN_DESC'] = 'Keybinding to scan for players looking for a guild.'
L['KEY_BINDING_NOTE'] = 'Note: Keybinds will not affect WoW keybindings.'
L['GEN_ACCOUNT_WIDE'] = 'Indicates all your charcters will be effected guild wide.'

-- * GR GM Settings Window
L['GM_SETTINGS'] = 'GM Settings'
L['GM_SETTINGS_DESC'] = 'Create a message description then the message itself and the save will enable.'
L['PLAYER_SETTINGS_DESC'] = 'Orange colored messages are from the GM.'
L['GM_FORCE_DESC1'] = 'The force check box allows you to make guild members use those settings.'
L['GM_FORCE_DESC2'] = 'Leave un-checked to allow guild members to change those options.'
L['MAX_CHARS'] = '(<sub> characters per message)'
L['LENGTH_INFO'] = 'Assumes 12 characters when using PLAYERNAME'
L['MESSAGE_LENGTH'] = 'Message Length'
L['BL_PRIVATE_REASON'] = 'Toggle Private Reason'
L['BL_PRIVATE_REASON_DESC'] = 'Toggle the private reason for blacklisting.'
L['BL_PRIVATE_REASON_ERROR'] = 'You did not blacklist'

-- * GR GM Invite Settings Window
L['GM_INVITE'] = 'GM Messages'
L['ENABLED_NOTE'] = 'Note: Disabled items are controlled by GM.'
L['OVERRIDE_GM_SETTINGS'] = 'Override GM Settings'
L['OVERRIDE_GM_SETTINGS_DESC'] = 'Override the GM settings for this character.'

-- * GR Invite Settings Window
L['INVITE_SETTINGS'] = 'Invite Settings'
L['WELCOME_MESSAGES'] = 'Welcome Messages'
L['ENABLE_ANTI_SPAM'] = 'Anti-Spam'
L['ENABLE_ANTI_SPAM_DESC'] = 'Enable the Anti-Spam feature to prevent spamming players.'
L['ANTI_SPAM_DAYS'] = 'Re-invite Delay'
L['ANTI_SPAM_DAYS_DESC'] = 'Number of days before inviting a player again.'
L['GUILD_WELCOME_MSG'] = 'Guild Welcome Message'
L['GUILD_WELCOME_MSG_DESC'] = 'The message to send to guild chat when a new player joins.'
L['WHISPER_WELCOME_MSG'] = 'Whisper Welcome Message'
L['WHISPER_WELCOME_MSG_DESC'] = 'Whispered message sent to a player when they join the guild.'
L['FORCE_MESSAGE_LIST'] = 'Force these messages as only ones to be used.'
L['FORCE_MESSAGE_LIST_DESC'] = 'Other guild members will not be able to make their own messages.'
L['SYNC_MESSAGES'] = 'Sync this message.'
L['SYNC_MESSAGES_DESC'] = 'Sync this message with the guild.'
L['FORCE_WHISPER_MESSAGE'] = 'Force Whisper Message'
L['FORCE_WHISPER_MESSAGE_DESC'] = 'Force the following whisper message to be sent to the player.'
L['FORCE_WHISPER_WELCOME_MSG_DESC'] = 'Force the whisper message to be sent to the player.'
L['FORCE_GUILD_GREETING'] = 'Force Guild Greeting'
L['FORCE_GUILD_GREETING_DESC'] = 'Force the guild greeting message to be sent to the guild chat.'
L['FORCE_GUILD_MESSAGE'] = 'Force Guild Greeting Message'
L['FORCE_GUILD_MESSAGE_DESC'] = 'Force the following message to be sent to the guild chat.'
L['FORCE_ENABLE_BLOCK_INVITE_CHECK'] = 'Force Block Check'
L['FORCE_ENABLE_BLOCK_INVITE_CHECK_DESC'] = 'Force the Block Invite Check to be enabled.'
L['ENABLE_BLOCK_INVITE_CHECK'] = 'Enable Block Check'
L['ENABLE_BLOCK_INVITE_CHECK_DESC'] = 'Attempts to ignore players that have Block Guild Invites turned on.'

-- * GR Invite Messages Window
L['INVITE_MESSAGES'] = 'Invite Messages'
L['INVITE_MESSAGES_DESC'] = [[These messages are separate from the GM synced messages.
They are tied only to your guild characters.]]

-- * BlackList Settings Window
L['BLACK_LIST'] = 'Blacklist'
L['BLACK_LIST_REMOVE'] = 'Remove Selected Blacklist Entries'
L['ADD_TO_BLACK_LIST'] = 'Add player to blacklist.'

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

--* 3.0.37+
L['KEEP_ADDON_OPEN'] = 'Keep the addon open - do /rl after changing'
L['KEEP_ADDON_OPEN_DESC'] = 'Keep the addon open and ignore ESC and other things that could close it.'
