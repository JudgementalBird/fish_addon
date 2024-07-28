---- DEBUG / PRINT ----
function debugprint(...)
    local args = {...}
    local assembled = ""
    for i = 1, #args do
        assembled = assembled .. tostring(args[i]) .. ", "
    end
    
    --trailing comma and space
    if #assembled > 2 then
        assembled = assembled:sub(1, -3)
    end

    assembled = assembled:gsub(".?.?#", ""):gsub("&.?.?", "")
    
    server.announce("[test]", assembled, ANNOUNCE_TO)
end
function peerprint(peer_id,...)
	ANNOUNCE_TO = peer_id
	debugprint(...)
	ANNOUNCE_TO = -1
end
function print_r(t, fd)
	local function print(str)
		str = str or ""
		debugprint(str)
	end
	local print_r_cache={}
	local function sub_print_r(t,indent)
		local function quotesm(thing)
			if type(thing) == "string" then return "\""..thing.."\"" end
			return tostring(thing)
		end
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
		print_r_cache[tostring(t)]=true
		if (type(t)=="table") then
			for pos,val in pairs(t) do
				if (type(val)=="table") then
					print(indent.."["..quotesm(pos).."] = {")
					sub_print_r(val,indent..string.rep(" ",string.len(pos)+6))
					print(indent..string.rep(" ",string.len(pos)+4).."}")
				elseif (type(val)=="string") then
					print(indent.."["..quotesm(pos)..'] = "'..val..'"')
				else
					print(indent.."["..quotesm(pos).."] = "..tostring(val))
				end
			end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(" {")
		sub_print_r(t,"  ")
		print("}")
	else
		sub_print_r(t,"  ")
	end
	print()
end

function round(x) return math.floor((x+0.5)*100)/100 end
function printsent(request)
	if logging.sent then
		debugprint("Sent: "..request)
	end
end
function getreplyflag(reply)
	return reply:sub(1,reply:find("|")-1)
end
function withoutreplyflag(reply)
	return reply:sub(reply:find("|")+1,-1)
end




---- GLOBALS ----
ticks = 0
ANNOUNCE_TO = -1 -- print commands
usedport = 2400
logging = {--http
	sent = false
}
crane_xml_name = "CRNAE 2"

