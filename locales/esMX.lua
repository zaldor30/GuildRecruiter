-- Localization file for English/United States
local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "esMX")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "El jugador rechazó la invitación de hermandad."
L["PLAYER_ALREADY_IN_GUILD"]         = "Ese jugador ya está en una hermandad."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "Ese jugador ya está en tu hermandad."
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "Ese jugador ya ha sido invitado."
L["PLAYER_NOT_FOUND"]                = "Jugador no encontrado."
L["PLAYER_NOT_PLAYING"]              = "El jugador no está jugando World of Warcraft."
L["PLAYER_IGNORING_YOU"]             = "Ese jugador te está ignorando."
L["PLAYER_JOINED_GUILD"]             = "El jugador se ha unido a una hermandad."
L["PLAYER_NOT_ONLINE"]               = "El jugador no está conectado."
L["PLAYER_IN_GUILD"]                 = "El jugador está en una hermandad."

--#region General
L["INVITE"]    = "Invitar"
L["SCAN"]      = "Escanear"
L["ABOUT"]     = "Acerca de"
L["CLOSE"]     = "Cerrar"
L["ENABLE"]    = "Activar"
L["ENABLED"]   = "Activado"
L["DISABLE"]   = "Desactivar"
L["DISABLED"]  = "Desactivado"
L["REMOVE"]    = "Eliminar"
L["HELP"]      = "Ayuda"
L["CONFIG"]    = "Configuración"
--#endregion

--#region Button Text
L["CANCEL"] = "Cancelar"
L["DELETE"] = "Eliminar"
L["SAVE"]   = "Guardar"
L["NEW"]    = "Nuevo"
L["YES"]    = "Sí"
L["NO"]     = "No"
L["OK"]     = "Aceptar"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[Esta es una versión VER de Guild Recruiter.
Informa cualquier problema en nuestro servidor de Discord.]]
L["AUTO_LOCKED"] = "El movimiento de la ventana ahora está bloqueado."
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "Anti-spam"
L["BLACKLIST"]     = "Lista negra"
L["SETTINGS"]      = "Configuración"
L["PREVIEW_TITLE"] = "Vista previa del mensaje seleccionado"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "No hay nombre de hermandad, recarga la IU."
L["BL_NO_ONE_ADDED"]             = "No se agregó a nadie a la lista negra."
L["GUILD_LINK_NOT_FOUND"]        = "No se encontró el enlace de hermandad. Recarga la IU."
L["GUILD_LINK_NOT_FOUND_LINE1"]  = "Prueba /rl o volver a iniciar sesión (puede requerir varios intentos)"
L["GM_GUILD_LINK_NOT_FOUND"]     = "Crea un reclutamiento en el buscador de hermandades y luego /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "Intenta sincronizar con la hermandad para obtener el enlace."
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "Invitación de hermandad (sin mensajes)"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "Invitación de hermandad (mensajes de bienvenida)"
L["BLACKLIST_PLAYER"]             = "Agregar jugador a la lista negra"
L["KICK_PLAYER_FROM_GUILD"]       = "Expulsar jugador de la hermandad (agregar a lista negra)"
L["KICK_PLAYER_CONFIRMATION"]     = "¿Seguro que quieres expulsar a %s de la hermandad?"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "¡Bienvenido PLAYERNAME a GUILDNAME!"
L["DATABASE_RESET"] = [[
La base de datos se ha restablecido.
Debido a la integración de Classic y Cata, todos los datos se restablecieron.
Disculpa las molestias.
|cFFFFFFFFRecarga la IU (/rl o /reload).|r]]
L["SLASH_COMMANDS"] = [[
Comandos de Guild Recruiter:
/rl recarga la IU de WoW (como /reload).
/gr help - Muestra este mensaje de ayuda.
/gr config - Abre la ventana de configuración.
/gr blacklist <nombre del jugador> - Agrega al jugador a la lista negra.]]
L["MINIMAP_TOOLTIP"] = [[
Clic izquierdo: Abrir Guild Recruiter
Mayús+Clic izquierdo: Abrir escáner
Clic derecho: Abrir configuración
%AntiSpam en la lista de invitados.
%BlackList en la lista de bloqueados.]]
L["NO_LONGER_GUILD_LEADER"] = "ya no es el líder de la hermandad."
L["NO_ANTI_SPAM"]           = "El anti-spam no está habilitado. Actívalo en la configuración."
L["CANNOT_INVITE"]          = "No tienes permiso para invitar nuevos miembros."
L["NOT_IN_GUILD"]           = "Guild Recruiter está desactivado porque no estás en una hermandad."
L["NOT_IN_GUILD_LINE1"]     = "Si te unes a una hermandad, escribe /rl para recargar."
L["FGI_LOADED"]             = "*ADVERTENCIA* FGI está cargado. Desactívalo para usar Guild Recruiter."
--#endregion

