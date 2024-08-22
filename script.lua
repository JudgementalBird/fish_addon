require("globals")

require("logging_printing")

require("admin_possibilities")
require("execute_admin_possibilites_function")

require("user_possibilities")
require("execute_user_possibilites_function")

require("general_functions")

require("crane_functions")

require("hopper_vehicle_functions")

require("fish_withdrawing_functions")

require("http_functions")

--require("ash_vehicles_integration")

---- !! CALLBACKS !! ----

function onCreate(is_world_create)
	debug_announce_to_chat(2, "oncreate called !")
	ticks = 0
end

function onTick(game_ticks)	
	ticks = ticks + 1
	advance_all_fish_withdrawals()

	if slow_interval(ticks) then
		debug_announce_to_chat(2, "slow interval!")
		recreate_rapid_info_table()
	end
	
	if rapid_interval(ticks) then
		debug_announce_to_chat(2, "fast interval!")

		check_queue_all_withdrawals()
	end
end

function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
	--debug_announce_to_chat(2, "onvehiclespawn called !")
	debug_announce_to_chat(2, "Spawning vehicle id: &",vehicle_id)

	note_down_spawn_data(vehicle_id, peer_id)
end

function onVehicleLoad(vehicle_id)
	--debug_announce_to_chat(2, "onvehicleload called !")
	debug_announce_to_chat(2, "Loading vehicle id: &",vehicle_id)

	handle_potential_crane_load(vehicle_id)
	if not loaded_vic_is_crane(vehicle_id) then
		handle_potential_hopper_vehicle_load(vehicle_id)
	end
end

function onVehicleUnload(vehicle_id)
	--debug_announce_to_chat(3, "onvehicleunload called !")

	handle_potential_known_crane_unload(vehicle_id)
	handle_potential_hopper_vehicle_unload(vehicle_id)
end
function onVehicleDespawn(vehicle_id, peer_id)
	--debug_announce_to_chat(3, "onvehicledespawn called !")

	handle_potential_known_crane_unload(vehicle_id)
	handle_potential_hopper_vehicle_unload(vehicle_id)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)

	--debug_announce_to_chat(3, "onCustomCommand() called with '"..command.."'. User is admin? "..tostring(is_admin)..". User is auth? "..tostring(is_auth)..".")

	--|To add user commands that USE HTTP, add to 'user_possibilities.http' (in user_possibilities.lua).|
	--|To add user commands that DON'T use HTTP, add to 'user_possibilities.no_http' (in user_possibilities.lua).|
	execute_potential_user_possibility(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
	
	--|To add admin only commands that USE HTTP, add to 'admin_possibilities.http' (in admin_possibilities.lua).|
	--|To add admin only commands that DON'T use HTTP, add to 'admin_possibilities.no_http' (in admin_possibilities.lua).|
	execute_potential_admin_possibility(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)

	--potentially_note_down_queued_ash_vehicle(user_peer_id, command, one, two)
end

function httpReply(port, request, reply)
	--debug_announce_to_chat(4, "httpreply called !")
	handle_http_response(port,request,reply)
end

