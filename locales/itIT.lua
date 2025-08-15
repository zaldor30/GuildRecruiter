local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "itIT")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "Il giocatore ha rifiutato l'invito di gilda."
L["PLAYER_ALREADY_IN_GUILD"]         = "Quel giocatore è già in una gilda."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "Quel giocatore è già nella tua gilda."
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "Quel giocatore è già stato invitato."
L["PLAYER_NOT_FOUND"]                = "Giocatore non trovato."
L["PLAYER_NOT_PLAYING"]              = "Il giocatore non sta giocando a World of Warcraft."
L["PLAYER_IGNORING_YOU"]             = "Quel giocatore ti sta ignorando."
L["PLAYER_JOINED_GUILD"]             = "Il giocatore è entrato in una gilda."
L["PLAYER_NOT_ONLINE"]               = "Il giocatore non è online."
L["PLAYER_IN_GUILD"]                 = "Il giocatore è in una gilda."

--#region General
L["INVITE"]    = "Invita"
L["SCAN"]      = "Scansione"
L["ABOUT"]     = "Info"
L["CLOSE"]     = "Chiudi"
L["ENABLE"]    = "Abilita"
L["ENABLED"]   = "Abilitato"
L["DISABLE"]   = "Disabilita"
L["DISABLED"]  = "Disabilitato"
L["REMOVE"]    = "Rimuovi"
L["HELP"]      = "Aiuto"
L["CONFIG"]    = "Configurazione"
--#endregion

