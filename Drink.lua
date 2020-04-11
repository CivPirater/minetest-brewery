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
--  palette_index: a int from 0 to 255
--  palette: a texture file set on load
--  description: the name of the drink
drink = brewery.drink

--Sets the color of the drink
--@color - an int value from 0 to 255
function drink.set_color(meta, color)
    assert(meta, "Meta can't be null")
    assert(color >= 0 and color <= 255, "Number can only be an integer between 0 and 255")
    meta:set_int("palette_index", color)
    meta:set_string("description", "Drink (color #" .. color .. ")")
end

minetest.register_craftitem(
    "brewery:bucket_drink",
    {
        description = "Drink",
        inventory_overlay = "brewery_bucket.png",
        inventory_image = "brewery_bucket_drink.png",
        palette = "brewery_drink_palette.png",
        palette_index = 0,
        on_use = function(itemstack)
            minetest.chat_send_all("Painted bucket")
            return drink.change_color(itemstack)
        end
    }
)

--Checks if a drink is the same as the other
--@meta1 - the meta of a drink
--@meta2 - the meta of the drink we want to compare it with
--@returns true if it is the same(check Drink.lua)
--         false if it isn't equal
function drink.equals(meta1, meta2)
    assert(meta1, "meta of the first drink can't be nil")
    assert(meta2, "meta of what we want to compare to can't be nil")
    if meta1 == meta2 then return true end
    if meta1:get_int("palette_index") ~= meta2:get_int("palette_index") then return false end

    return true
end

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
