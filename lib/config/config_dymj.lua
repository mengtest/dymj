
local config = {}

config.server = {
    {
        serverid = 1,
        servername = "server01",
    },
}

config.gate = {
    ip = "dyserver.dyzx7.cn",
    port = 9888,
    maxclient = 65535,
    servername = "gate01",
}

-- config.redis = {
--     host = "127.0.0.1",
--     port = 6379,
--     base = 10,
--     name = {
--     },
-- }

config.mongo = {
    info = {
        host = "10.66.250.39",
        username = "mongouser",
        password = "2TGpxZzw4JEEhbG",
    },
    name = {
	    "account",
        "user",
        "info",
        "offline",
        "status",
        "register",
        "user_record",
        "record_info",
        "record_detail",
        "iap_log",
        "charge_log",
        "invite_info",
        "invite_user_detail",
        "club",
    },
    index = {
        {"account", {"key", unique=true}},
        {"user", {"id", unique=true}},
        {"info", {"id", unique=true}},
        {"offline", {"id", unique=true}},
        {"status", {"key", unique=true}},
        {"user_record", {"id", unique=true}},
        {"record_info", {"id", unique=true}},
        {"record_info", {"clubid"}},
        {"record_info", {"expire", expireAfterSeconds=7*24*60*60}},
        {"record_detail", {"id", unique=true}},
        {"record_detail", {"expire", expireAfterSeconds=8*24*60*60}},
        {"iap_log", {"transaction_id", unique=true}},
        {"charge_log", {"id", unique=true}},
        {"invite_info", {"id", unique=true}},
        {"invite_user_detail", {"id", unique=true}},
        {"invite_user_detail", {"belong_id"}},
        {"club", {"id", unique=true}},
    },
}

return config
