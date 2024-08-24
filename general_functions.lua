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

function toboolean(str)
	local bool = false
	if str == "true" then
		 bool = true
	end
	return bool
end


function slow_interval(ticks)
	return (ticks%1800) == 0 --1800 = 30 seconds
end
function rapid_interval(ticks)
	return (ticks%300) == 0 --300 = 5 seconds
end

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
				warn_entire_chat_and_popup_for_peer(peer_id,"Spawning vehicle shares vehicle id ("..vehicle_id..") with already spawned vehicle.. contact judge..")
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