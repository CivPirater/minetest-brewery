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
--	contains	- the ammount of drink that the barrel contains
--				- 0 if it's empty
--	capacity	- the capacity of the barrel to hold drinks, should never be 0
barrel = brewery.barrel
drink = brewery.drink
utils = brewery.utils

local allowed_inputs_set = {}
utils.add_to_set(allowed_inputs_set, "brewery:bucket_drink")

local allowed_outputs_set = {}
utils.add_to_set(allowed_outputs_set, "bucket:bucket_empty")

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
function barrel.can_dig(pos)
	assert(pos, "Pos can't be null")
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return barrel.is_empty(meta) and inv:is_empty("input") and inv:is_empty("output")
end

--Checks if the user is allowed to place an item in the input value
--@returns	- the amount that he can input
--			- 0 if he can't
function barrel.can_topup(pos, listname, stack)
	assert(pos, "Pos can't be null")
	assert(listname, "listname can't be null")
	assert(stack, "stack can't be null")
	local barrel_meta = minetest.get_meta(pos)
	assert(not barrel.is_sealed(barrel_meta), "A sealed barrel can't have any input")
	local stack_meta = stack:get_meta()
	if listname == "input" and utils.contains_set(allowed_inputs_set, stack:get_name()) then
		if barrel.is_empty(barrel_meta) then
			return stack:get_count()
		elseif barrel.is_full(barrel_meta) then
			return 0
		elseif drink.equals(stack_meta, barrel_meta) then
			return stack:get_count()
		end
	elseif
		listname == "output" and not barrel.is_empty(barrel_meta) and
			utils.contains_set(allowed_outputs_set, stack:get_name())
	 then
		return stack:get_count()
	end
	return 0
end

minetest.register_node(
	"brewery:barrel",
	{
		description = "Small Barrel", --TODO: make this a variable
		inventory_image = "barrel1.png", --TODO: make this a variable
		wield_image = "barrel1.png", --TODO: make this a variable
		groups = {
			--TODO: make this a variable
			choppy = 2,
			oddly_breakable_by_hand = 2,
			flammable = 3
		},
		recipe = {
			--TODO: rework the entire crafting process
			{"", "group:wood", ""},
			{"group:wood", "group:wood", "group:wood"},
			{"", "group:wood", ""}
		},
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
		can_dig = function(pos)
			return barrel.can_dig(pos)
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			return barrel.can_topup(pos, listname, stack)
		end
	}
)
