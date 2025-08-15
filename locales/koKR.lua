local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "koKR")
if not L then return end

-- System outcomes (map from PATS tags)
L["PLAYER_DECLINED_INVITE"]          = "플레이어가 길드 초대를 거절했습니다."
L["PLAYER_ALREADY_IN_GUILD"]         = "해당 플레이어는 이미 길드에 속해 있습니다."
L["PLAYER_ALREADY_IN_YOUR_GUILD"]    = "해당 플레이어는 이미 당신의 길드에 있습니다."
L["PLAYER_ALREADY_INVITED_TO_GUILD"] = "해당 플레이어는 이미 초대를 받았습니다."
L["PLAYER_NOT_FOUND"]                = "플레이어를 찾을 수 없습니다."
L["PLAYER_NOT_PLAYING"]              = "해당 플레이어는 현재 월드 오브 워크래프트를 플레이하지 않습니다."
L["PLAYER_IGNORING_YOU"]             = "해당 플레이어는 당신을 무시하고 있습니다."
L["PLAYER_JOINED_GUILD"]             = "플레이어가 길드에 가입했습니다."
L["PLAYER_NOT_ONLINE"]               = "플레이어가 오프라인입니다."
L["PLAYER_IN_GUILD"]                 = "해당 플레이어는 길드에 있습니다."

--#region General
L["INVITE"]    = "초대"
L["SCAN"]      = "스캔"
L["ABOUT"]     = "정보"
L["CLOSE"]     = "닫기"
L["ENABLE"]    = "사용"
L["ENABLED"]   = "사용됨"
L["DISABLE"]   = "사용 안 함"
L["DISABLED"]  = "비활성화됨"
L["REMOVE"]    = "제거"
L["HELP"]      = "도움말"
L["CONFIG"]    = "설정"
--#endregion

--#region Button Text
L["CANCEL"] = "취소"
L["DELETE"] = "삭제"
L["SAVE"]   = "저장"
L["NEW"]    = "새로 만들기"
L["YES"]    = "예"
L["NO"]     = "아니요"
L["OK"]     = "확인"
--#endregion

--#region System Messages
L["TITLE"] = "Guild Recruiter"
L["BETA_INFORMATION"] = [[이것은 Guild Recruiter의 VER 버전입니다.
문제가 있으면 디스코드 서버에 제보해 주세요.]]
L["AUTO_LOCKED"] = "창 이동이 잠겼습니다."
--#endregion

--#region Frequently used strings
L["ANTI_SPAM"]     = "스팸 방지"
L["BLACKLIST"]     = "블랙리스트"
L["SETTINGS"]      = "설정"
L["PREVIEW_TITLE"] = "선택한 메시지 미리보기"
--#endregion

--#region General Error Messages
L["NO_GUILD_NAME"]               = "길드 이름이 없습니다. UI를 다시 불러오세요."
L["BL_NO_ONE_ADDED"]             = "블랙리스트에 아무도 추가되지 않았습니다."
L["GUILD_LINK_NOT_FOUND"]        = "길드 링크를 찾을 수 없습니다. UI를 다시 불러오세요."
L["GUILD_LINK_NOT_FOUND_LINE1"]  = " /rl 또는 재접속을 시도해 보세요(여러 번 필요할 수 있음)"
L["GM_GUILD_LINK_NOT_FOUND"]     = "길드 찾기에서 모집 글 생성 후 /rl을 실행하세요."
L["PLAYER_GUILD_LINK_NOT_FOUND"] = "길드와 동기화하여 길드 링크를 받아 보세요."
--#endregion

--#region Context Menu
L["GUILD_INVITE_NO_MESSAGE"]      = "길드 초대(메시지 없음)"
L["GUILD_INVITE_WELCOME_MESSAGE"] = "길드 초대(환영 메시지)"
L["BLACKLIST_PLAYER"]             = "플레이어를 블랙리스트에 추가"
L["KICK_PLAYER_FROM_GUILD"]       = "길드에서 플레이어 추방(블랙리스트에 추가)"
L["KICK_PLAYER_CONFIRMATION"]     = "정말 %s님을 길드에서 추방하시겠습니까?"
--#endregion

