-- Translator ZamestoTV
local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ruRU")
if not L then return end

--#region Перевод системных сообщений WoW
--! ДОЛЖНО БЫТЬ В НИЖНЕМ РЕГИСТРЕ!
L["PLAYER_NOT_ONLINE"] = "не в сети"
L["PLAYER_NOT_PLAYING"] = "в настоящее время играет"
L["PLAYER_NOT_FOUND"] = "игрок с именем не найден"
L["PLAYER_IN_GUILD"] = "уже приглашен в гильдию"
L["PLAYER_ALREADY_IN_GUILD"] = "уже состоит в гильдии"
L["PLAYER_JOINED_GUILD"] = "вступил в гильдию"
L["PLAYER_DECLINED_INVITE"] = "отклонил ваше приглашение в гильдию"
--#endregion

--#region Общие
L["INVITE"] = "Пригласить"
L["SCAN"] = "Сканировать"
L["ABOUT"] = "О аддоне"
L["CLOSE"] = "Закрыть"
L["ENABLE"] = "Включить"
L["ENABLED"] = "Включено"
L["DISABLE"] = "Отключить"
L["DISABLED"] = "Отключено"
L["REMOVE"] = "Удалить"
L["HELP"] = "Помощь"
L['CONFIG'] = 'Настройки'
--#endregion

--#region Текст кнопок
L['SCAN'] = 'Сканировать'
L["CANCEL"] = "Отмена"
L["DELETE"] = "Удалить"
L["SAVE"] = "Сохранить"
L["NEW"] = "Новый"
L["YES"] = "Да"
L["NO"] = "Нет"
L["OK"] = "ОК"
--#endregion

--#region Системные сообщения
L["TITLE"] = "Guild Recruiter"
L['BETA_INFORMATION'] = [[Это BETA-версия Guild Recruiter.
Пожалуйста, сообщайте о любых проблемах на нашем Discord-сервере.]]
L['AUTO_LOCKED'] = 'Перемещение экрана теперь заблокировано.'
--#endregion

--#region Часто используемые строки
L['ANTI_SPAM'] = 'Анти-спам'
L['BLACKLIST'] = 'Черный список'
L['SETTINGS'] = 'Настройки'
L['PREVIEW_TITLE'] = 'Предварительный просмотр выбранного сообщения'
--#endregion

--#region Общие сообщения об ошибках
L['NO_GUILD_NAME'] = 'Нет названия гильдии, пожалуйста, перезагрузите интерфейс.'
L['BL_NO_ONE_ADDED'] = 'Никто не был добавлен в черный список.'
L['GUILD_LINK_NOT_FOUND'] = 'Ссылка на гильдию не найдена. Пожалуйста, перезагрузите интерфейс.'
L["GUILD_LINK_NOT_FOUND_LINE1"] = "Попробуйте /rl или перезайдите в игру (может потребоваться несколько попыток)"
L["GM_GUILD_LINK_NOT_FOUND"] = "Попробуйте создать набор в поиске гильдий, затем /rl."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "Попробуйте синхронизироваться с гильдией, чтобы получить ссылку на гильдию."
--#endregion

--#region Контекстное меню
L['GUILD_INVITE_NO_MESSAGE'] = 'Приглашение в гильдию (без сообщений)'
L['GUILD_INVITE_WELCOME_MESSAGE'] = 'Приглашение в гильдию (с приветственным сообщением)'
L['BLACKLIST_PLAYER'] = 'Добавить игрока в черный список'
L['KICK_PLAYER_FROM_GUILD'] = 'Исключить игрока из гильдии (добавить в черный список)'
L['KICK_PLAYER_CONFIRMATION'] = 'Вы уверены, что хотите исключить %s из гильдии?'
--#endregion

