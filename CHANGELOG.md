# Guild Recruiter
## 4.0 - War Within and Class/Cata Release

### v4.0.00

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