--#region Core
L["RECRUITER"]             = "recruiter"
L["DEFAULT_GUILD_WELCOME"] = "PLAYERNAME님, GUILDNAME에 오신 것을 환영합니다!"
L["DATABASE_RESET"] = [[
데이터베이스가 초기화되었습니다.
클래식과 카타 통합으로 인해 모든 데이터가 초기화되었습니다.
불편을 드려 죄송합니다.
|cFFFFFFFFUI를 다시 불러오세요(/rl 또는 /reload).|r]]
L["SLASH_COMMANDS"] = [[
Guild Recruiter 슬래시 명령:
 /rl 은 WoW UI를 다시 불러옵니다(/reload와 동일).
 /gr help - 이 도움말을 표시합니다.
 /gr config - 설정 창을 엽니다.
 /gr blacklist <플레이어이름> - 해당 플레이어를 블랙리스트에 추가합니다.]]
L["MINIMAP_TOOLTIP"] = [[
좌클릭: Guild Recruiter 열기
Shift+좌클릭: 스캐너 열기
우클릭: 설정 열기
%AntiSpam 은 초대 목록에서.
%BlackList 는 블랙리스트 목록에서.]]
L["NO_LONGER_GUILD_LEADER"] = "더 이상 길드장이 아닙니다."
L["NO_ANTI_SPAM"]           = "스팸 방지 기능이 꺼져 있습니다. 설정에서 켜 주세요."
L["CANNOT_INVITE"]          = "새 구성원을 초대할 권한이 없습니다."
L["NOT_IN_GUILD"]           = "길드에 속해 있지 않아 Guild Recruiter가 비활성화되었습니다."
L["NOT_IN_GUILD_LINE1"]     = "길드에 가입했다면 /rl로 다시 불러오세요."
L["FGI_LOADED"]             = "*경고* FGI가 로드되어 있습니다. Guild Recruiter를 사용하려면 비활성화하세요."
--#endregion

--#region Base Screen
L["BACK"]                   = "뒤로"
L["BACK_TOOLTIP"]           = "이전 화면으로 돌아갑니다."
L["LOCK_TOOLTIP"]           = "창 이동 전환"
L["RESET_FILTER"]           = "필터 재설정"
L["RESET_FILTER_TOOLTIP"]   = "스캐너 필터를 재설정하여 다시 시작합니다."
L["COMPACT_MODE"]           = "컴팩트 모드"
L["COMPACT_MODE_TOOLTIP"]   = [[컴팩트 모드를 전환합니다.
컴팩트 모드 크기는 설정에서 변경하세요.]]
L["ABOUT_TOOLTIP"]          = "디스코드, 지원 정보 및 기여 방법."
L["SETTINGS_TOOLTIP"]       = "Guild Recruiter 설정을 변경합니다."
L["MANUAL_SYNC"]            = "수동 동기화"
L["MANUAL_SYNC_TOOLTIP"]    = "길드원과 목록을 수동으로 동기화합니다."
L["VIEW_ANALYTICS"]         = "분석 보기"
L["VIEW_ANALYTICS_TOOLTIP"] = "길드 초대 관련 통계를 보여줍니다."
L["BLACKLIST_TOOLTIP"]      = "플레이어를 블랙리스트에 추가합니다."
L["CUSTOM_FILTERS"]         = "사용자 지정 필터"
L["CUSTOM_FILTERS_TOOLTIP"] = "스캐너에 사용자 지정 필터를 추가합니다."
L["CUSTOM_FILTERS_DESC"] = [[
사용자 지정 필터로 특정 기준에 따라 플레이어를 거를 수 있습니다.
예: 직업 또는 종족으로 필터링.]]
L["NEW_FILTER_DESC"]       = "스캐너용 새 필터를 만듭니다."
L["FILTER_SAVE_LIST"]      = "필터 목록 저장"
L["FILTER_SAVE_LIST_DESC"] = "편집할 필터를 선택하세요."
L["FILTER_NAME"]           = "필터 이름 입력:"
L["FILTER_NAME_EXISTS"]    = "이미 존재하는 필터 이름입니다."
L["FILTER_CLASS"]          = "직업 또는 직업 조합 선택:"
L["SELECT_ALL_CLASSES"]    = "모든 직업 선택"
L["CLEAR_ALL_CLASSES"]     = "모든 직업 해제"
L["FILTER_SAVED"]          = "필터가 저장되었습니다."
L["FILTER_DELETED"]        = "필터가 삭제되었습니다."
L["FILTER_SAVE_ERROR"]     = "직업 및/또는 종족을 최소 1개 선택하세요."
--#endregion

