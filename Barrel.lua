-- Crafting Mod - Brewing in Minetest
-- Copyright (C) 2020
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

--Barrel is where drinks are aged
--Metadata attributes:
--	sealed_start_date	- the date that the barrel was sealed
-- 						- "" if it isn't sealed
--	contains			- the ammount of drink that the barrel contains
--	capacity			- the capacity of the barrel to hold drinks, should never be 0
--	original_container	- the original container of the drink before it was placed inside the barrel

barrel = brewery.barrel
drink = brewery.drink
utils = brewery.utils

local allowed_inputs_set = {}

local allowed_outputs_set = {}

local allowed_listnames_set = {}
utils.add_to_set(allowed_listnames_set, "input")
utils.add_to_set(allowed_listnames_set, "output")

-- Calculates the difference between dates that the system was sealed
-- Returns: The difference or nil (if it wasn't sealed)
function barrel.time_sealed(start_sealed_time, end_sealed_time)
	assert(start_sealed_time, "Start sealing time can't be null")
	assert(end_sealed_time, "End sealing time can't be null")
	return os.difftime(os.time(end_sealed_time), os.time(start_sealed_time))
end

-- Gets the time that the barrel was sealed on
function barrel.get_sealed_start_time(meta)
	assert(meta, "Meta can't be null")
	return minetest.deserialize(meta:get_string("sealed_start_date"))
end

function barrel.is_sealed(meta)
	assert(meta, "Meta can't be null")
	if (meta:get_string("sealed_start_date") ~= "") then
		return true
	else
		return false
	end
end

function barrel.calculate_filled_percentage(meta)
	assert(meta, "Meta can't be null")
	local max_capacity = meta:get_int("capacity")
	assert(max_capacity ~= 0 or nil, "Max_capacity can't be 0 or nil")
	local contains = meta:get_int("contains")
	if (contains == 0) then
		return 0, max_capacity
	else
		return (contains / max_capacity) * 100, max_capacity
	end
end

--Checks if the barrel is empty
function barrel.is_empty(meta)
	assert(meta, "Meta can't be null")
	if (meta:get_int("contains") == 0) then
		return true
	else
		return false
	end
end

--Checks if the barrel is full
function barrel.is_full(meta)
	assert(meta, "Meta can't be null")
	if meta:get_int("contains") == meta:get_int("capacity") then
		return true
	else
		return false
	end
end

--Calculates the free space in a barrel and returns it
--@returns	- capacity if it's empty
--			- 0 if it's full
--			- the free space inside the barrel
function barrel.capacity_left(meta)
	assert(meta, "Meta can't be null")
	if barrel.is_empty(meta) then
		return meta:get_int("capacity")
	end
	if barrel.is_full(meta) then
		return 0
	end
	return meta:get_int("capacity") - meta:get_int("contains")
end

--Gets the current capacity inside the barrel
--@returns	- 0 if barrel is empty
--			- the current capacity
function barrel.current_quantity(meta)
	assert(meta, "meta can't be null")
	return meta:get_int("contains")
end

--Seals the barrel and starts the aging process
function barrel.seal(meta)
	assert(meta, "Meta can't be null")
	assert(not barrel.is_sealed(meta), "Can't seal a already sealed barrel")
	if (barrel.is_empty(meta)) then
		barrel.generate_formspec(meta, "Can't seal an empty barrel!")
		return false -- Returns false cause it couldn't seal
	end
	meta:set_string("sealed_start_date", minetest.serialize(utils.get_current_time()))
	barrel.generate_formspec(meta)
	return true -- Returns true cause it sealed it
end

--Unseals the barrel and allows the user to retrieve drinks
function barrel.unseal(meta)
	assert(meta, "Meta can't be null")
	assert(barrel.is_sealed(meta), "Can't unseal a unsealed barrel")
	--TODO: finish this
end

function barrel.generate_formspec(meta, warning)
	assert(meta, "Meta can't be null")
	if (not warning) then
		warning = ""
	end
	local inv = meta:get_inventory()
	inv:set_size("input", 1)
	inv:set_size("output", 1)
	local seal_btn
	local percentage_lbl = barrel.calculate_filled_percentage(meta)
	local sealed_str = ""
	local unsealed_str = ""
	if (barrel.is_sealed(meta)) then
		local seal_start_date = barrel.get_sealed_start_time(meta)
		local sealed_duration = math.floor(barrel.time_sealed(seal_start_date, utils.get_current_time()) / 60)
		seal_btn = "button[2,0;1.5,1;unseal;Unseal Barrel]"
		local seal_start_date_str = os.date("%x %H:%M", os.time(seal_start_date))
		sealed_str =
			table.concat(
			{
				seal_btn,
				"label[4,0.5;Barrel Sealed On: ",
				seal_start_date_str,
				"]",
				"label[4,1;Barrel has been sealed for: ",
				sealed_duration,
				" minutes]"
			}
		)
	else -- it's unsealed
		seal_btn = "button[2,0;1.5,1;seal;Seal Barrel]"
		unsealed_str =
			table.concat(
			{
				"list[context;input;0.525,0;1,1;]",
				"list[context;output;1.3,1.4;1,1;]",
				"listring[current_player;main]",
				"listring[context;input]"
			}
		)
	end
	local string =
		table.concat(
		{
			"size[8,7]",
			sfinv.get_inventory_area_formspec(3),
			"image[0,0;2.36,3;brewery_barrel_gui.png^[opacity:127.5]",
			unsealed_str,
			sealed_str,
			seal_btn,
			"label[4,0;Percentage Filled: ",
			percentage_lbl,
			"%]",
			"label[4,2;",
			minetest.colorize("#ff0000", warning),
			"]"
		}
	)
	meta:set_string("formspec", string)
end

--Gets called when players press buttons
function barrel.receive_fields(fields, meta)
	-- God this is an ungodly mess
	if (barrel.is_sealed(meta)) then
		if (fields.unseal) then
			barrel.unseal(meta)
		end
	else
		if (fields.seal) then
			barrel.seal(meta)
		end
	end
end

--Checks if the user can remove the barrel from it's place
function barrel.can_dig(pos, player)
	assert(pos, "Pos can't be null")
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if player then
		if not barrel.is_empty(meta) then
			minetest.chat_send_player(player:get_player_name(), "Can't break non-empty barrel")
			return false
		elseif not inv:is_empty("input") or not inv:is_empty("output") then
			minetest.chat_send_player(
				player:get_player_name(),
				"Can't break barrel when there are items on input/output"
			)
			return false
		end
	end
	return barrel.is_empty(meta) and inv:is_empty("input") and inv:is_empty("output")
end

--Checks if the user is allowed to place an item in the input/output of the barrel
--@returns	- the amount that he can input
--			- 0 if he can't
function barrel.can_put_item_in(pos, listname, stack)
	assert(pos, "Pos can't be null")
	assert(listname, "listname can't be null")
	assert(utils.contains_set(allowed_listnames_set, listname), "listname doesn't exist in this block")
	assert(stack, "stack can't be null")
	local barrel_meta = minetest.get_meta(pos)
	assert(not barrel.is_sealed(barrel_meta), "A sealed barrel can't have any input or output")
	local quantity = 0
	if listname == "input" then
		quantity = barrel.can_topup(barrel_meta, stack)
	elseif listname == "output" then
		quantity = barrel.can_drain(barrel_meta, stack)
	end
	if quantity == 0 then
		return 0
	end
	barrel.generate_formspec(barrel_meta)
	local free_space = barrel.capacity_left(barrel_meta)
	if quantity > free_space then
		return free_space
	else
		return quantity
	end
end

--Checks if the user is allowed to put items inside the barrel on the input slot
--@returns	- 0 if he can't
--			- the amount that he put in if the player is allowed to
function barrel.can_topup(barrel_meta, stack)
	assert(barrel_meta, "barrel meta can't be null")
	assert(stack, "stack cant't be null")
	local stack_meta = stack:get_meta()
	if not utils.contains_set(allowed_inputs_set, stack:get_name()) then
		barrel.generate_formspec(
			barrel_meta,
			table.concat(
				{
					"Can't fill ",
					utils.meta_string_alt(barrel_meta, "description", "barrel"),
					" with ",
					utils.meta_string_alt(stack_meta, "description", "item"),
					"."
				}
			)
		)
		return 0
	elseif barrel.is_full(barrel_meta) then
		barrel.generate_formspec(barrel_meta, "Can't top-up full barrel.")
		return 0
	elseif not barrel.is_empty(barrel_meta) and not drink.equals(stack_meta, barrel_meta) then
		barrel.generate_formspec(
			barrel_meta,
			table.concat(
				{
					"Can't top-up barrel with a different ",
					utils.meta_string_alt(stack_meta, "description", "drink"),
					"."
				}
			)
		)
		return 0
	end
	return stack:get_count()
end

--Checks if the user is allowed to put items inside the barrel output slot
--@returns	- 0 if he can't
--			- the amount that he put in if the player is allowed to
function barrel.can_drain(barrel_meta, stack)
	assert(barrel_meta, "barrel meta can't be null")
	assert(stack, "stack can't be null")
	local stack_meta = stack:get_meta()
	if not utils.contains_set(allowed_outputs_set, stack:get_name()) then
		barrel.generate_formspec(
			barrel_meta,
			table.concat(
				{
					"Can't drain ",
					utils.meta_string_alt(barrel_meta, "description", "barrel"),
					" with ",
					utils.meta_string_alt(stack_meta, "description", "item"),
					"."
				}
			)
		)
		return 0
	elseif barrel.is_empty(barrel_meta) then
		barrel.generate_formspec(barrel_meta, "Can't drain from empty barrel.")
		return 0
	end
	return stack:get_count()
end

--Checks if the user is allowed to move items inside the slots in the barrel
--@returns	- the ammount that he can move
--			- 0 if he can't move
function barrel.can_move_items_in_inv(pos, from_list, from_index, to_list, count)
	assert(pos, "pos can't be null")
	assert(from_list, "from_list can't be null")
	assert(from_index, "from_index can't be null")
	assert(to_list, "to_list can't be null")
	assert(count, "count can't be null")
	local barrel_meta = minetest.get_meta(pos)
	assert(barrel_meta, "barrel meta can't be null")
	local inv = barrel_meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	assert(
		stack:get_count() == count,
		"the retrieved item should be the same as the count provided by the functions"
	)
	return barrel.can_put_item_in(pos, to_list, stack)
end

function barrel.put_item_in(pos, listname, stack, index)
	assert(pos, "pos can't be null")
	assert(listname, "listname can't be null")
	assert(utils.contains_set(allowed_listnames_set, listname), listname .. " is not present in barrel")
	assert(stack, "stack can't be null")
	assert(index, "index can't be null")
	local barrel_meta = minetest.get_meta(pos)
	assert(barrel_meta, "error fetching barrel_meta")
	if listname == "input" then
		barrel.topup(barrel_meta, listname, stack, index)
	elseif listname == "output" then
		barrel.drain()
	end
end

--Fills the barrel with a drink, does all the necessary actions and then manipulates
--the input slot and the metadata so that everything is correct
function barrel.topup(barrel_meta, listname, stack, index)
	assert(stack, "stack can't be null")
	assert(barrel_meta, "barrel_meta can't be null")
	assert(stack, "stack can't be null")
	assert(index, "index can't be null")
	local stack_meta = stack:get_meta()
	local barrel_exclusive_metadata, metadata = drink.get_barrel_metadata()
	if barrel.is_empty(barrel_meta) then
		for data, type in pairs(metadata) do
			if type == "int" then
				local val = stack_meta:get_int(data)
				barrel_meta:set_int(data, val)
			elseif type == "string" then
				local val = stack_meta:get_string(data)
				barrel_meta:set_string(data, val)
			end
		end
	else
		for data, type in pairs(barrel_exclusive_metadata) do
			--TODO add a thing to change when this happens
		end
	end
	local taken_space = barrel.current_quantity(barrel_meta)
	local ammount_to_add = stack:get_count()
	local current_ammount = taken_space + ammount_to_add
	barrel_meta:set_int("contains", current_ammount)
	local original_container = drink.get_original_container(stack:get_name())
	original_container = ItemStack(table.concat({original_container, " ", ammount_to_add}))
	barrel_meta:get_inventory():set_stack(listname, index, original_container)
	barrel.generate_formspec(barrel_meta)
end

function barrel.drain(barrel_meta, listname, stack, index)
	assert(barrel_meta, "barrel_meta can't be null")
	assert(listname, "listname can't be null")
	assert(stack, "stack can't be null")
	assert(index, "index can't be null")
end

utils.add_to_set(allowed_inputs_set, "brewery:bucket_drink") --TODO add to wrapper function
utils.add_to_set(allowed_outputs_set, "bucket:bucket_empty") --TODO add to wrapper function
minetest.register_node(
	"brewery:barrel",
	{
		description = "Small Barrel", --TODO: make this a variable
		sounds = default.node_sound_wood_defaults(),
		drawtype = "mesh",
		mesh = "brewery_barrel.obj",
		tiles = {"brewery_barrel.png"},
		paramtype = "light",
		paramtype2 = "wallmounted",
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- Center box
				{-0.0625, -0.5, -0.375, 0.0625, 0.5, 0.375}, -- NodeBox11
				{-0.375, -0.5, -0.0625, 0.375, 0.5, 0.0625} -- NodeBox12
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.52, -0.5, 0.5, 0.52, 0.5}
			}
		},
		groups = {
			--TODO: make this a variable
			choppy = 2,
			oddly_breakable_by_hand = 2,
			flammable = 3,
			falling_node = 1
		},
		recipe = {
			--TODO: rework the entire crafting process
			{"", "group:wood", ""},
			{"group:wood", "group:wood", "group:wood"},
			{"", "group:wood", ""}
		},
		can_dig = function(pos, player)
			return barrel.can_dig(pos, player)
		end,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("sealed_start_date", "")
			meta:set_int("contains", 0)
			meta:set_int("capacity", 2) --TODO: make this be a variable
			barrel.generate_formspec(meta)
		end,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			local meta = minetest.get_meta(pos)
			barrel.generate_formspec(meta)
		end,
		on_receive_fields = function(pos, formname, fields, player)
			local meta = minetest.get_meta(pos)
			barrel.receive_fields(fields, meta)
		end,
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			barrel.put_item_in(pos, listname, stack, index)
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			return barrel.can_put_item_in(pos, listname, stack)
		end,
		allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
			return barrel.can_move_items_in_inv(pos, from_list, from_index, to_list, count)
		end
	}
)