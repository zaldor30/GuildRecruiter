local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ptBR")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "O jogador recusou o convite de guilda."
L["PLAYER_ALREADY_IN_GUILD"]         = "Esse jogador já está em uma guilda."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "Esse jogador já está na sua guilda."
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "Esse jogador já foi convidado."
L["PLAYER_NOT_FOUND"]                = "Jogador não encontrado."
L["PLAYER_NOT_PLAYING"]              = "Esse jogador não está jogando World of Warcraft."
L["PLAYER_IGNORING_YOU"]             = "Esse jogador está te ignorando."
L["PLAYER_JOINED_GUILD"]             = "O jogador entrou em uma guilda."
L["PLAYER_NOT_ONLINE"]               = "O jogador está offline."
L["PLAYER_IN_GUILD"]                 = "O jogador está em uma guilda."

--#region General
L["INVITE"]    = "Convidar"
L["SCAN"]      = "Escanear"
L["ABOUT"]     = "Sobre"
L["CLOSE"]     = "Fechar"
L["ENABLE"]    = "Ativar"
L["ENABLED"]   = "Ativado"
L["DISABLE"]   = "Desativar"
L["DISABLED"]  = "Desativado"
L["REMOVE"]    = "Remover"
L["HELP"]      = "Ajuda"
L["CONFIG"]    = "Configurações"
--#endregion

--#region Button Text
L["CANCEL"] = "Cancelar"
L["DELETE"] = "Excluir"
L["SAVE"]   = "Salvar"
L["NEW"]    = "Novo"
L["YES"]    = "Sim"
L["NO"]     = "Não"
L["OK"]     = "OK"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[Esta é uma versão VER do Guild Recruiter.
Relate quaisquer problemas no nosso servidor do Discord.]]
L["AUTO_LOCKED"] = "O movimento da janela agora está bloqueado."
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "Anti-spam"
L["BLACKLIST"]     = "Lista negra"
L["SETTINGS"]      = "Configurações"
L["PREVIEW_TITLE"] = "Prévia da mensagem selecionada"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "Sem nome de guilda, recarregue a interface."
L["BL_NO_ONE_ADDED"]             = "Ninguém foi adicionado à lista negra."
L["GUILD_LINK_NOT_FOUND"]        = "Link da guilda não encontrado. Recarregue a interface."
L["GUILD_LINK_NOT_FOUND_LINE1"]  = "Tente /rl ou reconectar (pode exigir várias tentativas)"
L["GM_GUILD_LINK_NOT_FOUND"]     = "Crie um recrutamento no localizador de guildas e depois /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "Tente sincronizar com a guilda para obter o link."
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "Convite de guilda (sem mensagens)"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "Convite de guilda (mensagens de boas-vindas)"
L["BLACKLIST_PLAYER"]             = "Adicionar jogador à lista negra"
L["KICK_PLAYER_FROM_GUILD"]       = "Expulsar jogador da guilda (adicionar à lista negra)"
L["KICK_PLAYER_CONFIRMATION"]     = "Tem certeza de que deseja expulsar %s da guilda?"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "Bem-vindo(a) PLAYERNAME à GUILDNAME!"
L["DATABASE_RESET"] = [[
O banco de dados foi redefinido.
Devido à integração de Classic e Cata, todos os dados foram redefinidos.
Pedimos desculpas pelo inconveniente.
|cFFFFFFFFRecarregue a interface (/rl ou /reload).|r]]
L["SLASH_COMMANDS"] = [[
Comandos do Guild Recruiter:
/rl recarrega a interface do WoW (como /reload).
/gr help - Mostra esta mensagem de ajuda.
/gr config - Abre a janela de configurações.
/gr blacklist <nome do jogador> - Adiciona o jogador à lista negra.]]
L["MINIMAP_TOOLTIP"] = [[
Clique esquerdo: Abrir Guild Recruiter
Shift+Clique esquerdo: Abrir scanner
Clique direito: Abrir configurações
%AntiSpam na lista de convidados.
%BlackList na lista de bloqueados.]]
L["NO_LONGER_GUILD_LEADER"] = "não é mais o líder da guilda."
L["NO_ANTI_SPAM"]           = "O anti-spam não está habilitado. Ative nas configurações."
L["CANNOT_INVITE"]          = "Você não tem permissão para convidar novos membros."
L["NOT_IN_GUILD"]           = "Guild Recruiter está desativado porque você não está em uma guilda."
L["NOT_IN_GUILD_LINE1"]     = "Se entrar em uma guilda, use /rl para recarregar."
L["FGI_LOADED"]             = "*AVISO* FGI está carregado. Desative para usar o Guild Recruiter."
--#endregion

