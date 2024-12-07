local _, ns = ... -- Namespace (myaddon, namespace)

ns.changeLog = [[
    # Guild Recruiter
    ## 4.0 - War Within/Classic/Cata Release

    ### v4.0.22
        - Fixed issue with blacklist and anti-spam list not loading/saving.
        - Fixed issue with counting Blacklisted players.
    ### v4.0.19
        - Misc bug fixes.
    ### v4.0.14
        - Fixed issue with converting to new database.
    ### v4.0.13 (Beta)
        - Added analytics screen.
        - Fixed some issues with analytics not counting.
        - Other minor bug fixes.
        Note: This marks beta for the stable release of 4.0.
        The alpha will now be for the sync feature.
    ### v4.0.11
        - Created the about page.
        - Added fix for guild name change.
        - Implemented Analytics (can only see session for now).
    ### v4.0.10
        - Added What's New Screen
        - Added ability to change send message delay.
            - If you get error that states "Chat message
            limits exceeded" you can increase this delay
            in settings.
        - Fixed issue with context blacklisting a player.
    
    ### v4.0 Notes
        - Added Classic and Cataclysm support
        - Updated prompts to be more user friendly.
        - Reworked settings to be more understandable.
        - Updated icons to be more legible.
        - Added a super compact mode to scan/invite.
        - Reduced reliance on the Ace3 library.
          - Allows for more flexibility in the future.
]]