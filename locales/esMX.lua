-- Localization file for English/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GuildRecruiter", "esMX")
if not L then return end

-- * General
L["TITLE"] = "Reclutador de Guild"
L["INVITE"] = 'Invitar'
L["SCAN"] = 'Escanear'
L["ABOUT"] = 'Acerca'
L["CLOSE"] = 'Cerrar'
L["CANCEL"] = 'Cancelar'
L["SAVE"] = 'Guardar'
L["YES"] = 'Si'
L["NO"] = 'No'
L["OK"] = 'OK'
L["ENABLE"] = 'Habilitar'
L["DISABLE"] = 'Inhabilitar'
L["REMOVE"] = 'Eliminar'
L["NEW"] = 'Nuevo'
L["DELETE"] = 'Borrar'

-- * WoW System Message Translations
--! MUST BE IN LOWERCASE!
L["Player not found"] = "Spieler nicht gefunden"
L["joined the guild"] = "Gilde angeschlossen"
L["No Player Named"] = "No se llama Jugador"
L['no player named'] = 'no se llama jugador'
L["is already in a guild"] = "esta en una hermandad"
L['is not online'] = 'no está en línea'
L['has joined the guild'] = 'se ha unido a la hermandad'
L['declines your guild invitation'] = 'la invitación a tu hermandad'
L['JOINED_GUILD_MESSAGE'] = ' se unió a la gremia!'
L['NO_ANTISPAM_ADDED'] = 'No se añadió a la lista de Anti-Spam.'

--? 3.2.56 Changes
L['NO_WHISPER_MESSAGE'] = 'Seleccionaste un mensaje de susurro, pero no tienes ninguno.'
L['NO_GREETING_MESSAGE'] = 'Seleccionaste un mensaje de bienvenida del guild, pero no tienes ninguno.'
L['SYNC_TIMED_OUT'] = 'La sincronización no respondió a tiempo.'
L['FINDING_CLIENTS_SYNC'] = 'Buscando jugadores para con quien sincronizar.'
L['SYNC_REQUEST_RECEIVED'] = 'Solicitud de sincronización recibida de'
L['CLIENTS_FOUND'] = 'jugadores encontrados para sincronizar:'
L['NO_REASON_GIVEN'] = 'No se dio ninguna razón.'

L['PLAYER_IS_IN_GUILD'] = 'ya está en el guild.'
L['PLAYER_IS_ON_BLACKLIST'] = 'está en la lista negra.'
L['PLAYER_IS_ON_ANTISPAM_LIST'] = 'está en la lista Anti-Spam.'
L['PLAYER_MANUAL_ON_BLACKLIST'] = 'está en la lista negra.\nRazón: %REASON%\n\n¿Deseas invitarlo al guild?'

--? 3.2 Changes
L['SYNC_ALREADY_IN_PROGRESS'] = '¡La sincronización ya está en progreso con %s!'
L['NO_CLIENTS_FOUND'] = 'No se encontraron clientes para sincronizar.'
L['NO_BLACKLISTED_ADDED'] = 'No se añadió a la lista negra.'
L['CLIENT_REQUEST_DATA_TIMEOUT'] = 'El tiempo de espera de la solicitud de datos del cliente ha expirado.'
L['FAILED_TO_RECEIVE_SYNC_DATA'] = 'No se pudo recibir los datos de sincronización de'
L['OUTDATED_VERSION'] = 'Versión desactualizada de Guild Recruiter. Por favor, actualiza tu versión.'
L['OLDER_VERSION'] = 'Versión más antigua de Guild Recruiter. Por favor, actualiza tu versión.'
L['NEWER_VERSION'] = 'Versión más nueva de Guild Recruiter. Por favor, actualiza tu versión.'
L['NOT_GUILD_LEADER'] = 'No eres el líder del guild.'

-- * Donation Message
L['DONATION_MESSAGE'] = [[
Espero que encuentres útil este complemento. He invertido mucho tiempo y esfuerzo en
haciendo este complemento. Si desea donar, utilice el siguiente enlace.
¡Gracias por su apoyo!]]

