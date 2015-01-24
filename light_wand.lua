local S = technic.getter

--
--Heated Stone
--
minetest.register_node("moretechnictools:heated_stone", {
	tile_images = {"default_lava.png^moretechnictools_heated_stone.png"},
	description = "Heated Stone",
	groups = {cracky=3, stone=1},
	light_source = 11,
	drop = "default:cobble",
})

--
--Light Tool
--

--Register as a technic tool
technic.register_power_tool("moretechnictools:light_wand", 50000)

--Register as a tool item
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

		--Power usage of tool
		local charge_to_take = 1000

		local pos = pointed_thing.under

		--If has enough charge to be used and is pointed at a node
		if meta.charge >= charge_to_take and (not (pos == nil)) then
			local n = minetest.env:get_node(pos).name

			--If the pointed at node is stone then turn it into heated stone and decrease the tool's energy
			if n == "default:stone" then
				minetest.env:add_node(pos, {name="moretechnictools:heated_stone"})
				meta.charge = meta.charge - charge_to_take
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, 50000)

			--If the pointed at node is heated stone then turn it into stone and increase the tool's energy slightly
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
