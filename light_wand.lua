--local S = technic.getter

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  S = intllib.Getter(minetest.get_current_modname())
else
  S = function ( s ) return s end
end

--
--Heated Stone
--
minetest.register_node("moretechnictools:heated_stone", {
	description = S("Heated Stone"),
	tiles = {
		{
			name = "moretechnictools_heated_stone_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3,
			},
		},
	},
	--inventory_image = "moretechnictools_heated_stone.png",
	groups = {cracky=3, stone=1},
	light_source = 11,
	drop = "default:cobble",
})

--
--Light Tool
--

--Tool charge constants
local light_wand_max_charge = 30000
local light_wand_power_per_use = light_wand_max_charge / 20
local light_wand_power_restore = light_wand_power_per_use * 0.5

--Register as a technic tool
technic.register_power_tool("moretechnictools:light_wand", light_wand_max_charge)

--Register as a tool item
minetest.register_tool("moretechnictools:light_wand", {
	description = S("Light Wand"),
	inventory_image = "moretechnictools_light_wand.png",
	stack_max = 1,
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

		local charge_to_take = light_wand_power_per_use

		--If has enough charge to be used and is pointed at a node
		if meta.charge >= charge_to_take and (not (pos == nil)) then
			local n = minetest.get_node(pos).name

			--If the pointed at node is stone then turn it into heated stone and decrease the tool's energy
			if n == "default:stone" then
				minetest.add_node(pos, {name="moretechnictools:heated_stone"})
				meta.charge = meta.charge - charge_to_take
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, light_wand_max_charge)

			--If the pointed at node is heated stone then turn it into stone and increase the tool's energy slightly
			elseif n == "moretechnictools:heated_stone" then
				minetest.add_node(pos, {name="default:stone"})
				meta.charge = meta.charge + light_wand_power_restore
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, light_wand_max_charge)
			end

		--If does not have enough charge to be used on stone and is pointed at a node
		elseif not (pos == nil) then
			local n = minetest.get_node(pos).name

			--If the pointed at node is heated stone then turn it into stone and increase the tool's energy slightly
			if n == "moretechnictools:heated_stone" then
				minetest.add_node(pos, {name="default:stone"})
				meta.charge = meta.charge + light_wand_power_restore
				itemstack:set_metadata(minetest.serialize(meta))
				technic.set_RE_wear(itemstack, meta.charge, light_wand_max_charge)
			end
		end

		return itemstack
	end,
})

--Register crafting recipe
minetest.register_craft({
	output = "moretechnictools:light_wand",
	recipe = {
		{"", "default:mese_crystal", ""},
		{"technic:battery", "bucket:bucket_lava", "technic:battery"},
		{"", "technic:battery", ""}
	}
})
