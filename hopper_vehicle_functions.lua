function inform_about_hopper_vehicles()
	if is_table(g_savedata.known_hopper_holding_vehicles) then
		debug_announce_to_chat(2, "There are "..(#g_savedata.known_hopper_holding_vehicles).." known hopper carrying vehicles!")
	else
		debug_announce_to_chat(2, "There are 0 known hopper carrying vehicles!")
	end
end

function assert_hopper_vehicle_list_exists()
	if isnt_table(g_savedata.known_hopper_holding_vehicles) then
		g_savedata.known_hopper_holding_vehicles = {}
	end
end

function in_normal_spawn_queue(vehicle_id) --> times_queued, queued_at
	local times_queued, queued_at
	for k,data in ipairs(g_savedata.spawning_queue_data) do
		if data.vehicle_id == vehicle_id then
			queued_at = k
			times_queued = times_queued + 1
		end
	end
	return times_queued, queued_at
end
function is_in_server_spawn_queue(vehicle_id) --> bool
	local times_queued
	for k,data in ipairs(g_savedata.server_spawning_queue_data) do
		if data.vehicle_id == vehicle_id then
			times_queued = times_queued + 1
		end
	end
	return times_queued > 0
end

function handle_potential_hopper_vehicle_load(vehicle_id)
	--if is_in_server_spawn_queue(vehicle_id) then
	--	return
	--end

	local this_vehicle_spawn_data
	local times_queued, queued_at = in_normal_spawn_queue(vehicle_id)

	if times_queued == 1 then
		this_vehicle_spawn_data = table.remove(g_savedata.spawning_queue_data, queued_at)
		if this_vehicle_id then
			debug_announce_to_chat(2,"Ash vehicle loaded in!")
		end
	elseif times_queued > 1 then
		warn_entire_chat("Alerta, loading vehicle matches "..times_queued.." queued vehicle.s.. contact judge..")
		return
	elseif times_queued < 1 then
		--warn_entire_chat("No spawn data found for vehicle with id "..vehicle_id..", contact judge..")
		return
	end

	assert_hopper_vehicle_list_exists()
	local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(vehicle_id)
	if not is_success then
		warn_entire_chat("Failed to get vehicle components of vid "..vehicle_id.." to check for presence of hoppers ): \ncontact judge!!!")
		return
	end
	
	if has_any_hopper(LOADED_VEHICLE_DATA) then
		debug_announce_to_chat(4, "Found hopper!")
		table.insert(g_savedata.known_hopper_holding_vehicles, this_vehicle_spawn_data)
	else
		--we don't wanna check up on this vehicle since no hopper
		debug_announce_to_chat(4, "No hopper found, ignored "..vehicle_id..".")
	end
end
function handle_potential_hopper_vehicle_unload(vehicle_id)
	assert_hopper_vehicle_list_exists()

	local matches = 0
	for k, known_hopper_vehicle_data in ipairs(g_savedata.known_hopper_holding_vehicles) do
		if known_hopper_vehicle_data.vehicle_id == vehicle_id then
			matches = matches + 1
			table.remove(g_savedata.known_hopper_holding_vehicles, k)
		end
	end

	if matches == 0 then
		--this wasn't a hopper vehicle
		debug_announce_to_chat(3,"Checked, despawning vehicle was not known hopper carrying vehicle")
	elseif matches == 1 then
		--this was a hopper vehicle
		debug_announce_to_chat(3, "Handled unloading hopper carrying vehicle")
	elseif matches > 1 then
		--this matched multiple hopper vehicles
		warn_entire_chat("Unloading vehicle "..vehicle_id.." matched multiple hopper holding vehicles! Contact judge...")
	end
end