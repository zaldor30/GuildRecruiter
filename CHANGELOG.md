##2.1.36
* Brought back adding black list players to the icon bar.
* Added the ability to send greeting/welcome message when inviting via the menu (right click on player name in chat).
* Added message length to greeting message and restricted to 255 characters (1 message).
* Restricting welcome message to 255 characters (1 message).

## 2.1.38
* Fixed issue with Black List not working properly.
* Fixed /gr or /recruiter not opening the addon.

## 2.1.37
* Fixed issues with syncing.

## 2.1.35
* Fixed an issue with GM messages not syncing properly.

## 2.1.33
This version is a major rework to the code.  I have removed a lot of the old code and replaced it with new code.  This should fix a lot of the issues that have been reported.  I have also added new features and cleaned up the UI.  Please report any issues you find on CurseForge or Discord.

* Fixed invite issue with connected realms (Need feedback).
* Fixed anti-spam issue with connected realms.
* UI improvements and clean up.
* Default message is guild wide on your account.  Meaning, if you change it on one character, it will change on all.
* Added option to disable the 'What's New' message.
* Added skip if you don't want to invite a player right now, it will add them to the skip list.
* Scans now remember where you left off if you close the addon and reopen (note: not if you log off or reload UI.)
* Compact mode now remembers when you click on the icon.
* Opened GM settings from any character on GM's account.
* Added guild welcome message to the GM settings window.
* Added auto sync on login (will begin 60 seconds after login).
* Fixed issues with auto sync not transferring all data.
* and much more!

* -> Sync with older versions will time out.
* -> Everyone needs to be on the current version.

* ** Please report any bugs or issues on CurseForge or Discord **

## 2.0.5
* Bump in World of Warcraft versioning for 10.1.7

## 2.0.4
* Fix an error that displays if you are not in a guild.
* Fixes to the sync system.

## v2.0.2 and v2.0.3 (08/02/2023)
* Fixed issue with context menu giving error when not in a guild.
* Cleaned up verbose messaging when logging in with a
    character that is not in a guild.
* Fixed issue for info screen showing everytime an update occurs.
* Changed sync to verify database version an not app version.
* Created a reminder to have other officers update their addon.

## v2.0.1 (7/28/2023)
* Changed the look of the interface.
* Saves where you move the interface.
* Seperated out guilds, so one account can have multiple guilds.
* Fixed the welcome message to be whispered to the new player.
* Fixed issue with sticky tooltip on minimap icon.
* Major database overhaul and cleanup.
* Added an about screen.
* Rearranged categories in options.
* Lots of code fixes and some cleanup.

* Note: Had to do a reset on settings, other data should remain intact.

## v1.0.28 (07/18/2023)
* Added personal welcome message for each player in guild chat.
* Changed the welcome message to be whispered to the new player.
* Note: Make sure to check settings to turn on new welcome message.

## v1.0.27 (07/17/2023)
* Added a timer to welcome message to try to cut spam down
* Added an option to set the wait time for the timer
* Fixed show GM only and GM greeting message in GR Options
* Note: I am going to change the welcome message to be whispered to
    the new player and have an option to greet by name with custom message
    for each player that joins the guild.