--#region Base Screen
L["BACK"]                   = "Atrás"
L["BACK_TOOLTIP"]           = "Volver a la pantalla anterior."
L["LOCK_TOOLTIP"]           = "Alternar movimiento de la ventana"
L["RESET_FILTER"]           = "Restablecer filtro"
L["RESET_FILTER_TOOLTIP"]   = "Restablece el filtro del escáner para comenzar de nuevo."
L["COMPACT_MODE"]           = "Modo compacto"
L["COMPACT_MODE_TOOLTIP"]   = [[Alternar modo compacto.
Cambia el tamaño del modo compacto en la configuración.]]
L["ABOUT_TOOLTIP"]          = "Información de Discord, soporte y cómo contribuir."
L["SETTINGS_TOOLTIP"]       = "Cambiar configuración de Guild Recruiter."
L["MANUAL_SYNC"]            = "Sincronización manual"
L["MANUAL_SYNC_TOOLTIP"]    = "Sincroniza manualmente tus listas con otros miembros de la hermandad."
L["VIEW_ANALYTICS"]         = "Ver analíticas"
L["VIEW_ANALYTICS_TOOLTIP"] = "Desglosa tus estadísticas de invitaciones a la hermandad."
L["BLACKLIST_TOOLTIP"]      = "Agregar jugadores a la lista negra."
L["CUSTOM_FILTERS"]         = "Filtros personalizados"
L["CUSTOM_FILTERS_TOOLTIP"] = "Agregar filtros personalizados al escáner."
L["CUSTOM_FILTERS_DESC"] = [[
Los filtros personalizados permiten filtrar jugadores según criterios específicos.
Por ejemplo, puedes filtrar jugadores por clase o raza.
]]
L["NEW_FILTER_DESC"]       = "Crear un filtro nuevo para el escáner."
L["FILTER_SAVE_LIST"]      = "Guardar lista de filtros"
L["FILTER_SAVE_LIST_DESC"] = "Elige un filtro para modificar."
L["FILTER_NAME"]           = "Introduce el nombre del filtro:"
L["FILTER_NAME_EXISTS"]    = "El nombre del filtro ya existe."
L["FILTER_CLASS"]          = "Elige una clase o combinación de clases:"
L["SELECT_ALL_CLASSES"]    = "Seleccionar todas las clases"
L["CLEAR_ALL_CLASSES"]     = "Deseleccionar todas las clases"
L["FILTER_SAVED"]          = "Filtro guardado correctamente."
L["FILTER_DELETED"]        = "Filtro eliminado correctamente."
L["FILTER_SAVE_ERROR"]     = "Elige al menos 1 clase y/o raza."
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "Solo mensaje"
L["GUILD_INVITE_ONLY"]               = "Solo invitación de hermandad"
L["GUILD_INVITE_AND_MESSAGE"]        = "Invitación de hermandad y mensaje"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "Solo mensaje si se rechaza la invitación"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "Pendiente"
L["GUILD_INVITE_SENT"]      = "Invitación de hermandad enviada a"
L["INVITE_MESSAGE_SENT"]    = "Mensaje de invitación enviado a"
L["INVITE_MESSAGE_QUEUED"]  = "Mensaje de invitación en cola para"
L["GUILD_INVITE_BLOCKED"]   = "Se omitió el mensaje para %s porque tiene bloqueadas las invitaciones de hermandad."
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "Selecciona un filtro"
L["MIN_LEVEL"]                   = "Nivel mínimo"
L["MAX_LEVEL"]                   = "Nivel máximo"
L["MAX_LEVEL_ERROR"]             = "Ingresa un número entre 1 y "
L["LEVELS_FIXED"]                = "Niveles corregidos"
L["LEVELS_TOO_CLOSE"]            = "Aviso: Mantén el rango dentro de 5 niveles."
L["SELECT_INVITE_TYPE"]          = "Selecciona el tipo de invitación"
L["SELECT_INVITE_MESSAGE"]       = "Selecciona el mensaje de invitación"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "Crea el mensaje en la configuración"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "Progreso del filtro"
L["PLAYERS_FOUND"]             = "Jugadores encontrados"
L["SEND_MESSAGE"]              = "Enviar mensaje"
L["SEND_INVITE"]               = "Enviar invitación"
L["SEND_INVITE_AND_MESSAGE"]   = "Enviar invitación y mensaje"
L["BLACKLIST_TITLE"]           = "Agregar jugadores seleccionados a la lista negra"
L["BLACKLIST_SCANNER_TOOLTIP"] = "Agrega jugadores seleccionados a la lista negra."
L["ANTISPAM_TITLE"]            = "Agregar jugadores seleccionados al anti-spam"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "Agrega jugadores seleccionados a la lista anti-spam."
L["WHO_RESULTS"]               = "Resultados de /who: %d jugadores encontrados"
L["SCAN_FOR_PLAYERS"]          = "Buscar jugadores"
L["NEXT_QUERY"]                = "Siguiente consulta: %s"
L["NEXT_PLAYER_INVITE"]        = "Siguiente jugador a invitar (cola: %d):"
L["PLAYERS_QUEUED"]            = "Jugadores en cola: %d"
L["NO_QUEUED_PLAYERS"]         = "No hay jugadores en la cola."
L["WAIT"]                      = "Esperar"
L["INVITE_FIRST_STEP"]         = "Primero debes hacer clic en \"Buscar jugadores\"."
L["ADD_TO_ANTISPAM"]           = "Se agregaron %d jugadores a la lista anti-spam."
L["ADD_TO_BLACKLIST"]          = "Se agregaron %d jugadores a la lista negra."
L["SKIP_PLAYER"]               = "Saltar jugador"
L["SKIP"]                      = "Saltar"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
Espero que este addon te sea útil. He invertido mucho tiempo y esfuerzo
en su desarrollo. Si quieres donar, usa el enlace de abajo.
¡Gracias por tu apoyo!]]
L["ABOUT_LINK_MESSAGE"] = "Para más información, visita estos enlaces:"
L["COPY_LINK_MESSAGE"]  = "Los enlaces se pueden copiar. Selecciónalo y usa CTRL+C."
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(<sub> caracteres por mensaje)"
L["LENGTH_INFO"] = "Supone 12 caracteres si se usa PLAYERNAME"
L["MESSAGE_LENGTH"] = "Longitud del mensaje"
L["GEN_GUILD_WIDE"]   = "Significa que solo afecta a tu hermandad actual."
L["GEN_ACCOUNT_WIDE"] = "Significa que afecta a todos tus personajes de la cuenta."
L["RELOAD_AFTER_CHANGE"] = "Debes recargar la IU (/rl) después de realizar cambios."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - Crea un enlace clicable a tu hermandad."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - Muestra el nombre de tu hermandad.
PLAYERNAME - Muestra el nombre del jugador invitado.]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "Configuración de GR"
L["GEN_WHATS_NEW"]               = "Mostrar \"Novedades\""
L["GEN_WHATS_NEW_DESC"]          = "Muestra la ventana de Novedades cuando se actualiza Guild Recruiter."
L["GEN_TOOLTIPS"]                = "Mostrar todas las descripciones"
L["GEN_TOOLTIP_DESC"]            = "Mostrar todas las descripciones en Guild Recruiter."
L["GEN_ADDON_MESSAGES"]          = "Mostrar mensajes del sistema"
L["GEN_ADDON_MESSAGES_DESC"]     = "Mostrar mensajes del sistema de Guild Recruiter."
L["KEEP_ADDON_OPEN"]             = "Mantener addon abierto"
L["KEEP_ADDON_OPEN_DESC"]        = [[
Mantiene el addon abierto e ignora ESC y otras acciones que podrían cerrarlo.

NOTA: Tras cambiar este ajuste, ejecuta /rl.]]
L["GEN_MINIMAP"]                 = "Mostrar icono del minimapa"
L["GEN_MINIMAP_DESC"]            = "Mostrar el icono del minimapa de Guild Recruiter."
L["INVITE_SCAN_SETTINGS"]        = "Configuración de invitación y escaneo"
L["SEND_MESSAGE_WAIT_TIME"]      = "Retraso al enviar mensajes"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "Tiempo en segundos antes de enviar mensajes en espera (0,1 a 1 segundo)."
L["AUTO_SYNC"]                   = "Habilitar sincronización automática"
L["AUTO_SYNC_DESC"]              = "Sincroniza automáticamente con miembros de la hermandad al iniciar sesión."
L["SHOW_WHISPERS"]               = "Mostrar susurros en el chat"
L["SHOW_WHISPERS_DESC"]          = [[
Muestra el mensaje que envías a los jugadores al invitarles.

NOTA: Tras cambiar este ajuste, ejecuta /rl.]]
L["GEN_CONTEXT"]                 = "Habilitar invitación con clic derecho desde el chat"
L["GEN_CONTEXT_DESC"]            = "Muestra el menú contextual de Guild Recruiter al hacer clic derecho sobre un nombre en el chat."
L["COMPACT_SIZE"]                = "Tamaño compacto"
L["SCAN_WAIT_TIME"]              = "Retraso del escaneo en segundos"
L["SCAN_WAIT_TIME_DESC"]         = [[
Tiempo en segundos antes de buscar jugadores (2 a 10 segundos).

NOTA: Se recomiendan 5 o 6 segundos.]]
L["KEYBINDING_HEADER"]           = "Asignaciones de teclas"
L["KEYBINDING_INVITE"]           = "Tecla de Invitar"
L["KEYBINDING_INVITE_DESC"]      = "Tecla para invitar a un jugador a la hermandad."
L["KEYBINDING_SCAN"]             = "Tecla de Escanear"
L["KEYBINDING_SCAN_DESC"]        = "Tecla para buscar jugadores que buscan hermandad."
L["KEY_BINDING_NOTE"]            = "Nota: Las asignaciones no afectan la configuración del teclado de WoW."
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "Configuración de GM"
L["FORCE_OPTION"]                     = "Obligar a no GMs a usarlo"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "Habilitar comprobación de invitaciones bloqueadas."
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "Intenta comprobar si el jugador invitado tiene bloqueadas las invitaciones de hermandad."
L["ENABLE_ANTI_SPAM_DESC"]            = "Habilita la función anti-spam para prevenir spam."
L["ANTI_SPAM_DAYS"]                   = "Retraso de re-invitación"
L["ANTI_SPAM_DAYS_DESC"]              = "Número de días antes de volver a invitar a un jugador."
L["GUILD_WELCOME_MSG"]                = "Mensaje de bienvenida en el chat de hermandad"
L["GUILD_WELCOME_MSG_DESC"]           = "Mensaje que se envía al chat de hermandad cuando un jugador se une."
L["WHISPER_WELCOME_MSG"]              = "Mensaje de bienvenida por susurro"
L["WHISPER_WELCOME_MSG_DESC"]         = "Mensaje por susurro enviado al jugador cuando se une a la hermandad."
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "Mensajes de GM"
L["PLAYER_SETTINGS_DESC"]       = "Los mensajes en naranja provienen del GM."
L["INVITE_ACTIVE_MESSAGE"]      = "Mensajes de invitación:"
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
Mensajes enviados a posibles reclutas.

