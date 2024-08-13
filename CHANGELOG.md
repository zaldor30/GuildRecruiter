# Guild Recruiter
## 3.0 - War Within Release (Alpha)
### Alpha Fixes v3.0:
- Fixed preview showing '|c2'
- Fixed issue with lblPlayersScanned error.
- Right Click Invite Menu:
    - Added option to send invite message.
    - Now checks if player is in the guild.
- Added back in about screen.
- Added back in What's New screen.
- Added back analytics screen.
- Fixed issue with expired anti-spam.
- Still Needed:
    - Double check all analytics.
    - Syncing with other players.

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