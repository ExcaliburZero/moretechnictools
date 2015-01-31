--Get modpath
modpath=minetest.get_modpath("moretechnictools")

--Load Light Wand and Heated Stone
dofile(modpath.."/light_wand.lua")

--Load Cooling Device
dofile(modpath.."/cooling_device.lua")

--Load Tool Repairer
dofile(modpath.."/tool_repairer.lua")
