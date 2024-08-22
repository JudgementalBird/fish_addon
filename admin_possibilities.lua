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
				for _,hopper_vehicle_data in ipairs(g_savedata.known_hopper_holding_vehicles) do
					local loaded_string = "spawned"
					if hopper_vehicle_data.loaded == false then
						loaded_string = "not spawned"
					end
					peerprint("vid: &",hopper_vehicle_data.vehicle_id,"# (peer &",hopper_vehicle_data.peer_id,"#) - &",loaded_string)
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