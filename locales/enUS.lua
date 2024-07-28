--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GuildRecruiter", "enUS", true)

L['TITLE'] = "Guild Recruiter"

-- System Messages
L["player not found"] = true
L["joined the guild"] = true
L['no player named'] = true
L["is already in a guild"] = true
L['is not online'] = true
L['has joined the guild'] = true
L['declines your guild invitation'] = true
L['JOINED_GUILD_MESSAGE'] = ' has joined the guild.'
L['has already been invited to a guild'] = true

-- Generic Terms
L['ENABLED'] = 'is enabled'
L['DISABLED'] = 'is disabled'
L['Disabled'] = true
L['Check All'] = true
L['Uncheck All'] = true

-- Guild Message Replacement keys
L['GUILDLINK'] = true
L['GUILDNAME'] = true
L['PLAYERNAME'] = true

-- Slash Commands
L['help'] = true
L['config'] = true
L['reload'] = true
L['recruiter'] = true
L['blacklist'] = true

-- Error Messages
L['No Guild Name'] = true -- Code variable Replacement
L['No Guild Link'] = true -- Code variable Replacement
L['GUILD_LEADER_INSTRUCTIONS'] = ' was guild leader, but it appears that character is no longer the GM.  Please login to your GM character to update or ignore if you are no longer the GM.'

-- Base Screen
L['Settings'] = true
L['Analytics'] = true
L['Reset Filters'] = true
L['Home'] = true
L['Compact Mode'] = true
L['Create Filter'] = true

L['DONATION_MESSAGE'] = 'Thank you for using Guild Recruiter, if you find this addon useful, please consider donating to help support the addon.  -- Thank you!'

-- Core Startup
L['FIRST_RUN'] = 'You can use "/gr help" or "/recruiter help" to get a list of commands.'
L['ANTI_SPAM_REMOVAL'] = 'Removed %s players from anti-spam list.'
L['BL_REMOVAL'] = ' players were removed from the black list after the 14 day wait period.'

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
L['BAD_GUILD_DATA'] = 'There was an issue accessing the guild data.'
L['GUILD_NOT_FOUND'] = 'No guild found, Guild Recruiter disabled.'
L['DEFAULT_GUILD_WELCOME'] = 'Welcome PLAYERNAME to GUILDNAME!'
L['CANNOT_GUILD_INVITE'] = 'You do not have permission to invite players to the guild.'
L['PLAYER_IN_GUILD'] = 'is already in the guild.'
L['GUILD_LINK_INSTRUCTIONS'] = 'You can create a guild link only after setting up recruitment under "Guild and Communities".  Once you have done that type /rl to create a link.'

-- Home Screen Related
L['You must enter a number between 1 and'] = true
L['Min level must be less than max level set.'] = true
L['Your max level must be equal or larger then minimum.'] = true
L['Recruit Invite Format:'] = true
L['Min Level'] = true
L['Max Level'] = true
L['No message will be sent. Only guild invite will be sent.'] = true
L['Select a message from the list or create one in settings.'] = true

-- Settings Messages Reusable
L['SAVE_DESC'] = 'Save the selected record.'
L['DELETE_DESC'] = 'Delete the selected record.'
L['DELETE_CONFIRMATION'] = 'Are you sure you want to delete this record?'
L['Message Length'] = true
L['(255 characters per message)'] = true
L['assumes 12 characters when using PLAYERNAME).'] = true
L['RELOAD_NOTE'] = 'NOTE: You must reload your UI to take effect (/rl).' -- Code variable Replacement

-- Sync Related
L['Sync'] = true
L['Auto-sync'] = true
L['started'] = true
L['complete'] = true
L['is invalid'] = true
L['Master sync'] = true
L['Sending data requests to client'] = true
L['No clients found to sync with.'] = true
L['Added %s anti-spam records'] = true
L['Added %s black list records'] = true
L['MARKED_FOR_DELETE'] = 'Marked %s black list records for deletion.'
L['Sync data received from'] = true