--#region Основное
L['RECRUITER'] = 'рекрутер'
L['DEFAULT_GUILD_WELCOME'] = 'Добро пожаловать, PLAYERNAME, в гильдию GUILDNAME!'
L['DATABASE_RESET'] = [[
База данных была сброшена.
Из-за интеграции классической версии и Cataclysm все данные были сброшены.
Приносим извинения за неудобства.
|cFFFFFFFFПожалуйста, перезагрузите интерфейс (/rl или /reload).|r]]
L['SLASH_COMMANDS'] = [[
Команды Guild Recruiter:
/rl перезагрузит интерфейс WoW (как /reload).
/gr help - Показывает это сообщение справки.
/gr config - Открывает окно конфигурации.
/gr blacklist <имя игрока> - Добавит игрока в черный список.]]
L['MINIMAP_TOOLTIP'] = [[
ЛКМ: Открыть Guild Recruiter
Shift+ЛКМ: Открыть сканер
ПКМ: Открыть настройки
%AntiSpam в списке приглашенных.
%BlackList в черном списке.]]
L["NO_LONGER_GUILD_LEADER"] = "больше не является лидером гильдии."
L["NO_ANTI_SPAM"] = "Анти-спам не включен. Пожалуйста, включите его в настройках."
L["CANNOT_INVITE"] = "Guild Recruiter отключен, так как у вас нет разрешения на приглашение."
L["NOT_IN_GUILD"] = "Guild Recruiter отключен, так как вы не состоите в гильдии."
L["NOT_IN_GUILD_LINE1"] = "Если вы вступите в гильдию, введите /rl для перезагрузки."
L['FGI_LOADED'] = '*ВНИМАНИЕ* FGI загружен. Пожалуйста, отключите его для использования Guild Recruiter.'
--#endregion

--#region Основной экран
L['BACK'] = 'Назад'
L['BACK_TOOLTIP'] = 'Вернуться к предыдущему экрану.'
L['LOCK_TOOLTIP'] = 'Переключить перемещение окна'
L['RESET_FILTER'] = 'Сбросить фильтр'
L['RESET_FILTER_TOOLTIP'] = 'Сбросить фильтр сканера, чтобы начать заново.'
L['COMPACT_MODE'] = 'Компактный режим'
L['COMPACT_MODE_TOOLTIP'] = [[Переключить компактный режим.
Измените размер компактного режима в настройках.]]
L['ABOUT_TOOLTIP'] = 'Информация о Discord, поддержке и возможности внести вклад, если хотите.'
L['SETTINGS_TOOLTIP'] = 'Изменить настройки Guild Recruiter.'
L['MANUAL_SYNC'] = 'Ручная синхронизация'
L['MANUAL_SYNC_TOOLTIP'] = 'Вручную синхронизировать ваши списки с другими участниками гильдии.'
L['VIEW_ANALYTICS'] = 'Просмотр аналитики'
L['VIEW_ANALYTICS_TOOLTIP'] = 'Показывает статистику по приглашению игроков в гильдию.'
L['BLACKLIST_TOOLTIP'] = 'Добавить игроков в черный список.'
L['CUSTOM_FILTERS'] = 'Пользовательские фильтры'
L['CUSTOM_FILTERS_TOOLTIP'] = 'Добавить пользовательские фильтры в сканер.'
--#endregion

--#region Форматы приглашений
L['MESSAGE_ONLY'] = 'Только сообщение'
L['GUILD_INVITE_ONLY'] = 'Только приглашение в гильдию'
L['GUILD_INVITE_AND_MESSAGE'] = 'Приглашение в гильдию и сообщение'
L['MESSAGE_ONLY_IF_INVITE_DECLINED'] = 'Сообщение только при отклонении приглашения'
--#endregion

--#region Код приглашения
L['GUILD_INVITE_SENT'] = 'Приглашение в гильдию отправлено'
L['INVITE_MESSAGE_SENT'] = 'Сообщение с приглашением отправлено'
--#endregion

--#region Главный экран
L['SELECT_A_FILTER'] = 'Выберите фильтр'
L['MIN_LEVEL'] = 'Мин. уровень'
L['MAX_LEVEL'] = 'Макс. уровень'
L['MAX_LEVEL_ERROR'] =  'Пожалуйста, введите число от 1 до '
L['SELECT_INVITE_TYPE'] = 'Выберите тип приглашения'
L['SELECT_INVITE_MESSAGE'] = 'Выберите сообщение с приглашением'
--#endregion

