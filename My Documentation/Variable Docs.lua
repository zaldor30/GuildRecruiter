-- Documentation:

-- !ns.core:
    self.isEnabled = false
    self.fullyStarted = false
    self.ignoreAutoSync = false

    self.isGuildLeader = false

    self.addonSettings
        profile
        global

--!Database Variables
    -- General Settings Variables Declaration
    ns.gSettings = db.global[clubID] -- Global Settings
    ns.pSettings = db.profile.settings -- Profile Settings

    -- Guild Settings Variables Declaration
    ns.guildInfo = db.global.guildInfo -- Guild Info
    ns.gmSettings = db.global.gmSettings -- GM Settings

    -- Guild List Variables Declaration
    ns.blackList = db.global.blackList or {} -- Black List
    ns.antiSpamList = db.global.antiSpamList or {} -- Anti-Spam List

    -- Other Variables Declaration
    ns.gFilterList = db.global.filterList or {} -- Global Filter List
    ns.gAnalytics = db.global.analytics or {} -- Global Analytics
    ns.pAnalytics = db.profile.analytics or {} -- Profile Analytics