--#region Button Text
L["CANCEL"] = "Annulla"
L["DELETE"] = "Elimina"
L["SAVE"]   = "Salva"
L["NEW"]    = "Nuovo"
L["YES"]    = "Sì"
L["NO"]     = "No"
L["OK"]     = "OK"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[Questa è una versione VER di Guild Recruiter.
Segnala eventuali problemi sul nostro server Discord.]]
L["AUTO_LOCKED"] = "Lo spostamento della finestra è ora bloccato."
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "Anti-spam"
L["BLACKLIST"]     = "Lista nera"
L["SETTINGS"]      = "Impostazioni"
L["PREVIEW_TITLE"] = "Anteprima del messaggio selezionato"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "Nessun nome di gilda, ricarica l'interfaccia."
L["BL_NO_ONE_ADDED"]             = "Nessuno è stato aggiunto alla lista nera."
L["GUILD_LINK_NOT_FOUND"]        = "Link della gilda non trovato. Ricarica l'interfaccia."
L["GUILD_LINK_NOT_FOUND_LINE1"]  = "Prova /rl o a ricollegarti (potrebbero servire più tentativi)"
L["GM_GUILD_LINK_NOT_FOUND"]     = "Crea un annuncio di reclutamento nel cerca gilda e poi /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "Prova a sincronizzare con la gilda per ottenere il link."
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "Invito di gilda (senza messaggi)"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "Invito di gilda (messaggi di benvenuto)"
L["BLACKLIST_PLAYER"]             = "Aggiungi giocatore alla lista nera"
L["KICK_PLAYER_FROM_GUILD"]       = "Rimuovi giocatore dalla gilda (aggiungi alla lista nera)"
L["KICK_PLAYER_CONFIRMATION"]     = "Sei sicuro di voler rimuovere %s dalla gilda?"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "Benvenuto PLAYERNAME in GUILDNAME!"
L["DATABASE_RESET"] = [[
Il database è stato reimpostato.
A causa dell'integrazione di Classic e Cata, tutti i dati sono stati reimpostati.
Ci scusiamo per il disagio.
|cFFFFFFFFRicarica l'interfaccia (/rl o /reload).|r]]
L["SLASH_COMMANDS"] = [[
Comandi di Guild Recruiter:
/rl ricarica l'interfaccia di WoW (come /reload).
/gr help - Mostra questo messaggio di aiuto.
/gr config - Apre la finestra di configurazione.
/gr blacklist <nome giocatore> - Aggiunge il giocatore alla lista nera.]]
L["MINIMAP_TOOLTIP"] = [[
Clic sinistro: Apri Guild Recruiter
Maiusc+Clic sinistro: Apri Scanner
Clic destro: Apri Impostazioni
%AntiSpam nella lista invitati.
%BlackList nella lista bloccati.]]
L["NO_LONGER_GUILD_LEADER"] = "non è più il capogilda."
L["NO_ANTI_SPAM"]           = "Anti-spam non abilitato. Abilitalo nelle impostazioni."
L["CANNOT_INVITE"]          = "Non hai il permesso di invitare nuovi membri."
L["NOT_IN_GUILD"]           = "Guild Recruiter è disabilitato perché non sei in una gilda."
L["NOT_IN_GUILD_LINE1"]     = "Se entri in una gilda, usa /rl per ricaricare."
L["FGI_LOADED"]             = "*ATTENZIONE* FGI è caricato. Disabilitalo per usare Guild Recruiter."
--#endregion

--#region Base Screen
L["BACK"]                   = "Indietro"
L["BACK_TOOLTIP"]           = "Torna alla schermata precedente."
L["LOCK_TOOLTIP"]           = "Attiva/disattiva lo spostamento della finestra"
L["RESET_FILTER"]           = "Reimposta filtro"
L["RESET_FILTER_TOOLTIP"]   = "Reimposta il filtro dello scanner per ricominciare."
L["COMPACT_MODE"]           = "Modalità compatta"
L["COMPACT_MODE_TOOLTIP"]   = [[Attiva/disattiva la modalità compatta.
Modifica la dimensione della modalità compatta nelle impostazioni.]]
L["ABOUT_TOOLTIP"]          = "Info Discord, supporto e come contribuire."
L["SETTINGS_TOOLTIP"]       = "Modifica le impostazioni di Guild Recruiter."
L["MANUAL_SYNC"]            = "Sincronizzazione manuale"
L["MANUAL_SYNC_TOOLTIP"]    = "Sincronizza manualmente le tue liste con gli altri membri della gilda."
L["VIEW_ANALYTICS"]         = "Vedi statistiche"
L["VIEW_ANALYTICS_TOOLTIP"] = "Mostra le tue statistiche di invito alla gilda."
L["BLACKLIST_TOOLTIP"]      = "Aggiungi giocatori alla lista nera."
L["CUSTOM_FILTERS"]         = "Filtri personalizzati"
L["CUSTOM_FILTERS_TOOLTIP"] = "Aggiungi filtri personalizzati allo scanner."
L["CUSTOM_FILTERS_DESC"] = [[
I filtri personalizzati consentono di filtrare i giocatori in base a criteri specifici.
Ad esempio, puoi filtrare per classe o razza.
]]
L["NEW_FILTER_DESC"]       = "Crea un nuovo filtro per lo scanner."
L["FILTER_SAVE_LIST"]      = "Salva lista filtri"
L["FILTER_SAVE_LIST_DESC"] = "Scegli un filtro da modificare."
L["FILTER_NAME"]           = "Inserisci il nome del filtro:"
L["FILTER_NAME_EXISTS"]    = "Il nome del filtro esiste già."
L["FILTER_CLASS"]          = "Scegli una classe o una combinazione di classi:"
L["SELECT_ALL_CLASSES"]    = "Seleziona tutte le classi"
L["CLEAR_ALL_CLASSES"]     = "Deseleziona tutte le classi"
L["FILTER_SAVED"]          = "Filtro salvato correttamente."
L["FILTER_DELETED"]        = "Filtro eliminato correttamente."
L["FILTER_SAVE_ERROR"]     = "Scegli almeno 1 classe e/o razza."
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "Solo messaggio"
L["GUILD_INVITE_ONLY"]               = "Solo invito di gilda"
L["GUILD_INVITE_AND_MESSAGE"]        = "Invito di gilda e messaggio"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "Solo messaggio se l'invito viene rifiutato"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "In sospeso"
L["GUILD_INVITE_SENT"]      = "Invito di gilda inviato a"
L["INVITE_MESSAGE_SENT"]    = "Messaggio di invito inviato a"
L["INVITE_MESSAGE_QUEUED"]  = "Messaggio di invito in coda per"
L["GUILD_INVITE_BLOCKED"]   = "Messaggio per %s ignorato perché gli inviti di gilda sono bloccati."
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "Seleziona un filtro"
L["MIN_LEVEL"]                   = "Livello minimo"
L["MAX_LEVEL"]                   = "Livello massimo"
L["MAX_LEVEL_ERROR"]             = "Inserisci un numero tra 1 e "
L["LEVELS_FIXED"]                = "Livelli corretti"
L["LEVELS_TOO_CLOSE"]            = "Avviso: mantieni l'intervallo entro 5 livelli."
L["SELECT_INVITE_TYPE"]          = "Seleziona il tipo di invito"
L["SELECT_INVITE_MESSAGE"]       = "Seleziona il messaggio di invito"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "Crea il messaggio nelle impostazioni"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "Avanzamento filtro"
L["PLAYERS_FOUND"]             = "Giocatori trovati"
L["SEND_MESSAGE"]              = "Invia messaggio"
L["SEND_INVITE"]               = "Invia invito"
L["SEND_INVITE_AND_MESSAGE"]   = "Invia invito e messaggio"
L["BLACKLIST_TITLE"]           = "Aggiungi i giocatori selezionati alla lista nera"
L["BLACKLIST_SCANNER_TOOLTIP"] = "Aggiunge i giocatori selezionati alla lista nera."
L["ANTISPAM_TITLE"]            = "Aggiungi i giocatori selezionati all'anti-spam"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "Aggiunge i giocatori selezionati alla lista anti-spam."
L["WHO_RESULTS"]               = "Risultati /who: trovati %d giocatori"
L["SCAN_FOR_PLAYERS"]          = "Cerca giocatori"
L["NEXT_QUERY"]                = "Prossima richiesta: %s"
L["NEXT_PLAYER_INVITE"]        = "Prossimo giocatore da invitare (coda: %d):"
L["PLAYERS_QUEUED"]            = "Giocatori in coda: %d"
L["NO_QUEUED_PLAYERS"]         = "Nessun giocatore in coda."
L["WAIT"]                      = "Attendi"
L["INVITE_FIRST_STEP"]         = "Devi prima cliccare su \"Cerca giocatori\"."
L["ADD_TO_ANTISPAM"]           = "Sono stati aggiunti %d giocatori alla lista anti-spam."
L["ADD_TO_BLACKLIST"]          = "Sono stati aggiunti %d giocatori alla lista nera."
L["SKIP_PLAYER"]               = "Salta giocatore"
L["SKIP"]                      = "Salta"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
Spero che questo addon ti sia utile. Ho investito molto tempo e impegno
nel suo sviluppo. Se vuoi donare, usa il link qui sotto.
Grazie per il tuo supporto!]]
L["ABOUT_LINK_MESSAGE"] = "Per maggiori informazioni, visita questi link:"
L["COPY_LINK_MESSAGE"]  = "I link sono copiabili. Seleziona il link e usa CTRL+C."
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(<sub> caratteri per messaggio)"
L["LENGTH_INFO"] = "Si presume 12 caratteri se si usa PLAYERNAME"
L["MESSAGE_LENGTH"] = "Lunghezza del messaggio"
L["GEN_GUILD_WIDE"]   = "Significa che riguarda solo la tua gilda attuale."
L["GEN_ACCOUNT_WIDE"] = "Significa che riguarda tutti i personaggi dell'account."
L["RELOAD_AFTER_CHANGE"] = "Devi ricaricare l'interfaccia (/rl) dopo aver apportato modifiche."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - Crea un link cliccabile alla tua gilda."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - Mostra il nome della tua gilda.
PLAYERNAME - Mostra il nome del giocatore invitato.]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "Impostazioni GR"
L["GEN_WHATS_NEW"]               = "Mostra \"Novità\""
L["GEN_WHATS_NEW_DESC"]          = "Mostra la finestra Novità quando Guild Recruiter viene aggiornato."
L["GEN_TOOLTIPS"]                = "Mostra tutte le descrizioni"
L["GEN_TOOLTIP_DESC"]            = "Mostra tutte le descrizioni in Guild Recruiter."
L["GEN_ADDON_MESSAGES"]          = "Mostra messaggi di sistema"
L["GEN_ADDON_MESSAGES_DESC"]     = "Mostra i messaggi di sistema di Guild Recruiter."
L["KEEP_ADDON_OPEN"]             = "Mantieni l'addon aperto"
L["KEEP_ADDON_OPEN_DESC"]        = [[
Mantiene l'addon aperto e ignora ESC e altre azioni che potrebbero chiuderlo.

NOTA: Dopo aver modificato questa impostazione, esegui /rl.]]
L["GEN_MINIMAP"]                 = "Mostra icona minimappa"
L["GEN_MINIMAP_DESC"]            = "Mostra l'icona di Guild Recruiter sulla minimappa."
L["INVITE_SCAN_SETTINGS"]        = "Impostazioni inviti e scansione"
L["SEND_MESSAGE_WAIT_TIME"]      = "Ritardo invio messaggi"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "Tempo in secondi prima dell'invio dei messaggi in attesa (0,1–1 secondo)."
L["AUTO_SYNC"]                   = "Abilita sincronizzazione automatica"
L["AUTO_SYNC_DESC"]              = "Sincronizza automaticamente con i membri di gilda all'accesso."
L["SHOW_WHISPERS"]               = "Mostra sussurri in chat"
L["SHOW_WHISPERS_DESC"]          = [[
Mostra il messaggio inviato ai giocatori quando li inviti.

NOTA: Dopo aver modificato questa impostazione, esegui /rl.]]
L["GEN_CONTEXT"]                 = "Abilita invito con clic destro dalla chat"
L["GEN_CONTEXT_DESC"]            = "Mostra il menu contestuale di Guild Recruiter con clic destro sul nome in chat."
L["COMPACT_SIZE"]                = "Dimensione modalità compatta"
L["SCAN_WAIT_TIME"]              = "Ritardo scansione in secondi"
L["SCAN_WAIT_TIME_DESC"]         = [[
Tempo in secondi prima di cercare i giocatori (2–10 secondi).

NOTA: consigliati 5 o 6 secondi.]]
L["KEYBINDING_HEADER"]           = "Scorciatoie"
L["KEYBINDING_INVITE"]           = "Scorciatoia Invita"
L["KEYBINDING_INVITE_DESC"]      = "Scorciatoia per invitare un giocatore in gilda."
L["KEYBINDING_SCAN"]             = "Scorciatoia Scansione"
L["KEYBINDING_SCAN_DESC"]        = "Scorciatoia per cercare giocatori in cerca di gilda."
L["KEY_BINDING_NOTE"]            = "Nota: Le scorciatoie non influiscono sui tasti di WoW."
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "Impostazioni GM"
L["FORCE_OPTION"]                     = "Obbliga i non GM a usarlo"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "Abilita controllo inviti bloccati."
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "Prova a verificare se il giocatore ha bloccato gli inviti di gilda."
L["ENABLE_ANTI_SPAM_DESC"]            = "Abilita la funzione anti-spam per prevenire lo spam."
L["ANTI_SPAM_DAYS"]                   = "Ritardo di reinvito"
L["ANTI_SPAM_DAYS_DESC"]              = "Numero di giorni prima di reinvitare un giocatore."
L["GUILD_WELCOME_MSG"]                = "Messaggio di benvenuto in chat di gilda"
L["GUILD_WELCOME_MSG_DESC"]           = "Messaggio inviato in chat di gilda quando un giocatore entra."
L["WHISPER_WELCOME_MSG"]              = "Messaggio di benvenuto in sussurro"
L["WHISPER_WELCOME_MSG_DESC"]         = "Messaggio in sussurro inviato al giocatore quando entra in gilda."
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "Messaggi GM"
L["PLAYER_SETTINGS_DESC"]       = "I messaggi arancioni provengono dal GM."
L["INVITE_ACTIVE_MESSAGE"]      = "Messaggi di invito:"
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
Messaggi inviati ai potenziali reclute.