-- * GR Basic Command Messages
L['INVITE_MESSAGES_MENU'] = 'Invitar con Mensajes'
L['INVITE_NO_MESSAGES_MENU'] = 'Invitar sin Mensajes'
L['DELETE_CONFIRMATION'] = 'Estás seguro de que desea eliminar este registro?'
L['ABOUT_TOOLTIP'] = 'Ver que hay nuevo y informacion de soporte.'
L['PLEASE_WAIT'] = 'Espere por favor'
L['ERROR_SCAN_WAIT'] = 'segundos antes de volver a escanear.'

-- * Version 3.0 Changes

-- * GR Icon Bar
L['LOCK'] = 'Bloquee'
L['LOCK_TOOLTIP'] = 'Bloquee o desbloquee la ventana para que no se reposicione.'
L['SETTINGS'] = 'Ajustes'
L['SETTINGS_TOOLTIP'] = 'Abra la ventana de configuración de Guild Recruiter.'
L['SYNC'] = 'Sincronizar'
L['SYNC_TOOLTIP'] = 'Sincronización manual con miembros del guild.'
L['ANALYTICS'] = 'Analítica'
L['ANALYTICS_TOOLTIP'] = 'Ver la ventana de análisis.'
L['BLACKLIST'] = 'Lista negra'
L['NO_REASON'] = 'ninguna razón dada.'
L['BLACKLIST_TOOLTIP'] = 'Agregar un jugador a la lista negra.'
L['BLACK_LIST_REASON_INPUT'] = 'Por qué quieres poner en la lista negra?'
L['BL_NAME_NOT_ADDED'] = 'Nombre de la lista negra no añadido.'
L['ADDED_TO_BLACK_LIST'] = 'fue añadido a la lista negra con %s como motivo.'
L['FILTER_EDITOR'] = 'Editor de Filtros'
L['FILTER_EDITOR_TOOLTIP'] = 'Abre la ventana del editor de filtros.'
L['COMPACT_MODE'] = 'Modo Compacto'
L['COMPACT_MODE_TOOLTIP'] = 'Alternar el modo compacto del escáner compacto.'
L['RESET_FILTER'] = 'Restablecer Filtro'
L['RESET_FILTER_TOOLTIP'] = 'Restablecer el filtro para reiniciar el escaneo.'
L['FILTERS'] = 'Filtros'

-- * Icon Menu and Slash Commands
L["HELP"] = 'ayuda'
L["CONFIG"] = "configuración"
L["RELOAD"] = "recargar"
L["RECRUITER"] = "reclutador"
L['HOME_BUTTON'] = "Inicio"

-- * GR General Messages
L['IS_ENABLED'] = "está habilitado."

-- * Default Values
L['DEFAULT_GUILD_WELCOME'] = 'Welcome JUGADORNOMBRE to GUILDNOMBRE!'
L['GUILDLINK'] = 'ENLACEDEGUILD'
L['GUILD_LINK_NOT_FOUND'] = 'Sin enlace de guild'
L['GUILDNAME'] = 'NOMBREDEGUILD'
L['NO_GUILD_NAME'] = 'No Guild Nombre'
L['PLAYERNAME'] = 'NOMBREDEJUGADOR'
L['NO_PLAYER_NAME'] = 'jugador'
L['BLACK_LIST'] = 'Lista Negra'
L['OK_INVITE'] = 'Quieres invitar de todos modos?'
L['INVITE_REJECTED'] = "Mensaje no enviado, parece que el jugador tiene bloqueadas las invitaciones de guild."
L['NO_INVITE_MESSAGE'] = "No se ha seleccionado ningún mensaje. Por favor, selecciona un mensaje en la pantalla de inicio."
L['INVITE_IN_GUILD'] = "ya está en el guild"
L['IS_ON_SPAM_LIST'] = "está en la lista de Anti-Spam"
L['GUILD_INVITE_SENT'] = 'invitación enviada a Guild'
L['INVITE_MESSAGE_SENT'] = "Mensaje de invitación enviado a"
L['INVITE_ALREADY_SENT'] = "ya ha sido invitado"
L['NO_GUILD_LINK'] = "No se encontró enlace de guild. Sincroniza con el GM o inicia sesión en un personaje GM."
L['NO_GUILD_LINK2'] = "Intenta recargar tu interfaz (/rl) y verifica si recibes el mensaje nuevamente."
L['SELECT_MESSAGE'] = "Selecciona un mensaje de la lista o crea uno en la configuración."
L['FORCE_ANTI_SPAM'] = "Forzar Anti-Spam"
L['FORCE_ANTI_SPAM_DESC'] = 'Forzar la función Anti-Spam para evitar spam a jugadores.'

