
local base = {	
    LOGIN_PASSWORD = 1,
    LOGIN_PASSER = 2,
	LOGIN_WEIXIN = 3,

    MJ_FOUR = 4,
    MJ_ROLE_CARD = 13,
    MJ_CARD_INDEX = 45,
    MJ_CHI_COUNT = 2,
    JDMJ_ROLE_CARD = 16,
    POKER_CARD = 52,
    POKER_VALUE = 13,
    POKER_COLOR = 4,
    P13_FOUR = 4,
    P13_ROLE_CARD = 13,
    P13_COLOR = 4,
    PBJ_ROLE_CARD = 9,
    PBJ_FIVE = 5,

    PBJ_SIX = 6,
    POKER_CARD_FULL = 54,
    PBJ_WILDCARD_RATE = 100,

    MJ_OP_CHI = 1,
    MJ_OP_PENG = 2,
    MJ_OP_GANG = 3,
    MJ_OP_PASS = 4,
    MJ_OP_HIDE_GANG = 5,
    MJ_OP_HU = 6,
    MJ_OP_LEAVE = 7,
    MJ_OP_COUNT = 7,

    CHESS_STATUS_READY = 1,
    CHESS_STATUS_DEAL = 2,
    CHESS_STATUS_START = 3,
    CHESS_STATUS_FINISH = 4,
    CHESS_STATUS_EXIT = 5,

    USER_STATUS_ONLINE = 0,
    USER_STATUS_LOST = 1,
    USER_STATUS_LOGOUT = 2,
    
    HU_NONE = 1,
    HU_DUIZI = 2,
    HU_BAOTOU = 3,
    HU_GANGBAO = 4,
    HU_GANGKAI = 5,
    HU_QINGFENGZI = 6,
    HU_SHISANBUDA = 7,
    HU_QINGYISE = 8,
    HU_QIANGGANG = 9,
    
    PASS_STATUS_DEAL = 1,
    PASS_STATUS_OUT = 2,
    PASS_STATUS_GANG_HU = 3,
    PASS_STATUS_WEAVE = 4,

    P13_OP_LEAVE = 1,

    P13_TYPE_NONE = 0,
    P13_TYPE_DUIZI = 1,
    P13_TYPE_LIANGDUI = 2,
    P13_TYPE_SANZHANG = 3,
    P13_TYPE_SHUNZI = 4,
    P13_TYPE_TONGHUA = 5,
    P13_TYPE_HULU = 6,
    P13_TYPE_ZHADAN = 7,
    P13_TYPE_TONGHUASHUN = 8,

    P13_SPECIAL_QINGLONG = 1,
    P13_SPECIAL_YITIAOLONG = 2,
    P13_SPECIAL_SANJINTIAO = 3,
    P13_SPECIAL_SANZHADAN = 4,
    P13_SPECIAL_QUANDA = 5,
    P13_SPECIAL_QUANXIAO = 6,
    P13_SPECIAL_QUANHEI = 7,
    P13_SPECIAL_QUANHONG = 8,
    P13_SPECIAL_WUDUIYIKE = 9,
    P13_SPECIAL_LIUDUIBAN = 10,
    P13_SPECIAL_SISANTIAO = 11,
    P13_SPECIAL_SANTONGHUA = 12,
    P13_SPECIAL_SANSHUNZI = 13,

    PBJ_TYPE_NONE = 0,
    PBJ_TYPE_DUIZI = 1,
    PBJ_TYPE_SHUNZI = 2,
    PBJ_TYPE_TONGHUA = 3,
    PBJ_TYPE_TONGHUASHUN = 4,
    PBJ_TYPE_SANTIAO = 5,

    PBJ_SPECIAL_QUANHEI = 1,
    PBJ_SPECIAL_QUANHONG = 2,
    PBJ_SPECIAL_SANSHUNZI = 3,
    PBJ_SPECIAL_SHUANGTONGHUASHUN = 4,
    PBJ_SPECIAL_SHUANGSANTIAO = 5,
    PBJ_SPECIAL_SANQING = 6,
    PBJ_SPECIAL_SANTONGHUASHUN = 7,
    PBJ_SPECIAL_ZHADAN = 8,
    PBJ_SPECIAL_QUANSANTIAO = 9,
    PBJ_SPECIAL_JIULIANSHUN = 10,
    PBJ_SPECIAL_JIULIANTONGHUASHUN = 11,
    PBJ_SPECIAL_SHUANGZHADAN = 12,
}

base.P13_SPECIAL_SCORE = {
    [base.P13_SPECIAL_QINGLONG] = 108,
    [base.P13_SPECIAL_YITIAOLONG] = 26,
    [base.P13_SPECIAL_QUANHEI] = 26,
    [base.P13_SPECIAL_QUANHONG] = 26,
}

base.PBJ_SPECIAL_SCORE = {
    [base.PBJ_SPECIAL_SANTONGHUASHUN] = 8,
    [base.PBJ_SPECIAL_ZHADAN] = 10,
    [base.PBJ_SPECIAL_QUANSANTIAO] = 10,
    [base.PBJ_SPECIAL_JIULIANSHUN] = 15,
    [base.PBJ_SPECIAL_JIULIANTONGHUASHUN] = 20,
    [base.PBJ_SPECIAL_SHUANGZHADAN] = 20,
}

return base
