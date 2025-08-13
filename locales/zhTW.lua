local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhTW")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "該玩家拒絕了公會邀請。"
L["PLAYER_ALREADY_IN_GUILD"]         = "該玩家已在某個公會中。"
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "該玩家已在你的公會中。"
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "已向該玩家發送過邀請。"
L["PLAYER_NOT_FOUND"]                = "找不到該玩家。"
L["PLAYER_NOT_PLAYING"]              = "該玩家目前未在遊玩《魔獸世界》。"
L["PLAYER_IGNORING_YOU"]             = "該玩家正在忽略你。"
L["PLAYER_JOINED_GUILD"]             = "該玩家已加入公會。"
L["PLAYER_NOT_ONLINE"]               = "該玩家不在線上。"
L["PLAYER_IN_GUILD"]                 = "該玩家在某個公會中。"

--#region General
L["INVITE"]    = "邀請"
L["SCAN"]      = "掃描"
L["ABOUT"]     = "關於"
L["CLOSE"]     = "關閉"
L["ENABLE"]    = "啟用"
L["ENABLED"]   = "已啟用"
L["DISABLE"]   = "停用"
L["DISABLED"]  = "已停用"
L["REMOVE"]    = "移除"
L["HELP"]      = "說明"
L["CONFIG"]    = "設定"
--#endregion

--#region Button Text
L["CANCEL"] = "取消"
L["DELETE"] = "刪除"
L["SAVE"]   = "儲存"
L["NEW"]    = "新增"
L["YES"]    = "是"
L["NO"]     = "否"
L["OK"]     = "確定"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[這是 Guild Recruiter 的 VER 版本。
若遇到問題，請到我們的 Discord 伺服器回報。]]
L["AUTO_LOCKED"] = "視窗移動已鎖定。"
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "反垃圾"
L["BLACKLIST"]     = "黑名單"
L["SETTINGS"]      = "設定"
L["PREVIEW_TITLE"] = "預覽所選訊息"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "沒有公會名稱，請重新載入介面。"
L["BL_NO_ONE_ADDED"]             = "沒有人被加入黑名單。"
L["GUILD_LINK_NOT_FOUND"]        = "找不到公會連結。請重新載入介面。"
L["GUILD_LINK_NOT_FOUND_LINE1"]  = "嘗試 /rl 或重新登入（可能需要多次嘗試）"
L["GM_GUILD_LINK_NOT_FOUND"]     = "在公會搜尋器建立招募資訊後再執行 /rl。"
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "嘗試與公會同步以取得連結。"
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "公會邀請（不發送訊息）"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "公會邀請（歡迎訊息）"
L["BLACKLIST_PLAYER"]             = "將玩家加入黑名單"
L["KICK_PLAYER_FROM_GUILD"]       = "將玩家移出公會（加入黑名單）"
L["KICK_PLAYER_CONFIRMATION"]     = "你確定要將 %s 移出公會嗎？"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "歡迎 PLAYERNAME 加入 GUILDNAME！"
L["DATABASE_RESET"] = [[
資料庫已重設。
由於整合了 Classic 與 Cata，所有資料已被重設。
對此造成的不便深感抱歉。
|cFFFFFFFF請重新載入介面（/rl 或 /reload）。|r]]
L["SLASH_COMMANDS"] = [[
Guild Recruiter 指令：
/rl 重新載入 WoW 介面（等同 /reload）。
/gr help - 顯示本說明。
/gr config - 開啟設定視窗。
/gr blacklist <玩家名稱> - 將玩家加入黑名單。]]
L["MINIMAP_TOOLTIP"] = [[
左鍵：開啟 Guild Recruiter
Shift+左鍵：開啟掃描器
右鍵：開啟設定
%AntiSpam 在邀請清單。
%BlackList 在封鎖清單。]]
L["NO_LONGER_GUILD_LEADER"] = "不再是公會會長。"
L["NO_ANTI_SPAM"]           = "未啟用反垃圾。請在設定中啟用。"
L["CANNOT_INVITE"]          = "你沒有邀請新成員的權限。"
L["NOT_IN_GUILD"]           = "由於你不在公會中，Guild Recruiter 已停用。"
L["NOT_IN_GUILD_LINE1"]     = "若加入公會，請使用 /rl 重新載入。"
L["FGI_LOADED"]             = "*警告* FGI 已載入。請停用它以使用 Guild Recruiter。"
--#endregion

