--function potentially_note_down_queued_ash_vehicle(user_peer_id, command, group_id, steam64_or_peer_id)
--	if (user_peer_id ~= -1) or (command ~= "ashvehicle") then
--		return -- not an ash vehicle
--	end
--
--	local peer_id
--	if (is_number(steam64_or_peer_id) and (steam64_or_peer_id <= 110))  or  (is_string(steam64_or_peer_id) and (steam64_or_peer_id:len() <= 3)) then
--		--peer id
--		peer_id = steam64_or_peer_id
--	elseif (is_number(steam64_or_peer_id) and (steam64_or_peer_id > 110))  or  (is_string(steam64_or_peer_id) and (steam64_or_peer_id:len() > 3)) then
--		--steam id
--		peer_id = get_peer_id(steam64_or_peer_id)
--	else
--		warn_entire_chat("code and or stormworks and or my balls are fucked up, please contact judge")
--	end
--
--	--debug_announce_to_chat(2,"full_message: &", full_message, "user_peer_id: &", user_peer_id, "is_admin: &", is_admin, "is_auth: &", is_auth, "command: &", command, "one: &", one, "two: &", two, "three: &", three, "four: &", four)
--	local vehicle_ids, is_success = server.getVehicleGroup(group_id)
--	for _, vehicle_id in pairs(vehicle_ids) do
--		if error_checking_not_relaxed then
--			for _,already_queued in ipairs(g_savedata.spawning_queue_data) do
--				if already_queued.vehicle_id == vehicle_id then
--					warn_entire_chat("Ash spawned vehicle shares vehicle id ("..vehicle_id..") with already spawned vehicle.. contact judge..")
--				end
--			end
--		end
--		table.insert(g_savedata.spawning_queue_data, {vehicle_id = vehicle_id, peer_id = peer_id, is_ash = true})
--		debug_announce_to_chat(2,"Ash vehicle spawn noted down! Will try handling it as a hopper vehicle")
--		handle_potential_hopper_vehicle_load(vehicle_id)
--	end
--end