local skynet = require "skynet"
local util = require "util"
local timer = require "timer"
local func = require "func"
local sharedata = require "skynet.sharedata"
local queue = require "skynet.queue"

local assert = assert
local pairs = pairs

local error_code
local base

local club_db
local club
local club_role
local role_mgr
local room_list = {}
local role_room = {}
local role_room = {{}, {}}
local cs = queue() 

local function save()
    skynet.call(club_db, "lua", "update", {id=club.id}, club, true)
end

local function delay_save()
    timer.del_once_routine("delay_save_club")
    time.add_routine("save_club", save, 300)
end

local function del_timer()
    timer.del_once_routine("delay_save_club")
    timer.del_routine("save_club")
end

local CMD = {}
util.timer_wrap(CMD)

function CMD.exit()
	skynet.exit()
end

function CMD.open(info, delay)
    club = info
    time.add_once_routine("delay_save_club", delay_save, delay)
end

function CMD.leave(roleid)
    if club then
        local m = club.member[roleid]
        if m and m.pos ~= base.CLUB_POS_CHIEF then
            club.member[roleid] = nil
            club.member_count = club.member_count - 1
            if club.online then
                club.online_count = club.online_count - 1
            end
        else
            skynet.error(string.format("Role %d leave club %d error.", roleid, club.id))
        end
    else
        skynet.error(string.format("Role %d leave club error.", roleid))
    end
end

function CMD.disband(roleid)
    if club then
        local m = club.member[roleid]
        if m and m.pos == base.CLUB_POS_CHIEF then
            for k, v in pairs(club.member) do
                if v.id ~= roleid then
                    local agent = skynet.call(role_mgr, "lua", "get", v.id)
                    if agent then
                        skynet.call(agent, "action", "club", "leave", club.id)
                    else
                        skynet.call(club_role, "del", roleid, club.id)
                    end
                end
            end
            local room_card = club.room_card
            club = nil
            del_timer()
            skynet.call(club_db, "lua", "delete", {id=club.id})
            return room_card
        else
            skynet.error(string.format("Role %d disband club %d error.", roleid, club.id))
        end
    else
        skynet.error(string.format("Role %d disband club error.", roleid))
    end
end

function CMD.charge(roleid, room_card)
    if club then
        local m = club.member[roleid]
        if m and m.pos == base.CLUB_POS_CHIEF then
            club.room_card = club.room_card + room_card
            return club.room_card
        else
            skynet.error(string.format("Role %d charge club %d, room_card %d error.", roleid, club.id, room_card))
        end
    else
        skynet.error(string.format("Role %d charge club, room_card %d error.", roleid, room_card))
    end
end

function CMD.config(roleid, config)
    if club then
        local m = club.member[roleid]
        if m and m.pos == base.CLUB_POS_CHIEF then
            club.name = config.name
            club.day_card = config.day_card
            club.notify_card = config.notify_card
            -- TODO: notify member
        else
            skynet.error(string.format("Role %d change club %d name %d error.", roleid, club.id, name))
        end
    else
        skynet.error(string.format("Role %d change club name %d error.", roleid, name))
    end
end

function CMD.get_room_card()
    if club then
        return club.room_card
    else
        skynet.error("Get club room card error.")
    end
end

function CMD.consume_card(room_card)
    if club then
        club.room_card = club.room_card - room_card
    else
        skynet.error("Consume club room card error.") 
    end
end

function CMD.add_room(room)
    local number = room.number
    if room_list[number] then
        skynet.error(string.format("Add room %d error.", number))
    else
        room.role = {}
        room.enter_user = 0
        room_list[number] = room
        role_room[number] = room
    end
end

function CMD.del_room(number)
    if room_list[number] then
        room_list[number] = nil
        role_room[number] = nil
    else
        skynet.error(string.format("Del room %d error.", number))
    end
end

function CMD.enter_room(number, info)
    local room = room_list[number]
    if room then
        room.role[info.id] = info
        room.enter_user = room.enter_user + 1
        if room.enter_user >= room.user then
            role_room[number] = nil
        end
    else
        skynet.error(string.format("Role %d enter room %d error.", info.id, number))
    end
end

function CMD.leave_room(number, roleid)
    local room = room_list[number]
    if room then
        room.role[roleid] = nil
        room.enter_user = room.enter_user - 1
        role_room[number] = room
    else
        skynet.error(string.format("Role %d leave room %d error.", roleid, number))
    end
end

function CMD.get_info()
    return {
        id = club.id,
        name = club.name,
        chief_id = club.chief_id,
        chief = club.chief,
        member_count = club.member_count,
    }
end

function CMD.save()
    save()
end

