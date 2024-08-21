function track_crane_as_unloaded(crane_index)
	g_savedata.crane_glob_of_info[crane_index].loaded = false
	g_savedata.crane_glob_of_info[crane_index].vehicle_id = -1
end

function track_crane_as_loaded(crane_index, its_vehicle_id)
	g_savedata.crane_glob_of_info[crane_index].loaded = true
	g_savedata.crane_glob_of_info[crane_index].vehicle_id = its_vehicle_id
end

function handle_potential_crane_load(vehicle_id)
	local VEHICLE_DATA, is_success = server.getVehicleData(vehicle_id)
	if not is_success then
		debug_announce_to_chat(2, "Failed to get vehicle data for vehicle &",vehicle_id)
		return
	end
	if isnt_table(VEHICLE_DATA) then
		warn_entire_chat("Succeeded at getting vehicle data, but it is not a table?? contact judge")
		return
	end
	local loading_crane_tag = VEHICLE_DATA.tags_full
	if isnt_string(loading_crane_tag) then
		warn_entire_chat("Succeeded at getting vehicle data, and it is a table, but the tags are not a string?? contact judge")
		return
	end
	
	local found_match = false
	for crane_index, this_crane in pairs(g_savedata.crane_glob_of_info) do

		--logic
		if this_crane.tag ~= loading_crane_tag then
			goto craneload_continue_next_crane
		end
		--sanity checks
		if found_match ~= false then
			warn_entire_chat("Warning! Vehicle loaded in with tag that matches MULTIPLE CRANES?? sticking with highest index one - contact judge!!!")
		end
		if this_crane.loaded ~= false then
			warn_entire_chat("Warning! Vehicle loaded in matching crane tag of an ALREADY LOADED crane?? contact judge!!!")
		end

		found_match = crane_index

		::craneload_continue_next_crane::
	end

	if found_match ~= false then
		debug_announce_to_chat(2, "Crane loaded in at "..g_savedata.crane_glob_of_info[found_match].location)
		track_crane_as_loaded(found_match, vehicle_id)
	end
end

function handle_potential_known_crane_unload(this_vehicle_id)
	--scan through cranes and try to match a loaded crane's vehicle id to this unloading vehicle's id. If no crane matches, we're done here.
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
		if this_crane.loaded ~= true then
			warn_entire_chat("Warning! Unloading vehicle matches vehicle id with a NOT LOADED CRANE?? contact judge!!!")
		end

		matched_crane_index = crane_index

		::craneunload_continue_next_crane::
	end

	if matched_crane_index ~= false then
		track_crane_as_unloaded(matched_crane_index)
		debug_announce_to_chat(2,"Crane unloaded at "..g_savedata.crane_glob_of_info[matched_crane_index].location)
	end
end

function loaded_vic_is_crane(questioned_vehicle_id)
	local VEHICLE_DATA, is_success = server.getVehicleData(questioned_vehicle_id)
	if not is_success then
		debug_announce_to_chat(2, "Failed to get vehicle data for vehicle &",questioned_vehicle_id)
		return
	end
	if isnt_table(VEHICLE_DATA) then
		warn_entire_chat("Succeeded at getting vehicle data, but it is not a table?? contact judge")
		return
	end
	local loading_crane_tag = VEHICLE_DATA.tags_full
	if isnt_string(loading_crane_tag) then
		warn_entire_chat("Succeeded at getting vehicle data, and it is a table, but the tags are not a string?? contact judge")
		return
	end
	
	local found_match = false
	for crane_index, this_crane in pairs(g_savedata.crane_glob_of_info) do

		--logic
		if this_crane.tag ~= loading_crane_tag then
			goto loadediscrane_continue_next_crane
		end
		--sanity checks
		if found_match ~= false then
			warn_entire_chat("Warning! Questioned vehicle matches tag with multiple potential cranes?? sticking with highest index one - contact judge!!!")
		end

		found_match = true

		::loadediscrane_continue_next_crane::
	end

	return found_match
end