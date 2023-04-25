local function update_solar(player)
    local x = player:get_pos().x
    local z = player:get_pos().z
    local day = minetest.get_day_count() + minetest.get_timeofday()
    local season = day / 30
    -- at z = +-31k, it's north/south pole, where sun height doesn't change over the day
    local mag = 3 - math.abs(z) / 31000 * 3
    local base = 0.75 + 1.5 * z / 31000 * math.sin(season * 2 * math.pi)
    -- true noon => 1h earlier to 1h later
    local time_offset = (1 / 24) * x / 31000

    local ratio = base
        + mag * math.sin((minetest.get_timeofday() - 0.25 + time_offset) * math.pi * 2)

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