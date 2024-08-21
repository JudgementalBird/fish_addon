function recreate_rapid_info_table()
	--does a rough distance check from all known hopper holding vehicles to all known cranes and reconstructs rapid info with whos close to what crane location
	if isnt_table(g_savedata.known_hopper_holding_vehicles) then
		return
	end

	rapid_info = nil
	rapid_info = {}

	--construct
	for _,hopper_vehicle_data in ipairs(g_savedata.known_hopper_holding_vehicles) do
		
		local hopper_vehicle_vid = hopper_vehicle_data.vehicle_id
		local hopper_vehicle_peer_owner = hopper_vehicle_data.peer_id

		local hopper_vehicle_transform_matrix, is_success = server.getVehiclePos(hopper_vehicle_vid)
		if not is_success then
			warn_entire_chat("Failed to get position of hopper carrying vehicle with vid "..hopper_vehicle_vid)
			goto recreate_continue_next_hopper_vehicle
		end
		
		for this_crane_index,all_info_this_crane in ipairs(g_savedata.crane_glob_of_info) do
			
			if all_info_this_crane.loaded == false then
				goto recreate_continue_next_crane
			end
			local known_crane_transform_matrix, is_success = server.getVehiclePos(all_info_this_crane.vehicle_id)
			if not is_success then
				warn_entire_chat("Failed to get position of crane at "..all_info_this_crane.location)
				goto recreate_continue_next_crane
			end

			if matrixes_roughly_close(hopper_vehicle_transform_matrix, known_crane_transform_matrix) then
				
				if isnt_table( rapid_info[this_crane_index] ) then
					rapid_info[this_crane_index] = {}
				end

				table.insert(rapid_info[this_crane_index], {vehicle_id=hopper_vehicle_vid, peer_id=hopper_vehicle_peer_owner})
			end

			::recreate_continue_next_crane::
		end

		::recreate_continue_next_hopper_vehicle::
	end

	if error_checking_not_relaxed then
		--just potential warning from down here
		local looped_amount = 0
		--for each location
		for checker_crane_index, checker_vehicles_and_peers in pairs(rapid_info) do

			--for each vehicle id in that location
			for checker_index, checker_data in ipairs(checker_vehicles_and_peers) do

				--for each location
				for checked_crane_index, checked_vehicles_and_peers in pairs(rapid_info) do

					--for each vehicle id in that location
					for checked_index, checked_data in ipairs(checked_vehicles_and_peers) do

						looped_amount = looped_amount + 1

						--if they aren't at the same index in the same location
						if not (checker_index == checked_index and checker_crane_index == checked_crane_index) then

							-- if they have the same id, warn
							if checker_data.vehicle_id == checked_data.vehicle_id then
								warn_entire_chat("Warning! Vehicle with id "..checker_data.vehicle_id.." at "..g_savedata.crane_glob_of_info[checker_crane_index].location.." matches vehicle id with "..checked_data.vehicle_id.." at "..g_savedata.crane_glob_of_info[checked_crane_index].location.."! contact judge!")
							end
						end
					end
				end
			end
		end
		
		debug_announce_to_chat(3,"Looped "..looped_amount.." times while checking rapid_info table!!")
	end
end
function get_bros_tip_xyz(vehicle_id)
	local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(vehicle_id)
	if is_success ~= true then
		warn_entire_chat("Failed to get components of crane with vehicle id "..vehicle_id.."!")
		return
	end
	local button_pos = LOADED_VEHICLE_DATA.components.buttons[1].pos
	if error_checking_not_relaxed and isnt_table(button_pos) then
		warn_entire_chat("Failed to get position of bro's tip on crane with vehicle id "..vehicle_id.."!")
		return
	end
	local transform_matrix, is_success = server.getVehiclePos(vehicle_id, button_pos.x, button_pos.y, button_pos.z)
	if not is_success then
		warn_entire_chat("Failed to get transform_matrix of voxel pos of "..optional_name.." !")
		return 
	end
	debug_announce_to_chat(3, vehicle_id.." is at: &",transform_matrix[13],transform_matrix[15],transform_matrix[14])
		return transform_matrix[13],transform_matrix[15],transform_matrix[14]
