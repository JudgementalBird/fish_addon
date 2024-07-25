---- DEBUG / USEFUL ----
ANNOUNCE_TO = -1
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
  -- http --
usedport = 2400
logging = {
	sent = false
}

  -- cranes --
crane_xml_name = "CRNAE 2"
crane_matrices = {
	multiplayer_island = {
		[1] = -0.0,
		[2] = 0.0,
		[3] = -1.0,
		[4] = 0.0,
		[5] = 0.0,
		[6] = 1.0,
		[7] = 0.0,
		[8] = 0.0,
		[9] = 1.0,
		[10] = 0.0,
		[11] = -0.0,
		[12] = 0.0,
		[13] = -16645.83129664,
		[14] = 10.7,
		[15] = -12171,
		[16] = 1.0
	}
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
			command = {"?despawn","?d"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				server.despawnVehicle(tonumber(one), true)
			end
		},{
			command = {"?simreboot"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				onCreate()
			end
		},{
			command = {"?clean_up_cranes"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				clean_up_cranes()
			end
		},{
			command = {"?spawn_all_cranes"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				spawn_all_cranes()
			end
		},{
			command = {"?findhopper"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
				local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(one)
				if is_success then
					print_r(LOADED_VEHICLE_DATA.components.hoppers)
				else
					debugprint("Failure !")
				end
			end
		},{
			command = {"?wherehopper"},
			run = function(full_message, user_peer_id, is_admin, is_auth, command, one)
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
				local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(one)
				if is_success then
					for k,hopper in pairs(LOADED_VEHICLE_DATA.components.hoppers) do
						local transform_matrix, is_success = server.getVehiclePos(one, hopper.pos.x, hopper.pos.y, hopper.pos.z)
						if is_success then
							print_r(transform_matrix)
						else
							debugprint("Failed to get transform_matrix of voxel pos of hopper "..k.." !")
						end
					end
				else
					debugprint("Failed to get vehicle components!")
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
			end
			-- ^ this is ENTIRELY copied from dog addon with 1 word changed ^
		}
	}
}

function clean_up_cranes()
	-- Delete all cranes
	if g_savedata.cranes then
		local any_failure = false
		--if we have a saved table containing all the crane vehicle group ids, loop through said table and try to despawn every group in it
		for location_name,vehicle_id in pairs(g_savedata.cranes) do
			local is_success = server.despawnVehicle(vehicle_id, true)
			--inform if we fail
			if not is_success then
				any_failure = true
				debugprint("Failed to despawn vehicle: &", vehicle_id)
			end
		end

		--after despawning, if we succeeded, delete the entry in g_savedata to mark that all cranes are despawned
		if not any_failure then
			g_savedata.cranes = nil
			debugprint("Despawned all cranes :yum:")
		end
	end
end
function spawn_all_cranes()
	-- Spawn all cranes in crane_matrices
	g_savedata.cranes = {}
	
	local addon_index = server.getAddonIndex()
	local location_index = server.getLocationIndex(addon_index, "OCEAN")
	local component_data = server.getLocationComponentData(addon_index, location_index, i)
	
	for location_name,transform_matrix in pairs(crane_matrices) do
		
		local vehicle_id, is_success = server.spawnAddonVehicle(transform_matrix, addon_index, component_data.id)
		
		if is_success then
			debugprint("Successfully spawned crane at "..location_name..", with group id of "..vehicle_id)
			g_savedata.cranes.location_name = vehicle_id
		else
			debugprint("Failed to spawn crane at "..location_name)
		end
	end
end
function is_not_crane(vehicle_id)
	if g_savedata.cranes then
		for _,crane_v_id in pairs(g_savedata.cranes) do
			if crane_v_id == vehicle_id then
				return false
			end
		end
	end
	return true
end

---- NON-CRANE VEHICLES ----
g_savedata.vehicle_info_queue = {}--holds on-spawn data for hopper-carrying vehicles across loads and unloads until they are explicitly despawned.
--g_savedata.vehicle_info_queue = {
--	[vehicle_id] = {owner_peer_id=0,spawnpos={x=0,y=0,z=0},group_id,group_cost}
--}

g_savedata.slow_check_storage_vehicles = {}--list of all vehicles to check position of infrequently. Also holds all data from onVehicleSpawn(). onVehicle
--g_savedata.slow_check_storage_vehicles = {
--	[vehicle_id] = {owner_peer_id=0,spawnpos={x=0,y=0,z=0},group_id,group_cost}
--}

g_savedata.rapid_check_vehicles = {}
--g_savedata.rapid_check_vehicles = {
--	[n] = vehicle_id --of the vehicle in g_savedata.slow_check_storage_vehicles, so g_savedata.slow_check_storage_vehicles[vehicle_id] gives the whole vehicle
--}

--[[
GOALS:
Every slow interval:
	- Update electricity in all cranes
	- Check roughly if any vehicles with a hopper are near cranes, update list with rapid check mfs

Every fast interval:
	- Check rapid check list mfs compared to cranes to determine if they can slurp	

DONE:
Server creation:
	- Look for and delete all cranes
	- Spawn all cranes, keep a list of their IDs and stuff for updating elec later or replacing them
]]

---- PROGRAM ----
function onCreate(is_world_create) -- server created or loaded
	-- delete all cranes if there are any
	-- spawn all cranes, vehicle ids stored as values in g_savedata.cranes
	clean_up_cranes()
	spawn_all_cranes()
end

ticks = 0
function onTick()
	ticks = ticks + 1
	if (ticks%720) == 0 then -- SLOW INTERVAL:
		--Update electricity in all cranes
		--Check roughly if any vehicles with a hopper are near cranes, update list with rapid check mfs
		--debugprint("Slow interval")
	end
	if (ticks%55) == 0 then -- FAST INTERVAL:
		-- Check rapid check list mfs compared to cranes to determine if they can slurp	
		--debugprint("Fast interval")
	end
end

function onVehicleSpawn(vehicle_id, peer_id, x, y, z, group_cost, group_id)
	debugprint("spawned vehicle id: "..vehicle_id.." / group id: "..group_id)
	
	if is_not_crane(vehicle_id) then
		--add this vehicle to g_savedata.vehicle_info_queue
		g_savedata.vehicle_info_queue[vehicle_id]={owner_peer_id=peer_id,spawnpos={x=x,y=y,z=z},group_id=group_id,group_cost=group_cost}
	else
		debugprint("onVehicleSpawn ignored crane v_id: &",vehicle_id)
	end
end

function onVehicleLoad(vehicle_id)
	debugprint("Vehicle loaded.")

	if is_not_crane(vehicle_id) then
		local LOADED_VEHICLE_DATA, is_success = server.getVehicleComponents(vehicle_id)
		if (next(LOADED_VEHICLE_DATA.components.hoppers)~=nil) then
			debugprint("Found hopper.")
			--this vehicle has a hopper, add it to rough check list
			g_savedata.slow_check_storage_vehicles[vehicle_id] = g_savedata.vehicle_info_queue[vehicle_id]
			debugprint("Pointer to spawn-data added to slow thing, original pointer deleted from queue.")
			debugprint("Verification: slow.group_cost = &",g_savedata.slow_check_storage_vehicles[vehicle_id].group_cost)
		else
			debugprint("No hopper found.")
			--no hopper of any kind found in this vehicle, remove from queue cuz we don't wanna check up on it
			g_savedata.vehicle_info_queue[vehicle_id] = nil
			debugprint("Pointer to spawn-data deleted from queue.")
		end
	else
		debugprint("onVehicleLoad ignored crane v_id: &",vehicle_id)
	end
end

function onVehicleDespawn(vehicle_id, peer_id)
	if is_not_crane(vehicle_id) then
		--non-crane vehicle has been explicitly despawned, so remove from g_savedata.vehicle_info_queue since we will never need on-spawn info again for it,
		--and from g_savedata.slow_check_storage_vehicles and g_savedata.rapid_check_vehicles since we will never need to check up on it.
		g_savedata.vehicle_info_queue[vehicle_id] = nil
		g_savedata.slow_check_storage_vehicles[vehicle_id] = nil
		g_savedata.rapid_check_vehicles[vehicle_id] = nil
	else
		debugprint("onVehicleDespawn ignored crane v_id: &",vehicle_id)
	end
end

function onVehicleUnload(vehicle_id)
	if is_not_crane(vehicle_id) then
		--non-crane vehicle has unloaded, put it in a state so it is like it is loading in for the first time. Delete from g_savedata.slow_check_storage_vehicles and g_savedata.rapid_check_vehicles.
		g_savedata.slow_check_storage_vehicles[vehicle_id] = nil
		g_savedata.rapid_check_vehicles[vehicle_id] = nil
	else
		debugprint("onVehicleUnload ignored crane v_id: &",vehicle_id)
	end
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, one)
--print("onCustomCommand() called with '"..command.."'. User is admin? "..tostring(is_admin)..". User is auth? "..tostring(is_auth)..".")
	
	--|To add user commands that USE HTTP, add to 'user_possibilities.http'.|
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
	--|To add user commands that DON'T use HTTP, add to 'user_possibilities.no_http'.|
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

	if is_admin then
		--|To add admin only commands that USE HTTP, add to 'admin_possibilities.http'.|
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
		--|To add admin only commands that DON'T use HTTP, add to 'admin_possibilities.no_http'.|
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

function httpReply(port, request, reply)
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
