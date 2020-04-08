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

local drink = {}

function drink.set_color(meta, color)
    assert(meta, "Meta can't be null")
    assert(
        color.type == "number" and color >= 0 and color <= 255,
        "Number can only be an integer between 0 and 255"
    )
    meta:set_int("palette_index", color)
    meta:set_string("description", "Drink (color #" .. color .. ")")
end

minetest.register_craftitem(
    "brewery:drink",
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
