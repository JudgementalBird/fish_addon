--test concluded

ticks = 0
ANNOUNCE_TO = -1 -- print commands

g_savedata.spawning_queue_data = {}

g_savedata.crane_tags = {
	{tag="id1"},
	{tag="id2"},
	{tag="id3"},
	{tag="id4"},
	{tag="id5"},
	{tag="id6"},
	{tag="id7"},
	{tag="id8"},
	{tag="id9"},
	{tag="id10"},
	{tag="id11"},
	{tag="id12"},
	{tag="id13"},
	{tag="id14"},
	{tag="id15"}
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
			command = {"?setfish"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
				server.setVehicleHopper(one, two, three, four)
				peerprint(user_peer_id, "Tried to set hopper with name "..two.." on vehicle "..one.." to have "..three.." "..tostring(hopper_resource_lookup[four]).." ("..four..")")
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

function is_crane(questioned_vehicle_id)
	local this_tag = server.getVehicleData(questioned_vehicle_id).tags_full
	
	local found_match = false
	for crane_index, this_crane in pairs(g_savedata.crane_tags) do

		--logic
		if this_crane.tag ~= this_tag then
			goto craneload_continue_next_crane
		end
		--sanity checks
		if found_match == true then
			warn_entire_chat("Warning! Vehicle loaded in with tag that matches MULTIPLE CRANES?? sticking with highest index one - contact judge!!!")
		end

		found_match = true

		::craneload_continue_next_crane::
	end

	if found_match ~= false then
		debug_announce_to_chat(2, "Crane (vid &",questioned_vehicle_id,"#) loaded in.")
	end
	return found_match
end

---- !! CALLBACKS !! ----
function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
	--debug_announce_to_chat(2, "onvehiclespawn called !")
	debug_announce_to_chat(2, "Vehicle spawned! vehicle_id: &",vehicle_id,"# peer_id: &",peer_id,"# group_cost: &",group_cost,"# group_id: &",group_id)
end

function onVehicleLoad(vehicle_id)
	--debug_announce_to_chat(2, "onvehicleload called !")
	debug_announce_to_chat(2, "Loading vehicle id: "..vehicle_id)
	local fuck
	if is_crane(vehicle_id) then
		fuck = "is"
	else
		fuck = "is not"
	end
	debug_announce_to_chat(2, "This vehicle "..fuck.." a crane!")
end

function onVehicleUnload(vehicle_id)
	--debug_announce_to_chat(3, "onvehicleunload called !")
	debug_announce_to_chat(2, "Unloading vehicle id: "..vehicle_id)
end
function onVehicleDespawn(vehicle_id, peer_id)
	--debug_announce_to_chat(3, "onvehicledespawn called !")
	debug_announce_to_chat(2, "Vehicle despawned! vehicle_id: &",vehicle_id,"# peer_id: &",peer_id)
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
	
	--|To add admin only commands that USE HTTP, add to 'admin_possibilities.http' (in admin_possibilities.lua).|
	--|To add admin only commands that DON'T use HTTP, add to 'admin_possibilities.no_http' (in admin_possibilities.lua).|
	execute_potential_admin_possibility(full_message, user_peer_id, is_admin, is_auth, command, one, two, three, four)
end

