local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GuildRecruiter')

ns.raiderIO = {}
local raiderIO = ns.raiderIO

function raiderIO:Init()
    self.isRaiderIO = false
    self.raiderIOData = nil
end
function raiderIO:Start()
    print('raiderIO:Start')
    print(RaiderIO_DB)
    if not C_AddOns.IsAddOnLoaded('RaiderIO') and RaiderIO_DB then
        ns.code:fOut('RaiderIO not loaded')
        return
    end

    print(RaiderIO_DB)
    self.isRaiderIO = true
    self.raiderIOData = RaiderIO_DB
    local char = RaiderIO_GetScore("Dalaran", GetUnitName('player'))
    for k, r in pairs(char) do print(k,r) end
end
raiderIO:Init()