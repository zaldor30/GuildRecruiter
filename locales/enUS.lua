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

-- * GR Basic Command Messages
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
L['NEW'] = 'New'
L['SAVE'] = 'Save'
L['DELETE'] = 'Delete'
L['DELETE_CONFIRMATION'] = 'Are you sure you want to delete this record?'
L['ABOUT'] = 'About'
L['ABOUT_TOOLTIP'] = 'See What\'s New and support info.'
L['PLEASE_WAIT'] = 'Please wait'
L['ERROR_SCAN_WAIT'] = ' seconds before scanning again.'

-- *? Version 3.0 Changes

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
L['BLACKLIST_TOOLTIP'] = 'Add a player to the blacklist.'
L['FILTER_EDITOR'] = 'Filter Editor'
L['FILTER_EDITOR_TOOLTIP'] = 'Open the filter editor window.'
L['COMPACT_MODE'] = 'Compact Mode'
L['COMPACT_MODE_TOOLTIP'] = 'Toggle compact scanner compact mode.'
L['RESET_FILTER'] = 'Reset Filter'
L['RESET_FILTER_TOOLTIP'] = 'Reset the filter to the restart scan.'
L['FILTERS'] = 'Filters'

-- * Icon Menu and Slash Commands
L["HELP"] = 'help'
L["CONFIG"] = 'cofig'
L["RELOAD"] = 'reload'
L["RECRUITER"] = 'recruiter'
L["BLACKLIST"] = 'blacklist'
L['HOME_BUTTON'] = 'Home'

-- * GR General Messages
L['IS_ENABLED'] = 'is enabled.'

-- * Default Values
L['DEFAULT_GUILD_WELCOME'] = 'Welcome PLAYERNAME to GUILDNAME!' -- Default Guild Welcome Message
L['GUILDLINK'] = 'GUILDLINK' -- Guild Link Keyword
L['GUILD_LINK_NOT_FOUND'] = 'No Guild Link' -- No Guild Link Message
L['GUILDNAME'] = 'GUILDNAME' -- Guild Name Keyword
L['NO_GUILD_NAME'] = 'No Guild Name' -- No Guild Name Message
L['PLAYERNAME'] = 'PLAYERNAME' -- Player Name Keyword
L['NO_PLAYER_NAME'] = 'player' -- No Player Name Message
L['BLACK_LIST'] = 'Black List' -- Black List Keyword

-- * GR scanner Messages
L['BL'] = 'BL' -- Button Abbreviation for Black List
L['INVITE'] = 'Invite'
L['READY_INVITE'] = 'Ready to invite'
L['BL_ADD_PLAYER'] = 'Add Player to black list'
L['SKIP'] = 'Skip'
L['SKIP_DESC'] = 'Skip the current player and move to the next player.'
L['WHO_RESULTS'] = 'Who Results'
L['NEXT_FILTER'] = 'Next Query'
L['RESETTING_FILTERS'] = 'Resetting filters on next scan.'
L['NUMBER_PLAYERS_FOUND'] = 'Number of players found'
L['INVITE_BUTTON_TOOLTIP'] = 'Invite player to the guild.'
L['INVITE_BUTTON_BODY_TOOLTIP'] = [[Only unchecked players will be invited.

Checked players are for black list and skip.]]
L['BL_BUTTON_TOOLTIP'] = 'Add player to the blacklist.'
L['BL_BUTTON_BODY_TOOLTIP'] = [[Add the player to the blacklist and skip to the next player.

Can only invite if no players are checked.]]
L['SKIP_BUTTON_TOOLTIP'] = 'Skip player and move to the next player.'
L['SKIP_BUTTON_BODY_TOOLTIP'] = [[Skip the current player and move to the next player.
This will add the player to already invited and will try to
invite the player after the anti-spam expires.

Can only invite if no players are checked.]]
-- Analytics
L['TOTAL_SCANNED'] = 'Players Scanned'
L['TOTAL_INVITED'] = 'Players Invited'
L['INVITES_PENDING'] = 'Invites Pending'
L['TOTAL_DECLINED'] = 'Invites Declined'
L['TOTAL_ACCEPTED'] = 'Invites Accepted'
L['TOTAL_BLACKLISTED'] = 'Black Listed'

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
You are using a VER version of Guild Recruiter.
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
Shift+Left Click: Open Scanner
Right Click: Open Config

%AntiSpam in invited list.
%BlackList in blacklisted list.]]

-- * GR Home Screen
L['SCAN'] = 'Scan'
L['MESSAGE_ONLY'] = 'Message ONLY' -- Invite Message Only
L['GUILD_INVITE_ONLY'] = 'Guild Invite ONLY' -- Guild Invite Only
L['GUILD_INVITE_AND_MESSAGE'] = 'Guild Invite and Message' -- Guild Invite and Message
L['MESSAGE_ONLY_IF_INVITE_DECLINED'] = 'Message Only if Invitation is declined' -- Message Only if Invitation is declined
L['CLASS_FILTER'] = 'Default Class Filter' -- Default Class Filter
L['RACE_FILTER'] = 'Default Race Filter' -- Default Race Filter
L['INVITE_FORMAT'] = 'Recruit Invite Format:' -- Recruit Invite Format
L['MIN_LVL'] = 'Min Level:' -- Minimum level
L['MAX_LVL'] = 'Max Level:' -- Maximum level
L['MESSAGE_LIST'] = 'Invite Messages' -- Invite Messages
L['GUILD_INVITE_ONLY'] = 'No message will be sent. Only guild invite will be sent.'
L['SELECT_MESSAGE'] = 'Select a message from the list or create one in settings.'

