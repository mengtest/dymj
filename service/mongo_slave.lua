local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local util = require "util"

local assert = assert

local database = skynet.getenv("database")

local CMD = {}

local db

function CMD.open(conf, name)
    local d = mongo.client({host=conf.host})
    util.cmd_wrap(CMD, d[database][name])
    db = d[database][name]
end

function CMD.get()
    util.dump(db)
    local cursor = db:find()
    util.dump(cursor)
    while cursor:hasNext() do
        local r = cursor:next()
        util.dump(r)
    end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
        if session == 0 then
            f(...)
        else
            skynet.retpack(f(...))
        end
	end)
end)
