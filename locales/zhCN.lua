local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "该玩家拒绝了公会邀请。"
L["PLAYER_ALREADY_IN_GUILD"]         = "该玩家已在一个公会中。"
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "该玩家已在你的公会中。"
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "已向该玩家发送过邀请。"
L["PLAYER_NOT_FOUND"]                = "未找到该玩家。"
L["PLAYER_NOT_PLAYING"]              = "该玩家当前未在玩《魔兽世界》。"
L["PLAYER_IGNORING_YOU"]             = "该玩家正在忽略你。"
L["PLAYER_JOINED_GUILD"]             = "该玩家已加入公会。"
L["PLAYER_NOT_ONLINE"]               = "该玩家不在线。"
L["PLAYER_IN_GUILD"]                 = "该玩家在一个公会中。"

--#region General
L["INVITE"]    = "邀请"
L["SCAN"]      = "扫描"
L["ABOUT"]     = "关于"
L["CLOSE"]     = "关闭"
L["ENABLE"]    = "启用"
L["ENABLED"]   = "已启用"
L["DISABLE"]   = "禁用"
L["DISABLED"]  = "已禁用"
L["REMOVE"]    = "移除"
L["HELP"]      = "帮助"
L["CONFIG"]    = "设置"
--#endregion

--#region Button Text
L["CANCEL"] = "取消"
L["DELETE"] = "删除"
L["SAVE"]   = "保存"
L["NEW"]    = "新建"
L["YES"]    = "是"
L["NO"]     = "否"
L["OK"]     = "确定"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[这是 Guild Recruiter 的 VER 版本。
若遇到问题，请在我们的 Discord 服务器反馈。]]
L["AUTO_LOCKED"] = "窗口移动已锁定。"
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "反垃圾"
L["BLACKLIST"]     = "黑名单"
L["SETTINGS"]      = "设置"
L["PREVIEW_TITLE"] = "选中消息预览"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "没有公会名称，请重载界面。"
L["BL_NO_ONE_ADDED"]             = "没有任何人被加入黑名单。"
L["GUILD_LINK_NOT_FOUND"]        = "未找到公会链接。请重载界面。"
L["GUILD_LINK_NOT_FOUND_LINE1"]  = "尝试 /rl 或重新登录（可能需要多次重试）"
L["GM_GUILD_LINK_NOT_FOUND"]     = "在公会查找器中创建一条招募信息，然后 /rl。"
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "尝试与公会同步以获取链接。"
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "公会邀请（不发送消息）"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "公会邀请（发送欢迎消息）"
L["BLACKLIST_PLAYER"]             = "将玩家加入黑名单"
L["KICK_PLAYER_FROM_GUILD"]       = "将玩家移出公会（加入黑名单）"
L["KICK_PLAYER_CONFIRMATION"]     = "确认将 %s 移出公会吗？"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "欢迎 PLAYERNAME 加入 GUILDNAME！"
L["DATABASE_RESET"] = [[
数据库已重置。
由于整合了怀旧服与大灾变，所有数据已被重置。
对此带来的不便深表歉意。
|cFFFFFFFF请重载界面（/rl 或 /reload）。|r]]
L["SLASH_COMMANDS"] = [[
Guild Recruiter 命令：
/rl 重新加载 WoW 界面（等同 /reload）。
/gr help - 显示此帮助。
/gr config - 打开设置窗口。
/gr blacklist <玩家名> - 将玩家加入黑名单。]]
L["MINIMAP_TOOLTIP"] = [[
左键：打开 Guild Recruiter
Shift+左键：打开扫描器
右键：打开设置
%AntiSpam 位于邀请列表。
%BlackList 位于黑名单列表。]]
L["NO_LONGER_GUILD_LEADER"] = "不再是会长。"
L["NO_ANTI_SPAM"]           = "未启用反垃圾。请在设置中启用。"
L["CANNOT_INVITE"]          = "你没有邀请新成员的权限。"
L["NOT_IN_GUILD"]           = "由于你不在公会中，Guild Recruiter 已被禁用。"
L["NOT_IN_GUILD_LINE1"]     = "若加入了公会，请使用 /rl 重载。"
L["FGI_LOADED"]             = "*警告* FGI 已加载。请将其禁用以使用 Guild Recruiter。"
--#endregion