-- * GR Error Message
L['INVALID_LEVEL'] = 'You must enter a number between 1 and'
L['MIN_LVL_HIGHER_ERROR'] = 'The minimum level must be higher than the maximum level.'
L['MAX_LVL_LOWER_ERROR'] = 'The maximum level must be lower than the minimum level.'

-- * GR Config Window Messages
L['General Settings'] = true

-- ? GR Config Window General Settings
L['MESSAGE_REPLACEMENT_INSTRUCTIONS'] = [[
GUILDLINK - Will create a clickable link to your guild.
GUILDNAME - Will display your guild name.
PLAYERNAME - Will display the invited player's name.]]

L['INVITE_DESC'] = 'Description of the invite message:'
L['INVITE_DESC_TOOLTIP'] = 'A description of the invite message.'
L['INVITE_ACTIVE_MESSAGE'] = 'Invite Messages:'
L['INVITE_ACTIVE_MESSAGE_DESC'] = [['The messges that will be sent to potential recruits.
Note: You might need to /rl after a sync to see changes.']]
L['NEW_MESSAGE'] = 'New'
L['NEW_MESSAGE_DESC'] = 'Add a description of the message to the invite list.'
-- ? GR Config Window Tooltips
L['GEN_TOOLTIPS'] = 'Show all tooltips'
L['GEN_TOOLTIP_DESC'] = 'Show all tooltips in the Guild Recruiter addon'
L['GEN_MINIMAP'] = 'Show Minimap Icon'
L['GEN_MINIMAP_DESC'] = 'Show the Guild Recruiter minimap icon.'
L['GEN_CONTEXT'] = 'Enable inviting from chat'
L['GEN_CONTEXT_DESC'] = 'Show the Guild Recruiter context menu when right clicking a name in chat.'
L['GEN_WHATS_NEW'] = 'Show What\'s New?'
L['AUTO_SYNC'] = 'Auto sync at login'
L['AUTO_SYNC_DESC'] = 'Automatically sync with guild members when logging in.'
L['SHOW_WHISPERS'] = 'Show whispers'
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
L['KEY_BINDING_NOTE'] = 'Note: Keybinds will not effect WoW keybindings.'
L['GEN_ACCOUNT_WIDE'] = 'indicates effects all guild-wide characters'
-- ? GR GM Settings Window
L['GM_SETTINGS'] = 'GM Settings'
L['GM_SETTINGS_DESC'] = 'Note: Guild Masters have access to these settings on all their characters.'
L['MAX_CHARS'] = '(<sub> characters per message)' -- Max Characters per message
L['LENGTH_INFO'] = 'Assumes 12 characters when using PLAYERNAME'
L['MESSAGE_LENGTH'] = 'Message Length' -- Message Length Keyword
-- ? GR GM Invite Settings Window
L['GM_INVITE'] = 'GM Messages'
L['ENABLED_NOTE'] = 'Note: Disabled items are controlled by GM.'
L['OVERRIDE_GM_SETTINGS'] = 'Override GM Settings'
L['OVERRIDE_GM_SETTINGS_DESC'] = 'Override the GM settings for this character.'
--? GR Not GM Invite Settings Window
L['INVITE_SETTINGS'] = 'Invite Settings'
L['ENABLE_ANTI_SPAM'] = 'Enable Anti-Spam'
L['ENABLE_ANTI_SPAM_DESC'] = 'Enable the Anti-Spam feature to prevent spamming players.'
L['ANTI_SPAM_DAYS'] = 'Re-invite Delay'
L['ANTI_SPAM_DAYS_DESC'] = 'Number of days before inviting a player again.'
L['GUILD_WELCOME_MSG'] = 'Guild Welcome Message'
L['GUILD_WELCOME_MSG_DESC'] = 'The message to send to guild chat when a new player joins.'
L['WHISPER_WELCOME_MSG'] = 'Whisper Welcome Message'
L['WHISPER_WELCOME_MSG_DESC'] = 'Whispered message sent to a player when they join the guild.'
--? GR Invite Messages Window
L['INVITE_MESSAGES'] = 'Invite Messages'
--? BlackList Settings Window
L['BLACK_LIST'] = 'Black List'
L['BLACK_LIST_REMOVE'] = 'Remove Selected Black List Entries'
--? Invalid Settings Window
L['INVALID_ZONE'] = 'Invalid Zones'
L['ZONE_ID'] = 'Zone ID (Numeric ID)'
L['ZONE_NAME'] = 'Name of the Zone:'
L['ZONE_TYPE'] = 'Type of Zone:'
L['ZONE_ID_DESC'] = [[
The zone ID for the invalid zone.

List of instances:
    https://wowpedia.fandom.com/wiki/InstanceID

Best World Zone IDs I can Find:
    https://wowpedia.fandom.com/wiki/UiMapID
    
If you find a zone that should be added, please let me know.]]
L['ZONE_NOTE'] = 'Zones with |cFF00FF00*|r are the only editable zones.'
L['ZONE_LIST_NAME'] = 'The following zones will be ignored by the scanner:'
L['ABOUT_LINE'] = 'Thank you for using Guild Recruiter, I hope you find this addon useful!'
L['ABOUT_DOC_LINKS'] = 'Documentation and Links'
L['GITHUB_LINK'] = 'GitHub (Support documentation)'
L['ABOUT_DISCORD_LINK'] = 'Discord Link'
L['SUPPORT_LINKS'] = 'Support Guild Recruiter Links'