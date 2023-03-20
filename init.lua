minetest.register_node("poop:poop", {
    description = "Poop",
    tiles = { "poop_poop.png" },
    groups = { oddly_breakable_by_hand = 3 },
    after_dig_node = function(pos, oldnode, oldmetadata, player)
        if not player then return end
        player:punch(player, 0.1, {damage_groups={fleshy=11}})
        local msg = "Poop is toxic. You have to wait for it to dry before you can harvest it without getting hurt."
        minetest.chat_send_player(player:get_player_name(), msg)
    end
})

minetest.register_node("poop:poop_dried", {
    description = "Dried Poop",
    tiles = { "poop_poop_dried.png" },
    groups = { oddly_breakable_by_hand = 1 }
})

minetest.register_abm({
    label = "Toxic poop",
	nodenames = {"poop:poop"},
	interval = 2,
	chance = 3,
	action = function(pos, node)
        for _, obj in pairs(minetest.get_objects_inside_radius(pos, 7)) do
            obj:punch(obj, 0.1, {damage_groups={fleshy=8}})
            if obj:is_player() then
                local msg = "Oh no it looks like someone pooped and it is fresh. If you get too close, it is toxic. Wait for it to dry, then harvest it."
                minetest.chat_send_player(obj:get_player_name(), msg)
            end
        end
	end,
})

minetest.register_abm({
    label = "Dry poop",
	nodenames = {"poop:poop"},
	interval = 93,
	chance = 1,
	action = function(pos, node)
        minetest.swap_node(pos, {name="poop:poop_dried"})
	end,
})

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
    local name = user:get_player_name()
    local msg = "In around 30 seconds you will need to poop. In the meantime, please read this poem ... "
    local poem = [[
        Poop, destruction, diahreah, North and South Korea,
        Exploding POOP POOP,
        murder, violent constipation, bathroom time frustrations,
        Exploding POOP POOP
    ]]
    minetest.chat_send_player(name, msg)
    minetest.chat_send_player(name, poem)
    minetest.after(30, function()
        local pos = user:get_pos()
        local dir = user:get_look_dir()
        local poop_pos = vector.offset(pos, -dir.x*1.4,0,-dir.z*1.4)
        minetest.set_node(poop_pos, {name="poop:poop"})
        local meta = minetest.get_meta(poop_pos)
        meta:set_string("infotext", name.."'s Poop")
        minetest.spawn_falling_node(poop_pos)
        math.randomseed(os.time())
        minetest.sound_play("poop_poop"..tostring(math.floor(math.random(1, 5.5))), {
            object = user,
            gain = 5.0,
            max_hear_distance = 32,
            loop = false,
        }, true)
        minetest.chat_send_player(name, "You just pooped.")
    end)
end)
