local moddata = {
    days_offset = 0
}
local storage = minetest.get_mod_storage("solarphases")

local function save()
    storage:set_float("days_offset", moddata.days_offset)
end

local function load()
    if storage:contains("days_offset") then
        moddata.days_offset = storage:get_float("days_offset")
    end
end

local function update_solar(player)
    local pos = player:get_pos()
    local x = pos.x
    local z = pos.z
    local time_of_day = minetest.get_timeofday()
    local day = moddata.days_offset + minetest.get_day_count() + time_of_day
    local season = day / 30
    -- at z = +-31k, it's north/south pole, where sun height doesn't change over the day
    local mag = 3 - math.abs(z) / 31000 * 3
    local base = 0.75 + 1.5 * z / 31000 * math.sin(season * 2 * math.pi)
    -- true noon => 1h earlier to 1h later
    local time_offset = (1 / 24) * x / 31000

    local ratio = base
        + mag * math.sin((time_of_day - 0.25 + time_offset) * math.pi * 2)

    player:override_day_night_ratio(
        math.max(0, math.min(1, ratio))
    )
end

minetest.register_on_joinplayer(function(player, last_login)
    player:set_sun({
        visible = false,
        sunrise_visible = false
    })
    player:set_moon({
        visible = false
    })
    player:set_stars({
        visible = false
    })
    update_solar(player)
    minetest.register_globalstep(function(dtime)
        update_solar(player)
    end)
end)

minetest.register_chatcommand("setdays", {
    description = [[Allows setting the time and the day of the world as a float

Format: <day>.<time_of_day>]],
    params = "[days] (float)",
    privs = {settime = true},
    func = function (name, param)
        if param == nil then
            return false
        end
        local days = tonumber(param)
        if days == nil then
            return false
        end

        minetest.set_timeofday(days % 1.0)
        moddata.days_offset = math.floor(days) - minetest.get_day_count()
        save()
        return true, "time set"
    end
})

load()