local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ruRU")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "Игрок отклонил приглашение в гильдию."
L["PLAYER_ALREADY_IN_GUILD"]         = "Этот игрок уже состоит в гильдии."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "Этот игрок уже состоит в вашей гильдии."
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "Этот игрок уже был приглашен."
L["PLAYER_NOT_FOUND"]                = "Игрок не найден."
L["PLAYER_NOT_PLAYING"]              = "Этот игрок сейчас не играет в World of Warcraft."
L["PLAYER_IGNORING_YOU"]             = "Этот игрок игнорирует вас."
L["PLAYER_JOINED_GUILD"]             = "Игрок вступил в гильдию."
L["PLAYER_NOT_ONLINE"]               = "Игрок не в сети."
L["PLAYER_IN_GUILD"]                 = "Игрок состоит в гильдии."

--#region General
L["INVITE"]    = "Пригласить"
L["SCAN"]      = "Сканировать"
L["ABOUT"]     = "О модуле"
L["CLOSE"]     = "Закрыть"
L["ENABLE"]    = "Включить"
L["ENABLED"]   = "Включено"
L["DISABLE"]   = "Отключить"
L["DISABLED"]  = "Отключено"
L["REMOVE"]    = "Удалить"
L["HELP"]      = "Справка"
L["CONFIG"]    = "Настройки"
--#endregion

--#region Button Text
L["CANCEL"] = "Отмена"
L["DELETE"] = "Удалить"
L["SAVE"]   = "Сохранить"
L["NEW"]    = "Новый"
L["YES"]    = "Да"
L["NO"]     = "Нет"
L["OK"]     = "ОК"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[Это версия VER аддона Guild Recruiter.
Сообщайте о проблемах на нашем сервере Discord.]]
L["AUTO_LOCKED"] = "Перемещение окна теперь заблокировано."
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "Антиспам"
L["BLACKLIST"]     = "Черный список"
L["SETTINGS"]      = "Настройки"
L["PREVIEW_TITLE"] = "Предпросмотр выбранного сообщения"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "Нет названия гильдии, перезагрузите интерфейс."
L["BL_NO_ONE_ADDED"]             = "Никто не был добавлен в черный список."
L["GUILD_LINK_NOT_FOUND"]        = "Ссылка на гильдию не найдена. Перезагрузите интерфейс."
L["GUILD_LINK_NOT_FOUND_LINE1"]  = "Попробуйте /rl или повторный вход (может потребоваться несколько попыток)"
L["GM_GUILD_LINK_NOT_FOUND"]     = "Создайте объявление о наборе в Поиске гильдий и затем выполните /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "Попробуйте синхронизироваться с гильдией, чтобы получить ссылку."
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "Приглашение в гильдию (без сообщений)"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "Приглашение в гильдию (приветственные сообщения)"
L["BLACKLIST_PLAYER"]             = "Добавить игрока в черный список"
L["KICK_PLAYER_FROM_GUILD"]       = "Исключить из гильдии (добавить в черный список)"
L["KICK_PLAYER_CONFIRMATION"]     = "Вы уверены, что хотите исключить %s из гильдии?"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "Добро пожаловать, PLAYERNAME, в GUILDNAME!"
L["DATABASE_RESET"] = [[
База данных была сброшена.
В связи с интеграцией Classic и Cata все данные сброшены.
Приносим извинения за неудобства.
|cFFFFFFFFПерезагрузите интерфейс (/rl или /reload).|r]]
L["SLASH_COMMANDS"] = [[
Команды Guild Recruiter:
 /rl — перезагрузить интерфейс WoW (как /reload).
 /gr help — показать это сообщение помощи.
 /gr config — открыть окно настроек.
 /gr blacklist <имя игрока> — добавить игрока в черный список.]]
L["MINIMAP_TOOLTIP"] = [[
ЛКМ: открыть Guild Recruiter
Shift+ЛКМ: открыть сканер
ПКМ: открыть настройки
%AntiSpam в списке приглашений.
%BlackList в списке блокировок.]]
L["NO_LONGER_GUILD_LEADER"] = "больше не является лидером гильдии."
L["NO_ANTI_SPAM"]           = "Антиспам не включен. Включите его в настройках."
L["CANNOT_INVITE"]          = "У вас нет прав приглашать новых членов."
L["NOT_IN_GUILD"]           = "Guild Recruiter отключен, так как вы не состоите в гильдии."
L["NOT_IN_GUILD_LINE1"]     = "Если вступите в гильдию, выполните /rl для перезагрузки."
L["FGI_LOADED"]             = "*ПРЕДУПРЕЖДЕНИЕ* FGI загружен. Отключите его для работы Guild Recruiter."
--#endregion