--#region Invite Formats
L["MESSAGE_ONLY"]                    = "메시지만"
L["GUILD_INVITE_ONLY"]               = "길드 초대만"
L["GUILD_INVITE_AND_MESSAGE"]        = "길드 초대와 메시지"
L["MESSAGE_ONLY_IF_INVITE_DECLINED"] = "초대를 거절한 경우에만 메시지"
--#endregion

--#region Invite Code
L["ALREADY_INVITED_STATUS"] = "대기 중"
L["GUILD_INVITE_SENT"]      = "길드 초대 보냄:"
L["INVITE_MESSAGE_SENT"]    = "초대 메시지 보냄:"
L["INVITE_MESSAGE_QUEUED"]  = "초대 메시지가 대기열에 추가됨:"
L["GUILD_INVITE_BLOCKED"]   = "%s은(는) 길드 초대를 차단하여 메시지를 건너뜁니다."
--#endregion

--#region Home Screen
L["SELECT_A_FILTER"]             = "필터 선택"
L["MIN_LEVEL"]                   = "최소 레벨"
L["MAX_LEVEL"]                   = "최대 레벨"
L["MAX_LEVEL_ERROR"]             = "1부터 "
L["LEVELS_FIXED"]                = "레벨이 수정되었습니다"
L["LEVELS_TOO_CLOSE"]            = "주의: 범위를 5레벨 이내로 유지하세요."
L["SELECT_INVITE_TYPE"]          = "초대 유형 선택"
L["SELECT_INVITE_MESSAGE"]       = "초대 메시지 선택"
L["CREATE_MESSAGE_IN_SETTINGS"]  = "설정에서 메시지 생성"
--#endregion

--#region Scanner Screen
L["FILTER_PROGRESS"]           = "필터 진행도"
L["PLAYERS_FOUND"]             = "발견된 플레이어"
L["SEND_MESSAGE"]              = "메시지 보내기"
L["SEND_INVITE"]               = "초대 보내기"
L["SEND_INVITE_AND_MESSAGE"]   = "초대와 메시지 보내기"
L["BLACKLIST_TITLE"]           = "선택한 플레이어를 블랙리스트에 추가"
L["BLACKLIST_SCANNER_TOOLTIP"] = "선택한 플레이어를 블랙리스트에 추가합니다."
L["ANTISPAM_TITLE"]            = "선택한 플레이어를 스팸 방지 목록에 추가"
L["ANTISPAM_SCANNER_TOOLTIP"]  = "선택한 플레이어를 스팸 방지 목록에 추가합니다."
L["WHO_RESULTS"]               = "/who 결과: %d명의 플레이어 발견"
L["SCAN_FOR_PLAYERS"]          = "플레이어 검색"
L["NEXT_QUERY"]                = "다음 질의: %s"
L["NEXT_PLAYER_INVITE"]        = "다음 초대 대상(대기열: %d):"
L["PLAYERS_QUEUED"]            = "대기열의 플레이어: %d"
L["NO_QUEUED_PLAYERS"]         = "대기열에 플레이어가 없습니다."
L["WAIT"]                      = "대기"
L["INVITE_FIRST_STEP"]         = "먼저 '플레이어 검색'을 클릭해야 합니다."
L["ADD_TO_ANTISPAM"]           = "%d명의 플레이어가 스팸 방지 목록에 추가되었습니다."
L["ADD_TO_BLACKLIST"]          = "%d명의 플레이어가 블랙리스트에 추가되었습니다."
L["SKIP_PLAYER"]               = "플레이어 건너뛰기"
L["SKIP"]                      = "건너뛰기"
--#endregion

--#region About Screen
L["DONATION_MESSAGE"] = [[
이 애드온이 도움이 되었길 바랍니다. 개발에 많은 시간과 노력을 들였습니다.
후원하고 싶다면 아래 링크를 사용해 주세요.
지원해 주셔서 감사합니다!]]
L["ABOUT_LINK_MESSAGE"] = "자세한 정보는 다음 링크를 참고하세요:"
L["COPY_LINK_MESSAGE"]  = "링크는 복사할 수 있습니다. 선택 후 CTRL+C를 사용하세요."
--#endregion

