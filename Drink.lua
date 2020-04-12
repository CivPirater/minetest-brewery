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

--Drink is the fundamental item in Brewery, it's purpose is to accrue enough metadata to
--eventually be bottled.
--Metadata attributes:
--  description: the name of the drink
--  palette_index: a int from 0 to 255
--Extra attributes:
--  original_container: the container where the drink was originally stored in (e.g. "bucket:bucket_empty")
drink = brewery.drink

local metadata = {}
metadata["palette_index"] = "int"

local original_container = {}

--Sets the color of the drink
--@color    - an int value from 0 to 255
function drink.set_color(meta, color)
	assert(meta, "Meta can't be null")
	assert(color >= 0 and color <= 255, "Number can only be an integer between 0 and 255")
	meta:set_int("palette_index", color)
	meta:set_string("description", "Drink (color #" .. color .. ")")
end

--Checks if a drink is the same as the other
--@meta1    - the meta of a drink
--@meta2    - the meta of the drink we want to compare it with
--@returns  - true if it is the same(check Drink.lua)
--          - false if it isn't equal
function drink.equals(meta1, meta2)
	assert(meta1, "meta of the first drink can't be nil")
	assert(meta2, "meta of what we want to compare to can't be nil")
	if meta1 == meta2 then
		return true
	end
	for metadata_val, type in pairs(metadata) do
		if type == "int" then
			if meta1:get_int(metadata_val) ~= meta2:get_int(metadata_val) then
				return false
			end
		elseif type == "string" then
			if meta1:get_string(metadata_val) ~= meta2:get_string(metadata_val) then
				return false
			end
		else
			error("Unrecognized type in metadata array(Check Drink.lua metadata table declaration)")
		end
	end
	return true
end

--Gets all the relevant metadata
--@returns  - a metadata table with fields for non empty barrels
--          - and a copy of the entire metadata
function drink.get_barrel_metadata()
	local non_empty_metadata = table.copy(metadata)
	non_empty_metadata["palette_index"] = nil
	return non_empty_metadata, table.copy(metadata)
end

--Retrieves the original vessel of the item
--@param stackname	- e.g. "brewery:bucket_drink"
function drink.get_original_container(stackname)
	return table.copy(original_container)[stackname]
end

minetest.register_craftitem(
	"brewery:bucket_drink",
	{
		description = "Drink", --TODO variable
		inventory_overlay = "brewery_bucket.png", --TODO variable
		inventory_image = "brewery_bucket_drink.png", --TODO variable
		palette = "brewery_drink_palette.png", --TODO variable
		palette_index = 0, --TODO variable
		on_use = function(itemstack) --TODO temporary
			minetest.chat_send_all("Painted bucket")
			return drink.change_color(itemstack)
		end
	}
)
original_container["brewery:bucket_drink"] = "bucket:bucket_empty" --TODO wrap this inside, add variable and re-use key

--Temp function for testing
function drink.change_color(itemstack)
	local meta = itemstack:get_meta()
	local color = meta:get_int("palette_index")
	color = color + 1
	if (color > 255) then
		color = 0
	end
	drink.set_color(meta, color)
	return itemstack
end