--#region Base Screen
L["BACK"]                   = "Voltar"
L["BACK_TOOLTIP"]           = "Voltar para a tela anterior."
L["LOCK_TOOLTIP"]           = "Alternar movimento da janela"
L["RESET_FILTER"]           = "Redefinir filtro"
L["RESET_FILTER_TOOLTIP"]   = "Redefine o filtro do scanner para recomeçar."
L["COMPACT_MODE"]           = "Modo compacto"
L["COMPACT_MODE_TOOLTIP"]   = [[Alterna o modo compacto.
Ajuste o tamanho do modo compacto nas configurações.]]
L["ABOUT_TOOLTIP"]          = "Informações de Discord, suporte e como contribuir."
L["SETTINGS_TOOLTIP"]       = "Alterar as configurações do Guild Recruiter."
L["MANUAL_SYNC"]            = "Sincronização manual"
L["MANUAL_SYNC_TOOLTIP"]    = "Sincronize manualmente suas listas com outros membros da guilda."
L["VIEW_ANALYTICS"]         = "Ver estatísticas"
L["VIEW_ANALYTICS_TOOLTIP"] = "Detalha suas estatísticas de convites da guilda."
L["BLACKLIST_TOOLTIP"]      = "Adicionar jogadores à lista negra."
L["CUSTOM_FILTERS"]         = "Filtros personalizados"
L["CUSTOM_FILTERS_TOOLTIP"] = "Adicionar filtros personalizados ao scanner."
L["CUSTOM_FILTERS_DESC"] = [[
Filtros personalizados permitem filtrar jogadores por critérios específicos.
Por exemplo, é possível filtrar por classe ou raça.]]
L["NEW_FILTER_DESC"]       = "Criar um novo filtro para o scanner."
L["FILTER_SAVE_LIST"]      = "Salvar lista de filtros"
L["FILTER_SAVE_LIST_DESC"] = "Escolha um filtro para modificar."
L["FILTER_NAME"]           = "Insira o nome do filtro:"
L["FILTER_NAME_EXISTS"]    = "O nome do filtro já existe."
L["FILTER_CLASS"]          = "Escolha uma classe ou combinação de classes:"
L["SELECT_ALL_CLASSES"]    = "Selecionar todas as classes"
L["CLEAR_ALL_CLASSES"]     = "Desmarcar todas as classes"
L["FILTER_SAVED"]          = "Filtro salvo com sucesso."
L["FILTER_DELETED"]        = "Filtro excluído com sucesso."
L["FILTER_SAVE_ERROR"]     = "Selecione pelo menos 1 classe e/ou raça."
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "Apenas mensagem"
L["GUILD_INVITE_ONLY"]               = "Apenas convite de guilda"
L["GUILD_INVITE_AND_MESSAGE"]        = "Convite de guilda e mensagem"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "Apenas mensagem se o convite for recusado"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "Pendente"
L["GUILD_INVITE_SENT"]      = "Convite de guilda enviado para"
L["INVITE_MESSAGE_SENT"]    = "Mensagem de convite enviada para"
L["INVITE_MESSAGE_QUEUED"]  = "Mensagem de convite em fila para"
L["GUILD_INVITE_BLOCKED"]   = "Mensagem ignorada para %s porque convites de guilda estão bloqueados."
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "Selecione um filtro"
L["MIN_LEVEL"]                   = "Nível mínimo"
L["MAX_LEVEL"]                   = "Nível máximo"
L["MAX_LEVEL_ERROR"]             = "Insira um número entre 1 e "
L["LEVELS_FIXED"]                = "Níveis corrigidos"
L["LEVELS_TOO_CLOSE"]            = "Aviso: mantenha o intervalo dentro de 5 níveis."
L["SELECT_INVITE_TYPE"]          = "Selecione o tipo de convite"
L["SELECT_INVITE_MESSAGE"]       = "Selecione a mensagem de convite"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "Crie a mensagem nas configurações"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "Progresso do filtro"
L["PLAYERS_FOUND"]             = "Jogadores encontrados"
L["SEND_MESSAGE"]              = "Enviar mensagem"
L["SEND_INVITE"]               = "Enviar convite"
L["SEND_INVITE_AND_MESSAGE"]   = "Enviar convite e mensagem"
L["BLACKLIST_TITLE"]           = "Adicionar jogadores selecionados à lista negra"
L["BLACKLIST_SCANNER_TOOLTIP"] = "Adiciona os jogadores selecionados à lista negra."
L["ANTISPAM_TITLE"]            = "Adicionar jogadores selecionados ao anti-spam"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "Adiciona os jogadores selecionados à lista anti-spam."
L["WHO_RESULTS"]               = "Resultados do /who: %d jogadores encontrados"
L["SCAN_FOR_PLAYERS"]          = "Procurar jogadores"
L["NEXT_QUERY"]                = "Próxima consulta: %s"
L["NEXT_PLAYER_INVITE"]        = "Próximo jogador a convidar (fila: %d):"
L["PLAYERS_QUEUED"]            = "Jogadores na fila: %d"
L["NO_QUEUED_PLAYERS"]         = "Não há jogadores na fila."
L["WAIT"]                      = "Aguardar"
L["INVITE_FIRST_STEP"]         = "Primeiro, clique em \"Procurar jogadores\"."
L["ADD_TO_ANTISPAM"]           = "Foram adicionados %d jogadores à lista anti-spam."
L["ADD_TO_BLACKLIST"]          = "Foram adicionados %d jogadores à lista negra."
L["SKIP_PLAYER"]               = "Pular jogador"
L["SKIP"]                      = "Pular"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
Espero que este addon seja útil. Dediquei muito tempo e esforço
ao seu desenvolvimento. Se quiser doar, use o link abaixo.
Obrigado pelo seu apoio!]]
L["ABOUT_LINK_MESSAGE"] = "Para mais informações, visite estes links:"
L["COPY_LINK_MESSAGE"]  = "Os links podem ser copiados. Selecione e use CTRL+C."
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(<sub> caracteres por mensagem)"
L["LENGTH_INFO"] = "Pressupõe 12 caracteres ao usar PLAYERNAME"
L["MESSAGE_LENGTH"] = "Tamanho da mensagem"
L["GEN_GUILD_WIDE"]   = "Significa que afeta apenas sua guilda atual."
L["GEN_ACCOUNT_WIDE"] = "Significa que afeta todos os seus personagens da conta."
L["RELOAD_AFTER_CHANGE"] = "Você deve recarregar a interface (/rl) após fazer alterações."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - Cria um link clicável para sua guilda."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - Mostra o nome da sua guilda.
PLAYERNAME - Mostra o nome do jogador convidado.]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "Configurações do GR"
L["GEN_WHATS_NEW"]               = "Mostrar \"Novidades\""
L["GEN_WHATS_NEW_DESC"]          = "Mostra a janela de Novidades quando o Guild Recruiter é atualizado."
L["GEN_TOOLTIPS"]                = "Mostrar todas as dicas de ferramenta"
L["GEN_TOOLTIP_DESC"]            = "Mostrar todas as dicas de ferramenta no Guild Recruiter."
L["GEN_ADDON_MESSAGES"]          = "Mostrar mensagens do sistema"
L["GEN_ADDON_MESSAGES_DESC"]     = "Mostrar as mensagens do sistema do Guild Recruiter."
L["KEEP_ADDON_OPEN"]             = "Manter addon aberto"
L["KEEP_ADDON_OPEN_DESC"]        = [[
Mantém o addon aberto e ignora ESC e outras ações que poderiam fechá-lo.

OBS: Após alterar esta configuração, execute /rl.]]
L["GEN_MINIMAP"]                 = "Mostrar ícone do minimapa"
L["GEN_MINIMAP_DESC"]            = "Mostrar o ícone do Guild Recruiter no minimapa."
L["INVITE_SCAN_SETTINGS"]        = "Configurações de convite e varredura"
L["SEND_MESSAGE_WAIT_TIME"]      = "Atraso para enviar mensagens"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "Tempo, em segundos, antes de enviar mensagens em espera (0,1 a 1 segundo)."
L["AUTO_SYNC"]                   = "Habilitar sincronização automática"
L["AUTO_SYNC_DESC"]              = "Sincroniza automaticamente com membros da guilda ao conectar."
L["SHOW_WHISPERS"]               = "Mostrar sussurros no chat"
L["SHOW_WHISPERS_DESC"]          = [[
Mostra a mensagem enviada aos jogadores ao convidá-los.

OBS: Após alterar esta configuração, execute /rl.]]
L["GEN_CONTEXT"]                 = "Habilitar convite com clique direito pelo chat"
L["GEN_CONTEXT_DESC"]            = "Mostra o menu de contexto do Guild Recruiter ao clicar com o botão direito em um nome no chat."
L["COMPACT_SIZE"]                = "Tamanho compacto"
L["SCAN_WAIT_TIME"]              = "Tempo de espera da varredura (segundos)"
L["SCAN_WAIT_TIME_DESC"]         = [[
Tempo em segundos antes de procurar jogadores (2 a 10 segundos).

OBS: 5 ou 6 segundos são recomendados.]]
L["KEYBINDING_HEADER"]           = "Atalhos"
L["KEYBINDING_INVITE"]           = "Atalho de Convidar"
L["KEYBINDING_INVITE_DESC"]      = "Atalho para convidar um jogador para a guilda."
L["KEYBINDING_SCAN"]             = "Atalho de Escanear"
L["KEYBINDING_SCAN_DESC"]        = "Atalho para procurar jogadores que procuram guilda."
L["KEY_BINDING_NOTE"]            = "Observação: os atalhos não afetam as configurações de teclado do WoW."
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "Configurações de GM"
L["FORCE_OPTION"]                     = "Forçar não-GMs a usar"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "Habilitar verificação de convites bloqueados."
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "Tenta verificar se o jogador convidado bloqueou convites de guilda."
L["ENABLE_ANTI_SPAM_DESC"]            = "Habilita o recurso anti-spam para evitar spam."
L["ANTI_SPAM_DAYS"]                   = "Atraso para reenviar convite"
L["ANTI_SPAM_DAYS_DESC"]              = "Número de dias antes de convidar novamente um jogador."
L["GUILD_WELCOME_MSG"]                = "Mensagem de boas-vindas no chat da guilda"
L["GUILD_WELCOME_MSG_DESC"]           = "Mensagem enviada ao chat da guilda quando um jogador entra."
L["WHISPER_WELCOME_MSG"]              = "Mensagem de boas-vindas por sussurro"
L["WHISPER_WELCOME_MSG_DESC"]         = "Mensagem por sussurro enviada ao jogador quando entra na guilda."
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "Mensagens de GM"
L["PLAYER_SETTINGS_DESC"]       = "As mensagens em laranja vêm do GM."
L["INVITE_ACTIVE_MESSAGE"]      = "Mensagens de convite:"
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
Mensagens enviadas a recrutas em potencial.