--#region Guild Recruiter Settings
L["MAX_CHARS"]   = "(<sub> 메시지당 글자 수)"
L["LENGTH_INFO"] = "PLAYERNAME 사용 시 12자를 가정"
L["MESSAGE_LENGTH"] = "메시지 길이"
L["GEN_GUILD_WIDE"]   = "현재 길드에만 적용됩니다."
L["GEN_ACCOUNT_WIDE"] = "계정 내 모든 캐릭터에 적용됩니다."
L["RELOAD_AFTER_CHANGE"] = "변경 후에는 UI(/rl)를 다시 불러와야 합니다."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_CLASSIC"] = ""
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_1"] = "GUILDLINK - 길드로 가는 클릭 가능한 링크를 생성합니다."
L["MESSAGE_REPLACEMENT_INSTRUCTIONS_PART_2"] = [[
GUILDNAME - 당신의 길드 이름을 표시합니다.
PLAYERNAME - 초대받는 플레이어의 이름을 표시합니다.]]
L["GUILDLINK"]  = "GUILDLINK"
L["GUILDNAME"]  = "GUILDNAME"
L["PLAYERNAME"] = "PLAYERNAME"

-- General Settings
L["GR_SETTINGS"]                 = "GR 설정"
L["GEN_WHATS_NEW"]               = "\"새 소식\" 표시"
L["GEN_WHATS_NEW_DESC"]          = "Guild Recruiter 업데이트 시 \"새 소식\" 창을 표시합니다."
L["GEN_TOOLTIPS"]                = "모든 툴팁 표시"
L["GEN_TOOLTIP_DESC"]            = "Guild Recruiter의 모든 툴팁을 표시합니다."
L["GEN_ADDON_MESSAGES"]          = "시스템 메시지 표시"
L["GEN_ADDON_MESSAGES_DESC"]     = "Guild Recruiter의 시스템 메시지를 표시합니다."
L["KEEP_ADDON_OPEN"]             = "애드온 열어 두기"
L["KEEP_ADDON_OPEN_DESC"]        = [[
애드온을 열린 상태로 유지하고 ESC 등으로 닫히지 않게 합니다.

참고: 이 설정 변경 후 /rl이 필요합니다.]]
L["GEN_MINIMAP"]                 = "미니맵 아이콘 표시"
L["GEN_MINIMAP_DESC"]            = "Guild Recruiter 미니맵 아이콘을 표시합니다."
L["INVITE_SCAN_SETTINGS"]        = "초대 및 스캔 설정"
L["SEND_MESSAGE_WAIT_TIME"]      = "메시지 전송 지연"
L["SEND_MESSAGE_WAIT_TIME_DESC"] = "대기 중인 메시지를 보내기 전 지연 시간(0.1~1초)."
L["AUTO_SYNC"]                   = "자동 동기화 사용"
L["AUTO_SYNC_DESC"]              = "접속 시 길드원과 자동으로 동기화합니다."
L["SHOW_WHISPERS"]               = "채팅에 귓속말 표시"
L["SHOW_WHISPERS_DESC"]          = [[
초대 시 플레이어에게 보내는 메시지를 표시합니다.

참고: 이 설정 변경 후 /rl이 필요합니다.]]
L["GEN_CONTEXT"]                 = "채팅에서 우클릭 초대 활성화"
L["GEN_CONTEXT_DESC"]            = "채팅의 이름을 우클릭하면 Guild Recruiter 컨텍스트 메뉴를 표시합니다."
L["COMPACT_SIZE"]                = "컴팩트 크기"
L["SCAN_WAIT_TIME"]              = "스캔 대기 시간(초)"
L["SCAN_WAIT_TIME_DESC"]         = [[
플레이어를 검색하기 전 대기 시간(2~10초).

참고: 5~6초를 권장합니다.]]
L["KEYBINDING_HEADER"]           = "단축키"
L["KEYBINDING_INVITE"]           = "초대 단축키"
L["KEYBINDING_INVITE_DESC"]      = "플레이어를 길드에 초대하는 단축키."
L["KEYBINDING_SCAN"]             = "스캔 단축키"
L["KEYBINDING_SCAN_DESC"]        = "길드를 찾는 플레이어를 검색하는 단축키."
L["KEY_BINDING_NOTE"]            = "참고: 단축키는 WoW 키보드 설정에 영향을 주지 않습니다."
--#endregion

