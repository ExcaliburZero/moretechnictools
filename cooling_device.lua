-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  S = intllib.Getter(minetest.get_current_modname())
else
  S = function ( s ) return s end
end

--
--Cooling Device
--

--Tool charge constants
local cooling_device_max_charge = 30000
local cooling_device_power_per_use = cooling_device_max_charge / 20
local cooling_device_power_restore = cooling_device_power_per_use * 0.5

--Register as a technic tool
technic.register_power_tool("moretechnictools:cooling_device", cooling_device_max_charge)

--Register as a tool item
minetest.register_tool("moretechnictools:cooling_device", {
	description = S("Cooling Device"),
	inventory_image = "moretechnictools_cooling_device.png",
	stack_max = 1,
	liquids_pointable = true,
	wear_represents = "technic_RE_charge",
	on_refil = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		local meta = minetest.deserialize(itemstack:get_metadata())
		if not meta or not meta.charge then
			return
		end

		local pos = pointed_thing.under

		-- disallow using the tool in protected areas
		if minetest.is_protected(pos, user:get_player_name()) then
			return
		end

		local charge_to_take = cooling_device_power_per_use

		--If has enough charge to be used and is pointed at a node
		if meta.charge >= charge_to_take and (not (pos == nil)) then
			local n = minetest.get_node(pos).name

			--If the pointed at node is a water source or water flowing node the turn it into ice
			if n == "default:water_flowing" or n == "default:water_source" then
				minetest.add_node(pos, {name="default:ice"})
				meta.charge = meta.charge - charge_to_take
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, cooling_device_max_charge)

			--If the pointed at node is a lava flowing or lava source node then turn it into obsidian
			elseif n == "default:lava_flowing" or n == "default:lava_source" then
				minetest.add_node(pos, {name="default:obsidian"})
				meta.charge = meta.charge - charge_to_take
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, cooling_device_max_charge)
			end

		end

		return itemstack
	end,
})

--Register crafting recipe
minetest.register_craft({
	output = "moretechnictools:cooling_device",
	recipe = {
		{"", "default:mese_crystal", ""},
		{"technic:battery", "bucket:bucket_water", "technic:battery"},
		{"", "technic:battery", ""}
	}
})
