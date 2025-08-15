local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "deDE")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]         = "Der Spieler hat die Gildeneinladung abgelehnt."
L["PLAYER_ALREADY_IN_GUILD"]        = "Dieser Spieler ist bereits in einer Gilde."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]   = "Dieser Spieler ist bereits in deiner Gilde."
L["PLAYER_ALREADY_INVITED_TO_GUILD"]= "Dieser Spieler wurde bereits eingeladen."
L["PLAYER_NOT_FOUND"]               = "Spieler nicht gefunden."
L["PLAYER_NOT_PLAYING"]             = "Der Spieler spielt derzeit nicht World of Warcraft."
L["PLAYER_IGNORING_YOU"]            = "Dieser Spieler ignoriert dich."
L["PLAYER_JOINED_GUILD"]            = "Der Spieler ist einer Gilde beigetreten."
L["PLAYER_NOT_ONLINE"]              = "Der Spieler ist nicht online."
L["PLAYER_IN_GUILD"]                = "Der Spieler ist in einer Gilde."

--#region General
L["INVITE"]   = "Einladen"
L["SCAN"]     = "Scannen"
L["ABOUT"]    = "Über"
L["CLOSE"]    = "Schließen"
L["ENABLE"]   = "Aktivieren"
L["ENABLED"]  = "Aktiviert"
L["DISABLE"]  = "Deaktivieren"
L["DISABLED"] = "Deaktiviert"
L["REMOVE"]   = "Entfernen"
L["HELP"]     = "Hilfe"
L["CONFIG"]   = "Konfiguration"
--#endregion

--#region Button Text
L["SCAN"]   = "Scannen"
L["CANCEL"] = "Abbrechen"
L["DELETE"] = "Löschen"
L["SAVE"]   = "Speichern"
L["NEW"]    = "Neu"
L["YES"]    = "Ja"
L["NO"]     = "Nein"
L["OK"]     = "OK"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[Dies ist eine VER-Version von Guild Recruiter.
Bitte melde alle Probleme auf unserem Discord-Server.]]
L["AUTO_LOCKED"] = "Bewegen des Fensters ist jetzt gesperrt."
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "Anti-Spam"
L["BLACKLIST"]     = "Schwarze Liste"
L["SETTINGS"]      = "Einstellungen"
L["PREVIEW_TITLE"] = "Vorschau der ausgewählten Nachricht"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]                = "Kein Gildenname, bitte lade dein UI neu."
L["BL_NO_ONE_ADDED"]              = "Niemand wurde zur schwarzen Liste hinzugefügt."
L["GUILD_LINK_NOT_FOUND"]         = "Gildenlink nicht gefunden. Bitte lade dein UI neu."
L["GUILD_LINK_NOT_FOUND_LINE1"]   = "Versuche /rl oder reloggen (es kann mehrere Versuche benötigen)"
L["GM_GUILD_LINK_NOT_FOUND"]      = "Erstelle eine Rekrutierung im Gildenfinder und dann /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"]  = "Versuche, mit der Gilde zu synchronisieren, um den Gildenlink zu erhalten."
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]     = "Gildeneinladung (ohne Nachrichten)"
L["GUILD_INVITE_WELCOME_MESSAGE"]= "Gildeneinladung (Willkommensnachrichten)"
L["BLACKLIST_PLAYER"]            = "Spieler zur schwarzen Liste hinzufügen"
L["KICK_PLAYER_FROM_GUILD"]      = "Spieler aus der Gilde werfen (zur schwarzen Liste hinzufügen)"
L["KICK_PLAYER_CONFIRMATION"]    = "Möchtest du %s wirklich aus der Gilde werfen?"
--#endregion

--#region Core
L["RECRUITER"]              = "recruiter"
L["DEFAULT_GUILD_WELCOME"]  = "Willkommen PLAYERNAME bei GUILDNAME!"
L["DATABASE_RESET"] = [[
Die Datenbank wurde zurückgesetzt.
Aufgrund der Integration von Classic und Cata wurden alle Daten zurückgesetzt.
Ich entschuldige mich für die Unannehmlichkeiten.
|cFFFFFFFFBitte lade dein UI neu (/rl oder /reload).|r]]
L["SLASH_COMMANDS"] = [[
Guild Recruiter Slash-Befehle:
 /rl lädt das WoW-UI neu (wie /reload).
 /gr help - Zeigt diese Hilfenachricht an.
 /gr config - Öffnet das Konfigurationsfenster.
 /gr blacklist <Spielername> - Fügt den Spieler der schwarzen Liste hinzu.]]