--* GR Filter Messages
L['FILTERS'] = "Filtros"
L['DELETE_FILTER'] = "Eliminar Filtro"
L['DELETE_FILTER_CONFIRM'] = "Estás seguro de que quieres eliminar este filtro?"
L['FILTER_DESC'] = "Descripción del filtro"
L['WHO_COMMAND'] = "Comando Quien"
L['CLASSES'] = "Clases"
L['RACES'] = "Razas"

-- * GR Scanner Messages
L['BL'] = 'LN'
L['BLACK_LISTED'] = 'En la lista negra'
L['IS_ON_BLACK_LIST'] = "está en la lista negra."
L['BLACK_LIST_CONFIRM'] = "Estás seguro de que quieres añadir a este jugador a la lista negra?"
L['ANTI_SPAM'] = 'Anti-Spam'
L['READY_INVITE'] = "Listo para invitar"
L['BL_ADD_PLAYER'] = "Añadir jugador a la lista negra"
L['SKIP'] = 'Saltar'
L['SKIP_DESC'] = 'Saltar al jugador actual y pasar al siguiente jugador.'
L['WHO_RESULTS'] = 'Resultados del Comando Quien'
L['NEXT_FILTER'] = 'Siguiente Consulta'
L['FILTER_PROGRESS'] = 'Progreso del Filtro'
L['RESETTING_FILTERS'] = "Restableciendo filtros en el próximo escaneo."
L['NUMBER_PLAYERS_FOUND'] = "Número de jugadores encontrados"
L['INVITE_BUTTON_TOOLTIP'] =  "Invitar jugador al guild."
L['INVITE_BUTTON_BODY_TOOLTIP'] = [[Solo se invitarán a los jugadores no seleccionados. Los jugadores seleccionados son para la lista negra y para saltar.]]
L['BL_BUTTON_TOOLTIP'] = 'Añadir jugador a la lista negra.'
L['BL_BUTTON_BODY_TOOLTIP'] = [[Añadir al jugador a la lista negra y pasar al siguiente jugador. Solo se puede invitar si no hay jugadores seleccionados.]]
L['SKIP_BUTTON_TOOLTIP'] = 'Saltar al jugador y pasar al siguiente jugador.'
L['SKIP_BUTTON_BODY_TOOLTIP'] = [[Saltar al jugador actual y pasar al siguiente jugador. Esto añadirá al jugador a los ya invitados y tratará de invitar al jugador después de que expire el anti-spam. Solo se puede invitar si no hay jugadores seleccionados.]]

-- * Analytics
L['TOTAL_SCANNED'] = 'Jugadores Escaneados'
L['TOTAL_INVITED'] = "Jugadores Invitados"
L['INVITES_PENDING'] = "Invitaciones Pendientes"
L['TOTAL_DECLINED'] = "Invitaciones Rechazadas"
L['TOTAL_ACCEPTED'] = 'Invitaciones Acceptadas'
L['TOTAL_BLACKLISTED'] = 'En la lista negra'
L['TOTAL_ANTI_SPAM'] = 'Jugadores en Anti-Spam'
L['SESSION_STATS'] = 'Estadísticas de sesión'

-- * GR Core Messages
L['FIRST_TIME_INFO'] = [[
Bienvenidos al reclutador de guild!
Puedes acceder haciendo clic derecho en el icono del minimapa.
o escribiendo /gr config. Haz clic izquierdo en el minimapa.
icono para abrir la ventana de reclutamiento.
Si tiene algún problema, haga clic en el menú Acerca de
opción para obtener nuestro enlace de Discord.
IMPORTANTE: escriba /rl para recargar su interfaz de usuario, solo una vez.
]]
L['NUEVA_VERSIÓN_INFO'] = [[El reclutador del guild ha sido actualizado! Por favor consulte "¿Qué hay de nuevo?" por lo que ha cambiado.
]]
L['BETA_INFORMATION'] = [[Esta es una versión VER de Guild Reclutador.
Informe cualquier problema en nuestro servidor de Discord.

]]

