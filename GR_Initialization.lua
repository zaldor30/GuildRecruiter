-- Guild Recruiter Initialization
GR_ADDON = LibStub('AceAddon-3.0'):NewAddon('GuildRecruiter', 'AceConsole-3.0', 'AceEvent-3.0')

GR_ADDON.playerFaction = UnitFactionGroup('player') == 'Horde' and 2 or 1
GR_ADDON.version = GetAddOnMetadata('GuildRecruiter', 'Version')
GR_ADDON.whoQuery = {}
GR_ADDON.color = {
    WARRIOR='ffc79c6e',
	PALADIN='fff58cba',
	HUNTER='ffabd473',
	ROGUE='fffff569',
	PRIEST='ffffffff',
	DEATHKNIGHT='ffc41f3b',
	SHAMAN='ff0070de',
	MAGE='ff3fc7eb',
	WARLOCK='ff8788ee',
	MONK='ff00ff96',
	DRUID='ffff7d0a',
	DEMONHUNTER='ffa330c9',
	EVOKER='ff308a77',
}