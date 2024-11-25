local _, ns = ... -- Namespace (myaddon, namespace)

ns.changeLog = [[
    # Guild Recruiter
    ## 4.0 - War Within/Classic/Cata Release

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