OBS: Após uma sincronização, talvez seja necessário usar /rl para ver as alterações.]]
L["NEW_MESSAGE_DESC"]           = "Adicione uma descrição da mensagem à lista de convites."
L["INVITE_DESC"]                = "Descrição da mensagem de convite:"
L["INVITE_DESC_TOOLTIP"]        = "Uma descrição da mensagem de convite."
L["SYNC_MESSAGES"]              = "Sincronizar esta mensagem."
L["SYNC_MESSAGES_DESC"]         = "Sincroniza esta mensagem com a guilda."
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "Configurações de convite"
L["INVITE_MESSAGES"] = "Mensagens de convite"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "Remover entradas selecionadas da lista negra"
L["ADD_TO_BLACKLIST"]         = "Adicionar jogadores à lista negra."
L["BL_PRIVATE_REASON"]        = "Alternar motivo privado"
L["BL_PRIVATE_REASON_DESC"]   = "Alterna o motivo privado para a lista negra."
L["BL_PRIVATE_REASON_ERROR"]  = "Você não colocou ninguém na lista negra"
L["NO_REASON_GIVEN"]          = "Sem motivo informado"
L["ADDED_TO_BLACK_LIST"]      = "foi adicionado à lista negra pelo motivo %s."
L["BL_NAME_NOT_ADDED"]        = "não foi adicionado à lista negra."
L["IS_ON_BLACK_LIST"]         = "já está na lista negra."
L["BLACK_LIST_REASON_INPUT"]  = "Insira um motivo para colocar %s na lista negra."
L["BLACKLIST_NAME_PROMPT"] = [[
Insira o nome do jogador
que deseja colocar na lista negra.

Para outro reino, adicione - e o nome do reino.
(NomeDoJogador-NomeDoReino)
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "Zonas inválidas"
L["ZONE_NOT_FOUND"]      = "Não foi possível encontrar a zona"
L["ZONE_INSTRUCTIONS"]   = "O nome da zona deve corresponder EXATAMENTE ao nome no jogo."
L["ZONE_ID"]             = "ID da zona (ID numérico)"
L["ZONE_NAME"]           = "Nome da zona:"
L["ZONE_INVALID_REASON"] = "Motivo de invalidez:"
L["ZONE_ID_DESC"] = [[
O ID da zona inválida.
Lista de instâncias:
https://wowpedia.fandom.com/wiki/InstanceID
Melhores IDs de zonas do mundo que encontrei:
https://wowpedia.fandom.com/wiki/UiMapID
Se encontrar uma zona que deva ser adicionada, avise-me.]]
L["ZONE_NOTE"]           = "Zonas com |cFF00FF00*|r são as únicas editáveis."
L["ZONE_LIST_NAME"]      = "O scanner ignorará as seguintes zonas:"
--#endregion

--#region Analytics
L["ANALYTICS"]                     = "Estatísticas"
L["ANALYTICS_DESC"]                = "Verifique suas estatísticas ao convidar jogadores para a guilda."
L["ANALYTICS_BLACKLISTED"]         = "Jogadores que você colocou na lista negra"
L["ANALYTICS_SCANNED"]             = "Jogadores escaneados no total"
L["ANALYTICS_INVITED"]             = "Jogadores convidados para a guilda"
L["ANALYTICS_DECLINED"]            = "Jogadores que recusaram o convite"
L["ANALYTICS_ACCEPTED"]            = "Jogadores que aceitaram o convite"
L["ANALYTICS_NO_GUILD"]            = "Jogadores sem guilda encontrada"
L["ANALYTICS_STATS_START"]         = "Estatísticas desde"
L["ANALYTICS_SESSION"]             = "Sessão"
L["ANALYTICS_SESSION_SCANNED"]     = "Escaneados"
L["ANALYTICS_SESSION_BLACKLISTED"] = "Na lista negra"
L["ANALYTICS_SESSION_INVITED"]     = "Convidados"
L["ANALYTICS_SESSION_DECLINED"]    = "Convite recusado"
L["ANALYTICS_SESSION_ACCEPTED"]    = "Convite aceito"
L["ANALYTICS_SESSION_WAITING"]     = "Aguardando"
L["ANALYTICS_SESSION_TIMED_OUT"]   = "Convite expirado"
L["ANALYTICS_SESSION_NO_GUILD"]    = "Potenciais encontrados"
L["ANALYTICS_SESSION_STARTED"]     = "Sessão iniciada"
L["LAST_SCAN"]                     = "Último jogador escaneado"

L["GUILD_ANALYTICS"]   = "Estatísticas da guilda"
L["PROFILE_ANALYTICS"] = "Estatísticas do personagem"
L["SESSION_ANALYTICS"] = "Estatísticas da sessão"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "A sincronização já está em andamento"
L["SYNC_FAIL_TIMER"]               = "A sincronização expirou, tente novamente."
-- Server
L["AUTO_SYNC_STARTED"]             = "Você iniciou uma sincronização automática com sua guilda."
L["MANUAL_SYNC_STARTED"]           = "Você iniciou uma sincronização com sua guilda."
L["SYNC_CLIENTS_FOUND"]            = "Foram encontrados %d clientes para sincronizar."
-- Client
L["SYNC_CLIENT_STARTED"]           = "solicitou uma sincronização do Guild Recruiter."
-- Either
L["SYNC_SETTINGS_FAILED"]          = "Falha ao preparar as configurações para enviar."

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "Não foram recebidos dados dos clientes."
L["REQUEST_WAIT_TIMEOUT"]          = "Não foi recebida resposta do servidor."
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "Nenhum cliente encontrado para sincronizar."

-- Sync Messages
L["AUTO_SYNC"]     = "Sincronização automática"
L["MANUAL_SYNC"]   = "Sincronização manual"
L["CLIENT_SYNC"]   = "Sincronização do cliente"
L["SYNC_FINISHED"] = "foi concluída."
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "As configurações foram atualizadas."
L["MESSAGE_LIST_CHANGED"]  = "A lista de mensagens foi atualizada."
L["BLACKLIST_CHANGED"]     = "A lista negra foi atualizada com %d entradas."
L["ANTISPAM_CHANGED"]      = "A lista anti-spam foi atualizada com %d entradas."