--#region GM Invite Settings
L["GM_INVITE_SETTINGS"]               = "GM 설정"
L["FORCE_OPTION"]                     = "GM이 아닌 사용자도 사용 강제"
L["ENABLE_BLOCK_INVITE_CHECK"]        = "초대 차단 여부 확인 사용"
L["ENABLE_BLOCK_INVITE_CHECK_TOOLTIP"]= "초대 대상이 길드 초대를 차단했는지 확인하려고 시도합니다."
L["ENABLE_ANTI_SPAM_DESC"]            = "스팸 방지 기능을 활성화하여 스팸을 예방합니다."
L["ANTI_SPAM_DAYS"]                   = "재초대 지연"
L["ANTI_SPAM_DAYS_DESC"]              = "다시 초대하기까지의 일수."
L["GUILD_WELCOME_MSG"]                = "길드 채팅 환영 메시지"
L["GUILD_WELCOME_MSG_DESC"]           = "새 플레이어가 가입하면 길드 채팅에 보내는 메시지."
L["WHISPER_WELCOME_MSG"]              = "귓속말 환영 메시지"
L["WHISPER_WELCOME_MSG_DESC"]         = "플레이어가 가입하면 해당 플레이어에게 보내는 귓속말."
--#endregion

--#region GM Invite Messages
L["GM_INVITE_MESSAGES"]         = "GM 메시지"
L["PLAYER_SETTINGS_DESC"]       = "주황색 메시지는 GM이 작성한 것입니다."
L["INVITE_ACTIVE_MESSAGE"]      = "초대 메시지:"
L["INVITE_ACTIVE_MESSAGE_DESC"] = [[
잠재적 지원자에게 보내는 메시지입니다.

참고: 동기화 후 변경 사항을 보려면 /rl이 필요할 수 있습니다.]]
L["NEW_MESSAGE_DESC"]           = "초대 목록에 메시지 설명을 추가합니다."
L["INVITE_DESC"]                = "초대 메시지 설명:"
L["INVITE_DESC_TOOLTIP"]        = "초대 메시지에 대한 설명입니다."
L["SYNC_MESSAGES"]              = "이 메시지 동기화"
L["SYNC_MESSAGES_DESC"]         = "이 메시지를 길드와 동기화합니다."
--#endregion

--#region Player Invite Settings
L["INVITE_SETTINGS"] = "초대 설정"
L["INVITE_MESSAGES"] = "초대 메시지"
--#endregion

--#region Blacklist
L["BLACKLIST_REMOVE"]         = "선택한 블랙리스트 항목 제거"
L["ADD_TO_BLACKLIST"]         = "플레이어를 블랙리스트에 추가합니다."
L["BL_PRIVATE_REASON"]        = "비공개 사유 전환"
L["BL_PRIVATE_REASON_DESC"]   = "블랙리스트 비공개 사유를 전환합니다."
L["BL_PRIVATE_REASON_ERROR"]  = "아무도 블랙리스트에 등록하지 않았습니다"
L["NO_REASON_GIVEN"]          = "사유 없음"
L["ADDED_TO_BLACK_LIST"]      = "%s 사유로 블랙리스트에 추가되었습니다."
L["BL_NAME_NOT_ADDED"]        = "블랙리스트에 추가되지 않았습니다."
L["IS_ON_BLACK_LIST"]         = "이미 블랙리스트에 있습니다."
L["BLACK_LIST_REASON_INPUT"]  = "%s을(를) 블랙리스트에 올리는 사유를 입력하세요."
L["BLACKLIST_NAME_PROMPT"] = [[
블랙리스트에 올릴 플레이어의 이름을 입력하세요.

다른 서버의 경우 -와 서버명을 추가하세요.
(플레이어이름-서버이름)
]]
--#endregion

--#region Invalid Zones
L["INVALID_ZONE"]        = "잘못된 지역"
L["ZONE_NOT_FOUND"]      = "지역을 찾을 수 없습니다"
L["ZONE_INSTRUCTIONS"]   = "지역 이름은 게임 내 지역 이름과 정확히 일치해야 합니다."
L["ZONE_ID"]             = "지역 ID(숫자 ID)"
L["ZONE_NAME"]           = "지역 이름:"
L["ZONE_INVALID_REASON"] = "잘못된 이유:"
L["ZONE_ID_DESC"] = [[
잘못된 지역의 지역 ID입니다.
인스턴스 목록:
https://wowpedia.fandom.com/wiki/InstanceID
알려진 월드 지역 ID:
https://wowpedia.fandom.com/wiki/UiMapID
추가해야 할 지역을 발견하면 알려주세요.]]
L["ZONE_NOTE"]           = "|cFF00FF00*|r 표시된 지역만 편집할 수 있습니다."
L["ZONE_LIST_NAME"]      = "스캐너가 다음 지역을 무시합니다:"
--#endregion

