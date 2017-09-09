
local string = string

local function jdmj(rule)
    local r = {pack=rule}
    local p, c = string.unpack("BB", rule)
    if p == 1 then
        r.aa_pay = true
    else
        r.aa_pay = false
    end
    if c == 1 then
        r.total_count, r.total_card, r.single_card = 10, 4, 1
    else
        r.total_count, r.total_card, r.single_card = 20, 8, 2
    end
    return r
end

local function dymj(rule)
    local r = {pack=rule}
    local p, c = string.unpack("BB", rule)
    if p == 1 then
        r.aa_pay = true
    else
        r.aa_pay = false
    end
    if c == 1 then
        r.total_count, r.total_card, r.single_card = 8, 4, 1
    else
        r.total_count, r.total_card, r.single_card = 16, 8, 2
    end
    return r
end

local function jd13(rule)
    local r = {pack=rule}
    local p, c, n = string.unpack("BBB", rule)
    if p == 1 then
        r.aa_pay = true
    else
        r.aa_pay = false
    end
    if n == 1 then
        r.user = 4
    elseif n == 2 then
        r.user = 3
    else
        r.user = 2
    end
    if c == 1 then
        r.total_count, r.total_card, r.single_card = 10, r.user, 1
    else
        r.total_count, r.total_card, r.single_card = 20, 2*r.user, 2
    end
    return r
end

local option = {
    dymj = dymj,
    test_dymj = dymj,
    jdmj = jdmj,
    test_jdmj = jdmj,
    jd13 = jd13,
}

return option