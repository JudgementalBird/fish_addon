ticks = 0
ANNOUNCE_TO = -1 -- print commands

g_savedata.spawning_queue_data = {}

g_savedata.crane_glob_of_info = {
	{tag="id1",  loaded=false,  vehicle_id=-1,  location="SAWYER 9_8"},
	{tag="id2",  loaded=false,  vehicle_id=-1,  location="SAWYER 8_7"},
	{tag="id3",  loaded=false,  vehicle_id=-1,  location="SAWYER 15_2"},
	{tag="id4",  loaded=false,  vehicle_id=-1,  location="SAWYER 2_9"},
	{tag="id5",  loaded=false,  vehicle_id=-1,  location="MILITARY BASE"},
	{tag="id6",  loaded=false,  vehicle_id=-1,  location="HARBOUR BASE"},
	{tag="id7",  loaded=false,  vehicle_id=-1,  location="MULTIPLAYER ISLAND BASE"},
	{tag="id8",  loaded=false,  vehicle_id=-1,  location="MEIER 8_15"},
	{tag="id9",  loaded=false,  vehicle_id=-1,  location="MEIER 5_14"},
	{tag="id10",  loaded=false,  vehicle_id=-1,  location="MEIER 24_3"},
	{tag="id11",  loaded=false,  vehicle_id=-1,  location="MEIER 26_14"},
	{tag="id12",  loaded=false,  vehicle_id=-1,  location="TERMINAL SPYCAKES"},
	{tag="id13",  loaded=false,  vehicle_id=-1,  location="ARCTIC OIL PLATFORM"},
	{tag="id14",  loaded=false,  vehicle_id=-1,  location="ARCTIC ISLAND BASE"},
	{tag="id15",  loaded=false,  vehicle_id=-1,  location="CREATIVE BASE"}
}