--#region Base Screen
L["BACK"]                   = "返回"
L["BACK_TOOLTIP"]           = "返回上一屏。"
L["LOCK_TOOLTIP"]           = "切换窗口拖动"
L["RESET_FILTER"]           = "重置筛选"
L["RESET_FILTER_TOOLTIP"]   = "重置扫描器筛选以重新开始。"
L["COMPACT_MODE"]           = "紧凑模式"
L["COMPACT_MODE_TOOLTIP"]   = [[切换紧凑模式。
可在设置中调整紧凑模式大小。]]
L["ABOUT_TOOLTIP"]          = "Discord、支持与参与方式。"
L["SETTINGS_TOOLTIP"]       = "修改 Guild Recruiter 的设置。"
L["MANUAL_SYNC"]            = "手动同步"
L["MANUAL_SYNC_TOOLTIP"]    = "手动与其他公会成员同步你的列表。"
L["VIEW_ANALYTICS"]         = "查看统计"
L["VIEW_ANALYTICS_TOOLTIP"] = "显示你的公会邀请统计。"
L["BLACKLIST_TOOLTIP"]      = "将玩家加入黑名单。"
L["CUSTOM_FILTERS"]         = "自定义筛选"
L["CUSTOM_FILTERS_TOOLTIP"] = "为扫描器添加自定义筛选。"
L["CUSTOM_FILTERS_DESC"] = [[
自定义筛选可按特定条件筛选玩家。
例如可按职业或种族筛选。]]
L["NEW_FILTER_DESC"]       = "新建一个用于扫描器的筛选。"
L["FILTER_SAVE_LIST"]      = "保存筛选列表"
L["FILTER_SAVE_LIST_DESC"] = "选择要修改的筛选。"
L["FILTER_NAME"]           = "输入筛选名称："
L["FILTER_NAME_EXISTS"]    = "筛选名称已存在。"
L["FILTER_CLASS"]          = "选择职业或职业组合："
L["SELECT_ALL_CLASSES"]    = "全选职业"
L["CLEAR_ALL_CLASSES"]     = "清除选择"
L["FILTER_SAVED"]          = "筛选已保存。"
L["FILTER_DELETED"]        = "筛选已删除。"
L["FILTER_SAVE_ERROR"]     = "至少选择 1 个职业和/或种族。"
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "仅消息"
L["GUILD_INVITE_ONLY"]               = "仅公会邀请"
L["GUILD_INVITE_AND_MESSAGE"]        = "公会邀请和消息"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "仅在邀请被拒时发送消息"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "待处理"
L["GUILD_INVITE_SENT"]      = "已发送公会邀请给"
L["INVITE_MESSAGE_SENT"]    = "已发送邀请消息给"
L["INVITE_MESSAGE_QUEUED"]  = "邀请消息已加入队列："
L["GUILD_INVITE_BLOCKED"]   = "因 %s 已屏蔽公会邀请，已跳过消息。"
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "选择一个筛选"
L["MIN_LEVEL"]                   = "最低等级"
L["MAX_LEVEL"]                   = "最高等级"
L["MAX_LEVEL_ERROR"]             = "请输入 1 到 "
L["LEVELS_FIXED"]                = "等级已修正"
L["LEVELS_TOO_CLOSE"]            = "警告：请将区间保持在 5 级以内。"
L["SELECT_INVITE_TYPE"]          = "选择邀请类型"
L["SELECT_INVITE_MESSAGE"]       = "选择邀请消息"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "在设置中创建消息"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "筛选进度"
L["PLAYERS_FOUND"]             = "找到的玩家"
L["SEND_MESSAGE"]              = "发送消息"
L["SEND_INVITE"]               = "发送邀请"
L["SEND_INVITE_AND_MESSAGE"]   = "发送邀请和消息"
L["BLACKLIST_TITLE"]           = "将所选玩家加入黑名单"
L["BLACKLIST_SCANNER_TOOLTIP"] = "将所选玩家加入黑名单。"
L["ANTISPAM_TITLE"]            = "将所选玩家加入反垃圾"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "将所选玩家加入反垃圾列表。"
L["WHO_RESULTS"]               = "/who 结果：找到 %d 名玩家"
L["SCAN_FOR_PLAYERS"]          = "搜索玩家"
L["NEXT_QUERY"]                = "下一次查询：%s"
L["NEXT_PLAYER_INVITE"]        = "下一位要邀请的玩家（队列：%d）："
L["PLAYERS_QUEUED"]            = "队列中的玩家：%d"
L["NO_QUEUED_PLAYERS"]         = "队列中没有玩家。"
L["WAIT"]                      = "等待"
L["INVITE_FIRST_STEP"]         = "你需要先点击“搜索玩家”。"
L["ADD_TO_ANTISPAM"]           = "已将 %d 名玩家加入反垃圾列表。"
L["ADD_TO_BLACKLIST"]          = "已将 %d 名玩家加入黑名单。"
L["SKIP_PLAYER"]               = "跳过该玩家"
L["SKIP"]                      = "跳过"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
希望该插件对你有帮助。我为其开发投入了大量时间与精力。
如需捐助，请使用下方链接。
感谢你的支持！]]
L["ABOUT_LINK_MESSAGE"] = "更多信息请访问以下链接："
L["COPY_LINK_MESSAGE"]  = "链接可复制。选中后按 CTRL+C。"
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(每条消息 <sub> 个字符)"
L["LENGTH_INFO"] = "使用 PLAYERNAME 时默认按 12 个字符计算"
L["MESSAGE_LENGTH"] = "消息长度"
L["GEN_GUILD_WIDE"]   = "表示仅作用于你当前的公会。"
L["GEN_ACCOUNT_WIDE"] = "表示作用于账号下所有角色."
L["RELOAD_AFTER_CHANGE"] = "变更后需要重载界面（/rl）。"
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - 生成一个指向你公会的可点击链接。"
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - 显示你的公会名称。
PLAYERNAME - 显示被邀请玩家的名字。]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "GR 设置"
L["GEN_WHATS_NEW"]               = "显示“最新变化”"
L["GEN_WHATS_NEW_DESC"]          = "在 Guild Recruiter 更新时显示“最新变化”窗口。"
L["GEN_TOOLTIPS"]                = "显示所有提示"
L["GEN_TOOLTIP_DESC"]            = "在 Guild Recruiter 中显示所有工具提示。"
L["GEN_ADDON_MESSAGES"]          = "显示系统消息"
L["GEN_ADDON_MESSAGES_DESC"]     = "显示 Guild Recruiter 的系统消息。"
L["KEEP_ADDON_OPEN"]             = "保持插件窗口打开"
L["KEEP_ADDON_OPEN_DESC"]        = [[
保持插件窗口打开，忽略 ESC 等可能关闭它的操作。

注意：修改此设置后请执行 /rl。]]
L["GEN_MINIMAP"]                 = "显示小地图图标"
L["GEN_MINIMAP_DESC"]            = "在小地图上显示 Guild Recruiter 图标。"
L["INVITE_SCAN_SETTINGS"]        = "邀请与扫描设置"
L["SEND_MESSAGE_WAIT_TIME"]      = "发送消息延迟"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "发送待发消息前的延迟（0.1–1 秒）。"
L["AUTO_SYNC"]                   = "启用自动同步"
L["AUTO_SYNC_DESC"]              = "登录时自动与公会成员同步。"
L["SHOW_WHISPERS"]               = "在聊天中显示密语"
L["SHOW_WHISPERS_DESC"]          = [[
在邀请玩家时显示发送给他们的消息。

注意：修改此设置后请执行 /rl。]]
L["GEN_CONTEXT"]                 = "启用在聊天中右键邀请"
L["GEN_CONTEXT_DESC"]            = "在聊天中右键点击名字时显示 Guild Recruiter 上下文菜单。"
L["COMPACT_SIZE"]                = "紧凑模式大小"
L["SCAN_WAIT_TIME"]              = "扫描等待时间（秒）"
L["SCAN_WAIT_TIME_DESC"]         = [[
在搜索玩家前等待的时间（2–10 秒）。

注意：推荐 5 或 6 秒。]]
L["KEYBINDING_HEADER"]           = "快捷键"
L["KEYBINDING_INVITE"]           = "邀请快捷键"
L["KEYBINDING_INVITE_DESC"]      = "邀请玩家加入公会的快捷键。"
L["KEYBINDING_SCAN"]             = "扫描快捷键"
L["KEYBINDING_SCAN_DESC"]        = "搜索寻找公会的玩家的快捷键。"
L["KEY_BINDING_NOTE"]            = "注意：这些快捷键不会影响 WoW 的按键设置。"
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "GM 设置"
L["FORCE_OPTION"]                     = "强制非 GM 也使用"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "启用邀请屏蔽检查。"
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "尝试检测该玩家是否屏蔽了公会邀请。"
L["ENABLE_ANTI_SPAM_DESC"]            = "启用反垃圾功能以防止刷屏。"
L["ANTI_SPAM_DAYS"]                   = "重新邀请延迟"
L["ANTI_SPAM_DAYS_DESC"]              = "再次邀请该玩家前的天数。"
L["GUILD_WELCOME_MSG"]                = "公会聊天欢迎消息"
L["GUILD_WELCOME_MSG_DESC"]           = "当玩家加入时发送到公会聊天的消息。"
L["WHISPER_WELCOME_MSG"]              = "密语欢迎消息"
L["WHISPER_WELCOME_MSG_DESC"]         = "玩家加入时发送给其的密语。"
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "GM 消息"
L["PLAYER_SETTINGS_DESC"]       = "橙色消息来自 GM。"
L["INVITE_ACTIVE_MESSAGE"]      = "邀请消息："
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
发送给潜在招募对象的消息。