NOTA: Dopo una sincronizzazione, potresti dover usare /rl per vedere le modifiche.]]
L["NEW_MESSAGE_DESC"]           = "Aggiungi una descrizione del messaggio all'elenco inviti."
L["INVITE_DESC"]                = "Descrizione del messaggio di invito:"
L["INVITE_DESC_TOOLTIP"]        = "Una descrizione del messaggio di invito."
L["SYNC_MESSAGES"]              = "Sincronizza questo messaggio."
L["SYNC_MESSAGES_DESC"]         = "Sincronizza questo messaggio con la gilda."
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "Impostazioni invito"
L["INVITE_MESSAGES"] = "Messaggi di invito"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "Rimuovi voci selezionate dalla lista nera"
L["ADD_TO_BLACKLIST"]         = "Aggiungi giocatori alla lista nera."
L["BL_PRIVATE_REASON"]        = "Attiva/disattiva motivo privato"
L["BL_PRIVATE_REASON_DESC"]   = "Attiva/disattiva il motivo privato per la lista nera."
L["BL_PRIVATE_REASON_ERROR"]  = "Non hai messo nessuno in lista nera"
L["NO_REASON_GIVEN"]          = "Nessun motivo specificato"
L["ADDED_TO_BLACK_LIST"]      = "è stato aggiunto alla lista nera per il motivo %s."
L["BL_NAME_NOT_ADDED"]        = "non è stato aggiunto alla lista nera."
L["IS_ON_BLACK_LIST"]         = "è già nella lista nera."
L["BLACK_LIST_REASON_INPUT"]  = "Inserisci un motivo per mettere %s in lista nera."
L["BLACKLIST_NAME_PROMPT"] = [[
Inserisci il nome del giocatore
che vuoi mettere in lista nera.

Altro reame: aggiungi - e il nome del reame.
(NomeGiocatore-NomeReame)
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "Zone non valide"
L["ZONE_NOT_FOUND"]      = "Impossibile trovare la zona"
L["ZONE_INSTRUCTIONS"]   = "Il nome della zona deve corrispondere ESATTAMENTE al nome in gioco."
L["ZONE_ID"]             = "ID zona (ID numerico)"
L["ZONE_NAME"]           = "Nome della zona:"
L["ZONE_INVALID_REASON"] = "Motivo di non validità:"
L["ZONE_ID_DESC"] = [[
L'ID della zona non valida.
Elenco delle istanze:
https://wowpedia.fandom.com/wiki/InstanceID
Migliori ID delle zone del mondo che ho trovato:
https://wowpedia.fandom.com/wiki/UiMapID
Se trovi una zona da aggiungere, fammelo sapere.]]
L["ZONE_NOTE"]           = "Le zone con |cFF00FF00*|r sono le uniche modificabili."
L["ZONE_LIST_NAME"]      = "Lo scanner ignorerà le seguenti zone:"
--#endregion

--#region Analytics
L["ANALYTICS"]                     = "Statistiche"
L["ANALYTICS_DESC"]                = "Visualizza le tue statistiche sugli inviti in gilda."
L["ANALYTICS_BLACKLISTED"]         = "Giocatori messi in lista nera"
L["ANALYTICS_SCANNED"]             = "Giocatori scansionati totali"
L["ANALYTICS_INVITED"]             = "Giocatori invitati in gilda"
L["ANALYTICS_DECLINED"]            = "Giocatori che hanno rifiutato l'invito"
L["ANALYTICS_ACCEPTED"]            = "Giocatori che hanno accettato l'invito"
L["ANALYTICS_NO_GUILD"]            = "Giocatori senza gilda trovata"
L["ANALYTICS_STATS_START"]         = "Statistiche a partire da"
L["ANALYTICS_SESSION"]             = "Sessione"
L["ANALYTICS_SESSION_SCANNED"]     = "Scansionati"
L["ANALYTICS_SESSION_BLACKLISTED"] = "In lista nera"
L["ANALYTICS_SESSION_INVITED"]     = "Invitati"
L["ANALYTICS_SESSION_DECLINED"]    = "Invito rifiutato"
L["ANALYTICS_SESSION_ACCEPTED"]    = "Invito accettato"
L["ANALYTICS_SESSION_WAITING"]     = "In attesa di"
L["ANALYTICS_SESSION_TIMED_OUT"]   = "Invito scaduto"
L["ANALYTICS_SESSION_NO_GUILD"]    = "Potenziali trovati"
L["ANALYTICS_SESSION_STARTED"]     = "Sessione iniziata"
L["LAST_SCAN"]                     = "Ultimo giocatore scansionato"

L["GUILD_ANALYTICS"]   = "Statistiche gilda"
L["PROFILE_ANALYTICS"] = "Statistiche personaggio"
L["SESSION_ANALYTICS"] = "Statistiche sessione"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "Sincronizzazione già in corso"
L["SYNC_FAIL_TIMER"]               = "Sincronizzazione scaduta, riprova."
-- Server
L["AUTO_SYNC_STARTED"]             = "Hai avviato una sincronizzazione automatica con la tua gilda."
L["MANUAL_SYNC_STARTED"]           = "Hai avviato una sincronizzazione con la tua gilda."
L["SYNC_CLIENTS_FOUND"]            = "Hai trovato %d client da sincronizzare."
-- Client
L["SYNC_CLIENT_STARTED"]           = "ha richiesto una sincronizzazione di Guild Recruiter."
-- Either
L["SYNC_SETTINGS_FAILED"]          = "Impossibile preparare le impostazioni da inviare."

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "Nessun dato ricevuto dai client."
L["REQUEST_WAIT_TIMEOUT"]          = "Nessuna risposta ricevuta dal server."
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "Nessun client trovato con cui sincronizzare."

-- Sync Messages
L["AUTO_SYNC"]     = "Sincronizzazione automatica"
L["MANUAL_SYNC"]   = "Sincronizzazione manuale"
L["CLIENT_SYNC"]   = "Sincronizzazione client"
L["SYNC_FINISHED"] = "è stata completata."
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "Le impostazioni sono state aggiornate."
L["MESSAGE_LIST_CHANGED"]  = "L'elenco dei messaggi è stato aggiornato."
L["BLACKLIST_CHANGED"]     = "La lista nera è stata aggiornata con %d voci."
L["ANTISPAM_CHANGED"]      = "La lista anti-spam è stata aggiornata con %d voci."
--#endregion