-- Generic Terms
L['OK'] = true
L['New'] = true
L['Save'] = true
L['Scan'] = true
L['Lock'] = true
L['Races'] = true
L['Start'] = true
L['About'] = true
L['Close'] = true
L['Cancel'] = true
L['Delete'] = true
L['Black List'] = true
L['Please wait'] = true

-- Other
L['Message List'] = true
L['Filter List'] = true

-- Message Formats
L['Message ONLY'] = true
L['Guild Invite ONLY'] = true
L['Guild Invite and Message'] = true

-- Default Filters
L['Default Class Filter'] = true
L['Default Race Filter'] = true

-- Analytic Labels
L['Players Scanned'] = 'Players Scanned'
L['Session Stats'] = true
L['Total Declined'] = 'Declined Invites'
L['Total Invites'] = 'Invites Sent'
L['Pending'] = true
L['Total Accepted'] = 'Accepted Invites'
L['Total Black List'] = 'Players Black Listed'
L['Players on Anti-Spam'] = true

-- Scanner Related
L['ERROR_SCAN_WAIT'] = ' seconds before scanning again.'
L['ERROR_CANNOT_SCAN'] = 'Scanning is disabled.  Please check the addon for information.'
L['Invites:'] = true
L['Invite players to guild'] = true
L['Checked players are for adding to black list.'] = true
L['BL'] = true
L['Black List Players'] = true
L['Selected players will be added to the black list.'] = true
L['ADD_TO_BL_PROMPT'] = 'Are you sure you want to add the\nselected players to the black list?'
L['Ready for invite'] = true
L['Skip players'] = true
L['SKIP_DESC'] = 'Selected players will be skipped and\nnot invited to the guild.'
L['Who Results'] = true
L['Number of players found'] = true
L['Recruit Scanning'] = true
L['Next filter'] = true
L['Unguilded'] = true
L['WHO_NUMBER_FOUND_DESC'] = 'Number of players found'
L['CANNOT_INVITE'] = 'Inviting players is disabled.  Please check the addon for information.'

-- Black List
L['Bulk Add'] = true
L['No Reason'] = true
L['Reason'] = true
L['Add to Blacklist'] = true
L['WHO_TO_BLACK_LIST'] = "Who would you like to Black List?"
L['BL_WARNING_LINE_1'] = 'Spelling counts, include realm name if needed.'
L['BL_WARNING_LINE_2'] = 'Better to to use the context menu.'
L['BL_NAME_NOT_ADDED'] = 'was not added to Black List.'
L['BL_NO_ONE_ADDED'] = 'No one will be added to the black list.'
L['Why do you want to black list?'] = true
L['was added to the black list with %s as a reason.'] = true
L['IS_ON_BLACK_LIST'] = 'is already on the black list.'
L['CONFIRM_BLACK_LIST_INVITE'] = 'Is on the black list.\n \nAre you sure you want to invite this player?'

-- Invite List
L['SENT_LIST_ERROR'] = 'was not added to sent list.'
L['ALREADY_ON_SENT_LIST'] = 'was already on the invited list.'
L['GUILD_INVITE_SENT'] = 'Guild invite was sent to'
L['GUILD_MESSAGE_SENT'] = 'Sent invite message to'

-- Settings Related
L['GEN_ACCOUNT_WIDE'] = ' indicates that this setting affects all guild characters.'
----General Settings
L['General Settings'] = true
L['GEN_TOOLTIPS'] = 'Show General Tooltips'
L['GEN_TOOLTIP_DESC'] = 'Show/Hide basic tooltips.'
L['GEN_ICON'] = 'Show Minimap Icon'
L['GEN_ICON_DESC'] = 'Toggles the visibility of the minimap icon.\n/gr or /recruiter will allow you to open Guild Recruiter.'
L['GEN_CONTEXT'] = 'Enable Context Menu.'
L['GEN_CONTEXT_DESC'] = 'Menu that appears when you right click on a player.  Allows you to invite or black list.'
L['Addon Messages'] = true
L['GEN_WHATS_NEW'] = 'Enable "What\'s New" messages.'
L['GEN_WHATS_NEW_DESC'] = 'Shows a window with change notes for the current version.'
L['GEN_ADDON_MESSAGES'] = 'Display extra messages from the addon.'
L['GEN_ADDON_MESSAGES_DESC'] = 'Displays more detailed messages from the addon.'
L['Keybindings'] = true
L['Keybinding: Invite'] = true
L['KEYBINDING_DESC'] = 'Change the keybinding to invite a player to the guild.'
L['KEY_BOUND_TO_SCAN'] = 'That key is bound to scan, please choose another key.'
L['Keybinding: Scan'] = true
L['KEBINDING_SCAN_DESC'] = 'Change the keybinding to scan for players to invite.'
L['KEY_BOUND_TO_INVITE'] = 'That key is bound to invite, please choose another key.'
L['KEY_BINDING_NOTE'] = 'NOTE: Does not overwrite your WoW binds and are only used in the scanner.'

