local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "frFR")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "Le joueur a refusé l’invitation de guilde."
L["PLAYER_ALREADY_IN_GUILD"]         = "Ce joueur est déjà dans une guilde."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "Ce joueur est déjà dans votre guilde."
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "Ce joueur a déjà été invité."
L["PLAYER_NOT_FOUND"]                = "Joueur introuvable."
L["PLAYER_NOT_PLAYING"]              = "Le joueur ne joue pas à World of Warcraft."
L["PLAYER_IGNORING_YOU"]             = "Ce joueur vous ignore."
L["PLAYER_JOINED_GUILD"]             = "Le joueur a rejoint une guilde."
L["PLAYER_NOT_ONLINE"]               = "Le joueur n’est pas en ligne."
L["PLAYER_IN_GUILD"]                 = "Le joueur est dans une guilde."

--#region General
L["INVITE"]    = "Inviter"
L["SCAN"]      = "Scanner"
L["ABOUT"]     = "À propos"
L["CLOSE"]     = "Fermer"
L["ENABLE"]    = "Activer"
L["ENABLED"]   = "Activé"
L["DISABLE"]   = "Désactiver"
L["DISABLED"]  = "Désactivé"
L["REMOVE"]    = "Retirer"
L["HELP"]      = "Aide"
L["CONFIG"]    = "Configuration"
--#endregion

--#region Button Text
L["CANCEL"] = "Annuler"
L["DELETE"] = "Supprimer"
L["SAVE"]   = "Enregistrer"
L["NEW"]    = "Nouveau"
L["YES"]    = "Oui"
L["NO"]     = "Non"
L["OK"]     = "OK"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[Il s’agit d’une version VER de Guild Recruiter.
Merci de signaler tout problème sur notre serveur Discord.]]
L["AUTO_LOCKED"] = "Le déplacement de la fenêtre est maintenant verrouillé."
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "Anti-spam"
L["BLACKLIST"]     = "Liste noire"
L["SETTINGS"]      = "Paramètres"
L["PREVIEW_TITLE"] = "Aperçu du message sélectionné"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "Aucun nom de guilde, rechargez votre interface."
L["BL_NO_ONE_ADDED"]             = "Personne n’a été ajouté à la liste noire."
L["GUILD_LINK_NOT_FOUND"]        = "Lien de guilde introuvable. Rechargez votre interface."
L["GUILD_LINK_NOT_FOUND_LINE1"]  = "Essayez /rl ou reconnectez-vous (cela peut nécessiter plusieurs tentatives)"
L["GM_GUILD_LINK_NOT_FOUND"]     = "Créez un recrutement dans l’outil de recherche de guilde puis faites /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "Essayez de synchroniser avec la guilde pour obtenir le lien."
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "Invitation de guilde (sans messages)"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "Invitation de guilde (messages de bienvenue)"
L["BLACKLIST_PLAYER"]             = "Ajouter le joueur à la liste noire"
L["KICK_PLAYER_FROM_GUILD"]       = "Exclure le joueur de la guilde (ajouter à la liste noire)"
L["KICK_PLAYER_CONFIRMATION"]     = "Êtes-vous sûr de vouloir exclure %s de la guilde ?"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "Bienvenue PLAYERNAME dans GUILDNAME !"
L["DATABASE_RESET"] = [[
La base de données a été réinitialisée.
Suite à l’intégration de Classic et Cata, toutes les données ont été réinitialisées.
Veuillez nous excuser pour la gêne occasionnée.
|cFFFFFFFFVeuillez recharger votre interface (/rl ou /reload).|r]]
L["SLASH_COMMANDS"] = [[
Commandes de Guild Recruiter :
/rl recharge l’interface de WoW (comme /reload).
/gr help - Affiche ce message d’aide.
/gr config - Ouvre la fenêtre de configuration.
/gr blacklist <nom du joueur> - Ajoute le joueur à la liste noire.]]
L["MINIMAP_TOOLTIP"] = [[
Clic gauche : Ouvrir Guild Recruiter
Maj+Clic gauche : Ouvrir le scanner
Clic droit : Ouvrir la configuration
%AntiSpam dans la liste des invités.
%BlackList dans la liste des bloqués.]]
L["NO_LONGER_GUILD_LEADER"] = "n’est plus le chef de guilde."
L["NO_ANTI_SPAM"]           = "L’anti-spam n’est pas activé. Veuillez l’activer dans les paramètres."
L["CANNOT_INVITE"]          = "Vous n’avez pas l’autorisation d’inviter de nouveaux membres."
L["NOT_IN_GUILD"]           = "Guild Recruiter est désactivé car vous n’êtes pas dans une guilde."
L["NOT_IN_GUILD_LINE1"]     = "Si vous rejoignez une guilde, tapez /rl pour recharger."
L["FGI_LOADED"]             = "*AVERTISSEMENT* FGI est chargé. Désactivez-le pour utiliser Guild Recruiter."
--#endregion

