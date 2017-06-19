
local config = {}

config.server = {
    {
        serverid = 1,
        servername = "server01",
    },
}

config.gate = {
    ip = "192.168.2.100",
    -- ip = "192.168.1.202",
    port = 8888,
    maxclient = 65535,
    servername = "gate01",
}

config.redis = {
    host = "127.0.0.1",
    port = 6379,
    base = 0,
    name = {
    },
}

config.mongo = {
    host = "127.0.0.1",
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
    },
    index = {
        {"account", {"key", unique=true}},
        {"user", {"id", unique=true}},
        {"info", {"id", unique=true}},
        {"offline", {"id", unique=true}},
        {"status", {"key", unique=true}},
        {"user_record", {"id", unique=true}},
        {"record_info", {"id", unique=true}},
        {"record_info", {"time", expireAfterSeconds=60}},
        {"record_detail", {"id", unique=true}},
        {"record_detail", {"time", expireAfterSeconds=60}},
    },
}

return config
