-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  S = intllib.Getter(minetest.get_current_modname())
else
  S = function ( s ) return s end
end
--
--Tool Repairer
--

--Tool constants
local tool_repairer_list = {
--	{<num>, <max charge>, <power per use>, <repair amount>},
	{"1", 30000, 30000 / 5, 1000},
	{"2", 100000, 100000 / 10, 2000},
	{"3", 300000, 300000 / 20, 3000},
}
local tool_repairer_max_charge = 50000
local tool_repairer_power_per_use = tool_repairer_max_charge / 5

--Register all versions of the tool
for _, m in pairs(tool_repairer_list) do
	--Register as a technic tool
	technic.register_power_tool("moretechnictools:tool_repairer_mk"..m[1], m[2])

	--Register as a tool item
	minetest.register_tool("moretechnictools:tool_repairer_mk"..m[1], {
		description = S("Tool Repairer Mk%d"):format(m[1]),
		inventory_image = "moretechnictools_tool_repairer_mk"..m[1]..".png",
		stack_max = 1,
		wear_represents = "technic_RE_charge",
		on_refil = technic.refill_RE_charge,
		on_use = function(itemstack, user, pointed_thing)
			local meta = minetest.deserialize(itemstack:get_metadata())
			if not meta or not meta.charge then
				return
			end

			--If has enough charge to be used
			if meta.charge >= m[3] then
				--Get the stack to the left of the Tool Repairer
				local tool_to_repair = user:get_inventory():get_stack("main", user:get_wield_index()-1)

				--If the stack to the left is not empty and is not fully repaired
				if not tool_to_repair:is_empty() and tool_to_repair:get_wear() ~= 0 then
					--Reduce the wear of the tool
					tool_to_repair:add_wear(-1 * m[4])

					--Set the new wear value of the tool to the stack that the tool is in
					user:get_inventory():set_stack("main", user:get_wield_index()-1, tool_to_repair)

					--Decrease the charge of the Tool Repairer
					meta.charge = meta.charge - m[3]
					itemstack:set_metadata(minetest.serialize(meta))
					technic.set_RE_wear(itemstack, meta.charge, m[2])
				end

			end

			return itemstack
		end,
	})
end

--Register crafting recipes
--Mk1
minetest.register_craft({
	output = "moretechnictools:tool_repairer_mk1",
	recipe = {
		{"default:diamond", "technic:red_energy_crystal", "default:diamond"},
		{"technic:battery", "technic:tool_workshop", "technic:battery"},
		{"technic:battery", "technic:battery", "technic:battery"}
	}
})

--Mk2
minetest.register_craft({
	output = "moretechnictools:tool_repairer_mk2",
	recipe = {
		{"default:diamond", "technic:green_energy_crystal", "default:diamond"},
		{"technic:battery", "moretechnictools:tool_repairer_mk1", "technic:battery"},
		{"technic:battery", "technic:battery", "technic:battery"}
	}
})

--Mk3
minetest.register_craft({
	output = "moretechnictools:tool_repairer_mk3",
	recipe = {
		{"default:diamond", "technic:blue_energy_crystal", "default:diamond"},
		{"technic:battery", "moretechnictools:tool_repairer_mk2", "technic:battery"},
		{"technic:battery", "technic:battery", "technic:battery"}
	}
})
