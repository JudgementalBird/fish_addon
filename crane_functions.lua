function track_crane_as_despawned(crane_index)
	g_savedata.crane_glob_of_info[crane_index].spawned = false
	g_savedata.crane_glob_of_info[crane_index].vehicle_id = -1
end
function despawn_all_known_cranes()
	if error_checking_not_relaxed and isnt_table(g_savedata.crane_glob_of_info) then
		warn_entire_chat("crane_glob_of_info is nil??? Contact judge...")
		return
	end

	local cranes_failed_to_despawn = 0
	for crane_index,this_crane in ipairs(g_savedata.crane_glob_of_info) do

		-- logic and sanity checks
		if this_crane.spawned ~= true then
			goto despawncranes_continue_next_crane
		end
		if error_checking_not_relaxed and isnt_bool(this_crane.spawned) then
			warn_entire_chat("this_crane.spawned is not a boolean? Contact judge..")
			goto despawncranes_continue_next_crane
		end
		if error_checking_not_relaxed and isnt_number(this_crane.vehicle_id) then
			warn_entire_chat("this_crane.vehicle_id is not a number? Contact judge..")
			goto despawncranes_continue_next_crane
		end

		local is_success = server.despawnVehicle(this_crane.vehicle_id, true)
		if is_success then
			track_crane_as_despawned(crane_index)
		else
			cranes_failed_to_despawn = cranes_failed_to_despawn + 1
		end

		::despawncranes_continue_next_crane::
	end

	if (cranes_failed_to_despawn <= 0) then
		debug_announce_to_chat(2,"Despawned all cranes that were loaded in (some may still spawn in later as you move around) :yum:")
	else
		warn_entire_chat(cranes_failed_to_despawn.." cranes failed to despawn! contact judge probably..")
	end
end

function handle_queueing_cranes()
	if error_checking_not_relaxed and isnt_table(g_savedata.crane_glob_of_info) then
		warn_entire_chat("crane_glob_of_info is nil??? Contact judge...")
		return
	end

	for k,this_crane in ipairs(g_savedata.crane_glob_of_info) do

		-- quick sanity checks
		if error_checking_not_relaxed and isnt_bool(this_crane.spawned) then
			warn_entire_chat("this_crane.spawned is not a boolean? Contact judge..")
			goto handlequeueing_continue_next_crane
		end
		if error_checking_not_relaxed and isnt_bool(this_crane.queued) then
			warn_entire_chat("this_crane.queued is not a boolean? Contact judge..")
			goto handlequeueing_continue_next_crane
		end
		if error_checking_not_relaxed and isnt_string(this_crane.location) then
			warn_entire_chat("this_crane.location is not a string? Contact judge..")
			goto handlequeueing_continue_next_crane
		end

		--logic
		if (this_crane.spawned == true)  or  (this_crane.queued == true) then
			goto handlequeueing_continue_next_crane
		end

		local location_name = this_crane.location
		local is_success = server.spawnNamedAddonLocation(location_name)
		if is_success then
			debug_announce_to_chat(4, "Successfully tried to spawn crane location "..location_name)
			g_savedata.crane_glob_of_info[k].queued = true
		else
			warn_entire_chat("Failed to spawn crane at "..location_name.." !")
		end

		::handlequeueing_continue_next_crane::
	end
end

function track_crane_as_spawned(crane_index, its_vehicle_id)
	g_savedata.crane_glob_of_info[crane_index].spawned = true
	g_savedata.crane_glob_of_info[crane_index].queued = false
	g_savedata.crane_glob_of_info[crane_index].vehicle_id = its_vehicle_id
end
function handle_potential_crane_load(vehicle_id)
	local this_tag = server.getVehicleData(vehicle_id).tags_full
	
	local found_match = false
	for crane_index, this_crane in pairs(g_savedata.crane_glob_of_info) do

		--logic
		if this_crane.tag ~= this_tag then
			goto craneload_continue_next_crane
		end
		--sanity checks
		if found_match ~= false then
			warn_entire_chat("Warning! Vehicle loaded in with tag that matches MULTIPLE CRANES?? sticking with highest index one - contact judge!!!")
		end
		if this_crane.spawned ~= false then
			warn_entire_chat("Warning! Vehicle loaded in matching crane tag of an ALREADY SPAWNED crane?? contact judge!!!")
		end
		--Though it may jump out at you, we do not need to assert that .queued == true because an already queued and loaded (.queued becoming false) crane can exist, despawn when you go away, then load in again when you get close again

		found_match = crane_index

		::craneload_continue_next_crane::
	end

	if found_match ~= false then
		debug_announce_to_chat(2, "Crane loaded in at "..g_savedata.crane_glob_of_info[found_match].location)
		track_crane_as_spawned(found_match, vehicle_id)
	end
end

function handle_potential_known_crane_unload(this_vehicle_id)
	--scan through cranes and try to match a spawned crane's vehicle id to this unloading vehicle's id. If no crane matches, we're done here.
	local matched_crane_index = false
	for crane_index, this_crane in ipairs(g_savedata.crane_glob_of_info) do

		--logic
		if this_crane.vehicle_id ~= this_vehicle_id then
			goto craneunload_continue_next_crane
		end

		--sanity
		if matched_crane_index ~= false then
			warn_entire_chat("Warning! Unloading vehicle matches vehicle id with MULTIPLE CRANES?? sticking with highest index one - contact judge!!!")
		end
		if this_crane.queued ~= false then
			warn_entire_chat("Warning! Unloading vehicle is somehow a queued crane?? contact judge!!!")
		end
		if this_crane.spawned ~= true then
			warn_entire_chat("Warning! Unloading vehicle matches vehicle id with a NOT SPAWNED CRANE?? contact judge!!!")
		end

		matched_crane_index = crane_index

		::craneunload_continue_next_crane::
	end

	if matched_crane_index ~= false then
		track_crane_as_despawned(matched_crane_index)
		debug_announce_to_chat(2,"Crane despawned at "..g_savedata.crane_glob_of_info[matched_crane_index].location)
	end
end

function is_known_crane(questioned_vehicle_id)
	local is_known_crane = false
	for _, this_crane in ipairs(g_savedata.crane_glob_of_info) do
		
		--logic
		if this_crane.vehicle_id ~= questioned_vehicle_id then
			goto isknowncrane_continue_next_crane
		end
		--sanity
		if is_known_crane == true then
			warn_entire_chat("Warning, vehicle id "..questioned_vehicle_id.." matches with multiple cranes! contact judge!")
		end
		
		is_known_crane = true

		::isknowncrane_continue_next_crane::
	end

	return is_known_crane
end