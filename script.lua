require("globals")

require("logging_printing")

require("admin_possibilities")
require("execute_admin_possibilites_function")

require("general_functions")

require("crane_functions")



---- !! CALLBACKS !! ----
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
	--debug_announce_to_chat(2, "onvehiclespawn called !")
	debug_announce_to_chat(2, "Vehicle spawned! vehicle_id: &",vehicle_id,"# peer_id: &",peer_id,"# group_cost: &",group_cost,"# group_id: &",group_id)

	note_down_spawn_data(vehicle_id, peer_id)
end

function onVehicleLoad(vehicle_id)
	--debug_announce_to_chat(2, "onvehicleload called !")
	debug_announce_to_chat(2, "Loading vehicle id: "..vehicle_id)

	if not is_known_crane(vehicle_id) then
		handle_potential_hopper_vehicle_load(vehicle_id)
	end
end

function onVehicleUnload(vehicle_id)
	--debug_announce_to_chat(3, "onvehicleunload called !")
	debug_announce_to_chat(2, "Unloading vehicle id: "..vehicle_id)

	handle_potential_hopper_vehicle_unload(vehicle_id)
end
function onVehicleDespawn(vehicle_id, peer_id)
	--debug_announce_to_chat(3, "onvehicledespawn called !")
	debug_announce_to_chat(2, "Vehicle despawned! vehicle_id: &",vehicle_id,"# peer_id: &",peer_id)

	handle_potential_hopper_vehicle_unload(vehicle_id)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
	
	--|To add admin only commands that USE HTTP, add to 'admin_possibilities.http' (in admin_possibilities.lua).|
	--|To add admin only commands that DON'T use HTTP, add to 'admin_possibilities.no_http' (in admin_possibilities.lua).|
	execute_potential_admin_possibility(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
end