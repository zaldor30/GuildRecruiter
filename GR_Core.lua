-- Guild Recruiter Core
local AC = LibStub('AceConfig-3.0')
local ACD = LibStub('AceConfigDialog-3.0')

-- Addon Setting Data
local optionsDefault = {
    profile = {
        showIcon = true,
        showMsg = true,
        showMenu = true,
        remember = true,
        rememberTime = 'WEEK',
    }
}

function GR_ADDON:OnInitialize()
    GR_DB = LibStub('AceDB-3.0'):New('GuildRecruiterDB', optionsDefault, true)
    AC:RegisterOptionsTable('GuildRecruiter_Options', GR_MAIN_OPTIONS)
    self.optionsFrame = ACD:AddToBlizOptions('GuildRecruiter_Options', 'Guild Recruiter')

    self:RegisterChatCommand("rl", function() ReloadUI() end)
    self:RegisterChatCommand("gr", "SlashCommand")
    self:RegisterChatCommand("guildrecruiter", "SlashCommand")
end

function GR_ADDON:SlashCommand(msg)
    msg = msg and msg:trim() or msg
    if msg == 'config' then InterfaceOptionsFrame_OpenToCategory(self.optionsFrame) end
end