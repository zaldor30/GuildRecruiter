local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')
local icon = LibStub('LibDBIcon-1.0')

local MAX_CHARACTERS = 255
local bulletAccountWide = ns.code:cText('ff00ff00', '* ')

ns.addonSettings = {
    name = L['TITLE']..' '..GR.versionOut,
    type = 'group',
    args = {
        grSettings = { -- Guild Recruiter Settings
            name = 'GR Settings',
            type = 'group',
            order = 0,
            args = {
            },
        },
    },
}