注意：同步后可能需要 /rl 才能看到更改。]]
L["NEW_MESSAGE_DESC"]           = "向邀请列表添加一条消息描述。"
L["INVITE_DESC"]                = "邀请消息描述："
L["INVITE_DESC_TOOLTIP"]        = "邀请消息的描述。"
L["SYNC_MESSAGES"]              = "同步此消息。"
L["SYNC_MESSAGES_DESC"]         = "将此消息与公会同步。"
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "邀请设置"
L["INVITE_MESSAGES"] = "邀请消息"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "从黑名单中移除所选条目"
L["ADD_TO_BLACKLIST"]         = "将玩家加入黑名单。"
L["BL_PRIVATE_REASON"]        = "切换私有原因"
L["BL_PRIVATE_REASON_DESC"]   = "切换黑名单的私有原因。"
L["BL_PRIVATE_REASON_ERROR"]  = "你尚未将任何人加入黑名单"
L["NO_REASON_GIVEN"]          = "未提供原因"
L["ADDED_TO_BLACK_LIST"]      = "已因原因 %s 被加入黑名单。"
L["BL_NAME_NOT_ADDED"]        = "未被加入黑名单。"
L["IS_ON_BLACK_LIST"]         = "已在黑名单中。"
L["BLACK_LIST_REASON_INPUT"]  = "输入将 %s 加入黑名单的原因。"
L["BLACKLIST_NAME_PROMPT"] = [[
输入你要加入黑名单的玩家名字。

跨服请添加“-服务器名”。
（玩家名-服务器名）
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "无效区域"
L["ZONE_NOT_FOUND"]      = "未能找到该区域"
L["ZONE_INSTRUCTIONS"]   = "区域名称必须与游戏内名称完全一致。"
L["ZONE_ID"]             = "区域 ID（数字 ID）"
L["ZONE_NAME"]           = "区域名称："
L["ZONE_INVALID_REASON"] = "无效原因："
L["ZONE_ID_DESC"] = [[
无效区域的区域 ID。
副本列表：
https://wowpedia.fandom.com/wiki/InstanceID
世界地图 ID 列表：
https://wowpedia.fandom.com/wiki/UiMapID
如果发现需要添加的区域，请告知我。]]
L["ZONE_NOTE"]           = "标记为 |cFF00FF00*|r 的区域才可编辑。"
L["ZONE_LIST_NAME"]      = "扫描器将忽略以下区域："
--#endregion

--#region Analytics
L["ANALYTICS"]                     = "统计"
L["ANALYTICS_DESC"]                = "查看你的公会邀请统计。"
L["ANALYTICS_BLACKLISTED"]         = "已加入黑名单的玩家"
L["ANALYTICS_SCANNED"]             = "总共扫描的玩家"
L["ANALYTICS_INVITED"]             = "邀请入会的玩家"
L["ANALYTICS_DECLINED"]            = "拒绝邀请的玩家"
L["ANALYTICS_ACCEPTED"]            = "接受邀请的玩家"
L["ANALYTICS_NO_GUILD"]            = "未发现公会的玩家"
L["ANALYTICS_STATS_START"]         = "统计开始于"
L["ANALYTICS_SESSION"]             = "会话"
L["ANALYTICS_SESSION_SCANNED"]     = "扫描"
L["ANALYTICS_SESSION_BLACKLISTED"] = "黑名单"
L["ANALYTICS_SESSION_INVITED"]     = "邀请"
L["ANALYTICS_SESSION_DECLINED"]    = "拒绝"
L["ANALYTICS_SESSION_ACCEPTED"]    = "接受"
L["ANALYTICS_SESSION_WAITING"]     = "等待中"
L["ANALYTICS_SESSION_TIMED_OUT"]   = "邀请超时"
L["ANALYTICS_SESSION_NO_GUILD"]    = "发现的潜在对象"
L["ANALYTICS_SESSION_STARTED"]     = "会话已开始"
L["LAST_SCAN"]                     = "最后扫描的玩家"

L["GUILD_ANALYTICS"]   = "公会统计"
L["PROFILE_ANALYTICS"] = "角色统计"
L["SESSION_ANALYTICS"] = "会话统计"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "同步已在进行中"
L["SYNC_FAIL_TIMER"]               = "同步超时，请重试。"
-- Server
L["AUTO_SYNC_STARTED"]             = "你已开始与公会进行自动同步。"
L["MANUAL_SYNC_STARTED"]           = "你已开始与公会进行同步。"
L["SYNC_CLIENTS_FOUND"]            = "找到 %d 个客户端可进行同步。"
-- Client
L["SYNC_CLIENT_STARTED"]           = "请求了 Guild Recruiter 的同步。"
-- Either
L["SYNC_SETTINGS_FAILED"]          = "未能准备要发送的设置。"

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "未从客户端收到数据。"
L["REQUEST_WAIT_TIMEOUT"]          = "未收到来自服务器的响应。"
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "未找到可进行同步的客户端。"

-- Sync Messages
L["AUTO_SYNC"]     = "自动同步"
L["MANUAL_SYNC"]   = "手动同步"
L["CLIENT_SYNC"]   = "客户端同步"
L["SYNC_FINISHED"] = "已完成。"
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "设置已更新。"
L["MESSAGE_LIST_CHANGED"]  = "消息列表已更新。"
L["BLACKLIST_CHANGED"]     = "黑名单已更新，共 %d 条。"
L["ANTISPAM_CHANGED"]      = "反垃圾列表已更新，共 %d 条。"