function CMD.shutdown()
    del_timer()
    save()
end

function CMD.login(roleid)
    if club then
        local m = club.member[roleid]
        if m then
            return {
                id = club.id,
                name = club.name,
                chief_id = club.chief_id,
                chief = club.chief,
                pos = m.pos,
                addr = skynet.self(),
            }
        end
    end
end

function CMD.online(roleid, online)
    if club then
        local m = club.member[roleid]
        if m and m.online ~= online then
            m.online = online
            if online then
                club.online_count = club.online_count + 1
            else
                club.online_count = club.online_count - 1
            end
        end
    end
end

local MSG = {}

function MSG.apply(info)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    if club.member[info.id] then
        error{code = error_code.ALREADY_IN_CLUB}
    end
    if club.apply[info.id] then
        error{code = error_code.ALREADY_APPLY_CLUB}
    end
    club.apply[info.id] = info
    return "response", ""
end

function MSG.accept(adminid, roleid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    if admin.pos < base.CLUB_POS_ADMIN then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    if club.member[roleid] then
        error{code = error_code.ALREADY_IN_CLUB}
    end
    local a = club.apply[roleid]
    if not a then
        error{code = error_code.NOT_APPLY_CLUB}
    end
    local role = skynet.call(role_mgr, "lua", "get", roleid)
    if role then
        local info = {
            id = club.id,
            name = club.name,
            chief_id = club.chief_id,
            chief = club.chief,
            pos = base.CLUB_POS_NONE,
            addr = skynet.self(),
        }
        if skynet.call(role, "lua", "action", "club", "join", info) then
            a.time = floor(skynet.time())
            a.pos = base.CLUB_POS_NONE
            a.online = true
            club.member[roleid] = a
            club.member_count = club.member_count + 1
            club.online_count = club.online_count + 1
            club.apply[roleid] = nil
            return "update_club_apply", {id=club.id, apply={id=roleid, del=true}}
        else
            error{code = error_code.CLUB_LIMIT}
        end
    else
        if skynet.call(club_role, "lua", "count", roleid) >= base.MAX_CLUB then
            error{code = error_code.CLUB_LIMIT}
        else
            skynet.call(club_role, "lua", "add", roleid, club.id, skynet.self())
            a.time = floor(skynet.time())
            a.pos = base.CLUB_POS_NONE
            a.online = false
            club.member[roleid] = a
            club.member_count = club.member_count + 1
            club.apply[roleid] = nil
            return "update_club_apply", {id=club.id, apply={id=roleid, del=true}}
        end
    end
end

function MSG.accept_all(adminid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    if admin.pos < base.CLUB_POS_ADMIN then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    local member = club.member
    local m = {}
    local now = floor(skynet.time())
    for k, v in pairs(club.apply) do
        if not member[v.id] then
            local role = skynet.call(role_mgr, "lua", "get", v.id)
            if role then
                local info = {
                    id = club.id,
                    name = club.name,
                    chief_id = club.chief_id,
                    chief = club.chief,
                    pos = base.CLUB_POS_NONE,
                    addr = skynet.self(),
                }
                if skynet.call(role, "lua", "action", "club", "join", info) then
                    v.time = now
                    v.pos = base.CLUB_POS_NONE
                    v.online = true
                    member[v.id] = v
                    club.member_count = club.member_count + 1
                    club.online_count = club.online_count + 1
                    m[#m+1] = v
                end
            else
                if skynet.call(club_role, "lua", "count", v.id) < base.MAX_CLUB then
                    skynet.call(club_role, "lua", "add", v.id, club.id, skynet.self())
                    v.time = now
                    v.pos = base.CLUB_POS_NONE
                    v.online = false
                    member[v.id] = v
                    club.member_count = club.member_count + 1
                    m[#m+1] = v
                end
            end
        end
    end
    club.apply = {}
    return "club_apply_list", {id=club.id}
end

function MSG.refuse(adminid, roleid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    if admin.pos < base.CLUB_POS_ADMIN then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    if not club.apply[roleid] then
        error{code = error_code.NOT_APPLY_CLUB}
    end
    club.apply[roleid] = nil
    return "update_club_apply", {id=club.id, apply={id=roleid, del=true}}
end

function MSG.refuse_all(adminid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    if admin.pos < base.CLUB_POS_ADMIN then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    club.apply = {}
    return "club_apply_list", {id=club.id}
end

function MSG.query_apply(adminid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    if admin.pos < base.CLUB_POS_ADMIN then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    local a = {}
    for k, v in pairs(club.apply) do
        a[#a+1] = v
    end
    return "club_apply_list", {id=club.id, list=a}
end

function MSG.query_member(adminid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    local m = {}
    for k, v in pairs(club.member) do
        m[#m+1] = v
    end
    return "club_member_list", {id=club.id, list=m}
end

function MSG.remove_member(adminid, roleid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    local role = club.member[roleid]
    if not role then
        error{code = error_code.TARGET_NOT_IN_CLUB}
    end
    if admin.pos <= role.pos then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    local agent = skynet.call(role_mgr, "lua", "get", roleid)
    if agent then
        skynet.call(agent, "action", "club", "leave", club.id)
    else
        skynet.call(club_role, "del", roleid, club.id)
    end
    club.member[roleid] = nil
    club.member_count = club.member_count - 1
    if role.online then
        club.online_count = club.online_count - 1
    end
    return "update_club_member", {id=club.id, member={id=roleid, del=true}}
end

function MSG.promote(adminid, roleid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    if admin.pos ~= base.CLUB_POS_CHIEF then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    local role = club.member[roleid]
    if not role then
        error{code = error_code.TARGET_NOT_IN_CLUB}
    end
    if role.pos == base.CLUB_POS_ADMIN then
        error{code = error_code.ALREADY_CLUB_ADMIN}
    end
    local agent = skynet.call(role_mgr, "lua", "get", roleid)
    if agent then
        skynet.call(agent, "lua", "promote", club.id)
    end
    role.pos = base.CLUB_POS_ADMIN
    return "update_club_member", {id=club.id, member={id=roleid, pos=role.pos}}
end

function MSG.demote(adminid, roleid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local admin = club.member[adminid]
    if not admin then
        error{code = error_code.NOT_IN_CLUB}
    end
    if admin.pos ~= base.CLUB_POS_CHIEF then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    local role = club.member[roleid]
    if not role then
        error{code = error_code.TARGET_NOT_IN_CLUB}
    end
    if role.pos == base.CLUB_POS_NONE then
        error{code = error_code.NOT_CLUB_ADMIN}
    end
    local agent = skynet.call(role_mgr, "lua", "get", roleid)
    if agent then
        skynet.call(agent, "lua", "demote", club.id)
    end
    role.pos = base.CLUB_POS_NONE
    return "update_club_member", {id=club.id, member={id=roleid, pos=role.pos}}
end

function MSG.query_room(roleid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local role = club.member[roleid]
    if not role then
        error{code = error_code.NOT_IN_CLUB}
    end
    local room = {}
    for k, v in pairs(role_room) do
        local info = {
            name = v.name,
            number = v.number,
            rule = v.rule,
        }
        local u = {}
        for k1, v1 in pairs(v.role) do
            u[#u+1] = v1
        end
        info.role = u
        room[#room+1] = info
    end
    return "room_list", {
        id = club.id, 
        room = room,
    }
end

function MSG.query_all(roleid)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local role = club.member[roleid]
    if not role then
        error{code = error_code.NOT_IN_CLUB}
    end
    local room = {}
    for k, v in pairs(role_room) do
        local info = {
            name = v.name,
            number = v.number,
            rule = v.rule,
        }
        local u = {}
        for k1, v1 in pairs(v.role) do
            u[#u+1] = v1
        end
        info.role = u
        room[#room+1] = info
    end
    return "club_all", {
        id = club.id, 
        name = club.name,
        chief_id = club.chief_id,
        chief = club.chief,
        time = club.time,
        quick_game = club.quick_game,
        quick_rule = club.quick_rule,
        member_count = club.member_count, 
        online_count = club.online_count,
        room_card = club.room_card,
        room = room,
    }
end

function MSG.config_quick_start(roleid, game, rule)
    if not club then
        error{code = error_code.NO_CLUB}
    end
    local role = club.member(roleid)
    if not role then
        error{code = error_code.NOT_IN_CLUB}
    end
    if role.pos < base.CLUB_POS_ADMIN then
        error{code = error_code.CLUB_PERMIT_LIMIT}
    end
    club.quick_game = game
    club.quick_rule = rule
    return "club_all", {id=club.id, quick_game=club.quick_game, quick_rule=club.quick_rule}
end

for k, v in pairs(MSG) do
    CMD[k] = function(...)
        return func.return_msg(pcall(v, ...))
    end
end

skynet.start(function()
    error_code = sharedata.query("error_code")
    base = sharedata.query("base")

    local master = skynet.queryservice("mongo_master")
    club_db = skynet.call(master, "lua", "get", "club")
    club_role = skynet.queryservice("club_role")
    role_mgr = skynet.queryservice("role_mgr")

	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
        if session == 0 then
            cs(f, ...)
        else
            skynet.retpack(cs(f, ...))
        end
	end)
end)
