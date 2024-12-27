# Guild Recruiter
## 3.0 - War Within Release

### 3.2.75 - Bump in version to 11.07.
### 3.2.72
    - Added a warning about FGI not disabled.
    - Added a warning about not supporting classic/cata.
### 3.2.71
    - Update version for 11.05
### 3.2.70
    - Fixed nil issues.
    - Possible fix for wrong message being sent.
### 3.2.69
    - Added warning about FGI not disabled.
    - Hardened checks on anti-spam and black list.
### 3.2.67
    - Fixed issue with wrong message trying to be sent during invite.
    - Fix to nil message when sending.
    - Fix to sync with yourself.
### 3.2.65
    - Fix to anti-spam list.
    - Fix to sending messages.
    - Fix to right click invite.
### 3.2.59
    - Fix to right click inviting error no message.
### 3.2.58
    - Fix to not sending invite messages.
### 3.2.57
    - Fixing compact mode scanning.
### 3.2.56
    - Fixed sync, so it can handle larger data sets.
    - Sync: Added time-stamping to the sync data.
    - Rework on inviting to make more reliable.
    - Invite: Added delay for messages to comply with Blizzard's API.
    - Rework analytics to more accurately track stats.
### 3.2.55
    - Fixed issue with no messages.
    - Fixed database defaults for new installs.
    - Added a warning about Anti-Spam not being enabled.
    - Added a message governor of invites.
      This will limit invites being sent to 1 every second.
      This will not slow you down, the system will queue
      the invites and send them.
### 3.2.53
    - Fixed issue with detecting if you are a GM.
    - Fixed issue if you change your GM toon.
### 3.2.52
    - Updated the Ace3 library.
### 3.2.51
    - Fixed issue if you have no messages and do guild invite, it would not send the message.
### 3.2.50
    - Can now right click chat and copy player name again.
    - Fixing issues with GM message.
    - Fixing issues with right click invite.
### 3.2.49
    - Fixed GM messages not showing up on home screen.
    - Fixed issue with GMs not being able to send messages.
### v3.2.44 Notes
    - Reworked Sync
        - Now checks version information before syncing.
        - Will now support larger sized data sets.
        - Not so spammy now.
    - Rework of invalid zones to support other languages.
    - Also, made seasonal dungeons and raids automatically added to invalid zones.
    - Settings Rework:
        - Reorganized settings to make it easier to find things.
        - Only have invite or GM options, if you are a GM.
        - GM messages have an option to sync only the ones marked (not fully working yet).
        - Can see anti-spam list, but not change it.
        - Reworked black list and added a privacy option for reason.
        - Reworked invalid zones so you can specify a name of a zone to ignore.
    - Made races by faction again.
### v3.1.41 Notes
    - Fix to auto block guild invites not ever sending message.
### v3.1.40 Notes
    - Added option to keep addon running and ignore certain ways to close it.
    - esMX (Spanish Mexico) localization added.
    - Fixed issue with whispers not being sent when player joins guild.
    - Fixed issue with compact mode not removing anti-spam/black list before adding to invite list.
### v3.0.36 Notes -- Joined forces with FGI to bring recruiting to the next level.
    - Changed the 6 months to 180 days.  Also change 3 months to 120 days.
    (NOTE: If you were using the 6 or 3 months, you will need to update your settings.)
    - Added force checkbox to GM settings.
    - Added auto detect of Block Guild Invites from players before sending a message.
    - Updated sync so everyone in the guild will need to upgrade.
    - Invites should match up with the order on the screen.
    - Added season 1 raid to invalid zones.
    - Added TWW dungeons to invalid zones.
    - Added Delves to invalid zones.
    - Working on issue with wrong welcome messages being sent.
    - Fixed issue with not creating a guild link.
### v3.0.30 Notes
    - Fixed issue with missing no guild link localization.
    - Updated alert to missing guild link on login.

I have done pretty much a full rewrite of Guild Recruiter.  I have added a lot of new features and fixed a lot of bugs.

    ** CHANGES WERE MADE TO THE DATABASE. **
** PLEASE BACKUP YOUR SAVED FILES BEFORE UPDATING. **

### Features:
- Minimap icon:
    - Added shift+click to directly open the scanner.
    - Added anti-spam and black list counts to the tooltip.
- Invite Player Changes:
    - Analytics now tracks /ginvite.
    - Right Click Invite Menu:
        - Invite to guild now works.
        - Hides the option to black list if on the list.
        - Ask if you try to invite someone on the black list.
        - Send your invite message to a player.
- Scanner Changes:
    - Whispers will now show when show whispers is enabled.
    - Invite list and scan data will show after leaving the screen.
- Sync Changes:
    - Changed the detection of out of date versions.
    The sync will look at the database version and not the
    addon version.
    
    This means that the addons can be different versions and
    so long as the database is the same, they will sync.
Settings Changes:
    - Added the ability for GM to override GM settings so they
      can use personal invite settings.
    - Added the ability to turn off auto sync.
    - Added the ability to add zones to ignore.