NOTA: Tras una sincronización, puede que debas usar /rl para ver los cambios.]]
L["NEW_MESSAGE_DESC"]           = "Agrega una descripción del mensaje a la lista de invitaciones."
L["INVITE_DESC"]                = "Descripción del mensaje de invitación:"
L["INVITE_DESC_TOOLTIP"]        = "Una descripción del mensaje de invitación."
L["SYNC_MESSAGES"]              = "Sincronizar este mensaje."
L["SYNC_MESSAGES_DESC"]         = "Sincroniza este mensaje con la hermandad."
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "Configuración de invitación"
L["INVITE_MESSAGES"] = "Mensajes de invitación"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "Eliminar entradas seleccionadas de la lista negra"
L["ADD_TO_BLACKLIST"]         = "Agregar jugadores a la lista negra."
L["BL_PRIVATE_REASON"]        = "Alternar motivo privado"
L["BL_PRIVATE_REASON_DESC"]   = "Alterna el motivo privado para la lista negra."
L["BL_PRIVATE_REASON_ERROR"]  = "No has puesto a nadie en la lista negra"
L["NO_REASON_GIVEN"]          = "Sin motivo especificado"
L["ADDED_TO_BLACK_LIST"]      = "se agregó a la lista negra con el motivo %s."
L["BL_NAME_NOT_ADDED"]        = "no se agregó a la lista negra."
L["IS_ON_BLACK_LIST"]         = "ya está en la lista negra."
L["BLACK_LIST_REASON_INPUT"]  = "Introduce un motivo para poner en la lista negra a %s."
L["BLACKLIST_NAME_PROMPT"] = [[
Introduce el nombre del jugador
que quieres poner en la lista negra.

Para otro reino, agrega - y el nombre del reino.
(NombreDelJugador-NombreDelReino)
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "Zonas inválidas"
L["ZONE_NOT_FOUND"]      = "No se pudo encontrar la zona"
L["ZONE_INSTRUCTIONS"]   = "El nombre de la zona debe coincidir EXACTAMENTE con el nombre en el juego."
L["ZONE_ID"]             = "ID de zona (ID numérica)"
L["ZONE_NAME"]           = "Nombre de la zona:"
L["ZONE_INVALID_REASON"] = "Motivo de invalidez:"
L["ZONE_ID_DESC"] = [[
El ID de zona para la zona inválida.
Lista de instancias:
https://wowpedia.fandom.com/wiki/InstanceID
Mejores IDs de zonas del mundo que pude encontrar:
https://wowpedia.fandom.com/wiki/UiMapID
Si encuentras una zona que deba añadirse, avísame.]]
L["ZONE_NOTE"]           = "Las zonas con |cFF00FF00*|r son las únicas editables."
L["ZONE_LIST_NAME"]      = "El escáner ignorará las siguientes zonas:"
--#endregion

--#region Analytics
L["ANALYTICS"]                     = "Analíticas"
L["ANALYTICS_DESC"]                = "Consulta tus estadísticas al invitar jugadores a la hermandad."
L["ANALYTICS_BLACKLISTED"]         = "Jugadores que pusiste en la lista negra"
L["ANALYTICS_SCANNED"]             = "Jugadores escaneados en total"
L["ANALYTICS_INVITED"]             = "Jugadores que invitaste a la hermandad"
L["ANALYTICS_DECLINED"]            = "Jugadores que rechazaron la invitación"
L["ANALYTICS_ACCEPTED"]            = "Jugadores que aceptaron la invitación"
L["ANALYTICS_NO_GUILD"]            = "Jugadores sin hermandad encontrada"
L["ANALYTICS_STATS_START"]         = "Estadísticas desde"
L["ANALYTICS_SESSION"]             = "Sesión"
L["ANALYTICS_SESSION_SCANNED"]     = "Escaneados"
L["ANALYTICS_SESSION_BLACKLISTED"] = "A la lista negra"
L["ANALYTICS_SESSION_INVITED"]     = "Invitados"
L["ANALYTICS_SESSION_DECLINED"]    = "Invitación rechazada"
L["ANALYTICS_SESSION_ACCEPTED"]    = "Invitación aceptada"
L["ANALYTICS_SESSION_WAITING"]     = "En espera de"
L["ANALYTICS_SESSION_TIMED_OUT"]   = "Invitación expirada"
L["ANALYTICS_SESSION_NO_GUILD"]    = "Potenciales encontrados"
L["ANALYTICS_SESSION_STARTED"]     = "Sesión iniciada"
L["LAST_SCAN"]                     = "Último jugador escaneado"

L["GUILD_ANALYTICS"]   = "Analíticas de la hermandad"
L["PROFILE_ANALYTICS"] = "Analíticas del personaje"
L["SESSION_ANALYTICS"] = "Analíticas de la sesión"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "La sincronización ya está en curso"
L["SYNC_FAIL_TIMER"]               = "La sincronización expiró, inténtalo de nuevo."
-- Server
L["AUTO_SYNC_STARTED"]             = "Has iniciado una sincronización automática con tu hermandad."
L["MANUAL_SYNC_STARTED"]           = "Has iniciado una sincronización con tu hermandad."
L["SYNC_CLIENTS_FOUND"]            = "Se encontraron %d clientes para sincronizar."
-- Client
L["SYNC_CLIENT_STARTED"]           = "ha solicitado una sincronización de Guild Recruiter."
-- Either
L["SYNC_SETTINGS_FAILED"]          = "No se pudo preparar la configuración para enviar."

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "No se recibieron datos de los clientes."
L["REQUEST_WAIT_TIMEOUT"]          = "No se recibió respuesta del servidor."
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "No se encontraron clientes con los que sincronizar."

-- Sync Messages
L["AUTO_SYNC"]     = "Sincronización automática"
L["MANUAL_SYNC"]   = "Sincronización manual"
L["CLIENT_SYNC"]   = "Sincronización del cliente"
L["SYNC_FINISHED"] = "ha finalizado."
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "La configuración se actualizó."
L["MESSAGE_LIST_CHANGED"]  = "La lista de mensajes se actualizó."
L["BLACKLIST_CHANGED"]     = "La lista negra se actualizó con %d entradas."
L["ANTISPAM_CHANGED"]      = "La lista anti-spam se actualizó con %d entradas."
--#endregion