----GM Settings
L['GM Settings'] = true
L['GM_SETTINGS_DESC'] = 'Note: Guild Masters have access to these settings on all their characters.'
L['GM_ANTI_SPAM'] = 'Enable Anti-Spam'
L['GM_ANTI_SPAM_DESC'] = 'Enable/Disable anti-spam feature (forces others to use this option).'
L['GM_ANTI_SPAM_DAYS'] = 'Can reinvite players after how many days?' -- This is a question
L['GM_ANTI_SPAM_DAYS_DESC'] = 'How many days must pass before you can reinvite a player that has declined your invitation?'
L['Welcome Message'] = true
L['GM_SEND_WELCOME'] = 'Force Welcome Message in Guild Chat.'
L['GM_SEND_WELCOME_DESC'] = 'Enable/Disable sending a welcome message to new guild members.\n(Forces other guild members to use this option.)'
L['GM_WELCOME_MESSAGE'] = 'Welcome Message to new guild members.'
L['GM_WELCOME_MESSAGE_DESC'] = 'This message will be sent to new guild members.\nYou can use PLAYERNAME and GUILDNAME in the message.'
L['Greeting Message'] = true
L['GM_SEND_GREETING'] = 'Force Whispered Greeting Message to New Players.'
L['GM_SEND_GREETING_DESC'] = 'Enable/Disable sending a greeting message to new guild members.\n(Forces other guild members to use this option.)'
L['GM_GREETING_MESSAGE'] = 'Message to whisper to new guild members.'
L['GM_GREETING_MESSAGE_DESC'] = 'This message will be whispered to new guild members.\nYou can use PLAYERNAME and GUILDNAME in the message.'
----GM Messages
L['GM Messages'] = true
L['GM_MESSAGE_DESC_1'] = 'These messages will be pushed out to other officers that can invite players.'
L['GM_MESSAGE_DESC_2'] = ': Clickable link to allow player to join the guild.'
L['GM_MESSAGE_DESC_3'] = ': Guild name ('
L['GM_MESSAGE_DESC_4'] = ': Player name that is being invited to the guild.'
L['GM_MESSAGE_ACTIVE'] = 'Invite Messages'
L['GM_MESSAGE_ACTIVE_DESC'] = 'The messges that will be sent to potential recruits.\n \nNote: You might need to /rl after a sync to see changes.'
------GM Buttons
L['NEW_DESC'] = 'Add a new message.'
L['Invite Description'] = true
L['Short description of the message.'] = true

----Invite Settings
L['Invite Settings'] = true
L['SHOW_WHISPERS'] = 'Show your whisper when sending invite messages.'
L['SHOW_WHISPERS_DESC'] = 'Enable/Disable showing your whisper when sending invite messages.'
L['SCAN_WAIT_TIME'] = 'Time to wait between scans (default recommended).'
L['SCAN_WAIT_TIME_DESC'] = 'WoW requires a cooldown period between /who scans, this is the time that the system will wait between scans.'
L['SCAN_WAIT_TIME_NOTE'] = 'Note: 6 seconds seems to give best results, shorter time yields less results.\nCan be betwee 2 and 10 seconds.'
L['Anti-Spam Settings'] = true
L['ENABLE_ANTI_SPAM'] = 'Anti guild spam protection.'
L['ANTI_SPAM_DESC'] = "Remembers invited players so you don't constantly spam them invites"
L['SEND_WELCOME_DESC'] = 'Enable/Disable sending a welcome message to new guild members.'
L['SEND_WELCOME'] = 'Use Welcome Message in Guild Chat.'
L['WELCOME_MESSAGE_DESC'] = 'This message will be sent to new guild members.'
L['SEND_GREETING'] = 'Use Whispered Greeting Message to New Players.'
L['SEND_GREETING_DESC'] = 'Enable/Disable sending a greeting message to new guild members.'
L['GREETING_MESSAGE_DESC'] = 'This message will be whispered to new guild members.'
L['GM_DISABLE_NOTE'] = 'NOTE: Disabled options are controlled by the Guild Master.'
----Invite Messages
L['Invite Messages'] = true