-- * GR Error Messages
L['NO GUILD'] = "no estas en un guild."
L['NOT_LOADED'] = 'Guild reclutador no va a cargarár.'
L['CANNOT_INVITE'] = 'No tienes permiso para invitar al guild.'

-- * GR Slash Commands
L['SLASH_COMMANDS'] = [[
Comandos de corte del reclutador del guild:
/rl recargará la interfaz de usuario de WoW (como /recargar).
/gr ayuda: muestra este mensaje de ayuda.
/gr config: abre la ventana de configuración.
/gr lista negra <nombre del jugador>: agregará el jugador a la lista negra.]]

-- * GR Minimap Icon Tooltip
-- Keep %AntiSpam and %BlackList in the tooltip.
L['MINIMAP_TOOLTIP'] = [[
Clic izquierdo: Abrir reclutador de gremio
Mayús+clic izquierdo: abrir escáner
Clic derecho: Abrir configuración
%AntiSpam en lista de invitados.
%BlackList en la lista negra.]]

-- * GR Home Screen
L['MESSAGE_ONLY'] = 'SÓLO mensaje'
L['GUILD_INVITE_ONLY'] = 'SÓLO invitación del guild'
L['GUILD_INVITE_AND_MESSAGE'] = 'Invitación y mensaje del guild'
L['MESSAGE_ONLY_IF_INVITE_DECLINED'] = 'Mensaje solo si la invitación es rechazada'
L['CLASS_FILTER'] = 'Filtro de Clase Predeterminado'
L['RACE_FILTER'] = 'Filtro de Raza Predeterminado'
L['INVITE_FORMAT'] = 'Formato de Invitación de Reclutamiento:'
L['MIN_LVL'] = 'Nivel Mínimo:'
L['MAX_LVL'] = 'Nivel Máximo:'
L['MESSAGE_LIST'] = 'Mensajes de Invitación'
L['INVITE_MESSAGE_ONLY'] = 'Enviar solo mensaje de invitación'
L['FORCE_MESSAGE_LIST'] = 'Forzar Mensaje de Invitación'
L['FORCE_MESSAGE_LIST_DESC'] = 'Forzar el mensaje de invitación para que se envíe al jugador.'
L['SYNC_MESSAGES'] = 'Sincronizar Mensajes'
L['SYNC_MESSAGES_DESC'] = 'Sincronizar mensajes con el GM.'
L['PLAYER_SETTINGS_DESC'] = 'Configuración de mensajes de invitación y bienvenida.'

-- * GR Error Message
L['INVALID_LEVEL'] = 'Debes ingresar un número entre 1 y'
L['MIN_LVL_HIGHER_ERROR'] = 'El nivel mínimo debe ser mayor que el nivel máximo.'
L['MAX_LVL_LOWER_ERROR'] = 'El nivel máximo debe ser menor que el nivel mínimo.'

-- * GR Config Window Messages
L['GENERAL_SETTINGS'] = 'Configuración General'
L['SYSTEM_SETTINGS'] = 'Configuración del Sistema'
L['INVITE_SCAN_SETTINGS'] = 'Configuración de Invitación y Escaneo'
L['FORCE_ENABLE_BLOCK_INVITE_CHECK'] = 'Forzar Comprobación de Bloqueo de Invitaciones'
L['FORCE_ENABLE_BLOCK_INVITE_CHECK_DESC'] = 'Forzar la comprobación de bloqueo de invitaciones para todos los jugadores.'
L['MESSAGE_REPLACEMENT_INSTRUCTIONS'] = [[
ENLACEDELGUILD - Creará un enlace clicable a tu guild.
NOMBREDELGUILD - Mostrará el nombre de tu guild.
NOMBREDELJUGADOR - Mostrará el nombre del jugador invitado.]]
L['INVITE_DESC'] = 'Descripción del mensaje de invitación:'
L['INVITE_DESC_TOOLTIP'] = 'Una descripción del mensaje de invitación.'
L['INVITE_ACTIVE_MESSAGE'] = 'Mensajes de Invitación:'
L['INVITE_ACTIVE_MESSAGE_DESC'] = 'Los mensajes que se enviarán a posibles reclutas. Nota: Puede que necesites /rl después de una sincronización para ver los cambios.'
L['NEW_MESSAGE_DESC'] = 'Añadir una descripción del mensaje a la lista de invitaciones.'

