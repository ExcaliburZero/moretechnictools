local S = technic.getter

--Light Tool
minetest.register_node("moretechnictools:heated_stone", {
	tile_images = {"default_lava.png^moretechnictools_heated_stone.png"},
	description = "Heated Stone",
	groups = {cracky=3, stone=1},
	light_source = 11,
	drop = "default:cobble",
})

technic.register_power_tool("moretechnictools:light_wand", 50000)

minetest.register_tool("moretechnictools:light_wand", {
	description = S("Light Wand"),
	inventory_image = "moretechnictools_light_wand.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refil = technicrefill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		local meta = minetest.deserialize(itemstack:get_metadata())
		if not meta or not meta.charge then
			return
		end
		local charge_to_take = 1000
		local pos = pointed_thing.under

		if meta.charge >= charge_to_take and (not (pos == nil)) then
			
			print("\n\nWand: ")
			print(pointed_thing.under)
			print("\n\n")

			local n = minetest.env:get_node(pos).name

			if n == "default:stone" then
				minetest.env:add_node(pos, {name="moretechnictools:heated_stone"})
				meta.charge = meta.charge - charge_to_take
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, 50000)

			elseif n == "moretechnictools:heated_stone" then
				minetest.env:add_node(pos, {name="default:stone"})
				meta.charge = meta.charge + (charge_to_take * 0.5)
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, 50000)
			end

		end

		return itemstack
	end,
})