--#region Analytics
L["ANALYTICS"]                      = "분석"
L["ANALYTICS_DESC"]                 = "길드 초대 관련 통계를 확인하세요."
L["ANALYTICS_BLACKLISTED"]          = "블랙리스트에 올린 플레이어"
L["ANALYTICS_SCANNED"]              = "총 스캔한 플레이어 수"
L["ANALYTICS_INVITED"]              = "길드에 초대한 플레이어"
L["ANALYTICS_DECLINED"]             = "초대를 거절한 플레이어"
L["ANALYTICS_ACCEPTED"]             = "초대를 수락한 플레이어"
L["ANALYTICS_NO_GUILD"]             = "길드가 없는 것으로 확인된 플레이어"
L["ANALYTICS_STATS_START"]          = "통계 시작일"
L["ANALYTICS_SESSION"]              = "세션"
L["ANALYTICS_SESSION_SCANNED"]      = "스캔"
L["ANALYTICS_SESSION_BLACKLISTED"]  = "블랙리스트"
L["ANALYTICS_SESSION_INVITED"]      = "초대"
L["ANALYTICS_SESSION_DECLINED"]     = "거절"
L["ANALYTICS_SESSION_ACCEPTED"]     = "수락"
L["ANALYTICS_SESSION_WAITING"]      = "대기 중"
L["ANALYTICS_SESSION_TIMED_OUT"]    = "초대 시간 초과"
L["ANALYTICS_SESSION_NO_GUILD"]     = "잠재 대상 발견"
L["ANALYTICS_SESSION_STARTED"]      = "세션 시작됨"
L["LAST_SCAN"]                      = "마지막으로 스캔한 플레이어"

L["GUILD_ANALYTICS"]   = "길드 분석"
L["PROFILE_ANALYTICS"] = "프로필 분석"
L["SESSION_ANALYTICS"] = "세션 분석"
--#endregion

--#region Sync
L["SYNC_ALREADY_IN_PROGRESS"]      = "동기화가 이미 진행 중입니다"
L["SYNC_FAIL_TIMER"]               = "동기화가 만료되었습니다. 다시 시도하세요."
-- Server
L["AUTO_SYNC_STARTED"]             = "길드와 자동 동기화를 시작했습니다."
L["MANUAL_SYNC_STARTED"]           = "길드와 동기화를 시작했습니다."
L["SYNC_CLIENTS_FOUND"]            = "동기화할 클라이언트 %d개를 찾았습니다."
-- Client
L["SYNC_CLIENT_STARTED"]           = "Guild Recruiter 동기화를 요청했습니다."
-- Either
L["SYNC_SETTINGS_FAILED"]          = "보낼 설정을 준비하지 못했습니다."

-- Errors
L["DATA_WAIT_TIMEOUT"]             = "클라이언트로부터 데이터를 받지 못했습니다."
L["REQUEST_WAIT_TIMEOUT"]          = "서버의 응답을 받지 못했습니다."
L["NO_CLIENTS_FOUND_TO_SYNC_WITH"] = "동기화할 클라이언트를 찾지 못했습니다."

-- Sync Messages
L["AUTO_SYNC"]     = "자동 동기화"
L["MANUAL_SYNC"]   = "수동 동기화"
L["CLIENT_SYNC"]   = "클라이언트 동기화"
L["SYNC_FINISHED"] = "이(가) 완료되었습니다."
-- End of Sync Messages

L["SETTINGS_CHANGED"]      = "설정이 업데이트되었습니다."
L["MESSAGE_LIST_CHANGED"]  = "메시지 목록이 업데이트되었습니다."
L["BLACKLIST_CHANGED"]     = "블랙리스트가 %d개 항목으로 업데이트되었습니다."
L["ANTISPAM_CHANGED"]      = "스팸 방지 목록이 %d개 항목으로 업데이트되었습니다."