--#region Base Screen
L["BACK"]                   = "返回"
L["BACK_TOOLTIP"]           = "返回上一頁。"
L["LOCK_TOOLTIP"]           = "切換視窗拖移"
L["RESET_FILTER"]           = "重設篩選"
L["RESET_FILTER_TOOLTIP"]   = "重設掃描器篩選以重新開始。"
L["COMPACT_MODE"]           = "緊湊模式"
L["COMPACT_MODE_TOOLTIP"]   = [[切換緊湊模式。
可在設定中調整緊湊模式大小。]]
L["ABOUT_TOOLTIP"]          = "Discord、支援與參與方式。"
L["SETTINGS_TOOLTIP"]       = "修改 Guild Recruiter 的設定。"
L["MANUAL_SYNC"]            = "手動同步"
L["MANUAL_SYNC_TOOLTIP"]    = "手動與其他公會成員同步你的清單。"
L["VIEW_ANALYTICS"]         = "查看統計"
L["VIEW_ANALYTICS_TOOLTIP"] = "顯示你的公會邀請統計。"
L["BLACKLIST_TOOLTIP"]      = "將玩家加入黑名單。"
L["CUSTOM_FILTERS"]         = "自訂篩選"
L["CUSTOM_FILTERS_TOOLTIP"] = "為掃描器新增自訂篩選。"
L["CUSTOM_FILTERS_DESC"] = [[
自訂篩選可依特定條件篩選玩家。
例如可依職業或種族篩選。]]
L["NEW_FILTER_DESC"]       = "建立新的掃描器篩選。"
L["FILTER_SAVE_LIST"]      = "儲存篩選清單"
L["FILTER_SAVE_LIST_DESC"] = "選擇要修改的篩選。"
L["FILTER_NAME"]           = "輸入篩選名稱："
L["FILTER_NAME_EXISTS"]    = "篩選名稱已存在。"
L["FILTER_CLASS"]          = "選擇職業或職業組合："
L["SELECT_ALL_CLASSES"]    = "全選職業"
L["CLEAR_ALL_CLASSES"]     = "清除全部職業"
L["FILTER_SAVED"]          = "篩選已儲存。"
L["FILTER_DELETED"]        = "篩選已刪除。"
L["FILTER_SAVE_ERROR"]     = "至少選擇 1 個職業與/或種族。"
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "僅訊息"
L["GUILD_INVITE_ONLY"]               = "僅公會邀請"
L["GUILD_INVITE_AND_MESSAGE"]        = "公會邀請與訊息"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "僅在邀請被拒時傳送訊息"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "待處理"
L["GUILD_INVITE_SENT"]      = "已傳送公會邀請給"
L["INVITE_MESSAGE_SENT"]    = "已傳送邀請訊息給"
L["INVITE_MESSAGE_QUEUED"]  = "邀請訊息已加入佇列："
L["GUILD_INVITE_BLOCKED"]   = "由於 %s 已封鎖公會邀請，已略過訊息。"
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "選擇一個篩選"
L["MIN_LEVEL"]                   = "最低等級"
L["MAX_LEVEL"]                   = "最高等級"
L["MAX_LEVEL_ERROR"]             = "請輸入 1 到 "
L["LEVELS_FIXED"]                = "等級已修正"
L["LEVELS_TOO_CLOSE"]            = "警告：請將區間維持在 5 級以內。"
L["SELECT_INVITE_TYPE"]          = "選擇邀請類型"
L["SELECT_INVITE_MESSAGE"]       = "選擇邀請訊息"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "在設定中建立訊息"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "篩選進度"
L["PLAYERS_FOUND"]             = "找到的玩家"
L["SEND_MESSAGE"]              = "傳送訊息"
L["SEND_INVITE"]               = "傳送邀請"
L["SEND_INVITE_AND_MESSAGE"]   = "傳送邀請與訊息"
L["BLACKLIST_TITLE"]           = "將所選玩家加入黑名單"
L["BLACKLIST_SCANNER_TOOLTIP"] = "將所選玩家加入黑名單。"
L["ANTISPAM_TITLE"]            = "將所選玩家加入反垃圾清單"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "將所選玩家加入反垃圾清單。"
L["WHO_RESULTS"]               = "/who 結果：找到 %d 名玩家"
L["SCAN_FOR_PLAYERS"]          = "搜尋玩家"
L["NEXT_QUERY"]                = "下一次查詢：%s"
L["NEXT_PLAYER_INVITE"]        = "下一位要邀請的玩家（佇列：%d）："
L["PLAYERS_QUEUED"]            = "佇列中的玩家：%d"
L["NO_QUEUED_PLAYERS"]         = "佇列中沒有玩家。"
L["WAIT"]                      = "等候"
L["INVITE_FIRST_STEP"]         = "你需要先點選「搜尋玩家」。"
L["ADD_TO_ANTISPAM"]           = "已將 %d 名玩家加入反垃圾清單。"
L["ADD_TO_BLACKLIST"]          = "已將 %d 名玩家加入黑名單。"
L["SKIP_PLAYER"]               = "跳過玩家"
L["SKIP"]                      = "跳過"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
希望此插件對你有所幫助。我在開發上投入了大量時間與心力。
若想贊助，請使用下方連結。
感謝你的支持！]]
L["ABOUT_LINK_MESSAGE"] = "更多資訊請參考以下連結："
L["COPY_LINK_MESSAGE"]  = "連結可複製。選取後按 CTRL+C。"
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(每則訊息 <sub> 個字元)"
L["LENGTH_INFO"] = "使用 PLAYERNAME 時預設以 12 個字元計算"
L["MESSAGE_LENGTH"] = "訊息長度"
L["GEN_GUILD_WIDE"]   = "表示僅影響你目前的公會。"
L["GEN_ACCOUNT_WIDE"] = "表示影響帳號內所有角色。"
L["RELOAD_AFTER_CHANGE"] = "變更後須重新載入介面（/rl）。"
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - 產生可點擊的公會連結。"
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - 顯示你的公會名稱。
PLAYERNAME - 顯示受邀玩家的名字。]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "GR 設定"
L["GEN_WHATS_NEW"]               = "顯示「最新消息」"
L["GEN_WHATS_NEW_DESC"]          = "Guild Recruiter 更新時顯示「最新消息」視窗."
L["GEN_TOOLTIPS"]                = "顯示所有提示"
L["GEN_TOOLTIP_DESC"]            = "在 Guild Recruiter 中顯示所有工具提示。"
L["GEN_ADDON_MESSAGES"]          = "顯示系統訊息"
L["GEN_ADDON_MESSAGES_DESC"]     = "顯示 Guild Recruiter 的系統訊息。"
L["KEEP_ADDON_OPEN"]             = "保持插件視窗開啟"
L["KEEP_ADDON_OPEN_DESC"]        = [[
保持插件開啟並忽略 ESC 等可能關閉它的動作。

注意：修改此設定後請執行 /rl。]]
L["GEN_MINIMAP"]                 = "顯示小地圖圖示"
L["GEN_MINIMAP_DESC"]            = "在小地圖上顯示 Guild Recruiter 圖示。"
L["INVITE_SCAN_SETTINGS"]        = "邀請與掃描設定"
L["SEND_MESSAGE_WAIT_TIME"]      = "傳送訊息延遲"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "傳送待發訊息前的延遲秒數（0.1–1 秒）。"
L["AUTO_SYNC"]                   = "啟用自動同步"
L["AUTO_SYNC_DESC"]              = "登入時自動與公會成員同步。"
L["SHOW_WHISPERS"]               = "在聊天中顯示密語"
L["SHOW_WHISPERS_DESC"]          = [[
在邀請玩家時顯示傳送給他們的訊息。

注意：修改此設定後請執行 /rl。]]
L["GEN_CONTEXT"]                 = "啟用在聊天中以右鍵邀請"
L["GEN_CONTEXT_DESC"]            = "在聊天中以右鍵點擊名字時顯示 Guild Recruiter 內容選單。"
L["COMPACT_SIZE"]                = "緊湊模式大小"
L["SCAN_WAIT_TIME"]              = "掃描等待時間（秒）"
L["SCAN_WAIT_TIME_DESC"]         = [[
在搜尋玩家前的等待時間（2–10 秒）。

注意：建議 5 或 6 秒。]]
L["KEYBINDING_HEADER"]           = "快速鍵"
L["KEYBINDING_INVITE"]           = "邀請快速鍵"
L["KEYBINDING_INVITE_DESC"]      = "邀請玩家加入公會的快速鍵。"
L["KEYBINDING_SCAN"]             = "掃描快速鍵"
L["KEYBINDING_SCAN_DESC"]        = "搜尋尋找公會的玩家的快速鍵。"
L["KEY_BINDING_NOTE"]            = "注意：這些快速鍵不會影響 WoW 的按鍵設定。"
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "GM 設定"
L["FORCE_OPTION"]                     = "強制非 GM 使用"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "啟用邀請封鎖檢查。"
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "嘗試檢查該玩家是否封鎖公會邀請。"
L["ENABLE_ANTI_SPAM_DESC"]            = "啟用反垃圾功能以防止洗頻。"
L["ANTI_SPAM_DAYS"]                   = "重新邀請延遲"
L["ANTI_SPAM_DAYS_DESC"]              = "再次邀請玩家前的天數。"
L["GUILD_WELCOME_MSG"]                = "公會聊天歡迎訊息"
L["GUILD_WELCOME_MSG_DESC"]           = "玩家加入時傳送到公會聊天的訊息。"
L["WHISPER_WELCOME_MSG"]              = "密語歡迎訊息"
L["WHISPER_WELCOME_MSG_DESC"]         = "玩家加入時傳送給該玩家的密語。"
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "GM 訊息"
L["PLAYER_SETTINGS_DESC"]       = "橘色訊息來自 GM。"
L["INVITE_ACTIVE_MESSAGE"]      = "邀請訊息："
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
傳送給潛在招募對象的訊息。