--#region Base Screen
L["BACK"]                   = "Retour"
L["BACK_TOOLTIP"]           = "Revenir à l’écran précédent."
L["LOCK_TOOLTIP"]           = "Basculer le déplacement de la fenêtre"
L["RESET_FILTER"]           = "Réinitialiser le filtre"
L["RESET_FILTER_TOOLTIP"]   = "Réinitialise le filtre du scanner pour recommencer."
L["COMPACT_MODE"]           = "Mode compact"
L["COMPACT_MODE_TOOLTIP"]   = [[Basculer le mode compact.
Changez la taille du mode compact dans les paramètres.]]
L["ABOUT_TOOLTIP"]          = "Infos Discord, support et contribution."
L["SETTINGS_TOOLTIP"]       = "Modifier les paramètres de Guild Recruiter."
L["MANUAL_SYNC"]            = "Synchronisation manuelle"
L["MANUAL_SYNC_TOOLTIP"]    = "Synchronisez manuellement vos listes avec les membres de la guilde."
L["VIEW_ANALYTICS"]         = "Voir les statistiques"
L["VIEW_ANALYTICS_TOOLTIP"] = "Affiche vos statistiques d’invitations à la guilde."
L["BLACKLIST_TOOLTIP"]      = "Ajouter des joueurs à la liste noire."
L["CUSTOM_FILTERS"]         = "Filtres personnalisés"
L["CUSTOM_FILTERS_TOOLTIP"] = "Ajouter des filtres personnalisés au scanner."
L["CUSTOM_FILTERS_DESC"] = [[
Les filtres personnalisés permettent de filtrer les joueurs selon des critères spécifiques.
Par exemple, vous pouvez filtrer par classe ou par race.
]]
L["NEW_FILTER_DESC"]       = "Créer un nouveau filtre pour le scanner."
L["FILTER_SAVE_LIST"]      = "Enregistrer la liste de filtres"
L["FILTER_SAVE_LIST_DESC"] = "Choisissez un filtre à modifier."
L["FILTER_NAME"]           = "Entrez le nom du filtre :"
L["FILTER_NAME_EXISTS"]    = "Le nom du filtre existe déjà."
L["FILTER_CLASS"]          = "Choisissez une classe ou une combinaison de classes :"
L["SELECT_ALL_CLASSES"]    = "Sélectionner toutes les classes"
L["CLEAR_ALL_CLASSES"]     = "Désélectionner toutes les classes"
L["FILTER_SAVED"]          = "Filtre enregistré avec succès."
L["FILTER_DELETED"]        = "Filtre supprimé avec succès."
L["FILTER_SAVE_ERROR"]     = "Choisissez au moins 1 classe et/ou race."
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "Message uniquement"
L["GUILD_INVITE_ONLY"]               = "Invitation de guilde uniquement"
L["GUILD_INVITE_AND_MESSAGE"]        = "Invitation de guilde et message"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "Message uniquement si l’invitation est refusée"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "En attente"
L["GUILD_INVITE_SENT"]      = "Invitation de guilde envoyée à"
L["INVITE_MESSAGE_SENT"]    = "Message d’invitation envoyé à"
L["INVITE_MESSAGE_QUEUED"]  = "Message d’invitation mis en file d’attente pour"
L["GUILD_INVITE_BLOCKED"]   = "Message ignoré pour %s car les invitations de guilde sont bloquées."
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "Sélectionnez un filtre"
L["MIN_LEVEL"]                   = "Niveau minimum"
L["MAX_LEVEL"]                   = "Niveau maximum"
L["MAX_LEVEL_ERROR"]             = "Veuillez saisir un nombre entre 1 et "
L["LEVELS_FIXED"]                = "Niveaux corrigés"
L["LEVELS_TOO_CLOSE"]            = "Attention : gardez l’intervalle dans 5 niveaux."
L["SELECT_INVITE_TYPE"]          = "Sélectionnez le type d’invitation"
L["SELECT_INVITE_MESSAGE"]       = "Sélectionnez le message d’invitation"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "Créez le message dans les paramètres"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "Progression du filtre"
L["PLAYERS_FOUND"]             = "Joueurs trouvés"
L["SEND_MESSAGE"]              = "Envoyer un message"
L["SEND_INVITE"]               = "Envoyer une invitation"
L["SEND_INVITE_AND_MESSAGE"]   = "Envoyer invitation et message"
L["BLACKLIST_TITLE"]           = "Ajouter les joueurs sélectionnés à la liste noire"
L["BLACKLIST_SCANNER_TOOLTIP"] = "Ajoute les joueurs sélectionnés à la liste noire."
L["ANTISPAM_TITLE"]            = "Ajouter les joueurs sélectionnés à l’anti-spam"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "Ajoute les joueurs sélectionnés à la liste anti-spam."
L["WHO_RESULTS"]               = "Résultats /who : %d joueurs trouvés"
L["SCAN_FOR_PLAYERS"]          = "Rechercher des joueurs"
L["NEXT_QUERY"]                = "Prochaine requête : %s"
L["NEXT_PLAYER_INVITE"]        = "Prochain joueur à inviter (file : %d) :"
L["PLAYERS_QUEUED"]            = "Joueurs en file : %d"
L["NO_QUEUED_PLAYERS"]         = "Aucun joueur dans la file."
L["WAIT"]                      = "Attendre"
L["INVITE_FIRST_STEP"]         = "Vous devez d’abord cliquer sur « Rechercher des joueurs »."
L["ADD_TO_ANTISPAM"]           = "%d joueurs ajoutés à l’anti-spam."
L["ADD_TO_BLACKLIST"]          = "%d joueurs ajoutés à la liste noire."
L["SKIP_PLAYER"]               = "Ignorer le joueur"
L["SKIP"]                      = "Ignorer"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
J’espère que cet addon vous sera utile. J’y ai consacré beaucoup de temps et d’efforts.
Si vous souhaitez faire un don, utilisez le lien ci-dessous.
Merci pour votre soutien !]]
L["ABOUT_LINK_MESSAGE"] = "Pour plus d’informations, consultez ces liens :"
L["COPY_LINK_MESSAGE"]  = "Les liens sont copiables. Sélectionnez-en un et utilisez CTRL+C."
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(<sub> caractères par message)"
L["LENGTH_INFO"] = "Suppose 12 caractères si PLAYERNAME est utilisé"
L["MESSAGE_LENGTH"] = "Longueur du message"
L["GEN_GUILD_WIDE"]   = "Signifie que cela n’affecte que votre guilde actuelle."
L["GEN_ACCOUNT_WIDE"] = "Signifie que cela affecte tous vos personnages du compte."
L["RELOAD_AFTER_CHANGE"] = "Vous devez recharger l’interface (/rl) après avoir fait des changements."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - Crée un lien cliquable vers votre guilde."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - Affiche le nom de votre guilde.
PLAYERNAME - Affiche le nom du joueur invité.]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "Paramètres de GR"
L["GEN_WHATS_NEW"]               = "Afficher « Quoi de neuf ? »"
L["GEN_WHATS_NEW_DESC"]          = "Affiche la fenêtre « Quoi de neuf ? » lorsque Guild Recruiter est mis à jour."
L["GEN_TOOLTIPS"]                = "Afficher toutes les infobulles"
L["GEN_TOOLTIP_DESC"]            = "Afficher toutes les infobulles dans Guild Recruiter."
L["GEN_ADDON_MESSAGES"]          = "Afficher les messages système"
L["GEN_ADDON_MESSAGES_DESC"]     = "Afficher les messages système de Guild Recruiter."
L["KEEP_ADDON_OPEN"]             = "Garder l’addon ouvert"
L["KEEP_ADDON_OPEN_DESC"]        = [[
Garde l’addon ouvert et ignore ÉCHAP et d’autres actions susceptibles de le fermer.

REMARQUE : Après modification de ce paramètre, lancez /rl.]]
L["GEN_MINIMAP"]                 = "Afficher l’icône de la minicarte"
L["GEN_MINIMAP_DESC"]            = "Afficher l’icône de Guild Recruiter sur la minicarte."
L["INVITE_SCAN_SETTINGS"]        = "Paramètres d’invitation et de scan"
L["SEND_MESSAGE_WAIT_TIME"]      = "Délai d’envoi des messages"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "Temps en secondes avant l’envoi des messages en attente (0,1 à 1 seconde)."
L["AUTO_SYNC"]                   = "Activer la synchronisation automatique"
L["AUTO_SYNC_DESC"]              = "Synchroniser automatiquement avec les membres de la guilde à la connexion."
L["SHOW_WHISPERS"]               = "Afficher les chuchotements dans le chat"
L["SHOW_WHISPERS_DESC"]          = [[
Affiche le message envoyé aux joueurs lors de l’invitation.

REMARQUE : Après modification de ce paramètre, lancez /rl.]]
L["GEN_CONTEXT"]                 = "Activer l’invitation via clic droit depuis le chat"
L["GEN_CONTEXT_DESC"]            = "Affiche le menu contextuel de Guild Recruiter au clic droit sur un nom dans le chat."
L["COMPACT_SIZE"]                = "Taille du mode compact"
L["SCAN_WAIT_TIME"]              = "Délai du scan en secondes"
L["SCAN_WAIT_TIME_DESC"]         = [[
Temps en secondes avant la recherche de joueurs (2 à 10 secondes).

REMARQUE : 5 ou 6 secondes sont recommandées.]]
L["KEYBINDING_HEADER"]           = "Raccourcis clavier"
L["KEYBINDING_INVITE"]           = "Raccourci Inviter"
L["KEYBINDING_INVITE_DESC"]      = "Raccourci pour inviter un joueur dans la guilde."
L["KEYBINDING_SCAN"]             = "Raccourci Scanner"
L["KEYBINDING_SCAN_DESC"]        = "Raccourci pour rechercher des joueurs cherchant une guilde."
L["KEY_BINDING_NOTE"]            = "Remarque : Ces raccourcis n’affectent pas la configuration du clavier de WoW."
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "Paramètres GM"
L["FORCE_OPTION"]                     = "Forcer les non-GM à l’utiliser"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "Activer la vérification des invitations bloquées."
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "Tente de vérifier si le joueur invité a bloqué les invitations de guilde."
L["ENABLE_ANTI_SPAM_DESC"]            = "Active la fonction anti-spam pour éviter les spams."
L["ANTI_SPAM_DAYS"]                   = "Délai de ré-invitation"
L["ANTI_SPAM_DAYS_DESC"]              = "Nombre de jours avant de réinviter un joueur."
L["GUILD_WELCOME_MSG"]                = "Message de bienvenue dans le chat de guilde"
L["GUILD_WELCOME_MSG_DESC"]           = "Message envoyé dans le chat de guilde lorsqu’un joueur rejoint."
L["WHISPER_WELCOME_MSG"]              = "Message de bienvenue en chuchotement"
L["WHISPER_WELCOME_MSG_DESC"]         = "Message envoyé en chuchotement au joueur lorsqu’il rejoint la guilde."
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "Messages GM"
L["PLAYER_SETTINGS_DESC"]       = "Les messages en orange proviennent du GM."
L["INVITE_ACTIVE_MESSAGE"]      = "Messages d’invitation :"
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
Messages envoyés aux recrues potentielles.

