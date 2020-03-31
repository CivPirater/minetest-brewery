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

minetest.debug("Brewery Initialized")

brewery = {}

local function get_all_items_in_group(grouptag)
    minetest.debug("Logging all food tagged items: ")
    for name, def in pairs(minetest.registered_items) do
        for groupname in pairs(def.groups) do
            if string.find(groupname, grouptag) then
                minetest.debug(name .. " is in group: " .. groupname)
            end
        end
    end
    minetest.debug("End of all tagged items.")
end

minetest.debug(get_all_items_in_group("food"))

local modpath = minetest.get_modpath("brewery")

-- Load files
dofile(modpath .. "/Barrel.lua")