--#region Base Screen
L["BACK"]                   = "Назад"
L["BACK_TOOLTIP"]           = "Вернуться на предыдущий экран."
L["LOCK_TOOLTIP"]           = "Переключить перемещение окна"
L["RESET_FILTER"]           = "Сбросить фильтр"
L["RESET_FILTER_TOOLTIP"]   = "Сбрасывает фильтр сканера для нового начала."
L["COMPACT_MODE"]           = "Компактный режим"
L["COMPACT_MODE_TOOLTIP"]   = [[Переключить компактный режим.
Размер компактного режима настраивается в параметрах.]]
L["ABOUT_TOOLTIP"]          = "Дискорд, поддержка и как помочь проекту."
L["SETTINGS_TOOLTIP"]       = "Изменить параметры Guild Recruiter."
L["MANUAL_SYNC"]            = "Ручная синхронизация"
L["MANUAL_SYNC_TOOLTIP"]    = "Вручную синхронизировать списки с членами гильдии."
L["VIEW_ANALYTICS"]         = "Смотреть статистику"
L["VIEW_ANALYTICS_TOOLTIP"] = "Показать вашу статистику приглашений в гильдию."
L["BLACKLIST_TOOLTIP"]      = "Добавить игроков в черный список."
L["CUSTOM_FILTERS"]         = "Пользовательские фильтры"
L["CUSTOM_FILTERS_TOOLTIP"] = "Добавить пользовательские фильтры в сканер."
L["CUSTOM_FILTERS_DESC"] = [[
Пользовательские фильтры позволяют отбирать игроков по заданным критериям.
Например, по классу или расе.]]
L["NEW_FILTER_DESC"]       = "Создать новый фильтр для сканера."
L["FILTER_SAVE_LIST"]      = "Сохранить список фильтров"
L["FILTER_SAVE_LIST_DESC"] = "Выберите фильтр для изменения."
L["FILTER_NAME"]           = "Введите имя фильтра:"
L["FILTER_NAME_EXISTS"]    = "Такое имя фильтра уже существует."
L["FILTER_CLASS"]          = "Выберите класс или комбинацию классов:"
L["SELECT_ALL_CLASSES"]    = "Выбрать все классы"
L["CLEAR_ALL_CLASSES"]     = "Снять выбор со всех классов"
L["FILTER_SAVED"]          = "Фильтр успешно сохранен."
L["FILTER_DELETED"]        = "Фильтр успешно удален."
L["FILTER_SAVE_ERROR"]     = "Выберите минимум 1 класс и/или расу."
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "Только сообщение"
L["GUILD_INVITE_ONLY"]               = "Только приглашение в гильдию"
L["GUILD_INVITE_AND_MESSAGE"]        = "Приглашение в гильдию и сообщение"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "Только сообщение, если приглашение отклонено"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "В ожидании"
L["GUILD_INVITE_SENT"]      = "Отправлено приглашение в гильдию:"
L["INVITE_MESSAGE_SENT"]    = "Отправлено пригласительное сообщение:"
L["INVITE_MESSAGE_QUEUED"]  = "Сообщение о приглашении поставлено в очередь:"
L["GUILD_INVITE_BLOCKED"]   = "Сообщение для %s пропущено, так как приглашения в гильдию заблокированы."
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "Выберите фильтр"
L["MIN_LEVEL"]                   = "Минимальный уровень"
L["MAX_LEVEL"]                   = "Максимальный уровень"
L["MAX_LEVEL_ERROR"]             = "Введите число от 1 до "
L["LEVELS_FIXED"]                = "Уровни исправлены"
L["LEVELS_TOO_CLOSE"]            = "Внимание: держите диапазон в пределах 5 уровней."
L["SELECT_INVITE_TYPE"]          = "Выберите тип приглашения"
L["SELECT_INVITE_MESSAGE"]       = "Выберите сообщение приглашения"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "Создайте сообщение в настройках"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "Прогресс фильтра"
L["PLAYERS_FOUND"]             = "Найдено игроков"
L["SEND_MESSAGE"]              = "Отправить сообщение"
L["SEND_INVITE"]               = "Отправить приглашение"
L["SEND_INVITE_AND_MESSAGE"]   = "Отправить приглашение и сообщение"
L["BLACKLIST_TITLE"]           = "Добавить выбранных игроков в черный список"
L["BLACKLIST_SCANNER_TOOLTIP"] = "Добавляет выбранных игроков в черный список."
L["ANTISPAM_TITLE"]            = "Добавить выбранных игроков в антиспам"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "Добавляет выбранных игроков в список антиспама."
L["WHO_RESULTS"]               = "Результаты /who: найдено игроков — %d"
L["SCAN_FOR_PLAYERS"]          = "Искать игроков"
L["NEXT_QUERY"]                = "Следующий запрос: %s"
L["NEXT_PLAYER_INVITE"]        = "Следующий игрок для приглашения (очередь: %d):"
L["PLAYERS_QUEUED"]            = "Игроков в очереди: %d"
L["NO_QUEUED_PLAYERS"]         = "В очереди нет игроков."
L["WAIT"]                      = "Ожидание"
L["INVITE_FIRST_STEP"]         = "Сначала нажмите «Искать игроков»."
L["ADD_TO_ANTISPAM"]           = "В список антиспама добавлено игроков: %d."
L["ADD_TO_BLACKLIST"]          = "В черный список добавлено игроков: %d."
L["SKIP_PLAYER"]               = "Пропустить игрока"
L["SKIP"]                      = "Пропустить"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
Надеюсь, этот аддон вам полезен. На его разработку ушло много времени и сил.
Если хотите поддержать проект, используйте ссылку ниже.
Спасибо за поддержку!]]
L["ABOUT_LINK_MESSAGE"] = "Подробнее — по ссылкам:"
L["COPY_LINK_MESSAGE"]  = "Ссылки можно копировать. Выделите и нажмите CTRL+C."
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(<sub> символов на сообщение)"
L["LENGTH_INFO"] = "Предполагается 12 символов при использовании PLAYERNAME"
L["MESSAGE_LENGTH"] = "Длина сообщения"
L["GEN_GUILD_WIDE"]   = "Применяется только к вашей текущей гильдии."
L["GEN_ACCOUNT_WIDE"] = "Применяется ко всем персонажам аккаунта."
L["RELOAD_AFTER_CHANGE"] = "После изменений необходимо перезагрузить интерфейс (/rl)."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK — создает кликабельную ссылку на вашу гильдию."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME — показывает название вашей гильдии.
PLAYERNAME — показывает имя игрока, которого вы приглашаете.]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "Настройки GR"
L["GEN_WHATS_NEW"]               = "Показывать «Что нового»"
L["GEN_WHATS_NEW_DESC"]          = "Показывать окно «Что нового» при обновлении Guild Recruiter."
L["GEN_TOOLTIPS"]                = "Показывать все подсказки"
L["GEN_TOOLTIP_DESC"]            = "Показывать все подсказки в Guild Recruiter."
L["GEN_ADDON_MESSAGES"]          = "Показывать системные сообщения"
L["GEN_ADDON_MESSAGES_DESC"]     = "Показывать системные сообщения Guild Recruiter."
L["KEEP_ADDON_OPEN"]             = "Держать аддон открытым"
L["KEEP_ADDON_OPEN_DESC"]        = [[
Сохраняет окно открытым и игнорирует ESC и другие действия, которые могут его закрыть.

Примечание: после изменения параметра выполните /rl.]]
L["GEN_MINIMAP"]                 = "Показывать иконку на миникарте"
L["GEN_MINIMAP_DESC"]            = "Показывать иконку Guild Recruiter на миникарте."
L["INVITE_SCAN_SETTINGS"]        = "Настройки приглашений и сканирования"
L["SEND_MESSAGE_WAIT_TIME"]      = "Задержка отправки сообщений"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "Время в секундах до отправки отложенных сообщений (0.1–1 сек)."
L["AUTO_SYNC"]                   = "Включить авто-синхронизацию"
L["AUTO_SYNC_DESC"]              = "Автоматически синхронизироваться с членами гильдии при входе."
L["SHOW_WHISPERS"]               = "Показывать шепот в чате"
L["SHOW_WHISPERS_DESC"]          = [[
Показывать сообщение, отправляемое игрокам при их приглашении.

Примечание: после изменения параметра выполните /rl.]]
L["GEN_CONTEXT"]                 = "Включить приглашение ПКМ из чата"
L["GEN_CONTEXT_DESC"]            = "Показывать контекстное меню Guild Recruiter по ПКМ на имени в чате."
L["COMPACT_SIZE"]                = "Размер компактного режима"
L["SCAN_WAIT_TIME"]              = "Задержка сканирования (сек)"
L["SCAN_WAIT_TIME_DESC"]         = [[
Время ожидания перед поиском игроков (2–10 секунд).

Примечание: рекомендуется 5–6 секунд.]]
L["KEYBINDING_HEADER"]           = "Горячие клавиши"
L["KEYBINDING_INVITE"]           = "Клавиша приглашения"
L["KEYBINDING_INVITE_DESC"]      = "Клавиша для приглашения игрока в гильдию."
L["KEYBINDING_SCAN"]             = "Клавиша сканирования"
L["KEYBINDING_SCAN_DESC"]        = "Клавиша для поиска игроков, ищущих гильдию."
L["KEY_BINDING_NOTE"]            = "Примечание: эти клавиши не влияют на настройки клавиатуры WoW."
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "Настройки лидера гильдии"
L["FORCE_OPTION"]                     = "Обязать остальных использовать"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "Проверять блокировку приглашений."
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "Пробует определить, заблокированы ли приглашения в гильдию у игрока."
L["ENABLE_ANTI_SPAM_DESC"]            = "Включает антиспам для предотвращения спама."
L["ANTI_SPAM_DAYS"]                   = "Задержка повторного приглашения"
L["ANTI_SPAM_DAYS_DESC"]              = "Количество дней до повторного приглашения игрока."
L["GUILD_WELCOME_MSG"]                = "Приветствие в чате гильдии"
L["GUILD_WELCOME_MSG_DESC"]           = "Сообщение, отправляемое в чат гильдии при вступлении игрока."
L["WHISPER_WELCOME_MSG"]              = "Приветствие шепотом"
L["WHISPER_WELCOME_MSG_DESC"]         = "Личное сообщение игроку при его вступлении в гильдию."
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "Сообщения лидера"
L["PLAYER_SETTINGS_DESC"]       = "Оранжевые сообщения созданы лидером гильдии."
L["INVITE_ACTIVE_MESSAGE"]      = "Пригласительные сообщения:"
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
Сообщения, отправляемые потенциальным рекрутам.

