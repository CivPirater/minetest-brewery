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

fermenter = {}

function fermenter.calculate_yeast_concentration(time_dif, yeast)
	if (yeast == nil) then
		error("No yeast passed")
	elseif
		(yeast.growth_rate == nil or yeast.lag_phase_duration == nil or yeast.death_rate == nil or
			yeast.yeast.stationary_phase == nil)
	 then
		error("Yeast can't have nil values")
	elseif (time_dif > 0) then
		error("Difference in time can't be equal or smaller than 0")
	end
	return 1 / (1 + math.exp(1) ^ (-yeast.growth_rate * (time_dif - yeast.lag_phase_duration))) +
		1 / (1 + math.exp(1) ^ (yeast.death_rate * (time_dif - yeast.stationary_phase))) -
		1
end

function fermenter.calculate_alcohol_quantity(time_dif, yeast)
	if (yeast == nil) then
		error("No yeast passed")
	elseif
		(yeast.growth_rate == nil or yeast.lag_phase_duration == nil or yeast.death_rate == nil or
			yeast.yeast.stationary_phase == nil)
	 then
		error("Yeast can't have nil values")
	elseif (time_dif > 0) then
		error("Difference in time can't be equal or smaller than 0")
	end
	return -math.log(math.exp(1) ^ (yeast.death_rate * yeast.stationary_phase - yeast.death_rate * time_dif) + 1) /
		yeast.death_rate +
		math.log(
			math.exp(1) ^ (yeast.growth_rate * time_dif) + math.exp(1) ^ (yeast.growth_rate * yeast.lag_phase_duration)
		) /
			yeast.growth_rate -
		time_dif +
		(yeast.stationary_phase - yeast.lag_phase_duration)
end

function fermenter.calculate_alcohol_percentage(time_dif, yeast)
	if (yeast == nil) then
		error("No yeast passed")
	elseif
		(yeast.growth_rate == nil or yeast.lag_phase_duration == nil or yeast.death_rate == nil or
			yeast.yeast.stationary_phase == nil)
	 then
		error("Yeast can't have nil values")
	elseif (time_dif > 0) then
		error("Difference in time can't be equal or smaller than 0")
	end
	return (-math.log(
		math.exp(1) ^ (yeast.death_rate * yeast.stationary_phase - yeast.death_rate * time_dif) + 1
	) /
		yeast.death_rate +
		math.log(
			math.exp(1) ^ (yeast.growth_rate * time_dif) + math.exp(1) ^ (yeast.growth_rate * yeast.lag_phase_duration)
		) /
			yeast.growth_rate -
		time_dif +
		(yeast.stationary_phase - yeast.lag_phase_duration)) /
		(yeast.stationary_phase - yeast.lag_phase_duration)
end

function fermenter.register_fermenter()
end