end

function queue_fish_withdrawal(crane_index, vehicle_id, to_withdraw, peer_id)
	
	local a_task_exists_for_this_vehicle = false
	for _,task_data in ipairs(g_savedata.fish_withdrawal_tasks) do
		
		if task_data.premise.vehicle_id == vehicle_id then
			a_task_exists_for_this_vehicle = true
		end
	end

	if a_task_exists_for_this_vehicle then
		debug_announce_to_chat(3, "Skipped queueing a fish withdrawal since vehicle "..vehicle_id.." already has a task!")
		return
	end

	debug_announce_to_chat(3, "Queueing a fish withdrawal"..(#g_savedata.fish_withdrawal_tasks).."!")
	local task_data = {premise={crane_index=crane_index, vehicle_id=vehicle_id, to_withdraw=to_withdraw, peer_id=peer_id}, state={remaining_to_withdraw=to_withdraw, first_tick=true, specific_withdrawn={}}}
	for i = 13,55 do
		task_data.state.specific_withdrawn[i] = 0
	end
	table.insert(g_savedata.fish_withdrawal_tasks,task_data)
end

function clear_fish_withdrawal(task_index)
	debug_announce_to_chat(4, "Ending fish withdrawal "..task_index.."!")
	table.remove(g_savedata.fish_withdrawal_tasks,task_index)
end

function tally_up_fishes_in(hoppers)
	local specific_found = {}
	local total_found = 0
	for hopper_index, hopper in pairs(hoppers) do

		--sanity
		if error_checking_not_relaxed and isnt_table(hopper.values) then
			warn_entire_chat("Error while withdrawing: a hopper's .values is not a table? Exiting early, this may be really bad, so please contact judge!")
			return
		end

		for i = 13,55 do
			local fish_type, amount_of_this_fish = i, hopper.values[i]

			if amount_of_this_fish > 0 then
				specific_found[fish_type] = amount_of_this_fish
				total_found = total_found + amount_of_this_fish
			end
		end
	end
	return total_found, specific_found
end


function advance_this_fish_withdrawal(this_task_index)	
	local my_data = g_savedata.fish_withdrawal_tasks[this_task_index]
	my_data.state.nothing_left = true
	
	debug_announce_to_chat(3, "task "..this_task_index.." being advanced!")
	if my_data.state.first_tick == true then
		debug_announce_to_chat(3, "Going to try to withdraw "..my_data.premise.to_withdraw)
		my_data.state.first_tick = false
	end

	local LOADED_VEHICLE_DATA, succeeded_getting_components = server.getVehicleComponents(my_data.premise.vehicle_id)

	--sanity
	if not succeeded_getting_components then
		warn_entire_chat("Error while withdrawing: Was unable to get vehicle "..my_data.premise.vehicle_id.."'s data to withdraw! Exiting early, this may be really bad, so please contact judge!")
		clear_fish_withdrawal(this_task_index)
		return
	end
	if error_checking_not_relaxed and isnt_table(LOADED_VEHICLE_DATA.components) then
		warn_entire_chat("Error while withdrawing: .components is not a table? Exiting early, this may be really bad, so please contact judge!")
		clear_fish_withdrawal(this_task_index)
		return
	end
	if error_checking_not_relaxed and isnt_table(LOADED_VEHICLE_DATA.components.hoppers) then
		warn_entire_chat("Error while withdrawing: .components.hoppers is not a table? Exiting early, this may be really bad, so please contact judge!")
		clear_fish_withdrawal(this_task_index)
		return
	end

	local total_fishes_in_vehicle, specific_fishes_in_vehicle = tally_up_fishes_in(LOADED_VEHICLE_DATA.components.hoppers)
	-- sanity
	if total_fishes_in_vehicle == nil then
		--error message is in tally_up_fishes_in()
		clear_fish_withdrawal(this_task_index)
		return
	end
	if total_fishes_in_vehicle < 0 then
		warn_entire_chat("Error while withdrawing: amount of fishes in vehicle is negative ?? Contact judge...")
		clear_fish_withdrawal(this_task_index)
		return
	end
	if my_data.state.remaining_to_withdraw < 0 then
		warn_entire_chat("Error while withdrawing: amount remaining to withdraw is negative! Contact judge...")
		clear_fish_withdrawal(this_task_index)
		return
	end

	-- logic
	if my_data.state.remaining_to_withdraw == 0 then
		debug_announce_to_chat(2, "Fish withdrawal task number "..this_task_index.." is done withdrawing!")
		formulate_send_fish_task_http(my_data)
		clear_fish_withdrawal(this_task_index)
		return
	end
	if total_fishes_in_vehicle == 0 then
		debug_announce_to_chat(2, "Ending withdrawal, "..my_data.state.remaining_to_withdraw.." left to withdraw")
		formulate_send_fish_task_http(my_data)
		clear_fish_withdrawal(this_task_index)
		return
	end
	
	-- At this point there must be fishes in the vehicle, and fishes remaining to withdraw.
	-- Withdraw from a fish type there is > 0 of in a hopper, then break.
	for hopper_index, hopper in pairs(LOADED_VEHICLE_DATA.components.hoppers) do
		for i = 13,55 do
			local fish_type, amount_of_this_fish = i, hopper.values[i]
			local new_fish_quantity = 0

			if amount_of_this_fish <= 0 then
				goto advancewithdrawal_continue_next_fish_type
			end
			
			if my_data.state.remaining_to_withdraw <= amount_of_this_fish then
				debug_announce_to_chat(3, "Enough "..hopper_resource_lookup[fish_type].." in hopper "..hopper_index.." to take from!")
				new_fish_quantity = amount_of_this_fish - my_data.state.remaining_to_withdraw
				my_data.state.specific_withdrawn[fish_type] = my_data.state.specific_withdrawn[fish_type] + my_data.state.remaining_to_withdraw
				my_data.state.remaining_to_withdraw = 0

			elseif my_data.state.remaining_to_withdraw > amount_of_this_fish then
				debug_announce_to_chat(3, "Need to withdraw more "..hopper_resource_lookup[fish_type].." than are in this hopper! Setting to 0 and retrying next time this task advances")
				new_fish_quantity = 0
				my_data.state.remaining_to_withdraw = my_data.state.remaining_to_withdraw - amount_of_this_fish
				my_data.state.specific_withdrawn[fish_type] = my_data.state.specific_withdrawn[fish_type] + amount_of_this_fish
			else
				warn_entire_chat("Error while withdrawing: not less or same to withdraw than amount of fish, and not more to withdraw than amount of fish! Contact judge...")
				clear_fish_withdrawal(this_task_index)
				return
			end

			server.setVehicleHopper(my_data.premise.vehicle_id, hopper.pos.x, hopper.pos.y, hopper.pos.z, new_fish_quantity, fish_type)
			debug_announce_to_chat(3, "server.setVehicleHopper("..my_data.premise.vehicle_id..", "..hopper.pos.x..", "..hopper.pos.y..", "..hopper.pos.z..", "..new_fish_quantity..", "..fish_type)

			do return end

			::advancewithdrawal_continue_next_fish_type::
		end
	end
end

function advance_all_fish_withdrawals()
	--debug_announce_to_chat(4, "Advancing all fish withdrawals!")
	for task_index,_ in ipairs(g_savedata.fish_withdrawal_tasks) do
		advance_this_fish_withdrawal(task_index)
	end
end

function check_queue_all_withdrawals()
	debug_announce_to_chat(3, "check_queue_all_withdrawals() called")
	local anything_got_said = false
	local slurpables = 0

	if isnt_table(rapid_info) then
		--this should maybe be an error (say regardless of debugstate) but I've only seen it happen in a normal context so I'm locking it behind debugstate
		debug_announce_to_chat(3, "Rapid info is not a table (Should be that slow interval hasn't ran yet, should fix itself in a few seconds. If like 30s of this have passed, report it to judge)")
		return
	end

	for crane_index, vehicles_and_peers_data in pairs(rapid_info) do

		local crane_tip_x, crane_tip_y, crane_tip_z = get_bros_tip_xyz(g_savedata.crane_glob_of_info[crane_index].vehicle_id)
		if isnt_number(crane_tip_x) then
			warn_entire_chat("crane x was not number..")--this error is vague because at time of writing, get_bros_tip_xyz gives better errors
			anything_got_said = true
			goto checkqueueall_continue_next_crane
		end

		for _, hopper_vehicle_and_peer in pairs(vehicles_and_peers_data) do
			local hopper_vehicle_peer_owner = hopper_vehicle_and_peer.peer_id
			local hopper_vehicle_vid = hopper_vehicle_and_peer.vehicle_id
			local found_a_single_slurpable_hopper_in_this_vehicle = false

			local loaded_vehicle_data, got_components_this_hopper_vehicle = server.getVehicleComponents(hopper_vehicle_vid)
			
			if got_components_this_hopper_vehicle == false then
				--this should maybe be an error (say regardless of debugstate) but I've only seen it happen in a normal context so I'm locking it behind debugstate
				debug_announce_to_chat(3,"Failed to determine slurpability: Couldn't get component data for hopper carrying vehicle "..hopper_vehicle_vid..", this is probably nothing but contact judge!")
				goto checkqueueall_continue_next_hopper_vehicle
			end
			if error_checking_not_relaxed and isnt_table(loaded_vehicle_data.components) then
				warn_entire_chat("Failed to determine slurpability: .components of "..hopper_vehicle_vid.." is not a table? Contact judge!")
				return
			end
			if error_checking_not_relaxed and isnt_table(loaded_vehicle_data.components.hoppers) then
				warn_entire_chat("Failed to determine slurpability: .components.hoppers "..hopper_vehicle_vid.." is not a table? Contact judge!")
				return
			end

			for hopper_index, hopper in ipairs(loaded_vehicle_data.components.hoppers) do
				
				local hopper_vehicle_transform_matrix, is_success = server.getVehiclePos(hopper_vehicle_vid, hopper.pos.x, hopper.pos.y, hopper.pos.z)
				local hopper_vehicle_x, hopper_vehicle_y, hopper_vehicle_z = hopper_vehicle_transform_matrix[13],hopper_vehicle_transform_matrix[15],hopper_vehicle_transform_matrix[14]
				
				if not is_success then
					warn_entire_chat("Failed to get transform_matrix of voxel pos of hopper number "..hopper_index.." in vehicle "..hopper_vehicle_vid)
					anything_got_said = true
					goto checkqueueall_continue_next_hopper
				end

				if positions_slurpably_close(crane_tip_x, crane_tip_y, crane_tip_z,  hopper_vehicle_x, hopper_vehicle_y, hopper_vehicle_z) then	
					
					debug_announce_to_chat(4, "Hopper close enough to be slurped!! Will queue a fish withdrawing task!")
					found_a_single_slurpable_hopper_in_this_vehicle = true
					anything_got_said = true
					slurpables = slurpables + 1
					goto checkqueueall_continue_next_hopper_vehicle

				else
					debug_announce_to_chat(4, "Hopper NOT close enough to be slurped.")
				end

				::checkqueueall_continue_next_hopper::
			end

			::checkqueueall_continue_next_hopper_vehicle::

			if found_a_single_slurpable_hopper_in_this_vehicle then
				queue_fish_withdrawal(crane_index, hopper_vehicle_vid, 75, hopper_vehicle_peer_owner)--75 standard for now
			end
		end

		::checkqueueall_continue_next_crane::
	end
	if anything_got_said == true then
		debug_announce_to_chat(3, "\n---- there's "..slurpables.." slurpable hoppers ----\n")
	end
end