-- * GR Config Window Tooltips
L['GEN_TOOLTIPS'] = 'Mostrar todas las descripciones emergentes'
L['GEN_TOOLTIP_DESC'] = 'Mostrar todas las descripciones emergentes en el addon Reclutador de Guild'
L['GEN_MINIMAP'] = 'Mostrar icono en el minimapa'
L['GEN_MINIMAP_DESC'] = 'Mostrar el icono del minimapa del Reclutador de Guild.'
L['GEN_CONTEXT'] = 'Habilitar invitaciones desde el chat'
L['GEN_CONTEXT_DESC'] = 'Mostrar el menú contextual del Reclutador de Guild al hacer clic derecho en un nombre en el chat.'
L['GEN_WHATS_NEW'] = 'Mostrar ¿Qué hay de nuevo?'
L['AUTO_SYNC'] = 'Sincronización automática al iniciar sesión'
L['AUTO_SYNC_DESC'] = 'Sincronizar automáticamente con los miembros del guild al iniciar sesión.'
L['SHOW_WHISPERS'] = 'Mostrar susurros |cFF00FF00Haz un /rl después de cambiar|r'
L['SHOW_WHISPERS_DESC'] = 'Mostrar el mensaje que envías a los jugadores al invitarlos.'
L['SCAN_WAIT_TIME'] = 'Retraso de escaneo en segundos'
L['SCAN_WAIT_TIME_DESC'] = 'El tiempo en segundos para esperar antes de escanear jugadores (2 a 10 segundos).'
L['GEN_WHATS_NEW_DESC'] = 'Mostrar la ventana ¿Qué hay de nuevo? cuando se actualiza el Reclutador de Guild.'
L['GEN_ADDON_MESSAGES'] = 'Mostrar mensajes del sistema'
L['GEN_ADDON_MESSAGES_DESC'] = 'Mostrar mensajes del sistema del Reclutador de Guild.'
L['KEYBINDING_HEADER'] = 'Asignaciones de teclas'
L['KEYBINDING_INVITE'] = 'Tecla de invitación'
L['KEYBINDING_INVITE_DESC'] = 'Asignación de tecla para invitar a un jugador al Guild.'
L['KEYBINDING_SCAN'] = 'Tecla de escaneo'
L['KEYBINDING_SCAN_DESC'] = 'Asignación de tecla para escanear jugadores que buscan un Guild.'
L['KEY_BINDING_NOTE'] = 'Nota: Las asignaciones de teclas no afectarán a las asignaciones de teclas de WoW.'
L['GEN_ACCOUNT_WIDE'] = 'indica que afecta a todos los personajes del Guild'

-- * GR GM Settings Window
L['GM_SETTINGS'] = 'Configuración del GM'
L['GM_SETTINGS_DESC'] = 'Primero crea una descripción del mensaje, luego el mensaje en sí, y entonces se habilitará la opción de guardar.'
L['MAX_CHARS'] = '(<sub> caracteres por mensaje)'
L['LENGTH_INFO'] = 'Asume 12 caracteres al usar NOMBREDELJUGADOR'
L['MESSAGE_LENGTH'] = 'Longitud del mensaje'
L['BL_PRIVATE_REASON'] = 'Razón de la lista negra privada'
L['BL_PRIVATE_REASON_DESC'] = 'Razón de la lista negra que solo se mostrará a los GM.'
L['BL_PRIVATE_REASON_ERROR'] = 'La razón de la lista negra privada no puede estar vacía.'

-- * GR GM Invite Settings Window
L['GM_INVITE'] = 'Mensajes del GM'
L['ENABLED_NOTE'] = 'Nota: Los elementos deshabilitados son controlados por el GM.'
L['OVERRIDE_GM_SETTINGS'] = 'Anular configuración del GM'
L['OVERRIDE_GM_SETTINGS_DESC'] = 'Anular la configuración del GM para este personaje.'