----Custom Filters
L['Filter'] = true
L['Classes'] = true
L['Races'] = true
L['Choose a filter type'] = true
L['Custom Filters'] = true
L['Select a filter to edit'] = true
L['Create a new filter.'] = true
L['Create/Edit Filter'] = true
L['Filter Name'] = true
L['FILTER_DESC'] = 'Short description of the filter.'
L['FILTER_CREATE_EDIT_DESC'] = 'Edit and/or create your filter.'
L['FILTER_CLASS_NAME'] = 'Classes (Only select "All Classes" or multiple classes)'
L['FILTER_CLASS_NAME_DESC'] = 'Specific class, classes with type of damage, heals or tanks, etc.'
L['FILTER_CLASS_ERROR'] = 'You can only select one group or multiple classes.'
L['RACES_FILTER_DESC'] = 'Choose "All Races" or specific races.'
L['FILTER_RACES_ERROR'] = 'You can only select one group or multiple races.'
L['CLASS_BOX_NAME'] = 'Select either all classes or role.'
L['CLASS_BOX_DESC'] = 'This will filter out all classes except the selected roles.'
L['RACE_BOX_NAME'] = 'Select either all races or roles.'
L['RACE_BOX_DESC'] = 'This will filter out all races except the selected roles.'
L['Who Command'] = 'Who Command Editor (Choose classes/races bellow):'

---- Filter Editor
L['New Filter'] = true
L['Save Filter'] = true
L['Delete Filter'] = true
L['Select Filter'] = true
L['Filter Saved'] = true
L['Filter Name/Desc:'] = true
L['Filter Name Already Exists'] = true

------Cutom Filter Command Instructions
L['Filter Instructions and Commands'] = true
L['FILTER_INSTRUCTIONS_1'] = 'The following commands can be used in filters:'
L['FILTER_INSTRUCTIONS_2'] = 'Player Name (%s): Used to search for a specific character.'
L['FILTER_INSTRUCTIONS_3'] = 'Zone (%s): Used to search for a specific zone.'
L['FILTER_INSTRUCTIONS_4'] =  'Race (%s): Used to search a specific race'
L['FILTER_INSTRUCTIONS_5'] = 'Class (%s): Used to search for a specific class.'
L['FILTER_INSTRUCTIONS_6'] = '* Follow the exact format in the parenthesis. *'
L['FILTER_INSTRUCTIONS_7'] = '* Replace the <command> with correct value. *'
----Black List
L['Players marked in %s are marked for deletion.'] = true
L['Players marked in %s are active black listed players.'] = true
L['Players marked in %s are able to be removed from the list now.'] = true
L['Remove Selected Black List Entries'] = true
L['BLACK_LIST_REMOVE_DESC'] = 'Unsynced black list entries will be removed now.\nBlack List entries marked for deletion will be permanently removed 30 days after marked.  During this time, the addon will ignore the selected Black List entries.'
----Invalid Zones
L['Invalid Zone List'] = true
L['ZONE_LIST_NAME'] = 'The following zones will be ignored by the scanner:'
L['ZONE_LIST_NOTE'] = 'If you find a zone that is not listed, please let me know.'
----About
L['About GR'] = true
L['Documentation Links'] = true
L['ABOUT_LINE_1'] = 'Thank you for using Guild Recruiter, I hope you find this addon useful!'
L['Support %s Links'] = true