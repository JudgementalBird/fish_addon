function send_peer_http(request)
	server.httpGet(usedport, request)
	printsent(request)
end

function formulate_send_fish_task_http(task_data)
	local crane_index, specific_withdrawn = math.floor(task_data.premise.crane_index), task_data.state.specific_withdrawn
	local withdrew_total = 0
	for _,amount_of_this_fish in pairs(specific_withdrawn) do
		withdrew_total = withdrew_total + amount_of_this_fish
	end

	if withdrew_total == 0 then
		return
	end

	local steam_id = get_steam_id(task_data.premise.peer_id)
	if steam_id == nil then
		--error message is in get_steamid()
		return
	end

	local request = "/withdrew/"..crane_index.."/"..steam_id.."/"
	
	local withdrawn_string = ""
	for i = 13,79 do
		local fish_type, amount_of_this_fish = i, specific_withdrawn[i]

		if amount_of_this_fish > 0 then
			withdrawn_string = withdrawn_string.."a"..math.floor(fish_type).."bc"..math.floor(amount_of_this_fish).."dx"
		end
	end

	request = request..withdrawn_string
	
	server.httpGet(usedport, request)
	printsent(request)
end

function handle_http_response(port,request,reply)
	if (reply == "Connection closed unexpectedly") or (reply == "connect(): Connection refused") then
		warn_entire_chat(reply..".. contact judge on discord..,,")
	else
		if not hasreplyflag(reply) then
			return
		end
		received_replyflag = getreplyflag(reply)
		debug_announce_to_chat(3, "Replyflag is: "..received_replyflag)

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