--#region Экран сканера
L['FILTER_PROGRESS'] = 'Прогресс фильтра'
L['PLAYERS_FOUND'] = 'Найдено игроков'
L['SEND_MESSAGE'] = 'Отправить сообщение'
L['SEND_INVITE'] = 'Отправить приглашение'
L['SEND_INVITE_AND_MESSAGE'] = 'Отправить приглашение и сообщение'
L['BLACKLIST_TITLE'] = 'Добавить выбранного игрока(ов) в черный список'
L['BLACKLIST_SCANNER_TOOLTIP'] = 'Добавить выбранных игроков в черный список.'
L['ANTISPAM_TITLE'] = 'Добавить выбранного игрока(ов) в список анти-спама'
L['ANTISPAM_SCANNER_TOOLTIP'] = 'Добавит выбранных игроков в список анти-спама.'
L['WHO_RESULTS'] = 'Результаты поиска: найдено %d игроков'
L['SCAN_FOR_PLAYERS'] = 'Поиск игроков'
L['NEXT_QUERY'] = 'Следующий запрос: %s'
L['NEXT_PLAYER_INVITE'] = 'Следующий игрок для приглашения (в очереди: %d):'
L['PLAYERS_QUEUED'] = 'Игроков в очереди: %d'
L['NO_QUEUED_PLAYERS'] = 'Нет игроков в очереди.'
L['WAIT'] = 'Подождите'
L['INVITE_FIRST_STEP'] = 'Сначала нажмите кнопку "Поиск игроков".'
L['ADD_TO_ANTISPAM'] = 'Добавлено %d игроков в список анти-спама.'
L['ADD_TO_BLACKLIST'] = 'Добавлено %d игроков в черный список.'
L['SKIP_PLAYER'] = 'Пропустить игрока'
L['SKIP'] = 'Пропустить'
--endregion

--#region Экран "О аддоне"
-- * Сообщение о пожертвованиях
L['DONATION_MESSAGE'] = [[
Надеюсь, вы найдете этот аддон полезным. Я вложил много времени и усилий в
создание этого аддона. Если вы хотите сделать пожертвование, пожалуйста, используйте ссылку ниже.
Спасибо за вашу поддержку!]]
L['ABOUT_LINK_MESSAGE'] = 'Для получения дополнительной информации посетите следующие ссылки:'
L['COPY_LINK_MESSAGE'] = 'Ссылки можно копировать. Выделите ссылку и скопируйте (CTRL+C).'
--#endregion

