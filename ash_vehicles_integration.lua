function is_ash_vehicle_load(spawner_user_id, command)
	--announce_to_entire_chat("Called: is_ash_vehicle_load(&",spawner_user_id,"#, &",command,"#)")
	--announce_to_entire_chat("Type of spawner_user_id is: &",spawner_user_id)
	--announce_to_entire_chat("Type of command is: &",command)
	--announce_to_entire_chat("Type of tonumber(spawner_user_id) is &",type(tonumber(spawner_user_id)))
	--announce_to_entire_chat("Type of command is &",type(command))
	return (tonumber(spawner_user_id) == -1) and (command == "ashvehicle")
end

function potentially_note_down_queued_ash_vehicle(spawner_user_id, command, group_id, vehicle_peer_id)
	local vehicle_peer_id = tonumber(vehicle_peer_id)
	if 
		(isnt_number(vehicle_peer_id))  or  (is_number(vehicle_peer_id) and (vehicle_peer_id >= 300))
	then
		warn_entire_chat("Ash vehicles provided a peer id that did not pass a validity test!\nCode will assume the test is invalid and the peer id is correct, this may break things, please contact judge!")
	end

	--debug_announce_to_chat(2,"full_message: &", full_message, "spawner_user_id: &", spawner_user_id, "is_admin: &", is_admin, "is_auth: &", is_auth, "command: &", command, "one: &", one, "two: &", two, "three: &", three, "four: &", four)
	local vehicle_ids, is_success = server.getVehicleGroup(group_id)
	for _, vehicle_id in pairs(vehicle_ids) do
		if error_checking_not_relaxed then
			for _,already_queued in ipairs(g_savedata.spawning_queue_data) do
				if already_queued.vehicle_id == vehicle_id then
					warn_entire_chat("Ash spawned/loaded vehicle shares vehicle id ("..vehicle_id..") with already loaded vehicle.. contact judge..")
				end
			end
		end
		table.insert(g_savedata.spawning_queue_data, {vehicle_id = vehicle_id, peer_id = vehicle_peer_id})
		debug_announce_to_chat(2,"Ash vehicle spawn noted down! Will try handling it as a hopper vehicle")
		handle_potential_hopper_vehicle_load(vehicle_id)
		debug_announce_to_chat(2,"Ash vehicle load handled!")
	end
end