-- * GR Invite Settings Window
L['INVITE_SETTINGS'] = 'Configuración de Invitaciones'
L['WELCOME_MESSAGES'] = 'Mensajes de Bienvenida'
L['ENABLE_ANTI_SPAM'] = 'Habilitar Anti-Spam'
L['ENABLE_ANTI_SPAM_DESC'] = 'Habilitar la función Anti-Spam para evitar que se haga spam a los jugadores.'
L['ANTI_SPAM_DAYS'] = 'Retraso para Reinvitación'
L['ANTI_SPAM_DAYS_DESC'] = 'Número de días antes de volver a invitar a un jugador.'
L['GUILD_WELCOME_MSG'] = 'Mensaje de Bienvenida del Guild'
L['GUILD_WELCOME_MSG_DESC'] = 'El mensaje que se enviará al chat del guild cuando un nuevo jugador se una.'
L['WHISPER_WELCOME_MSG'] = 'Mensaje de Bienvenida por susurro'
L['WHISPER_WELCOME_MSG_DESC'] = 'Mensaje por susurro enviado a un jugador cuando se une al guild.'
L['FORCE_WHISPER_MESSAGE'] = 'Forzar Mensaje por Susurro'
L['FORCE_WHISPER_MESSAGE_DESC'] = 'Forzar el envío del siguiente mensaje por susurro al jugador.'
L['FORCE_WHISPER_WELCOME_MSG_DESC'] = 'Forzar el mensaje de bienvenida por susurro para que sea enviado al jugador.'
L['FORCE_GUILD_GREETING'] = 'Forzar Saludo del Guild'
L['FORCE_GUILD_GREETING_DESC'] = 'Forzar el envío del mensaje de saludo al chat del guild.'
L['FORCE_GUILD_MESSAGE'] = 'Forzar Mensaje del Guild'
L['FORCE_GUILD_MESSAGE_DESC'] = 'Forzar el envío del siguiente mensaje al chat del guild.'
L['ENABLE_BLOCK_INVITE_CHECK'] = 'Habilitar Comprobación de Bloqueo de Invitaciones'
L['ENABLE_BLOCK_INVITE_CHECK_DESC'] = 'Intentar ignorar a los jugadores que tienen activado el bloqueo de invitaciones de guild.'

-- * GR Invite Messages Window
L['INVITE_MESSAGES'] = "Mensajes de Invitación"
L['INVITE_MESSAGES_DESC'] = [[
Estos mensajes están separados de los mensajes sincronizados de GM.
Están vinculados únicamente a los personajes de tu guild.]]

-- * BlackList Settings Window
L['BLACK_LIST'] = 'Lista Negra'
L['BLACK_LIST_REMOVE'] = 'Eliminar Entradas Seleccionadas de la Lista Negra'
L['ADD_TO_BLACK_LIST'] = 'Añadir jugador a la lista negra.'

-- * Invalid Settings Window
L['INVALID_ZONE'] = 'Zonas Inválidas'
L['ZONE_NOT_FOUND'] = 'Zona no encontrada'
L['ZONE_INSTRUCTIONS'] = 'The zone name must EXACTLY match the zone name in the game.'
L['ZONE_ID'] = 'ID de Zona (ID Numérico)'
L['ZONE_NAME'] = 'Nombre de la Zona:'
L['ZONE_INVALID_REASON'] = 'Razón de la Zona Inválida'
L['ZONE_ID_DESC'] = [[
El ID de zona para la zona inválida.
Lista de instancias:
https://wowpedia.fandom.com/wiki/InstanceID
Mejores IDs de Zonas del Mundo que Puedo Encontrar:
https://wowpedia.fandom.com/wiki/UiMapID
Si encuentras una zona que deba ser añadida, por favor házmelo saber.]]
L['ZONE_NOTE'] = 'Las zonas con |cFF00FF00*|r son las únicas zonas editables.'
L['ZONE_LIST_NAME'] = 'Las siguientes zonas serán ignoradas por el escáner:'

-- * About
L['ABOUT_LINE'] = '¡Gracias por usar Reclutador de Guild, espero que encuentres útil este addon!'
L['ABOUT_DOC_LINKS'] = 'Documentación y Enlaces'
L['GITHUB_LINK'] = 'GitHub (Documentación de soporte)'
L['ABOUT_DISCORD_LINK'] = 'Enlace de Discord'
L['SUPPORT_LINKS'] = 'Enlaces de Soporte del Reclutador de Guild'
