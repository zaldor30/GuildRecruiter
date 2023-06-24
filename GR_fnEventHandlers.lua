local _, ns = ... -- Namespace (myaddon, namespace)
--[[ Register and Unregister events
    Add event to table
    Add event to Register event ]]
ns.events = {}
local events = ns.events
function events:Init()
    self.tblEvents = events:CreateTableEvents()
end
function events:CreateTableEvents()
    return {
        ['WHO_LIST_UPDATE'] = {active = false, installed = true},
        ['CHAT_MSG_SYSTEM'] = {active = false, installed = true},
        ['GUILD_ROSTER_UPDATE'] = {active = false, installed = true},
    }
end
function events:RegisterEvent(event)
    if self.tblEvents[event].active then return
    elseif not self.tblEvents[event] and not self.tblEvents.installed then ns.code:consoleOut(event..' event is not registered in fnEventHandlers.') end

    local function eventCallBack(...)
        self.tblEvents[...].active = true
        if event == 'WHO_LIST_UPDATE' then ns.ScreenInvite:eventWhoQueryResults()
        elseif event == 'CHAT_MSG_SYSTEM' then ns.Invite:ChatMsgHandler(...)
        elseif event == 'GUILD_ROSTER_UPDATE' then ns.Invite:GuildRosterHandler(...) end
    end

    GRADDON:RegisterEvent(event, eventCallBack)
end
function events:UnregisterEvent(event)
    if strupper(event) == 'ALL' then
        for k, r in pairs(self.tblEvents) do
            if r.active then GRADDON:UnregisterEvent(k) end
        end
    elseif event and self.tblEvents[event] then
        self.tblEvents[event].active = false
        GRADDON:UnregisterEvent(event)
    end
end
events:Init()