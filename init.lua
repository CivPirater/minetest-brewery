local timer = 0
local minutes = 15;

print("Brewery Mod Alpha")

minetest.register_node("brewery:barrel", {
    description = "Barrel",
    tiles = {
        "barrel2.png",
        "barrel1.png",
        "barrel1.png",
        "barrel1.png",
        "barrel1.png",
        "barrel1.png"
    },
    groups = { choppy=3 },
    
    --Creates an inventory for the barrel.
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", [[
          size[8,9]
          list[context;main;2.5,1;3,3;]
          list[current_player;main;0,5;8,4;]"
          ]])
        local inv = meta:get_inventory()
        inv:set_size("main", 32)
    end,

})

--minetest.chat_send_all("brewery")

minetest.register_craft({
    type = "shaped",
    output = "brewery:barrel",
    recipe = {
        {"stairs:stair_wood", "default:wood", "stairs:stair_wood"},
        {"stairs:stair_wood", "default:wood", "stairs:stair_wood"},
        {"stairs:stair_wood", "default:wood", "stairs:stair_wood"}
    }
})

--drink template
minetest.register_craftitem("brewery:vodka", {
    age = 0,
    maximumAge = 10,
    description = "Vodka",
    inventory_image = "vodka.png",
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_all("drank a vodka!")
        minetest.do_item_eat(20, nil, ...)
        return itemstack,
    end,
})

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= (60*minutes) then
		--add to age here, age+=1
		timer = 0
	end
end)
