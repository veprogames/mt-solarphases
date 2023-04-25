local function update_solar(player)
    local z = player:get_pos().z
    local day = minetest.get_day_count() + minetest.get_timeofday()
    local season = day / 30
    local mag = 3 - math.abs(z) / 31000 * 2
    local base = 0.75 + 1.5 * z / 31000 * math.sin(season * 2 * math.pi)

    local ratio = base
        + mag * math.sin((minetest.get_timeofday() - 0.25) * math.pi * 2)
    print(day, " ", ratio)

    player:override_day_night_ratio(
        math.max(0, math.min(1, ratio))
    )
    minetest.after(0.5, function ()
        update_solar(player)
    end)
end

minetest.register_on_joinplayer(function(player, last_login)
    player:set_sun({
        visible = false
    })
    player:set_moon({
        visible = false
    })
    player:set_stars({
        visible = false
    })
    update_solar(player)
    minetest.after(1, function ()
        update_solar(player)
    end)
end)