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

utils = brewery.utils

--@returns  - true if it added the key successfully
--          - false if it didn't add the key
function utils.add_to_set(set, key)
    assert(set, "set can't be null")
    assert(key, "key can't be null")
    set[key] = true
    return set[key] == true
end

--@returns  - true if it contains the key
--          - false if it doesn't
function utils.contains_set(set, key)
    return set[key] ~= nil
end

--@returns  - true if it was successfully removed
--          - false if it wasn't
function utils.remove_set(set, key)
    assert(set, "set can't be null")
    assert(key, "key can't be null")
    set[key] = nil
    return set[key] == nil
end

--@returns  - the OS date time
function utils.get_current_time()
	return os.date("*t")
end

--Checks if a given meta data contains a string, and if it doesn't
--it return's the alternative string
--@params meta          - the metadata of the node/item
--@params meta_string   - the value to look for inside the metadata
--@params alternative   - the alternative string to write
function utils.meta_string_alt(meta, meta_string, alternative)
    assert(meta, "meta can't be null")
    assert(alternative,"alternative can't be null")
    local string = meta:get_string(meta_string)
    if string == "" then return alternative
    else return string end
end