REMARQUE : Après une synchronisation, vous devrez peut-être faire /rl pour voir les changements.]]
L["NEW_MESSAGE_DESC"]           = "Ajoutez une description du message à la liste d’invitations."
L["INVITE_DESC"]                = "Description du message d’invitation :"
L["INVITE_DESC_TOOLTIP"]        = "Une description du message d’invitation."
L["SYNC_MESSAGES"]              = "Synchroniser ce message."
L["SYNC_MESSAGES_DESC"]         = "Synchroniser ce message avec la guilde."
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "Paramètres d’invitation"
L["INVITE_MESSAGES"] = "Messages d’invitation"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "Supprimer les entrées sélectionnées de la liste noire"
L["ADD_TO_BLACKLIST"]         = "Ajouter des joueurs à la liste noire."
L["BL_PRIVATE_REASON"]        = "Basculer la raison privée"
L["BL_PRIVATE_REASON_DESC"]   = "Basculer la raison privée pour la liste noire."
L["BL_PRIVATE_REASON_ERROR"]  = "Vous n’avez mis personne sur la liste noire"
L["NO_REASON_GIVEN"]          = "Aucune raison indiquée"
L["ADDED_TO_BLACK_LIST"]      = "a été ajouté à la liste noire pour la raison %s."
L["BL_NAME_NOT_ADDED"]        = "n’a pas été ajouté à la liste noire."
L["IS_ON_BLACK_LIST"]         = "est déjà sur la liste noire."
L["BLACK_LIST_REASON_INPUT"]  = "Veuillez saisir une raison pour mettre %s sur la liste noire."
L["BLACKLIST_NAME_PROMPT"] = [[
Veuillez saisir le nom du joueur
que vous souhaitez mettre sur la liste noire.

Autre royaume : ajoutez - et le nom du royaume.
(NomDuJoueur-NomDuRoyaume)
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "Zones invalides"
L["ZONE_NOT_FOUND"]      = "Impossible de trouver la zone"
L["ZONE_INSTRUCTIONS"]   = "Le nom de la zone doit correspondre EXACTEMENT au nom en jeu."
L["ZONE_ID"]             = "ID de zone (ID numérique)"
L["ZONE_NAME"]           = "Nom de la zone :"
L["ZONE_INVALID_REASON"] = "Raison de l’invalidité :"
L["ZONE_ID_DESC"] = [[
L’ID de zone pour la zone invalide.
Liste des instances :
https://wowpedia.fandom.com/wiki/InstanceID
Meilleurs IDs de zones du monde que j’ai trouvés :
https://wowpedia.fandom.com/wiki/UiMapID
Si vous trouvez une zone à ajouter, merci de me le faire savoir.]]
L["ZONE_NOTE"]           = "Les zones avec |cFF00FF00*|r sont les seules zones modifiables."
L["ZONE_LIST_NAME"]      = "Le scanner ignorera les zones suivantes :"
--#endregion

--#region Analytics
L["ANALYTICS"]                     = "Statistiques"
L["ANALYTICS_DESC"]                = "Consultez vos statistiques d’invitations à la guilde."
L["ANALYTICS_BLACKLISTED"]         = "Joueurs que vous avez mis sur liste noire"
L["ANALYTICS_SCANNED"]             = "Joueurs scannés au total"
L["ANALYTICS_INVITED"]             = "Joueurs invités dans la guilde"
L["ANALYTICS_DECLINED"]            = "Joueurs ayant refusé l’invitation"
L["ANALYTICS_ACCEPTED"]            = "Joueurs ayant accepté l’invitation"
L["ANALYTICS_NO_GUILD"]            = "Joueurs sans guilde trouvée"
L["ANALYTICS_STATS_START"]         = "Statistiques depuis le"
L["ANALYTICS_SESSION"]             = "Session"
L["ANALYTICS_SESSION_SCANNED"]     = "Scannés"
L["ANALYTICS_SESSION_BLACKLISTED"] = "Mis sur liste noire"
L["ANALYTICS_SESSION_INVITED"]     = "Invités"
L["ANALYTICS_SESSION_DECLINED"]    = "Invitation refusée"
L["ANALYTICS_SESSION_ACCEPTED"]    = "Invitation acceptée"
L["ANALYTICS_SESSION_WAITING"]     = "En attente de"
L["ANALYTICS_SESSION_TIMED_OUT"]   = "Invitation expirée"
L["ANALYTICS_SESSION_NO_GUILD"]    = "Potentiels trouvés"
L["ANALYTICS_SESSION_STARTED"]     = "Session commencée"
L["LAST_SCAN"]                     = "Dernier joueur scanné"

L["GUILD_ANALYTICS"]   = "Statistiques de guilde"
L["PROFILE_ANALYTICS"] = "Statistiques du personnage"
L["SESSION_ANALYTICS"] = "Statistiques de la session"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "La synchronisation est déjà en cours"
L["SYNC_FAIL_TIMER"]               = "La synchronisation a expiré, veuillez réessayer."
-- Server
L["AUTO_SYNC_STARTED"]             = "Vous avez lancé une synchronisation automatique avec votre guilde."
L["MANUAL_SYNC_STARTED"]           = "Vous avez lancé une synchronisation avec votre guilde."
L["SYNC_CLIENTS_FOUND"]            = "Vous avez trouvé %d clients à synchroniser."
-- Client
L["SYNC_CLIENT_STARTED"]           = "a demandé une synchronisation Guild Recruiter."
-- Either
L["SYNC_SETTINGS_FAILED"]          = "Échec de la préparation des paramètres à envoyer."

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "Aucune donnée reçue des clients."
L["REQUEST_WAIT_TIMEOUT"]          = "Aucune réponse reçue du serveur."
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "Aucun client trouvé pour synchroniser."

-- Sync Messages
L["AUTO_SYNC"]     = "Synchronisation automatique"
L["MANUAL_SYNC"]   = "Synchronisation manuelle"
L["CLIENT_SYNC"]   = "Synchronisation client"
L["SYNC_FINISHED"] = "est terminée."
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "Les paramètres ont été mis à jour."
L["MESSAGE_LIST_CHANGED"]  = "La liste des messages a été mise à jour."
L["BLACKLIST_CHANGED"]     = "La liste noire a été mise à jour avec %d entrées."
L["ANTISPAM_CHANGED"]      = "La liste anti-spam a été mise à jour avec %d entrées."
--#endregion