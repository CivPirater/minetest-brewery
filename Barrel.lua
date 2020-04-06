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

barrel = {
    sealed_start_date = nil,
    sealed_end_date = nil
}

-- Returns: the OS date time
function barrel.get_current_time()
    return os.date("*t")
end

-- Calculates the difference between dates that the system was sealed
-- Returns: The difference or nil (if it wasn't sealed)
function barrel.time_sealed(start_sealed_time, end_sealed_time)
    if barrel.is_sealed() then
        return os.difftime(start_sealed_time, end_sealed_time)
    else
        return nil
    end
end

-- Returns true if barrel is sealed and false if barrel is not sealed
function barrel.is_sealed()
end

function barrel.get_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local formspec =
		"size[8,9]" ..
		"list[nodemeta:" .. spos .. ";main;0,0.3;8,4;]" ..
		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[nodemeta:" .. spos .. ";main]" ..
		"listring[current_player;main]" ..
        default.get_hotbar_bg(0,4.85)
    return formspec
end

minetest.register_node(
    "brewery:barrel",
    {
        description = "Small Barrel",
        inventory_image = "barrel1.png",
        wield_image = "barrel1.png",
        groups = {
            choppy = 2,
            oddly_breakable_by_hand = 2,
            flammable = 3
        },
        recipe = {
            {"", "group:wood", ""},
            {"group:wood", "group:wood", "group:wood"},
            {"", "group:wood", ""}
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            minetest.show_formspec(clicker:get_player_name(), "brewery:barrelformspec", barrel.get_formspec(pos))
        end
    }
)