L["MINIMAP_TOOLTIP"] = [[
Linksklick: Guild Recruiter öffnen
Umschalt+Linksklick: Scanner öffnen
Rechtsklick: Konfiguration öffnen
%AntiSpam in der Einladungsliste.
%BlackList in der Blacklist-Liste.]]
L["NO_LONGER_GUILD_LEADER"] = "ist nicht mehr der Gildenleiter."
L["NO_ANTI_SPAM"]           = "Anti-Spam ist nicht aktiviert. Bitte in den Einstellungen aktivieren."
L["CANNOT_INVITE"]          = "Du hast keine Berechtigung, neue Mitglieder einzuladen."
L["NOT_IN_GUILD"]           = "Guild Recruiter ist deaktiviert, weil du in keiner Gilde bist."
L["NOT_IN_GUILD_LINE1"]     = "Wenn du einer Gilde beitrittst, gib /rl ein, um neu zu laden."
L["FGI_LOADED"]             = "*WARNUNG* FGI ist geladen. Bitte deaktiviere es, um Guild Recruiter zu verwenden."
--#endregion

--#region Base Screen
L["BACK"]                    = "Zurück"
L["BACK_TOOLTIP"]            = "Zur vorherigen Ansicht zurückkehren."
L["LOCK_TOOLTIP"]            = "Bewegen des Fensters umschalten"
L["RESET_FILTER"]            = "Filter zurücksetzen"
L["RESET_FILTER_TOOLTIP"]    = "Scanner-Filter zurücksetzen, um neu zu beginnen."
L["COMPACT_MODE"]            = "Kompaktmodus"
L["COMPACT_MODE_TOOLTIP"]    = [[Kompaktmodus umschalten.
Ändere die Größe des Kompaktmodus in den Einstellungen.]]
L["ABOUT_TOOLTIP"]           = "Discord-Infos, Support-Infos und wie du beitragen kannst."
L["SETTINGS_TOOLTIP"]        = "Einstellungen für Guild Recruiter ändern."
L["MANUAL_SYNC"]             = "Manuelle Synchronisierung"
L["MANUAL_SYNC_TOOLTIP"]     = "Synchronisiere deine Listen manuell mit anderen in der Gilde."
L["VIEW_ANALYTICS"]          = "Statistiken anzeigen"
L["VIEW_ANALYTICS_TOOLTIP"]  = "Zeigt deine Einladungsstatistiken an."
L["BLACKLIST_TOOLTIP"]       = "Spieler zur schwarzen Liste hinzufügen."
L["CUSTOM_FILTERS"]          = "Benutzerdefinierte Filter"
L["CUSTOM_FILTERS_TOOLTIP"]  = "Füge dem Scanner benutzerdefinierte Filter hinzu."
L["CUSTOM_FILTERS_DESC"]     = [[
Benutzerdefinierte Filter ermöglichen es dir, Spieler anhand bestimmter Kriterien zu filtern.
Zum Beispiel kannst du Spieler nach Klasse oder Rasse filtern.
]]
L["NEW_FILTER_DESC"]         = "Erstelle einen neuen Filter für den Scanner."
L["FILTER_SAVE_LIST"]        = "Filterliste speichern"
L["FILTER_SAVE_LIST_DESC"]   = "Wähle einen Filter zum Bearbeiten."
L["FILTER_NAME"]             = "Filternamen eingeben:"
L["FILTER_NAME_EXISTS"]      = "Filtername existiert bereits."
L["FILTER_CLASS"]            = "Wähle eine Klasse oder Klassenkombination:"
L["SELECT_ALL_CLASSES"]      = "Alle Klassen auswählen"
L["CLEAR_ALL_CLASSES"]       = "Alle Klassen abwählen"
L["FILTER_SAVED"]            = "Filter erfolgreich gespeichert."
L["FILTER_DELETED"]          = "Filter erfolgreich gelöscht."
L["FILTER_SAVE_ERROR"]       = "Wähle mindestens 1 Klasse und/oder Rasse."
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                     = "Nur Nachricht"
L["GUILD_INVITE_ONLY"]                = "Nur Gildeneinladung"
L["GUILD_INVITE_AND_MESSAGE"]         = "Gildeneinladung und Nachricht"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"]  = "Nur Nachricht, wenn Einladung abgelehnt wird"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"]  = "Ausstehend"
L["GUILD_INVITE_SENT"]       = "Gildeneinladung gesendet an"
L["INVITE_MESSAGE_SENT"]     = "Einladungsnachricht gesendet an"
L["INVITE_MESSAGE_QUEUED"]   = "Einladungsnachricht zur Sendung in die Warteschlange gestellt für"
L["GUILD_INVITE_BLOCKED"]    = "Einladungsnachricht für %s übersprungen, da Gildeneinladungen blockiert sind."
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]            = "Filter auswählen"
L["MIN_LEVEL"]                  = "Mindestlevel"
L["MAX_LEVEL"]                  = "Maximallevel"
L["MAX_LEVEL_ERROR"]            = "Bitte gib eine Zahl zwischen 1 und "
L["LEVELS_FIXED"]               = "Level korrigiert"
L["LEVELS_TOO_CLOSE"]           = "Achtung: Halte den Levelbereich innerhalb von 5 Stufen."
L["SELECT_INVITE_TYPE"]         = "Einladungsart auswählen"
L["SELECT_INVITE_MESSAGE"]      = "Einladungsnachricht auswählen"
L["CREATE_MESSAGE_IN_SETTINGS"] = "Nachricht in den Einstellungen erstellen"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]            = "Filterfortschritt"
L["PLAYERS_FOUND"]              = "Gefundene Spieler"
L["SEND_MESSAGE"]               = "Nachricht senden"
L["SEND_INVITE"]                = "Einladung senden"
L["SEND_INVITE_AND_MESSAGE"]    = "Einladung und Nachricht senden"
L["BLACKLIST_TITLE"]            = "Ausgewählte Spieler zur schwarzen Liste hinzufügen"
L["BLACKLIST_SCANNER_TOOLTIP"]  = "Ausgewählte Spieler zur schwarzen Liste hinzufügen."
L["ANTISPAM_TITLE"]             = "Ausgewählte Spieler zur Anti-Spam-Liste hinzufügen"
L["ANTISPAM_SCANNER_TOOLTIP"]   = "Fügt ausgewählte Spieler zur Anti-Spam-Liste hinzu."
L["WHO_RESULTS"]                = "Who-Ergebnisse: %d Spieler gefunden"
L["SCAN_FOR_PLAYERS"]           = "Nach Spielern scannen"
L["NEXT_QUERY"]                 = "Nächste Abfrage: %s"
L["NEXT_PLAYER_INVITE"]         = "Nächster einzuladender Spieler (Warteschlange: %d):"
L["PLAYERS_QUEUED"]             = "Spieler in Warteschlange: %d"
L["NO_QUEUED_PLAYERS"]          = "Keine Spieler in der Warteschlange."
L["WAIT"]                       = "Warten"
L["INVITE_FIRST_STEP"]          = "Du musst zuerst auf „Nach Spielern suchen“ klicken."
L["ADD_TO_ANTISPAM"]            = "Es wurden %d Spieler zur Anti-Spam-Liste hinzugefügt."
L["ADD_TO_BLACKLIST"]           = "Es wurden %d Spieler zur schwarzen Liste hinzugefügt."
L["SKIP_PLAYER"]                = "Spieler überspringen"
L["SKIP"]                       = "Überspringen"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
Ich hoffe, du findest dieses Addon nützlich. Ich habe viel Zeit und Mühe in
die Entwicklung gesteckt. Wenn du spenden möchtest, nutze bitte den untenstehenden Link.
Vielen Dank für deine Unterstützung!]]
L["ABOUT_LINK_MESSAGE"] = "Für weitere Informationen besuche bitte folgende Links:"
L["COPY_LINK_MESSAGE"]  = "Links sind kopierbar. Markiere den Link und kopiere ihn (STRG+C)."
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]  = "(<sub> Zeichen pro Nachricht)"
L["LENGTH_INFO"]= "Geht von 12 Zeichen aus, wenn PLAYERNAME verwendet wird"
L["MESSAGE_LENGTH"] = "Nachrichtenlänge"
L["GEN_GUILD_WIDE"]   = "Bedeutet, dass nur deine aktuelle Gilde betroffen ist."
L["GEN_ACCOUNT_WIDE"] = "Bedeutet, dass alle deine Charaktere accountweit betroffen sind."
L["RELOAD_AFTER_CHANGE"] = "Du musst dein UI (/rl) neu laden, nachdem du Änderungen vorgenommen hast."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - Erstellt einen anklickbaren Link zu deiner Gilde."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - Zeigt deinen Gildennamen an.
PLAYERNAME - Zeigt den Namen des eingeladenen Spielers an.]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

