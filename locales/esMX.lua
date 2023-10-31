--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GuildRecruiter", "esMX")

L['TITLE'] = "Reclutador de la gremia"

-- System Messages
L["Player not found"] = "Spieler nicht gefunden"
L["joined the guild"] = "Gilde angeschlossen"
L["No Player Named"] = "No se llama Jugador"
L['no player named'] = 'no se llama jugador'
L["is already in a guild"] = "esta en una hermandad"
L['is not online'] = 'no está en línea'
L['has joined the guild'] = 'se ha unido a la hermandad'
L['declines your guild invitation'] = 'la invitación a tu hermandad'
L['JOINED_GUILD_MESSAGE'] = ' se unió a la gremia!'

-- Generic Terms
L['ENABLED'] = 'está habilitado'
L['DISABLED'] = 'está discapacitado'

-- Slash Commands
L['help'] = 'ayuda'
L['config'] = 'config'
L['reload'] = 'recargar'
L['recruiter'] = "reclutador"
L['blacklist'] = 'listanegra'

-- Core Startup
L['FIRST_RUN'] = 'Puedes usar "/gr ayuda or /reclutador" para obtener una lista de órdenes.'
L['ANTI_SPAM_REMOVAL'] = 'Eliminado %s jugadores de Lis anti-spam.'
L['BL_REMOVAL'] = ' fueron eliminados de la lista negra después del período de espera de 30 días.'

-- Minimap Tooltip
L['LEFT_MOUSE_BUTTON'] = 'LMB - Empieza a buscar reclutas'
L['RIGHT_MOUSE_BUTTON'] = 'RMB - Configuración abierta'

-- Slash Help Commands
L['SLASH_HELP1'] = '%s - Help'
L['SLASH_HELP2'] = 'Puedes usar "/gr ayuda or /reclutador" para obtener una lista de órdenes.'
L['SLASH_HELP3'] = 'config - Te lleva a la pantalla de configuración de Reclutador de la gremio.'
L['SLASH_HELP4'] = 'listanegra <nombre del reproductor> - Esto añadirá al reproductor a la lista negra (no use la <>)'
L['SLASH_HELP5'] = 'recargar - Puede escribir /rl para recargar su UI (igual que /recargar).'

-- Guild Related
L['NO_GUILD'] = 'No se encontró ningún gremio, Reclutador de la gremia discapacitado.'
L['BAD_GUILD_DATA'] = 'Hubo un problema en acceder a los datos del gremio.'