logging = {
	http_send = true,
	debug = {
		"no debug",
		"highest level debug",
		"involved debug",
		"ALL debug"
	},
	debugstate = 1,
	get_debug = function()
		return logging.debug[logging.debugstate]
	end,
	increment_debug = function()
		logging.debugstate = (logging.debugstate + 1)
		if logging.debugstate > (#logging.debug) then
			logging.debugstate = 1
		end
		return logging.debug[logging.debugstate]
	end
}

hopper_resource_lookup = {
	[0] = "coal",
	[1] = "iron",
	[2] = "aluminium",
	[3] = "gold",
	[4] = "gold_dirt",
	[5] = "uranium",
	[6] = "ingot_iron",
	[7] = "ingot_steel",
	[8] = "ingot_aluminium",
	[9] = "ingot_gold_impure",
	[10] = "ingot_gold",
	[11] = "ingot_uranium",
	[12] = "solid_propellant",
	[13] = "Anchovy",
	[14] = "Anglerfish",
	[15] = "Arctic Char",
	[16] = "Ballan Lizardfish",
	[17] = "Ballan Wrasse",
	[18] = "Barreleye Fish",
	[19] = "Black Bream",
	[20] = "Black Dragonfish",
	[21] = "Clownfish",
	[22] = "Cod",
	[23] = "Dolphinfish",
	[24] = "Gulper Eel",
	[25] = "Haddock",
	[26] = "Hake",
	[27] = "Herring",
	[28] = "John Dory",
	[29] = "Labrus",
	[30] = "Lanternfish",
	[31] = "Mackerel",
	[32] = "Midshipman",
	[33] = "Perch",
	[34] = "Pike",
	[35] = "Pinecone Fish",
	[36] = "Pollock",
	[37] = "Red Mullet",
	[38] = "Rockfish",
	[39] = "Sablefish",
	[40] = "Salmon",
	[41] = "Sardine",
	[42] = "Scad",
	[43] = "Sea Bream",
	[44] = "Halibut",
	[45] = "Sea Piranha",
	[46] = "Seabass",
	[47] = "Slimehead",
	[48] = "Snapper",
	[49] = "Gold Snapper",
	[50] = "Snook",
	[51] = "Spadefish",
	[52] = "Trout",
	[53] = "Tubeshoulders fish",
	[54] = "Viperfish",
	[55] = "Yellowfin Tuna"
}
---- DEBUG / PRINT ----
function debugprint(...) --
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
	
	server.announce("[Fish Expansion]", assembled, ANNOUNCE_TO)
end
function peerprint(peer_id,...)
	ANNOUNCE_TO = peer_id
	debugprint(...)
	ANNOUNCE_TO = -1
end
--just different names to provide intent where calling:
function warn_entire_chat(...)
	debugprint(...)
end
function announce_to_entire_chat(...)
	debugprint(...)
end
function debug_announce_to_chat(debug_level,...)
	if logging.debugstate >= debug_level then
		debugprint(...)
	end
end
function warn_peer_in_chat(peer_id, ...)
	peerprint(peer_id, ...)
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

function printsent(request)
	debug_announce_to_chat(2, "Sent: "..request)
end

function getreplyflag(reply)
	return reply:sub(1,reply:find("|") -1)
end
function withoutreplyflag(reply)
	return reply:sub(reply:find("|")+1, -1)
end
function hasreplyflag(reply)
	return is_number(reply:find("|"))
end

function getpeerflag(reply)
	return reply:sub(reply:find("#")+1, -1)
end
function withoutpeerflag(reply)
	return reply:sub(1, reply:find("#")-1)
end
admin_possibilities = {
	http = {
		{
			command = {"?test_http"},
			send = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local request = "/test_message/13/4/58/765482599353/42"
				server.httpGet(usedport, request)
				printsent(request)
			end,
			replyflags = {"test_response"},
			handlers = {
				function(reply)
					announce_to_entire_chat(withoutreplyflag(reply))
				end
			}
		}
	},
	no_http = {
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
			command = {"?debugmode","?dbgm"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local newsetting = tonumber(one)
				if (newsetting == nil) or (newsetting > 4) or (newsetting < 1) then
					local newlogging = logging.increment_debug()
					peerprint(user_peer_id, "Debug mode set to "..newlogging)
				else
					logging.debugstate = newsetting
					peerprint(user_peer_id, "Debug mode set to "..logging.get_debug())
				end
			end
		},{
			command = {"?disable_logic"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				disable_much_core_functionality = not disable_much_core_functionality
				peerprint(user_peer_id,"Is much core logic disabled? "..tostring(disable_much_core_functionality))
			end
		},{
			command = {"?relax_errors"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				error_checking_not_relaxed = not error_checking_not_relaxed
				peerprint(user_peer_id,"Is script doing expensive sanity checks? "..tostring(error_checking_not_relaxed))
			end
		},{
			command = {"?despawn_known_cranes"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				despawn_all_known_cranes()
			end
		},{
			command = {"?normal_rehandle_hopper_vehicle_load"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				if one == nil then
					peerprint(user_peer_id, "This commands needs a vehicle id!")
					return
				end
				local vid = tonumber(one)
				if vid == nil then
					peerprint(user_peer_id, "This commands needs an argument that can be converted to a number as vehicle id!")
					return
				end
				handle_potential_hopper_vehicle_load(vid)
				peerprint(user_peer_id, "Called normal handling function.,,")
			end
		},{
			command = {"?hard_rehandle_hopper_vehicle_load"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one, two)
				if (one == nil) or (two == nil) then
					peerprint(user_peer_id, "This commands needs a vehicle id, and a peer id!")
					return
				end
				local vid, pid = tonumber(one), tonumber(two)
				if (vid == nil) or (pid == nil) then
					peerprint(user_peer_id, "This commands needs two arguments that can be converted to numbers as vehicle id and peer id!")
					return
				end
				table.insert(g_savedata.known_hopper_holding_vehicles, {vehicle_id=vid, peer_id=pid})
				peerprint(user_peer_id, "Inserted {vehicle_id="..vid..", peer_id="..pid.."}")
			end
		},{
			command = {"?clear_known_hopper_vehicle"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				if (one == nil) then
					peerprint(user_peer_id, "This function needs a vehicle id!")
					return
				end
				local vid = tonumber(one)
				if vid == nil then
					peerprint(user_peer_id, "This commands needs an argument that can be converted to a number as vehicle id!")
					return
				end
				local match = false
				for k,hopper_vehicle_data in ipairs(g_savedata.known_hopper_holding_vehicles) do
					if hopper_vehicle_data.vehicle_id == vid then
						if match ~= false then
							warn_entire_chat("While clearing known hopper vehicle, multiple vehicles matched the provided id! Contact judge!")
						end
						match = k
					end
				end
				if match ~= false then
					table.remove(g_savedata.known_hopper_holding_vehicles, match)
					peerprint(user_peer_id,"Removed known hopper carrying vehicle with vid "..vid.." at index "..k)
				else
					peerprint(user_peer_id,"Didn't find that one in the table")
				end
			end
		},{
			command = {"?setfish"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
				server.setVehicleHopper(one, two, three, four)
				peerprint(user_peer_id, "Tried to set hopper with name "..two.." on vehicle "..one.." to have "..three.." "..tostring(hopper_resource_lookup[four]).." ("..four..")")
			end
		},{
			command = {"?queue_all_cranes"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				handle_queueing_cranes()
				peerprint(user_peer_id, "Tried to handle queueing all cranes!")
			end
		},{
			command = {"?simreboot"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				peerprint(user_peer_id, "Calling onCreate() !")
				onCreate()
			end
		},{
			command = {"?tp_to_vid"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local transform_matrix, is_success = server.getVehiclePos(one)
				if is_success then
					local is_success = server.setPlayerPos(user_peer_id, transform_matrix)
					if not is_success then
						warn_peer_in_chat(user_peer_id, "Failed to tp!")
					end
					peerprint(user_peer_id, "Success!")
				else
					warn_peer_in_chat(user_peer_id, "Failed to get vehicle pos!")
				end
			end
		},{
			command = {"?tp_to_pid"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				if (one == nil) then
					peerprint(user_peer_id, "This function needs a peer id!")
					return
				end
				local pid = tonumber(one)
				if pid == nil then
					peerprint(user_peer_id, "This commands needs an argument that can be converted to a number as peer id!")
					return
				end
				local transform_matrix, is_success = server.server.getPlayerPos(pid)
				if is_success then
					local is_success = server.setPlayerPos(user_peer_id, transform_matrix)
					if not is_success then
						warn_peer_in_chat(user_peer_id, "Failed to tp!")
					end
					peerprint(user_peer_id, "Success!")
				else
					warn_peer_in_chat(user_peer_id, "Failed to get target player pos!")
				end
			end
		},{
			command = {"?list_known_hopper_vehicles"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				for _,v in ipairs(g_savedata.known_hopper_holding_vehicles) do
					peerprint("vid: "..v.vehicle_id.." (peer "..v.peer_id..")")
				end
			end
		},{
			command = {"?distset","?ds"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local transform_matrix, is_success = server.getPlayerPos(user_peer_id)
				if not is_success then
					warn_entire_chat("Failed to get player position")
					return
				end
				if not g_savedata.positions then
					g_savedata.player_dist_checks = {}
				end
				local pos = {x=transform_matrix[13],y=transform_matrix[15],z=transform_matrix[14]}
				peerprint(user_peer_id,"Stored x: &",pos.x,"y: &",pos.y,"z: &",pos.z)
				g_savedata.player_dist_checks[get_steam_id(user_peer_id)] = pos
			end
		},{
			command = {"?distcheck","?dc"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				if (g_savedata.player_dist_checks == nil) or (g_savedata.player_dist_checks[get_steam_id(user_peer_id)] == nil) then
					peerprint(user_peer_id, "Use ?distset first")
					return
				end
				local transform_matrix, is_success = server.getPlayerPos(user_peer_id)
				if not is_success then
					warn_entire_chat("Failed to get player position")
					return
				end
				local now_pos = {x=transform_matrix[13],y=transform_matrix[15],z=transform_matrix[14]}
				local old_pos = g_savedata.player_dist_checks[get_steam_id(user_peer_id)]
				local dist = math.sqrt((now_pos.x-old_pos.x)^2+(now_pos.y-old_pos.y)^2+(now_pos.z-old_pos.z))
				peerprint(user_peer_id, dist.." meters from last ?distset")
			end
		}
	}	
}
function execute_potential_admin_possibility(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
	if is_admin then
		for possibility_key,possibility in ipairs(admin_possibilities.http) do
			local match = false
			for k,v in ipairs(possibility.command) do
				if (command == v) then
					match = true
				end
			end
			if match == true then
				possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
			elseif type(possibility.commandfunction) == "function" then
				if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four) then
					possibility.send(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
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
				possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
			elseif type(possibility.commandfunction) == "function" then
				if possibility.commandfunction(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four) then
					possibility.run(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
				end
			end
		end
	end
end
function is_table(a)
	return type(a) == "table"
end
function isnt_table(a)
	return type(a) ~= "table"
end
function is_bool(a)
	return type(a) == "boolean"
end
function isnt_bool(a)
	return type(a) ~= "boolean"
end
function is_number(a)
	return type(a) == "number"
end
function isnt_number(a)
	return type(a) ~= "number"
end
function is_string(a)
	return type(a) == "string"
end
function isnt_string(a)
	return type(a) ~= "string"
end

function round(x) return math.floor((x+0.5)*100)/100 end

function get_steam_id(peer_id)
	local steam_id
	local PLAYER_LIST = server.getPlayers()
	for _, player in pairs(PLAYER_LIST) do
		if player.id == peer_id then
			steam_id = player.steam_id
			break
		end
	end
	if isnt_number(steam_id) then
		warn_entire_chat("Peer "..peer_id.." wasn't found in returned PLAYER_LIST?? contact judge bruh")
		return
	end
	return steam_id
end

function get_peer_id(steam_id)
	local steam_id = tostring(steam_id)
	local peer_id
	local PLAYER_LIST = server.getPlayers()
	for _, player in pairs(PLAYER_LIST) do
		local this_player_steam_id = tostring(player.steam_id)
		debug_announce_to_chat(2,"Comparing &",this_player_steam_id,"# and &",steam_id)
		if this_player_steam_id:find(steam_id) then
			peer_id = player.id
			break
		end
	end
	if peer_id == nil then
		warn_entire_chat("Steamid &",steam_id,"# wasn't found in returned PLAYER_LIST?? contact judge bruh")
		return
	end
	debug_announce_to_chat(2,"Connected steam id &",steam_id,"# to peer id &",peer_id)
	return peer_id
end

function note_down_spawn_data(vehicle_id, peer_id)
	if peer_id == -1 then
		debug_announce_to_chat(2,"A vehicle was spawned by the server!")
		return
	end
	if error_checking_not_relaxed then
		for _,data in ipairs(g_savedata.spawning_queue_data) do
			if data.vehicle_id == vehicle_id then
				warn_entire_chat("Spawning vehicle shares vehicle id ("..vehicle_id..") with already spawned vehicle.. contact judge..")
			end
		end
	end

	table.insert(g_savedata.spawning_queue_data, {vehicle_id=vehicle_id, peer_id=peer_id})
end

function has_any_hopper(LOADED_VEHICLE_DATA)
	return (next(LOADED_VEHICLE_DATA.components.hoppers)~=nil)
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
function track_crane_as_despawned(crane_index)
	g_savedata.crane_glob_of_info[crane_index].loaded = false
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
		if this_crane.loaded ~= true then
			goto despawncranes_continue_next_crane
		end
		if error_checking_not_relaxed and isnt_bool(this_crane.loaded) then
			warn_entire_chat("this_crane.loaded is not a boolean? Contact judge..")
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

function track_crane_as_spawned(crane_index, its_vehicle_id)
	g_savedata.crane_glob_of_info[crane_index].loaded = true
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
		if this_crane.loaded ~= false then
			warn_entire_chat("Warning! Vehicle loaded in matching crane tag of an ALREADY LOADED crane?? contact judge!!!")
		end

		found_match = crane_index

		::craneload_continue_next_crane::
	end

	if found_match ~= false then
		debug_announce_to_chat(2, "Crane loaded in at "..g_savedata.crane_glob_of_info[found_match].location)
		track_crane_as_spawned(found_match, vehicle_id)
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