注意：同步後可能需要 /rl 才能看到變更。]]
L["NEW_MESSAGE_DESC"]           = "在邀請清單新增一則訊息描述。"
L["INVITE_DESC"]                = "邀請訊息描述："
L["INVITE_DESC_TOOLTIP"]        = "邀請訊息的描述。"
L["SYNC_MESSAGES"]              = "同步此訊息。"
L["SYNC_MESSAGES_DESC"]         = "與公會同步此訊息。"
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "邀請設定"
L["INVITE_MESSAGES"] = "邀請訊息"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "從黑名單移除所選項目"
L["ADD_TO_BLACKLIST"]         = "將玩家加入黑名單。"
L["BL_PRIVATE_REASON"]        = "切換私人理由"
L["BL_PRIVATE_REASON_DESC"]   = "切換黑名單的私人理由。"
L["BL_PRIVATE_REASON_ERROR"]  = "你尚未將任何人加入黑名單"
L["NO_REASON_GIVEN"]          = "未提供理由"
L["ADDED_TO_BLACK_LIST"]      = "已因理由 %s 被加入黑名單。"
L["BL_NAME_NOT_ADDED"]        = "未被加入黑名單。"
L["IS_ON_BLACK_LIST"]         = "已在黑名單中。"
L["BLACK_LIST_REASON_INPUT"]  = "輸入將 %s 加入黑名單的理由。"
L["BLACKLIST_NAME_PROMPT"] = [[
輸入你要加入黑名單的玩家名稱。

跨伺服器請加上「-」與伺服器名稱。
（玩家名-伺服器名）
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "無效區域"
L["ZONE_NOT_FOUND"]      = "無法找到該區域"
L["ZONE_INSTRUCTIONS"]   = "區域名稱必須與遊戲內名稱完全一致。"
L["ZONE_ID"]             = "區域 ID（數值 ID）"
L["ZONE_NAME"]           = "區域名稱："
L["ZONE_INVALID_REASON"] = "無效原因："
L["ZONE_ID_DESC"] = [[
無效區域的區域 ID。
副本清單：
https://wowpedia.fandom.com/wiki/InstanceID
世界地圖 ID 清單：
https://wowpedia.fandom.com/wiki/UiMapID
若發現需要新增的區域，請告知我。]]
L["ZONE_NOTE"]           = "標示為 |cFF00FF00*|r 的區域才可編輯。"
L["ZONE_LIST_NAME"]      = "掃描器將忽略以下區域："
--#endregion

--#region Analytics
L["ANALYTICS"]                     = "統計"
L["ANALYTICS_DESC"]                = "檢視你的公會邀請統計。"
L["ANALYTICS_BLACKLISTED"]         = "你加入黑名單的玩家"
L["ANALYTICS_SCANNED"]             = "總共掃描的玩家"
L["ANALYTICS_INVITED"]             = "邀請入會的玩家"
L["ANALYTICS_DECLINED"]            = "拒絕邀請的玩家"
L["ANALYTICS_ACCEPTED"]            = "接受邀請的玩家"
L["ANALYTICS_NO_GUILD"]            = "未發現公會的玩家"
L["ANALYTICS_STATS_START"]         = "統計起始於"
L["ANALYTICS_SESSION"]             = "工作階段"
L["ANALYTICS_SESSION_SCANNED"]     = "掃描"
L["ANALYTICS_SESSION_BLACKLISTED"] = "黑名單"
L["ANALYTICS_SESSION_INVITED"]     = "邀請"
L["ANALYTICS_SESSION_DECLINED"]    = "拒絕"
L["ANALYTICS_SESSION_ACCEPTED"]    = "接受"
L["ANALYTICS_SESSION_WAITING"]     = "等待中"
L["ANALYTICS_SESSION_TIMED_OUT"]   = "邀請逾時"
L["ANALYTICS_SESSION_NO_GUILD"]    = "發現的潛在對象"
L["ANALYTICS_SESSION_STARTED"]     = "工作階段已開始"
L["LAST_SCAN"]                     = "最後掃描的玩家"

L["GUILD_ANALYTICS"]   = "公會統計"
L["PROFILE_ANALYTICS"] = "角色統計"
L["SESSION_ANALYTICS"] = "工作階段統計"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "同步已在進行中"
L["SYNC_FAIL_TIMER"]               = "同步逾時，請再試一次。"
-- Server
L["AUTO_SYNC_STARTED"]             = "你已開始與公會進行自動同步。"
L["MANUAL_SYNC_STARTED"]           = "你已開始與公會進行同步。"
L["SYNC_CLIENTS_FOUND"]            = "找到 %d 個用戶端可進行同步。"
-- Client
L["SYNC_CLIENT_STARTED"]           = "已請求 Guild Recruiter 的同步。"
-- Either
L["SYNC_SETTINGS_FAILED"]          = "無法準備要傳送的設定。"

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "未自用戶端收到資料。"
L["REQUEST_WAIT_TIMEOUT"]          = "未收到伺服器回應。"
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "找不到可進行同步的用戶端。"

-- Sync Messages
L["AUTO_SYNC"]     = "自動同步"
L["MANUAL_SYNC"]   = "手動同步"
L["CLIENT_SYNC"]   = "用戶端同步"
L["SYNC_FINISHED"] = "已完成。"
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "設定已更新。"
L["MESSAGE_LIST_CHANGED"]  = "訊息清單已更新。"
L["BLACKLIST_CHANGED"]     = "黑名單已更新，共 %d 筆。"
L["ANTISPAM_CHANGED"]      = "反垃圾清單已更新，共 %d 筆。"