--#region Настройки Guild Recruiter
L['MAX_CHARS'] = '(<sub> символов на сообщение)'
L['LENGTH_INFO'] = 'Предполагается 12 символов при использовании PLAYERNAME'
L['MESSAGE_LENGTH'] = 'Длина сообщения'
L['GEN_GUILD_WIDE'] = 'Указывает, что изменения коснутся только вашей текущей гильдии.'
L['GEN_ACCOUNT_WIDE'] = 'Указывает, что изменения коснутся всех ваших персонажей на аккаунте.'
L['RELOAD_AFTER_CHANGE'] = 'Вы должны перезагрузить интерфейс (/rl) после внесения изменений.'
L['MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC'] = '' -- Оставить пустым для сейчас
L['MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1'] = 'GUILDLINK - Создаст кликабельную ссылку на вашу гильдию.'
L['MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2'] = [[
GUILDNAME - Покажет название вашей гильдии.
PLAYERNAME - Покажет имя приглашенного игрока.]]
L['GUILDLINK'] = 'GUILDLINK'
L['GUILDNAME'] = 'GUILDNAME'
L['PLAYERNAME'] = 'PLAYERNAME'
--#region Общие настройки
L['GR_SETTINGS'] = 'Настройки GR'
L['GEN_WHATS_NEW'] = 'Показывать "Что нового?"'
L['GEN_WHATS_NEW_DESC'] = 'Показывать окно "Что нового?" при обновлении Guild Recruiter.'
L['GEN_TOOLTIPS'] = 'Показывать все подсказки'
L['GEN_TOOLTIP_DESC'] = 'Показывать все подсказки в аддоне Guild Recruiter'
L['GEN_ADDON_MESSAGES'] = 'Показывать системные сообщения'
L['GEN_ADDON_MESSAGES_DESC'] = 'Показывать системные сообщения от Guild Recruiter.'
L['KEEP_ADDON_OPEN'] = 'Держать аддон открытым'
L['KEEP_ADDON_OPEN_DESC'] = [[
Держать аддон открытым и игнорировать ESC и другие действия, которые могут его закрыть.

ПРИМЕЧАНИЕ: Вам нужно будет выполнить /rl после изменения этой настройки.]]
L['GEN_MINIMAP'] = 'Показывать иконку на миникарте'
L['GEN_MINIMAP_DESC'] = 'Показывать иконку Guild Recruiter на миникарте.'
L['INVITE_SCAN_SETTINGS'] = 'Настройки приглашений и сканирования'
L['SEND_MESSAGE_WAIT_TIME'] = 'Задержка отправки сообщения'
L['SEND_MESSAGE_WAIT_TIME_DESC'] = 'Время в секундах перед отправкой сообщений из очереди (от 0.1 до 1 секунды).'
L['AUTO_SYNC'] = 'Включить автоматическую синхронизацию'
L['AUTO_SYNC_DESC'] = 'Автоматически синхронизироваться с участниками гильдии при входе в игру.'
L['SHOW_WHISPERS'] = 'Показывать шепот в чате'
L['SHOW_WHISPERS_DESC'] = [[
Показывать сообщения, которые вы отправляете игрокам при приглашении.

ПРИМЕЧАНИЕ: Вам нужно будет выполнить /rl после изменения этой настройки.]]
L['GEN_CONTEXT'] = 'Включить приглашение по правому клику в чате'
L['GEN_CONTEXT_DESC'] = 'Показывать контекстное меню Guild Recruiter при правом клике на имя в чате.'
L['COMPACT_SIZE'] = 'Компактный размер'
L['SCAN_WAIT_TIME'] = 'Задержка сканирования в секундах'
L['SCAN_WAIT_TIME_DESC'] = [[
Время в секундах перед сканированием игроков (от 2 до 10 секунд).

ПРИМЕЧАНИЕ: Рекомендуется 5 или 6 секунд.]]
L['KEYBINDING_HEADER'] = 'Назначение клавиш'
L['KEYBINDING_INVITE'] = 'Клавиша приглашения'
L['KEYBINDING_INVITE_DESC'] = 'Клавиша для приглашения игрока в гильдию.'
L['KEYBINDING_SCAN'] = 'Клавиша сканирования'
L['KEYBINDING_SCAN_DESC'] = 'Клавиша для сканирования игроков, ищущих гильдию.'
L['KEY_BINDING_NOTE'] = 'Примечание: Назначение клавиш не повлияет на клавиши WoW.'
--#endregion
--#region Настройки приглашений GM
L['GM_INVITE_SETTINGS'] = 'Настройки ГМ'
L['FORCE_OPTION'] = 'Принудительно использовать для не-ГМ'
L['ENABLE_BLOCK_INVITE_CHECK'] = 'Включить проверку блокировки приглашений.'
L['ENABLE_BLOCK_INVITE_CHECK_TOOLTIP'] = 'Пытается проверить, включена ли у игрока блокировка приглашений в гильдию.'
L['ENABLE_ANTI_SPAM_DESC'] = 'Включить функцию анти-спама для предотвращения спама игрокам.'
L['ANTI_SPAM_DAYS'] = 'Задержка повторного приглашения'
L['ANTI_SPAM_DAYS_DESC'] = 'Количество дней перед повторным приглашением игрока.'
L['GUILD_WELCOME_MSG'] = 'Приветственное сообщение в чате гильдии'
L['GUILD_WELCOME_MSG_DESC'] = 'Сообщение, отправляемое в чат гильдии, когда новый игрок присоединяется.'
L['WHISPER_WELCOME_MSG'] = 'Приветственное сообщение в личном сообщении'
L['WHISPER_WELCOME_MSG_DESC'] = 'Сообщение, отправляемое игроку, когда он присоединяется к гильдии.'
--#endregion
--#region Сообщения приглашений GM
L['GM_INVITE_MESSAGES'] = 'Сообщения ГМ'
L['PLAYER_SETTINGS_DESC'] = 'Оранжевые сообщения от ГМ.'
L['INVITE_ACTIVE_MESSAGE'] = 'Сообщения приглашений:'
L['INVITE_ACTIVE_MESSAGE_DESC'] = [[
Сообщения, которые будут отправлены потенциальным рекрутам.

ПРИМЕЧАНИЕ: Возможно, потребуется /rl после синхронизации, чтобы увидеть изменения.]]
L['NEW_MESSAGE_DESC'] = 'Добавить описание сообщения в список приглашений.'
L['INVITE_DESC'] = 'Описание сообщения приглашения:'
L['INVITE_DESC_TOOLTIP'] = 'Описание сообщения приглашения.'
L['SYNC_MESSAGES'] = 'Синхронизировать это сообщение.'
L['SYNC_MESSAGES_DESC'] = 'Синхронизировать это сообщение с гильдией.'