--#region General Settings
L["GR_SETTINGS"]                = "GR-Einstellungen"
L["GEN_WHATS_NEW"]              = "„Was ist neu?“ anzeigen"
L["GEN_WHATS_NEW_DESC"]         = "Zeigt das „Was ist neu?“-Fenster an, wenn Guild Recruiter aktualisiert wurde."
L["GEN_TOOLTIPS"]               = "Alle Tooltips anzeigen"
L["GEN_TOOLTIP_DESC"]           = "Alle Tooltips im Addon Guild Recruiter anzeigen."
L["GEN_ADDON_MESSAGES"]         = "Systemnachrichten anzeigen"
L["GEN_ADDON_MESSAGES_DESC"]    = "Systemnachrichten von Guild Recruiter anzeigen."
L["KEEP_ADDON_OPEN"]            = "Addon geöffnet halten"
L["KEEP_ADDON_OPEN_DESC"]       = [[
Halte das Addon geöffnet und ignoriere ESC und andere Dinge, die es schließen könnten.

HINWEIS: Nach Änderung dieser Einstellung musst du ein /rl durchführen.]]
L["GEN_MINIMAP"]                = "Minimap-Symbol anzeigen"
L["GEN_MINIMAP_DESC"]           = "Das Minimap-Symbol von Guild Recruiter anzeigen."
L["INVITE_SCAN_SETTINGS"]       = "Einladungs- und Scan-Einstellungen"
L["SEND_MESSAGE_WAIT_TIME"]     = "Verzögerung beim Senden von Nachrichten"
L["SEND_MESSAGE_WAIT_TIME_DESC"]= "Zeit in Sekunden, bevor wartende Nachrichten gesendet werden (0,1 bis 1 Sekunde)."
L["AUTO_SYNC"]                  = "Automatische Synchronisierung aktivieren"
L["AUTO_SYNC_DESC"]             = "Beim Einloggen automatisch mit Gildenmitgliedern synchronisieren."
L["SHOW_WHISPERS"]              = "Flüstern im Chat anzeigen"
L["SHOW_WHISPERS_DESC"]         = [[
Zeigt die Nachricht, die du Spielern beim Einladen sendest.

HINWEIS: Nach Änderung dieser Einstellung musst du ein /rl durchführen.]]
L["GEN_CONTEXT"]                = "Rechtsklick-Einladung aus dem Chat aktivieren"
L["GEN_CONTEXT_DESC"]           = "Zeigt das Guild-Recruiter-Kontextmenü beim Rechtsklick auf einen Namen im Chat."
L["COMPACT_SIZE"]               = "Kompaktgröße"
L["SCAN_WAIT_TIME"]             = "Scan-Verzögerung in Sekunden"
L["SCAN_WAIT_TIME_DESC"]        = [[
Die Zeit in Sekunden, bevor nach Spielern gesucht wird (2 bis 10 Sekunden).

HINWEIS: 5 oder 6 Sekunden werden empfohlen.]]
L["KEYBINDING_HEADER"]          = "Tastenzuweisungen"
L["KEYBINDING_INVITE"]          = "Tastenzuweisung Einladen"
L["KEYBINDING_INVITE_DESC"]     = "Tastenzuweisung, um einen Spieler in die Gilde einzuladen."
L["KEYBINDING_SCAN"]            = "Tastenzuweisung Scannen"
L["KEYBINDING_SCAN_DESC"]       = "Tastenzuweisung, um nach Spielern zu scannen, die eine Gilde suchen."
L["KEY_BINDING_NOTE"]           = "Hinweis: Tastenzuweisungen beeinflussen nicht die WoW-Tastaturbelegung."
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]            = "GM-Einstellungen"
L["FORCE_OPTION"]                  = "Nicht-GMs zur Nutzung zwingen"
L["ENABLE_BLOCK_INVITE_CHECK"]     = "Prüfung auf blockierte Einladungen aktivieren."
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"] = "Versucht zu prüfen, ob der eingeladene Spieler Gildeneinladungen blockiert hat."
L["ENABLE_ANTI_SPAM_DESC"]         = "Aktiviere die Anti-Spam-Funktion, um Spam zu verhindern."
L["ANTI_SPAM_DAYS"]                = "Wiedereinladungs-Verzögerung"
L["ANTI_SPAM_DAYS_DESC"]           = "Anzahl der Tage, bevor ein Spieler erneut eingeladen wird."
L["GUILD_WELCOME_MSG"]             = "Willkommensnachricht im Gildenchat"
L["GUILD_WELCOME_MSG_DESC"]        = "Die Nachricht, die im Gildenchat gesendet wird, wenn ein neuer Spieler beitritt."
L["WHISPER_WELCOME_MSG"]           = "Flüster-Willkommensnachricht"
L["WHISPER_WELCOME_MSG_DESC"]      = "Geflüsterte Nachricht, die an einen Spieler gesendet wird, wenn er der Gilde beitritt."
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]        = "GM-Nachrichten"
L["PLAYER_SETTINGS_DESC"]      = "Orangefarbene Nachrichten stammen vom GM."
L["INVITE_ACTIVE_MESSAGE"]     = "Einladungsnachrichten:"
L["INVITE_ACTIVE_MESSAGE_DESC"]= [[
Die Nachrichten, die an potenzielle Rekruten gesendet werden.

HINWEIS: Möglicherweise musst du nach einer Synchronisierung /rl ausführen, um Änderungen zu sehen.]]
L["NEW_MESSAGE_DESC"]          = "Füge eine Beschreibung der Nachricht zur Einladeliste hinzu."
L["INVITE_DESC"]               = "Beschreibung der Einladungsnachricht:"
L["INVITE_DESC_TOOLTIP"]       = "Eine Beschreibung der Einladungsnachricht."
L["SYNC_MESSAGES"]             = "Diese Nachricht synchronisieren."
L["SYNC_MESSAGES_DESC"]        = "Diese Nachricht mit der Gilde synchronisieren."
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"]  = "Einladungseinstellungen"
L["INVITE_MESSAGES"]  = "Einladungsnachrichten"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]        = "Ausgewählte Blacklist-Einträge entfernen"
L["ADD_TO_BLACKLIST"]        = "Spieler zur schwarzen Liste hinzufügen."
L["BL_PRIVATE_REASON"]       = "Privaten Grund umschalten"
L["BL_PRIVATE_REASON_DESC"]  = "Privaten Grund für Blacklisting umschalten."
L["BL_PRIVATE_REASON_ERROR"] = "Du hast nicht auf die schwarze Liste gesetzt"
L["NO_REASON_GIVEN"]         = "Kein Grund angegeben"
L["ADDED_TO_BLACK_LIST"]     = "wurde mit dem Grund %s zur schwarzen Liste hinzugefügt."
L["BL_NAME_NOT_ADDED"]       = "wurde nicht zur schwarzen Liste hinzugefügt."
L["IS_ON_BLACK_LIST"]        = "steht bereits auf der schwarzen Liste."
L["BLACK_LIST_REASON_INPUT"] = "Bitte gib einen Grund für das Blacklisting von %s ein."
L["BLACKLIST_NAME_PROMPT"] = [[
Bitte gib den Namen des Spielers ein,
den du auf die schwarze Liste setzen möchtest.

Anderer Realm, füge - und den Realmnamen hinzu.
(Spielername-Realmname)
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "Ungültige Zonen"
L["ZONE_NOT_FOUND"]      = "Zone konnte nicht gefunden werden"
L["ZONE_INSTRUCTIONS"]   = "Der Zonenname muss GENAU dem Namen im Spiel entsprechen."
L["ZONE_ID"]             = "Zonen-ID (numerische ID)"
L["ZONE_NAME"]           = "Name der Zone:"
L["ZONE_INVALID_REASON"] = "Grund für die Ungültigkeit:"
L["ZONE_ID_DESC"] = [[
Die Zonen-ID für die ungültige Zone.
Liste der Instanzen:
https://wowpedia.fandom.com/wiki/InstanceID
Beste mir bekannte Weltzonen-IDs:
https://wowpedia.fandom.com/wiki/UiMapID
Wenn du eine Zone findest, die hinzugefügt werden sollte, lass es mich bitte wissen.]]
L["ZONE_NOTE"]           = "Zonen mit |cFF00FF00*|r sind die einzigen bearbeitbaren Zonen."
L["ZONE_LIST_NAME"]      = "Die folgenden Zonen werden vom Scanner ignoriert:"
--#endregion

--#region Analytics
L["ANALYTICS"]                      = "Analysen"
L["ANALYTICS_DESC"]                 = "Sieh dir deine Statistiken zum Einladen von Spielern in die Gilde an."
L["ANALYTICS_BLACKLISTED"]          = "Spieler, die du auf die schwarze Liste gesetzt hast"
L["ANALYTICS_SCANNED"]              = "Insgesamt gescannte Spieler"
L["ANALYTICS_INVITED"]              = "Spieler, die du in die Gilde eingeladen hast"
L["ANALYTICS_DECLINED"]             = "Spieler, die Einladung abgelehnt haben"
L["ANALYTICS_ACCEPTED"]             = "Spieler, die Einladung angenommen haben"
L["ANALYTICS_NO_GUILD"]             = "Spieler ohne gefundene Gilde"
L["ANALYTICS_STATS_START"]          = "Statistiken beginnend am"
L["ANALYTICS_SESSION"]              = "Sitzung"
L["ANALYTICS_SESSION_SCANNED"]      = "Gescannt"
L["ANALYTICS_SESSION_BLACKLISTED"]  = "Auf Blacklist gesetzt"
L["ANALYTICS_SESSION_INVITED"]      = "Eingeladen"
L["ANALYTICS_SESSION_DECLINED"]     = "Einladung abgelehnt"
L["ANALYTICS_SESSION_ACCEPTED"]     = "Einladung angenommen"
L["ANALYTICS_SESSION_WAITING"]      = "Wartend auf"
L["ANALYTICS_SESSION_TIMED_OUT"]    = "Einladung abgelaufen"
L["ANALYTICS_SESSION_NO_GUILD"]     = "Potenzial gefunden"
L["ANALYTICS_SESSION_STARTED"]      = "Sitzung gestartet"
L["LAST_SCAN"]                      = "Zuletzt gescannter Spieler"

L["GUILD_ANALYTICS"]   = "Gildenanalysen"
L["PROFILE_ANALYTICS"] = "Charakteranalysen"
L["SESSION_ANALYTICS"] = "Sitzungsanalysen"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "Synchronisierung läuft bereits"
L["SYNC_FAIL_TIMER"]               = "Die Synchronisierung ist abgelaufen, bitte versuche es erneut."
-- Server
L["AUTO_SYNC_STARTED"]             = "Du hast eine automatische Synchronisierung mit deiner Gilde gestartet."
L["MANUAL_SYNC_STARTED"]           = "Du hast eine Synchronisierung mit deiner Gilde gestartet."
L["SYNC_CLIENTS_FOUND"]            = "Du hast %d Clients zum Synchronisieren gefunden."
-- Client
L["SYNC_CLIENT_STARTED"]           = "hat eine Synchronisierung mit Guild Recruiter angefordert."
-- Either
L["SYNC_SETTINGS_FAILED"]          = "Vorbereitung der Einstellungen zum Senden fehlgeschlagen."

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "Keine Daten von Client(s) erhalten."
L["REQUEST_WAIT_TIMEOUT"]          = "Keine Antwort vom Server erhalten."
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "Keine Clients zum Synchronisieren gefunden."

-- Sync Messages
L["AUTO_SYNC"]     = "Auto-Sync"
L["MANUAL_SYNC"]   = "Manueller Sync"
L["CLIENT_SYNC"]   = "Client-Sync"
L["SYNC_FINISHED"] = "ist abgeschlossen."

-- End of Sync Messages
L["SETTINGS_CHANGED"]      = "Einstellungen wurden aktualisiert."
L["MESSAGE_LIST_CHANGED"]  = "Nachrichtenliste wurde aktualisiert."
L["BLACKLIST_CHANGED"]     = "Blacklist wurde mit %d Einträgen aktualisiert."
L["ANTISPAM_CHANGED"]      = "Anti-Spam-Liste wurde mit %d Einträgen"