g_savedata.crane_glob_of_info = {
	{tag="id1",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 9_8"},
	{tag="id2",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 8_7"},
	{tag="id3",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 15_2"},
	{tag="id4",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 2_9"},
	{tag="id5",  queued=false,  spawned=false,  vehicle_id=-1,  location="MILITARY BASE"},
	{tag="id6",  queued=false,  spawned=false,  vehicle_id=-1,  location="HARBOUR BASE"},
	{tag="id7",  queued=false,  spawned=false,  vehicle_id=-1,  location="MULTIPLAYER ISLAND BASE"},
	{tag="id8",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 8_15"},
	{tag="id9",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 5_14"},
	{tag="id10",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 24_3"},
	{tag="id11",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 26_14"},
	{tag="id12",  queued=false,  spawned=false,  vehicle_id=-1,  location="TERMINAL SPYCAKES"},
	{tag="id13",  queued=false,  spawned=false,  vehicle_id=-1,  location="ARCTIC OIL PLATFORM"},
	{tag="id14",  queued=false,  spawned=false,  vehicle_id=-1,  location="ARCTIC ISLAND BASE"},
	{tag="id15",  queued=false,  spawned=false,  vehicle_id=-1,  location="CREATIVE BASE"}
}

---- COMMANDS ----
admin_possibilities = {
	http = {
		--{
		--	command = {"?thecommand","?alternative"},
		--	send = function(full_message, user_peer_id, is_admin, is_auth, command, one)
		--		local request = "/export/"
		--		local request = request..x.."/"..y
		--		server.httpGet(usedport, request)
		--		printsent(request)
		--	end,
		--	replyflags = {"export_reply"},
		--	handlers = {
		--		function(reply)
		--			
		--		end
		--	}
		--},
		{
			command = {"?export_g"},
			send = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local request = "/export_g/"
				
				-- missing code here that concatenates all of g_savedata into one readable string with newlines and tabs
				-- then replaces all illegal characters with legal characters so it can be sent as a target with the httpGet

				server.httpGet(usedport, request)
				printsent(request)
			end,
			replyflags = {"export_g_reply"},
			handlers = {
				function(reply)
					debugprint(withoutreplyflag(reply))
				end
			}
		},
	},
	no_http = {
		--{
		--	command = {"?thecommand","?alternative"},
		--	run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
		--		
		--	end
		--},
		{
			command = {"?fishhelp","?fhelp"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				-- v this is ENTIRELY copied from dog addon
				if one then
					--check admin http possibilities for alias match
					for _,http_possibility in ipairs(admin_possibilities.http) do
						local found = false
						for _,v in ipairs(http_possibility.command) do
							if v:find(one) then
								found = true
							end
						end
						if found then
							local text = "Command has the following aliases: "
							for k,v in ipairs(http_possibility.command) do
								text = text..v..", "
							end
							peerprint(user_peer_id,text:sub(1,-3))
						end
					end
					--check admin non-http possibilities for alias match
					for _,possibility in ipairs(admin_possibilities.no_http) do
						local found = false
						for _,v in ipairs(possibility.command) do
							if v:find(one) then
								found = true
							end
						end
						if found then
							local text = "Command has the following aliases: "
							for k,v in ipairs(possibility.command) do
								text = text..v..", "
							end
							peerprint(user_peer_id,text:sub(1,-3))
						end
					end
				else
					local commands = ""
					for k,v in ipairs(admin_possibilities.http) do
						commands = commands..v.command[1]..", "
					end
					for k,v in ipairs(admin_possibilities.no_http) do
						commands = commands..v.command[1]..", "
					end
					commands = commands:sub(1,-3)
					peerprint(user_peer_id,"Your status of admin additionally grants you the following commands, some of which may have aliases:\n"..commands)
				end
			end
			-- ^ this is ENTIRELY copied from dog addon
		},{
			command = {"?despawn_known_cranes"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				despawn_all_known_cranes()
			end
		},{
			command = {"?queue_all_cranes"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				handle_queueing_cranes()
			end
		},{
			command = {"?simreboot"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				onCreate()
			end
		},{
			command = {"?tp_to_vid"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local transform_matrix, is_success = server.getVehiclePos(one)
				if is_success then
					local is_success = server.setPlayerPos(user_peer_id, transform_matrix)
					if not is_success then
						debugprint("Failed to tp!")
					end
				else
					debugprint("Failed to get vehicle pos!")
				end
			end
		},{
			command = {"?list_known_hopper_vehicles"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				for k,v in ipairs(g_savedata.known_hopper_holding_vehicles) do
					debugprint(v)
				end
			end
		},{
			command = {"?where_hopper"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local x,y,z = get_hopper_xyz(one)
				if type(x) == "number" then
					debugprint("That hopper's at: &",x,y,z)
				end
			end
		},
	}	
}
user_possibilities = {
	http = {
	},
	no_http = {
		{
			command = {"?fishhelp","?fhelp"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				-- v this is ENTIRELY copied from dog addon with 1 word changed v
				if one then
					--check user http possibilities for alias match
					for _,http_possibility in ipairs(user_possibilities.http) do
						local found = false
						for _,v in ipairs(http_possibility.command) do
							if v:find(one) then
								found = true
							end
						end
						if found then
							local text = "Command has the following aliases: "
							for k,v in ipairs(http_possibility.command) do
								text = text..v..", "
							end
							peerprint(user_peer_id,text:sub(1,-3))
						end
					end
					--check user non-http possibilities for alias match
					for _,possibility in ipairs(user_possibilities.no_http) do
						local found = false
						for _,v in ipairs(possibility.command) do
							if v:find(one) then
								found = true
							end
						end
						if found then
							local text = "Command has the following aliases: "
							for k,v in ipairs(possibility.command) do
								text = text..v..", "
							end
							peerprint(user_peer_id,text:sub(1,-3))
						end
					end
				else
					local commands = ""
					for k,v in ipairs(user_possibilities.http) do
						commands = commands..v.command[1]..", "
					end
					for k,v in ipairs(user_possibilities.no_http) do
						commands = commands..v.command[1]..", "
					end
					commands = commands:sub(1,-3)
					peerprint(user_peer_id,"As a user you have access to the following commands, some of which may have aliases:\n"..commands)
					peerprint(user_peer_id,"FYI: Use ?fishhelp (command name) for more info about a specific command")
				end
				-- ^ this is ENTIRELY copied from dog addon with 1 word changed ^
			end
		}
	}
}

-- Crane code
function despawn_all_known_cranes()
	failures = 0
	for k,all_info_this_crane in ipairs(g_savedata.crane_glob_of_info) do
		if all_info_this_crane.spawned == true then
			is_success = server.despawnVehicle(all_info_this_crane.vehicle_id, true)
			if not is_success then
				failures = failures + 1
			else
				g_savedata.crane_glob_of_info[k].spawned = false
				g_savedata.crane_glob_of_info[k].vehicle_id = -1
			end
		end
	end

	if not (failures > 0) then
		debugprint("Despawned all cranes that were loaded in (some may still spawn in later as you move around) :yum:")
	else
		debugprint("Had "..failures.." failures while trying to despawn cranes! contact judge probably..")
	end
end

function handle_queueing_cranes()

	for k,all_info_this_crane in ipairs(g_savedata.crane_glob_of_info) do
		if (all_info_this_crane.spawned == false)  and  (all_info_this_crane.queued == false) then
			local location_name = all_info_this_crane.location
			is_success = server.spawnNamedAddonLocation(location_name)
			if is_success then
				debugprint("Successfully tried to spawn crane location "..location_name)
				g_savedata.crane_glob_of_info[k].queued = true
			else
				debugprint("Failed to spawn crane at "..location_name.." !")
			end
		end
	end
end
function handle_potential_crane_load(vehicle_id)
	local this_tag = server.getVehicleData(vehicle_id).tags_full
	
	local found_match = false
	for k,all_info_this_crane in pairs(g_savedata.crane_glob_of_info) do
		if all_info_this_crane.tag == this_tag then
			if found_match ~= false then
				debugprint("Warning! Vehicle loaded in with tag that matches MULTIPLE CRANES?? sticking with highest index one - contact judge!!!")
			end
			if all_info_this_crane.queued ~= true then
				debugprint("Warning! Vehicle loaded in matching crane tag of a NOT queued crane?? contact judge!!!")
			end
			if all_info_this_crane.spawned ~= false then
				debugprint("Warning! Vehicle loaded in matching crane tag of an ALREADY SPAWNED crane?? contact judge!!!")
			end

			found_match = k
		end
	end

	if found_match ~= false then
		debugprint("Successfully detected crane loading in at "..g_savedata.crane_glob_of_info[found_match].location)
		g_savedata.crane_glob_of_info[found_match].spawned = true
		g_savedata.crane_glob_of_info[found_match].queued = false
		g_savedata.crane_glob_of_info[found_match].vehicle_id = vehicle_id
	end
end
function handle_potential_known_crane_unload(this_vehicle_id)
	--scan through cranes and try to match a spawned crane's vehicle id to this unloading vehicle's id. If no crane matches, we're done here.
	local matched_crane_index = false
	for k,all_info_this_crane in ipairs(g_savedata.crane_glob_of_info) do
		if all_info_this_crane.vehicle_id == this_vehicle_id then
			if matched_crane_index ~= false then
				debugprint("Warning! Unloading vehicle matches vehicle id with MULTIPLE CRANES?? sticking with highest index one - contact judge!!!")
			end
			if all_info_this_crane.queued ~= false then
				debugprint("Warning! Unloading vehicle is somehow a queued crane?? contact judge!!!")
			end
			if all_info_this_crane.spawned ~= true then
				debugprint("Warning! Unloading vehicle matches vehicle id with a NOT SPAWNED CRANE?? contact judge!!!")
			end

			matched_crane_index = k
		end
	end

	if matched_crane_index ~= false then
		g_savedata.crane_glob_of_info[matched_crane_index].spawned = false
		g_savedata.crane_glob_of_info[matched_crane_index].vehicle_id = -1
		debugprint("All logic completed successfully to detect and handle the despawning of crane at "..g_savedata.crane_glob_of_info[matched_crane_index].location.."!")
	end
end
function is_known_crane(questioned_vehicle_id)
	local is_known_crane = false
	for _,all_info_this_crane in ipairs(g_savedata.crane_glob_of_info) do
		if all_info_this_crane.vehicle_id == questioned_vehicle_id then
			
			if is_known_crane == true then
				debugprint("Warning, vehicle id "..questioned_vehicle_id.." matches with multiple cranes! contact judge!")
			end
			is_known_crane = true
		end
	end

	return is_known_crane
end

-- hopper carrying vehicle code
function assert_hopper_vehicle_list_exists()
	if not (type(g_savedata.known_hopper_holding_vehicles) == "table") then
		g_savedata.known_hopper_holding_vehicles = {}
	end
end
function handle_potential_hopper_vehicle_load(vehicle_id)
	assert_hopper_vehicle_list_exists()

	local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(vehicle_id)
	if is_success then
		if (next(LOADED_VEHICLE_DATA.components.hoppers)~=nil) then
			debugprint("Found hopper!")
			table.insert(g_savedata.known_hopper_holding_vehicles,vehicle_id)
		else
			--we don't wanna check up on this vehicle since no hopper
			--debugprint("No hopper found, ignored "..vehicle_id..".")
		end
	else
		debugprint("Failed to get vehicle components of vid "..vehicle_id.." to check for presence of hoppers ): \ncontact judge!!!")
	end
end
function handle_potential_hopper_vehicle_unload(vehicle_id)
	assert_hopper_vehicle_list_exists()

	local found_match = 0
	for k,known_hopper_vehicle_vid in ipairs(g_savedata.known_hopper_holding_vehicles) do
		if known_hopper_vehicle_vid == vehicle_id then
			found_match = k
		end
	end

	if found_match > 0 then
		table.remove(g_savedata.known_hopper_holding_vehicles,k)

	else
		--found_match's start 0 value never got replaced, there was no known hopper vehicle with this vehicle id, remove nothing from list of known hopper holding vehicles
	end
end

function slow_interval(ticks)
	return (ticks%400) == 0 --1080 = 18 seconds
end
function rapid_interval(ticks)
	return (ticks%60) == 0 --120 = 2 seconds
end

function matrixes_roughly_close(first_matrix,second_matrix)
	local threshold = 100

	if math.abs(first_matrix[13]-second_matrix[13]) > threshold then --x 13
		return false
	end
	if math.abs(first_matrix[15]-second_matrix[15]) > threshold then --y 15
		return false
	end
	if math.abs(first_matrix[14]-second_matrix[14]) > threshold then --z 14
		return false
	end

	return true
end
function recreate_rapid_info_table()
	--does a rough distance check from all known hopper holding vehicles to all known cranes and reconstructs rapid info with whos close to what crane location
	if type(g_savedata.known_hopper_holding_vehicles) ~= "table" then
		return
	end

	rapid_info = nil
	rapid_info = {}

	--construct
	for _,hopper_vehicle_vid in ipairs(g_savedata.known_hopper_holding_vehicles) do
		local hopper_vehicle_transform_matrix, is_success = server.getVehiclePos(hopper_vehicle_vid)
		if is_success then

			for this_crane_index,all_info_this_crane in ipairs(g_savedata.crane_glob_of_info) do
				if all_info_this_crane.spawned == true then
					local known_crane_transform_matrix, is_success = server.getVehiclePos(all_info_this_crane.vehicle_id)
					if is_success then
						if matrixes_roughly_close(hopper_vehicle_transform_matrix,known_crane_transform_matrix) then
							if type(rapid_info[this_crane_index]) ~= "table" then
								rapid_info[this_crane_index] = {}
							end

							table.insert(rapid_info[this_crane_index], hopper_vehicle_vid)
						end

					else
						debugprint("Failed to get position of crane at "..all_info_this_crane.location)
					end
				end
			end
		else
			debugprint("Failed to get position of hopper carrying vehicle with vid "..hopper_vehicle_vid)
		end
	end

	--just potential warning from down here
	local looped_amount = 0
	--for each location
	for checker_crane_index, checker_vehicle_ids in pairs(rapid_info) do

		--for each vehicle id in that location
		for checker_index, checker_vehicle_id in ipairs(checker_vehicle_ids) do

			--for each location
			for checked_crane_index, checked_vehicle_ids in pairs(rapid_info) do

				--for each vehicle id in that location
				for checked_index, checked_vehicle_id in ipairs(checked_vehicle_ids) do

					looped_amount = looped_amount + 1

					--if they aren't at the same index in the same location
					if not (checker_index == checked_index and checker_crane_index == checked_crane_index) then

						-- if they have the same id, warn
						if checker_vehicle_id == checked_vehicle_id then
							debugprint("Warning! Vehicle with id "..checker_vehicle_id.." at "..g_savedata.crane_glob_of_info[checker_crane_index].location.." matches vehicle id with "..checked_vehicle_id.." at "..g_savedata.crane_glob_of_info[checked_crane_index].location.."! contact judge!")
						end
					end
				end
			end
		end
	end
	debugprint("Looped "..looped_amount.." times while reconstructing rapid_info table!!")
end

function get_hopper_xyz(vehicle_id,optional_name)
	--[[
	LOADED_VEHICLE_DATA = {
		components = { 
			hoppers = {
				[i] = {
					pos = {x=0,y=0,z=0},
					capacity = 0,
					values = {
						[1] = 0,
						[2] = 0,
						[...] = 0,
						[54] = 0,
						[55] = 0,
						[0] = 0
					},
					name = ""
				}
			}
		}
	}
	]]
	local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(vehicle_id)
	if is_success ~= true then
		if type(optional_name) == "string" then
			debugprint("Failed to get components of vehicle with id "..vehicle_id.." that owns "..optional_name.."!")
		else
			debugprint("Failed to get components of vehicle with id "..vehicle_id.."!")
		end
		return nil,nil,nil
	end
	for _,hopper in ipairs(LOADED_VEHICLE_DATA.components.hoppers) do
		if type(optional_name) == "string" then
			if hopper.name == optional_name then
				debugprint("Found "..optional_name.." !!!")


				local transform_matrix, is_success = server.getVehiclePos(vehicle_id, hopper.pos.x, hopper.pos.y, hopper.pos.z)
				if is_success then
					debugprint(optional_name.." is at: &",transform_matrix[13],transform_matrix[15],transform_matrix[14])
					return transform_matrix[13],transform_matrix[15],transform_matrix[14]
				else
					debugprint("Failed to get transform_matrix of voxel pos of "..optional_name.." !")
				end
			end
		else
			local transform_matrix, is_success = server.getVehiclePos(vehicle_id, hopper.pos.x, hopper.pos.y, hopper.pos.z)
			if is_success then
				debugprint("Vehicle "..vehicle_id.." is at: &",transform_matrix[13],transform_matrix[15],transform_matrix[14])
				return transform_matrix[13],transform_matrix[15],transform_matrix[14]
			else
				debugprint("Failed to get transform_matrix of voxel pos of hopper in vehicle "..vehicle_id)
			end
		end
	end
end

function positions_slurpably_close(x1,y1,z1, x2,y2,z2)
	if math.abs(x1-x2) > 1.5 then
		return false
	end
	if math.abs(y1-y2) > 1.5 then
		return false
	end
	if math.abs(z1-z2) > 2.5 then
		return false
	end

	return true
end
function inform_slurps()
	
	if type(rapid_info) ~= "table" then
		--debugprint("Rapid info is not a table ?")
		return
	end

	for crane_index, vehicle_ids in pairs(rapid_info) do

		local crane_tip_x, crane_tip_y, crane_tip_z = get_hopper_xyz(g_savedata.crane_glob_of_info[crane_index].vehicle_id, "bro's tip")
		if type(crane_tip_x) == "number" then

			for _, hopper_vehicle_vid in ipairs(vehicle_ids) do
				--[[
				LOADED_VEHICLE_DATA = {
					components = { 
						hoppers = {
							[i] = {
								pos = {x=0,y=0,z=0},
								capacity = 0,
								values = {
									[1] = 0,
									[2] = 0,
									[...] = 0,
									[54] = 0,
									[55] = 0,
									[0] = 0
								},
								name = ""
							}
						}
					}
				}
				]]
				local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(hopper_vehicle_vid)
				if is_success == true then
					for hopper_index, hopper in ipairs(LOADED_VEHICLE_DATA.components.hoppers) do
						local transform_matrix, is_success = server.getVehiclePos(hopper_vehicle_vid, hopper.pos.x, hopper.pos.y, hopper.pos.z)
						if is_success then
							if positions_slurpably_close(crane_tip_x,crane_tip_y,crane_tip_z, transform_matrix[13],transform_matrix[15],transform_matrix[14]) then
								debugprint("Hopper close enough to be slurped!!")
							else
								debugprint("Hopper NOT close enough to be slurped.")
							end
						else
							debugprint("Failed to get transform_matrix of voxel pos of hopper number "..hopper_index.." in vehicle "..hopper_vehicle_vid)
						end
					end
				else
					debugprint("Failed to get component data for hopper carrying vehicle "..hopper_vehicle_vid)
				end
			end
		else
			debugprint("crane x was not number..")
		end
	end
end

function execute_potential_user_possibility(full_message, user_peer_id, is_admin, is_auth, command, one)
	for possibility_key,possibility in ipairs(user_possibilities.http) do
		local match = false
		for k,v in ipairs(possibility.command) do
			if (command == v) then
				match = true
			end
		end
		if match == true then
			possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one)
		elseif type(possibility.commandfunction) == "function" then
			if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one) then
				possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one)
			end
		end
	end
	for possibility_key,possibility in ipairs(user_possibilities.no_http) do
		local match = false
		for k,v in ipairs(possibility.command) do
			if (command == v) then
				match = true
			end
		end
		if match == true then
			possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one)
		elseif type(possibility.commandfunction) == "function" then
			if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one) then
				possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one)
			end
		end
	end
end
function execute_potential_admin_possibility(full_message, user_peer_id, is_admin, is_auth, command, one)
	if is_admin then
		for possibility_key,possibility in ipairs(admin_possibilities.http) do
			local match = false
			for k,v in ipairs(possibility.command) do
				if (command == v) then
					match = true
				end
			end
			if match == true then
				possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one)
			elseif type(possibility.commandfunction) == "function" then
				if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one) then
					possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one)
				end
			end
		end
		for possibility_key,possibility in ipairs(admin_possibilities.no_http) do
			local match = false
			for k,v in ipairs(possibility.command) do
				if (command == v) then
					match = true
				end
			end
			if match == true then
				possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one)
			elseif type(possibility.commandfunction) == "function" then
				if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one) then
					possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one)
				end
			end
		end
	end
end

function handle_http_response(port,request,reply)
	if (reply == "Connection closed unexpectedly") or (reply == "connect(): Connection refused") then
		print(reply..".. contact judge on discord..,,")
	else
		received_replyflag = getreplyflag(reply)
		print("Replyflag is: "..received_replyflag)

		for _,possibility in ipairs(user_possibilities.http) do
			for replyflagkey,replyflag in ipairs(possibility.replyflags) do
				if (received_replyflag == replyflag) then
					possibility.handlers[replyflagkey](reply)
				end
			end
		end

		for _,possibility in ipairs(admin_possibilities.http) do
			for replyflagkey,replyflag in ipairs(possibility.replyflags) do
				if (received_replyflag == replyflag) then
					possibility.handlers[replyflagkey](reply)
				end
			end
		end
	end
end

---- !! CALLBACKS !! ----
---- !! CALLBACKS !! ----

function onCreate(is_world_create)
	despawn_all_known_cranes()
	handle_queueing_cranes()
end

function onTick()
	ticks = ticks + 1
	if slow_interval(ticks) then
		recreate_rapid_info_table()
		debugprint("There are "..(#g_savedata.known_hopper_holding_vehicles).." known hopper carrying vehicles!")
	end
	if rapid_interval(ticks) then
		inform_slurps()
	end
end

function onVehicleLoad(vehicle_id)
	debugprint("Spawning vehicle id: "..vehicle_id)
	handle_potential_crane_load(vehicle_id)
	if not is_known_crane(vehicle_id) then
		handle_potential_hopper_vehicle_load(vehicle_id)
	end
end

function onVehicleUnload(vehicle_id)
	handle_potential_known_crane_unload(vehicle_id)
	handle_potential_hopper_vehicle_unload(vehicle_id)
end
function onVehicleDespawn(vehicle_id, peer_id)
	handle_potential_known_crane_unload(vehicle_id)
	handle_potential_hopper_vehicle_unload(vehicle_id)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one)
	--print("onCustomCommand() called with '"..command.."'. User is admin? "..tostring(is_admin)..". User is auth? "..tostring(is_auth)..".")
	
	--|To add user commands that USE HTTP, add to 'user_possibilities.http'.|
	--|To add user commands that DON'T use HTTP, add to 'user_possibilities.no_http'.|
	execute_potential_user_possibility(full_message, user_peer_id, is_admin, is_auth, command, one)
	--|To add admin only commands that USE HTTP, add to 'admin_possibilities.http'.|
	--|To add admin only commands that DON'T use HTTP, add to 'admin_possibilities.no_http'.|
	execute_potential_admin_possibility(full_message, user_peer_id, is_admin, is_auth, command, one)
end

function httpReply(port, request, reply)
	-- this shit was STRAIGHT RIPPED from my dog addon so I dont know if its good
	handle_http_response(port,request,reply)
end