--#endregion
--#region Настройки приглашений игроков
L['INVITE_SETTINGS'] = 'Настройки приглашений'
L['INVITE_MESSAGES'] = 'Сообщения приглашений'
--#endregion
--#region Черный список
L['BLACKLIST_REMOVE'] = 'Удалить выбранные записи из черного списка'
L['ADD_TO_BLACKLIST'] = 'Добавить игрока в черный список.'
L['BL_PRIVATE_REASON'] = 'Переключить приватную причину'
L['BL_PRIVATE_REASON_DESC'] = 'Переключить приватную причину для черного списка.'
L['BL_PRIVATE_REASON_ERROR'] = 'Вы не добавили в черный список'
L['NO_REASON_GIVEN'] = 'Причина не указана'
L['ADDED_TO_BLACK_LIST'] = 'был добавлен в черный список с причиной %s.'
L['BL_NAME_NOT_ADDED'] = 'не был добавлен в черный список.'
L['IS_ON_BLACK_LIST'] = 'уже находится в черном списке.'
L['BLACK_LIST_REASON_INPUT'] = 'Пожалуйста, введите причину для добавления %s в черный список.'
L['BLACKLIST_NAME_PROMPT'] = [[
Пожалуйста, введите имя игрока,
которого вы хотите добавить в черный список.

Другой сервер, добавьте - и название сервера.
(Имя игрока-Название сервера)
]]
--#endregion
--#region Недопустимые зоны
L['INVALID_ZONE'] = 'Недопустимые зоны'
L['ZONE_NOT_FOUND'] = 'Не удалось найти зону'
L['ZONE_INSTRUCTIONS'] = 'Название зоны должно ТОЧНО совпадать с названием зоны в игре.'
L['ZONE_ID'] = 'ID зоны (числовой ID)'
L['ZONE_NAME'] = 'Название зоны:'
L['ZONE_INVALID_REASON'] = 'Причина недопустимости:'
L['ZONE_ID_DESC'] = [[
ID зоны для недопустимой зоны.
Список подземелий:
https://wowpedia.fandom.com/wiki/InstanceID
Лучшие ID мировых зон, которые я смог найти:
https://wowpedia.fandom.com/wiki/UiMapID
Если вы найдете зону, которую нужно добавить, пожалуйста, дайте мне знать.]]
L['ZONE_NOTE'] = 'Зоны с |cFF00FF00*|r - единственные редактируемые зоны.'
L['ZONE_LIST_NAME'] = 'Следующие зоны будут игнорироваться сканером:'
--#endregion
--#endregion

