# Guild Recruiter
## 2.2.54
- Fixed settings
## 2.2.53
- War within Update
## 2.2.52
- Forgot to enable old dungeons and raids when inviting players.
## 2.2.51
- Fix issue give nil error when filter is finished and will now restart.
## 2.2.50
- Fix issue give nil error when trying to skip/black list a player.
- Fix issue with min/max level not working properly.

## 2.2.49
  Sorry all, have been taking a break from WoW and my computer for a bit.  I am back
  and if you have an issue, please let me know in Discord or on CurseForge (quciker
  response in Discord).  I will be working on the addon again and getting the filter
  working soon, been kicking my butt.

- Bump in World of Warcraft versioning for 10.2.7
- Fixed an issue where Start Search would not work.
  If you were having an issue clicking on players, let me know if still an issue.

## 2.2.48
- Bump in World of Warcraft versioning for 10.2.6

## 2.2.47
- Fixed an specifying levels and then having to /rl before it would work.
- Fixed issue with sending a welcome/greeting message when inviting from chat.
- Fixed type in settings (HIDE minimap icon, should be SHOW minimap icon).

## 2.2.45
- Fixed an issue with not being able to create/edit non-GM messages.

## 2.2.44
- Fixed an issue on single server realms, checking names would cause LUA error.

## 2.2.43
- WARNING!! Data will be reset with this update.  This is due to the new database structure.
- NOTE: Custom filters are under construction!!  They will be back soon.
- Database maintenance.
- Removed old unused variables.
- Cleaned up where data is stored.
- Moved more settings to guild wide versus character.
- Fixed when GM has changed the current GM will be come invalidated in the addon.
- Added instructions on how to get a guild link.
- Lots of clean up and fixes to settings.
- Made many settings guild wide so you do not have to change them on each character.
- Some UI tweaks and improvements.
- Rework to sync to make it more reliable.
- Added saving of session data for later updates.
- Added total counts for invited players and black list to analytics.
- Scans will now resume from where you left off if you leave the scan screen and return.
- Added reasons to un-guilded players in /who results.
- Only works when not in compact mode.
- Moved custom filters and reworked to main icon bar.
- Updated ACE3 libraries.

## 2.1.42
- Increment for patch 10.2
- Added total invited players and black listed players in analytics.
- Fixed error with default race filter.

## 2.1.40
- Fixed issues with black list and invited players.

## 2.1.39
- Added compression to database for invited players and black list.
Note: This is to facilitate larger lists with less penealty to performance when logging in.
- Changed anti-spam to base 7 days and up to 6 months.
Note: Go into settings to make sure it is correct.
- Added anti-spam for when not forced by Guild Master.
- Added keybindings for inviting and scanning (Found in settings, Invite Settings).
Note: This does not overwrite any existing keybindings in WoW.
- Players in an instance will not be messaged or invited (fixed).
- Fixed issue with welcome message not using GM settings.
- Fixed issues with analytics not tracking black list and invited players.
- Black listed players can be removed right away as long as a sync has not occurred.

## 2.1.36
- Brought back adding black list players to the icon bar.
- Added the ability to send greeting/welcome message when inviting via the menu (right click on player name in chat).
- Added message length to greeting message and restricted to 255 characters (1 message).
- Restricting welcome message to 255 characters (1 message).

## 2.1.38
- Fixed issue with Black List not working properly.
- Fixed /gr or /recruiter not opening the addon.

## 2.1.37
- Fixed issues with syncing.

## 2.1.35
- Fixed an issue with GM messages not syncing properly.

## 2.1.33
This version is a major rework to the code.  I have removed a lot of the old code and replaced it with new code.  This should fix a lot of the issues that have been reported.  I have also added new features and cleaned up the UI.  Please report any issues you find on CurseForge or Discord.

- Fixed invite issue with connected realms (Need feedback).
- Fixed anti-spam issue with connected realms.
- UI improvements and clean up.
- Default message is guild wide on your account.  Meaning, if you change it on one character, it will change on all.
- Added option to disable the 'What's New' message.
- Added skip if you don't want to invite a player right now, it will add them to the skip list.
- Scans now remember where you left off if you close the addon and reopen (note: not if you log off or reload UI.)
- Compact mode now remembers when you click on the icon.
- Opened GM settings from any character on GM's account.
- Added guild welcome message to the GM settings window.
- Added auto sync on login (will begin 60 seconds after login).
- Fixed issues with auto sync not transferring all data.
- and much more!

- -> Sync with older versions will time out.
- -> Everyone needs to be on the current version.

- *- Please report any bugs or issues on CurseForge or Discord **

## 2.0.5
- Bump in World of Warcraft versioning for 10.1.7

## 2.0.4
- Fix an error that displays if you are not in a guild.
- Fixes to the sync system.

## v2.0.2 and v2.0.3 (08/02/2023)
- Fixed issue with context menu giving error when not in a guild.
- Cleaned up verbose messaging when logging in with a
    character that is not in a guild.
- Fixed issue for info screen showing everytime an update occurs.
- Changed sync to verify database version an not app version.
- Created a reminder to have other officers update their addon.

## v2.0.1 (7/28/2023)
- Changed the look of the interface.
- Saves where you move the interface.
- Seperated out guilds, so one account can have multiple guilds.
- Fixed the welcome message to be whispered to the new player.
- Fixed issue with sticky tooltip on minimap icon.
- Major database overhaul and cleanup.
- Added an about screen.
- Rearranged categories in options.
- Lots of code fixes and some cleanup.

- Note: Had to do a reset on settings, other data should remain intact.

## v1.0.28 (07/18/2023)
- Added personal welcome message for each player in guild chat.
- Changed the welcome message to be whispered to the new player.
- Note: Make sure to check settings to turn on new welcome message.

## v1.0.27 (07/17/2023)
- Added a timer to welcome message to try to cut spam down
- Added an option to set the wait time for the timer
- Fixed show GM only and GM greeting message in GR Options
- Note: I am going to change the welcome message to be whispered to
    the new player and have an option to greet by name with custom message
    for each player that joins the guild.