Примечание: после синхронизации может потребоваться /rl для отображения изменений.]]
L["NEW_MESSAGE_DESC"]           = "Добавьте описание сообщения в список приглашений."
L["INVITE_DESC"]                = "Описание пригласительного сообщения:"
L["INVITE_DESC_TOOLTIP"]        = "Описание для пригласительного сообщения."
L["SYNC_MESSAGES"]              = "Синхронизировать это сообщение."
L["SYNC_MESSAGES_DESC"]         = "Синхронизировать это сообщение с гильдией."
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "Настройки приглашений"
L["INVITE_MESSAGES"] = "Пригласительные сообщения"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "Удалить выбранные записи из черного списка"
L["ADD_TO_BLACKLIST"]         = "Добавить игроков в черный список."
L["BL_PRIVATE_REASON"]        = "Переключить личную причину"
L["BL_PRIVATE_REASON_DESC"]   = "Переключает личную причину для черного списка."
L["BL_PRIVATE_REASON_ERROR"]  = "Вы никого не добавили в черный список"
L["NO_REASON_GIVEN"]          = "Причина не указана"
L["ADDED_TO_BLACK_LIST"]      = "добавлен(а) в черный список по причине: %s."
L["BL_NAME_NOT_ADDED"]        = "не был(а) добавлен(а) в черный список."
L["IS_ON_BLACK_LIST"]         = "уже в черном списке."
L["BLACK_LIST_REASON_INPUT"]  = "Укажите причину добавления %s в черный список."
L["BLACKLIST_NAME_PROMPT"] = [[
Введите имя игрока,
которого хотите добавить в черный список.

Для другого мира добавьте «-» и имя мира.
(ИмяИгрока-ИмяМира)
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "Недопустимые зоны"
L["ZONE_NOT_FOUND"]      = "Не удалось найти зону"
L["ZONE_INSTRUCTIONS"]   = "Название зоны должно ТОЧНО соответствовать игровому названию."
L["ZONE_ID"]             = "ID зоны (числовой ID)"
L["ZONE_NAME"]           = "Название зоны:"
L["ZONE_INVALID_REASON"] = "Причина недопустимости:"
L["ZONE_ID_DESC"] = [[
ID зоны для недопустимой зоны.
Список инстансов:
https://wowpedia.fandom.com/wiki/InstanceID
Лучшие ID зон мира, что я нашел:
https://wowpedia.fandom.com/wiki/UiMapID
Если найдете зону для добавления — сообщите.]]
L["ZONE_NOTE"]           = "Редактировать можно только зоны, отмеченные |cFF00FF00*|r."
L["ZONE_LIST_NAME"]      = "Сканер будет игнорировать следующие зоны:"
--#endregion

--#region Analytics
L["ANALYTICS"]                     = "Статистика"
L["ANALYTICS_DESC"]                = "Просматривайте статистику приглашений в гильдию."
L["ANALYTICS_BLACKLISTED"]         = "Игроки, добавленные в черный список"
L["ANALYTICS_SCANNED"]             = "Всего отсканировано игроков"
L["ANALYTICS_INVITED"]             = "Игроки, приглашенные в гильдию"
L["ANALYTICS_DECLINED"]            = "Игроки, отклонившие приглашение"
L["ANALYTICS_ACCEPTED"]            = "Игроки, принявшие приглашение"
L["ANALYTICS_NO_GUILD"]            = "Игроки без гильдии"
L["ANALYTICS_STATS_START"]         = "Статистика с"
L["ANALYTICS_SESSION"]             = "Сессия"
L["ANALYTICS_SESSION_SCANNED"]     = "Сканировано"
L["ANALYTICS_SESSION_BLACKLISTED"] = "В черный список"
L["ANALYTICS_SESSION_INVITED"]     = "Приглашено"
L["ANALYTICS_SESSION_DECLINED"]    = "Отклонено"
L["ANALYTICS_SESSION_ACCEPTED"]    = "Принято"
L["ANALYTICS_SESSION_WAITING"]     = "Ожидание"
L["ANALYTICS_SESSION_TIMED_OUT"]   = "Истекло время"
L["ANALYTICS_SESSION_NO_GUILD"]    = "Найдено кандидатов"
L["ANALYTICS_SESSION_STARTED"]     = "Сессия начата"
L["LAST_SCAN"]                     = "Последний отсканированный игрок"

L["GUILD_ANALYTICS"]   = "Статистика гильдии"
L["PROFILE_ANALYTICS"] = "Статистика персонажа"
L["SESSION_ANALYTICS"] = "Статистика сессии"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "Синхронизация уже выполняется"
L["SYNC_FAIL_TIMER"]               = "Синхронизация истекла, попробуйте еще раз."
-- Server
L["AUTO_SYNC_STARTED"]             = "Вы начали автоматическую синхронизацию с гильдией."
L["MANUAL_SYNC_STARTED"]           = "Вы начали синхронизацию с гильдией."
L["SYNC_CLIENTS_FOUND"]            = "Найдено клиентов для синхронизации: %d."
-- Client
L["SYNC_CLIENT_STARTED"]           = "запросил(а) синхронизацию Guild Recruiter."
-- Either
L["SYNC_SETTINGS_FAILED"]          = "Не удалось подготовить настройки для отправки."

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "Данные от клиентов не получены."
L["REQUEST_WAIT_TIMEOUT"]          = "Ответ от сервера не получен."
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "Клиенты для синхронизации не найдены."

-- Sync Messages
L["AUTO_SYNC"]     = "Автосинхронизация"
L["MANUAL_SYNC"]   = "Ручная синхронизация"
L["CLIENT_SYNC"]   = "Клиентская синхронизация"
L["SYNC_FINISHED"] = "завершена."
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "Настройки обновлены."
L["MESSAGE_LIST_CHANGED"]  = "Список сообщений обновлен."
L["BLACKLIST_CHANGED"]     = "Черный список обновлен, записей: %d."
L["ANTISPAM_CHANGED"]      = "Список антиспама обновлен, записей: %d."