--#region Аналитика
L['ANALYTICS'] = 'Аналитика'
L['ANALYTICS_DESC'] = 'Просмотр статистики по приглашению игроков в гильдию.'
L['ANALYTICS_BLACKLISTED'] = 'Игроки, добавленные вами в черный список'
L['ANALYTICS_SCANNED'] = 'Всего отсканировано игроков'
L['ANALYTICS_INVITED'] = 'Игроки, приглашенные вами в гильдию'
L['ANALYTICS_DECLINED'] = 'Игроки, отклонившие приглашение'
L['ANALYTICS_ACCEPTED'] = 'Игроки, принявшие приглашение'
L['ANALYTICS_NO_GUILD'] = 'Игроки без гильдии'
L['ANALYTICS_STATS_START'] = 'Статистика начинается с'
L['ANALYTICS_SESSION'] = 'Сессия'
L['ANALYTICS_SESSION_SCANNED'] = 'Отсканировано'
L['ANALYTICS_SESSION_BLACKLISTED'] = 'Добавлено в черный список'
L['ANALYTICS_SESSION_INVITED'] = 'Приглашено'
L['ANALYTICS_SESSION_DECLINED'] = 'Отклонено приглашений'
L['ANALYTICS_SESSION_ACCEPTED'] = 'Принято приглашений'
L['ANALYTICS_SESSION_WAITING'] = 'Ожидание'
L['ANALYTICS_SESSION_TIMED_OUT'] = 'Приглашение истекло'
L['ANALYTICS_SESSION_NO_GUILD'] = 'Потенциальные найдены'
L['ANALYTICS_SESSION_STARTED'] = 'Сессия начата'
L['LAST_SCAN'] = 'Последний отсканированный игрок'

L['GUILD_ANALYTICS'] = 'Аналитика гильдии'
L['PROFILE_ANALYTICS'] = 'Аналитика персонажа'
L['SESSION_ANALYTICS'] = 'Аналитика сессии'
--#endregion

--#region Синхронизация
L['SYNC_ALREADY_IN_PROGRESS'] = 'Синхронизация уже выполняется'
L['SYNC_FAIL_TIMER'] = 'Синхронизация завершилась тайм-аутом, пожалуйста, попробуйте снова.'
-- Сервер
L['AUTO_SYNC_STARTED'] = 'Вы начали автоматическую синхронизацию с вашей гильдией.'
L['MANUAL_SYNC_STARTED'] = 'Вы начали синхронизацию с вашей гильдией.'
L['SYNC_CLIENTS_FOUND'] = 'Вы нашли %d клиентов для синхронизации.'
-- Клиент
L['SYNC_CLIENT_STARTED'] = 'запросил синхронизацию с Guild Recruiter.'
-- Любой
L['SYNC_SETTINGS_FAILED'] = 'Не удалось подготовить настройки для отправки.'

-- Ошибки
L['DATA_WAIT_TIMEOUT'] = 'Не удалось получить данные от клиента(ов).'
L['REQUEST_WAIT_TIMEOUT'] = 'Не удалось получить ответ от сервера.'
L['NO_CLIENTS_FOUND_TO_SYNC_WITH'] = 'Не найдено клиентов для синхронизации.'

-- Сообщения синхронизации
L['AUTO_SYNC'] = 'Автоматическая синхронизация'
L['MANUAL_SYNC'] = 'Ручная синхронизация'
L['CLIENT_SYNC'] = 'Синхронизация клиента'
L['SYNC_FINISHED'] = 'завершена.'

-- Конец сообщений синхронизации
L['SETTINGS_CHANGED'] = 'Настройки были обновлены.'
L['MESSAGE_LIST_CHANGED'] = 'Список сообщений был обновлен.'
L['BLACKLIST_CHANGED'] = 'Черный список обновлен с %d записями.'
L['ANTISPAM_CHANGED'] = 'Список анти-спама обновлен с %d записями.'
--#endregion
